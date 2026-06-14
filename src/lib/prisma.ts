import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "../generated/prisma/client.js";

const globalForPrisma = globalThis as unknown as {
  prisma?: PrismaClient;
};

export function getPrisma() {
  if (globalForPrisma.prisma) {
    return globalForPrisma.prisma;
  }

  if (!process.env.DATABASE_URL) {
    throw new Error("DATABASE_URL is required for database-backed routes.");
  }

  const adapter = new PrismaPg({
    connectionString: process.env.DATABASE_URL,
    // RDS presents an AWS-managed CA that node-pg does not trust by default.
    // In production (ECS -> RDS) enable TLS but skip strict CA verification.
    // Local Docker Postgres has no TLS, so SSL stays off there.
    ...(process.env.NODE_ENV === "production"
      ? { ssl: { rejectUnauthorized: false } }
      : {}),
  });

  const prisma = new PrismaClient({
    adapter,
    log: process.env.NODE_ENV === "development" ? ["error", "warn"] : ["error"],
  });

  if (process.env.NODE_ENV !== "production") {
    globalForPrisma.prisma = prisma;
  }

  return prisma;
}
