import mongoose from "mongoose";
import cloudinary from "../config/cloudinary.js"; // make sure path is correct

const noteSchema = new mongoose.Schema({
  semesterId: { type: mongoose.Schema.Types.ObjectId, ref: "Semester", required: true },
  subjectId: { type: mongoose.Schema.Types.ObjectId, ref: "Subject", required: true },
  chapterId: { type: mongoose.Schema.Types.ObjectId, ref: "Chapter", required: true },

  userId: { type: String, required: true }, // firebase uid

  type: { 
    type: String, 
    enum: ["text", "image", "file"], 
    required: true 
  },

  // TEXT NOTE
  title: { type: String },
  content: { type: String },

  // IMAGE NOTE
  imageUrl: { type: String },

  // FILE NOTE
  fileUrl: { type: String },
  fileName: { type: String },
  publicId: { type: String }, // NEW

  createdAt: { type: Date, default: Date.now }
});

// Make id appear in JSON
noteSchema.set("toJSON", {
  virtuals: true,
  versionKey: false,
  transform: (_, ret) => { delete ret._id; }
});

/**
 * Pre-remove middleware to clean up Cloudinary files
 */
noteSchema.pre("deleteOne", { document: true, query: false }, async function(next) {
  try {
    if (this.publicId) {
      const resourceType = this.type === "image" ? "image" : "raw";
      await cloudinary.uploader.destroy(this.publicId, { resource_type: resourceType });
    }
    next();
  } catch (err) {
    next(err);
  }
});


export default mongoose.model("Note", noteSchema);
