// routes/upload.js
import express from "express";
import cloudinary from "../config/cloudinary.js";
import upload from "../middleware/upload.js";
import Note from "../models/Note.js";

const router = express.Router();

/**
 * POST /api/upload
 * Handles one or multiple files
 * form-data fields:
 *  - files: file(s)
 *  - title[]: optional titles for each file (same order as files)
 *  - semesterId, subjectId, chapterId, userId
 */
router.post("/", async (req, res) => {
  try {
    const multerUpload = upload.any();
    multerUpload(req, res, async (err) => {
      if (err) return res.status(400).json({ message: err.message });
      if (!req.files || req.files.length === 0)
        return res.status(400).json({ message: "No files provided" });

      const { semesterId, subjectId, chapterId, userId } = req.body;
      if (!semesterId || !subjectId || !chapterId || !userId) {
        return res.status(400).json({ message: "Missing required IDs" });
      }

      // Ensure titles is always an array
      const titles = Array.isArray(req.body.title) ? req.body.title : [req.body.title || ""];

      // Helper to upload buffer to Cloudinary
      const uploadBuffer = (buffer, resourceType) =>
        new Promise((resolve, reject) => {
          const stream = cloudinary.uploader.upload_stream(
            { resource_type: resourceType },
            (error, result) => {
              if (error) return reject(error);
              resolve(result);
            }
          );
          stream.end(buffer);
        });

      // Process all files with Promise.allSettled
      const results = await Promise.allSettled(
        req.files.map(async (file, index) => {
          const isImage = file.mimetype.startsWith("image/");
          const resourceType = isImage ? "image" : "raw";
          const result = await uploadBuffer(file.buffer, resourceType);

          const note = new Note({
            semesterId,
            subjectId,
            chapterId,
            userId,
            type: isImage ? "image" : "file",
            fileUrl: isImage ? undefined : result.secure_url,
            imageUrl: isImage ? result.secure_url : undefined,
            fileName: file.originalname,
            title: titles[index] || file.originalname,
            publicId: result.public_id,
          });

          return await note.save();
        })
      );

      // Separate successes and failures
      const savedNotes = results
        .filter(r => r.status === "fulfilled")
        .map(r => r.value);

      const failedUploads = results
        .filter(r => r.status === "rejected")
        .map(r => r.reason);

      res.status(201).json({ savedNotes, failedUploads });
    });
  } catch (err) {
    console.error("Upload error:", err);
    res.status(500).json({ message: err.message || "Upload failed" });
  }
});

export default router;
