import express from "express";
import User from "../models/User.js";
import Semester from "../models/Semester.js";
import Subject from "../models/Subject.js";
import Chapter from "../models/Chapter.js";
import Note from "../models/Note.js";

const router = express.Router();


// GET /api/users?search=<query>
// GET /api/user-data?search=<query>
router.get("/", async (req, res) => {
  try {
    const searchQuery = req.query.search || "";

    let users = await User.find({
      $or: [
        { email: { $regex: searchQuery, $options: "i" } },
        { name: { $regex: searchQuery, $options: "i" } },
      ],
    }).select("firebaseUid name email profile_pic bio visible");

    // hide email for invisible users
    users = users.map(u => {
      const userObj = u.toObject();
      if (!userObj.visible) delete userObj.email;
      return userObj;
    });

    res.json(users);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


// GET /api/users/:uid/semesters
router.get("/:uid/semesters", async (req, res) => {
  try {
    const semesters = await Semester.find({ userId: req.params.uid });
    res.json(semesters);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// GET /api/users/:uid/semesters/:semesterId/subjects
router.get("/:uid/semesters/:semesterId/subjects", async (req, res) => {
  try {
    const subjects = await Subject.find({
      semesterId: req.params.semesterId,
      // optional: could check userId ownership if needed
    });
    res.json(subjects);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


// GET /api/users/:uid/subjects/:subjectId/chapters
router.get("/:uid/subjects/:subjectId/chapters", async (req, res) => {
  try {
    const chapters = await Chapter.find({ subjectId: req.params.subjectId });
    res.json(chapters);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


// GET /api/users/:uid/chapters/:chapterId/notes
router.get("/:uid/chapters/:chapterId/notes", async (req, res) => {
  try {
    const notes = await Note.find({ chapterId: req.params.chapterId });
    res.json(notes);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});


export default router;