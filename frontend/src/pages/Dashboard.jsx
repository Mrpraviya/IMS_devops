import { useEffect, useState } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar";

export default function Dashboard() {
  const [products, setProducts] = useState([]);
  const api = "http://54.172.52.159:5000/api/products";

  useEffect(() => {
    axios
      .get(api)
      .then((r) => setProducts(r.data))
      .catch(() => setProducts([]));
  }, []);

  const totalStock = products.reduce((s, p) => s + (p.stock || 0), 0);
  const lowStock = products.filter((p) => (p.stock || 0) < 10).length;

  return (
    <div className="flex min-h-screen bg-gradient-to-br from-green-500 via-emerald-600 to-gray-900 text-white">
      <Sidebar />

      <main className="flex-1 p-8 relative">
        {/* Header */}
        <header className="flex items-center justify-between mb-10">
          <h1 className="text-4xl font-extrabold tracking-wide drop-shadow-md">
            📊 Dashboard
          </h1>
          <div className="text-lg font-medium text-white/90">
            Welcome back, <span className="font-bold text-green-200">Admin</span> 👋
          </div>
        </header>

        {/* Stats Cards */}
        <section className="grid grid-cols-1 md:grid-cols-3 gap-8 mb-10">
          <div className="bg-white/15 backdrop-blur-lg rounded-2xl p-6 shadow-2xl border border-white/20 hover:scale-105 transition-transform duration-300">
            <div className="text-sm text-gray-200 mb-2">Total Products</div>
            <div className="text-4xl font-bold text-white">{products.length}</div>
          </div>

          <div className="bg-white/15 backdrop-blur-lg rounded-2xl p-6 shadow-2xl border border-white/20 hover:scale-105 transition-transform duration-300">
            <div className="text-sm text-gray-200 mb-2">Total Stock</div>
            <div className="text-4xl font-bold text-white">{totalStock}</div>
          </div>

          <div className="bg-white/15 backdrop-blur-lg rounded-2xl p-6 shadow-2xl border border-white/20 hover:scale-105 transition-transform duration-300">
            <div className="text-sm text-gray-200 mb-2">Low Stock</div>
            <div className="text-4xl font-bold text-red-300">{lowStock}</div>
          </div>
        </section>

        {/* Recent Products */}
        <section className="bg-white/10 backdrop-blur-lg rounded-2xl shadow-xl border border-white/20 p-6">
          <h2 className="text-2xl font-semibold mb-6 text-green-100">
            🛒 Recent Products
          </h2>

          {products.length === 0 ? (
            <div className="text-gray-300 text-center p-6 text-lg">
              No products yet 🚫
            </div>
          ) : (
            <div className="divide-y divide-white/20">
              {products.slice(0, 5).map((p) => (
                <div
                  key={p._id}
                  className="flex items-center justify-between py-4 hover:bg-white/10 px-3 rounded-lg transition"
                >
                  <div>
                    <div className="font-medium text-white text-lg">{p.name}</div>
                    <div className="text-sm text-gray-300">{p.category}</div>
                  </div>
                  <div className="text-sm font-semibold text-green-300">
                    {p.stock} in stock
                  </div>
                </div>
              ))}
            </div>
          )}
        </section>
      </main>
    </div>
  );
}
