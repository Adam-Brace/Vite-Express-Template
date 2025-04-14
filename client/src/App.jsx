import { useState, useEffect } from "react";
import "./App.css";
const API_URL = import.meta.env.VITE_API_URL; // This is the API URL from the server ex: http://localhost:3001

function App() {
	const [data, setData] = useState(null);
	useEffect(() => {
		fetch(`${API_URL}`)
			.then((response) => response)
			.then((data) => setData(data));
	}, []);

	return data ? "Api is working" : "Api is not working";
}

export default App;
