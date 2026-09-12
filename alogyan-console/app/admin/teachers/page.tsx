'use client';

import { useEffect, useState } from 'react';
import {
  Search,
  Edit2,
  Trash2,
  Eye,
  EyeOff,
  Star,
  Check,
  X,
  Plus,
  Filter,
  Download
} from 'lucide-react';
import Link from 'next/link';
import Image from 'next/image';

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
  const [filteredTeachers, setFilteredTeachers] = useState<Teacher[]>([]);
  const [loading, setLoading] = useState(true);
  const [serverPage, setServerPage] = useState(1);
  const [hasMore, setHasMore] = useState(false);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterStatus, setFilterStatus] = useState<'all' | 'active' | 'featured'>('all');
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [selectedTeacher, setSelectedTeacher] = useState<Teacher | null>(null);

  useEffect(() => {
    fetchTeachers();
  }, [serverPage]);

  useEffect(() => {
    filterTeachers();
  }, [teachers, searchTerm, filterStatus]);

  const fetchTeachers = async () => {
    try {
      const response = await fetch(`/api/admin/teachers?page=${serverPage}`, {
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to fetch teachers');

      setHasMore(response.headers.get('X-Has-More') === 'true');
      const data = await response.json();
      setTeachers(data);
    } catch (err) {
      setError('Failed to load teachers');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const filterTeachers = () => {
    let filtered = [...teachers];

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(t =>
        t.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        t.location.city.toLowerCase().includes(searchTerm.toLowerCase()) ||
        t.subject.some(s => s.toLowerCase().includes(searchTerm.toLowerCase()))
      );
    }

    // Status filter
    if (filterStatus === 'active') {
      filtered = filtered.filter(t => t.ad_listing.active);
    } else if (filterStatus === 'featured') {
      filtered = filtered.filter(t => t.is_featured);
    }

    setFilteredTeachers(filtered);
  };

  const handleToggleFeatured = async (teacherId: string, isFeatured: boolean) => {
    try {
      const response = await fetch('/api/admin/teachers', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teacherId, is_featured: !isFeatured }),
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to update');

      setTeachers(teachers.map(t =>
        t._id === teacherId ? { ...t, is_featured: !isFeatured } : t
      ));
    } catch (err) {
      console.error('Error toggling featured:', err);
      alert('Failed to update teacher');
    }
  };

  const handleToggleActive = async (teacherId: string, isActive: boolean) => {
    try {
      const response = await fetch('/api/admin/teachers', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teacherId, 'ad_listing.active': !isActive }),
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to update');

      setTeachers(teachers.map(t =>
        t._id === teacherId
          ? { ...t, ad_listing: { ...t.ad_listing, active: !isActive } }
          : t
      ));
    } catch (err) {
      console.error('Error toggling active:', err);
      alert('Failed to update teacher');
    }
  };

  const handleDelete = async () => {
    if (!selectedTeacher) return;

    try {
      const response = await fetch('/api/admin/teachers', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ teacherId: selectedTeacher._id }),
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to delete');

      setTeachers(teachers.filter(t => t._id !== selectedTeacher._id));
      setShowDeleteModal(false);
      setSelectedTeacher(null);
    } catch (err) {
      console.error('Error deleting:', err);
      alert('Failed to delete teacher');
    }
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3"><button className="border rounded px-3 py-2" disabled={serverPage===1 || loading} onClick={()=>setServerPage(p=>p-1)}>Previous</button><span>Page {serverPage} · Filters apply to this page</span><button className="border rounded px-3 py-2" disabled={!hasMore || loading} onClick={()=>setServerPage(p=>p+1)}>Next</button></div>
      {/* Header */}
      <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
        <div>
          <h2 className="text-3xl font-bold text-gray-900">Teachers Management</h2>
          <p className="text-gray-600 mt-1">{filteredTeachers.length} teachers found</p>
        </div>
        <Link
          href={"/admin/teachers/new" as any}
          className="inline-flex items-center gap-2 px-6 py-3 bg-brand-gradient text-white font-bold rounded-xl hover:shadow-lg transition-all"
        >
          <Plus className="h-5 w-5" />
          Add New Teacher
        </Link>
      </div>

      {/* Search and Filters */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          <div className="lg:col-span-2">
            <label className="block text-sm font-semibold text-gray-700 mb-2">Search</label>
            <div className="relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search by name, city, or subject..."
                className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2" htmlFor="teacher-filter">
              Filter
            </label>
            <select
              id="teacher-filter"
              value={filterStatus}
              onChange={(e) => setFilterStatus(e.target.value as any)}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              title="Filter teachers"
            >
              <option value="all">All Teachers</option>
              <option value="active">Active Only</option>
              <option value="featured">Featured Only</option>
            </select>
          </div>
        </div>
      </div>

      {/* Teachers Table */}
      {loading ? (
        <div className="text-center py-12">
          <div className="w-12 h-12 border-4 border-brand-coral/30 border-t-brand-coral rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Loading teachers...</p>
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-red-700">{error}</div>
      ) : (
        <div className="bg-white rounded-2xl shadow-lg overflow-hidden">
          <div className="overflow-x-auto">
            <table className="w-full">
              <thead>
                <tr className="bg-gray-50 border-b border-gray-200">
                  <th className="px-6 py-4 text-left text-sm font-bold text-gray-900">Teacher</th>
                  <th className="px-6 py-4 text-left text-sm font-bold text-gray-900">Location</th>
                  <th className="px-6 py-4 text-left text-sm font-bold text-gray-900">Subjects</th>
                  <th className="px-6 py-4 text-left text-sm font-bold text-gray-900">Rating</th>
                  <th className="px-6 py-4 text-left text-sm font-bold text-gray-900">Status</th>
                  <th className="px-6 py-4 text-left text-sm font-bold text-gray-900">Actions</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-200">
                {filteredTeachers.map((teacher) => (
                  <tr key={teacher._id} className="hover:bg-gray-50 transition-colors">
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-3">
                        {teacher.profile_image && (
                          <Image
                            src={teacher.profile_image}
                            alt={teacher.name}
                            width={40}
                            height={40}
                            className="w-10 h-10 rounded-full object-cover"
                          />
                        )}
                        <div>
                          <p className="font-semibold text-gray-900">{teacher.name}</p>
                          <p className="text-sm text-gray-600">{teacher.institution}</p>
                        </div>
                      </div>
                    </td>
                    <td className="px-6 py-4 text-sm text-gray-600">{teacher.location.city}</td>
                    <td className="px-6 py-4">
                      <div className="flex flex-wrap gap-2">
                        {teacher.subject.slice(0, 2).map((s) => (
                          <span key={s} className="bg-brand-coral/10 text-brand-coral text-xs font-bold px-2 py-1 rounded">
                            {s}
                          </span>
                        ))}
                        {teacher.subject.length > 2 && (
                          <span className="text-xs text-gray-600">+{teacher.subject.length - 2}</span>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-1">
                        <Star className="h-4 w-4 fill-yellow-400 text-yellow-400" />
                        <span className="font-bold text-gray-900">{teacher.rating.toFixed(1)}</span>
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        {teacher.is_featured && (
                          <span className="bg-purple-100 text-purple-700 text-xs font-bold px-3 py-1 rounded-full">
                            ⭐ Featured
                          </span>
                        )}
                        {teacher.ad_listing.active && (
                          <span className="bg-green-100 text-green-700 text-xs font-bold px-3 py-1 rounded-full">
                            ✓ Active
                          </span>
                        )}
                      </div>
                    </td>
                    <td className="px-6 py-4">
                      <div className="flex items-center gap-2">
                        <button
                          onClick={() => handleToggleFeatured(teacher._id, teacher.is_featured)}
                          className="p-2 text-gray-600 hover:bg-purple-100 hover:text-purple-600 rounded-lg transition-colors"
                          title={teacher.is_featured ? 'Unfeature' : 'Feature'}
                        >
                          <Star className={`h-5 w-5 ${teacher.is_featured ? 'fill-purple-600 text-purple-600' : ''}`} />
                        </button>
                        <button
                          onClick={() => handleToggleActive(teacher._id, teacher.ad_listing.active)}
                          className="p-2 text-gray-600 hover:bg-green-100 hover:text-green-600 rounded-lg transition-colors"
                          title={teacher.ad_listing.active ? 'Deactivate' : 'Activate'}
                        >
                          {teacher.ad_listing.active ? (
                            <Eye className="h-5 w-5 text-green-600" />
                          ) : (
                            <EyeOff className="h-5 w-5" />
                          )}
                        </button>
                        <Link
                          href={`/admin/teachers/${teacher._id}` as any}
                          className="p-2 text-gray-600 hover:bg-blue-100 hover:text-blue-600 rounded-lg transition-colors"
                          title="Edit"
                        >
                          <Edit2 className="h-5 w-5" />
                        </Link>
                        <button
                          onClick={() => {
                            setSelectedTeacher(teacher);
                            setShowDeleteModal(true);
                          }}
                          className="p-2 text-gray-600 hover:bg-red-100 hover:text-red-600 rounded-lg transition-colors"
                          title="Delete"
                        >
                          <Trash2 className="h-5 w-5" />
                        </button>
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>

          {filteredTeachers.length === 0 && (
            <div className="text-center py-12">
              <p className="text-gray-600">No teachers found matching your criteria</p>
            </div>
          )}
        </div>
      )}

      {/* Delete Modal */}
      {showDeleteModal && selectedTeacher && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
            <h3 className="text-2xl font-bold text-gray-900 mb-2">Delete Teacher?</h3>
            <p className="text-gray-600 mb-6">
              Are you sure you want to delete <strong>{selectedTeacher.name}</strong>? This action cannot be undone.
            </p>
            <div className="flex gap-4">
              <button
                onClick={() => setShowDeleteModal(false)}
                className="flex-1 px-4 py-3 border-2 border-gray-200 rounded-xl font-bold text-gray-900 hover:bg-gray-50 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={handleDelete}
                className="flex-1 px-4 py-3 bg-red-600 text-white rounded-xl font-bold hover:bg-red-700 transition-colors"
              >
                Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
