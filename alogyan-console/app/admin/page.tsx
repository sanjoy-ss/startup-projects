'use client';

import { useEffect, useState } from 'react';
import {
  Users,
  MessageSquare,
  Star,
  TrendingUp,
  Award,
  Activity,
  AlertCircle,
  BookOpen,
  SlidersHorizontal,
  PanelRightClose,
  PanelRightOpen,
  RefreshCw,
  CheckCircle2,
  Database,
  ShieldCheck,
  ArrowUpRight,
  Sparkles,
  Server,
  Zap,
  Clock,
  Layers,
  ArrowRight
} from 'lucide-react';
import Link from 'next/link';

interface DashboardStats {
  totalTeachers: number;
  totalReviews: number;
  averageRating: number;
  activeTeachers: number;
  featuredTeachers: number;
  totalSubjects: number;
}

export default function AdminDashboard() {
  const [stats, setStats] = useState<DashboardStats>({
    totalTeachers: 0,
    totalReviews: 0,
    averageRating: 0,
    activeTeachers: 0,
    featuredTeachers: 0,
    totalSubjects: 0,
  });
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');
  const [optionsOpen, setOptionsOpen] = useState(true);
  const [cacheStatus, setCacheStatus] = useState<'idle' | 'clearing' | 'cleared'>('idle');

  const fetchStats = async () => {
    try {
      const response = await fetch('/api/admin/analytics', {
        credentials: 'include',
      });

      if (!response.ok) {
        throw new Error('Failed to fetch stats');
      }

      const data = await response.json();
      setStats(data);
      setError('');
    } catch (err) {
      console.error('Error fetching stats:', err);
      setError('Failed to load dashboard data');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchStats();
  }, []);

  const handleRefresh = () => {
    setRefreshing(true);
    fetchStats();
  };



  const statCards = [
    {
      title: 'Total Teachers',
      value: stats.totalTeachers,
      badge: 'All registered',
      icon: Users,
      iconColor: 'text-[#C91F26]',
      iconBg: 'bg-red-50',
      href: '/admin/teachers',
    },
    {
      title: 'Active Teachers',
      value: stats.activeTeachers,
      badge: 'Live on platform',
      icon: Activity,
      iconColor: 'text-emerald-600',
      iconBg: 'bg-emerald-50',
      href: '/admin/teachers',
    },
    {
      title: 'Total Reviews',
      value: stats.totalReviews,
      badge: 'Moderated feedback',
      icon: MessageSquare,
      iconColor: 'text-blue-600',
      iconBg: 'bg-blue-50',
      href: '/admin/reviews',
    },
    {
      title: 'Average Rating',
      value: stats.averageRating ? stats.averageRating.toFixed(1) : '0.0',
      badge: 'Out of 5.0',
      icon: Star,
      iconColor: 'text-amber-500',
      iconBg: 'bg-amber-50',
      isRating: true,
    },
    {
      title: 'Featured Teachers',
      value: stats.featuredTeachers,
      badge: 'Promoted roster',
      icon: Award,
      iconColor: 'text-purple-600',
      iconBg: 'bg-purple-50',
      href: '/admin/teachers',
    },
    {
      title: 'Total Subjects',
      value: stats.totalSubjects,
      badge: 'Curriculum catalog',
      icon: BookOpen,
      iconColor: 'text-cyan-600',
      iconBg: 'bg-cyan-50',
      href: '/admin/content',
    },
  ];

  return (
    <div className="w-full space-y-6">
      {/* Top Controls Toolbar: Clean, no duplicate appbar */}
      {/* <div className="flex items-center justify-between gap-4 pb-1">
        <div className="flex items-center gap-2">
          <span className="text-xs font-bold uppercase tracking-wider text-gray-500 font-poppins">
            Platform Overview
          </span>
          <span className="hidden sm:inline-flex items-center gap-1.5 px-2 py-0.5 rounded-full text-[10px] font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/60">
            <span className="w-1.5 h-1.5 rounded-full bg-emerald-500 animate-pulse" />
            Live Sync
          </span>
        </div>

        <div className="flex items-center gap-2">
          <button
            onClick={handleRefresh}
            disabled={refreshing}
            className="inline-flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-medium text-gray-600 bg-white hover:bg-gray-50 border border-gray-200/80 rounded-lg transition-colors disabled:opacity-50 shadow-xs"
            title="Refresh metrics data"
          >
            <RefreshCw className={`h-3.5 w-3.5 text-gray-500 ${refreshing ? 'animate-spin' : ''}`} />
            <span>{refreshing ? 'Updating...' : 'Refresh'}</span>
          </button>

          <button
            onClick={() => setOptionsOpen(!optionsOpen)}
            className={`inline-flex items-center gap-1.5 px-2.5 py-1.5 text-xs font-medium rounded-lg border transition-colors shadow-xs ${
              optionsOpen
                ? 'bg-red-50 text-[#C91F26] border-red-200 hover:bg-red-100/70'
                : 'bg-white text-gray-600 border-gray-200/80 hover:bg-gray-50'
            }`}
            title={optionsOpen ? 'Collapse options panel' : 'Expand options panel'}
          >
            {optionsOpen ? (
              <>
                <PanelRightClose className="h-3.5 w-3.5" />
                <span>Options Panel (Open)</span>
              </>
            ) : (
              <>
                <PanelRightOpen className="h-3.5 w-3.5" />
                <span>Options Panel (Closed)</span>
              </>
            )}
          </button>
        </div>
      </div> */}

      {/* Main Layout Area: Fluid Content + Expandable Right Panel */}
      <div className="flex flex-col lg:flex-row items-start gap-6 w-full">
        {/* Left Section: Occupies All Available Space */}
        <div className="flex-1 min-w-0 w-full space-y-6">
          {/* Key Metrics Section */}
          <div className="space-y-3">
            <div className="flex items-center justify-between">
              <h3 className="text-sm font-bold uppercase tracking-wider text-gray-500 font-poppins">
                Platform Performance
              </h3>
              <span className="text-xs text-gray-400 font-medium">Live Aggregations</span>
            </div>

            {loading ? (
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                {[...Array(6)].map((_, i) => (
                  <div key={i} className="bg-white border border-gray-200/80 rounded-xl p-5 h-32 animate-pulse space-y-3">
                    <div className="h-4 bg-gray-100 rounded w-1/3" />
                    <div className="h-8 bg-gray-100 rounded w-1/2" />
                  </div>
                ))}
              </div>
            ) : error ? (
              <div className="bg-red-50 border border-red-200/80 rounded-xl p-4 flex items-start gap-3">
                <AlertCircle className="h-5 w-5 text-red-600 flex-shrink-0 mt-0.5" />
                <div>
                  <h4 className="text-xs font-bold text-red-900">Telemetry Synchronization Error</h4>
                  <p className="text-xs text-red-700 mt-0.5">{error}</p>
                </div>
              </div>
            ) : (
              <div className="grid grid-cols-1 sm:grid-cols-2 xl:grid-cols-3 gap-4">
                {statCards.map((card) => {
                  const Icon = card.icon;
                  const Wrapper = card.href ? Link : 'div';

                  return (
                    <Wrapper
                      key={card.title}
                      href={(card.href || '#') as any}
                      className={`bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs transition-all duration-150 relative group ${card.href ? 'hover:border-gray-300 hover:shadow-sm cursor-pointer' : ''
                        }`}
                    >
                      <div className="flex items-center justify-between mb-3">
                        <span className="text-xs font-semibold text-gray-500 uppercase tracking-tight">
                          {card.title}
                        </span>
                        <div className={`w-8 h-8 rounded-lg ${card.iconBg} flex items-center justify-center flex-shrink-0`}>
                          <Icon className={`h-4 w-4 ${card.iconColor}`} />
                        </div>
                      </div>

                      <div className="flex items-baseline gap-2 mb-2">
                        <span className="text-2xl font-bold text-gray-900 tracking-tight font-poppins">
                          {card.value}
                        </span>
                        {card.isRating && (
                          <div className="inline-flex items-center gap-1 text-amber-500 text-xs font-semibold">
                            <Star className="h-3.5 w-3.5 fill-amber-400 text-amber-400" />
                          </div>
                        )}
                      </div>

                      <div className="flex items-center justify-between pt-2 border-t border-gray-100">
                        <span className="text-[11px] text-gray-400 font-medium">
                          {card.badge}
                        </span>
                        {card.href && (
                          <span className="text-[11px] font-semibold text-gray-500 group-hover:text-[#C91F26] inline-flex items-center gap-0.5 transition-colors">
                            Manage
                            <ArrowUpRight className="h-3 w-3" />
                          </span>
                        )}
                      </div>
                    </Wrapper>
                  );
                })}
              </div>
            )}
          </div>

          {/* Quick Operations Modules */}
          <div className="space-y-3">
            <h3 className="text-sm font-bold uppercase tracking-wider text-gray-500 font-poppins">
              Management Workflows
            </h3>

            <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
              <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs hover:border-gray-300 transition-all">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-red-50 flex items-center justify-center text-[#C91F26]">
                      <Users className="h-4 w-4" />
                    </div>
                    <h4 className="text-sm font-bold text-gray-900 font-poppins">Teacher Management</h4>
                  </div>
                  <span className="text-[10px] font-semibold bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
                    Roster
                  </span>
                </div>
                <p className="text-xs text-gray-500 mb-4 leading-relaxed">
                  Review tutor credentials, update subject specializations, and manage featured visibility.
                </p>
                <Link
                  href="/admin/teachers"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-[#C91F26] hover:text-[#A81920] transition-colors"
                >
                  Access Directory
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>

              <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs hover:border-gray-300 transition-all">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-blue-50 flex items-center justify-center text-blue-600">
                      <MessageSquare className="h-4 w-4" />
                    </div>
                    <h4 className="text-sm font-bold text-gray-900 font-poppins">Feedback & Reviews</h4>
                  </div>
                  <span className="text-[10px] font-semibold bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
                    Moderation
                  </span>
                </div>
                <p className="text-xs text-gray-500 mb-4 leading-relaxed">
                  Moderate student ratings, inspect reports, and ensure quality standards across listings.
                </p>
                <Link
                  href="/admin/reviews"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-blue-600 hover:text-blue-700 transition-colors"
                >
                  Inspect Reviews
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>

              <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs hover:border-gray-300 transition-all">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-cyan-50 flex items-center justify-center text-cyan-600">
                      <BookOpen className="h-4 w-4" />
                    </div>
                    <h4 className="text-sm font-bold text-gray-900 font-poppins">Content & Media CMS</h4>
                  </div>
                  <span className="text-[10px] font-semibold bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
                    CMS
                  </span>
                </div>
                <p className="text-xs text-gray-500 mb-4 leading-relaxed">
                  Maintain curriculum documentation, landing materials, FAQs, and static platform assets.
                </p>
                <Link
                  href="/admin/content"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-cyan-700 hover:text-cyan-800 transition-colors"
                >
                  Edit Publications
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>

              <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs hover:border-gray-300 transition-all">
                <div className="flex items-start justify-between mb-2">
                  <div className="flex items-center gap-2.5">
                    <div className="w-8 h-8 rounded-lg bg-purple-50 flex items-center justify-center text-purple-600">
                      <TrendingUp className="h-4 w-4" />
                    </div>
                    <h4 className="text-sm font-bold text-gray-900 font-poppins">Growth & Telemetry</h4>
                  </div>
                  <span className="text-[10px] font-semibold bg-gray-100 text-gray-600 px-2 py-0.5 rounded">
                    Analytics
                  </span>
                </div>
                <p className="text-xs text-gray-500 mb-4 leading-relaxed">
                  Analyze cohort retention, center acquisition channels, and high-demand teaching disciplines.
                </p>
                <Link
                  href="/admin/analytics"
                  className="inline-flex items-center gap-1.5 text-xs font-semibold text-purple-600 hover:text-purple-700 transition-colors"
                >
                  View Trends
                  <ArrowRight className="h-3.5 w-3.5" />
                </Link>
              </div>
            </div>
          </div>
        </div>


      </div>
    </div>
  );
}
