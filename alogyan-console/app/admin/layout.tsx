'use client';

import { useEffect, useState, useMemo } from 'react';
import { useRouter, usePathname } from 'next/navigation';
import Link from 'next/link';
import Image from 'next/image';
import {
  LayoutDashboard,
  BarChart3,
  Building2,
  GraduationCap,
  BadgeCheck,
  MessageSquareText,
  CreditCard,
  FolderKanban,
  Megaphone,
  UserCheck,
  ShieldAlert,
  SlidersHorizontal,
  LogOut,
  Menu,
  ChevronRight,
  UserCircle2,
  Sparkles,
  Server,
  Zap,
  Clock,
  CheckCircle2,
  Database,
  ShieldCheck,
  Users,
  ArrowUpRight, RefreshCw, PanelRightClose, PanelRightOpen
} from 'lucide-react';

interface NavigationItem {
  name: string;
  href: string;
  icon: React.ComponentType<{ className?: string }>;
  permissionKey?: string;
  badge?: string;
}

interface NavigationGroup {
  label: string;
  items: NavigationItem[];
}

const NAVIGATION_GROUPS: NavigationGroup[] = [
  {
    label: 'Overview',
    items: [
      { name: 'Dashboard', href: '/admin', icon: LayoutDashboard },
      { name: 'Analytics', href: '/admin/analytics', icon: BarChart3, permissionKey: 'can_view_analytics' },
    ],
  },
  {
    label: 'Directory & Network',
    items: [
      { name: 'Institutes & Centers', href: '/admin/customers', icon: Building2, permissionKey: 'can_view_customers' },
      { name: 'Teachers & Tutors', href: '/admin/teachers', icon: GraduationCap, permissionKey: 'can_manage_teachers' },
      { name: 'Profile Approvals', href: '/admin/listings', icon: BadgeCheck, permissionKey: 'can_manage_teachers' },
      { name: 'Reviews & Ratings', href: '/admin/reviews', icon: MessageSquareText, permissionKey: 'can_manage_reviews' },
    ],
  },
  {
    label: 'Commerce & CMS',
    items: [
      { name: 'Plans & Billing', href: '/admin/plans', icon: CreditCard, permissionKey: 'can_manage_billing' },
      { name: 'Plan Members', href: '/admin/members', icon: Users, permissionKey: 'can_manage_billing' },
      { name: 'Content CMS', href: '/admin/content', icon: FolderKanban, permissionKey: 'can_manage_content' },
    ],
  },
  {
    label: 'Growth',
    items: [
      { name: 'Digital Marketing', href: '/admin/marketing', icon: Megaphone, permissionKey: 'can_manage_marketing' },
    ],
  },
  {
    label: 'Governance & System',
    items: [
      { name: 'Admin Directory', href: '/admin/admins', icon: UserCheck, permissionKey: 'can_manage_admins' },
      { name: 'Audit Trail', href: '/admin/audit', icon: ShieldAlert },
      { name: 'Settings', href: '/admin/settings', icon: SlidersHorizontal },
    ],
  },
];

