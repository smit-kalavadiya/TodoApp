const express = require('express');
const Todo = require('../models/todo');

const router = express.Router();

// CRUD routes
router.get('/', async (req, res) => {
  try {
    const userId = req.headers["x-user-id"];
    const todos = await Todo.find({ userId });
    res.status(200).json(todos); // ✅ Always respond with array
  } catch (err) {
    console.error("Error fetching todos:", err);
    res.status(500).json({ error: "Server error fetching todos" });
  }
});

router.post('/', async (req, res) => {
  const userId = req.headers["x-user-id"];
  const todo = await Todo.create({ ...req.body, userId });
  res.json(todo);
});

router.put('/:id', async (req, res) => {
  const userId = req.headers["x-user-id"];
  const todo = await Todo.findOneAndUpdate(
    { _id: req.params.id, userId },
    req.body,
    { new: true }
  );
  res.json(todo);
});

router.delete('/:id', async (req, res) => {
  const userId = req.headers["x-user-id"];
  await Todo.findOneAndDelete({ _id: req.params.id, userId });
  res.json({ message: 'Todo deleted' });
});

module.exports = router;
