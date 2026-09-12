'use client';

import { useEffect, useState } from 'react';
import {
  Search,
  Trash2,
  MessageSquare,
  Star,
  User,
  Calendar,
  AlertCircle,
  Check,
  X
} from 'lucide-react';

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
  const [filteredReviews, setFilteredReviews] = useState<Review[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterRating, setFilterRating] = useState<'all' | number>('all');
  const [showDeleteModal, setShowDeleteModal] = useState(false);
  const [selectedReview, setSelectedReview] = useState<Review | null>(null);

  useEffect(() => {
    fetchReviews();
  }, []);

  useEffect(() => {
    filterReviews();
  }, [reviews, searchTerm, filterRating]);

  const fetchReviews = async () => {
    try {
      const response = await fetch('/api/admin/reviews', {
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to fetch reviews');

      const data = await response.json();
      setReviews(data);
    } catch (err) {
      setError('Failed to load reviews');
      console.error(err);
    } finally {
      setLoading(false);
    }
  };

  const filterReviews = () => {
    let filtered = [...reviews];

    // Search filter
    if (searchTerm) {
      filtered = filtered.filter(r =>
        r.teacher_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.author_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.title.toLowerCase().includes(searchTerm.toLowerCase()) ||
        r.body.toLowerCase().includes(searchTerm.toLowerCase())
      );
    }

    // Rating filter
    if (filterRating !== 'all') {
      filtered = filtered.filter(r => r.rating === filterRating);
    }

    setFilteredReviews(filtered);
  };

  const handleDelete = async () => {
    if (!selectedReview) return;

    try {
      const response = await fetch('/api/admin/reviews', {
        method: 'DELETE',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ reviewId: selectedReview._id }),
        credentials: 'include'
      });

      if (!response.ok) throw new Error('Failed to delete');

      setReviews(reviews.filter(r => r._id !== selectedReview._id));
      setShowDeleteModal(false);
      setSelectedReview(null);
    } catch (err) {
      console.error('Error deleting:', err);
      alert('Failed to delete review');
    }
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('en-US', {
      year: 'numeric',
      month: 'short',
      day: 'numeric'
    });
  };

  const getRatingColor = (rating: number) => {
    if (rating >= 4) return 'text-green-600 bg-green-100';
    if (rating >= 3) return 'text-yellow-600 bg-yellow-100';
    return 'text-red-600 bg-red-100';
  };

  return (
    <div className="space-y-6">
      {/* Header */}
      <div>
        <h2 className="text-3xl font-bold text-gray-900">Reviews Management</h2>
        <p className="text-gray-600 mt-1">{filteredReviews.length} reviews found</p>
      </div>

      {/* Search and Filters */}
      <div className="bg-white rounded-2xl shadow-lg p-6">
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2">Search</label>
            <div className="relative">
              <Search className="absolute left-4 top-1/2 -translate-y-1/2 h-5 w-5 text-gray-400" />
              <input
                type="text"
                value={searchTerm}
                onChange={(e) => setSearchTerm(e.target.value)}
                placeholder="Search by teacher, author, or content..."
                className="w-full pl-12 pr-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              />
            </div>
          </div>

          <div>
            <label className="block text-sm font-semibold text-gray-700 mb-2" title="Filter by rating">Filter by Rating</label>
            <select
              value={filterRating}
              onChange={(e) => setFilterRating(e.target.value === 'all' ? 'all' : Number(e.target.value))}
              className="w-full px-4 py-3 border-2 border-gray-200 rounded-xl focus:outline-none focus:border-brand-coral"
              title="Filter reviews by rating"
            >
              <option value="all">All Ratings</option>
              <option value="5">⭐⭐⭐⭐⭐ 5 Stars</option>
              <option value="4">⭐⭐⭐⭐ 4 Stars</option>
              <option value="3">⭐⭐⭐ 3 Stars</option>
              <option value="2">⭐⭐ 2 Stars</option>
              <option value="1">⭐ 1 Star</option>
            </select>
          </div>
        </div>
      </div>

      {/* Reviews List */}
      {loading ? (
        <div className="text-center py-12">
          <div className="w-12 h-12 border-4 border-brand-coral/30 border-t-brand-coral rounded-full animate-spin mx-auto mb-4"></div>
          <p className="text-gray-600">Loading reviews...</p>
        </div>
      ) : error ? (
        <div className="bg-red-50 border border-red-200 rounded-xl p-6 text-red-700">{error}</div>
      ) : filteredReviews.length === 0 ? (
        <div className="bg-white rounded-2xl shadow-lg p-12 text-center">
          <MessageSquare className="h-16 w-16 text-gray-300 mx-auto mb-4" />
          <p className="text-gray-600 text-lg">No reviews found</p>
        </div>
      ) : (
        <div className="space-y-4">
          {filteredReviews.map((review) => (
            <div key={review._id} className="bg-white rounded-2xl shadow-lg p-6 border-l-4 border-brand-coral hover:shadow-xl transition-all">
              {/* Header */}
              <div className="flex items-start justify-between mb-4">
                <div className="flex-1">
                  <div className="flex items-center gap-3 mb-2">
                    <h3 className="text-lg font-bold text-gray-900">{review.teacher_name}</h3>
                    <div className={`flex items-center gap-1 px-3 py-1 rounded-full font-bold text-sm ${getRatingColor(review.rating)}`}>
                      <Star className="h-4 w-4 fill-current" />
                      {review.rating}
                    </div>
                  </div>
                  <div className="flex items-center gap-4 text-sm text-gray-600 flex-wrap">
                    <div className="flex items-center gap-1">
                      <User className="h-4 w-4" />
                      <span>{review.author_name || 'Anonymous'}</span>
                    </div>
                    <div className="flex items-center gap-1">
                      <Calendar className="h-4 w-4" />
                      <span>{formatDate(review.created_at)}</span>
                    </div>
                  </div>
                </div>

                <button
                  onClick={() => {
                    setSelectedReview(review);
                    setShowDeleteModal(true);
                  }}
                  className="p-2 text-gray-600 hover:bg-red-100 hover:text-red-600 rounded-lg transition-colors"
                  title="Delete review"
                >
                  <Trash2 className="h-5 w-5" />
                </button>
              </div>

              {/* Review Content */}
              <div className="bg-gray-50 rounded-xl p-4 mb-4">
                {review.title && (
                  <h4 className="font-bold text-gray-900 mb-2">{review.title}</h4>
                )}
                <p className="text-gray-700 text-sm leading-relaxed">{review.body}</p>
              </div>

              {/* Footer */}
              <div className="flex items-center gap-2">
                <Check className="h-5 w-5 text-green-600" />
                <span className="text-xs text-gray-500 font-medium">Approved & Published</span>
              </div>
            </div>
          ))}
        </div>
      )}

      {/* Delete Modal */}
      {showDeleteModal && selectedReview && (
        <div className="fixed inset-0 bg-black/50 flex items-center justify-center z-50 p-4">
          <div className="bg-white rounded-2xl shadow-2xl max-w-md w-full p-6">
            <h3 className="text-2xl font-bold text-gray-900 mb-2">Delete Review?</h3>
            <p className="text-gray-600 mb-2">
              Are you sure you want to delete the review from <strong>{selectedReview.author_name || 'Anonymous'}</strong>?
            </p>
            <p className="text-gray-600 mb-6 text-sm">This action cannot be undone.</p>
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