const ROUTE_METADATA: Record<string, { title: string; group: string; subtitle: string }> = {
  '/admin': {
    title: 'Executive Dashboard',
    group: 'Overview',
    subtitle: 'Real-time platform operations and system health overview',
  },
  '/admin/analytics': {
    title: 'Analytics & Trends',
    group: 'Overview',
    subtitle: 'Traffic insights, user engagement, and platform telemetry',
  },
  '/admin/customers': {
    title: 'Institutes & Centers',
    group: 'Directory & Network',
    subtitle: 'Manage educational centers, plan combinations, and subscription access',
  },
  '/admin/teachers': {
    title: 'Teachers & Tutors',
    group: 'Directory & Network',
    subtitle: 'Educator roster, profile verifications, and onboarding states',
  },
  '/admin/listings': {
    title: 'Profile Approvals',
    group: 'Directory & Network',
    subtitle: 'Verification queue for pending teacher and institute submissions',
  },
  '/admin/reviews': {
    title: 'Reviews & Ratings',
    group: 'Directory & Network',
    subtitle: 'Moderate student reviews, testimonials, and rating appeals',
  },
  '/admin/plans': {
    title: 'Plans & Billing',
    group: 'Commerce & CMS',
    subtitle: 'Subscription tiers, billing cycles, quotas, and invoices',
  },
  '/admin/members': {
    title: 'Plan Members & Subscriptions',
    group: 'Commerce & CMS',
    subtitle: 'Institute subscribers, purchased plan combinations, and renewal trends',
  },
  '/admin/content': {
    title: 'Content CMS',
    group: 'Commerce & CMS',
    subtitle: 'Curriculum assets, banners, FAQs, and static documents',
  },
  '/admin/marketing': {
    title: 'Digital Marketing',
    group: 'Growth',
    subtitle: 'Lead funnels, attribution channels, and promotion campaigns',
  },
  '/admin/admins': {
    title: 'Admin Directory',
    group: 'Governance & System',
    subtitle: 'Console team access control, roles, and administrative staff',
  },
  '/admin/audit': {
    title: 'Audit Trail',
    group: 'Governance & System',
    subtitle: 'Security logs, compliance events, and mutation history',
  },
  '/admin/settings': {
    title: 'System Settings',
    group: 'Governance & System',
    subtitle: 'Global parameters, API integrations, and notification channels',
  },
};

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
  const [optionsOpen, setOptionsOpen] = useState(true);
  const [cacheStatus, setCacheStatus] = useState<'idle' | 'clearing' | 'cleared'>('idle');
  const handleClearCache = () => {
    setCacheStatus('clearing');
    setTimeout(() => {
      setCacheStatus('cleared');
      setTimeout(() => setCacheStatus('idle'), 2500);
    }, 800);
  };
  useEffect(() => {
    const checkAuth = async () => {
      try {
        const response = await fetch('/api/admin/check-auth', {
          method: 'GET',
          credentials: 'include',
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
        credentials: 'include',
      });

      router.push('/admin/login');
    } catch (error) {
      console.error('Logout failed:', error);
    }
  };

  // Check if an item is allowed for current role and permissions
  const isItemVisible = (item: NavigationItem): boolean => {
    if (adminRole === 'super_admin') return true;
    if (item.href === '/admin') return true;
    if (item.href === '/admin/settings') return true;
    if (item.href === '/admin/audit') return false; // super_admin only
    if (item.permissionKey) {
      return Boolean(adminPermissions[item.permissionKey]);
    }
    return false;
  };

  // Filter groups and items
  const visibleGroups = useMemo(() => {
    return NAVIGATION_GROUPS.map((group) => ({
      ...group,
      items: group.items.filter(isItemVisible),
    })).filter((group) => group.items.length > 0);
  }, [adminRole, adminPermissions]);

  // Derive current page metadata for breadcrumbs & header
  const currentMeta = useMemo(() => {
    if (!pathname) return ROUTE_METADATA['/admin'];
    if (ROUTE_METADATA[pathname]) return ROUTE_METADATA[pathname];
    const matchedKey = Object.keys(ROUTE_METADATA).find(
      (k) => k !== '/admin' && pathname.startsWith(k)
    );
    return matchedKey ? ROUTE_METADATA[matchedKey] : ROUTE_METADATA['/admin'];
  }, [pathname]);

  if (isLoading) {
    return (
      <div className="flex items-center justify-center min-h-screen bg-gray-50">
        <div className="text-center">
          <div className="w-10 h-10 border-3 border-gray-200 border-t-[#C91F26] rounded-full animate-spin mx-auto mb-3"></div>
          <p className="text-xs font-medium text-gray-500 uppercase tracking-wider">Loading Console...</p>
        </div>
      </div>
    );
  }

  if (isLoginPage) {
    return <div className="min-h-screen bg-gray-50">{children}</div>;
  }

  const roleLabel = (adminRole || 'admin').replace('_', ' ').toUpperCase();

  return (
    <div className="flex h-screen bg-[#F9FAFB] text-gray-900 font-sans antialiased overflow-hidden">
      {/* Mobile backdrop overlay */}
      {sidebarOpen && (
        <div
          className="fixed inset-0 bg-gray-900/30 z-20 lg:hidden backdrop-blur-xs transition-opacity"
          onClick={() => setSidebarOpen(false)}
        />
      )}

      {/* Sidebar: Fixed height, smooth width transition */}
      <aside
        className={`${sidebarOpen ? 'w-64' : 'w-20'
          } bg-white border-r border-gray-200/80 transition-all duration-200 flex flex-col z-30 select-none shadow-[1px_0_4px_rgba(0,0,0,0.02)] flex-shrink-0 h-screen sticky top-0`}
      >
        {/* Sidebar Header with Internal Hamburger / Collapse Toggle */}
        <div className="h-16 flex items-center justify-between px-3.5 border-b border-gray-100 flex-shrink-0">
          {sidebarOpen ? (
            <>
              <div className="flex items-center gap-2.5 overflow-hidden min-w-0">

                <div className="flex flex-col min-w-0">
                  <div className="flex items-center gap-1.5">
                    <span className="text-sm font-bold text-gray-900 tracking-tight font-poppins">ALOGYAN</span>
                    <span className="text-[10px] font-semibold bg-red-50 text-[#C91F26] px-1.5 py-0.2 rounded border border-red-100">
                      Console
                    </span>
                  </div>
                  <span className="text-[11px] text-gray-400 font-medium truncate">Education Management</span>
                </div>
              </div>

              {/* Hamburger Toggle button inside expanded sidebar */}
              <button
                onClick={() => setSidebarOpen(false)}
                className="p-1.5 rounded-lg text-gray-400 hover:text-gray-700 hover:bg-gray-100 transition-colors flex-shrink-0"
                title="Collapse sidebar"
                aria-label="Collapse sidebar"
              >
                <Menu className="h-4 w-4" />
              </button>
            </>
          ) : (
            /* Hamburger Toggle button inside collapsed sidebar */
            <div className="w-full flex items-center justify-center">
              <button
                onClick={() => setSidebarOpen(true)}
                className="w-9 h-9  bg-gray-50 hover:bg-gray-100 border border-gray-200/70 flex items-center justify-center text-gray-600 hover:text-gray-900 transition-colors group relative"
                title="Expand sidebar"
                aria-label="Expand sidebar"
              >
                <Menu className="h-4 w-4" />
                <div className="absolute left-full ml-3 px-2.5 py-1 bg-gray-900 text-white text-[11px] font-medium rounded-md shadow-md opacity-0 pointer-events-none group-hover:opacity-100 transition-opacity duration-150 whitespace-nowrap z-50">
                  Expand sidebar
                </div>
              </button>
            </div>
          )}
        </div>

        {/* Grouped Navigation Links: No visible scrollbar, fixed clean layout */}
        <nav
          className={`flex-1 overflow-y-auto overflow-x-hidden [-ms-overflow-style:none] [scrollbar-width:none] [&::-webkit-scrollbar]:hidden ${sidebarOpen ? 'px-3 py-3 space-y-4' : 'px-2 py-2 space-y-2'
            }`}
        >
          {visibleGroups.map((group) => (
            <div key={group.label} className="space-y-0.5">
              {sidebarOpen ? (
                <div className="px-3 pt-1 pb-1 text-[10px] font-bold uppercase tracking-wider text-gray-400 select-none">
                  {group.label}
                </div>
              ) : (
                <div className="my-1 border-t border-gray-100 w-6 mx-auto" />
              )}

              <div className="space-y-0.5">
                {group.items.map((item) => {
                  const Icon = item.icon;
                  const isActive =
                    item.href === '/admin'
                      ? pathname === '/admin'
                      : pathname === item.href || pathname.startsWith(`${item.href}/`);

                  return (
                    <Link
                      key={item.href}
                      href={item.href as any}
                      className={`group relative flex items-center ${sidebarOpen
                        ? 'px-3 py-2 rounded-r-md gap-3  text-xs'
                        : 'w-10 h-10 mx-auto justify-center rounded-r-sm'
                        } transition-all duration-150 ${isActive
                          ? 'bg-red-50/70 text-[#C91F26] font-semibold shadow-xs'
                          : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100/70 font-medium'
                        }`}
                    >
                      {/* Active indicator bar */}
                      {isActive && (
                        <span className="absolute left-0 top-1.5 bottom-1.5 w-1 bg-[#C91F26] rounded-r" />
                      )}

                      <Icon
                        className={`h-4 w-4 flex-shrink-0 transition-colors ${isActive
                          ? 'text-[#C91F26]'
                          : 'text-gray-400 group-hover:text-gray-700'
                          }`}
                      />

                      {sidebarOpen && (
                        <span className="truncate text-xs">{item.name}</span>
                      )}

                      {/* Tooltip in collapsed mode */}
                      {!sidebarOpen && (
                        <div className="absolute left-full ml-3 px-2.5 py-1 bg-gray-900 text-white text-[11px] font-medium rounded-md shadow-md opacity-0 pointer-events-none group-hover:opacity-100 transition-opacity duration-150 whitespace-nowrap z-50">
                          {item.name}
                        </div>
                      )}
                    </Link>
                  );
                })}
              </div>
            </div>
          ))}
        </nav>

        {/* Sidebar Footer: Admin Profile Card */}
        <div className="p-3 border-t border-gray-100 bg-gray-50/50 flex-shrink-0">
          {sidebarOpen ? (
            <div className="flex items-center justify-between gap-2 p-2 rounded-sm bg-white border border-gray-200/70 shadow-xs">
              <div className="flex items-center gap-2.5 min-w-0">
                <div className="relative w-8 h-8 rounded-full overflow-hidden border border-gray-200 bg-white flex-shrink-0">
                  {adminAvatar ? (
                    <div className="w-8 h-8 rounded-lg bg-gray-50 border border-gray-200/70 p-1 flex items-center justify-center shadow-xs flex-shrink-0">
                      <Image src="/logo-official.png" alt="ALOGYAN" width={24} height={24} className="object-contain" priority />
                    </div>
                  ) : (
                    <UserCircle2 className="h-full w-full text-gray-400" />
                  )}
                </div>
                <div className="min-w-0 flex-1">
                  <p className="text-xs font-semibold text-gray-900 truncate leading-tight">
                    {adminUsername}
                  </p>
                  <p className="text-[10px] text-gray-400 font-medium truncate">
                    {roleLabel}
                  </p>
                </div>
              </div>

              <button
                onClick={handleLogout}
                className="p-1.5 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors"
                title="Sign out"
                aria-label="Sign out"
              >
                <LogOut className="h-4 w-4" />
              </button>
            </div>
          ) : (
            <div className=" flex items-center justify-center">
              <button
                onClick={handleLogout}
                className="p-2 text-gray-400 hover:text-red-600 hover:bg-red-50 rounded-md transition-colors group relative"
                title="Sign out"
                aria-label="Sign out"
              >
                <LogOut className="h-4 w-4" />
                <div className="absolute left-full top-0 ml-3 px-2 py-1 bg-gray-900 text-white text-[11px] font-medium rounded-md shadow-md opacity-0 pointer-events-none group-hover:opacity-100 transition-opacity duration-150 whitespace-nowrap z-50">
                  Logout
                </div>
              </button>
            </div>
          )}
        </div>
      </aside>

      {/* Main Content Area */}
      <div className="flex-1 flex flex-col min-w-0 overflow-hidden">
        {/* Top Header Bar: Clean breadcrumb + status (Hamburger menu moved inside sidebar) */}
        <header className="h-16 bg-white border-b border-gray-200/80 flex items-center justify-between px-6 flex-shrink-0 z-20 shadow-xs">
          {/* Left: Dynamic Breadcrumb Navigation */}
          <div className="flex flex-col min-w-0">
            <nav aria-label="Breadcrumb" className="flex items-center gap-1.5 text-[11px] text-gray-400 font-medium">
              <span className="hover:text-gray-600 transition-colors">Console</span>
              <ChevronRight className="h-3 w-3 text-gray-300" />
              <span className="hover:text-gray-600 transition-colors">{currentMeta.group}</span>
              <ChevronRight className="h-3 w-3 text-gray-300" />
              <span className="text-gray-700 font-semibold truncate">{currentMeta.title}</span>
            </nav>
            <h1 className="text-base font-bold text-gray-900 truncate leading-tight font-poppins">
              {currentMeta.title}
            </h1>
          </div>

          {/* Right: Operational Status & Role Indicator */}
          <div className="flex items-center gap-3 flex-shrink-0">
            <button
              onClick={() => setOptionsOpen(!optionsOpen)}
              className={`inline-flex items-center gap-1.5 p-1.5 text-xs font-medium  border transition-colors shadow-xs ${optionsOpen
                ? 'bg-red-50 text-[#C91F26] border-red-200 hover:bg-red-100/70'
                : 'bg-white text-gray-600 border-gray-200/80 hover:bg-gray-50'
                }`}
              title={optionsOpen ? 'Collapse options panel' : 'Expand options panel'}
            >
              {optionsOpen ? (
                <>
                  <PanelRightClose className="h-4 w-4" />
                </>
              ) : (
                <>
                  <PanelRightOpen className="h-4 w-4" />

                </>
              )}
            </button>

            <div className="hidden md:flex items-center gap-2 pl-3 border-l border-gray-200">
              <div className="w-8 h-8 rounded-lg bg-gray-50 border border-gray-200/70 p-1 flex items-center justify-center shadow-xs flex-shrink-0">
                <Image src="/logo-official.png" alt="ALOGYAN" width={24} height={24} className="object-contain" priority />
              </div>
            </div>
          </div>
        </header>

        {/* Scrollable Page Body */}
        <main className="flex-1 min-h-0 flex flex-col lg:flex-row gap-6 p-4 lg:p-8 overflow-hidden">
          {/* Middle section — scrolls independently */}
          <div className="flex-1 min-h-0 min-w-0 w-full space-y-6 overflow-y-auto overscroll-contain [scrollbar-width:none] [&::-webkit-scrollbar]:hidden">
            {children}
          </div>
          {optionsOpen && (
            <aside className="w-full lg:w-80 xl:w-88 flex-shrink-0 space-y-5 transition-all duration-200">
              {/* Quick Actions Panel */}
              <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs space-y-4">
                <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                  <div className="flex items-center gap-2">
                    <SlidersHorizontal className="h-4 w-4 text-gray-700" />
                    <h4 className="text-xs font-bold uppercase tracking-wider text-gray-700 font-poppins">
                      Quick Controls
                    </h4>
                  </div>
                  <button
                    onClick={() => setOptionsOpen(false)}
                    className="text-gray-400 hover:text-gray-600 p-1 rounded-md transition-colors"
                    title="Close panel"
                  >
                    <PanelRightClose className="h-3.5 w-3.5" />
                  </button>
                </div>

                <div className="space-y-2.5">
                  <Link
                    href="/admin/listings"
                    className="flex items-center justify-between p-2.5 rounded-lg border border-gray-200/80 hover:bg-gray-50 transition-colors group"
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <div className="w-7 h-7 rounded-md bg-amber-50 text-amber-600 flex items-center justify-center flex-shrink-0">
                        <Sparkles className="h-3.5 w-3.5" />
                      </div>
                      <span className="text-xs font-medium text-gray-800 truncate">Verification Queue</span>
                    </div>
                    <span className="text-[10px] font-semibold bg-amber-100/80 text-amber-800 px-2 py-0.5 rounded">
                      Pending
                    </span>
                  </Link>

                  <Link
                    href="/admin/audit"
                    className="flex items-center justify-between p-2.5 rounded-lg border border-gray-200/80 hover:bg-gray-50 transition-colors group"
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <div className="w-7 h-7 rounded-md bg-blue-50 text-blue-600 flex items-center justify-center flex-shrink-0">
                        <ShieldCheck className="h-3.5 w-3.5" />
                      </div>
                      <span className="text-xs font-medium text-gray-800 truncate">Audit Trail</span>
                    </div>
                    <ArrowUpRight className="h-3.5 w-3.5 text-gray-400 group-hover:text-gray-700 transition-colors" />
                  </Link>

                  <button
                    onClick={handleClearCache}
                    disabled={cacheStatus !== 'idle'}
                    className="w-full flex items-center justify-between p-2.5 rounded-lg border border-gray-200/80 hover:bg-gray-50 transition-colors text-left"
                  >
                    <div className="flex items-center gap-2.5 min-w-0">
                      <div className="w-7 h-7 rounded-md bg-gray-100 text-gray-600 flex items-center justify-center flex-shrink-0">
                        <RefreshCw className={`h-3.5 w-3.5 ${cacheStatus === 'clearing' ? 'animate-spin' : ''}`} />
                      </div>
                      <span className="text-xs font-medium text-gray-800 truncate">Purge Edge Cache</span>
                    </div>
                    <span className="text-[10px] font-semibold text-gray-500">
                      {cacheStatus === 'clearing' ? 'Clearing...' : cacheStatus === 'cleared' ? 'Done' : 'Flush'}
                    </span>
                  </button>
                </div>
              </div>

              {/* Infrastructure & Platform Health Card */}
              <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs space-y-3.5">
                <div className="flex items-center justify-between pb-3 border-b border-gray-100">
                  <div className="flex items-center gap-2">
                    <Server className="h-4 w-4 text-gray-700" />
                    <h4 className="text-xs font-bold uppercase tracking-wider text-gray-700 font-poppins">
                      Infrastructure Status
                    </h4>
                  </div>
                  <span className="text-[10px] font-semibold bg-emerald-50 text-emerald-700 px-2 py-0.5 rounded border border-emerald-200/60">
                    Healthy
                  </span>
                </div>

                <div className="space-y-2.5 text-xs">
                  <div className="flex items-center justify-between p-2.5 bg-gray-50/70 rounded-lg border border-gray-100">
                    <div className="flex items-center gap-2">
                      <CheckCircle2 className="h-3.5 w-3.5 text-emerald-600 flex-shrink-0" />
                      <span className="text-gray-700 font-medium">Core API Gateway</span>
                    </div>
                    <span className="text-[11px] font-mono text-emerald-700 font-semibold">99.98%</span>
                  </div>

                  <div className="flex items-center justify-between p-2.5 bg-gray-50/70 rounded-lg border border-gray-100">
                    <div className="flex items-center gap-2">
                      <Database className="h-3.5 w-3.5 text-blue-600 flex-shrink-0" />
                      <span className="text-gray-700 font-medium">Primary Database</span>
                    </div>
                    <span className="text-[11px] font-mono text-blue-700 font-semibold">Connected</span>
                  </div>

                  <div className="flex items-center justify-between p-2.5 bg-gray-50/70 rounded-lg border border-gray-100">
                    <div className="flex items-center gap-2">
                      <Zap className="h-3.5 w-3.5 text-purple-600 flex-shrink-0" />
                      <span className="text-gray-700 font-medium">Search Indices</span>
                    </div>
                    <span className="text-[11px] font-mono text-purple-700 font-semibold">Synchronized</span>
                  </div>
                </div>

                <div className="pt-2 flex items-center justify-between text-[11px] text-gray-400">
                  <span className="flex items-center gap-1">
                    <Clock className="h-3 w-3" />
                    Automated Backups
                  </span>
                  <span className="font-medium text-gray-600">Daily at 03:00 UTC</span>
                </div>
              </div>
            </aside>
          )}
        </main>
        {/* Right Section: Expandable Options & System Controls */}


      </div>
    </div>
  );
}
