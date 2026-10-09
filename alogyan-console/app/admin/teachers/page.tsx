'use client';

import { useEffect, useState, useMemo } from 'react';
import {
  Edit2,
  Trash2,
  Eye,
  EyeOff,
  Star,
  Plus,
  ChevronLeft,
  ChevronRight,
  UserCircle2
} from 'lucide-react';
import Link from 'next/link';
import Image from 'next/image';
import DirectoryToolbar from '@/components/admin/DirectoryToolbar';
import StatusBadge from '@/components/admin/StatusBadge';
import EmptyState from '@/components/admin/EmptyState';
import ConfirmModal from '@/components/admin/ConfirmModal';

interface Teacher {
  _id: string;
  name: string;
  institution: string;
  profile_image: string;
  rating: number;
  subject: string[];
  location: { city: string };
  is_featured: boolean;
  ad_listing: { active: boolean };
  email: string;
  phone: string[];
  created_at: string;
}

export default function TeachersManagement() {
  const [teachers, setTeachers] = useState<Teacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [serverPage, setServerPage] = useState(1);
  const [hasMore, setHasMore] = useState(false);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<string>('all');
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [selectedTeacher, setSelectedTeacher] = useState<Teacher | null>(null);
  const [actionBusy, setActionBusy] = useState(false);

  const fetchTeachers = async () => {
    try {
      const response = await fetch(`/api/admin/teachers?page=${serverPage}`, {
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to fetch teachers');

      setHasMore(response.headers.get('X-Has-More') === 'true');
      const data = await response.json();
      setTeachers(data);
      setError('');
    } catch (err) {
      setError('Failed to load teachers roster');
      console.error(err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchTeachers();
  }, [serverPage]);

  const handleRefresh = () => {
    setRefreshing(true);
    fetchTeachers();
  };

  // Filtered teachers list based on search and status
  const filteredTeachers = useMemo(() => {
    return teachers.filter((t) => {
      // Search term filter
      if (searchTerm) {
        const term = searchTerm.toLowerCase();
        const matchesName = t.name?.toLowerCase().includes(term);
        const matchesCity = t.location?.city?.toLowerCase().includes(term);
        const matchesSubject = t.subject?.some((s) => s.toLowerCase().includes(term));
        if (!matchesName && !matchesCity && !matchesSubject) return false;
      }

      // Status filter
      if (filterStatus === 'active') return t.ad_listing?.active;
      if (filterStatus === 'featured') return t.is_featured;
      if (filterStatus === 'inactive') return !t.ad_listing?.active;

      return true;
    });
  }, [teachers, searchTerm, filterStatus]);

  const handleToggleFeatured = async (teacherId: string, currentStatus: boolean) => {
    try {
      const response = await fetch('/api/admin/teachers', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          teacherId,
          updates: { is_featured: !currentStatus },
        }),
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to update featured status');

      setTeachers((prev) =>
        prev.map((t) => (t._id === teacherId ? { ...t, is_featured: !currentStatus } : t))
      );
    } catch (err) {
      console.error(err);
      alert('Could not update featured status');
    }
  };

  const handleToggleActive = async (teacherId: string, currentStatus: boolean) => {
    try {
      const response = await fetch('/api/admin/teachers', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          teacherId,
          updates: { 'ad_listing.active': !currentStatus },
        }),
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to update listing status');

      setTeachers((prev) =>
        prev.map((t) =>
          t._id === teacherId
            ? { ...t, ad_listing: { ...t.ad_listing, active: !currentStatus } }
            : t
        )
      );
    } catch (err) {
      console.error(err);
      alert('Could not update listing status');
    }
  };

  const confirmDelete = async () => {
    if (!selectedTeacher) return;
    setActionBusy(true);

    try {
      const response = await fetch('/api/admin/teachers', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teacherId: selectedTeacher._id }),
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to delete teacher profile');

      setTeachers((prev) => prev.filter((t) => t._id !== selectedTeacher._id));
      setShowDeleteModal(false);
      setSelectedTeacher(null);
    } catch (err) {
      console.error(err);
      alert('Failed to delete teacher profile');
    } finally {
      setActionBusy(false);
    }
  };

  return (
    <div className="w-full space-y-4">
      {/* Reusable Directory Toolbar */}
      <DirectoryToolbar
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        searchPlaceholder="Search educators by name, city, or subject..."
        filterValue={filterStatus}
        onFilterChange={setFilterStatus}
        filterOptions={[
          { label: 'All Roster', value: 'all' },
          { label: 'Active Listings', value: 'active' },
          { label: 'Featured Only', value: 'featured' },
          { label: 'Inactive / Suspended', value: 'inactive' },
        ]}
        totalCount={filteredTeachers.length}
        countLabel="educators found"
        onRefresh={handleRefresh}
        refreshing={refreshing}
        actionSlot={
          <Link
            href={'/admin/teachers/new' as any}
            className="inline-flex items-center gap-1.5 px-3 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors whitespace-nowrap"
          >
            <Plus className="h-3.5 w-3.5" />
            <span>Add Educator</span>
          </Link>
        }
      />

      {/* Error alert */}
      {error && (
        <div className="p-3 bg-red-50 border border-red-200/80 rounded-xl text-xs text-red-700 font-medium">
          {error}
        </div>
      )}

      {/* Loading State */}
      {loading ? (
        <div className="text-center py-16 space-y-2">
          <div className="w-8 h-8 border-3 border-gray-200 border-t-[#C91F26] rounded-full animate-spin mx-auto" />
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Syncing Teacher Directory...</p>
        </div>
      ) : !filteredTeachers.length ? (
        <EmptyState
          title="No teachers found"
          description={
            searchTerm
              ? `No educator profiles matched "${searchTerm}".`
              : 'No teachers have been onboarded yet.'
          }
          action={
            <Link
              href={'/admin/teachers/new' as any}
              className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-[#C91F26] text-white text-xs font-semibold rounded-lg shadow-xs"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>Create First Profile</span>
            </Link>
          }
        />
      ) : (
        /* Teachers Table */
        <div className="bg-white border border-gray-200/80 rounded-xl overflow-hidden shadow-xs">
          <div className="overflow-x-auto">
            <table className="w-full text-left text-xs">
              <thead className="bg-gray-50/80 border-b border-gray-200/80 text-[11px] font-bold uppercase tracking-wider text-gray-500">
                <tr>
                  <th className="px-5 py-3">Educator</th>
                  <th className="px-5 py-3">Institution & Location</th>
                  <th className="px-5 py-3">Subjects</th>
                  <th className="px-5 py-3">Rating</th>
                  <th className="px-5 py-3">Status</th>
                  <th className="px-5 py-3 text-right">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100">
                {filteredTeachers.map((teacher) => (
                  <tr key={teacher._id} className="hover:bg-gray-50/60 transition-colors">
                    {/* Educator Identity */}
                    <td className="px-5 py-3.5">
                      <div className="flex items-center gap-3">
                        <div className="w-9 h-9 rounded-full overflow-hidden bg-gray-100 border border-gray-200/80 flex-shrink-0 flex items-center justify-center">
                          {teacher.profile_image ? (
                            <Image
                              src={teacher.profile_image}
                              alt={teacher.name}
                              width={36}
                              height={36}
                              className="w-full h-full object-cover"
                            />
                          ) : (
                            <UserCircle2 className="h-6 w-6 text-gray-400" />
                          )}
                        </div>
                        <div className="min-w-0">
                          <p className="font-bold text-gray-900 truncate font-poppins">{teacher.name}</p>
                          <p className="text-[11px] text-gray-400 truncate">{teacher.email || 'No email specified'}</p>
                        </div>
                      </div>
                    </td>

                    {/* Institution & Location */}
                    <td className="px-5 py-3.5">
                      <p className="font-medium text-gray-800 truncate">{teacher.institution || 'Independent Educator'}</p>
                      <p className="text-[11px] text-gray-400 truncate">{teacher.location?.city || 'Undisclosed City'}</p>
                    </td>

                    {/* Subjects */}
                    <td className="px-5 py-3.5 max-w-[200px]">
                      <div className="flex flex-wrap gap-1">
                        {teacher.subject?.slice(0, 3).map((subj) => (
                          <span
                            key={subj}
                            className="bg-gray-100 text-gray-700 text-[10px] font-medium px-1.5 py-0.5 rounded"
                          >
                            {subj}
                          </span>
                        ))}
                        {(teacher.subject?.length || 0) > 3 && (
                          <span className="text-[10px] text-gray-400 font-medium">
                            +{teacher.subject.length - 3} more
                          </span>
                        )}
                      </div>
                    </td>

                    {/* Rating */}
                    <td className="px-5 py-3.5 whitespace-nowrap">
                      <div className="inline-flex items-center gap-1 font-semibold text-gray-800">
                        <Star className="h-3 w-3 fill-amber-400 text-amber-400" />
                        <span>{teacher.rating ? teacher.rating.toFixed(1) : '0.0'}</span>
                      </div>
                    </td>

                    {/* Status Badges */}
                    <td className="px-5 py-3.5 whitespace-nowrap">
                      <div className="flex items-center gap-1.5 flex-wrap">
                        <StatusBadge status={teacher.ad_listing?.active} />
                        {teacher.is_featured && <StatusBadge variant="featured" label="Featured" />}
                      </div>
                    </td>

                    {/* Actions */}
                    <td className="px-5 py-3.5 text-right whitespace-nowrap">
                      <div className="flex items-center justify-end gap-1">
                        <button
                          onClick={() => handleToggleFeatured(teacher._id, teacher.is_featured)}
                          className={`p-1.5 rounded-lg border transition-colors ${
                            teacher.is_featured
                              ? 'bg-purple-50 text-purple-700 border-purple-200 hover:bg-purple-100'
                              : 'text-gray-400 border-gray-200 hover:text-purple-600 hover:bg-purple-50'
                          }`}
                          title={teacher.is_featured ? 'Remove featured banner' : 'Promote to featured'}
                        >
                          <Star className="h-3.5 w-3.5" />
                        </button>

                        <button
                          onClick={() => handleToggleActive(teacher._id, teacher.ad_listing?.active)}
                          className={`p-1.5 rounded-lg border transition-colors ${
                            teacher.ad_listing?.active
                              ? 'text-gray-400 border-gray-200 hover:text-amber-600 hover:bg-amber-50'
                              : 'bg-emerald-50 text-emerald-700 border-emerald-200 hover:bg-emerald-100'
                          }`}
                          title={teacher.ad_listing?.active ? 'Deactivate listing' : 'Activate listing'}
                        >
                          {teacher.ad_listing?.active ? (
                            <EyeOff className="h-3.5 w-3.5" />
                          ) : (
                            <Eye className="h-3.5 w-3.5" />
                          )}
                        </button>

                        <button
                          onClick={() => {
                            setSelectedTeacher(teacher);
                            setShowDeleteModal(true);
                          }}
                          className="p-1.5 text-gray-400 hover:text-rose-600 hover:bg-rose-50 border border-gray-200 rounded-lg transition-colors"
                          title="Delete educator profile"
                        >
                          <Trash2 className="h-3.5 w-3.5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {/* Pagination bar */}
          <div className="p-3 bg-gray-50/70 border-t border-gray-100 flex items-center justify-between text-xs text-gray-500">
            <span>
              Page <strong className="text-gray-900 font-bold">{serverPage}</strong>
            </span>
            <div className="flex items-center gap-1.5">
              <button
                disabled={serverPage === 1 || loading}
                onClick={() => setServerPage((p) => p - 1)}
                className="inline-flex items-center gap-1 px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 hover:bg-gray-50 disabled:opacity-40 transition-colors shadow-xs"
              >
                <ChevronLeft className="h-3.5 w-3.5" />
                <span>Previous</span>
              </button>
              <button
                disabled={!hasMore || loading}
                onClick={() => setServerPage((p) => p + 1)}
                className="inline-flex items-center gap-1 px-3 py-1.5 bg-white border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 hover:bg-gray-50 disabled:opacity-40 transition-colors shadow-xs"
              >
                <span>Next</span>
                <ChevronRight className="h-3.5 w-3.5" />
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Reusable Confirmation Modal */}
      <ConfirmModal
        isOpen={showDeleteModal}
        onClose={() => {
          setShowDeleteModal(false);
          setSelectedTeacher(null);
        }}
        onConfirm={confirmDelete}
        title="Delete Educator Profile"
        message={`Are you sure you want to permanently delete "${selectedTeacher?.name}"? This will remove all associated profile data and public listings.`}
        confirmLabel="Delete Educator"
        danger={true}
        loading={actionBusy}
      />
    </div>
  );
}
