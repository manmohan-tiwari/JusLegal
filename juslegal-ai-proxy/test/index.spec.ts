import { createExecutionContext, waitOnExecutionContext } from "cloudflare:test";
import { describe, expect, it } from "vitest";
import worker, { type Env } from "../src/index";

const testEnv: Env = {
	ALLOWED_ORIGIN: "https://juslegal-2196.web.app",
	GROQ_API_KEY: "groq-key",
	OPENROUTER_API_KEY: "openrouter-key",
	PROXY_AUTH_TOKEN: "test-client-token",
};

async function dispatch(path: string, init: RequestInit = {}) {
	const request = new Request(`https://proxy.example${path}`, init);
	const ctx = createExecutionContext();
	const response = await worker.fetch(request, testEnv, ctx);
	await waitOnExecutionContext(ctx);
	return response;
}

describe("JusLegal AI proxy", () => {
	it("allows the configured origin", async () => {
		const response = await dispatch("/unknown", {
			method: "POST",
			headers: { Origin: testEnv.ALLOWED_ORIGIN, "Content-Type": "application/json" },
		});
		expect(response.status).toBe(404);
		expect(response.headers.get("Access-Control-Allow-Origin")).toBe(testEnv.ALLOWED_ORIGIN);
	});

	it("rejects an unconfigured origin", async () => {
		const response = await dispatch("/callGroq", {
			method: "POST",
			headers: { Origin: "https://evil.example", "Content-Type": "application/json" },
		});
		expect(response.status).toBe(403);
		expect(response.headers.get("Access-Control-Allow-Origin")).toBeNull();
	});

	it("answers an allowed CORS preflight", async () => {
		const response = await dispatch("/callOpenRouter", {
			method: "OPTIONS",
			headers: { Origin: testEnv.ALLOWED_ORIGIN },
		});
		expect(response.status).toBe(204);
		expect(response.headers.get("Access-Control-Allow-Headers")).toContain("Authorization");
	});

	it("rejects an unauthenticated provider request", async () => {
		const response = await dispatch("/callOpenRouter", {
			method: "POST",
			headers: { Origin: testEnv.ALLOWED_ORIGIN, "Content-Type": "application/json" },
			body: "{}",
		});
		expect(response.status).toBe(401);
		expect(await response.json()).toEqual({ error: "Unauthorized" });
	});
});
