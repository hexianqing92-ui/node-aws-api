import cors from "cors";
import express, { type ErrorRequestHandler } from "express";
import helmet from "helmet";
import { ZodError } from "zod";
import { healthRouter } from "./routes/health.js";
import { todosRouter } from "./routes/todos.js";

export function createApp() {
  const app = express();

  app.use(helmet());
  app.use(cors());
  app.use(express.json());

  app.get("/", (_req, res) => {
    res.json({
      service: "node-aws-api",
      docs: "Use GET /health, GET /todos, and POST /todos.",
    });
  });

  app.use("/health", healthRouter);
  app.use("/todos", todosRouter);

  app.use((_req, res) => {
    res.status(404).json({ error: "Not found" });
  });

  const errorHandler: ErrorRequestHandler = (error, _req, res, _next) => {
    if (error instanceof ZodError) {
      res.status(400).json({
        error: "Invalid request body",
        details: error.flatten(),
      });
      return;
    }

    console.error(error);
    res.status(500).json({ error: "Internal server error" });
  };

  app.use(errorHandler);

  return app;
}
