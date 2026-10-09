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

      setSaveMessage('Changes saved successfully.');
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
    <div className="w-full space-y-4">
      {/* Sub-toolbar */}
      <div className="flex items-center justify-between pb-1">
        <div className="flex items-center gap-2">
          <span className="text-xs font-bold uppercase tracking-wider text-gray-500 font-poppins">
            Content Publications
          </span>
          <span className="text-xs text-gray-400 font-medium">({pages.length} pages managed)</span>
        </div>

        {saveMessage && (
          <span className="text-xs font-semibold text-emerald-700 bg-emerald-50 px-2.5 py-1 rounded-full border border-emerald-200/60 animate-fade-in">
            {saveMessage}
          </span>
        )}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-6 items-start">
        {/* Pages Navigation List */}
        <div className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs space-y-3">
          <div className="flex items-center justify-between pb-2 border-b border-gray-100">
            <h3 className="font-bold text-xs uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
              <FileText className="h-4 w-4 text-[#C91F26]" />
              Static Documents
            </h3>
            <span className="text-[10px] font-semibold bg-gray-100 text-gray-600 px-1.5 py-0.5 rounded">
              CMS
            </span>
          </div>

          <div className="space-y-1">
            {pages.map((page) => {
              const isActive = selectedPage?.slug === page.slug;
              return (
                <button
                  key={page.slug}
                  onClick={() => setSelectedPage(page)}
                  className={`w-full text-left px-3 py-2.5 rounded-lg transition-all duration-150 relative ${
                    isActive
                      ? 'bg-red-50/70 text-[#C91F26] font-semibold border border-red-200/60 shadow-xs'
                      : 'text-gray-700 hover:bg-gray-50 hover:text-gray-900 border border-transparent'
                  }`}
                >
                  <p className="text-xs font-bold truncate">{page.title}</p>
                  <p className={`text-[10px] mt-0.5 truncate font-mono ${isActive ? 'text-red-600/80' : 'text-gray-400'}`}>
                    /{page.slug}
                  </p>
                </button>
              );
            })}
          </div>
        </div>

        {/* Content Editor */}
        <div className="lg:col-span-3 bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs">
          {selectedPage ? (
            <div className="space-y-4">
              {/* Title & Slug Header */}
              <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                <div>
                  <h3 className="text-sm font-bold text-gray-900 font-poppins">{selectedPage.title}</h3>
                  <p className="text-[11px] text-gray-400 font-mono">Route: /{selectedPage.slug}</p>
                </div>
                <div className="flex items-center gap-2">
                  <button
                    onClick={() => setShowPreview(!showPreview)}
                    className={`px-3 py-1.5 text-xs font-semibold rounded-lg border transition-colors shadow-xs ${
                      showPreview
                        ? 'bg-gray-900 text-white border-gray-900'
                        : 'bg-white text-gray-700 border-gray-200 hover:bg-gray-50'
                    }`}
                  >
                    {showPreview ? 'Back to Editor' : 'Live Preview'}
                  </button>
                </div>
              </div>

              {/* Title Input */}
              <div className="space-y-1">
                <label className="block text-xs font-semibold text-gray-700">Page Title</label>
                <input
                  type="text"
                  value={editTitle}
                  onChange={(e) => setEditTitle(e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  placeholder="Page title"
                />
              </div>

              {/* Meta Description Input */}
              <div className="space-y-1">
                <div className="flex items-center justify-between">
                  <label className="block text-xs font-semibold text-gray-700">Meta Description (SEO)</label>
                  <span className="text-[10px] text-gray-400 font-mono">{editDescription.length}/160</span>
                </div>
                <input
                  type="text"
                  value={editDescription}
                  onChange={(e) => setEditDescription(e.target.value)}
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  placeholder="Short summary for search results"
                  maxLength={160}
                />
              </div>

              {/* Content Body Editor or Preview */}
              <div className="space-y-1">
                <label className="block text-xs font-semibold text-gray-700">Markdown Content</label>
                {showPreview ? (
                  <div className="bg-gray-50 border border-gray-200 rounded-lg p-5 min-h-[260px] text-xs leading-relaxed text-gray-700">
                    <div className="space-y-3">
                      {editContent.split('\n').map((para, i) =>
                        para.trim() ? (
                          <p key={i} className="text-gray-700">
                            {para}
                          </p>
                        ) : null
                      )}
                    </div>
                  </div>
                ) : (
                  <textarea
                    value={editContent}
                    onChange={(e) => setEditContent(e.target.value)}
                    className="w-full p-3 border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] min-h-[260px] font-mono text-xs leading-relaxed text-gray-800 transition-colors"
                    placeholder="Enter page content here. Supports plain text and markdown paragraphs."
                  />
                )}
              </div>

              {/* Action Buttons */}
              <div className="flex items-center justify-end gap-2.5 pt-3 border-t border-gray-100">
                <button
                  type="button"
                  onClick={handleReset}
                  disabled={!isChanged || isSaving}
                  className="px-4 py-2 border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 rounded-lg transition-colors disabled:opacity-40"
                >
                  Discard Changes
                </button>
                <button
                  type="button"
                  onClick={handleSave}
                  disabled={!isChanged || isSaving}
                  className="inline-flex items-center gap-1.5 px-5 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-40"
                >
                  <Save className="h-3.5 w-3.5" />
                  <span>{isSaving ? 'Saving...' : 'Publish Changes'}</span>
                </button>
              </div>
            </div>
          ) : (
            <div className="text-center py-16 text-xs text-gray-500">
              Select a page from the left to edit its content.
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
