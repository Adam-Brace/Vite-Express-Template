import dotenv from "dotenv";
import { defineConfig } from "vite";
import react from "@vitejs/plugin-react";

dotenv.config();

export default defineConfig({
	plugins: [react()],
	server: {
		port: process.env.PORT,
		open: true,
	},
	test: {
		globals: true,
		environment: "jsdom",
		setupFiles: "./tests/setupTests.js",
	},
});
