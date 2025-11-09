import { useState, useEffect } from "react";
import Modal from "react-modal";
import toast, { Toaster } from "react-hot-toast";
import { useNavigate } from "react-router-dom";
import {
  fetchTodos,
  addTodo,
  editTodo,
  deleteTodo,
} from "../Services/Todo-Services";
import { validateToken } from "../Utils/Auth";

Modal.setAppElement("#root");

export default function Dashboard() {
  const [todos, setTodos] = useState([]);
  const [newTodo, setNewTodo] = useState("");
  const [loading, setLoading] = useState(true);
  const [auth, setAuth] = useState(null);

  const [isEditOpen, setIsEditOpen] = useState(false);
  const [editingTodo, setEditingTodo] = useState(null);
  const [editTitle, setEditTitle] = useState("");
  const navigate = useNavigate();

  useEffect(() => {
    const result = validateToken(navigate);
    if (result) {
      setAuth(result);
      loadTodos(result.token, result.decoded.userId);
    }
  }, [navigate]);

  const loadTodos = async (token, userId) => {
    try {
      setLoading(true);
      const data = await fetchTodos(token, userId);
      setTodos(Array.isArray(data) ? data : data.todos || []);
    } catch {
      toast.error("Failed to fetch todos");
    } finally {
      setLoading(false);
    }
  };

  const handleAddTodo = async (e) => { 
    e.preventDefault();
    if (!newTodo.trim() || !auth) return;
    try {
      const newItem = await addTodo(auth.token, auth.decoded.userId, newTodo);
      setTodos((prev) => [...prev, newItem]);
      setNewTodo("");
      toast.success("Todo added!");
    } catch {
      toast.error("Failed to add todo");
    }
  };

  const openEditModal = (todo) => {
    setEditingTodo(todo);
    setEditTitle(todo.title);
    setIsEditOpen(true);
  };

  const handleEditConfirm = async () => {
    if (!editTitle.trim() || !auth) return;
    try {
      const updated = await editTodo(
        auth.token,
        auth.decoded.userId,
        editingTodo._id,
        editTitle.trim()
      );
      setTodos((prev) =>
        prev.map((t) => (t._id === editingTodo._id ? updated : t))
      );
      setIsEditOpen(false);
      toast.success("Todo updated!");
    } catch {
      toast.error("Failed to update todo");
    }
  };

  const handleDelete = async (id) => {
    if (!auth) return;
    try {
      await deleteTodo(auth.token, auth.decoded.userId, id);
      setTodos((prev) => prev.filter((t) => t._id !== id));
      toast.success("Todo deleted!");
    } catch {
      toast.error("Failed to delete todo");
    }
  };

  const handleLogout = () => {
    localStorage.removeItem("token");
    navigate("/login");
  };

  return (
    <div className="min-h-screen bg-gray-100">
      <Toaster position="top-right" />
      {/* Header */}
      <header className="w-full flex justify-between items-center p-4 bg-white shadow fixed top-0 left-0 right-0 z-10">
        <h1 className="text-2xl font-bold">Todo Dashboard</h1>
        <button
          onClick={handleLogout}
          className="bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 transition"
        >
          Logout
        </button>
      </header>

      <main className="flex flex-col items-center justify-start pt-24">
        {/* Add Todo */}
        <form
          onSubmit={handleAddTodo}
          className="bg-white p-6 rounded-lg shadow-md mt-6 w-96 flex flex-col gap-3"
        >
          <input
            type="text"
            placeholder="Enter new todo..."
            value={newTodo}
            onChange={(e) => setNewTodo(e.target.value)}
            className="w-full p-3 border border-gray-300 rounded focus:ring-2 focus:ring-blue-400 outline-none transition"
          />
          <button
            type="submit"
            disabled={!newTodo.trim()}
            className="w-full bg-blue-500 text-white py-2 rounded hover:bg-blue-600 disabled:opacity-50 transition"
          >
            Add Todo
          </button>
        </form>

        {/* Todo List */}
        <section className="bg-white rounded-lg shadow-md mt-6 w-96 p-4">
          <h2 className="text-lg font-semibold mb-3">My Todos</h2>
          {loading ? (
            <p className="text-gray-500 text-sm">Loading...</p>
          ) : todos.length === 0 ? (
            <p className="text-gray-500 text-sm">No todos yet.</p>
          ) : (
            <ul className="space-y-2">
              {todos.map((todo) => (
                <li
                  key={todo._id}
                  className="flex justify-between items-center p-2 border border-gray-200 rounded hover:bg-gray-50 transition"
                >
                  <span>{todo.title}</span>
                  <div className="space-x-2">
                    <button
                      onClick={() => openEditModal(todo)}
                      className="text-blue-500 hover:text-blue-700 transition"
                    >
                      ✏️
                    </button>
                    <button
                      onClick={() => handleDelete(todo._id)}
                      className="text-red-500 hover:text-red-700 transition"
                    >
                      🗑️
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </section>
      </main>

      {/* ✅ User-Friendly Edit Modal */}
      <Modal
        isOpen={isEditOpen}
        onRequestClose={() => setIsEditOpen(false)}
        contentLabel="Edit Todo"
        shouldCloseOnOverlayClick={true}
        shouldCloseOnEsc={true}
        className="bg-white rounded-xl shadow-lg p-6 max-w-md mx-auto mt-32 outline-none transform transition-transform duration-300"
        overlayClassName="fixed inset-0 bg-black bg-opacity-50 flex items-start justify-center"
      >
        <h2 className="text-xl font-bold mb-4">Edit Todo</h2>
        <input
          type="text"
          value={editTitle}
          onChange={(e) => setEditTitle(e.target.value)}
          className="w-full p-3 border border-gray-300 rounded focus:ring-2 focus:ring-blue-400 outline-none mb-4 transition"
          onKeyDown={(e) => e.key === "Enter" && handleEditConfirm()}
        />
        <div className="flex justify-end gap-3">
          <button
            onClick={() => setIsEditOpen(false)}
            className="px-4 py-2 bg-gray-300 rounded hover:bg-gray-400 transition"
          >
            Cancel
          </button>
          <button
            onClick={handleEditConfirm}
            disabled={!editTitle.trim()}
            className="px-4 py-2 bg-blue-500 text-white rounded hover:bg-blue-600 disabled:opacity-50 transition"
          >
            Save
          </button>
        </div>
      </Modal>
    </div>
  );
}
