'use client';

import { useEffect, useState } from 'react';
import {
  Users,
  MessageSquare,
  Star,
  TrendingUp,
  Award,
  BookOpen,
  Calendar,
  Download,
  BarChart3
} from 'lucide-react';

interface AnalyticsData {
  totalTeachers: number;
  activeTeachers: number;
  featuredTeachers: number;
  totalReviews: number;
  averageRating: number;
  totalSubjects: number;
}

const PROGRESS_WIDTH_CLASSES = [
  'w-[0%]',
  'w-[5%]',
  'w-[10%]',
  'w-[15%]',
  'w-[20%]',
  'w-[25%]',
  'w-[30%]',
  'w-[35%]',
  'w-[40%]',
  'w-[45%]',
  'w-[50%]',
  'w-[55%]',
  'w-[60%]',
  'w-[65%]',
  'w-[70%]',
  'w-[75%]',
  'w-[80%]',
  'w-[85%]',
  'w-[90%]',
  'w-[95%]',
  'w-[100%]'
] as const;

const getProgressWidthClass = (percent: number) => {
  const clamped = Math.max(0, Math.min(100, percent));
  const stepIndex = Math.round(clamped / 5);
  return PROGRESS_WIDTH_CLASSES[stepIndex] ?? 'w-[0%]';
};

