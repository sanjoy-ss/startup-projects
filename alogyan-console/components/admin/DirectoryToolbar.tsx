'use client';

import React from 'react';
import { Search, X, Filter, RefreshCw } from 'lucide-react';

export interface FilterOption {
  label: string;
  value: string;
}

interface DirectoryToolbarProps {
  searchTerm: string;
  onSearchChange: (value: string) => void;
  searchPlaceholder?: string;
  filterValue?: string;
  onFilterChange?: (value: string) => void;
  filterOptions?: FilterOption[];
  totalCount?: number;
  countLabel?: string;
  actionSlot?: React.ReactNode;
  onRefresh?: () => void;
  refreshing?: boolean;
}

export default function DirectoryToolbar({
  searchTerm,
  onSearchChange,
  searchPlaceholder = 'Search records...',
  filterValue,
  onFilterChange,
  filterOptions,
  totalCount,
  countLabel = 'records found',
  actionSlot,
  onRefresh,
  refreshing = false,
}: DirectoryToolbarProps) {
  return (
    <div className="bg-white border border-gray-200/80 rounded-xl p-3.5 shadow-xs flex flex-col md:flex-row items-stretch md:items-center justify-between gap-3">
      {/* Left: Search & Filter inputs */}
      <div className="flex flex-1 items-center gap-2.5 min-w-0">
        {/* Search Field */}
        <div className="relative flex-1 min-w-[200px]">
          <Search className="absolute left-3 top-1/2 -translate-y-1/2 h-4 w-4 text-gray-400 pointer-events-none" />
          <input
            type="text"
            value={searchTerm}
            onChange={(e) => onSearchChange(e.target.value)}
            placeholder={searchPlaceholder}
            className="w-full pl-9 pr-8 py-2 text-xs bg-gray-50/70 hover:bg-gray-50 focus:bg-white border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] transition-colors"
          />
          {searchTerm && (
            <button
              onClick={() => onSearchChange('')}
              className="absolute right-2.5 top-1/2 -translate-y-1/2 text-gray-400 hover:text-gray-600 p-0.5 rounded"
              title="Clear search"
            >
              <X className="h-3.5 w-3.5" />
            </button>
          )}
        </div>

        {/* Filter Dropdown */}
        {filterOptions && onFilterChange && (
          <div className="relative flex-shrink-0">
            <select
              value={filterValue}
              onChange={(e) => onFilterChange(e.target.value)}
              className="py-2 pl-3 pr-8 text-xs font-medium bg-gray-50/70 border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26] text-gray-700 cursor-pointer"
            >
              {filterOptions.map((opt) => (
                <option key={opt.value} value={opt.value}>
                  {opt.label}
                </option>
              ))}
            </select>
          </div>
        )}
      </div>

      {/* Right: Count indicator & Actions */}
      <div className="flex items-center justify-between md:justify-end gap-3 flex-shrink-0">
        {typeof totalCount === 'number' && (
          <span className="text-xs text-gray-500 font-medium whitespace-nowrap">
            <strong className="text-gray-900 font-bold">{totalCount}</strong> {countLabel}
          </span>
        )}

        {onRefresh && (
          <button
            onClick={onRefresh}
            disabled={refreshing}
            className="p-2 text-gray-500 hover:text-gray-800 hover:bg-gray-100 border border-gray-200 rounded-lg transition-colors disabled:opacity-50"
            title="Refresh"
            aria-label="Refresh list"
          >
            <RefreshCw className={`h-3.5 w-3.5 ${refreshing ? 'animate-spin' : ''}`} />
          </button>
        )}

        {actionSlot}
      </div>
    </div>
  );
}
