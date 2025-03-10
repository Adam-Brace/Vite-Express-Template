/* eslint-disable no-undef */
import { render, screen } from "@testing-library/react";
import App from "./App";

test("renders Hello World", () => {
	// Render the App component
	render(<App />);

	// Check if "Hello World" is present in the document
	const linkElement = screen.getByText(/Hello World/i);
	expect(linkElement).toBeInTheDocument();
});
