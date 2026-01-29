import { useEffect, useState } from "react";
import axios from "axios";
import Sidebar from "../components/Sidebar";

export default function Products() {
  const [products, setProducts] = useState([]);
  const [loading, setLoading] = useState(true);
  const [formOpen, setFormOpen] = useState(false);
  const [editing, setEditing] = useState(null);
  const [form, setForm] = useState({
    name: "",
    category: "",
    price: 0,
    stock: 0,
    description: "",
  });

  const api = `${import.meta.env.VITE_API_URL}/api/products`;

  const fetchProducts = async () => {
    setLoading(true);
    try {
      const res = await axios.get(api);
      setProducts(res.data);
    } catch (err) {
      console.error(err);
      alert("Failed to load products");
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchProducts();
  }, []);

  const openCreate = () => {
    setEditing(null);
    setForm({ name: "", category: "", price: 0, stock: 0, description: "" });
    setFormOpen(true);
  };

  const openEdit = (p) => {
    setEditing(p._id);
    setForm({
      name: p.name || "",
      category: p.category || "",
      price: p.price || 0,
      stock: p.stock || 0,
      description: p.description || "",
    });
    setFormOpen(true);
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      if (editing) {
        await axios.put(`${api}/${editing}`, form);
      } else {
        await axios.post(api, form);
      }
      setFormOpen(false);
      fetchProducts();
    } catch (err) {
      console.error(err);
      alert("Error saving product");
    }
  };

  const handleDelete = async (id) => {
    if (!confirm("Delete this product?")) return;
    try {
      await axios.delete(`${api}/${id}`);
      fetchProducts();
    } catch (err) {
      console.error(err);
      alert("Delete failed");
    }
  };

  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 p-6">
        <header className="flex items-center justify-between mb-6">
          <h1 className="text-2xl font-bold">Products</h1>
          <button
            onClick={openCreate}
            className="bg-indigo-600 text-white px-4 py-2 rounded-md"
          >
            + New Product
          </button>
        </header>

        <section className="bg-white rounded-md shadow p-4">
          {loading ? (
            <div>Loading...</div>
          ) : products.length === 0 ? (
            <div className="text-center text-gray-500 p-8">No products yet</div>
          ) : (
            <div className="overflow-x-auto">
              <table className="w-full table-auto">
                <thead className="bg-gray-100">
                  <tr>
                    <th className="p-3 text-left">Name</th>
                    <th className="p-3 text-left">Category</th>
                    <th className="p-3 text-left">Stock</th>
                    <th className="p-3 text-left">Price</th>
                    <th className="p-3 text-left">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {products.map((p) => (
                    <tr key={p._id} className="border-t">
                      <td className="p-3">{p.name}</td>
                      <td className="p-3">{p.category}</td>
                      <td className="p-3">{p.stock}</td>
                      <td className="p-3">${p.price}</td>
                      <td className="p-3">
                        <button
                          onClick={() => openEdit(p)}
                          className="mr-2 px-3 py-1 bg-yellow-100 rounded"
                        >
                          Edit
                        </button>
                        <button
                          onClick={() => handleDelete(p._id)}
                          className="px-3 py-1 bg-red-100 rounded"
                        >
                          Delete
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </section>

        {formOpen && (
          <div className="fixed inset-0 bg-black/40 flex items-center justify-center p-4">
            <div className="bg-white rounded-lg shadow-lg w-full max-w-xl p-6">
              <h3 className="text-lg font-semibold mb-4">{editing ? "Edit Product" : "Add Product"}</h3>
              <form onSubmit={handleSubmit} className="space-y-3">
                <div>
                  <label className="block text-sm text-gray-600">Name</label>
                  <input
                    required
                    value={form.name}
                    onChange={(e) => setForm({ ...form, name: e.target.value })}
                    className="w-full border p-2 rounded"
                  />
                </div>
                <div>
                  <label className="block text-sm text-gray-600">Category</label>
                  <input
                    value={form.category}
                    onChange={(e) => setForm({ ...form, category: e.target.value })}
                    className="w-full border p-2 rounded"
                  />
                </div>
                <div className="grid grid-cols-2 gap-3">
                  <div>
                    <label className="block text-sm text-gray-600">Price</label>
                    <input
                      type="number"
                      step="0.01"
                      value={form.price}
                      onChange={(e) => setForm({ ...form, price: Number(e.target.value) })}
                      className="w-full border p-2 rounded"
                    />
                  </div>
                  <div>
                    <label className="block text-sm text-gray-600">Stock</label>
                    <input
                      type="number"
                      value={form.stock}
                      onChange={(e) => setForm({ ...form, stock: Number(e.target.value) })}
                      className="w-full border p-2 rounded"
                    />
                  </div>
                </div>
                <div>
                  <label className="block text-sm text-gray-600">Description</label>
                  <textarea
                    value={form.description}
                    onChange={(e) => setForm({ ...form, description: e.target.value })}
                    className="w-full border p-2 rounded"
                  />
                </div>

                <div className="flex justify-end gap-2">
                  <button type="button" onClick={() => setFormOpen(false)} className="px-4 py-2 rounded border">
                    Cancel
                  </button>
                  <button type="submit" className="px-4 py-2 rounded bg-indigo-600 text-white">
                    {editing ? "Update" : "Create"}
                  </button>
                </div>
              </form>
            </div>
          </div>
        )}
      </main>
    </div>
  );
}