import { directoryCategories } from '@/lib/directory-categories';
import mongoose, { Schema, InferSchemaType, model, models, CallbackWithoutResultAndOptionalError } from "mongoose";

const TeacherSchema = new Schema({
  category: { type: String, enum: ['', ...directoryCategories.map(category => category.id)], default: '', index: true },
  institution: { type: String, default: "" },
  name: { type: String, required: true, index: true },
  ad_listing: {
    active: { type: Boolean, default: false },
    expires_at: { type: Date, default: null }
  },
  created_at: { type: Date, default: Date.now },
  email: { type: String, default: "" },
  experience_years: { type: Number, default: 0 },
  fees: { type: Schema.Types.Mixed, default: {} },
  id: { type: String, required: true, unique: true },
  is_featured: { type: Boolean, default: false, index: true },
  location: {
    city: { type: String, index: true },
    address: { type: String, default: "" },
    lat: { type: Number, default: null },
    lng: { type: Number, default: null }
  },
  phone: { type: [String], default: [] },
  profile_image: { type: String, default: "" },
  qualification: { type: String, default: "" },
  rating: { type: Number, default: 0, index: true },
  review_count: { type: Number, default: 0, index: true },
  seo: {
    slug: { type: String, required: true, unique: true, index: true },
    keywords: { type: [String], default: [] },
    meta_description: { type: String, default: "" }
  },
  slots: { type: [Schema.Types.Mixed], default: [] },
  subject: { type: [String], default: [], index: true },
  updated_at: { type: Date, default: Date.now },
  // New field for full-text search optimization
  search_text: { type: String }
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

// Compound indexes for optimized queries
TeacherSchema.index({ 'location.city': 1, subject: 1 });
TeacherSchema.index({ rating: -1, review_count: -1 });
TeacherSchema.index({ is_featured: -1, rating: -1 });

// Text index for full-text search
TeacherSchema.index({ 
  name: 'text', 
  institution: 'text',
  'seo.keywords': 'text',
  subject: 'text'
}, {
  weights: {
    name: 10,
    subject: 5,
    'seo.keywords': 5,
    institution: 3
  }
});

// Pre-save middleware to update search_text
TeacherSchema.pre('save', function(this: any) {
  this.search_text = [
    this.name,
    this.institution,
    this.subject?.join(' '),
    this.location?.city
  ].filter(Boolean).join(' ').toLowerCase();
});

// Static method for auto-suggestions
TeacherSchema.statics.getAutoSuggestions = async function(query: string, limit: number = 5) {
  const regex = new RegExp(query, 'i');
  
  // Get teacher name suggestions
  const teachers = await this.find({
    name: regex
  })
  .limit(limit)
  .select('name seo.slug profile_image')
  .lean();
  
  // Get subject suggestions
  const subjects = await this.aggregate([
    { $unwind: '$subject' },
    { $match: { subject: regex } },
    { $group: { _id: '$subject', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: limit }
  ]);
  
  // Get city suggestions
  const cities = await this.aggregate([
    { $match: { 'location.city': regex } },
    { $group: { _id: '$location.city', count: { $sum: 1 } } },
    { $sort: { count: -1 } },
    { $limit: limit }
  ]);
  
  return {
    teachers: teachers.map((t: any) => ({ 
      type: 'teacher', 
      name: t.name, 
      slug: t.seo.slug,
      image: t.profile_image 
    })),
    subjects: subjects.map((s: any) => ({ 
      type: 'subject', 
      name: s._id, 
      count: s.count 
    })),
    cities: cities.map((c: any) => ({ 
      type: 'city', 
      name: c._id, 
      count: c.count 
    }))
  };
};

// Static method for full-text search
TeacherSchema.statics.searchTeachers = async function(query: string, options: any = {}) {
  const { limit = 10, skip = 0, filters = {} } = options;
  
  const searchQuery: any = {
    $text: { $search: query }
  };
  
  // Apply additional filters
  if (filters.subject) searchQuery.subject = filters.subject;
  if (filters.city) searchQuery['location.city'] = new RegExp(filters.city, 'i');
  if (filters.minRating) searchQuery.rating = { $gte: filters.minRating };
  
  const results = await this.find(
    searchQuery,
    { score: { $meta: 'textScore' } }
  )
  .sort({ score: { $meta: 'textScore' }, rating: -1 })
  .skip(skip)
  .limit(limit)
  .select('name institution profile_image rating subject location seo review_count')
  .lean();
  
  const total = await this.countDocuments(searchQuery);
  
  return { results, total };
};

export type Teacher = InferSchemaType<typeof TeacherSchema>;

export default models.Teacher || model("Teacher", TeacherSchema);
