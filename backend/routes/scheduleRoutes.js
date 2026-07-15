import express from "express";
import ScheduleItem from "../models/ScheduleItem.js";

const router = express.Router();

// GET all items for a user (optionally filter by type)
router.get("/:uid", async (req, res) => {
  try {
    const type = req.query.type; // optional
    const query = { userId: req.params.uid };

    if (type) query.type = type;

    const items = await ScheduleItem.find(query);
    res.json(items);
  } catch (err) {
    res.status(500).json({ message: "Failed to fetch schedule items.", error: err.message });
  }
});

// CREATE schedule item
router.post("/", async (req, res) => {
  try {
    const newItem = new ScheduleItem(req.body);
    const saved = await newItem.save(); // triggers pre('save') validation
    res.status(201).json(saved);
  } catch (err) {
    // Mongoose validation errors
    if (err.name === "ValidationError") {
      const messages = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ message: "Validation failed.", errors: messages });
    }

    // Custom errors thrown in pre('save')
    if (err.message) {
      return res.status(400).json({ message: err.message });
    }

    res.status(500).json({ message: "Failed to create schedule item.", error: err.message });
  }
});


// UPDATE schedule item
router.put("/:id", async (req, res) => {
  try {
    const item = await ScheduleItem.findById(req.params.id);
    if (!item) return res.status(404).json({ message: "Schedule item not found." });

    // Update fields from request body
    Object.assign(item, req.body);

    // Save triggers pre('save') validation
    const updated = await item.save();

    res.json(updated);
  } catch (err) {
    // Mongoose validation errors
    if (err.name === "ValidationError") {
      const messages = Object.values(err.errors).map(e => e.message);
      return res.status(400).json({ message: "Validation failed.", errors: messages });
    }

    // Custom errors from pre('save')
    if (err.message) {
      return res.status(400).json({ message: err.message });
    }

    res.status(500).json({ message: "Failed to update schedule item.", error: err.message });
  }
});


// DELETE item
router.delete("/:id", async (req, res) => {
  try {
    const deleted = await ScheduleItem.findByIdAndDelete(req.params.id);
    if (!deleted) return res.status(404).json({ message: "Schedule item not found." });
    res.json({ message: "Deleted successfully.", deleted });
  } catch (err) {
    res.status(500).json({ message: "Failed to delete schedule item.", error: err.message });
  }
});

export default router;