export default function Analytics() {
  const [analytics, setAnalytics] = useState<AnalyticsData | null>(null);
  const [loading, setLoading] = useState(true);
  const [timeRange, setTimeRange] = useState('month');

  useEffect(() => {
    const fetchAnalytics = async () => {
      try {
        const response = await fetch('/api/admin/analytics', {
          credentials: 'include'
        });

        if (!response.ok) throw new Error('Failed to fetch analytics');

        const data = await response.json();
        setAnalytics(data);
      } catch (error) {
        console.error('Error fetching analytics:', error);
      } finally {
        setLoading(false);
      }
    };

    fetchAnalytics();
  }, []);

  if (loading) {
    return (
      <div className="text-center py-12">
        <div className="w-12 h-12 border-4 border-brand-coral/30 border-t-brand-coral rounded-full animate-spin mx-auto mb-4"></div>
        <p className="text-gray-600">Loading analytics...</p>
      </div>
    );
  }

  if (!analytics) {
    return (
      <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-red-700">
        Failed to load analytics data
      </div>
    );
  }

  const activePercent = analytics.totalTeachers
    ? (analytics.activeTeachers / analytics.totalTeachers) * 100
    : 0;
  const featuredPercent = analytics.totalTeachers
    ? (analytics.featuredTeachers / analytics.totalTeachers) * 100
    : 0;
  const inactivePercent = analytics.totalTeachers
    ? ((analytics.totalTeachers - analytics.activeTeachers) / analytics.totalTeachers) * 100
    : 0;

  const metrics = [
    {
      title: 'Total Teachers',
      value: analytics.totalTeachers,
      change: '+12%',
      icon: Users,
      color: 'from-orange-100 to-red-100',
      textColor: 'text-orange-600'
    },
    {
      title: 'Active Teachers',
      value: analytics.activeTeachers,
      change: '+8%',
      icon: Award,
      color: 'from-green-100 to-emerald-100',
      textColor: 'text-green-600'
    },
    {
      title: 'Total Reviews',
      value: analytics.totalReviews,
      change: '+24%',
      icon: MessageSquare,
      color: 'from-purple-100 to-pink-100',
      textColor: 'text-purple-600'
    },
    {
      title: 'Average Rating',
      value: analytics.averageRating.toFixed(1),
      change: '+0.3',
      icon: Star,
      color: 'from-yellow-100 to-amber-100',
      textColor: 'text-yellow-600',
      suffix: '⭐'
    },
    {
      title: 'Featured Teachers',
      value: analytics.featuredTeachers,
      change: '+5',
      icon: Award,
      color: 'from-blue-100 to-cyan-100',
      textColor: 'text-blue-600'
    },
    {
      title: 'Total Subjects',
      value: analytics.totalSubjects,
      change: '+2',
      icon: BookOpen,
      color: 'from-indigo-100 to-blue-100',
      textColor: 'text-indigo-600'
    }
  ];

  return (
    <div className="space-y-8">
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-900">Analytics</h2>
          <p className="text-gray-600 mt-1">Track platform performance and growth</p>
        </div>
        <div className="flex gap-4">
          <select
            value={timeRange}
            onChange={(e) => setTimeRange(e.target.value)}
            className="px-4 py-2 border-2 border-gray-200 rounded-lg focus:outline-none focus:border-brand-coral"
            title="Select time range"
          >
            <option value="week">Last 7 Days</option>
            <option value="month">Last 30 Days</option>
            <option value="quarter">Last Quarter</option>
            <option value="year">Last Year</option>
          </select>
          <button className="flex items-center gap-2 px-4 py-2 bg-brand-gradient text-white font-bold rounded-lg hover:shadow-lg transition-all">
            <Download className="h-5 w-5" />
            Export
          </button>
        </div>
      </div>

      {/* Key Metrics Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
        {metrics.map((metric) => {
          const Icon = metric.icon;
          return (
            <div
              key={metric.title}
              className={`bg-gradient-to-br ${metric.color} rounded-2xl shadow-lg p-6 border border-white/50`}
            >
              <div className="flex items-start justify-between mb-4">
                <Icon className={`h-8 w-8 ${metric.textColor}`} />
                <div className="bg-white/50 px-3 py-1 rounded-full text-xs font-bold text-green-600">
                  {metric.change}
                </div>
              </div>
              <p className="text-gray-700 font-medium text-sm mb-2">{metric.title}</p>
              <div className="flex items-baseline gap-2">
                <p className="text-4xl font-bold text-gray-900">{metric.value}</p>
                {metric.suffix && <span className="text-2xl">{metric.suffix}</span>}
              </div>
            </div>
          );
        })}
      </div>

      {/* Charts Section */}
      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Teachers Distribution */}
        <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
          <h3 className="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
            <BarChart3 className="h-6 w-6 text-brand-coral" />
            Teacher Status Distribution
          </h3>
          <div className="space-y-4">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-semibold text-gray-700">Active Teachers</span>
                <span className="text-sm font-bold text-gray-900">{analytics.activeTeachers}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                <div className={`bg-green-500 h-full rounded-full transition-all duration-300 ${getProgressWidthClass(activePercent)}`}></div>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-semibold text-gray-700">Featured Teachers</span>
                <span className="text-sm font-bold text-gray-900">{analytics.featuredTeachers}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                <div className={`bg-purple-500 h-full rounded-full transition-all duration-300 ${getProgressWidthClass(featuredPercent)}`}></div>
              </div>
            </div>

            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-semibold text-gray-700">Inactive Teachers</span>
                <span className="text-sm font-bold text-gray-900">{analytics.totalTeachers - analytics.activeTeachers}</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-3 overflow-hidden">
                <div className={`bg-gray-400 h-full rounded-full transition-all duration-300 ${getProgressWidthClass(inactivePercent)}`}></div>
              </div>
            </div>
          </div>
        </div>

        {/* Rating Distribution */}
        <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
          <h3 className="text-lg font-bold text-gray-900 mb-6 flex items-center gap-2">
            <Star className="h-6 w-6 text-yellow-500" />
            Platform Health
          </h3>
          <div className="space-y-6">
            <div>
              <div className="flex items-center justify-between mb-2">
                <span className="text-sm font-semibold text-gray-700">Average Rating</span>
                <span className="text-2xl font-bold text-gray-900">{analytics.averageRating.toFixed(1)} ⭐</span>
              </div>
              <p className="text-xs text-gray-600">Based on {analytics.totalReviews} reviews</p>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-gray-700">Content Quality</span>
                <span className="text-sm font-bold text-green-600">Excellent</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                <div className="bg-green-500 h-full rounded-full w-[85%]"></div>
              </div>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-gray-700">User Engagement</span>
                <span className="text-sm font-bold text-blue-600">Good</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                <div className="bg-blue-500 h-full rounded-full w-[72%]"></div>
              </div>
            </div>

            <div className="space-y-2">
              <div className="flex items-center justify-between">
                <span className="text-sm font-medium text-gray-700">Growth Rate</span>
                <span className="text-sm font-bold text-purple-600">Strong</span>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2 overflow-hidden">
                <div className="bg-purple-500 h-full rounded-full w-[78%]"></div>
              </div>
            </div>
          </div>
        </div>
      </div>

      {/* Statistics Summary */}
      <div className="bg-gradient-to-r from-brand-coral to-brand-purple rounded-2xl shadow-xl p-8 text-white">
        <h3 className="text-2xl font-bold mb-6">Platform Summary</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          <div>
            <p className="text-white/80 text-sm mb-2">Total Platform Value</p>
            <p className="text-4xl font-bold">{analytics.totalTeachers * 5}</p>
            <p className="text-white/80 text-xs mt-2">Teaching profiles active</p>
          </div>
          <div>
            <p className="text-white/80 text-sm mb-2">Community Reviews</p>
            <p className="text-4xl font-bold">{analytics.totalReviews}</p>
            <p className="text-white/80 text-xs mt-2">Verified student feedback</p>
          </div>
          <div>
            <p className="text-white/80 text-sm mb-2">Subject Coverage</p>
            <p className="text-4xl font-bold">{analytics.totalSubjects}</p>
            <p className="text-white/80 text-xs mt-2">Different subjects available</p>
          </div>
        </div>
      </div>
    </div>
  );
}
