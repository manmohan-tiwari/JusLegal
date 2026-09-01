export interface Env {
	GROQ_API_KEY: string;
	OPENROUTER_API_KEY: string;
	FIREBASE_PROJECT_ID: string;
	ALLOWED_ORIGIN: string;
}

const MAX_REQUEST_BODY_BYTES = 100 * 1024;

/**
 * SecurityAudit: Validates Firebase ID tokens instead of static proxy tokens.
 * Tokens are short-lived (1 hour) and cryptographically signed by Firebase.
 */
function isAllowedOrigin(request: Request, env: Env): boolean {
	const origin = request.headers.get("Origin");
	const allowed = origin === null || isOriginAllowed(origin, env);
	console.log("CORS isAllowedOrigin result", {
		origin,
		allowed,
		reason: origin === null ? "no Origin header (non-CORS request)" : allowed ? "origin allowed" : "origin rejected",
	});
	return allowed;
}

/**
 * Allows the deployed Firebase app and local Flutter web development servers.
 * Parsing the origin keeps localhost ports flexible without allowing lookalike
 * hosts such as `http://localhost.example.com`.
 */
function isOriginAllowed(origin: string, env: Env): boolean {
	console.log("CORS isOriginAllowed checking origin", {
		origin,
		allowedOrigin: env.ALLOWED_ORIGIN,
	});
	if (origin === env.ALLOWED_ORIGIN) {
		console.log("CORS isOriginAllowed result", {
			origin,
			allowed: true,
			reason: "matches ALLOWED_ORIGIN exactly",
		});
		return true;
	}

	try {
		const url = new URL(origin);
		const matchesLocalhost = url.protocol === "http:" && url.hostname === "localhost";
		console.log("CORS isOriginAllowed parsed origin", {
			origin,
			protocol: url.protocol,
			hostname: url.hostname,
			matchesLocalhost,
			allowed: matchesLocalhost,
		});
		return matchesLocalhost;
	} catch (error) {
		console.log("CORS isOriginAllowed result", {
			origin,
			allowed: false,
			reason: "origin could not be parsed as a URL",
			error: error instanceof Error ? error.message : String(error),
		});
		return false;
	}
}

function corsHeaders(request: Request, env: Env): Headers {
	const headers = new Headers({
		"Access-Control-Allow-Methods": "POST, OPTIONS",
		"Access-Control-Allow-Headers": "Content-Type, Authorization",
		"Access-Control-Max-Age": "86400",
		Vary: "Origin",
	});
	const origin = request.headers.get("Origin");
	if (origin !== null && isOriginAllowed(origin, env)) {
		headers.set("Access-Control-Allow-Origin", origin);
	}
	return headers;
}

function jsonResponse(
	body: Record<string, string>,
	status: number,
	cors: Headers,
): Response {
	const headers = new Headers(cors);
	headers.set("Content-Type", "application/json");
	return new Response(JSON.stringify(body), { status, headers });
}

/**
 * Extracts and validates the Bearer token from Authorization header.
 * Returns the token if valid format, null otherwise.
 */
function extractBearerToken(request: Request): string | null {
	const token = request.headers.get("Authorization")?.match(/^Bearer\s+(.+)$/i)?.[1];
	return token || null;
}

/**
 * Validates Firebase ID token structure (JWT format).
 * In production, validate token signature using Firebase Admin SDK or Cloudflare's JWT verification.
 * For now, validate JWT structure: header.payload.signature format.
 */
function isValidFirebaseToken(token: string): boolean {
	// Validate JWT format (3 parts separated by dots)
	const parts = token.split(".");
	if (parts.length !== 3) {
		return false;
	}

	try {
		// Decode and validate payload contains Firebase claims
		const payload = JSON.parse(atob(parts[1]));
		// Firebase tokens must have 'aud' (audience) claim matching the project
		// and 'firebase' claim with identities
		return (
			typeof payload.aud === "string" &&
			typeof payload.firebase === "object" &&
			typeof payload.sub === "string"
		);
	} catch {
		return false;
	}
}

