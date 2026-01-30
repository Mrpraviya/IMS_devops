// import express from "express";
// import mongoose from "mongoose";
// import dotenv from "dotenv";
// import cors from "cors";

// dotenv.config(); // ...existing code...
// const app = express();
// app.use(express.json());
// app.use(cors());

// // MongoDB connection
// const mongoUri = process.env.MONGO_URI || "mongodb://localhost:27017/ims-db";
// mongoose
//   .connect(mongoUri)
//   .then(() => console.log("✅ MongoDB connected"))
//   .catch((err) => console.error('❌ MongoDB connection error:', err));

// // Routes
// import authRoutes from "./routes/auth.js";
// import productsRoutes from "./routes/products.js"; // new

// app.use("/api/auth", authRoutes);
// app.use("/api/products", productsRoutes); // new

// const PORT = process.env.PORT || 5000;
// app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));

 import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import cors from "cors";

dotenv.config();

const app = express();
app.use(cors({
  origin: [
    "http://54.172.52.159",    // frontend public URL
    "http://localhost:3000"     // optional for local dev
  ],
  credentials: true
}));
app.use(express.json());

// MongoDB connection
mongoose
  .connect(process.env.MONGO_URI)
  .then(() => console.log("✅ MongoDB connected"))
  .catch((err) => console.error("❌ MongoDB connection error:", err));

// Routes
import authRoutes from "./routes/auth.js";
app.use("/api/auth", authRoutes);

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`🚀 Server running on port ${PORT}`));
