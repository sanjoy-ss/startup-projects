import mongoose from "mongoose";


declare global {
  // eslint-disable-next-line no-var
  var _mongoose: { conn: typeof mongoose | null, promise: Promise<typeof mongoose> | null };
}

let cached = global._mongoose || { conn: null, promise: null };
global._mongoose = cached;

export async function dbConnect() {
  const MONGODB_URI = process.env.MONGODB_URI as string;
  if (!MONGODB_URI) {
    throw new Error("Missing MONGODB_URI in environment");
  }

  if (cached.conn) return cached.conn;
  if (!cached.promise) {
    cached.promise = mongoose.connect(MONGODB_URI, {
      dbName: process.env.MONGODB_DB || "teacher_directory"
    });
  }
  cached.conn = await cached.promise;
  return cached.conn;
}
