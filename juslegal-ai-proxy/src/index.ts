export interface Env {
	GROQ_API_KEY: string;
	OPENROUTER_API_KEY: string;
	PROXY_AUTH_TOKEN: string;
	ALLOWED_ORIGIN: string;
}

const MAX_REQUEST_BODY_BYTES = 100 * 1024;

function isAllowedOrigin(request: Request, env: Env): boolean {
	const origin = request.headers.get("Origin");
	return origin === null || origin === env.ALLOWED_ORIGIN;
}

function corsHeaders(request: Request, env: Env): Headers {
	const headers = new Headers({
		"Access-Control-Allow-Methods": "POST, OPTIONS",
		"Access-Control-Allow-Headers": "Authorization, Content-Type",
		Vary: "Origin",
	});
	if (request.headers.get("Origin") === env.ALLOWED_ORIGIN) {
		headers.set("Access-Control-Allow-Origin", env.ALLOWED_ORIGIN);
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

function hasValidBearerToken(request: Request, env: Env): boolean {
	const token = request.headers.get("Authorization")?.match(/^Bearer\s+(.+)$/i)?.[1];
	if (!token || !env.PROXY_AUTH_TOKEN || token.length !== env.PROXY_AUTH_TOKEN.length) {
		return false;
	}

	let difference = 0;
	for (let index = 0; index < token.length; index++) {
		difference |= token.charCodeAt(index) ^ env.PROXY_AUTH_TOKEN.charCodeAt(index);
	}
	return difference === 0;
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
		const cors = corsHeaders(request, env);
		if (!isAllowedOrigin(request, env)) {
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
