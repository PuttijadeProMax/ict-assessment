import { Prisma } from "@prisma/client";
export function errorHandler(error, _req, res, _next) {
  const status =
    error.status ||
    (error instanceof Prisma.PrismaClientKnownRequestError
      ? error.code === "P2002"
        ? 409
        : error.code === "P2025"
          ? 404
          : 400
      : 500);
  const isDuplicateEmail =
    error instanceof Prisma.PrismaClientKnownRequestError &&
    error.code === "P2002" &&
    Array.isArray(error.meta?.target) &&
    error.meta.target.includes("email");
  const message =
    status === 500
      ? "เกิดข้อผิดพลาดภายในระบบ"
      : isDuplicateEmail
        ? "อีเมลนี้ถูกใช้งานแล้ว"
        : error.message;
  if (status === 500) console.error("Request failed:", error.message);
  res
    .status(status)
    .json({
      success: false,
      error: {
        code: isDuplicateEmail ? "EMAIL_ALREADY_EXISTS" : error.code || "INTERNAL_ERROR",
        message,
      },
    });
}
