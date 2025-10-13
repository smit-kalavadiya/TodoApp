import axios from "axios";

const BASE_TODOS_URL = import.meta.env.VITE_BASE_TODOS_URL;

const getHeaders = (token, userId) => ({
  Authorization: `Bearer ${token}`,
  "x-user-id": userId,
});

export const fetchTodos = async (token, userId) => {
  const res = await axios.get(BASE_TODOS_URL, { headers: getHeaders(token, userId) });
  const data = res.data;

  // ✅ ensure array
  if (Array.isArray(data)) return data;
  if (Array.isArray(data.todos)) return data.todos;
  return []; // fallback
};


export const addTodo = async (token, userId, title) => {
  const res = await axios.post(BASE_TODOS_URL, { title }, { headers: getHeaders(token, userId) });
  return res.data;
};

export const editTodo = async (token, userId, id, title) => {
  const res = await axios.put(`${BASE_TODOS_URL}/${id}`, { title }, { headers: getHeaders(token, userId) });
  return res.data;
};

export const deleteTodo = async (token, userId, id) => {
  await axios.delete(`${BASE_TODOS_URL}/${id}`, { headers: getHeaders(token, userId) });
};
