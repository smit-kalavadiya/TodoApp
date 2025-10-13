require("dotenv").config();
const express = require("express");
const cors = require('cors');
const { createProxyMiddleware } = require("http-proxy-middleware");
const jwt = require("jsonwebtoken");

const app = express();
app.use(cors({
    origin: "http://localhost:5173", // your React frontend URL
    credentials: true, // if you want to send cookies (optional)
  }));

const AUTH_SERVICE_URL = "http://localhost:5000/auth";
const TODO_SERVICE_URL = "http://localhost:5001/todos";
const JWT_SECRET = process.env.JWT_SECRET;

// Middleware to verify JWT
const auth = (req, res, next) => {
  const token = req.headers["authorization"]?.split(" ")[1];
  if (!token) return res.status(401).json({ error: "Unauthorized" });

  try {
    req.user = jwt.verify(token, JWT_SECRET);
    next();
  } catch (err) {
    console.error("JWT verification failed:", err.message);
    return res.status(401).json({ error: "Invalid token" });
  }
};

// AUTH ROUTES (no JWT needed)
app.use(
  "/auth",
  createProxyMiddleware({
    target: AUTH_SERVICE_URL,
    changeOrigin: true,
    logLevel: "debug",
  })
);

// TODOS ROUTES (JWT required)
app.use(
  "/todos",
  auth,
  createProxyMiddleware({
    target: TODO_SERVICE_URL,
    changeOrigin: true,
    logLevel: "debug",
    pathRewrite: { "^/todos": "" },

    onProxyReq: (proxyReq, req) => {
      // Add custom header
      if (req.user) {
        proxyReq.setHeader("x-user-id", req.user.userId);
      }

      // Forward body safely for POST/PUT
      if (
        req.method === "POST" ||
        req.method === "PUT" ||
        req.method === "PATCH"
      ) {
        const bodyData = JSON.stringify(req.body);
        if (bodyData) {
          proxyReq.setHeader("Content-Type", "application/json");
          proxyReq.setHeader("Content-Length", Buffer.byteLength(bodyData));
          proxyReq.write(bodyData);
        }
      }
    },
  })
);

app.get("/", (req, res) => {
  res.send("Welcome to the API Gateway");
});

const PORT = 4001;
app.listen(PORT, () => console.log(`API Gateway running on port ${PORT}`));
