// middleware/upload.js
import multer from "multer";

// Files are kept in memory — faster, safer, no temp folder needed
const storage = multer.memoryStorage();

const upload = multer({
  storage,
  limits: {
    fileSize: 20 * 1024 * 1024 // 20MB max file size
  }
});

export default upload;
