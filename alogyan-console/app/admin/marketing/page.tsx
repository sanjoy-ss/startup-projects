'use client';

import { useEffect, useState } from 'react';
import {
  Save,
  AlertCircle,
  CheckCircle,
  Megaphone,
  Search,
  Globe,
  Image as ImageIcon,
  Share2,
  Phone,
  Mail,
  Target,
  TrendingUp,
  Eye,
  Plus,
  X,
  Edit2,
  Trash2,
  BarChart2,
  MessageSquare,
  Star
} from 'lucide-react';
import Image from 'next/image';

interface MarketingData {
  seo: any;
  hero: any;
  social: any;
  contact: any;
  features: any[];
  testimonials: any[];
  analytics: any;
  cta_banners: any[];
  footer: any;
  faqs: any[];
  blog: any;
}

export default function DigitalMarketingPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });
  const [activeTab, setActiveTab] = useState('seo');
  const [marketingData, setMarketingData] = useState<MarketingData | null>(null);

  useEffect(() => {
    fetchMarketingData();
  }, []);

  const fetchMarketingData = async () => {
    try {
      const response = await fetch('/api/admin/marketing', {
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to fetch marketing data');

      const data = await response.json();
      setMarketingData(data);
    } catch (error) {
      console.error('Error fetching marketing data:', error);
      setMessage({ type: 'error', text: 'Failed to load marketing data' });
    } finally {
      setLoading(false);
    }
  };

  const handleSave = async (section: string, data: any) => {
    setSaving(true);
    setMessage({ type: '', text: '' });

    try {
      const response = await fetch('/api/admin/marketing', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ section, data }),
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to save');

      setMessage({ type: 'success', text: 'Changes saved successfully!' });
      await fetchMarketingData();
      
      // Emit event to trigger real-time sync on public website
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new Event('marketing-settings-updated'));
      }
      
      setTimeout(() => setMessage({ type: '', text: '' }), 3000);
    } catch (error) {
      setMessage({ type: 'error', text: 'Failed to save changes' });
    } finally {
      setSaving(false);
    }
  };

  const updateField = (section: string, path: string, value: any) => {
    if (!marketingData) return;

    const keys = path.split('.');
    const updatedData = { ...marketingData };
    let current: any = updatedData[section as keyof MarketingData];

    for (let i = 0; i < keys.length - 1; i++) {
      current = current[keys[i]];
    }
    current[keys[keys.length - 1]] = value;

    setMarketingData(updatedData);
  };

  const tabs = [
    { id: 'seo', label: 'SEO Settings', icon: Search },
    { id: 'hero', label: 'Hero Section', icon: Target },
    { id: 'social', label: 'Social Media', icon: Share2 },
    { id: 'contact', label: 'Contact Info', icon: Phone },
    { id: 'features', label: 'Features', icon: Star },
    { id: 'testimonials', label: 'Testimonials', icon: MessageSquare },
    { id: 'analytics', label: 'Analytics', icon: BarChart2 },
    { id: 'cta', label: 'CTA Banners', icon: Megaphone },
    { id: 'footer', label: 'Footer', icon: Globe },
    { id: 'faqs', label: 'FAQs', icon: MessageSquare }
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center py-12">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-brand-coral/30 border-t-brand-coral rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Loading marketing settings...</p>
        </div>
      </div>
    );
  }

  if (!marketingData) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-xl p-6">
        <p className="text-red-700">Failed to load marketing data</p>
      </div>
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="bg-brand-gradient rounded-2xl shadow-xl p-8 text-white">
        <div className="flex items-center gap-4">
          <Megaphone className="h-12 w-12" />
          <div>
            <h2 className="text-3xl font-bold mb-2">Digital Marketing Hub</h2>
            <p className="text-white/90">
              Manage all website content, SEO, social media, and marketing materials
            </p>
          </div>
        </div>
      </div>

      {/* Status Message */}
      {message.text && (
        <div
          className={`p-4 rounded-xl flex items-center gap-3 ${
            message.type === 'success'
              ? 'bg-green-50 border border-green-200 text-green-700'
              : 'bg-red-50 border border-red-200 text-red-700'
          }`}
        >
          {message.type === 'success' ? (
            <CheckCircle className="h-5 w-5" />
          ) : (
            <AlertCircle className="h-5 w-5" />
          )}
          <p className="font-medium">{message.text}</p>
        </div>
      )}

      {/* Tabs */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <div className="flex gap-2 overflow-x-auto pb-4 border-b border-gray-200">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-4 py-2 rounded-lg font-semibold whitespace-nowrap transition-all ${
                  activeTab === tab.id
                    ? 'bg-brand-gradient text-white shadow-lg'
                    : 'text-gray-600 hover:bg-gray-100'
                }`}
              >
                <Icon className="h-4 w-4" />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Tab Content */}
        <div className="mt-6">
          {/* SEO Settings */}
          {activeTab === 'seo' && (
            <div className="space-y-6">
              <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Search className="h-6 w-6 text-brand-coral" />
                SEO & Meta Tags
              </h3>

              {Object.keys(marketingData.seo).map((page) => (
                <div key={page} className="bg-gray-50 rounded-xl p-6 space-y-4">
                  <h4 className="font-bold text-gray-900 capitalize">{page} Page</h4>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Page Title
                    </label>
                    <input
                      type="text"
                      value={marketingData.seo[page].title || ''}
                      onChange={(e) =>
                        updateField('seo', `${page}.title`, e.target.value)
                      }
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                      placeholder="Enter page title"
                    />
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Meta Description
                    </label>
                    <textarea
                      value={marketingData.seo[page].meta_description || ''}
                      onChange={(e) =>
                        updateField('seo', `${page}.meta_description`, e.target.value)
                      }
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                      rows={3}
                      placeholder="Enter meta description (150-160 characters)"
                    />
                    <p className="text-xs text-gray-500 mt-1">
                      {(marketingData.seo[page].meta_description || '').length} / 160 characters
                    </p>
                  </div>

                  <div>
                    <label className="block text-sm font-semibold text-gray-700 mb-2">
                      Keywords (comma-separated)
                    </label>
                    <input
                      type="text"
                      value={(marketingData.seo[page].keywords || []).join(', ')}
                      onChange={(e) =>
                        updateField(
                          'seo',
                          `${page}.keywords`,
                          e.target.value.split(',').map((k) => k.trim())
                        )
                      }
                      className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                      placeholder="keyword1, keyword2, keyword3"
                    />
                  </div>

                  {page === 'homepage' && (
                    <div>
                      <label className="block text-sm font-semibold text-gray-700 mb-2">
                        OG Image URL
                      </label>
                      <input
                        type="text"
                        value={marketingData.seo[page].og_image || ''}
                        onChange={(e) =>
                          updateField('seo', `${page}.og_image`, e.target.value)
                        }
                        className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                        placeholder="https://example.com/image.jpg"
                      />
                    </div>
                  )}
                </div>
              ))}

              <button
                onClick={() => handleSave('seo', marketingData.seo)}
                disabled={saving}
                className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                <Save className="h-5 w-5" />
                {saving ? 'Saving...' : 'Save SEO Settings'}
              </button>
            </div>
          )}

          {/* Hero Section */}
          {activeTab === 'hero' && (
            <div className="space-y-6">
              <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Target className="h-6 w-6 text-brand-coral" />
                Hero Section Content
              </h3>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Main Heading
                </label>
                <input
                  type="text"
                  value={marketingData.hero.main_heading || ''}
                  onChange={(e) =>
                    updateField('hero', 'main_heading', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Enter main heading"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Sub Heading
                </label>
                <input
                  type="text"
                  value={marketingData.hero.sub_heading || ''}
                  onChange={(e) => updateField('hero', 'sub_heading', e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Enter sub heading"
                />
              </div>

              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Primary CTA Text
                  </label>
                  <input
                    type="text"
                    value={marketingData.hero.cta_primary_text || ''}
                    onChange={(e) =>
                      updateField('hero', 'cta_primary_text', e.target.value)
                    }
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                    placeholder="e.g., Get Started"
                  />
                </div>

                <div>
                  <label className="block text-sm font-semibold text-gray-700 mb-2">
                    Secondary CTA Text
                  </label>
                  <input
                    type="text"
                    value={marketingData.hero.cta_secondary_text || ''}
                    onChange={(e) =>
                      updateField('hero', 'cta_secondary_text', e.target.value)
                    }
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                    placeholder="e.g., Learn More"
                  />
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Background Image URL
                </label>
                <input
                  type="text"
                  value={marketingData.hero.background_image || ''}
                  onChange={(e) =>
                    updateField('hero', 'background_image', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="https://example.com/hero-bg.jpg"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Video URL (Optional)
                </label>
                <input
                  type="text"
                  value={marketingData.hero.video_url || ''}
                  onChange={(e) => updateField('hero', 'video_url', e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="https://youtube.com/watch?v=..."
                />
              </div>

              <button
                onClick={() => handleSave('hero', marketingData.hero)}
                disabled={saving}
                className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                <Save className="h-5 w-5" />
                {saving ? 'Saving...' : 'Save Hero Settings'}
              </button>
            </div>
          )}

          {/* Social Media */}
          {activeTab === 'social' && (
            <div className="space-y-6">
              <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Share2 className="h-6 w-6 text-brand-coral" />
                Social Media Links
              </h3>

              {Object.keys(marketingData.social).map((platform) => (
                <div key={platform}>
                  <label className="block text-sm font-semibold text-gray-700 mb-2 capitalize">
                    {platform} URL
                  </label>
                  <input
                    type="text"
                    value={marketingData.social[platform] || ''}
                    onChange={(e) =>
                      updateField('social', platform, e.target.value)
                    }
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                    placeholder={`https://${platform}.com/yourpage`}
                  />
                </div>
              ))}

              <button
                onClick={() => handleSave('social', marketingData.social)}
                disabled={saving}
                className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                <Save className="h-5 w-5" />
                {saving ? 'Saving...' : 'Save Social Links'}
              </button>
            </div>
          )}

          {/* Contact Information */}
          {activeTab === 'contact' && (
            <div className="space-y-6">
              <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Phone className="h-6 w-6 text-brand-coral" />
                Contact Information
              </h3>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Email
                </label>
                <input
                  type="email"
                  value={marketingData.contact.email || ''}
                  onChange={(e) => updateField('contact', 'email', e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="alogyan.main@gmail.com"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Phone
                </label>
                <input
                  type="text"
                  value={marketingData.contact.phone || ''}
                  onChange={(e) => updateField('contact', 'phone', e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="+1 234 567 8900"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Address
                </label>
                <textarea
                  value={marketingData.contact.address || ''}
                  onChange={(e) => updateField('contact', 'address', e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  rows={3}
                  placeholder="Street address, City, State, ZIP"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Support Hours
                </label>
                <input
                  type="text"
                  value={marketingData.contact.support_hours || ''}
                  onChange={(e) =>
                    updateField('contact', 'support_hours', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Mon-Fri, 9AM-6PM"
                />
              </div>

              <button
                onClick={() => handleSave('contact', marketingData.contact)}
                disabled={saving}
                className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                <Save className="h-5 w-5" />
                {saving ? 'Saving...' : 'Save Contact Info'}
              </button>
            </div>
          )}

          {/* Analytics */}
          {activeTab === 'analytics' && (
            <div className="space-y-6">
              <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <BarChart2 className="h-6 w-6 text-brand-coral" />
                Analytics & Tracking Codes
              </h3>

              <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4 flex gap-3">
                <AlertCircle className="h-5 w-5 text-yellow-600 flex-shrink-0" />
                <div className="text-sm text-yellow-700">
                  <p className="font-bold mb-1">Privacy Notice</p>
                  <p>
                    Ensure you have proper consent mechanisms in place before adding tracking codes.
                  </p>
                </div>
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Google Analytics ID
                </label>
                <input
                  type="text"
                  value={marketingData.analytics.google_analytics_id || ''}
                  onChange={(e) =>
                    updateField('analytics', 'google_analytics_id', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="G-XXXXXXXXXX"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Facebook Pixel ID
                </label>
                <input
                  type="text"
                  value={marketingData.analytics.facebook_pixel_id || ''}
                  onChange={(e) =>
                    updateField('analytics', 'facebook_pixel_id', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="123456789012345"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Google Tag Manager ID
                </label>
                <input
                  type="text"
                  value={marketingData.analytics.google_tag_manager_id || ''}
                  onChange={(e) =>
                    updateField('analytics', 'google_tag_manager_id', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="GTM-XXXXXXX"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Hotjar ID
                </label>
                <input
                  type="text"
                  value={marketingData.analytics.hotjar_id || ''}
                  onChange={(e) =>
                    updateField('analytics', 'hotjar_id', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="1234567"
                />
              </div>

              <button
                onClick={() => handleSave('analytics', marketingData.analytics)}
                disabled={saving}
                className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                <Save className="h-5 w-5" />
                {saving ? 'Saving...' : 'Save Analytics Settings'}
              </button>
            </div>
          )}

          {/* Footer */}
          {activeTab === 'footer' && (
            <div className="space-y-6">
              <h3 className="text-xl font-bold text-gray-900 flex items-center gap-2">
                <Globe className="h-6 w-6 text-brand-coral" />
                Footer Content
              </h3>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  About Text
                </label>
                <textarea
                  value={marketingData.footer.about_text || ''}
                  onChange={(e) =>
                    updateField('footer', 'about_text', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  rows={4}
                  placeholder="Brief description about your platform"
                />
              </div>

              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">
                  Copyright Text
                </label>
                <input
                  type="text"
                  value={marketingData.footer.copyright_text || ''}
                  onChange={(e) =>
                    updateField('footer', 'copyright_text', e.target.value)
                  }
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="© 2024 Company Name. All rights reserved."
                />
              </div>

              <button
                onClick={() => handleSave('footer', marketingData.footer)}
                disabled={saving}
                className="flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50"
              >
                <Save className="h-5 w-5" />
                {saving ? 'Saving...' : 'Save Footer Content'}
              </button>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
