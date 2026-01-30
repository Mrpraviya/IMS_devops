 
import { useState } from "react";
import axios from "axios";
import { useNavigate } from "react-router-dom";

export default function Signup() {
  const [form, setForm] = useState({ username: "", email: "", password: "" });
  const [error, setError] = useState("");
  const [loading, setLoading] = useState(false);
  const navigate = useNavigate();

   const API_URL = import.meta.env.VITE_API_URL || "http://54.144.116.87:5000";

  const handleChange = (e) =>
    setForm({ ...form, [e.target.name]: e.target.value });

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError("");
    setLoading(true);
    try {
      const res = await axios.post(`${API_URL}/api/auth/signup`, form);
      alert("✅ Signup successful");
      navigate("/login");
    } catch (err) {
      setError(err.response?.data?.error || "❌ Signup failed");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="flex flex-col items-center justify-center h-screen bg-gradient-to-r from-green-500 via-emerald-600 to-gray-900">
      <h1 className="text-4xl md:text-5xl font-bold text-white drop-shadow-lg mb-8">
        Inventory Management System
      </h1>

      <div className="w-96 bg-white/20 backdrop-blur-lg shadow-2xl rounded-2xl p-8 border border-white/30">
        <h2 className="text-3xl font-bold text-center text-white mb-6">
          Create Account
        </h2>

        {error && (
          <div className="bg-red-500/80 text-white p-3 mb-4 rounded-lg text-sm shadow-md text-center">
            {error}
          </div>
        )}

        <form onSubmit={handleSubmit} className="space-y-5">
          <div>
            <label className="block text-gray-100 text-sm mb-1">
              Username :
            </label>
            <input
              type="text"
              name="username"
              placeholder="Enter your Username"
              value={form.username}
              onChange={handleChange}
              required
              className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none shadow-sm"
            />
          </div>

          <div>
            <label className="block text-gray-100 text-sm mb-1">Email :</label>
            <input
              type="email"
              name="email"
              placeholder="Enter your Email"
              value={form.email}
              onChange={handleChange}
              required
              className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none shadow-sm"
            />
          </div>

          <div>
            <label className="block text-gray-100 text-sm mb-1">
              Password :
            </label>
            <input
              type="password"
              name="password"
              placeholder="Enter your Password"
              value={form.password}
              onChange={handleChange}
              required
              className="w-full px-4 py-2 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:outline-none shadow-sm"
            />
          </div>

          <button
            type="submit"
            disabled={loading}
            className={`w-full ${
              loading
                ? "bg-gray-400 cursor-not-allowed"
                : "bg-green-600 hover:bg-green-700"
            } text-white py-2 rounded-lg shadow-md transition-all duration-300`}
          >
            {loading ? "Signing up..." : "Sign Up"}
          </button>
        </form>

        <p className="text-gray-200 text-sm text-center mt-6">
          Already have an account?{" "}
          <a href="/login" className="text-blue-700 hover:underline">
            Login
          </a>
        </p>
      </div>
    </div>
  );
}
