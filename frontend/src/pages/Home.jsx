// import { motion } from "framer-motion";

// export default function Home() {
//   return (
//     <div className="min-h-screen flex flex-col bg-gradient-to-r from-green-500 via-emerald-600 to-gray-900 text-white relative overflow-hidden">
//       {/* Background Overlay */}
//       <div className="absolute inset-0 bg-[url('https://www.toptal.com/designers/subtlepatterns/uploads/dot-grid.png')] opacity-10"></div>

//       {/* Floating gradient shapes */}
//       <div className="absolute -top-24 -left-24 w-72 h-72 bg-indigo-400 rounded-full mix-blend-multiply blur-3xl opacity-30 animate-pulse"></div>
//       <div className="absolute -bottom-24 -right-24 w-72 h-72 bg-pink-400 rounded-full mix-blend-multiply blur-3xl opacity-30 animate-pulse"></div>

//       {/* Navigation Bar */}
//       <nav className="flex justify-between items-center px-8 py-6 z-10">
         
//         <div className="flex items-center gap-4">
//           <a
//             href="/login"
//             className="btn btn-outline btn-accent rounded-full px-6 font-semibold hover:scale-105 transition-transform duration-300"
//           >
//             Login
//           </a>
//           <a
//             href="/signup"
//             className="btn btn-primary rounded-full px-6 font-semibold hover:scale-105 transition-transform duration-300"
//           >
//             Sign Up
//           </a>
//         </div>
//       </nav>

//       {/* Hero Section */}
//       <motion.div
//         initial={{ opacity: 0, y: 25 }}
//         animate={{ opacity: 1, y: 0 }}
//         transition={{ duration: 0.8 }}
//         className="flex flex-col justify-center items-center flex-grow text-center px-6 z-10"
//       >
//         <h2 className="text-6xl font-extrabold mb-6 drop-shadow-lg">
//          S & P Inventory Management System 
//         </h2>
//         <p className="text-lg md:text-xl mb-8 text-gray-200 max-w-2xl mx-auto leading-relaxed">
//           Track stock, manage products, and monitor sales effortlessly with an
//           intelligent dashboard designed for modern businesses.
//         </p>
//       </motion.div>

//       {/* Footer */}
//       <footer className="text-center py-4 text-sm text-gray-300">
//         © {new Date().getFullYear()} S&P Inventory Manager. All rights reserved.
//       </footer>
//     </div>
//   );
// }


import { motion } from "framer-motion";

// ...existing code...
export default function Home() {
  return (
    <div className="min-h-screen flex flex-col bg-gradient-to-r from-green-500 via-emerald-600 to-gray-900 text-white relative overflow-hidden">
      {/* Background Overlay */}
      <div className="absolute inset-0 bg-[url('https://www.toptal.com/designers/subtlepatterns/uploads/dot-grid.png')] opacity-10"></div>

      {/* Floating gradient shapes */}
      <div className="absolute -top-24 -left-24 w-72 h-72 bg-indigo-400 rounded-full mix-blend-multiply blur-3xl opacity-30 animate-pulse"></div>
      <div className="absolute -bottom-24 -right-24 w-72 h-72 bg-pink-400 rounded-full mix-blend-multiply blur-3xl opacity-30 animate-pulse"></div>

      {/* Navigation Bar - moved to top-right */}
      <nav className="absolute top-6 right-8 z-20 flex items-center gap-4">
        <a
          href="/login"
          className="btn btn-outline btn-accent rounded-full px-4 py-2 font-semibold hover:scale-105 transition-transform duration-300"
        >
          Login
        </a>
        <a
          href="/signup"
          className="btn btn-primary rounded-full px-4 py-2 font-semibold hover:scale-105 transition-transform duration-300"
        >
          Sign Up
        </a>
      </nav>

      {/* Hero Section */}
      <motion.div
        initial={{ opacity: 0, y: 25 }}
        animate={{ opacity: 1, y: 0 }}
        transition={{ duration: 0.8 }}
        className="flex flex-col justify-center items-center flex-grow text-center px-6 z-10"
      >
        <h2 className="text-6xl font-extrabold mb-6 drop-shadow-lg">
         S & P Inventory Management System 
        </h2>
        <p className="text-lg md:text-xl mb-8 text-gray-200 max-w-2xl mx-auto leading-relaxed">
          Track stock, manage products, and monitor sales effortlessly with an
          intelligent dashboard designed for modern businesses.
        </p>
      </motion.div>

      {/* Footer */}
      <footer className="text-center py-4 text-sm text-gray-300">
        © {new Date().getFullYear()} S&P Inventory Manager. All rights reserved.
      </footer>
    </div>
  );
}
// ...existing code...