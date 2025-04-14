import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";
import path from "path";

import dotenv from "dotenv";
dotenv.config({ path: "/app_data/.env" });

var PORT = process.env.CLIENT_PORT;
var SERVER_PORT = process.env.SERVER_PORT;
let open = false;

if (!PORT) {
	dotenv.config({ path: path.resolve(__dirname, "../.env") });
	PORT = process.env.CLIENT_PORT;
	SERVER_PORT = process.env.SERVER_PORT;
	open = true;
}

export default defineConfig({
	plugins: [react()],
	define: {
		"import.meta.env.VITE_API_URL": JSON.stringify(
			`http://localhost:${SERVER_PORT}`
		),
	},
	server: {
		port: PORT,
		host: true,
		open: open,
	},
	test: {
		globals: true,
		environment: "jsdom",
		setupFiles: "./setupTests.js",
	},
});
