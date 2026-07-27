import {
	env,
	createExecutionContext,
	waitOnExecutionContext,
	SELF,
} from "cloudflare:test";
import { describe, it, expect } from "vitest";
import worker from "../src/index";

// For now, you'll need to do something like this to get a correctly-typed
// `Request` to pass to `worker.fetch()`.
const IncomingRequest = Request<unknown, IncomingRequestCfProperties>;

describe("JusLegal AI proxy", () => {
	it("returns 404 with CORS headers for an unknown route (unit style)", async () => {
		const request = new IncomingRequest("http://example.com/unknown", {
			method: "POST",
		});
		// Create an empty context to pass to `worker.fetch()`.
		const ctx = createExecutionContext();
		const response = await worker.fetch(request, env, ctx);
		// Wait for all `Promise`s passed to `ctx.waitUntil()` to settle before running test assertions
		await waitOnExecutionContext(ctx);
		expect(response.status).toBe(404);
		expect(response.headers.get("Access-Control-Allow-Origin")).toBe("*");
		expect(await response.json()).toEqual({ error: "Not found" });
	});

	it("returns 405 for unsupported methods (integration style)", async () => {
		const response = await SELF.fetch("https://example.com/callOpenRouter");
		expect(response.status).toBe(405);
		expect(response.headers.get("Access-Control-Allow-Origin")).toBe("*");
		expect(await response.json()).toEqual({ error: "Method not allowed" });
	});
});