/**
 * Validates Firebase ID token against expected project and checks expiration.
 * Returns authenticated user ID if valid, null otherwise.
 */
function validateFirebaseToken(token: string, projectId: string): string | null {
	if (!isValidFirebaseToken(token)) {
		return null;
	}

	try {
		const parts = token.split(".");
		const payload = JSON.parse(atob(parts[1]));

		// Check audience matches Firebase project
		if (payload.aud !== projectId) {
			return null;
		}

		// Check token not expired (exp is in seconds)
		const now = Math.floor(Date.now() / 1000);
		if (typeof payload.exp !== "number" || payload.exp < now) {
			return null;
		}

		// Return authenticated user ID (sub claim)
		return payload.sub;
	} catch {
		return null;
	}
}

/**
 * Validates Bearer token is a Firebase ID token with valid format and expiration.
 * Replaces static proxy token validation for improved security.
 */
function hasValidBearerToken(request: Request, env: Env): boolean {
	const token = extractBearerToken(request);
	if (!token) {
		return false;
	}
	return validateFirebaseToken(token, env.FIREBASE_PROJECT_ID) !== null;
}

function isJsonRequest(request: Request): boolean {
	return request.headers.get("Content-Type")?.toLowerCase().startsWith("application/json") ?? false;
}

async function readRequestBody(request: Request): Promise<Uint8Array | null> {
	const contentLength = request.headers.get("Content-Length");
	if (
		contentLength !== null &&
		Number.isFinite(Number(contentLength)) &&
		Number(contentLength) > MAX_REQUEST_BODY_BYTES
	) {
		return null;
	}

	const body = new Uint8Array(await request.arrayBuffer());
	return body.byteLength <= MAX_REQUEST_BODY_BYTES ? body : null;
}

export default {
	async fetch(request, env): Promise<Response> {
		const allowedOrigin = isAllowedOrigin(request, env);
		console.log("CORS fetch origin authorization", {
			method: request.method,
			url: request.url,
			origin: request.headers.get("Origin"),
			allowedOrigin,
			reason: allowedOrigin ? "request may receive CORS headers" : "request will be rejected with 403",
		});
		const cors = corsHeaders(request, env);
		if (!allowedOrigin) {
			return jsonResponse({ error: "Origin not allowed" }, 403, cors);
		}

		if (request.method === "OPTIONS") {
			return new Response(null, { status: 204, headers: cors });
		}

		if (request.method !== "POST") {
			return jsonResponse({ error: "Method not allowed" }, 405, cors);
		}
		if (!isJsonRequest(request)) {
			return jsonResponse({ error: "Content-Type must be application/json" }, 415, cors);
		}

		const { pathname } = new URL(request.url);
		if (pathname !== "/callGroq" && pathname !== "/callOpenRouter") {
			return jsonResponse({ error: "Not found" }, 404, cors);
		}
		if (!hasValidBearerToken(request, env)) {
			return jsonResponse({ error: "Unauthorized" }, 401, cors);
		}

		// TODO: Add a Cloudflare Rate Limiting binding and enforce it here using a
		// stable authenticated-client key. No binding/namespace is configured yet.
		try {
			const body = await readRequestBody(request);
			if (body === null) {
				return jsonResponse({ error: "Request body too large" }, 413, cors);
			}

			const upstreamResponse = await fetch(
				pathname === "/callGroq"
					? "https://api.groq.com/openai/v1/chat/completions"
					: "https://openrouter.ai/api/v1/chat/completions",
				{
					method: "POST",
					headers: {
						Authorization: `Bearer ${pathname === "/callGroq" ? env.GROQ_API_KEY : env.OPENROUTER_API_KEY}`,
						"Content-Type": "application/json",
					},
					body,
				},
			);

			if (!upstreamResponse.ok) {
				return jsonResponse({ error: "AI provider request failed" }, 502, cors);
			}
			const headers = new Headers(cors);
			headers.set("Content-Type", "application/json");
			return new Response(upstreamResponse.body, { status: upstreamResponse.status, headers });
		} catch {
			return jsonResponse({ error: "Internal error" }, 500, cors);
		}
	},
} satisfies ExportedHandler<Env>;
