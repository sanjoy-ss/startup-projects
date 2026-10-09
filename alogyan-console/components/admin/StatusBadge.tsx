'use client';

import React from 'react';
import { Check, Star, AlertCircle, Clock } from 'lucide-react';

export type BadgeVariant = 'active' | 'featured' | 'pending' | 'suspended' | 'inactive' | 'info';

interface StatusBadgeProps {
  status?: string | boolean | null;
  variant?: BadgeVariant;
  label?: string;
  size?: 'sm' | 'md';
}

export default function StatusBadge({ status, variant, label, size = 'sm' }: StatusBadgeProps) {
  // Normalize variant from status string if not explicitly given
  const normalizedVariant: BadgeVariant = variant || (() => {
    if (typeof status === 'boolean') return status ? 'active' : 'inactive';
    const s = String(status || '').toLowerCase();
    if (['active', 'approved', 'live', 'good', 'success'].includes(s)) return 'active';
    if (['featured', 'promoted'].includes(s)) return 'featured';
    if (['pending', 'publishing', 'draft', 'review'].includes(s)) return 'pending';
    if (['suspended', 'inactive', 'revoked', 'rejected', 'deleted'].includes(s)) return 'inactive';
    return 'info';
  })();

  const textLabel = label || (typeof status === 'boolean' ? (status ? 'Active' : 'Inactive') : String(status || 'Active'));

  const sizeClasses = size === 'md' ? 'px-2.5 py-1 text-xs' : 'px-2 py-0.5 text-[11px]';

  switch (normalizedVariant) {
    case 'active':
      return (
        <span className={`inline-flex items-center gap-1.5 font-semibold bg-emerald-50 text-emerald-700 border border-emerald-200/60 rounded-full ${sizeClasses}`}>
          <span className="w-1.5 h-1.5 rounded-full bg-emerald-500" />
          <span className="capitalize">{textLabel}</span>
        </span>
      );
    case 'featured':
      return (
        <span className={`inline-flex items-center gap-1 font-semibold bg-purple-50 text-purple-700 border border-purple-200/60 rounded-full ${sizeClasses}`}>
          <Star className="h-3 w-3 fill-purple-500 text-purple-500" />
          <span className="capitalize">{textLabel}</span>
        </span>
      );
    case 'pending':
      return (
        <span className={`inline-flex items-center gap-1.5 font-semibold bg-amber-50 text-amber-700 border border-amber-200/60 rounded-full ${sizeClasses}`}>
          <Clock className="h-3 w-3 text-amber-600" />
          <span className="capitalize">{textLabel}</span>
        </span>
      );
    case 'inactive':
    case 'suspended':
      return (
        <span className={`inline-flex items-center gap-1.5 font-semibold bg-rose-50 text-rose-700 border border-rose-200/60 rounded-full ${sizeClasses}`}>
          <span className="w-1.5 h-1.5 rounded-full bg-rose-400" />
          <span className="capitalize">{textLabel}</span>
        </span>
      );
    case 'info':
    default:
      return (
        <span className={`inline-flex items-center gap-1 font-semibold bg-gray-100 text-gray-700 border border-gray-200 rounded-full ${sizeClasses}`}>
          <span className="capitalize">{textLabel}</span>
        </span>
      );
  }
}
