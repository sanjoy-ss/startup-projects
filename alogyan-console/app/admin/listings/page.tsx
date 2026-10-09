'use client';

import { useEffect, useState, useMemo } from 'react';
import { BadgeCheck, Globe, CheckCircle2, RotateCw } from 'lucide-react';
import DirectoryToolbar from '@/components/admin/DirectoryToolbar';
import StatusBadge from '@/components/admin/StatusBadge';
import EmptyState from '@/components/admin/EmptyState';

interface Draft {
  id: string;
  revision: number;
  status: string;
  publicFields: {
    name: string;
    slug: string;
    city: string;
    subject: string[];
    description: string;
  };
}

export default function ProfileApprovalsPage() {
  const [items, setItems] = useState<Draft[]>([]);
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [error, setError] = useState('');
  const [busyId, setBusyId] = useState<string | null>(null);
  const [searchTerm, setSearchTerm] = useState('');

  const load = async () => {
    try {
      const r = await fetch('/api/admin/listings', { credentials: 'include' });
      const d = await r.json();
      if (!r.ok) throw new Error(d.error || 'Failed to fetch pending listings');
      setItems(d.items || []);
      setError('');
    } catch {
      setError('Could not load profile approvals queue');
    } finally {
      setLoading(false);
      setRefreshing(false);
    }
  };

  useEffect(() => {
    void load();
  }, []);

  const handleRefresh = () => {
    setRefreshing(true);
    void load();
  };

  const handleApprove = async (draft: Draft) => {
    setBusyId(draft.id);
    setError('');
    try {
      const r = await fetch('/api/admin/listings', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ id: draft.id, revision: draft.revision }),
        credentials: 'include',
      });
      if (!r.ok) throw new Error();
      await load();
    } catch {
      setError('Publication failed. Please verify that the profile slug is unique and retry.');
    } finally {
      setBusyId(null);
    }
  };

  const filteredItems = useMemo(() => {
    if (!searchTerm) return items;
    const term = searchTerm.toLowerCase();
    return items.filter(
      (d) =>
        d.publicFields?.name?.toLowerCase().includes(term) ||
        d.publicFields?.city?.toLowerCase().includes(term) ||
        d.publicFields?.slug?.toLowerCase().includes(term) ||
        d.publicFields?.subject?.some((s) => s.toLowerCase().includes(term))
    );
  }, [items, searchTerm]);

  return (
    <div className="w-full space-y-4">
      {/* Reusable Toolbar */}
      <DirectoryToolbar
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        searchPlaceholder="Filter verification queue by name, city, or subject..."
        totalCount={filteredItems.length}
        countLabel="profiles pending review"
        onRefresh={handleRefresh}
        refreshing={refreshing}
      />

      <p className="text-xs text-gray-500 leading-relaxed px-1">
        Review customer-submitted public educator listings before making them live on the public directory. Student data is never exposed.
      </p>

      {/* Error notification */}
      {error && (
        <div role="alert" className="p-3.5 bg-red-50 border border-red-200/80 rounded-xl text-xs text-red-700 font-medium">
          {error}
        </div>
      )}

      {/* Loading state */}
      {loading ? (
        <div className="text-center py-16 space-y-2">
          <div className="w-8 h-8 border-3 border-gray-200 border-t-[#C91F26] rounded-full animate-spin mx-auto" />
          <p className="text-xs font-semibold text-gray-500 uppercase tracking-wider">Loading Verification Queue...</p>
        </div>
      ) : !filteredItems.length ? (
        <EmptyState
          icon={CheckCircle2}
          title="Verification Queue Clear"
          description={
            searchTerm
              ? `No pending profiles matched "${searchTerm}".`
              : 'All submitted educator profiles have been reviewed and published.'
          }
        />
      ) : (
        /* Profiles Cards */
        <div className="grid gap-4">
          {filteredItems.map((draft) => {
            const isBusy = busyId === draft.id;
            return (
              <article
                key={draft.id}
                className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs hover:border-gray-300 transition-all space-y-3"
              >
                <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-2 pb-2 border-b border-gray-100">
                  <div className="flex items-center gap-2.5">
                    <h3 className="text-sm font-bold text-gray-900 font-poppins">
                      {draft.publicFields.name}
                    </h3>
                    <StatusBadge
                      status={draft.status === 'publishing' ? 'pending' : 'pending'}
                      label={draft.status === 'publishing' ? 'Publishing...' : 'Pending Review'}
                    />
                    <span className="text-[10px] font-semibold bg-gray-100 text-gray-600 px-2 py-0.5 rounded font-mono">
                      v{draft.revision}
                    </span>
                  </div>

                  <span className="text-xs text-gray-500 font-medium flex items-center gap-1">
                    <Globe className="h-3 w-3 text-gray-400" />
                    /teachers/{draft.publicFields.slug}
                  </span>
                </div>

                <div className="flex flex-wrap items-center gap-2 text-xs">
                  <span className="font-semibold text-gray-800 bg-gray-50 px-2 py-1 rounded border border-gray-200/70">
                    {draft.publicFields.city || 'City Unspecified'}
                  </span>
                  <div className="flex flex-wrap gap-1">
                    {draft.publicFields.subject?.map((s) => (
                      <span key={s} className="bg-red-50 text-[#C91F26] text-[10px] font-semibold px-2 py-0.5 rounded border border-red-100">
                        {s}
                      </span>
                    ))}
                  </div>
                </div>

                <p className="text-xs text-gray-600 leading-relaxed bg-gray-50/60 p-3 rounded-lg border border-gray-100">
                  {draft.publicFields.description || 'No descriptive bio provided in this submission.'}
                </p>

                <div className="pt-1 flex items-center justify-end gap-2">
                  <button
                    disabled={isBusy}
                    onClick={() => handleApprove(draft)}
                    className="inline-flex items-center gap-1.5 px-4 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors disabled:opacity-50"
                  >
                    {isBusy ? (
                      <>
                        <RotateCw className="h-3.5 w-3.5 animate-spin" />
                        <span>Publishing...</span>
                      </>
                    ) : (
                      <>
                        <BadgeCheck className="h-3.5 w-3.5" />
                        <span>{draft.status === 'publishing' ? 'Retry Publication' : 'Approve & Publish'}</span>
                      </>
                    )}
                  </button>
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
