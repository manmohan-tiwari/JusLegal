export interface Env {
	GROQ_API_KEY: string;
	OPENROUTER_API_KEY: string;
	ALLOWED_ORIGIN: string;
}

const MAX_REQUEST_BODY_BYTES = 100 * 1024;

function corsHeaders(env: Env): Headers {
	return new Headers({
		"Access-Control-Allow-Origin": env.ALLOWED_ORIGIN,
		"Access-Control-Allow-Methods": "POST, OPTIONS",
		"Access-Control-Allow-Headers": "Content-Type",
	});
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
		const cors = corsHeaders(env);

		if (request.method === "OPTIONS") {
			return new Response(null, { status: 204, headers: cors });
		}

		if (request.method !== "POST") {
			return jsonResponse({ error: "Method not allowed" }, 405, cors);
		}

		try {
			const body = await readRequestBody(request);
			if (body === null) {
				return jsonResponse({ error: "Request body too large" }, 413, cors);
			}

			const { pathname } = new URL(request.url);
			let upstreamResponse: Response;

			if (pathname === "/callGroq") {
				upstreamResponse = await fetch(
					"https://api.groq.com/openai/v1/chat/completions",
					{
						method: "POST",
						headers: {
							Authorization: `Bearer ${env.GROQ_API_KEY}`,
							"Content-Type": "application/json",
						},
						body,
					},
				);
			} else if (pathname === "/callOpenRouter") {
				upstreamResponse = await fetch(
					"https://openrouter.ai/api/v1/chat/completions",
					{
						method: "POST",
						headers: {
							Authorization: `Bearer ${env.OPENROUTER_API_KEY}`,
							"Content-Type": "application/json",
						},
						body,
					},
				);
			} else {
				return jsonResponse({ error: "Not found" }, 404, cors);
			}

			const headers = new Headers(cors);
			headers.set("Content-Type", "application/json");
			return new Response(upstreamResponse.body, {
				status: upstreamResponse.status,
				headers,
			});
		} catch {
			return jsonResponse({ error: "Internal error" }, 500, cors);
		}
	},
} satisfies ExportedHandler<Env>;
