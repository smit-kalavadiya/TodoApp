require("dotenv").config();
const express = require('express');
const cors = require('cors');
const todoRoutes = require('./router/todo');
const connectDB = require('./db');
const app = express();

const PORT = process.env.PORT || 5001;

//Middleware
app.use(cors());
app.use(express.json());

//routes
app.use('/todos', todoRoutes);

//database connection
connectDB();

app.listen(PORT, () => console.log('Todo service running on port ' + PORT));