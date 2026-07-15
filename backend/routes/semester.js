import express from "express";
import Semester from "../models/Semester.js";

const router = express.Router();

// Get all semesters for a user
router.get("/:userId", async (req, res) => {
  try {
    const semesters = await Semester.find({ userId: req.params.userId });
    res.json(semesters);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add a new semester
router.post("/", async (req, res) => {
  const { userId, title } = req.body;
  const semester = new Semester({ userId, title });

  try {
    const savedSemester = await semester.save();
    res.status(201).json(savedSemester);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update a semester
router.put("/:id", async (req, res) => {
  try {
    const semester = await Semester.findById(req.params.id);
    if (!semester) return res.status(404).json({ message: "Semester not found" });

    semester.title = req.body.title || semester.title;
    const updated = await semester.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete a semester
router.delete("/:id", async (req, res) => {
  try {
    const semester = await Semester.findById(req.params.id);
    if (!semester) return res.status(404).json({ message: "Semester not found" });

    await semester.deleteOne();
    res.json({ message: "Semester deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
