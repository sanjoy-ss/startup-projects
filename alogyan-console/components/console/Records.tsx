'use client';

import { FormEvent, useCallback, useEffect, useMemo, useState } from 'react';
import {
  CreditCard,
  UserCheck,
  ShieldAlert,
  Building2,
  Plus,
  Clock,
  Calendar,
  Layers,
  Sparkles,
  ExternalLink,
  Lock,
  Mail,
  User
} from 'lucide-react';
import DirectoryToolbar, { FilterOption } from '@/components/admin/DirectoryToolbar';
import StatusBadge from '@/components/admin/StatusBadge';
import EmptyState from '@/components/admin/EmptyState';
import ConfirmModal from '@/components/admin/ConfirmModal';

type Item = {
  id?: string;
  _id?: string;
  name?: string;
  email?: string;
  username?: string;
  role?: string;
  status?: string;
  is_active?: boolean;
  active?: boolean;
  action?: string;
  path?: string;
  actorId?: string;
  createdAt?: string;
  created_at?: string;
  razorpayPlanId?: string;
  totalCount?: number;
  subscription?: { status: string; planId?: string; accessUntil: number };
  amount?: number;
  currency?: string;
  period?: string;
  interval?: number;
};

type Field = {
  name: string;
  label: string;
  type?: string;
  placeholder?: string;
  options?: string[];
};

const ROLE_BADGES: Record<string, { label: string; bg: string; text: string; border: string }> = {
  super_admin: { label: 'Super Admin', bg: 'bg-purple-50', text: 'text-purple-700', border: 'border-purple-200' },
  billing_manager: { label: 'Billing Manager', bg: 'bg-emerald-50', text: 'text-emerald-700', border: 'border-emerald-200' },
  teacher_manager: { label: 'Teacher Manager', bg: 'bg-blue-50', text: 'text-blue-700', border: 'border-blue-200' },
  review_moderator: { label: 'Review Moderator', bg: 'bg-amber-50', text: 'text-amber-700', border: 'border-amber-200' },
  content_manager: { label: 'Content Manager', bg: 'bg-cyan-50', text: 'text-cyan-700', border: 'border-cyan-200' },
  analytics_viewer: { label: 'Analytics Viewer', bg: 'bg-slate-100', text: 'text-slate-700', border: 'border-slate-200' },
  digital_marketer: { label: 'Digital Marketer', bg: 'bg-rose-50', text: 'text-rose-700', border: 'border-rose-200' },
  support: { label: 'Support', bg: 'bg-gray-100', text: 'text-gray-700', border: 'border-gray-200' },
};

