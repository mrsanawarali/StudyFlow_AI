import mongoose from "mongoose";
import Note from "./Note.js"; // Make sure path is correct

const chapterSchema = new mongoose.Schema({
  semesterId: { type: mongoose.Schema.Types.ObjectId, ref: "Semester", required: true },
  subjectId: { type: mongoose.Schema.Types.ObjectId, ref: "Subject", required: true },
  title: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

// Return `id` instead of `_id` in JSON
chapterSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: (doc, ret) => { delete ret._id; }
});

/**
 * Pre-remove middleware to handle cascading deletes
 * Deleting a chapter deletes all its notes
 */
chapterSchema.pre("deleteOne", { document: true, query: false }, async function(next) {
  try {
    const notes = await Note.find({ chapterId: this.id });
    // for (let note of notes) {
    //   await note.deleteOne(); // triggers Note's pre-hook for Cloudinary cleanup
    // }
    await Promise.all(notes.map(note => note.deleteOne())); // 🔹 parallel delete
    next();
  } catch (err) {
    next(err);
  }
});

const Chapter = mongoose.model("Chapter", chapterSchema);

export default Chapter;
