import bcrypt from "bcrypt";
import { prisma } from "../config/prisma.js";

const email = process.env.INITIAL_ADMIN_EMAIL?.trim().toLowerCase();
const password = process.env.INITIAL_ADMIN_PASSWORD;

try {
  const userCount = await prisma.users.count();
  if (!userCount && email && password) {
    if (password.length < 10)
      throw new Error("INITIAL_ADMIN_PASSWORD ต้องมีอย่างน้อย 10 ตัวอักษร");
    const role = await prisma.roles.findUnique({ where: { name: "ADMIN" } });
    if (!role) throw new Error("ไม่พบ Role ADMIN หลัง migration");
    await prisma.users.create({
      data: {
        full_name: "System Administrator",
        email,
        password_hash: await bcrypt.hash(password, 12),
        role_id: role.id,
      },
    });
    console.log("Initial administrator created.");
  } else if (!userCount) {
    console.warn("No initial administrator created: set INITIAL_ADMIN_EMAIL and INITIAL_ADMIN_PASSWORD.");
  }
} finally {
  await prisma.$disconnect();
}
