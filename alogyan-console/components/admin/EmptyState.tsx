'use client';

import React from 'react';
import { SearchX, Inbox } from 'lucide-react';

interface EmptyStateProps {
  icon?: React.ComponentType<{ className?: string }>;
  title: string;
  description?: string;
  action?: React.ReactNode;
}

export default function EmptyState({
  icon: Icon = Inbox,
  title,
  description,
  action,
}: EmptyStateProps) {
  return (
    <div className="bg-white border border-gray-200/80 rounded-xl p-10 text-center flex flex-col items-center justify-center space-y-3 shadow-xs">
      <div className="w-12 h-12 rounded-xl bg-gray-50 border border-gray-200/70 flex items-center justify-center text-gray-400">
        <Icon className="h-6 w-6" />
      </div>
      <div className="max-w-md space-y-1">
        <h4 className="text-sm font-bold text-gray-900 font-poppins">{title}</h4>
        {description && (
          <p className="text-xs text-gray-500 leading-relaxed">{description}</p>
        )}
      </div>
      {action && <div className="pt-2">{action}</div>}
    </div>
  );
}
