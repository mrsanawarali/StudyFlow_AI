import mongoose from "mongoose";

const userSchema = new mongoose.Schema({
  firebaseUid: { type: String, required: true, unique: true },
  name: { type: String, required: true },
  bio:{type:String},
  profile_pic: { type: String },
  email: { type: String, required: true, unique: true },
  visible:{type:Boolean,default:true},
  bookmarked:[{type:String}]
});

export default mongoose.models.User || mongoose.model("User", userSchema);
