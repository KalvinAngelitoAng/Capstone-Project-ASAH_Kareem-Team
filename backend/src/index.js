import "dotenv/config";
import express from "express";
import cors from "cors";
import authRoutes from "./routes/auth.js";
import crewRoutes from "./routes/crew_route.js";
import equipmentRoutes from "./routes/equipment_routes.js";
import maintenanceScheduleRoutes from "./routes/maintenance_schedule_route.js";
import pitRoutes from "./routes/pit_route.js";
import blendingPlanRoutes from "./routes/blending_plan_route.js";

const PORT = process.env.PORT || 3000;
const app = express();

const allowedEnvOrigins = (process.env.FRONTEND_URL || "")
  .split(",")
  .map((s) => s.trim())
  .filter(Boolean);
const defaultDevOrigins = [
  "http://localhost:5173",
  "http://localhost:4173",
  "http://localhost:4174",
];

app.use(
  cors({
    origin: (origin, cb) => {
      if (!origin) return cb(null, true);
      if (
        allowedEnvOrigins.includes(origin) ||
        defaultDevOrigins.includes(origin)
      ) {
        return cb(null, true);
      }
      return cb(new Error("Not allowed by CORS"));
    },
    methods: ["GET", "POST", "PUT", "DELETE"],
    credentials: true,
  })
);

app.use(express.json());
app.use(express.urlencoded({ extended: true }));

app.get("/", (req, res) => {
  res.send("Backend API Lancar Cuyyy - Login/Register Ready");
});

app.use("/api/auth", authRoutes);

// API crew atau karyawan
app.use("/crews", crewRoutes);

// API equipment atau alat berat
app.use("/equipments", equipmentRoutes);

// API maintenance schedule
app.use("/maintenance-schedules", maintenanceScheduleRoutes);

// API pit
app.use("/pits", pitRoutes);

// API blending-plan
app.use("/blending-plans", blendingPlanRoutes);

app.use((err, req, res, next) => {
  const status = err.status || 500;
  const message = err.message || "Terjadi kesalahan pada server.";

  console.error(err.stack);

  res.status(status).json({
    message: message,
  });
});

app.listen(PORT, () => {
  console.log(`Server berjalan di http://localhost:${PORT}`);
});
