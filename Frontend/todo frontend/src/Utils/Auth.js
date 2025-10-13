import { jwtDecode } from "jwt-decode";

export const validateToken = (navigate) => {
  const token = localStorage.getItem("token");
  if (!token) {
    navigate("/login");
    return null;
  }

  try {
    const decoded = jwtDecode(token);
    const currentTime = Date.now() / 1000;
    if (decoded.exp && decoded.exp < currentTime) {
      localStorage.removeItem("token");
      navigate("/login");
      return null;
    }
    return { token, decoded };
  } catch {
    localStorage.removeItem("token");
    navigate("/login");
    return null;
  }
};
