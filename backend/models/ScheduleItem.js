import mongoose from "mongoose";

const scheduleItemSchema = new mongoose.Schema({
  userId: { type: String, required: true },
  type: { type: String, enum: ["Classes","Quizzes","Assignments","Others"], required: true },
  title: { type: String, required: true },
   day: { type: String },
  startDate: { type: Date },      
  endDate: { type: Date },        
  startTime: { type: String },    
  endTime: { type: String },      
  room: { type: String },
  details: { type: String },
  createdAt: { type: Date, default: Date.now }
});

// Return id instead of _id
scheduleItemSchema.set('toJSON', {
  virtuals: true,
  versionKey: false,
  transform: (doc, ret) => { delete ret._id; }
});


scheduleItemSchema.pre("save", function (next) {
  // Only validate if startDate and endDate are provided
  if (this.startDate && this.endDate) {
    if (this.endDate < this.startDate) {
      return next(new Error("End date must be after start date."));
    }
  }

  // Only validate time if startTime and endTime are provided
  if (this.startTime && this.endTime) {
    // Parse time strings into minutes
    const parseTime = (t) => {
      const [hourMin, period] = t.split(" ");
      let [h, m] = hourMin.split(":").map(Number);
      if (period.toUpperCase() === "PM" && h !== 12) h += 12;
      if (period.toUpperCase() === "AM" && h === 12) h = 0;
      return h * 60 + m;
    };

    const startMinutes = parseTime(this.startTime);
    const endMinutes = parseTime(this.endTime);

    // Only enforce endTime > startTime if startDate === endDate or endDate is missing
    const startDateTime = this.startDate ? new Date(this.startDate) : null;
    const endDateTime = this.endDate ? new Date(this.endDate) : null;

    if (
      (!startDateTime && !endDateTime) || // both dates missing
      (startDateTime && endDateTime && startDateTime.getTime() === endDateTime.getTime())
    ) {
      if (endMinutes <= startMinutes) {
        return next(new Error("End time must be after start time for the same day."));
      }
    }
  }

  next();
});


const ScheduleItem = mongoose.model("ScheduleItem", scheduleItemSchema);
export default ScheduleItem;
