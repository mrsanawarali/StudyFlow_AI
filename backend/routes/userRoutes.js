import express from "express";
import User from "../models/User.js";

const router = express.Router();

// GET user by firebaseUid
router.get("/:firebaseUid", async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.params.firebaseUid });
    if (!user) return res.status(404).json({ message: "User not found" });

    res.json(user);
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

// CREATE a user
router.post("/", async (req, res) => {
  const { firebaseUid, name, email, bio, profile_pic } = req.body;

  const user = new User({
    firebaseUid,
    name,
    email,
    bio,
    profile_pic
  });

  try {
    const saved = await user.save();
    res.status(201).json(saved);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// UPDATE user profile
router.put("/:firebaseUid", async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.params.firebaseUid });
    if (!user) return res.status(404).json({ message: "User not found" });

    user.name = req.body.name ?? user.name;
    user.bio = req.body.bio ?? user.bio;
    user.visible = req.body.visible ?? user.visible;
    user.profile_pic = req.body.profile_pic ?? user.profile_pic;

    const updated = await user.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// ADD a bookmark
router.post("/:firebaseUid/bookmark", async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.params.firebaseUid });
    if (!user) return res.status(404).json({ message: "User not found" });

    const { itemId } = req.body;

    if (!user.bookmarked.includes(itemId)) {
      user.bookmarked.push(itemId);
    }

    const updated = await user.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// REMOVE a bookmark
router.delete("/:firebaseUid/bookmark/:itemId", async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.params.firebaseUid });
    if (!user) return res.status(404).json({ message: "User not found" });

    user.bookmarked = user.bookmarked.filter(
      (id) => id !== req.params.itemId
    );

    const updated = await user.save();
    res.json(updated);
  } catch (err) {
    res.status(400).json({ message: err.message });
  }
});

// DELETE user (optional)
router.delete("/:firebaseUid", async (req, res) => {
  try {
    const user = await User.findOne({ firebaseUid: req.params.firebaseUid });
    if (!user) return res.status(404).json({ message: "User not found" });

    await user.deleteOne();
    res.json({ message: "User deleted" });
  } catch (err) {
    res.status(500).json({ message: err.message });
  }
});

export default router;
