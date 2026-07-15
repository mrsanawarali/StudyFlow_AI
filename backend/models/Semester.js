
import mongoose from "mongoose";
import Subject from "./Subject.js"; // Make sure path is correct

const semesterSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  title: { type: String, required: true },
  createdAt: { type: Date, default: Date.now }
});

// Return `id` instead of `_id` in JSON
semesterSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: (doc, ret) => { delete ret._id; }
});

/**
 * Pre-remove middleware to handle cascading deletes
 */
semesterSchema.pre("deleteOne", { document: true, query: false }, async function(next) {
  try {
    const subjects = await Subject.find({ semesterId: this.id });
    // for (let subject of subjects) {
    //   await subject.deleteOne(); // recursive delete
    // }
    await Promise.all(subjects.map(subject => subject.deleteOne()));  // 🔹 parallel delete

    next();
  } catch (err) {
    next(err);
  }
});

const Semester = mongoose.model("Semester", semesterSchema);

export default Semester;
