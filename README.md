# Vite-Express-Template

**Vite-Express-Template** combines **Vite** for fast front-end development with **Express** for back-end API handling. It offers a full-stack setup, where **Vite** handles the development workflow with hot-reloading, while **Express** serves API routes and static files, providing a seamless development experience. This template includes **PostgreSQL** as the database and **Knex.js** as the query builder, making database interactions easier and more flexible.

The template also includes automated **testing** with:

-   **Jest** and **Supertest** for back-end API route testing.
-   **Jest** and **React Testing Library** for front-end component testing.

This ensures a robust, reliable, and efficient development process.

---

## 🚀 Run Locally

### 📌 Prerequisites

Ensure you have the following installed:

-   [Node.js](https://nodejs.org/) (Recommended: v16+)
-   npm (comes with Node.js)
-   Git (to clone the repository)
-   PostgreSQL installed on your system [PostgreSQL Official Site](https://www.postgresql.org/download/).

### 🔹 Clone the repository

```bash
  git clone https://github.com/Adam-Brace/Vite-Express-Template
```

### 🔹 Navigate to the project directory

```bash
  cd Vite-Express-Template
```

### 🔹 Run the setup script and follow the prompts

```bash
  ./setup.sh
```

### 🔹 Start the client

```bash
  npm run dev --prefix ./client
```

### 🔹 Open a new terminal and start the server

```bash
  npm run dev --prefix ./server
```

---

## 🛠 Common Issues

When running `./setup.sh`, you may encounter one of these errors:

**❌ Error:**

-   `bash: ./setup.sh: Permission denied`

-   `bash: Unknown command. './setup.sh' exists but is not an executable file.`

**Solution:**
Run the following command to grant execute permissions to the setup script:

```bash
  chmod +x setup.sh
```

---

## ✅ Running Tests

To run tests, make sure you are in the server or client directory, then run the following command:

```bash
  npm run test
```

---

## 👤 Author

-   [Adam Brace](https://github.com/Adam-Brace)
