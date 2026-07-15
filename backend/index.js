import express from "express";
import dotenv from "dotenv";
import connectDB from "./config/db.js";
import semesterRoutes from "./routes/semester.js"; 
import subjectRoutes from "./routes/subject.js";
import chapterRoutes from "./routes/chapter.js";
import noteRoutes from "./routes/note.js";
import uploadRoutes from "./routes/upload.js";
import downloadRoutes from "./routes/download.js";
import scheduleRoutes from "./routes/scheduleRoutes.js";
import userRoutes from "./routes/user.js";
import userAccountRoutes from "./routes/userRoutes.js";
import cors from "cors";   // <-- import cors


dotenv.config();
connectDB();

const app = express();
app.use(cors());         // <-- enable CORS for all origins
app.use(express.json());


app.use("/api/semesters", semesterRoutes);
app.use("/api/subjects", subjectRoutes);
app.use("/api/chapters", chapterRoutes);
app.use("/api/notes", noteRoutes);
app.use("/api/upload", uploadRoutes);
app.use("/api/users", userRoutes);
app.use("/api/download", downloadRoutes);
app.use("/api/schedule", scheduleRoutes);
app.use("/api/user-data", userAccountRoutes);


const PORT = process.env.PORT || 5000;
//app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
app.listen(PORT, '0.0.0.0', () => console.log(`Server running on port ${PORT}`));
