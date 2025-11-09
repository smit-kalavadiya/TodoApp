require("dotenv").config();
const express = require('express');
const cors = require('cors');
const todoRoutes = require('./router/Todo');
const connectDB = require('./db');

const app = express();
app.use(cors({
    origin: "http://localhost:5173", // your React frontend URL
    credentials: true, // if you want to send cookies (optional)
  }));
app.use(express.json());

//routes
app.use('/todos', todoRoutes);

//database connection
connectDB();

app.listen(process.env.PORT || 5001, () => console.log('Todo service running on port 5001'));
