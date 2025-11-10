 import Sidebar from "../components/Sidebar";

export default function Orders() {
  return (
    <div className="flex min-h-screen bg-gray-50">
      <Sidebar />
      <main className="flex-1 p-6">
        <h1 className="text-2xl font-bold mb-4">Orders</h1>
        <div className="bg-white rounded-md shadow p-4">Orders management will be here.</div>
      </main>
    </div>
  );
}