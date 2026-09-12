'use client';

import { useState, useEffect } from 'react';
import { Save, X, Edit2, FileText, AlertCircle } from 'lucide-react';

interface ContentPage {
  slug: string;
  title: string;
  description: string;
  content: string;
}

const defaultPages: ContentPage[] = [
  {
    slug: 'about',
    title: 'About Us',
    description: 'Information about ALOGYAN',
    content: 'ALOGYAN is a leading platform connecting students with qualified teachers...'
  },
  {
    slug: 'privacy',
    title: 'Privacy Policy',
    description: 'Privacy Policy of ALOGYAN',
    content: 'Your privacy is important to us. This Privacy Policy explains...'
  },
  {
    slug: 'terms',
    title: 'Terms & Conditions',
    description: 'Terms and Conditions of ALOGYAN',
    content: 'By using ALOGYAN, you agree to these terms...'
  },
  {
    slug: 'help',
    title: 'Help Center',
    description: 'Help and Support for ALOGYAN users',
    content: 'Welcome to our Help Center. Here you can find answers to common questions...'
  },
  {
    slug: 'faq',
    title: 'FAQ',
    description: 'Frequently Asked Questions',
    content: 'Q: How do I create a teacher profile?\nA: Click on "Become a Teacher" and fill in your details...'
  }
];

export default function ContentManagement() {
  const [pages, setPages] = useState<ContentPage[]>(defaultPages);
  const [selectedPage, setSelectedPage] = useState<ContentPage | null>(defaultPages[0]);
  const [editContent, setEditContent] = useState('');
  const [editTitle, setEditTitle] = useState('');
  const [editDescription, setEditDescription] = useState('');
  const [isSaving, setIsSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState('');
  const [showPreview, setShowPreview] = useState(false);

  useEffect(() => {
    if (selectedPage) {
      setEditContent(selectedPage.content);
      setEditTitle(selectedPage.title);
      setEditDescription(selectedPage.description);
    }
  }, [selectedPage]);

  const handleSave = async () => {
    if (!selectedPage) return;

    setIsSaving(true);
    try {
      // Simulate saving to backend
      await new Promise(resolve => setTimeout(resolve, 500));

      const updatedPages = pages.map(p =>
        p.slug === selectedPage.slug
          ? { ...p, content: editContent, title: editTitle, description: editDescription }
          : p
      );
      setPages(updatedPages);
      setSelectedPage({
        ...selectedPage,
        content: editContent,
        title: editTitle,
        description: editDescription
      });

      setSaveMessage('Changes saved successfully! ✓');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (error) {
      console.error('Error saving:', error);
      setSaveMessage('Failed to save changes');
    } finally {
      setIsSaving(false);
    }
  };

  const handleReset = () => {
    if (selectedPage) {
      setEditContent(selectedPage.content);
      setEditTitle(selectedPage.title);
      setEditDescription(selectedPage.description);
      setSaveMessage('');
    }
  };

  const isChanged =
    selectedPage &&
    (editContent !== selectedPage.content ||
      editTitle !== selectedPage.title ||
      editDescription !== selectedPage.description);

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-3xl font-bold text-gray-900">Content Management</h2>
        <p className="text-gray-600 mt-1">Edit static pages and site content</p>
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6">
        {/* Pages List */}
        <div className="bg-white rounded-2xl shadow-lg p-6 h-fit">
          <h3 className="font-bold text-gray-900 mb-4 flex items-center gap-2">
            <FileText className="h-5 w-5 text-brand-coral" />
            Pages
          </h3>
          <div className="space-y-2">
            {pages.map((page) => (
              <button
                key={page.slug}
                onClick={() => setSelectedPage(page)}
                className={`w-full text-left px-4 py-3 rounded-lg transition-all duration-200 ${
                  selectedPage?.slug === page.slug
                    ? 'bg-brand-gradient text-white shadow-lg'
                    : 'bg-gray-100 text-gray-900 hover:bg-gray-200'
                }`}
              >
                <p className="font-semibold text-sm">{page.title}</p>
                <p className={`text-xs mt-1 ${selectedPage?.slug === page.slug ? 'text-white/80' : 'text-gray-600'}`}>
                  {page.slug}
                </p>
              </button>
            ))}
          </div>
        </div>

        {/* Content Editor */}
        <div className="lg:col-span-3 bg-white rounded-2xl shadow-lg p-6">
          {selectedPage ? (
            <div className="space-y-4">
              {/* Title Input */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Page Title</label>
                <input
                  type="text"
                  value={editTitle}
                  onChange={(e) => setEditTitle(e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Page title"
                />
              </div>

              {/* Description Input */}
              <div>
                <label className="block text-sm font-semibold text-gray-700 mb-2">Meta Description</label>
                <input
                  type="text"
                  value={editDescription}
                  onChange={(e) => setEditDescription(e.target.value)}
                  className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="SEO meta description"
                  maxLength={160}
                />
                <p className="text-xs text-gray-500 mt-1">{editDescription.length}/160</p>
              </div>

              {/* Content Editor */}
              <div>
                <div className="flex items-center justify-between mb-2">
                  <label className="block text-sm font-semibold text-gray-700">Content</label>
                  <button
                    onClick={() => setShowPreview(!showPreview)}
                    className="text-xs font-bold text-brand-coral hover:text-brand-purple transition-colors"
                  >
                    {showPreview ? 'Edit' : 'Preview'}
                  </button>
                </div>

                {showPreview ? (
                  <div className="bg-gray-50 border-2 border-gray-200 rounded-xl p-6 min-h-64">
                    <div className="prose prose-sm max-w-none">
                      {editContent.split('\n').map((para, i) => (
                        <p key={i} className="text-gray-700 mb-4">
                          {para}
                        </p>
                      ))}
                    </div>
                  </div>
                ) : (
                  <textarea
                    value={editContent}
                    onChange={(e) => setEditContent(e.target.value)}
                    className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral min-h-64 font-mono text-sm"
                    placeholder="Enter your content here. Supports markdown and plain text."
                  />
                )}
              </div>

              {/* Save Message */}
              {saveMessage && (
                <div className={`p-4 rounded-xl text-sm font-medium ${
                  saveMessage.includes('success')
                    ? 'bg-green-100 text-green-700'
                    : 'bg-red-100 text-red-700'
                }`}>
                  {saveMessage}
                </div>
              )}

              {/* Info Box */}
              <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 flex gap-3">
                <AlertCircle className="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" />
                <div className="text-sm text-blue-700">
                  <p className="font-bold mb-1">Preview your changes</p>
                  <p>Click the Preview button to see how your content will look to users.</p>
                </div>
              </div>

              {/* Action Buttons */}
              <div className="flex gap-4 pt-4 border-t border-gray-200">
                <button
                  onClick={handleSave}
                  disabled={!isChanged || isSaving}
                  className="flex-1 flex items-center justify-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50 disabled:cursor-not-allowed transition-all duration-200"
                >
                  <Save className="h-5 w-5" />
                  {isSaving ? 'Saving...' : 'Save Changes'}
                </button>
                <button
                  onClick={handleReset}
                  disabled={!isChanged}
                  className="px-6 py-3 border-2 border-gray-200 text-gray-900 font-bold rounded-xl hover:bg-gray-50 disabled:opacity-50 disabled:cursor-not-allowed transition-all"
                >
                  Reset
                </button>
              </div>
            </div>
          ) : (
            <div className="text-center py-12">
              <p className="text-gray-600">Select a page to edit</p>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
