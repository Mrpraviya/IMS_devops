import { NavLink, useNavigate } from "react-router-dom";

export default function Sidebar() {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("token");
    // any other cleanup
    navigate("/");
  };

  const linkClass = ({ isActive }) =>
    `flex items-center gap-3 px-4 py-2 rounded-md hover:bg-indigo-100 transition ${
      isActive ? "bg-indigo-200 font-semibold" : "text-gray-700"
    }`;

  return (
    <aside className="w-64 bg-white shadow-md min-h-screen p-4">
      <div className="mb-8 text-center">
        <div className="text-2xl font-bold text-indigo-600">S&P Inventory</div>
        <div className="text-sm text-gray-500">IMS</div>
      </div>

      <nav className="space-y-3">
        <NavLink to="/dashboard" className={linkClass}>
          <span>🏠</span> Dashboard
        </NavLink>
        <NavLink to="/products" className={linkClass}>
          <span>📦</span> Products
        </NavLink>
        <NavLink to="/suppliers" className={linkClass}>
          <span>🚚</span> Suppliers
        </NavLink>
        <NavLink to="/orders" className={linkClass}>
          <span>🧾</span> Orders
        </NavLink>
        <NavLink to="/settings" className={linkClass}>
          <span>⚙️</span> Settings
        </NavLink>

        <button
          onClick={handleLogout}
          className="w-full text-left mt-4 flex items-center gap-3 px-4 py-2 rounded-md hover:bg-red-100 text-red-700"
        >
          <span>🔒</span> Logout
        </button>
      </nav>
    </aside>
  );
}