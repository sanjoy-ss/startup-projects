import mongoose, { Schema, InferSchemaType, models, model } from "mongoose";

const ReviewSchema = new Schema({
  teacher_id: { type: Schema.Types.ObjectId, ref: "Teacher", required: true, index: true },
  teacher_slug: { type: String, required: true, index: true },
  rating: { type: Number, min: 1, max: 5, required: true, index: true },
  title: { type: String, default: "" },
  body: { type: String, default: "" },
  author_name: { type: String, default: "Anonymous" },
  author_email: { type: String, default: "" },
  helpful_count: { type: Number, default: 0 },
  is_verified: { type: Boolean, default: false },
  is_approved: { type: Boolean, default: true, index: true },
  created_at: { type: Date, default: Date.now, index: true },
  updated_at: { type: Date, default: Date.now }
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

// Compound indexes for common queries
ReviewSchema.index({ teacher_id: 1, created_at: -1 });
ReviewSchema.index({ teacher_slug: 1, is_approved: 1, created_at: -1 });
ReviewSchema.index({ rating: -1, helpful_count: -1 });

// Static method to get teacher review stats
ReviewSchema.statics.getTeacherStats = async function(teacherId: string) {
  const stats = await this.aggregate([
    { 
      $match: { 
        teacher_id: new mongoose.Types.ObjectId(teacherId),
        is_approved: true 
      } 
    },
    {
      $group: {
        _id: null,
        total_reviews: { $sum: 1 },
        average_rating: { $avg: '$rating' },
        five_star: { $sum: { $cond: [{ $eq: ['$rating', 5] }, 1, 0] } },
        four_star: { $sum: { $cond: [{ $eq: ['$rating', 4] }, 1, 0] } },
        three_star: { $sum: { $cond: [{ $eq: ['$rating', 3] }, 1, 0] } },
        two_star: { $sum: { $cond: [{ $eq: ['$rating', 2] }, 1, 0] } },
        one_star: { $sum: { $cond: [{ $eq: ['$rating', 1] }, 1, 0] } }
      }
    }
  ]);
  
  return stats[0] || {
    total_reviews: 0,
    average_rating: 0,
    five_star: 0,
    four_star: 0,
    three_star: 0,
    two_star: 0,
    one_star: 0
  };
};

// Post-save hook to update teacher ratings (only for approved reviews)
ReviewSchema.post('save', async function() {
  if (this.is_approved) {
    const Teacher = mongoose.models.Teacher;
    if (Teacher) {
      const stats = await (this.constructor as any).getTeacherStats(this.teacher_id);
      await Teacher.findByIdAndUpdate(this.teacher_id, {
        rating: stats.average_rating || 0,
        review_count: stats.total_reviews || 0
      });
    }
  }
});

export type Review = InferSchemaType<typeof ReviewSchema>;
export default models.Review || model("Review", ReviewSchema);
