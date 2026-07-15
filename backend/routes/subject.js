import express from "express";
import Subject from "../models/Subject.js"; // import the model

const router = express.Router();

// Get all subjects for a semester
router.get("/:semesterId", async (req, res) => {
  try {
    const subjects = await Subject.find({ semesterId: req.params.semesterId });
    res.json(subjects);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add a new subject
router.post("/", async (req, res) => {
  const { semesterId, title, courseCode, instructor } = req.body;
  const subject = new Subject({ semesterId, title, courseCode, instructor });

  try {
    const savedSubject = await subject.save();
    res.status(201).json(savedSubject);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update a subject
router.put("/:id", async (req, res) => {
  try {
    const subject = await Subject.findById(req.params.id);
    if (!subject) return res.status(404).json({ message: "Subject not found" });

    subject.title = req.body.title || subject.title;
    subject.courseCode = req.body.courseCode || subject.courseCode;
    subject.instructor = req.body.instructor || subject.instructor;

    const updated = await subject.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete a subject
router.delete("/:id", async (req, res) => {
  try {
    const subject = await Subject.findById(req.params.id);
    if (!subject) return res.status(404).json({ message: "Subject not found" });

    await subject.deleteOne();
    res.json({ message: "Subject deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
