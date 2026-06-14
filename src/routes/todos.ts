import { Router } from "express";
import { z } from "zod";
import { getPrisma } from "../lib/prisma.js";

export const todosRouter = Router();

const createTodoSchema = z.object({
  title: z.string().trim().min(1).max(200),
});

todosRouter.get("/", async (_req, res, next) => {
  try {
    const todos = await getPrisma().todo.findMany({
      orderBy: {
        createdAt: "desc",
      },
    });

    res.json({ data: todos });
  } catch (error) {
    next(error);
  }
});

todosRouter.post("/", async (req, res, next) => {
  try {
    const payload = createTodoSchema.parse(req.body);
    const todo = await getPrisma().todo.create({
      data: {
        title: payload.title,
      },
    });

    res.status(201).json({ data: todo });
  } catch (error) {
    next(error);
  }
});
