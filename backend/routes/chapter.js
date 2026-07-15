import express from "express";
import Chapter from "../models/Chapter.js";

const router = express.Router();

// Get all chapters for a subject
router.get("/:subjectId", async (req, res) => {
  try {
    const chapters = await Chapter.find({ subjectId: req.params.subjectId });
    res.json(chapters);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Add a new chapter
router.post("/", async (req, res) => {
  const { semesterId, subjectId, title } = req.body;
  const chapter = new Chapter({ semesterId, subjectId, title });

  try {
    const savedChapter = await chapter.save();
    res.status(201).json(savedChapter);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update a chapter
router.put("/:id", async (req, res) => {
  try {
    const chapter = await Chapter.findById(req.params.id);
    if (!chapter) return res.status(404).json({ message: "Chapter not found" });

    chapter.title = req.body.title || chapter.title;

    const updated = await chapter.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete a chapter
router.delete("/:id", async (req, res) => {
  try {
    const chapter = await Chapter.findById(req.params.id);
    if (!chapter) return res.status(404).json({ message: "Chapter not found" });

    await chapter.deleteOne();
    res.json({ message: "Chapter deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
