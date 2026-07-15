import mongoose from "mongoose";
import Chapter from "./Chapter.js"; // Make sure path is correct

const subjectSchema = new mongoose.Schema({
  semesterId: { type: mongoose.Schema.Types.ObjectId, ref: "Semester", required: true },
  title: { type: String, required: true },
  courseCode: { type: String },
  instructor: { type: String },
  createdAt: { type: Date, default: Date.now }
});

// Return `id` instead of `_id` in JSON
subjectSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: (doc, ret) => { delete ret._id; }
});

/**
 * Pre-remove middleware to handle cascading deletes
 * Deleting a subject deletes all its chapters
 */
subjectSchema.pre("deleteOne", { document: true, query: false }, async function(next) {
  try {
    const chapters = await Chapter.find({ subjectId: this.id });
    // for (let chapter of chapters) {
    //   await chapter.deleteOne(); // triggers Chapter's pre-hook, which deletes Notes
    // }

    await Promise.all(chapters.map(chapter => chapter.deleteOne())); // 🔹 parallel delete

    next();
  } catch (err) {
    next(err);
  }
});

const Subject = mongoose.model("Subject", subjectSchema);

export default Subject;
