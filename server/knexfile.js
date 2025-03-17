require("dotenv").config();
module.exports = {
	development: {
		client: "postgresql",
		connection: {
			host: "127.0.0.1",
			password: process.env.USER_PASSWORD,
			user: process.env.USER_NAME,
			port: process.env.DATABASE_PORT,
			database: process.env.DATABASE_NAME,
		},
	},
};
