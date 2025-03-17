require("dotenv").config();
module.exports = {
	development: {
		client: "pg",
		connection: `postgres://${process.env.USER_NAME}:${process.env.USER_PASSWORD}@localhost/${process.env.DATABASE_PORT}`,
	},
};
