import mongoose, { Schema, InferSchemaType, model, models } from "mongoose";

const AdminUserSchema = new Schema({
  username: { type: String, required: true, unique: true, index: true },
  password_hash: { type: String, required: true },
  email: { type: String, required: true, index: true },
  role: {
    type: String,
    enum: ['super_admin', 'content_manager', 'teacher_manager', 'review_moderator', 'analytics_viewer', 'digital_marketer'],
    default: 'review_moderator'
  },
  permissions: {
    can_manage_teachers: { type: Boolean, default: false },
    can_manage_reviews: { type: Boolean, default: false },
    can_manage_content: { type: Boolean, default: false },
    can_view_analytics: { type: Boolean, default: false },
    can_manage_admins: { type: Boolean, default: false },
    can_manage_marketing: { type: Boolean, default: false }
  },
  is_active: { type: Boolean, default: true },
  last_login: { type: Date, default: null },
  created_by: { type: String, default: 'system' },
  created_at: { type: Date, default: Date.now },
  updated_at: { type: Date, default: Date.now }
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

export type AdminUser = InferSchemaType<typeof AdminUserSchema>;

export default models.AdminUser || model("AdminUser", AdminUserSchema);