export default function Records({
  title,
  description,
  endpoint,
  fields,
}: {
  title: string;
  description: string;
  endpoint: string;
  fields?: Field[];
}) {
  const [items, setItems] = useState<Item[]>([]);
  const [cursor, setCursor] = useState<string | null>(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [searchTerm, setSearchTerm] = useState('');
  const [filterValue, setFilterValue] = useState('all');
  const [showAddForm, setShowAddForm] = useState(false);

  // Modal confirmation state
  const [confirmModal, setConfirmModal] = useState<{
    isOpen: boolean;
    title: string;
    message: string;
    confirmLabel: string;
    danger: boolean;
    onConfirm: () => void;
  }>({
    isOpen: false,
    title: '',
    message: '',
    confirmLabel: '',
    danger: true,
    onConfirm: () => {},
  });

  const isCustomer = endpoint.endsWith('/customers');
  const isPlan = endpoint.endsWith('/plans');
  const isAdmin = endpoint.endsWith('/admins');
  const isAudit = endpoint.endsWith('/audit');

  const filterOptions: FilterOption[] = useMemo(() => {
    if (isPlan) {
      return [
        { label: 'All Plans', value: 'all' },
        { label: 'Active Only', value: 'active' },
        { label: 'Disabled Only', value: 'inactive' },
      ];
    }
    if (isAdmin) {
      return [
        { label: 'All Staff', value: 'all' },
        { label: 'Active Identity', value: 'active' },
        { label: 'Revoked Access', value: 'revoked' },
      ];
    }
    if (isCustomer) {
      return [
        { label: 'All Institutes', value: 'all' },
        { label: 'Active Accounts', value: 'active' },
        { label: 'Suspended Accounts', value: 'suspended' },
      ];
    }
    return [
      { label: 'All Operations', value: 'all' },
    ];
  }, [isPlan, isAdmin, isCustomer]);

  const load = useCallback(
    async (after?: string) => {
      setLoading(true);
      setError('');
      try {
        const response = await fetch(`${endpoint}${after ? `?after=${encodeURIComponent(after)}` : ''}`);
        const data = await response.json();
        if (!response.ok) throw new Error(data.error || 'Unable to load records');
        setItems((old) => (after ? [...old, ...(data.items || data.admins)] : data.items || data.admins));
        setCursor(data.nextCursor || null);
      } catch (e) {
        setError(e instanceof Error ? e.message : 'Unable to load records');
      } finally {
        setLoading(false);
      }
    },
    [endpoint]
  );

  useEffect(() => {
    void load();
  }, [load]);

  async function mutate(body: unknown, method = 'POST') {
    setBusy(true);
    setError('');
    try {
      const response = await fetch(endpoint, {
        method,
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(body),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Operation failed');
      await load();
      return true;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Operation failed');
      return false;
    } finally {
      setBusy(false);
    }
  }

  async function submit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    const form = event.currentTarget;
    const data = Object.fromEntries(new FormData(form));
    const body: Record<string, unknown> = { ...data };
    if ('totalCount' in data) body.totalCount = Number(data.totalCount);
    if (await mutate(body)) {
      form.reset();
      setShowAddForm(false);
    }
  }

  // Filter items by client search term & status filter
  const filteredItems = items.filter((item) => {
    // 1. Search term
    if (searchTerm) {
      const term = searchTerm.toLowerCase();
      const match =
        (item.name && item.name.toLowerCase().includes(term)) ||
        (item.email && item.email.toLowerCase().includes(term)) ||
        (item.username && item.username.toLowerCase().includes(term)) ||
        (item.id && item.id.toLowerCase().includes(term)) ||
        (item.action && item.action.toLowerCase().includes(term)) ||
        (item.path && item.path.toLowerCase().includes(term)) ||
        (item.razorpayPlanId && item.razorpayPlanId.toLowerCase().includes(term)) ||
        (item.role && item.role.toLowerCase().includes(term));
      if (!match) return false;
    }

    // 2. Filter selection
    if (filterValue !== 'all') {
      if (isPlan) {
        const isActive = item.active !== false;
        if (filterValue === 'active' && !isActive) return false;
        if (filterValue === 'inactive' && isActive) return false;
      } else if (isAdmin) {
        const isActive = item.is_active !== false;
        if (filterValue === 'active' && !isActive) return false;
        if (filterValue === 'revoked' && isActive) return false;
      } else if (isCustomer) {
        const status = item.status || 'active';
        if (filterValue !== status) return false;
      }
    }

    return true;
  });

  return (
    <div className="w-full space-y-4">
      {/* Reusable Directory Toolbar */}
      <DirectoryToolbar
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        searchPlaceholder={`Search ${title.toLowerCase()}...`}
        filterValue={filterValue}
        onFilterChange={setFilterValue}
        filterOptions={filterOptions}
        totalCount={filteredItems.length}
        countLabel="records"
        onRefresh={() => void load()}
        refreshing={loading}
        actionSlot={
          fields ? (
            <button
              onClick={() => setShowAddForm(!showAddForm)}
              className="inline-flex items-center gap-1.5 px-3 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>{showAddForm ? 'Cancel Form' : 'New Entry'}</span>
            </button>
          ) : null
        }
      />

      {/* Description caption */}
      {description && (
        <p className="text-xs text-gray-500 leading-relaxed px-1 font-normal">
          {description}
        </p>
      )}

      {/* Error alert */}
      {error && (
        <div role="alert" className="rounded-xl bg-red-50 border border-red-200/80 p-3.5 text-xs text-red-800 font-medium">
          {error}
        </div>
      )}

      {/* Creation Drawer Form */}
      {fields && showAddForm && (
        <form
          onSubmit={submit}
          className="bg-white border border-gray-200/90 rounded-xl p-5 grid gap-4 sm:grid-cols-2 shadow-xs animate-fade-in"
        >
          {fields.map((field) => (
            <label key={field.name} className="text-xs font-semibold text-gray-700 space-y-1 block">
              <span>{field.label}</span>
              {field.options ? (
                <select
                  name={field.name}
                  required
                  className="block w-full text-xs border border-gray-200 rounded-lg p-2.5 bg-gray-50 focus:bg-white focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26]"
                >
                  {field.options.map((value) => (
                    <option key={value} value={value}>
                      {value}
                    </option>
                  ))}
                </select>
              ) : (
                <input
                  name={field.name}
                  type={field.type || 'text'}
                  placeholder={field.placeholder}
                  required
                  className="block w-full text-xs border border-gray-200 rounded-lg p-2.5 bg-gray-50 focus:bg-white focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26]"
                />
              )}
            </label>
          ))}
          <div className="sm:col-span-2 pt-2 flex justify-end gap-2 border-t border-gray-100">
            <button
              type="button"
              onClick={() => setShowAddForm(false)}
              className="px-4 py-2 border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
            >
              Cancel
            </button>
            <button
              type="submit"
              disabled={busy}
              className="px-5 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs disabled:opacity-50 transition-colors"
            >
              {busy ? 'Saving...' : 'Register Record'}
            </button>
          </div>
        </form>
      )}

      {/* Empty State */}
      {!filteredItems.length && !loading && (
        <EmptyState
          title={`No ${title.toLowerCase()} found`}
          description={
            searchTerm
              ? `No records matched your search query "${searchTerm}".`
              : 'No records exist in this directory yet.'
          }
          action={
            fields ? (
              <button
                onClick={() => setShowAddForm(true)}
                className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors"
              >
                <Plus className="h-3.5 w-3.5" />
                <span>Create Record</span>
              </button>
            ) : undefined
          }
        />
      )}

      {/* Polished Entity Cards */}
      <div className="grid gap-3">
        {filteredItems.map((item) => {
          const rawStatus = item.status || (item.active === false || item.is_active === false ? 'inactive' : 'active');

          /* 1. Plans & Billing Card */
          if (isPlan) {
            const formattedPrice =
              typeof item.amount === 'number'
                ? new Intl.NumberFormat('en-IN', { style: 'currency', currency: item.currency || 'INR' }).format(
                    item.amount / 100
                  )
                : 'Free';

            return (
              <article
                key={item.id}
                className="rounded-xl border border-gray-200/80 bg-white p-4 shadow-xs hover:border-gray-300 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4"
              >
                <div className="flex items-start gap-3.5 min-w-0">
                  <div className="w-10 h-10 rounded-xl bg-red-50 text-[#C91F26] flex items-center justify-center flex-shrink-0 mt-0.5">
                    <CreditCard className="h-5 w-5" />
                  </div>
                  <div className="min-w-0 space-y-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="text-xs font-bold text-gray-900 font-poppins">{item.name || item.id}</h3>
                      <StatusBadge status={item.active ? 'active' : 'inactive'} />
                      <span className="text-[10px] font-mono bg-gray-100 text-gray-600 px-2 py-0.5 rounded font-medium">
                        {item.id}
                      </span>
                    </div>

                    <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500 font-mono">
                      <span>Gateway Plan: {item.razorpayPlanId || 'N/A'}</span>
                      {item.totalCount && (
                        <span className="text-gray-600 font-sans">
                          Cycles: <strong className="text-gray-900 font-semibold">{item.totalCount}</strong> billing cycles
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <div className="flex items-center justify-between md:justify-end gap-4 flex-shrink-0 pt-2 md:pt-0 border-t md:border-t-0 border-gray-100">
                  <div className="text-left md:text-right">
                    <div className="text-sm font-bold text-gray-900 font-poppins">{formattedPrice}</div>
                    <div className="text-[10px] text-gray-400 capitalize">
                      per {item.interval && item.interval > 1 ? `${item.interval} ` : ''}{item.period || 'month'}
                    </div>
                  </div>

                  <button
                    disabled={busy}
                    onClick={() => {
                      setConfirmModal({
                        isOpen: true,
                        title: item.active ? 'Disable Plan Sales' : 'Reactivate Plan',
                        message: item.active
                          ? `Are you sure you want to disable sales for "${item.name}"? Existing subscriptions will be preserved.`
                          : `Reactivate "${item.name}" for new subscription purchases?`,
                        confirmLabel: item.active ? 'Disable Plan' : 'Activate Plan',
                        danger: !!item.active,
                        onConfirm: () => {
                          setConfirmModal((prev) => ({ ...prev, isOpen: false }));
                          void mutate({ id: item.id, active: !item.active }, 'PATCH');
                        },
                      });
                    }}
                    className={`px-3 py-1.5 text-xs font-semibold rounded-lg border transition-colors ${
                      item.active
                        ? 'border-gray-200 text-gray-700 hover:bg-gray-50'
                        : 'border-emerald-200 text-emerald-700 hover:bg-emerald-50'
                    }`}
                  >
                    {item.active ? 'Disable Plan' : 'Enable Plan'}
                  </button>
                </div>
              </article>
            );
          }

          /* 2. Admin Directory Card */
          if (isAdmin) {
            const roleMeta = (item.role && ROLE_BADGES[item.role]) || {
              label: item.role || 'Staff',
              bg: 'bg-gray-100',
              text: 'text-gray-700',
              border: 'border-gray-200',
            };

            return (
              <article
                key={item._id || item.id}
                className="rounded-xl border border-gray-200/80 bg-white p-4 shadow-xs hover:border-gray-300 transition-all flex flex-col md:flex-row md:items-center justify-between gap-4"
              >
                <div className="flex items-start gap-3.5 min-w-0">
                  <div className="w-10 h-10 rounded-xl bg-purple-50 text-purple-700 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <UserCheck className="h-5 w-5" />
                  </div>
                  <div className="min-w-0 space-y-1">
                    <div className="flex flex-wrap items-center gap-2">
                      <h3 className="text-xs font-bold text-gray-900 font-poppins">{item.username}</h3>
                      <StatusBadge status={item.is_active !== false ? 'active' : 'revoked'} />
                      <span className={`text-[10px] font-semibold px-2 py-0.5 rounded-full border ${roleMeta.bg} ${roleMeta.text} ${roleMeta.border}`}>
                        {roleMeta.label}
                      </span>
                    </div>

                    <div className="flex flex-wrap items-center gap-x-3 text-xs text-gray-500 font-mono">
                      <span>{item.email}</span>
                      {item.created_at && (
                        <span className="text-[11px] text-gray-400 font-sans">
                          Joined {new Date(item.created_at).toLocaleDateString()}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                <div className="flex items-center gap-2 flex-shrink-0 pt-2 md:pt-0 border-t md:border-t-0 border-gray-100">
                  {item.is_active !== false && (
                    <button
                      disabled={busy}
                      onClick={() => {
                        setConfirmModal({
                          isOpen: true,
                          title: 'Revoke Console Access',
                          message: `Are you sure you want to revoke console access for ${item.username} (${item.email})? Their active sessions will be terminated immediately.`,
                          confirmLabel: 'Revoke Access',
                          danger: true,
                          onConfirm: () => {
                            setConfirmModal((prev) => ({ ...prev, isOpen: false }));
                            void mutate({ id: item._id }, 'DELETE');
                          },
                        });
                      }}
                      className="px-3 py-1.5 text-xs font-semibold rounded-lg border border-rose-200 text-rose-700 hover:bg-rose-50 transition-colors"
                    >
                      Revoke Access
                    </button>
                  )}
                </div>
              </article>
            );
          }

          /* 3. Audit Trail Card */
          if (isAudit) {
            const method = item.action?.split(' ')?.[0] || 'OP';
            const methodColor =
              method === 'POST'
                ? 'bg-emerald-50 text-emerald-700 border-emerald-200'
                : method === 'PATCH' || method === 'PUT'
                ? 'bg-blue-50 text-blue-700 border-blue-200'
                : method === 'DELETE'
                ? 'bg-rose-50 text-rose-700 border-rose-200'
                : 'bg-gray-100 text-gray-700 border-gray-200';

            return (
              <article
                key={item.id}
                className="rounded-xl border border-gray-200/80 bg-white p-3.5 shadow-xs hover:border-gray-300 transition-all flex flex-col md:flex-row md:items-center justify-between gap-3 text-xs"
              >
                <div className="flex items-start gap-3 min-w-0">
                  <div className="w-8 h-8 rounded-lg bg-gray-100 text-gray-600 flex items-center justify-center flex-shrink-0 mt-0.5">
                    <ShieldAlert className="h-4 w-4" />
                  </div>
                  <div className="min-w-0 space-y-0.5">
                    <div className="flex flex-wrap items-center gap-2">
                      <span className={`text-[10px] font-bold px-1.5 py-0.5 rounded border font-mono ${methodColor}`}>
                        {method}
                      </span>
                      <span className="font-mono text-xs font-semibold text-gray-900 truncate">
                        {item.path || item.action}
                      </span>
                      <StatusBadge status={item.status || 'success'} />
                    </div>

                    <div className="flex flex-wrap items-center gap-x-3 text-[11px] text-gray-400">
                      <span>Staff ID: <code className="text-gray-600 font-mono">{item.actorId || 'system'}</code></span>
                      {item.createdAt && (
                        <span>Logged: <span className="text-gray-600">{new Date(item.createdAt).toLocaleString()}</span></span>
                      )}
                    </div>
                  </div>
                </div>
              </article>
            );
          }

          /* 4. Customer / Default Card */
          return (
            <article
              key={item.id || item._id}
              className="rounded-xl border border-gray-200/80 bg-white p-4 shadow-xs hover:border-gray-300 transition-all flex flex-col sm:flex-row sm:items-center justify-between gap-4"
            >
              <div className="flex items-start gap-3 min-w-0">
                <div className="w-10 h-10 rounded-xl bg-sky-50 text-sky-700 flex items-center justify-center flex-shrink-0 mt-0.5">
                  <Building2 className="h-5 w-5" />
                </div>
                <div className="min-w-0 space-y-1">
                  <div className="flex items-center gap-2">
                    <h3 className="text-xs font-bold text-gray-900 truncate font-poppins">
                      {item.name || item.id}
                    </h3>
                    <StatusBadge status={rawStatus} />
                  </div>

                  <p className="text-xs text-gray-500 truncate font-mono">
                    {item.email || item.id}
                  </p>

                  {item.subscription && (
                    <p className="text-[11px] text-gray-600">
                      Tier: <strong className="font-semibold text-gray-800">{item.subscription.planId || 'Basic'}</strong> · Status:{' '}
                      <span className="capitalize">{item.subscription.status}</span>
                      {item.subscription.accessUntil > 0 &&
                        ` · Valid until ${new Date(item.subscription.accessUntil).toLocaleDateString()}`}
                    </p>
                  )}
                </div>
              </div>

              <div className="flex items-center gap-2 flex-shrink-0 pt-2 sm:pt-0 border-t sm:border-t-0 border-gray-100">
                {isCustomer && (
                  <button
                    disabled={busy}
                    className={`px-3 py-1.5 text-xs font-semibold rounded-lg border transition-colors ${
                      item.status === 'active'
                        ? 'border-rose-200 text-rose-700 hover:bg-rose-50'
                        : 'border-emerald-200 text-emerald-700 hover:bg-emerald-50'
                    }`}
                    onClick={() => {
                      const reason = window.prompt('Reason for updating this institute’s status:');
                      if (reason) void mutate({ id: item.id, status: item.status === 'active' ? 'suspended' : 'active', reason }, 'PATCH');
                    }}
                  >
                    {item.status === 'active' ? 'Suspend Account' : 'Restore Account'}
                  </button>
                )}
              </div>
            </article>
          );
        })}
      </div>

      {loading && (
        <div className="text-center py-6 text-xs font-semibold text-gray-400">
          Syncing records...
        </div>
      )}

      {cursor && (
        <div className="text-center pt-2">
          <button
            disabled={loading}
            className="px-4 py-2 border border-gray-200 rounded-lg text-xs font-semibold text-gray-700 hover:bg-gray-50 transition-colors"
            onClick={() => void load(cursor)}
          >
            Load Older Records
          </button>
        </div>
      )}

      {/* Confirmation Modal */}
      <ConfirmModal
        isOpen={confirmModal.isOpen}
        onClose={() => setConfirmModal((prev) => ({ ...prev, isOpen: false }))}
        onConfirm={confirmModal.onConfirm}
        title={confirmModal.title}
        message={confirmModal.message}
        confirmLabel={confirmModal.confirmLabel}
        danger={confirmModal.danger}
        loading={busy}
      />
    </div>
  );
}
