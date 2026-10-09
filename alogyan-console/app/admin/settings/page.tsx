'use client';

import { useEffect, useRef, useState } from 'react';
import Image from 'next/image';
import {
  Settings as SettingsIcon,
  Lock,
  Mail,
  Save,
  AlertCircle,
  Eye,
  EyeOff,
  Key,
  RefreshCw,
  Camera,
  ImageUp,
  UserCircle2,
  Copy,
  Check,
  CheckCircle2,
  ShieldAlert
} from 'lucide-react';
import ConfirmModal from '@/components/admin/ConfirmModal';

export default function AdminSettings() {
  const [activeTab, setActiveTab] = useState('general');
  const [isSaving, setIsSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [copiedKey, setCopiedKey] = useState(false);

  // Modal confirmation for API Key regeneration
  const [showRegenModal, setShowRegenModal] = useState(false);

  const AVATAR_KEY = 'adminAvatar';
  const DEFAULT_AVATAR = '/logo-official.png';
  const [adminAvatar, setAdminAvatar] = useState(DEFAULT_AVATAR);
  const fileInputRef = useRef<HTMLInputElement | null>(null);

  useEffect(() => {
    if (typeof window === 'undefined') return;
    const saved = window.localStorage.getItem(AVATAR_KEY);
    setAdminAvatar(saved || DEFAULT_AVATAR);
  }, []);

  const persistAvatar = (dataUrl: string) => {
    setAdminAvatar(dataUrl || DEFAULT_AVATAR);
    if (typeof window !== 'undefined') {
      window.localStorage.setItem(AVATAR_KEY, dataUrl || DEFAULT_AVATAR);
      window.dispatchEvent(new Event('admin-avatar-updated'));
    }
  };

  const handleAvatarChange = (file?: File) => {
    if (!file) return;
    const reader = new FileReader();
    reader.onload = () => {
      const result = reader.result?.toString();
      if (result) {
        persistAvatar(result);
      }
    };
    reader.readAsDataURL(file);
  };

  const handleAvatarReset = () => {
    persistAvatar(DEFAULT_AVATAR);
    if (fileInputRef.current) fileInputRef.current.value = '';
  };

  // General Settings
  const [siteName, setSiteName] = useState('ALOGYAN');
  const [siteDescription, setSiteDescription] = useState('Connect with qualified teachers and coaching institutes');
  const [contactEmail, setContactEmail] = useState('alogyan.main@gmail.com');

  // Admin Security Settings
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  // API Settings
  const [apiKey, setApiKey] = useState('sk-live_alogyan_a87f2e9d4c1b5a67e890');
  const [showApiKey, setShowApiKey] = useState(false);

  const handleSaveGeneral = async () => {
    setIsSaving(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 500));
      setSaveMessage('General settings updated successfully.');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch {
      setSaveMessage('Failed to save settings');
    } finally {
      setIsSaving(false);
    }
  };

  const handleChangePassword = async () => {
    if (newPassword !== confirmPassword) {
      setSaveMessage('Error: Passwords do not match.');
      return;
    }

    if (newPassword.length < 8) {
      setSaveMessage('Error: Password must contain at least 8 characters.');
      return;
    }

    setIsSaving(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 500));
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      setSaveMessage('Password updated successfully.');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch {
      setSaveMessage('Failed to change password');
    } finally {
      setIsSaving(false);
    }
  };

  const handleRegenerateApiKey = async () => {
    setShowRegenModal(false);
    setIsSaving(true);
    try {
      await new Promise((resolve) => setTimeout(resolve, 500));
      setApiKey('sk-live_' + Math.random().toString(36).substring(2, 12) + Math.random().toString(36).substring(2, 12));
      setSaveMessage('API key regenerated successfully.');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch {
      setSaveMessage('Failed to regenerate API key');
    } finally {
      setIsSaving(false);
    }
  };

  const copyToClipboard = () => {
    if (typeof navigator !== 'undefined') {
      void navigator.clipboard.writeText(apiKey);
      setCopiedKey(true);
      setTimeout(() => setCopiedKey(false), 2000);
    }
  };

  const tabs = [
    { id: 'general', label: 'Platform Profile', icon: SettingsIcon },
    { id: 'admin', label: 'Admin Identity & Security', icon: Lock },
    { id: 'api', label: 'API & Developer Access', icon: Key },
  ];

  return (
    <div className="w-full space-y-4">
      {/* Toast Alert */}
      {saveMessage && (
        <div
          className={`p-3 rounded-xl flex items-center gap-2.5 text-xs font-semibold animate-fade-in ${
            saveMessage.includes('success') || saveMessage.includes('updated')
              ? 'bg-emerald-50 border border-emerald-200/60 text-emerald-800'
              : 'bg-red-50 border border-red-200/60 text-red-800'
          }`}
        >
          {saveMessage.includes('success') || saveMessage.includes('updated') ? (
            <CheckCircle2 className="h-4 w-4 text-emerald-600 flex-shrink-0" />
          ) : (
            <AlertCircle className="h-4 w-4 text-red-600 flex-shrink-0" />
          )}
          <p>{saveMessage}</p>
        </div>
      )}

      {/* Main Settings Card */}
      <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs space-y-5">
        {/* Navigation Tabs */}
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

        {/* Tab 1: General Settings */}
        {activeTab === 'general' && (
          <div className="space-y-4 max-w-2xl animate-fade-in">
            <div className="flex items-center justify-between pb-2 border-b border-gray-100">
              <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                <SettingsIcon className="h-4 w-4 text-[#C91F26]" />
                Platform Identity
              </h3>
              <span className="text-[11px] text-gray-400">Global site naming & support contacts</span>
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Platform Brand Name</label>
              <input
                type="text"
                value={siteName}
                onChange={(e) => setSiteName(e.target.value)}
                className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                placeholder="Platform name"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Platform Description</label>
              <textarea
                value={siteDescription}
                onChange={(e) => setSiteDescription(e.target.value)}
                className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors leading-relaxed"
                rows={3}
                placeholder="Brief summary of platform"
              />
            </div>

            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Administrative Contact Email</label>
              <div className="relative">
                <Mail className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400 pointer-events-none" />
                <input
                  type="email"
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                  className="w-full pl-9 pr-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                  placeholder="admin@example.com"
                />
              </div>
            </div>

            <div className="pt-2 flex justify-end">
              <button
                onClick={handleSaveGeneral}
                disabled={isSaving}
                className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
              >
                <Save className="h-3.5 w-3.5" />
                <span>{isSaving ? 'Saving...' : 'Save Configuration'}</span>
              </button>
            </div>
          </div>
        )}

        {/* Tab 2: Admin Security & Identity */}
        {activeTab === 'admin' && (
          <div className="space-y-5 max-w-2xl animate-fade-in">
            <div className="flex items-center justify-between pb-2 border-b border-gray-100">
              <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                <Lock className="h-4 w-4 text-[#C91F26]" />
                Account Profile & Security
              </h3>
              <span className="text-[11px] text-gray-400">Avatar and credential management</span>
            </div>

            {/* Profile Avatar Card */}
            <div className="flex flex-col sm:flex-row items-start sm:items-center gap-4 p-4 border border-gray-200/70 rounded-xl bg-gray-50/70">
              <div className="w-16 h-16 rounded-xl overflow-hidden border border-gray-200 bg-white flex items-center justify-center flex-shrink-0 shadow-2xs">
                {adminAvatar ? (
                  <Image src={adminAvatar} alt="Admin avatar" width={64} height={64} className="object-cover w-full h-full" />
                ) : (
                  <UserCircle2 className="h-10 w-10 text-gray-400" />
                )}
              </div>
              <div className="flex-1 space-y-2 min-w-0">
                <div>
                  <h4 className="text-xs font-bold text-gray-900 font-poppins">Profile Image</h4>
                  <p className="text-[11px] text-gray-500">Official avatar rendered in console top-bar and audit logs.</p>
                </div>
                <div className="flex flex-wrap gap-2">
                  <label className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 hover:border-gray-300 hover:bg-gray-50 cursor-pointer transition-colors shadow-2xs">
                    <ImageUp className="h-3.5 w-3.5 text-[#C91F26]" />
                    <span>Upload Image</span>
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => handleAvatarChange(e.target.files?.[0])}
                    />
                  </label>
                  <label className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 hover:border-gray-300 hover:bg-gray-50 cursor-pointer transition-colors shadow-2xs">
                    <Camera className="h-3.5 w-3.5 text-[#C91F26]" />
                    <span>Camera</span>
                    <input
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => handleAvatarChange(e.target.files?.[0])}
                    />
                  </label>
                  <button
                    type="button"
                    onClick={handleAvatarReset}
                    className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-xs font-semibold text-gray-600 hover:border-gray-300 hover:bg-gray-50 transition-colors shadow-2xs"
                  >
                    Reset to Default
                  </button>
                </div>
              </div>
            </div>

            {/* Password Change Fields */}
            <div className="space-y-3 pt-2">
              <h4 className="text-xs font-bold text-gray-900 font-poppins">Update Password</h4>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Current Password</label>
                <div className="relative">
                  <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400 pointer-events-none" />
                  <input
                    type={showPassword ? 'text' : 'password'}
                    value={currentPassword}
                    onChange={(e) => setCurrentPassword(e.target.value)}
                    className="w-full pl-9 pr-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                    placeholder="Enter current password"
                  />
                </div>
              </div>

              <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">New Password</label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400 pointer-events-none" />
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={newPassword}
                      onChange={(e) => setNewPassword(e.target.value)}
                      className="w-full pl-9 pr-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                      placeholder="At least 8 characters"
                    />
                  </div>
                </div>

                <div>
                  <label className="block text-xs font-semibold text-gray-700 mb-1">Confirm New Password</label>
                  <div className="relative">
                    <Lock className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400 pointer-events-none" />
                    <input
                      type={showPassword ? 'text' : 'password'}
                      value={confirmPassword}
                      onChange={(e) => setConfirmPassword(e.target.value)}
                      className="w-full pl-9 pr-9 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
                      placeholder="Re-enter new password"
                    />
                    <button
                      type="button"
                      onClick={() => setShowPassword(!showPassword)}
                      className="absolute right-2.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 p-0.5 rounded"
                      title="Toggle password visibility"
                    >
                      {showPassword ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                    </button>
                  </div>
                </div>
              </div>

              <div className="pt-2 flex justify-end">
                <button
                  onClick={handleChangePassword}
                  disabled={isSaving || !currentPassword || !newPassword || !confirmPassword}
                  className="inline-flex items-center gap-1.5 px-5 py-2.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                >
                  <Lock className="h-3.5 w-3.5" />
                  <span>{isSaving ? 'Updating...' : 'Change Password'}</span>
                </button>
              </div>
            </div>
          </div>
        )}

        {/* Tab 3: API Settings */}
        {activeTab === 'api' && (
          <div className="space-y-5 max-w-2xl animate-fade-in">
            <div className="flex items-center justify-between pb-2 border-b border-gray-100">
              <h3 className="text-xs font-bold uppercase tracking-wider text-gray-700 flex items-center gap-2 font-poppins">
                <Key className="h-4 w-4 text-[#C91F26]" />
                API & Integration Credentials
              </h3>
              <span className="text-[11px] text-gray-400">Server keys & webhook destinations</span>
            </div>

            {/* Warning Pill */}
            <div className="bg-amber-50 border border-amber-200/80 rounded-xl p-3 flex items-start gap-2.5 text-xs text-amber-800">
              <AlertCircle className="h-4 w-4 text-amber-600 flex-shrink-0 mt-0.5" />
              <div>
                <p className="font-bold">Confidential API Access Key</p>
                <p className="text-[11px] text-amber-700 mt-0.5">
                  Keep your API key strictly confidential. Never expose it in client-side code or public repositories.
                </p>
              </div>
            </div>

            {/* API Key Box */}
            <div>
              <label className="block text-xs font-semibold text-gray-700 mb-1">Active Server Key</label>
              <div className="relative">
                <Key className="absolute left-3 top-1/2 -translate-y-1/2 h-3.5 w-3.5 text-gray-400 pointer-events-none" />
                <input
                  type={showApiKey ? 'text' : 'password'}
                  value={apiKey}
                  readOnly
                  className="w-full pl-9 pr-20 py-2 border border-gray-200 rounded-lg bg-gray-50 font-mono text-xs text-gray-800"
                  placeholder="API Key"
                />
                <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1">
                  <button
                    type="button"
                    onClick={() => setShowApiKey(!showApiKey)}
                    className="p-1 text-gray-400 hover:text-gray-700 transition-colors"
                    title={showApiKey ? 'Hide key' : 'Show key'}
                  >
                    {showApiKey ? <EyeOff className="h-3.5 w-3.5" /> : <Eye className="h-3.5 w-3.5" />}
                  </button>
                  <button
                    type="button"
                    onClick={copyToClipboard}
                    className="p-1 text-gray-400 hover:text-gray-700 transition-colors"
                    title="Copy API key"
                  >
                    {copiedKey ? <Check className="h-3.5 w-3.5 text-emerald-600" /> : <Copy className="h-3.5 w-3.5" />}
                  </button>
                </div>
              </div>
            </div>

            {/* Integration Endpoints */}
            <div className="space-y-2">
              <h4 className="text-xs font-bold text-gray-900 font-poppins">Integration Endpoints</h4>
              <div className="grid gap-2 bg-gray-50/70 border border-gray-200/60 rounded-xl p-3.5">
                {[
                  { method: 'POST', path: '/api/admin/auth', label: 'Auth Token Exchange' },
                  { method: 'GET / PATCH', path: '/api/admin/teachers', label: 'Teacher Directory Service' },
                  { method: 'GET / PATCH', path: '/api/admin/plans', label: 'Billing & Plan Registry' },
                  { method: 'GET', path: '/api/admin/analytics', label: 'Aggregated Analytics Feed' },
                ].map((ep) => (
                  <div key={ep.path} className="flex items-center justify-between text-xs py-1 border-b border-gray-100 last:border-b-0">
                    <div className="flex items-center gap-2">
                      <span className="font-mono text-[10px] font-bold px-1.5 py-0.5 rounded bg-gray-200/70 text-gray-700">
                        {ep.method}
                      </span>
                      <code className="text-gray-900 font-mono text-xs">{ep.path}</code>
                    </div>
                    <span className="text-[11px] text-gray-400 hidden sm:inline">{ep.label}</span>
                  </div>
                ))}
              </div>
            </div>

            <div className="pt-2 flex items-center justify-between border-t border-gray-100">
              <p className="text-[11px] text-gray-500">
                Regenerating will immediately invalidate existing connections.
              </p>
              <button
                type="button"
                onClick={() => setShowRegenModal(true)}
                disabled={isSaving}
                className="inline-flex items-center gap-1.5 px-4 py-2 border border-amber-300 bg-amber-50 hover:bg-amber-100 text-amber-900 text-xs font-semibold rounded-lg transition-colors"
              >
                <RefreshCw className="h-3.5 w-3.5" />
                <span>Regenerate Key</span>
              </button>
            </div>
          </div>
        )}
      </div>

      {/* Confirmation Modal for Key Regeneration */}
      <ConfirmModal
        isOpen={showRegenModal}
        onClose={() => setShowRegenModal(false)}
        onConfirm={() => void handleRegenerateApiKey()}
        title="Regenerate API Access Key"
        message="Regenerating your API key will immediately invalidate the active key. All backend integrations and workers using this key will fail until updated with the new credential."
        confirmLabel="Regenerate Now"
        danger={true}
        loading={isSaving}
      />
    </div>
  );
}
