import express from "express";
import Note from "../models/Note.js";

const router = express.Router();

// Get all notes for a chapter
router.get("/:chapterId", async (req, res) => {
  try {
    const notes = await Note.find({ chapterId: req.params.chapterId });
    res.json(notes);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// Create a new note
router.post("/", async (req, res) => {
  try {
    const note = new Note(req.body);
    const saved = await note.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Update a note
router.put("/:id", async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);
    if (!note) return res.status(404).json({ message: "Note not found" });

    Object.assign(note, req.body);

    const updated = await note.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// Delete a note
router.delete("/:id", async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);
    if (!note) return res.status(404).json({ message: "Note not found" });

    await note.deleteOne();
    res.json({ message: "Note deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
