 import { Routes, Route } from "react-router-dom";
import Login from "./pages/Login";
import Signup from "./pages/Signup";
import Dashboard from "./pages/Dashboard";
import Home from "./pages/Home";
import Products from "./pages/Products";
import Suppliers from "./pages/Suppliers";
import Orders from "./pages/Orders";
import Settings from "./pages/Settings";

function App() {
  return (
    <Routes>
      <Route path="/" element={<Home />} />
      <Route path="/login" element={<Login />} />
      <Route path="/signup" element={<Signup />} />
      <Route path="/dashboard" element={<Dashboard />} />
      <Route path="/products" element={<Products />} />
      <Route path="/suppliers" element={<Suppliers />} />
      <Route path="/orders" element={<Orders />} />
      <Route path="/settings" element={<Settings />} />
    </Routes>
  );
}

export default App;