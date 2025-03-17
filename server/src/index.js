require("dotenv").config();
const express = require("express");
const app = express();
const PORT = process.env.PORT;
const cors = require("cors");
const kenex = require("knex")(require("./knexfile")["development"]);

app.get("/", (req, res) => {
	res.send("Hello World!");
});

app.use(cors());

const server = app.listen(PORT, () => {
	console.log(`App listening at http://localhost:${PORT}`);
});

module.exports = { app, server, PORT };
