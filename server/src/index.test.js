const request = require("supertest");
const { app, server, PORT } = require("./index");

describe("Express App", () => {
	jest.setTimeout(10000);

	it('should return "Hello World!" on GET /', async () => {
		const response = await request(app).get("/");
		expect(response.status).toBe(200);
		expect(response.text).toBe("Hello World!");
	});

	it("should listen on the correct port from .env", () => {
		expect(PORT).toBeDefined();
		expect(PORT).toMatch(/\d+/);
	});

	afterAll((done) => {
		server.close(() => {
			console.log(`Test server closed.`);
			done();
		});
	});
});
