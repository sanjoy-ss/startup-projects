'use client';

import { useEffect, useState } from 'react';
import {
  Save,
  AlertCircle,
  CheckCircle,
  Megaphone,
  Search,
  Globe,
  Share2,
  Phone,
  Target,
  BarChart2,
} from 'lucide-react';

interface MarketingData {
  seo: Record<string, { title?: string; meta_description?: string; keywords?: string[]; og_image?: string }>;
  hero: {
    main_heading?: string;
    sub_heading?: string;
    cta_primary_text?: string;
    cta_secondary_text?: string;
    background_image?: string;
    video_url?: string;
  };
  social: Record<string, string>;
  contact: {
    email?: string;
    phone?: string;
    address?: string;
    support_hours?: string;
  };
  analytics: {
    google_analytics_id?: string;
    facebook_pixel_id?: string;
    google_tag_manager_id?: string;
    hotjar_id?: string;
  };
  footer: {
    about_text?: string;
    copyright_text?: string;
  };
}

export default function DigitalMarketingPage() {
  const [loading, setLoading] = useState(true);
  const [saving, setSaving] = useState(false);
  const [message, setMessage] = useState({ type: '', text: '' });
  const [activeTab, setActiveTab] = useState('seo');
  const [marketingData, setMarketingData] = useState<MarketingData | null>(null);

  useEffect(() => {
    void fetchMarketingData();
  }, []);

  const fetchMarketingData = async () => {
    try {
      const response = await fetch('/api/admin/marketing', {
        credentials: 'include',
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

  const handleSave = async (section: string, data: unknown) => {
    setSaving(true);
    setMessage({ type: '', text: '' });

    try {
      const response = await fetch('/api/admin/marketing', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ section, data }),
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to save');

      setMessage({ type: 'success', text: 'Changes published successfully.' });
      await fetchMarketingData();

      // Emit event to trigger real-time sync on public website
      if (typeof window !== 'undefined') {
        window.dispatchEvent(new Event('marketing-settings-updated'));
      }

      setTimeout(() => setMessage({ type: '', text: '' }), 3000);
    } catch {
      setMessage({ type: 'error', text: 'Failed to save changes' });
    } finally {
      setSaving(false);
    }
  };

  const updateField = (section: keyof MarketingData, path: string, value: unknown) => {
    if (!marketingData) return;

    const keys = path.split('.');
    const updatedData = { ...marketingData };
    // eslint-disable-next-line @typescript-eslint/no-explicit-any
    let current: any = updatedData[section];

    for (let i = 0; i < keys.length - 1; i++) {
      current = current[keys[i]];
    }
    current[keys[keys.length - 1]] = value;

    setMarketingData(updatedData);
  };

  const tabs = [
    { id: 'seo', label: 'SEO & Meta Tags', icon: Search },
    { id: 'hero', label: 'Hero Banner', icon: Target },
    { id: 'social', label: 'Social Channels', icon: Share2 },
    { id: 'contact', label: 'Contact Coordinates', icon: Phone },
    { id: 'analytics', label: 'Analytics & Tracking', icon: BarChart2 },
    { id: 'footer', label: 'Footer & Copyright', icon: Globe },
  ];

  if (loading) {
    return (
      <div className="flex items-center justify-center py-16">
        <div className="text-center space-y-3">
          <div className="w-10 h-10 border-3 border-gray-200 border-t-[#C91F26] rounded-full animate-spin mx-auto"></div>
          <p className="text-xs font-semibold text-gray-500">Loading growth configurations...</p>
        </div>
      </div>
    );
  }

  if (!marketingData) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-center">
        <p className="text-xs font-semibold text-red-700">Failed to load marketing settings.</p>
      </div>
    );
  }

  return (
    <div className="w-full space-y-4">
      {/* Toast Alert */}
      {message.text && (
        <div
          className={`p-3 rounded-xl flex items-center gap-2.5 text-xs font-semibold animate-fade-in ${
            message.type === 'success'
              ? 'bg-emerald-50 border border-emerald-200/60 text-emerald-800'
              : 'bg-red-50 border border-red-200/60 text-red-800'
          }`}
        >
          {message.type === 'success' ? (
            <CheckCircle className="h-4 w-4 text-emerald-600 flex-shrink-0" />
          ) : (
            <AlertCircle className="h-4 w-4 text-red-600 flex-shrink-0" />
          )}
          <p>{message.text}</p>
        </div>
      )}

      {/* Modern Tab Bar Card */}
      <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs space-y-5">
        <div className="flex gap-1.5 overflow-x-auto pb-3 border-b border-gray-100 scrollbar-none">
          {tabs.map((tab) => {
            const Icon = tab.icon;
            const isActive = activeTab === tab.id;
            return (
              <button
                key={tab.id}
                onClick={() => setActiveTab(tab.id)}
                className={`flex items-center gap-2 px-3 py-1.5 rounded-lg text-xs font-semibold whitespace-nowrap transition-all duration-150 ${
                  isActive
                    ? 'bg-red-50/70 text-[#C91F26] border border-red-200/60 shadow-xs'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-50 border border-transparent'
                }`}
              >
                <Icon className={`h-3.5 w-3.5 ${isActive ? 'text-[#C91F26]' : 'text-gray-400'}`} />
                {tab.label}
              </button>
            );
          })}
        </div>

        {/* Tab Content Panes */}
        <div>
          {/* 1. SEO Settings */}
          {activeTab === 'seo' && marketingData.seo && (
            <div className="space-y-5">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                  <Search className="h-4 w-4 text-[#C91F26]" />
                  Search Engine Optimization
                </h3>
                <span className="text-[11px] text-gray-400">Public metadata & social graph tags</span>
              </div>

              <div className="grid gap-4 sm:grid-cols-2">
                {Object.keys(marketingData.seo).map((page) => (
                  <div key={page} className="bg-gray-50/70 border border-gray-200/60 rounded-xl p-4 space-y-3">
                    <div className="flex items-center justify-between">
                      <h4 className="font-bold text-xs text-gray-900 capitalize font-poppins">{page} Page</h4>
                      <span className="text-[10px] font-mono text-gray-400 bg-white px-2 py-0.5 rounded border border-gray-200/60">
                        /{page === 'homepage' ? '' : page}
                      </span>
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-gray-700 mb-1">Page Title</label>
                      <input
                        type="text"
                        value={marketingData.seo[page]?.title || ''}
                        onChange={(e) => updateField('seo', `${page}.title`, e.target.value)}
                        className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                        placeholder="Page title"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-gray-700 mb-1">Meta Description</label>
                      <textarea
                        value={marketingData.seo[page]?.meta_description || ''}
                        onChange={(e) => updateField('seo', `${page}.meta_description`, e.target.value)}
                        className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors leading-relaxed"
                        rows={2}
                        placeholder="Meta description (150-160 chars)"
                      />
                    </div>

                    <div>
                      <label className="block text-xs font-semibold text-gray-700 mb-1">Keywords</label>
                      <input
                        type="text"
                        value={(marketingData.seo[page]?.keywords || []).join(', ')}
                        onChange={(e) =>
                          updateField(
                            'seo',
                            `${page}.keywords`,
                            e.target.value.split(',').map((k) => k.trim())
                          )
                        }
                        className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                        placeholder="keyword1, keyword2"
                      />
                    </div>

                    {page === 'homepage' && (
                      <div>
                        <label className="block text-xs font-semibold text-gray-700 mb-1">OpenGraph Image URL</label>
                        <input
                          type="text"
                          value={marketingData.seo[page]?.og_image || ''}
                          onChange={(e) => updateField('seo', `${page}.og_image`, e.target.value)}
                          className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                          placeholder="https://example.com/og-banner.jpg"
                        />
                      </div>
                    )}
                  </div>
                ))}
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => handleSave('seo', marketingData.seo)}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{saving ? 'Saving...' : 'Save SEO Configurations'}</span>
                </button>
              </div>
            </div>
          )}

          {/* 2. Hero Section */}
          {activeTab === 'hero' && marketingData.hero && (
            <div className="space-y-4 max-w-2xl">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                  <Target className="h-4 w-4 text-[#C91F26]" />
                  Landing Page Hero Banner
                </h3>
                <span className="text-[11px] text-gray-400">Hero CTA and heading content</span>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Main Heading</label>
                <input
                  type="text"
                  value={marketingData.hero.main_heading || ''}
                  onChange={(e) => updateField('hero', 'main_heading', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Sub Heading</label>
                <textarea
                  value={marketingData.hero.sub_heading || ''}
                  onChange={(e) => updateField('hero', 'sub_heading', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors leading-relaxed"
                  rows={2}
                />
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Primary CTA Label</label>
                  <input
                    type="text"
                    value={marketingData.hero.cta_primary_text || ''}
                    onChange={(e) => updateField('hero', 'cta_primary_text', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  />
                </div>
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Secondary CTA Label</label>
                  <input
                    type="text"
                    value={marketingData.hero.cta_secondary_text || ''}
                    onChange={(e) => updateField('hero', 'cta_secondary_text', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  />
                </div>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Background Image URL</label>
                <input
                  type="text"
                  value={marketingData.hero.background_image || ''}
                  onChange={(e) => updateField('hero', 'background_image', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  placeholder="https://example.com/banner.jpg"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Intro Video URL (Optional)</label>
                <input
                  type="text"
                  value={marketingData.hero.video_url || ''}
                  onChange={(e) => updateField('hero', 'video_url', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  placeholder="https://youtube.com/watch?v=..."
                />
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => handleSave('hero', marketingData.hero)}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{saving ? 'Saving...' : 'Save Hero Settings'}</span>
                </button>
              </div>
            </div>
          )}

          {/* 3. Social Media */}
          {activeTab === 'social' && marketingData.social && (
            <div className="space-y-4 max-w-2xl">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                  <Share2 className="h-4 w-4 text-[#C91F26]" />
                  Social Media Links
                </h3>
                <span className="text-[11px] text-gray-400">External community channels</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                {Object.keys(marketingData.social).map((platform) => (
                  <div key={platform}>
                    <label className="block text-xs font-semibold text-gray-700 mb-1 capitalize">
                      {platform} URL
                    </label>
                    <input
                      type="text"
                      value={marketingData.social[platform] || ''}
                      onChange={(e) => updateField('social', platform, e.target.value)}
                      className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                      placeholder={`https://${platform}.com/...`}
                    />
                  </div>
                ))}
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => handleSave('social', marketingData.social)}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{saving ? 'Saving...' : 'Save Social Links'}</span>
                </button>
              </div>
            </div>
          )}

          {/* 4. Contact Info */}
          {activeTab === 'contact' && marketingData.contact && (
            <div className="space-y-4 max-w-2xl">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                  <Phone className="h-4 w-4 text-[#C91F26]" />
                  Public Contact Coordinates
                </h3>
                <span className="text-[11px] text-gray-400">Website footer and contact page</span>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Contact Email</label>
                <input
                  type="email"
                  value={marketingData.contact.email || ''}
                  onChange={(e) => updateField('contact', 'email', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Phone Number</label>
                <input
                  type="text"
                  value={marketingData.contact.phone || ''}
                  onChange={(e) => updateField('contact', 'phone', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  placeholder="+91 ..."
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Physical Address / Headquarters</label>
                <textarea
                  value={marketingData.contact.address || ''}
                  onChange={(e) => updateField('contact', 'address', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors leading-relaxed"
                  rows={2}
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Support Hours</label>
                <input
                  type="text"
                  value={marketingData.contact.support_hours || ''}
                  onChange={(e) => updateField('contact', 'support_hours', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                />
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => handleSave('contact', marketingData.contact)}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{saving ? 'Saving...' : 'Save Contact Info'}</span>
                </button>
              </div>
            </div>
          )}

          {/* 5. Analytics & Pixels */}
          {activeTab === 'analytics' && marketingData.analytics && (
            <div className="space-y-4 max-w-2xl">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                  <BarChart2 className="h-4 w-4 text-[#C91F26]" />
                  Analytics & Ad Pixels
                </h3>
                <span className="text-[11px] text-gray-400">Measurement and event tracking</span>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Google Analytics ID</label>
                  <input
                    type="text"
                    value={marketingData.analytics.google_analytics_id || ''}
                    onChange={(e) => updateField('analytics', 'google_analytics_id', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors font-mono"
                    placeholder="G-XXXXXXXXXX"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Facebook Pixel ID</label>
                  <input
                    type="text"
                    value={marketingData.analytics.facebook_pixel_id || ''}
                    onChange={(e) => updateField('analytics', 'facebook_pixel_id', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors font-mono"
                    placeholder="1234567890"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Google Tag Manager ID</label>
                  <input
                    type="text"
                    value={marketingData.analytics.google_tag_manager_id || ''}
                    onChange={(e) => updateField('analytics', 'google_tag_manager_id', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors font-mono"
                    placeholder="GTM-XXXXXXX"
                  />
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Hotjar ID</label>
                  <input
                    type="text"
                    value={marketingData.analytics.hotjar_id || ''}
                    onChange={(e) => updateField('analytics', 'hotjar_id', e.target.value)}
                    className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors font-mono"
                    placeholder="1234567"
                  />
                </div>
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => handleSave('analytics', marketingData.analytics)}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{saving ? 'Saving...' : 'Save Tracking Configurations'}</span>
                </button>
              </div>
            </div>
          )}

          {/* 6. Footer Content */}
          {activeTab === 'footer' && marketingData.footer && (
            <div className="space-y-4 max-w-2xl">
              <div className="flex items-center justify-between pb-2 border-b border-gray-100">
                <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                  <Globe className="h-4 w-4 text-[#C91F26]" />
                  Footer & Legal Copy
                </h3>
                <span className="text-[11px] text-gray-400">Website footer boilerplate</span>
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">About Text</label>
                <textarea
                  value={marketingData.footer.about_text || ''}
                  onChange={(e) => updateField('footer', 'about_text', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors leading-relaxed"
                  rows={3}
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Copyright Notice</label>
                <input
                  type="text"
                  value={marketingData.footer.copyright_text || ''}
                  onChange={(e) => updateField('footer', 'copyright_text', e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                />
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={() => handleSave('footer', marketingData.footer)}
                  disabled={saving}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{saving ? 'Saving...' : 'Save Footer Content'}</span>
                </button>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
