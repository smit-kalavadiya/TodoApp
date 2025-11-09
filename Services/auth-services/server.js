require("dotenv").config();
const express = require("express");
const authRoutes = require("./router/auth");
const cors = require('cors');
const connectDB = require("./db");
const app = express();

const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json()); // for parsing JSON request bodies

// Routes
app.use("/auth", authRoutes);

// Connect to database
connectDB();

app.listen(PORT, () => console.log(`Auth app listening on port ${PORT}`));