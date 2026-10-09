'use client';

import { useEffect, useState, useMemo } from 'react';
import {
  Trash2,
  Star,
  User,
  Calendar,
  MessageSquare
} from 'lucide-react';
import DirectoryToolbar from '@/components/admin/DirectoryToolbar';
import EmptyState from '@/components/admin/EmptyState';
import ConfirmModal from '@/components/admin/ConfirmModal';

interface Review {
  _id: string;
  teacher_slug: string;
  teacher_name: string;
  rating: number;
  title: string;
  body: string;
  author_name: string;
  created_at: string;
}

export default function ReviewsManagement() {
  const [reviews, setReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterRating, setFilterRating] = useState<string>('all');
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [selectedReview, setSelectedReview] = useState<Review | null>(null);
  const [deleteBusy, setDeleteBusy] = useState(false);

  const fetchReviews = async () => {
    try {
      const response = await fetch('/api/admin/reviews', {
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to fetch reviews');

      const data = await response.json();
      setReviews(data);
      setError('');
    } catch (err) {
      setError('Failed to load reviews dataset');
      console.error(err);
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    fetchReviews();
  }, []);

  const handleRefresh = () => {
    setRefreshing(true);
    fetchReviews();
  };

  const filteredReviews = useMemo(() => {
    return reviews.filter((r) => {
      if (searchTerm) {
        const term = searchTerm.toLowerCase();
        const matchesTeacher = r.teacher_name?.toLowerCase().includes(term);
        const matchesAuthor = r.author_name?.toLowerCase().includes(term);
        const matchesTitle = r.title?.toLowerCase().includes(term);
        const matchesBody = r.body?.toLowerCase().includes(term);
        if (!matchesTeacher && !matchesAuthor && !matchesTitle && !matchesBody) return false;
      }

      if (filterRating !== 'all') {
        if (r.rating !== Number(filterRating)) return false;
      }

      return true;
    });
  }, [reviews, searchTerm, filterRating]);

  const confirmDelete = async () => {
    if (!selectedReview) return;
    setDeleteBusy(true);

    try {
      const response = await fetch('/api/admin/reviews', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reviewId: selectedReview._id }),
        credentials: 'include',
      });

      if (!response.ok) throw new Error('Failed to delete review');

      setReviews((prev) => prev.filter((r) => r._id !== selectedReview._id));
      setShowDeleteModal(false);
      setSelectedReview(null);
    } catch (err) {
      console.error(err);
      alert('Failed to delete review');
    } finally {
      setDeleteBusy(false);
    }
  };

  return (
    <div className="w-full space-y-4">
      {/* Reusable Directory Toolbar */}
      <DirectoryToolbar
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        searchPlaceholder="Search reviews by student, teacher, or content keywords..."
        filterValue={filterRating}
        onFilterChange={setFilterRating}
        filterOptions={[
          { label: 'All Ratings', value: 'all' },
          { label: '5 Stars Only', value: '5' },
          { label: '4 Stars Only', value: '4' },
          { label: '3 Stars Only', value: '3' },
          { label: '2 Stars & Below', value: '2' },
          { label: '1 Star Only', value: '1' },
        ]}
        totalCount={filteredReviews.length}
        countLabel="reviews moderated"
        onRefresh={handleRefresh}
        refreshing={refreshing}
      />

      <p className="text-xs text-gray-500 leading-relaxed px-1">
        Moderate public student testimonials, ratings, and feedback submitted across educator profiles.
      </p>

      {/* Error alert */}
      {error && (
        <div role="alert" className="p-3 bg-red-50 border border-red-200/80 rounded-xl text-xs text-red-700 font-medium">
          {error}
        </div>
      )}

      {/* Loading State */}
      {loading ? (
        <div className="text-center py-16 space-y-2">
          <div className="w-8 h-8 border-3 border-gray-200 border-t-[#C91F26] rounded-full animate-spin mx-auto" />
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Syncing Student Reviews...</p>
        </div>
      ) : !filteredReviews.length ? (
        <EmptyState
          icon={MessageSquare}
          title="No reviews found"
          description={
            searchTerm
              ? `No student feedback matched your search "${searchTerm}".`
              : 'No reviews have been submitted for moderation yet.'
          }
        />
      ) : (
        /* Review Cards Grid */
        <div className="grid gap-4">
          {filteredReviews.map((review) => (
            <article
              key={review._id}
              className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs hover:border-gray-300 transition-all space-y-3"
            >
              <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2.5 border-b border-gray-100">
                <div className="flex items-center gap-2.5 flex-wrap">
                  <div className="flex items-center gap-1">
                    {[1, 2, 3, 4, 5].map((star) => (
                      <Star
                        key={star}
                        className={`h-3.5 w-3.5 ${
                          star <= review.rating
                            ? 'fill-amber-400 text-amber-400'
                            : 'text-gray-200'
                        }`}
                      />
                    ))}
                  </div>

                  <span className="text-xs font-bold text-gray-900 font-poppins">
                    {review.title || 'Review without title'}
                  </span>
                </div>

                <div className="flex items-center gap-3 text-xs text-gray-500">
                  <span className="flex items-center gap-1">
                    <User className="h-3 w-3 text-gray-400" />
                    <strong>{review.author_name || 'Anonymous Student'}</strong>
                  </span>

                  <span className="flex items-center gap-1 text-gray-400">
                    <Calendar className="h-3 w-3" />
                    {review.created_at
                      ? new Date(review.created_at).toLocaleDateString()
                      : 'Recent'}
                  </span>
                </div>
              </div>

              <div className="text-xs">
                <span className="text-gray-400">Educator: </span>
                <span className="font-semibold text-gray-800 bg-gray-50 px-2 py-0.5 rounded border border-gray-200/60">
                  {review.teacher_name || review.teacher_slug}
                </span>
              </div>

              <p className="text-xs text-gray-600 leading-relaxed bg-gray-50/60 p-3 rounded-lg border border-gray-100">
                {review.body}
              </p>

              <div className="flex items-center justify-end pt-1">
                <button
                  onClick={() => {
                    setSelectedReview(review);
                    setShowDeleteModal(true);
                  }}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold text-rose-700 hover:text-white hover:bg-rose-600 border border-rose-200 rounded-lg transition-colors"
                >
                  <Trash2 className="h-3.5 w-3.5" />
                  <span>Delete Review</span>
                </button>
              </div>
            </article>
          ))}
        </div>
      )}

      {/* Confirmation Modal */}
      <ConfirmModal
        isOpen={showDeleteModal}
        onClose={() => {
          setShowDeleteModal(false);
          setSelectedReview(null);
        }}
        onConfirm={confirmDelete}
        title="Remove Review"
        message={`Are you sure you want to permanently delete this review by "${selectedReview?.author_name}"? This action cannot be undone.`}
        confirmLabel="Delete Review"
        danger={true}
        loading={deleteBusy}
      />
    </div>
  );
}
