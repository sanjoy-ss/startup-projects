import mongoose, { Schema, InferSchemaType, model, models } from "mongoose";

const MarketingSettingsSchema = new Schema({
  // SEO Settings
  seo: {
    homepage: {
      title: { type: String, default: 'ALOGYAN - Find the Best Teachers Near You' },
      meta_description: { type: String, default: 'Connect with qualified teachers for all subjects. Find experienced tutors in your area.' },
      keywords: { type: [String], default: ['teachers', 'tutors', 'education', 'learning'] },
      og_image: { type: String, default: '' }
    },
    about: {
      title: { type: String, default: 'About ALOGYAN - Our Mission' },
      meta_description: { type: String, default: '' },
      keywords: { type: [String], default: [] }
    },
    contact: {
      title: { type: String, default: 'Contact Us - ALOGYAN' },
      meta_description: { type: String, default: '' },
      keywords: { type: [String], default: [] }
    },
    teachers: {
      title: { type: String, default: 'Find Teachers - ALOGYAN' },
      meta_description: { type: String, default: '' },
      keywords: { type: [String], default: [] }
    }
  },

  // Hero Section Content
  hero: {
    main_heading: { type: String, default: 'Find Your Perfect Teacher' },
    sub_heading: { type: String, default: 'Connect with qualified educators for any subject' },
    cta_primary_text: { type: String, default: 'Find Teachers' },
    cta_secondary_text: { type: String, default: 'List as Teacher' },
    background_image: { type: String, default: '' },
    video_url: { type: String, default: '' }
  },

  // Social Media Links
  social: {
    facebook: { type: String, default: '' },
    twitter: { type: String, default: '' },
    instagram: { type: String, default: '' },
    linkedin: { type: String, default: '' },
    youtube: { type: String, default: '' },
    whatsapp: { type: String, default: '' }
  },

  // Contact Information
  contact: {
    email: { type: String, default: 'alogyan.main@gmail.com' },
    phone: { type: String, default: '' }, // Phone number commented out for now
    address: { type: String, default: '' }, // HQ location commented out for now
    support_hours: { type: String, default: 'Mon-Fri, 9AM-6PM' }
  },

  // Featured Sections
  features: [{
    title: { type: String, default: '' },
    description: { type: String, default: '' },
    icon: { type: String, default: '' },
    order: { type: Number, default: 0 }
  }],

  // Testimonials
  testimonials: [{
    name: { type: String, default: '' },
    role: { type: String, default: '' },
    content: { type: String, default: '' },
    avatar: { type: String, default: '' },
    rating: { type: Number, default: 5 },
    is_featured: { type: Boolean, default: false }
  }],

  // Analytics & Tracking
  analytics: {
    google_analytics_id: { type: String, default: '' },
    facebook_pixel_id: { type: String, default: '' },
    google_tag_manager_id: { type: String, default: '' },
    hotjar_id: { type: String, default: '' }
  },

  // Call-to-Action Banners
  cta_banners: [{
    title: { type: String, default: '' },
    description: { type: String, default: '' },
    button_text: { type: String, default: '' },
    button_link: { type: String, default: '' },
    background_color: { type: String, default: '' },
    text_color: { type: String, default: '' },
    is_active: { type: Boolean, default: true },
    position: { type: String, enum: ['top', 'bottom', 'sidebar'], default: 'top' }
  }],

  // Footer Content
  footer: {
    about_text: { type: String, default: '' },
    copyright_text: { type: String, default: '© 2024 ALOGYAN. All rights reserved.' },
    links: [{
      title: { type: String, default: '' },
      url: { type: String, default: '' }
    }]
  },

  // FAQ Section
  faqs: [{
    question: { type: String, default: '' },
    answer: { type: String, default: '' },
    category: { type: String, default: 'general' },
    order: { type: Number, default: 0 },
    is_published: { type: Boolean, default: true }
  }],

  // Blog/News Settings
  blog: {
    enabled: { type: Boolean, default: false },
    posts_per_page: { type: Number, default: 10 },
    show_author: { type: Boolean, default: true },
    allow_comments: { type: Boolean, default: false }
  },

  updated_by: { type: String, default: 'system' },
  updated_at: { type: Date, default: Date.now }
}, { timestamps: { createdAt: 'created_at', updatedAt: 'updated_at' } });

export type MarketingSettings = InferSchemaType<typeof MarketingSettingsSchema>;

export default models.MarketingSettings || model("MarketingSettings", MarketingSettingsSchema);
