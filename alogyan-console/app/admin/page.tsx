'use client';

import { useEffect, useState } from 'react';
import {
  Users,
  MessageSquare,
  Star,
  TrendingUp,
  Award,
  Calendar,
  Activity,
  AlertCircle,
  BookOpen,
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
  const [error, setError] = useState('');

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const response = await fetch('/api/admin/analytics', {
          credentials: 'include'
        });

        if (!response.ok) {
          throw new Error('Failed to fetch stats');
        }

        const data = await response.json();
        setStats(data);
      } catch (err) {
        console.error('Error fetching stats:', err);
        setError('Failed to load dashboard data');
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  const statCards = [
    {
      title: 'Total Teachers',
      value: stats.totalTeachers,
      icon: Users,
      color: 'brand-coral',
      bgColor: 'from-orange-100 to-red-100',
      href: '/admin/teachers'
    },
    {
      title: 'Active Teachers',
      value: stats.activeTeachers,
      icon: Activity,
      color: 'brand-green',
      bgColor: 'from-green-100 to-emerald-100',
      href: '/admin/teachers'
    },
    {
      title: 'Total Reviews',
      value: stats.totalReviews,
      icon: MessageSquare,
      color: 'brand-purple',
      bgColor: 'from-purple-100 to-pink-100',
      href: '/admin/reviews'
    },
    {
      title: 'Average Rating',
      value: stats.averageRating.toFixed(1),
      icon: Star,
      color: 'brand-yellow',
      bgColor: 'from-yellow-100 to-amber-100',
      suffix: '⭐'
    },
    {
      title: 'Featured Teachers',
      value: stats.featuredTeachers,
      icon: Award,
      color: 'brand-blue',
      bgColor: 'from-blue-100 to-cyan-100',
      href: '/admin/teachers'
    },
    {
      title: 'Total Subjects',
      value: stats.totalSubjects,
      icon: BookOpen,
      color: 'brand-indigo',
      bgColor: 'from-indigo-100 to-blue-100',
      href: '/admin/content'
    },
  ];

  return (
    <div className="space-y-8">
      {/* Welcome Section */}
      <div className="bg-brand-gradient rounded-2xl shadow-xl p-8 text-white">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-4xl font-bold mb-2">Welcome Back! 👋</h2>
            <p className="text-white/90 text-lg max-w-2xl">
              Here's what's happening with your ALOGYAN teaching platform today.
            </p>
          </div>
          <div className="text-6xl opacity-20">📊</div>
        </div>
      </div>

      {/* Stats Grid */}
      <div>
        <h3 className="text-2xl font-bold text-gray-900 mb-6">Key Metrics</h3>
        {loading ? (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {[...Array(6)].map((_, i) => (
              <div key={i} className="bg-gray-200 animate-pulse rounded-2xl h-40"></div>
            ))}
          </div>
        ) : error ? (
          <div className="bg-red-50 border border-red-200 rounded-2xl p-6 flex items-start gap-4">
            <AlertCircle className="h-6 w-6 text-red-600 flex-shrink-0 mt-1" />
            <div>
              <h4 className="font-bold text-red-900">Error Loading Stats</h4>
              <p className="text-red-700 text-sm">{error}</p>
            </div>
          </div>
        ) : (
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
            {statCards.map((card) => {
              const Icon = card.icon;
              const Component = card.href ? Link : 'div';
              return (
                <Component
                  key={card.title}
                  href={(card.href || '#') as any}
                  className={`bg-gradient-to-br ${card.bgColor} rounded-2xl shadow-lg p-6 hover:shadow-xl transition-all duration-300 ${
                    card.href ? 'hover:scale-105 cursor-pointer' : ''
                  }`}
                >
                  <div className="flex items-start justify-between mb-4">
                    <div className="w-14 h-14 bg-white/50 rounded-xl flex items-center justify-center">
                      <Icon className="h-7 w-7 text-gray-800" />
                    </div>
                    <TrendingUp className="h-5 w-5 text-green-600 opacity-50" />
                  </div>
                  <p className="text-gray-700 font-medium text-sm mb-2">{card.title}</p>
                  <div className="flex items-baseline gap-2">
                    <span className="text-4xl font-bold text-gray-900">{card.value}</span>
                    {card.suffix && <span className="text-2xl">{card.suffix}</span>}
                  </div>
                </Component>
              );
            })}
          </div>
        )}
      </div>

      {/* Quick Actions */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
        <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <Users className="h-6 w-6 text-brand-coral" />
            <h4 className="text-lg font-bold text-gray-900">Manage Teachers</h4>
          </div>
          <p className="text-gray-600 text-sm mb-4">
            Add, edit, approve, or remove teacher profiles. Manage features, ratings, and visibility.
          </p>
          <Link
            href="/admin/teachers"
            className="inline-flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg transition-all duration-200"
          >
            Go to Teachers
            <span>→</span>
          </Link>
        </div>

        <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <MessageSquare className="h-6 w-6 text-brand-purple" />
            <h4 className="text-lg font-bold text-gray-900">Review Management</h4>
          </div>
          <p className="text-gray-600 text-sm mb-4">
            Moderate student reviews, manage ratings, and ensure platform quality standards.
          </p>
          <Link
            href="/admin/reviews"
            className="inline-flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg transition-all duration-200"
          >
            View Reviews
            <span>→</span>
          </Link>
        </div>

        <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <BookOpen className="h-6 w-6 text-brand-blue" />
            <h4 className="text-lg font-bold text-gray-900">Content Management</h4>
          </div>
          <p className="text-gray-600 text-sm mb-4">
            Update static pages, manage FAQ, terms, privacy, and other site content.
          </p>
          <Link
            href="/admin/content"
            className="inline-flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg transition-all duration-200"
          >
            Edit Content
            <span>→</span>
          </Link>
        </div>

        <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
          <div className="flex items-center gap-3 mb-4">
            <Calendar className="h-6 w-6 text-brand-indigo" />
            <h4 className="text-lg font-bold text-gray-900">View Analytics</h4>
          </div>
          <p className="text-gray-600 text-sm mb-4">
            Track platform growth, user engagement, and detailed analytics reports.
          </p>
          <Link
            href="/admin/analytics"
            className="inline-flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg transition-all duration-200"
          >
            View Analytics
            <span>→</span>
          </Link>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-white rounded-2xl shadow-lg p-6 border-2 border-gray-100">
        <h4 className="text-lg font-bold text-gray-900 mb-6">Platform Health</h4>
        <div className="space-y-4">
          <div className="flex items-center justify-between p-4 bg-green-50 rounded-lg border border-green-200">
            <span className="text-green-900 font-medium">✓ All systems operational</span>
            <span className="text-green-600 text-sm font-bold">GOOD</span>
          </div>
          <div className="flex items-center justify-between p-4 bg-blue-50 rounded-lg border border-blue-200">
            <span className="text-blue-900 font-medium">📊 Database connection active</span>
            <span className="text-blue-600 text-sm font-bold">ACTIVE</span>
          </div>
          <div className="flex items-center justify-between p-4 bg-yellow-50 rounded-lg border border-yellow-200">
            <span className="text-yellow-900 font-medium">⚠️ Regular backups recommended</span>
            <span className="text-yellow-600 text-sm font-bold">INFO</span>
          </div>
        </div>
      </div>
    </div>
  );
}
