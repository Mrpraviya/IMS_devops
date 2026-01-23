 
import { NavLink, useNavigate } from "react-router-dom";

export default function Sidebar() {
  const navigate = useNavigate();

  const handleLogout = () => {
    localStorage.removeItem("token");
    navigate("/");
  };

  const linkClass = ({ isActive }) =>
    `flex items-center gap-3 px-4 py-2.5 rounded-lg transition-all duration-300 ${
      isActive
        ? "bg-gradient-to-r from-indigo-500 to-purple-500 text-white shadow-md"
        : "text-gray-700 hover:bg-indigo-50 hover:text-indigo-600"
    }`;

  return (
    <aside className="w-64 bg-white/90 backdrop-blur-xl border-r border-gray-200 shadow-lg min-h-screen p-5 flex flex-col justify-between">
      {/* Header Section */}
      <div>
        <div className="mb-10 text-center">
          <div className="text-3xl font-extrabold text-transparent bg-clip-text bg-gradient-to-r from-indigo-500 to-purple-600">
            S&P Inventory
          </div>
          <div className="text-sm text-gray-400 tracking-wide mt-1">IMS</div>
        </div>

        {/* Navigation Links */}
        <nav className="space-y-2">
          <NavLink to="/dashboard" className={linkClass}>
            <span className="text-lg">🏠</span> Dashboard
          </NavLink>
          <NavLink to="/products" className={linkClass}>
            <span className="text-lg">📦</span> Products
          </NavLink>
          <NavLink to="/suppliers" className={linkClass}>
            <span className="text-lg">🚚</span> Suppliers
          </NavLink>
          <NavLink to="/orders" className={linkClass}>
            <span className="text-lg">🧾</span> Orders
          </NavLink>
          <NavLink to="/settings" className={linkClass}>
            <span className="text-lg">⚙️</span> Settings
          </NavLink>
        </nav>
      </div>

      {/* Logout Section */}
      <div className="mt-6 border-t border-gray-100 pt-4">
        <button
          onClick={handleLogout}
          className="w-full flex items-center gap-3 px-4 py-2.5 rounded-lg text-red-600 font-medium hover:bg-red-50 transition-all duration-300"
        >
          <span className="text-lg">🔒</span> Logout
        </button>
      </div>
    </aside>
  );
}

 