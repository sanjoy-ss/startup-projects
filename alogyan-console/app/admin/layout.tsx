'use client';

import { useEffect, useState } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import {
  BarChart3,
  LogOut,
  Menu,
  X,
  Users,
  MessageSquare,
  Settings,
  FileText,
  Home,
  Shield,
  UserCircle2,
  Megaphone
} from 'lucide-react';

const navigationItems = [
  { name: 'Dashboard', href: '/admin', icon: Home },
  { name: 'Customers', href: '/admin/customers', icon: Users },
  { name: 'Plans & Billing', href: '/admin/plans', icon: FileText },
  { name: 'Audit Log', href: '/admin/audit', icon: Shield },
  { name: 'Profile Approvals', href: '/admin/listings', icon: Users },
  { name: 'Teachers', href: '/admin/teachers', icon: Users },
  { name: 'Reviews', href: '/admin/reviews', icon: MessageSquare },
  { name: 'Content', href: '/admin/content', icon: FileText },
  { name: 'Digital Marketing', href: '/admin/marketing', icon: Megaphone },
  { name: 'Analytics', href: '/admin/analytics', icon: BarChart3 },
  { name: 'Admin Management', href: '/admin/admins', icon: Shield },
  { name: 'Settings', href: '/admin/settings', icon: Settings },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter();
  const pathname = usePathname();
  const isLoginPage = pathname?.startsWith('/admin/login');
  const [sidebarOpen, setSidebarOpen] = useState(true);
  const [adminUsername, setAdminUsername] = useState('');
  const [adminRole, setAdminRole] = useState('');
  const [adminPermissions, setAdminPermissions] = useState<Record<string, boolean>>({});
  const [isLoading, setIsLoading] = useState(true);
  const [adminAvatar, setAdminAvatar] = useState('/logo-official.png');

  useEffect(() => {
    // Check if user is authenticated by trying to access a protected route
    const checkAuth = async () => {
      try {
        const response = await fetch('/api/admin/check-auth', {
          method: 'GET',
          credentials: 'include'
        });

        if (!response.ok) {
          router.push('/admin/login');
          return;
        }

        const data = await response.json();
        setAdminUsername(data.username || 'admin');
        setAdminRole(data.role || 'super_admin');
        setAdminPermissions(data.permissions || {});
      } catch (error) {
        console.error('Auth check failed:', error);
        router.push('/admin/login');
      } finally {
        setIsLoading(false);
      }
    };

    // Only check auth if not on login page
    if (!pathname?.includes('/login')) {
      checkAuth();
    } else {
      setIsLoading(false);
    }
  }, [router, pathname]);

  useEffect(() => {
    const loadAvatar = () => {
      if (typeof window === 'undefined') return;
      const saved = window.localStorage.getItem('adminAvatar');
      setAdminAvatar(saved || '/logo-official.png');
    };

    loadAvatar();

    const handleAvatarUpdated = () => loadAvatar();
    if (typeof window !== 'undefined') {
      window.addEventListener('admin-avatar-updated', handleAvatarUpdated);
    }

    return () => {
      if (typeof window !== 'undefined') {
        window.removeEventListener('admin-avatar-updated', handleAvatarUpdated);
      }
    };
  }, []);

  const handleLogout = async () => {
    try {
      await fetch('/api/admin/auth', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'logout' }),
        credentials: 'include'
      });

      router.push('/admin/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen">
        <div className="text-center">
          <div className="w-12 h-12 border-4 border-brand-coral/30 border-t-brand-coral rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600 font-medium">Loading...</p>
        </div>
      </div>
    );
  }

  // For the login page, render children without admin chrome (no sidebar/header/profile)
  if (isLoginPage) {
    return (
      <div className="min-h-screen bg-gray-50">
        {children}
      </div>
    );
  }

  return (
    <div className="flex h-screen bg-gray-50">
      {/* Sidebar */}
      <div
        className={`${
          sidebarOpen ? 'w-64' : 'w-20'
        } bg-white border-r border-gray-200 transition-all duration-300 flex flex-col shadow-sm`}
      >
        {/* Logo */}
        <div className="h-20 flex items-center justify-between px-4 border-b border-gray-200">
          <div className={`${!sidebarOpen && 'hidden'} flex items-center gap-3`}>
            <div className="w-10 h-10 bg-white border border-gray-200 rounded-lg flex items-center justify-center shadow-sm">
              <Image src="/logo-official.png" alt="ALOGYAN" width={32} height={32} className="object-contain" />
            </div>
            <div>
              <div className="text-sm font-bold text-transparent bg-clip-text bg-brand-gradient">ALOGYAN</div>
              <div className="text-xs text-gray-500">In-house Console</div>
            </div>
          </div>
          {sidebarOpen && (
            <button
              onClick={() => setSidebarOpen(false)}
              className="lg:hidden text-gray-500 hover:text-gray-700"
              title="Collapse sidebar"
              aria-label="Collapse sidebar"
            >
              <X className="h-5 w-5" />
            </button>
          )}
          {!sidebarOpen && (
            <button
              onClick={() => setSidebarOpen(true)}
              className="hidden lg:block text-gray-500 hover:text-gray-700"
              title="Expand sidebar"
              aria-label="Expand sidebar"
            >
              <Menu className="h-5 w-5" />
            </button>
          )}
        </div>

        {/* Navigation */}
        <nav className="flex-1 overflow-y-auto px-3 py-6 space-y-2">
          {navigationItems.filter((item) => {
            // Filter navigation based on role and permissions
            if (adminRole === 'super_admin') return true;
            
            if (item.href === '/admin/customers') return adminPermissions.can_view_customers;
            if (item.href === '/admin/plans') return adminPermissions.can_manage_billing;
            if (item.href === '/admin/audit') return false;
            if (item.href === '/admin') return true; // Dashboard for all
            if (item.href === '/admin/settings') return true; // Settings for all
            
            if (item.href === '/admin/listings') return adminPermissions.can_manage_teachers;
            if (item.href === '/admin/teachers') return adminPermissions.can_manage_teachers;
            if (item.href === '/admin/reviews') return adminPermissions.can_manage_reviews;
            if (item.href === '/admin/content') return adminPermissions.can_manage_content;
            if (item.href === '/admin/marketing') return adminPermissions.can_manage_marketing;
            if (item.href === '/admin/analytics') return adminPermissions.can_view_analytics;
            if (item.href === '/admin/admins') return adminPermissions.can_manage_admins;
            
            return false;
          }).map((item) => {
            const Icon = item.icon;
            const isActive = pathname === item.href;
            return (
              <Link
                key={item.href}
                href={item.href as any}
                className={`flex items-center gap-3 px-4 py-3 rounded-lg transition-all duration-200 ${
                  isActive
                    ? 'bg-brand-gradient text-white shadow-lg'
                    : 'text-gray-700 hover:bg-gray-100'
                }`}
                title={item.name}
              >
                <Icon className="h-5 w-5 flex-shrink-0" />
                {sidebarOpen && <span className="text-sm font-medium">{item.name}</span>}
              </Link>
            );
          })}
        </nav>

        {/* Logout Button */}
        <div className="p-3 border-t border-gray-200">
          <button
            onClick={handleLogout}
            className="w-full flex items-center gap-3 px-4 py-3 rounded-lg text-gray-700 hover:bg-red-50 hover:text-red-600 transition-all duration-200 group"
            title="Logout"
          >
            <LogOut className="h-5 w-5 flex-shrink-0 group-hover:rotate-180 transition-transform duration-300" />
            {sidebarOpen && <span className="text-sm font-medium">Logout</span>}
          </button>
        </div>
      </div>

      {/* Main Content */}
      <div className="flex-1 flex flex-col overflow-hidden">
        {/* Top Header */}
        <div className="h-20 bg-white border-b border-gray-200 flex items-center justify-between px-8 shadow-sm">
          <div className="flex items-center gap-4">
            <button
              onClick={() => setSidebarOpen(!sidebarOpen)}
              className="hidden lg:block text-gray-600 hover:text-gray-900"
              title="Toggle sidebar"
              aria-label="Toggle sidebar"
            >
              <Menu className="h-6 w-6" />
            </button>
            <div>
              <h1 className="text-2xl font-bold text-gray-900">Dashboard</h1>
              <p className="text-sm text-gray-500">Welcome to Alogyan Console</p>
            </div>
          </div>

          {/* Admin Info */}
          <div className="flex items-center gap-4">
            <div className="text-right">
              <p className="text-sm font-semibold text-gray-900">{adminUsername}</p>
              <p className="text-xs text-gray-500 bg-blue-50 px-2 py-1 rounded-md">{adminRole.replace('_', ' ').toUpperCase()}</p>
            </div>
            <div className="w-12 h-12 rounded-full overflow-hidden border border-gray-200 shadow-sm bg-white flex items-center justify-center">
              {adminAvatar ? (
                <Image
                  key={adminAvatar}
                  src={adminAvatar}
                  alt="Admin avatar"
                  width={48}
                  height={48}
                  className="object-cover w-full h-full"
                />
              ) : (
                <UserCircle2 className="h-10 w-10 text-gray-400" />
              )}
            </div>
          </div>
        </div>

        {/* Content Area */}
        <div className="flex-1 overflow-auto">
          <div className="p-8 max-w-7xl mx-auto w-full">
            {children}
          </div>
        </div>
      </div>
    </div>
  );
}
