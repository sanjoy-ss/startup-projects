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
  UserCircle2
} from 'lucide-react';

export default function AdminSettings() {
  const [activeTab, setActiveTab] = useState('general');
  const [isSaving, setIsSaving] = useState(false);
  const [saveMessage, setSaveMessage] = useState('');
  const [showPassword, setShowPassword] = useState(false);

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
  const [siteDescription, setSiteDescription] = useState('Connect with qualified teachers');
  const [contactEmail, setContactEmail] = useState('alogyan.main@gmail.com');

  // Admin Settings
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');

  // API Settings
  const [apiKey, setApiKey] = useState('****-****-****-****');
  const [showApiKey, setShowApiKey] = useState(false);

  const handleSaveGeneral = async () => {
    setIsSaving(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      setSaveMessage('General settings saved! ✓');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (error) {
      setSaveMessage('Failed to save settings');
    } finally {
      setIsSaving(false);
    }
  };

  const handleChangePassword = async () => {
    if (newPassword !== confirmPassword) {
      setSaveMessage('Passwords do not match!');
      return;
    }

    if (newPassword.length < 8) {
      setSaveMessage('Password must be at least 8 characters');
      return;
    }

    setIsSaving(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      setCurrentPassword('');
      setNewPassword('');
      setConfirmPassword('');
      setSaveMessage('Password changed successfully! ✓');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (error) {
      setSaveMessage('Failed to change password');
    } finally {
      setIsSaving(false);
    }
  };

  const handleRegenerateApiKey = async () => {
    if (!window.confirm('Regenerate API key? This will invalidate the current key.')) return;

    setIsSaving(true);
    try {
      await new Promise(resolve => setTimeout(resolve, 500));
      setApiKey('sk-' + Math.random().toString(36).substr(2, 32));
      setSaveMessage('API key regenerated successfully! ✓');
      setTimeout(() => setSaveMessage(''), 3000);
    } catch (error) {
      setSaveMessage('Failed to regenerate API key');
    } finally {
      setIsSaving(false);
    }
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-3xl font-bold text-gray-900">Admin Settings</h2>
        <p className="text-gray-600 mt-1">Manage your ALOGYAN platform configuration</p>
      </div>

      {/* Tabs */}
      <div className="flex gap-4 border-b border-gray-200 overflow-x-auto">
        {[
          { id: 'general', label: 'General Settings', icon: SettingsIcon },
          { id: 'admin', label: 'Admin Account', icon: Lock },
          { id: 'api', label: 'API Settings', icon: Key }
        ].map((tab) => {
          const Icon = tab.icon;
          return (
            <button
              key={tab.id}
              onClick={() => setActiveTab(tab.id)}
              className={`flex items-center gap-2 px-6 py-4 font-semibold transition-all duration-200 border-b-2 whitespace-nowrap ${
                activeTab === tab.id
                  ? 'border-brand-coral text-brand-coral'
                  : 'border-transparent text-gray-600 hover:text-gray-900'
              }`}
            >
              <Icon className="h-5 w-5" />
              {tab.label}
            </button>
          );
        })}
      </div>

      {/* Content */}
      <div className="space-y-6">
        {/* General Settings */}
        {activeTab === 'general' && (
          <div className="bg-white rounded-2xl shadow-lg p-8 space-y-6">
            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Site Name</label>
              <input
                type="text"
                value={siteName}
                onChange={(e) => setSiteName(e.target.value)}
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                placeholder="Your site name"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Site Description</label>
              <textarea
                value={siteDescription}
                onChange={(e) => setSiteDescription(e.target.value)}
                className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                rows={4}
                placeholder="Brief description of your platform"
              />
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Contact Email</label>
              <div className="relative">
                <Mail className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type="email"
                  value={contactEmail}
                  onChange={(e) => setContactEmail(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="alogyan.main@gmail.com"
                />
              </div>
            </div>

            {saveMessage && (
              <div className={`p-4 rounded-xl text-sm font-medium ${
                saveMessage.includes('success') || saveMessage.includes('saved')
                  ? 'bg-green-100 text-green-700'
                  : 'bg-red-100 text-red-700'
              }`}>
                {saveMessage}
              </div>
            )}

            <button
              onClick={handleSaveGeneral}
              disabled={isSaving}
              className="flex items-center gap-2 px-8 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50 transition-all"
            >
              <Save className="h-5 w-5" />
              {isSaving ? 'Saving...' : 'Save Settings'}
            </button>
          </div>
        )}

        {/* Admin Account */}
        {activeTab === 'admin' && (
          <div className="bg-white rounded-2xl shadow-lg p-8 space-y-6">
            <div className="bg-blue-50 border border-blue-200 rounded-xl p-4 flex gap-3">
              <AlertCircle className="h-5 w-5 text-blue-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-blue-700">
                <p className="font-bold mb-1">Change your admin password</p>
                <p>Choose a strong password with at least 8 characters including letters, numbers, and symbols.</p>
              </div>
            </div>

            <div className="flex flex-col md:flex-row md:items-center gap-6 p-4 border border-gray-100 rounded-xl bg-gray-50">
              <div className="w-24 h-24 rounded-full overflow-hidden border border-gray-200 bg-white flex items-center justify-center">
                {adminAvatar ? (
                  <Image src={adminAvatar} alt="Admin avatar" width={96} height={96} className="object-cover w-full h-full" />
                ) : (
                  <UserCircle2 className="h-16 w-16 text-gray-400" />
                )}
              </div>
              <div className="flex-1 space-y-2">
                <p className="text-sm font-semibold text-gray-900">Profile photo</p>
                <p className="text-sm text-gray-600">Default is the ALOGYAN logo. Upload a new picture from your device or camera anytime.</p>
                <div className="flex flex-wrap gap-3">
                  <label className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-lg font-semibold text-gray-700 hover:border-brand-coral cursor-pointer">
                    <ImageUp className="h-5 w-5 text-brand-coral" />
                    <span>Upload from device</span>
                    <input
                      ref={fileInputRef}
                      type="file"
                      accept="image/*"
                      className="hidden"
                      onChange={(e) => handleAvatarChange(e.target.files?.[0])}
                    />
                  </label>
                  <label className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 rounded-lg font-semibold text-gray-700 hover:border-brand-coral cursor-pointer">
                    <Camera className="h-5 w-5 text-brand-coral" />
                    <span>Use camera</span>
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
                    className="inline-flex items-center gap-2 px-4 py-2 border border-gray-200 rounded-lg font-semibold text-gray-700 hover:border-brand-coral"
                  >
                    <UserCircle2 className="h-5 w-5 text-brand-coral" />
                    Use default logo
                  </button>
                </div>
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Current Password</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={currentPassword}
                  onChange={(e) => setCurrentPassword(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Enter current password"
                />
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">New Password</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={newPassword}
                  onChange={(e) => setNewPassword(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Enter new password"
                />
              </div>
              <p className="text-xs text-gray-500 mt-2">Minimum 8 characters</p>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">Confirm Password</label>
              <div className="relative">
                <Lock className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type={showPassword ? 'text' : 'password'}
                  value={confirmPassword}
                  onChange={(e) => setConfirmPassword(e.target.value)}
                  className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
                  placeholder="Confirm new password"
                />
                <button
                  type="button"
                  onClick={() => setShowPassword(!showPassword)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                >
                  {showPassword ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
            </div>

            {saveMessage && (
              <div className={`p-4 rounded-xl text-sm font-medium ${
                saveMessage.includes('success') || saveMessage.includes('changed')
                  ? 'bg-green-100 text-green-700'
                  : 'bg-red-100 text-red-700'
              }`}>
                {saveMessage}
              </div>
            )}

            <button
              onClick={handleChangePassword}
              disabled={isSaving || !currentPassword || !newPassword || !confirmPassword}
              className="flex items-center gap-2 px-8 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg disabled:opacity-50 transition-all"
            >
              <Lock className="h-5 w-5" />
              {isSaving ? 'Updating...' : 'Change Password'}
            </button>
          </div>
        )}

        {/* API Settings */}
        {activeTab === 'api' && (
          <div className="bg-white rounded-2xl shadow-lg p-8 space-y-6">
            <div className="bg-yellow-50 border border-yellow-200 rounded-xl p-4 flex gap-3">
              <AlertCircle className="h-5 w-5 text-yellow-600 flex-shrink-0 mt-0.5" />
              <div className="text-sm text-yellow-700">
                <p className="font-bold mb-1">API Key Management</p>
                <p>Keep your API key secret. Never share it publicly or commit it to version control.</p>
              </div>
            </div>

            <div>
              <label className="block text-sm font-semibold text-gray-700 mb-2">API Key</label>
              <div className="relative">
                <Key className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
                <input
                  type={showApiKey ? 'text' : 'password'}
                  value={apiKey}
                  readOnly
                  className="w-full pl-12 pr-12 py-3 border-2 border-gray-200 rounded-xl bg-gray-50 font-mono text-sm"
                  aria-label="API key"
                  placeholder="API key"
                />
                <button
                  type="button"
                  onClick={() => setShowApiKey(!showApiKey)}
                  className="absolute right-4 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600"
                  title="Toggle API key visibility"
                >
                  {showApiKey ? <EyeOff className="h-5 w-5" /> : <Eye className="h-5 w-5" />}
                </button>
              </div>
              <p className="text-xs text-gray-500 mt-2">Current API Key</p>
            </div>

            <div>
              <h4 className="font-semibold text-gray-900 mb-3">Integration Endpoints</h4>
              <div className="space-y-3 bg-gray-50 rounded-xl p-4">
                <div>
                  <p className="text-xs font-semibold text-gray-600 uppercase mb-1">Auth Endpoint</p>
                  <code className="text-xs text-gray-700 break-all">POST /api/admin/auth</code>
                </div>
                <div>
                  <p className="text-xs font-semibold text-gray-600 uppercase mb-1">Teachers Endpoint</p>
                  <code className="text-xs text-gray-700 break-all">GET/PATCH/DELETE /api/admin/teachers</code>
                </div>
                <div>
                  <p className="text-xs font-semibold text-gray-600 uppercase mb-1">Reviews Endpoint</p>
                  <code className="text-xs text-gray-700 break-all">GET/DELETE /api/admin/reviews</code>
                </div>
                <div>
                  <p className="text-xs font-semibold text-gray-600 uppercase mb-1">Analytics Endpoint</p>
                  <code className="text-xs text-gray-700 break-all">GET /api/admin/analytics</code>
                </div>
              </div>
            </div>

            {saveMessage && (
              <div className={`p-4 rounded-xl text-sm font-medium ${
                saveMessage.includes('regenerated')
                  ? 'bg-green-100 text-green-700'
                  : 'bg-red-100 text-red-700'
              }`}>
                {saveMessage}
              </div>
            )}

            <div className="pt-4 border-t border-gray-200">
              <button
                onClick={handleRegenerateApiKey}
                disabled={isSaving}
                className="flex items-center gap-2 px-8 py-3 border-2 border-yellow-600 text-yellow-600 font-bold rounded-xl hover:bg-yellow-50 disabled:opacity-50 transition-all"
              >
                <RefreshCw className="h-5 w-5" />
                {isSaving ? 'Regenerating...' : 'Regenerate API Key'}
              </button>
              <p className="text-xs text-gray-500 mt-3">
                ⚠️ Regenerating your API key will invalidate the current key. Update it in your application immediately.
              </p>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
