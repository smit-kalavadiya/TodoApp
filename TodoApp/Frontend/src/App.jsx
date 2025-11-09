import './App.css'

function App() {

  return (
    <>
    <div>
      <h1>Home Page</h1>
      <nav>
        <Link to="/login">Login</Link> |{" "}
        <Link to="/register">Register</Link> |{" "}
        <Link to="/dashboard">Dashboard</Link> 
      </nav>
    </div>
    </>
  )
}

export default App
