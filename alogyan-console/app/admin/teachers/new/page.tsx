'use client';

import { directoryCategories } from '@/lib/directory-categories';
import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { Save, ArrowLeft, Plus, X, AlertCircle } from 'lucide-react';
import Link from 'next/link';
import { slugify } from '@/lib/untils/utils';

interface TeacherFormData {
  name: string;
  email: string;
  phone: string[];
  category: string;
  institution: string;
  subject: string[];
  qualification: string;
  experience_years: number;
  location: {
    city: string;
    address: string;
  };
  profile_image: string;
  is_featured: boolean;
  ad_listing: {
    active: boolean;
  };
}

export default function NewTeacherPage() {
  const router = useRouter();
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState('');

  const [formData, setFormData] = useState<TeacherFormData>({
    name: '',
    email: '',
    phone: [''],
    category: '',
    institution: '',
    subject: [''],
    qualification: '',
    experience_years: 0,
    location: {
      city: '',
      address: ''
    },
    profile_image: '',
    is_featured: false,
    ad_listing: {
      active: true
    }
  });

  const updateField = (path: string, value: any) => {
    setFormData((prev) => {
      const keys = path.split('.');
      if (keys.length === 1) {
        return { ...prev, [keys[0]]: value };
      }
      if (keys.length === 2) {
        return {
          ...prev,
          [keys[0]]: {
            ...(prev[keys[0] as keyof TeacherFormData] as any),
            [keys[1]]: value
          }
        };
      }
      return prev;
    });
  };

  const addArrayItem = (field: 'phone' | 'subject') => {
    setFormData((prev) => ({
      ...prev,
      [field]: [...prev[field], '']
    }));
  };

  const updateArrayItem = (field: 'phone' | 'subject', index: number, value: string) => {
    setFormData((prev) => ({
      ...prev,
      [field]: prev[field].map((item, i) => (i === index ? value : item))
    }));
  };

  const removeArrayItem = (field: 'phone' | 'subject', index: number) => {
    setFormData((prev) => ({
      ...prev,
      [field]: prev[field].filter((_, i) => i !== index)
    }));
  };

  const handleSave = async () => {
    if (!formData.name.trim()) {
      setError('Teacher name is required');
      return;
    }

    if (!formData.location.city.trim()) {
      setError('City is required');
      return;
    }

    setSaving(true);
    setError('');

    try {
      const slug = slugify(formData.name);
      const teacherData = {
        ...formData,
        id: slug + '-' + Date.now(),
        seo: {
          slug,
          keywords: formData.subject,
          meta_description: `${formData.name} teaches ${formData.subject.join(', ')} in ${formData.location.city}`
        },
        phone: formData.phone.filter((p) => p.trim() !== ''),
        subject: formData.subject.filter((s) => s.trim() !== ''),
        rating: 0,
        review_count: 0
      };

      const response = await fetch('/api/admin/teachers/create', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(teacherData),
        credentials: 'include'
      });

      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Failed to create teacher');
      }

      router.push('/admin/teachers');
    } catch (err: any) {
      setError(err.message || 'Failed to create teacher');
    } finally {
      setSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-3xl font-bold text-gray-900">Add New Teacher</h2>
          <p className="text-gray-600 mt-1">Create a new teacher profile</p>
        </div>
        <Link href="/admin/teachers" className="inline-flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-lg text-gray-700 hover:bg-gray-50">
          <ArrowLeft className="h-5 w-5" />
          Back
        </Link>
      </div>

      {error && (
        <div className="bg-red-50 border border-red-200 rounded-xl p-4 flex gap-3">
          <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0" />
          <p className="text-red-700 text-sm font-medium">{error}</p>
        </div>
      )}

      <div className="bg-white rounded-2xl shadow-lg p-8 space-y-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Name *</label>
            <input
              type="text"
              value={formData.name}
              onChange={(e) => updateField('name', e.target.value)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              placeholder="Full name"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Email</label>
            <input
              type="email"
              value={formData.email}
              onChange={(e) => updateField('email', e.target.value)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              placeholder="email@example.com"
            />
          </div>

          <div>
            <label htmlFor="provider-category" className="block text-sm font-semibold text-gray-700 mb-2">Education category</label>
            <select id="provider-category" value={formData.category} onChange={e => updateField('category', e.target.value)} className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl mb-4">
              <option value="">Uncategorized</option>
              {directoryCategories.map(category => <option key={category.id} value={category.id}>{category.name}</option>)}
            </select>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Institution</label>
            <input
              type="text"
              value={formData.institution}
              onChange={(e) => updateField('institution', e.target.value)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              placeholder="School or College"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Qualification</label>
            <input
              type="text"
              value={formData.qualification}
              onChange={(e) => updateField('qualification', e.target.value)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              placeholder="e.g., B.Ed, M.Sc"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Experience (years)</label>
            <input
              type="number"
              value={formData.experience_years}
              onChange={(e) => updateField('experience_years', parseInt(e.target.value) || 0)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              placeholder="0"
              min="0"
            />
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">City *</label>
            <input
              type="text"
              value={formData.location.city}
              onChange={(e) => updateField('location.city', e.target.value)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              placeholder="City"
            />
          </div>
        </div>

        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2">Address</label>
          <input
            type="text"
            value={formData.location.address}
            onChange={(e) => updateField('location.address', e.target.value)}
            className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
            placeholder="Full address"
          />
        </div>

        <div>
          <label className="block text-sm font-semibold text-gray-700 mb-2">Profile Image URL</label>
          <input
            type="text"
            value={formData.profile_image}
            onChange={(e) => updateField('profile_image', e.target.value)}
            className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
            placeholder="https://example.com/image.jpg"
          />
        </div>

        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="block text-sm font-semibold text-gray-700">Phone Numbers</label>
            <button
              type="button"
              onClick={() => addArrayItem('phone')}
              className="inline-flex items-center gap-1 text-xs font-semibold text-brand-coral hover:underline"
            >
              <Plus className="h-4 w-4" />
              Add Phone
            </button>
          </div>
          <div className="space-y-2">
            {formData.phone.map((phone, idx) => (
              <div key={idx} className="flex gap-2">
                <input
                  type="text"
                  value={phone}
                  onChange={(e) => updateArrayItem('phone', idx, e.target.value)}
                  className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Phone number"
                />
                {formData.phone.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeArrayItem('phone', idx)}
                    className="px-3 py-3 text-red-600 hover:bg-red-50 rounded-lg"
                    title="Remove phone"
                  >
                    <X className="h-5 w-5" />
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        <div>
          <div className="flex items-center justify-between mb-2">
            <label className="block text-sm font-semibold text-gray-700">Subjects</label>
            <button
              type="button"
              onClick={() => addArrayItem('subject')}
              className="inline-flex items-center gap-1 text-xs font-semibold text-brand-coral hover:underline"
            >
              <Plus className="h-4 w-4" />
              Add Subject
            </button>
          </div>
          <div className="space-y-2">
            {formData.subject.map((subj, idx) => (
              <div key={idx} className="flex gap-2">
                <input
                  type="text"
                  value={subj}
                  onChange={(e) => updateArrayItem('subject', idx, e.target.value)}
                  className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Subject name"
                />
                {formData.subject.length > 1 && (
                  <button
                    type="button"
                    onClick={() => removeArrayItem('subject', idx)}
                    className="px-3 py-3 text-red-600 hover:bg-red-50 rounded-lg"
                    title="Remove subject"
                  >
                    <X className="h-5 w-5" />
                  </button>
                )}
              </div>
            ))}
          </div>
        </div>

        <div className="flex gap-4">
          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={formData.is_featured}
              onChange={(e) => updateField('is_featured', e.target.checked)}
              className="w-5 h-5 rounded border-gray-300 text-brand-coral focus:ring-brand-coral"
            />
            <span className="text-sm font-semibold text-gray-700">Featured Teacher</span>
          </label>

          <label className="flex items-center gap-3 cursor-pointer">
            <input
              type="checkbox"
              checked={formData.ad_listing.active}
              onChange={(e) => updateField('ad_listing.active', e.target.checked)}
              className="w-5 h-5 rounded border-gray-300 text-brand-coral focus:ring-brand-coral"
            />
            <span className="text-sm font-semibold text-gray-700">Active Listing</span>
          </label>
        </div>

        <div className="flex gap-4 pt-4 border-t border-gray-200">
          <button
            type="button"
            onClick={handleSave}
            disabled={saving}
            className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
          >
            <Save className="h-5 w-5" />
            {saving ? 'Creating...' : 'Create Teacher'}
          </button>
          <Link
            href="/admin/teachers"
            className="flex items-center gap-2 px-6 py-3 border-2 border-gray-200 rounded-xl font-bold text-gray-700 hover:bg-gray-50"
          >
            Cancel
          </Link>
        </div>
      </div>
    </div>
  );
}
