export interface Env {
	GROQ_API_KEY: string;
	OPENROUTER_API_KEY: string;
	FIREBASE_PROJECT_ID: string;
	ALLOWED_ORIGIN: string;
}

const MAX_REQUEST_BODY_BYTES = 100 * 1024;
const MAX_MESSAGES = 20;
const MAX_MESSAGE_CONTENT_CHARS = 20_000;
const MAX_TOTAL_MESSAGE_CHARS = 60_000;
const MAX_TOKENS = 2_400;
const CLOCK_SKEW_SECONDS = 60;
const FIREBASE_JWKS_URL =
	"https://www.googleapis.com/service_accounts/v1/jwk/securetoken@system.gserviceaccount.com";

interface FirebaseClaims {
	aud?: unknown;
	iss?: unknown;
	sub?: unknown;
	exp?: unknown;
	iat?: unknown;
	auth_time?: unknown;
}

interface FirebaseJwk extends JsonWebKey {
	kid?: string;
}

interface FirebaseJwks {
	keys?: FirebaseJwk[];
}

let cachedJwks: { expiresAt: number; keys: Map<string, CryptoKey> } | null = null;

function isOriginAllowed(origin: string, env: Env): boolean {
	if (origin === env.ALLOWED_ORIGIN) return true;

	try {
		const url = new URL(origin);
		return url.protocol === "http:" && url.hostname === "localhost";
	} catch {
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
	body: Record<string, unknown>,
	status: number,
	cors: Headers,
): Response {
	const headers = new Headers(cors);
	headers.set("Content-Type", "application/json; charset=utf-8");
	headers.set("Cache-Control", "no-store");
	headers.set("X-Content-Type-Options", "nosniff");
	return new Response(JSON.stringify(body), { status, headers });
}

function extractBearerToken(request: Request): string | null {
	const token = request.headers.get("Authorization")?.match(/^Bearer\s+([^\s]+)$/i)?.[1];
	return token || null;
}

function base64UrlToBytes(value: string): Uint8Array {
	const normalized = value.replace(/-/g, "+").replace(/_/g, "/").padEnd(Math.ceil(value.length / 4) * 4, "=");
	const binary = atob(normalized);
	return Uint8Array.from(binary, (char) => char.charCodeAt(0));
}

function decodeJson<T>(value: string): T | null {
	try {
		const bytes = base64UrlToBytes(value);
		return JSON.parse(new TextDecoder().decode(bytes)) as T;
	} catch {
		return null;
	}
}

async function getFirebaseKeys(forceRefresh = false): Promise<Map<string, CryptoKey>> {
	const now = Date.now();
	if (!forceRefresh && cachedJwks && cachedJwks.expiresAt > now) return cachedJwks.keys;

	const response = await fetch(FIREBASE_JWKS_URL, {
		headers: { Accept: "application/json" },
	});
	if (!response.ok) throw new Error(`Firebase JWKS request failed: ${response.status}`);

	const cacheControl = response.headers.get("Cache-Control") ?? "";
	const maxAgeMatch = cacheControl.match(/max-age=(\d+)/i);
	const maxAgeSeconds = maxAgeMatch ? Number(maxAgeMatch[1]) : 3600;
	const jwks = (await response.json()) as FirebaseJwks;
	if (!Array.isArray(jwks.keys) || jwks.keys.length === 0) {
		throw new Error("Firebase JWKS response did not contain keys");
	}

	const keys = new Map<string, CryptoKey>();
	for (const jwk of jwks.keys) {
		if (typeof jwk.kid !== "string") continue;
		const key = await crypto.subtle.importKey(
			"jwk",
			jwk,
			{ name: "RSASSA-PKCS1-v1_5", hash: "SHA-256" },
			false,
			["verify"],
		);
		keys.set(jwk.kid, key);
	}

	cachedJwks = {
		expiresAt: now + Math.max(60, Math.min(maxAgeSeconds, 86_400)) * 1000,
		keys,
	};
	return keys;
}

async function validateFirebaseToken(token: string, projectId: string): Promise<string | null> {
	const parts = token.split(".");
	if (parts.length !== 3) return null;

	const header = decodeJson<{ alg?: unknown; kid?: unknown }>(parts[0]);
	const claims = decodeJson<FirebaseClaims>(parts[1]);
	if (
		!header ||
		header.alg !== "RS256" ||
		typeof header.kid !== "string" ||
		!claims ||
		claims.aud !== projectId ||
		claims.iss !== `https://securetoken.google.com/${projectId}` ||
		typeof claims.sub !== "string" ||
		claims.sub.length === 0 ||
		claims.sub.length > 128 ||
		typeof claims.exp !== "number" ||
		typeof claims.iat !== "number"
	) {
		return null;
	}

	const now = Math.floor(Date.now() / 1000);
	if (claims.exp <= now - CLOCK_SKEW_SECONDS || claims.iat > now + CLOCK_SKEW_SECONDS) {
		return null;
	}
	if (typeof claims.auth_time === "number" && claims.auth_time > now + CLOCK_SKEW_SECONDS) {
		return null;
	}

	const signingInput = new TextEncoder().encode(`${parts[0]}.${parts[1]}`);
	let signature: Uint8Array;
	try {
		signature = base64UrlToBytes(parts[2]);
	} catch {
		return null;
	}

	try {
		let keys = await getFirebaseKeys();
		let key = keys.get(header.kid);
		// Firebase can rotate signing keys before the cached max-age expires.
		// Refresh once when a token references an unknown kid.
		if (!key) {
			keys = await getFirebaseKeys(true);
			key = keys.get(header.kid);
		}
		if (!key) return null;
		const valid = await crypto.subtle.verify(
			{ name: "RSASSA-PKCS1-v1_5" },
			key,
			signature,
			signingInput,
		);
		return valid ? claims.sub : null;
	} catch {
		return null;
	}
}

async function hasValidBearerToken(request: Request, env: Env): Promise<boolean> {
	const token = extractBearerToken(request);
	if (!token) return false;
	return (await validateFirebaseToken(token, env.FIREBASE_PROJECT_ID)) !== null;
}

async function readRequestBody(request: Request): Promise<Uint8Array | null> {
	const contentLength = request.headers.get("Content-Length");
	if (contentLength !== null) {
		const length = Number(contentLength);
		if (!Number.isSafeInteger(length) || length < 0 || length > MAX_REQUEST_BODY_BYTES) return null;
	}

	if (!request.body) return new Uint8Array();
	const reader = request.body.getReader();
	const chunks: Uint8Array[] = [];
	let total = 0;

	try {
		while (true) {
			const { done, value } = await reader.read();
			if (done) break;
			if (!value) continue;
			total += value.byteLength;
			if (total > MAX_REQUEST_BODY_BYTES) {
				await reader.cancel();
				return null;
			}
			chunks.push(value);
		}
	} finally {
		reader.releaseLock();
	}

	const body = new Uint8Array(total);
	let offset = 0;
	for (const chunk of chunks) {
		body.set(chunk, offset);
		offset += chunk.byteLength;
	}
	return body;
}

type PayloadValidationResult =
	| { payload: Record<string, unknown>; reason: null }
	| { payload: null; reason: string };

export function parseRequestJson(value: string): unknown | null {
	try {
		return JSON.parse(value) as unknown;
	} catch {
		return null;
	}
}

export function sanitizeUpstreamPayload(raw: unknown, expectedModel: string): PayloadValidationResult {
	if (!raw || typeof raw !== "object" || Array.isArray(raw)) {
		return { payload: null, reason: "invalid_json_object" };
	}
	const input = raw as Record<string, unknown>;
	// The browser deliberately does not choose a model. If a legacy client sends
	// one, it is ignored; the endpoint's server-side configuration below remains
	// the sole authority for the upstream model.
	if (!Array.isArray(input.messages) || input.messages.length === 0 || input.messages.length > MAX_MESSAGES) {
		return { payload: null, reason: "messages_count_invalid" };
	}

	let totalChars = 0;
	const messages: Array<{ role: string; content: string }> = [];
	for (const item of input.messages) {
		if (!item || typeof item !== "object" || Array.isArray(item)) {
			return { payload: null, reason: "message_invalid" };
		}
		const message = item as Record<string, unknown>;
		if (!['system', 'user', 'assistant'].includes(String(message.role)) || typeof message.content !== "string") {
			return { payload: null, reason: "message_role_or_content_invalid" };
		}
		if (message.content.length > MAX_MESSAGE_CONTENT_CHARS) {
			return { payload: null, reason: "message_content_too_long" };
		}
		totalChars += message.content.length;
		if (totalChars > MAX_TOTAL_MESSAGE_CHARS) {
			return { payload: null, reason: "messages_content_too_long" };
		}
		messages.push({ role: String(message.role), content: message.content });
	}

	const temperature = typeof input.temperature === "number" ? input.temperature : 0.2;
	if (!Number.isFinite(temperature) || temperature < 0 || temperature > 1) {
		return { payload: null, reason: "temperature_invalid" };
	}
	const maxTokens = typeof input.max_tokens === "number" ? input.max_tokens : 1200;
	if (!Number.isInteger(maxTokens) || maxTokens < 1 || maxTokens > MAX_TOKENS) {
		return { payload: null, reason: "max_tokens_invalid" };
	}
	if (
		"response_format" in input &&
		(!input.response_format ||
			typeof input.response_format !== "object" ||
			Array.isArray(input.response_format) ||
			(input.response_format as Record<string, unknown>).type !== "json_object")
	) {
		return { payload: null, reason: "response_format_invalid" };
	}

	const output: Record<string, unknown> = {
		model: expectedModel,
		messages,
		temperature,
		max_tokens: maxTokens,
		stream: false,
	};
	if (
		input.response_format &&
		typeof input.response_format === "object" &&
		(input.response_format as Record<string, unknown>).type === "json_object"
	) {
		output.response_format = { type: "json_object" };
	}
	return { payload: output, reason: null };
}

async function getOpenRouterFreeModels(apiKey: string): Promise<string[]> {
	try {
		const res = await fetch("https://openrouter.ai/api/v1/models", {
			headers: { Authorization: `Bearer ${apiKey}` },
		});
		if (!res.ok) return [];
		const data = (await res.json()) as { data?: Array<{ id?: string }> };
		if (!Array.isArray(data.data)) return [];
		return data.data
			.map((m) => m.id)
			.filter((id): id is string => typeof id === "string" && id.endsWith(":free"));
	} catch {
		return [];
	}
}

export default {
	async fetch(request, env): Promise<Response> {
		const cors = corsHeaders(request, env);
		const origin = request.headers.get("Origin");
		if (origin !== null && !isOriginAllowed(origin, env)) {
			return jsonResponse({ error: "Origin not allowed" }, 403, cors);
		}

		if (request.method === "OPTIONS") {
			return new Response(null, { status: 204, headers: cors });
		}
		if (request.method !== "POST") {
			return jsonResponse({ error: "Method not allowed" }, 405, cors);
		}
		if (!request.headers.get("Content-Type")?.toLowerCase().startsWith("application/json")) {
			return jsonResponse({ error: "Content-Type must be application/json" }, 415, cors);
		}

		const { pathname } = new URL(request.url);

		let candidateModels: string[] | null = null;
		if (pathname === "/callGroq") {
			candidateModels = [
				"llama-3.1-8b-instant",
				"llama-3.3-70b-specdec",
				"mixtral-8x7b-32768",
				"gemma2-9b-it",
			];
		} else if (pathname === "/callOpenRouter") {
			const dynamicFree = await getOpenRouterFreeModels(env.OPENROUTER_API_KEY);
			candidateModels = [
				"google/gemini-2.0-flash-exp:free",
				"meta-llama/llama-3.1-8b-instruct:free",
				"deepseek/deepseek-r1:free",
				...dynamicFree,
			];
			// Deduplicate candidate model list
			candidateModels = Array.from(new Set(candidateModels));
		}

		if (!candidateModels) return jsonResponse({ error: "Not found" }, 404, cors);

		if (!(await hasValidBearerToken(request, env))) {
			return jsonResponse({ error: "Unauthorized" }, 401, cors);
		}

		try {
			const body = await readRequestBody(request);
			if (body === null) return jsonResponse({ error: "Request body too large" }, 413, cors);

			const raw = parseRequestJson(new TextDecoder().decode(body));
			const validation = sanitizeUpstreamPayload(raw, candidateModels[0]);

			if (!validation.payload) {
				return jsonResponse(
					{
						error: "Invalid AI request payload",
						reason: validation.reason,
					},
					400,
					cors,
				);
			}

			let lastErrorDetail = "";
			let lastStatus = 502;

			for (const modelName of candidateModels) {
				const payload = { ...validation.payload, model: modelName };
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
						body: JSON.stringify(payload),
					},
				);

				if (upstreamResponse.ok) {
					const headers = new Headers(cors);
					headers.set("Content-Type", "application/json; charset=utf-8");
					headers.set("Cache-Control", "no-store");
					headers.set("X-Content-Type-Options", "nosniff");
					return new Response(upstreamResponse.body, { status: upstreamResponse.status, headers });
				}

				lastStatus = upstreamResponse.status;
				lastErrorDetail = await upstreamResponse.text();
			}

			return jsonResponse(
				{ error: "AI provider request failed", upstreamStatus: lastStatus, detail: lastErrorDetail },
				502,
				cors,
			);
		} catch {
			return jsonResponse({ error: "Internal error" }, 500, cors);
		}
	},
} satisfies ExportedHandler<Env>;