import express from "express";
import axios from "axios";
import Note from "../models/Note.js";

const router = express.Router();

/**
 * GET /api/download/:id
 * Downloads a file from Cloudinary and returns it with correct filename + extension
 */
router.get("/:id", async (req, res) => {
  try {
    const note = await Note.findById(req.params.id);
    if (!note) return res.status(404).json({ message: "Note not found" });

    const url = note.type === "image" ? note.imageUrl : note.fileUrl;
    if (!url) return res.status(400).json({ message: "File URL missing" });

    // Request file from Cloudinary as a stream
    const response = await axios.get(url, { responseType: "arraybuffer" });

    const fileBuffer = response.data;
    const fileName = note.fileName || "download";

    // Send file with correct headers
    res.set({
      "Content-Type": response.headers["content-type"] || "application/octet-stream",
      "Content-Disposition": `attachment; filename="${fileName}"`,
    });

    res.send(fileBuffer);
  } catch (err) {
    console.error("Download error:", err);
    res.status(500).json({ message: "Download failed" });
  }
});

export default router;
