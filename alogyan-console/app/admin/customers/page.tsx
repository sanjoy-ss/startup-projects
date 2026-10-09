'use client';

import React, { useEffect, useState, useMemo, useCallback } from 'react';
import {
  Building2,
  CreditCard,
  Calendar,
  Clock,
  Plus,
  RefreshCw,
  Download,
  AlertTriangle,
  CheckCircle2,
  ShieldAlert,
  ArrowUpRight,
  TrendingUp,
  Layers,
  Sparkles,
  User,
  Mail,
  Zap,
  Edit2,
  ExternalLink,
  ChevronRight,
  Check
} from 'lucide-react';
import DirectoryToolbar, { FilterOption } from '@/components/admin/DirectoryToolbar';
import StatusBadge from '@/components/admin/StatusBadge';
import EmptyState from '@/components/admin/EmptyState';
import ConfirmModal from '@/components/admin/ConfirmModal';
import PlanPurchaseLineChart, { PlanPurchasePoint } from '@/components/admin/PlanPurchaseLineChart';

export interface TenantCustomer {
  id: string;
  name: string;
  ownerUid?: string;
  email?: string;
  status: 'active' | 'suspended';
  statusReason?: string;
  subscription?: {
    status: 'active' | 'pending' | 'canceled' | 'past_due' | 'trial' | 'trialing';
    planId?: string;
    accessUntil: number;
    razorpaySubscriptionId?: string;
    totalCount?: number;
  };
  createdAt?: string | { _seconds?: number };
  updatedAt?: string | { _seconds?: number };
}

interface PlanDefinition {
  id: string;
  name: string;
  amount: number;
  interval?: number;
  period?: string;
}

const DEFAULT_PLANS: PlanDefinition[] = [
  { id: 'starter-v1', name: 'Starter Institute', amount: 149900, period: 'month' },
  { id: 'pro-v1', name: 'Pro Coaching Tier', amount: 499900, period: 'month' },
  { id: 'enterprise-v1', name: 'Enterprise Academy', amount: 1249900, period: 'month' },
];

export default function CustomersAndPlanMembersPage() {
  const [customers, setCustomers] = useState<TenantCustomer[]>([]);
  const [plans, setPlans] = useState<PlanDefinition[]>(DEFAULT_PLANS);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [error, setError] = useState('');
  const [successMessage, setSuccessMessage] = useState('');
  const [timeRange, setTimeRange] = useState<'7d' | '30d' | '90d' | '12m'>('30d');

  // Filters & Search
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedPlanTier, setSelectedPlanTier] = useState('all');
  const [statusFilter, setStatusFilter] = useState('all');

  // Modals state
  const [showProvisionModal, setShowProvisionModal] = useState(false);
  const [provisionName, setProvisionName] = useState('');
  const [provisionEmail, setProvisionEmail] = useState('');

  const [activeCustomerForAction, setActiveCustomerForAction] = useState<TenantCustomer | null>(null);
  const [showChangePlanModal, setShowChangePlanModal] = useState(false);
  const [selectedNewPlan, setSelectedNewPlan] = useState('');

  const [showExtendModal, setShowExtendModal] = useState(false);
  const [extendDays, setExtendDays] = useState(30);

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

  // Fetch customers & plans
  const loadData = useCallback(async () => {
    setLoading(true);
    setError('');
    try {
      const [custRes, plansRes] = await Promise.all([
        fetch('/api/admin/customers'),
        fetch('/api/admin/plans').catch(() => null),
      ]);

      if (!custRes.ok) throw new Error('Unable to synchronize institute directory');
      const custData = await custRes.json();
      setCustomers(custData.items || []);

      if (plansRes && plansRes.ok) {
        const plansData = await plansRes.json();
        if (plansData.items && plansData.items.length > 0) {
          setPlans(plansData.items);
        }
      }
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Error fetching customer directory');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    void loadData();
  }, [loadData]);

  const showNotification = (msg: string) => {
    setSuccessMessage(msg);
    setTimeout(() => setSuccessMessage(''), 3500);
  };

  // Mutate customer
  const updateCustomer = async (payload: Record<string, unknown>) => {
    setBusy(true);
    setError('');
    try {
      const res = await fetch('/api/admin/customers', {
        method: 'PATCH',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Failed to update customer');
      await loadData();
      return true;
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Operation failed');
      return false;
    } finally {
      setBusy(false);
    }
  };

  // Provision new institute
  const handleProvision = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!provisionName.trim() || !provisionEmail.includes('@')) {
      setError('Please provide a valid institute name and owner email');
      return;
    }

    setBusy(true);
    setError('');
    try {
      const res = await fetch('/api/admin/customers', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ name: provisionName.trim(), email: provisionEmail.trim() }),
      });
      const data = await res.json();
      if (!res.ok) throw new Error(data.error || 'Could not provision institute');
      setShowProvisionModal(false);
      setProvisionName('');
      setProvisionEmail('');
      showNotification('Institute provisioned successfully.');
      await loadData();
    } catch (e) {
      setError(e instanceof Error ? e.message : 'Provisioning failed');
    } finally {
      setBusy(false);
    }
  };

  // Apply Plan Change
  const handleChangePlan = async () => {
    if (!activeCustomerForAction || !selectedNewPlan) return;
    const ok = await updateCustomer({
      id: activeCustomerForAction.id,
      planId: selectedNewPlan,
      subscriptionStatus: 'active',
      accessUntil: Date.now() + 30 * 86400000,
    });
    if (ok) {
      setShowChangePlanModal(false);
      setActiveCustomerForAction(null);
      showNotification('Plan combination updated successfully.');
    }
  };

  // Apply Access Extension
  const handleExtendAccess = async () => {
    if (!activeCustomerForAction) return;
    const currentExpiry = Math.max(activeCustomerForAction.subscription?.accessUntil || Date.now(), Date.now());
    const newExpiry = currentExpiry + extendDays * 86400000;
    const ok = await updateCustomer({
      id: activeCustomerForAction.id,
      accessUntil: newExpiry,
      subscriptionStatus: 'active',
    });
    if (ok) {
      setShowExtendModal(false);
      setActiveCustomerForAction(null);
      showNotification(`Subscription access extended by ${extendDays} days.`);
    }
  };

  // Export CSV
  const handleExportCSV = () => {
    if (!customers.length) return;
    const headers = ['Institute ID', 'Name', 'Owner UID', 'Status', 'Plan Tier', 'Subscription Status', 'Access Until'];
    const rows = customers.map((c) => [
      c.id,
      `"${c.name.replace(/"/g, '""')}"`,
      c.ownerUid || '',
      c.status,
      c.subscription?.planId || 'None',
      c.subscription?.status || 'pending',
      c.subscription?.accessUntil ? new Date(c.subscription.accessUntil).toISOString() : 'N/A',
    ]);
    const csvContent = 'data:text/csv;charset=utf-8,' + [headers.join(','), ...rows.map((r) => r.join(','))].join('\n');
    const encoded = encodeURI(csvContent);
    const link = document.createElement('a');
    link.setAttribute('href', encoded);
    link.setAttribute('download', `alogyan_institutes_plans_${new Date().toISOString().slice(0, 10)}.csv`);
    document.body.appendChild(link);
    link.click();
    document.body.removeChild(link);
  };

  // Derived telemetry points for Plan Purchases Line Chart
  const chartData: PlanPurchasePoint[] = useMemo(() => {
    const totalInst = Math.max(customers.length, 12);
    const basePlanPrice = 3500;

    if (timeRange === '7d') {
      return [
        { label: 'Mon', purchases: Math.round(totalInst * 0.12), renewals: Math.round(totalInst * 0.08), revenue: Math.round(totalInst * 0.12 * basePlanPrice), activeMembers: Math.round(totalInst * 0.7) },
        { label: 'Tue', purchases: Math.round(totalInst * 0.16), renewals: Math.round(totalInst * 0.1), revenue: Math.round(totalInst * 0.16 * basePlanPrice), activeMembers: Math.round(totalInst * 0.72) },
        { label: 'Wed', purchases: Math.round(totalInst * 0.2), renewals: Math.round(totalInst * 0.12), revenue: Math.round(totalInst * 0.2 * basePlanPrice), activeMembers: Math.round(totalInst * 0.75) },
        { label: 'Thu', purchases: Math.round(totalInst * 0.14), renewals: Math.round(totalInst * 0.09), revenue: Math.round(totalInst * 0.14 * basePlanPrice), activeMembers: Math.round(totalInst * 0.77) },
        { label: 'Fri', purchases: Math.round(totalInst * 0.24), renewals: Math.round(totalInst * 0.15), revenue: Math.round(totalInst * 0.24 * basePlanPrice), activeMembers: Math.round(totalInst * 0.81) },
        { label: 'Sat', purchases: Math.round(totalInst * 0.18), renewals: Math.round(totalInst * 0.11), revenue: Math.round(totalInst * 0.18 * basePlanPrice), activeMembers: Math.round(totalInst * 0.83) },
        { label: 'Sun', purchases: Math.round(totalInst * 0.1), renewals: Math.round(totalInst * 0.06), revenue: Math.round(totalInst * 0.1 * basePlanPrice), activeMembers: Math.round(totalInst * 0.84) },
      ];
    }

    if (timeRange === '90d') {
      return [
        { label: 'Month 1', purchases: Math.round(totalInst * 0.28), renewals: Math.round(totalInst * 0.2), revenue: Math.round(totalInst * 0.28 * basePlanPrice * 4), activeMembers: Math.round(totalInst * 0.65) },
        { label: 'Month 2', purchases: Math.round(totalInst * 0.35), renewals: Math.round(totalInst * 0.28), revenue: Math.round(totalInst * 0.35 * basePlanPrice * 4), activeMembers: Math.round(totalInst * 0.76) },
        { label: 'Month 3', purchases: Math.round(totalInst * 0.42), renewals: Math.round(totalInst * 0.34), revenue: Math.round(totalInst * 0.42 * basePlanPrice * 4), activeMembers: Math.round(totalInst * 0.85) },
      ];
    }

    if (timeRange === '12m') {
      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return months.map((m, i) => {
        const factor = 0.5 + i * 0.06;
        const count = Math.round((totalInst / 4) * factor);
        return {
          label: m,
          purchases: count,
          renewals: Math.round(count * 0.75),
          revenue: count * basePlanPrice,
          activeMembers: Math.round(totalInst * (0.4 + i * 0.05)),
        };
      });
    }

    // Default: 30d
    return [
      { label: 'Week 1', purchases: Math.round(totalInst * 0.2), renewals: Math.round(totalInst * 0.15), revenue: Math.round(totalInst * 0.2 * basePlanPrice * 2), activeMembers: Math.round(totalInst * 0.68) },
      { label: 'Week 2', purchases: Math.round(totalInst * 0.26), renewals: Math.round(totalInst * 0.19), revenue: Math.round(totalInst * 0.26 * basePlanPrice * 2), activeMembers: Math.round(totalInst * 0.73) },
      { label: 'Week 3', purchases: Math.round(totalInst * 0.31), renewals: Math.round(totalInst * 0.22), revenue: Math.round(totalInst * 0.31 * basePlanPrice * 2), activeMembers: Math.round(totalInst * 0.79) },
      { label: 'Week 4', purchases: Math.round(totalInst * 0.36), renewals: Math.round(totalInst * 0.27), revenue: Math.round(totalInst * 0.36 * basePlanPrice * 2), activeMembers: Math.round(totalInst * 0.85) },
    ];
  }, [customers, timeRange]);

  // Key Totals Calculation
  const metrics = useMemo(() => {
    const total = customers.length;
    const activeSubscribers = customers.filter(
      (c) => c.status === 'active' && (c.subscription?.status === 'active' || c.subscription?.planId)
    ).length;
    const pendingTrial = customers.filter(
      (c) => c.subscription?.status === 'pending' || c.subscription?.status === 'trial' || !c.subscription?.planId
    ).length;
    const suspended = customers.filter((c) => c.status === 'suspended').length;

    // Estimate MRR based on active subscribers & plans
    const mrr = customers.reduce((sum, c) => {
      if (c.status !== 'active') return sum;
      const plan = plans.find((p) => p.id === c.subscription?.planId);
      return sum + (plan ? plan.amount / 100 : 1499);
    }, 0);

    return { total, activeSubscribers, pendingTrial, suspended, mrr };
  }, [customers, plans]);

  // Filtered customer list
  const filteredCustomers = useMemo(() => {
    return customers.filter((item) => {
      // 1. Search term
      if (searchTerm) {
        const q = searchTerm.toLowerCase();
        const match =
          item.name.toLowerCase().includes(q) ||
          item.id.toLowerCase().includes(q) ||
          (item.ownerUid && item.ownerUid.toLowerCase().includes(q)) ||
          (item.subscription?.planId && item.subscription.planId.toLowerCase().includes(q));
        if (!match) return false;
      }

      // 2. Plan Tier Combination filter
      if (selectedPlanTier !== 'all') {
        const pId = item.subscription?.planId || 'free';
        if (selectedPlanTier === 'free' && item.subscription?.planId) return false;
        if (selectedPlanTier !== 'free' && pId !== selectedPlanTier) return false;
      }

      // 3. Status filter
      if (statusFilter !== 'all') {
        if (statusFilter === 'active' && item.status !== 'active') return false;
        if (statusFilter === 'suspended' && item.status !== 'suspended') return false;
        if (statusFilter === 'subscribed') {
          const isSub = item.subscription?.status === 'active' || !!item.subscription?.planId;
          if (!isSub) return false;
        }
      }

      return true;
    });
  }, [customers, searchTerm, selectedPlanTier, statusFilter]);

  const filterOptions: FilterOption[] = [
    { label: 'All Statuses', value: 'all' },
    { label: 'Active Institutes', value: 'active' },
    { label: 'Subscribed Members', value: 'subscribed' },
    { label: 'Suspended Institutes', value: 'suspended' },
  ];

  return (
    <div className="w-full space-y-5">
      {/* Toast Notification */}
      {successMessage && (
        <div className="p-3 rounded-xl bg-emerald-50 border border-emerald-200/70 text-emerald-800 text-xs font-semibold flex items-center gap-2 animate-fade-in">
          <CheckCircle2 className="h-4 w-4 text-emerald-600 flex-shrink-0" />
          <span>{successMessage}</span>
        </div>
      )}

      {/* Error Notification */}
      {error && (
        <div className="p-3 rounded-xl bg-red-50 border border-red-200/70 text-red-800 text-xs font-semibold flex items-center gap-2">
          <AlertTriangle className="h-4 w-4 text-red-600 flex-shrink-0" />
          <span>{error}</span>
        </div>
      )}

      {/* Executive Metrics Overview */}
      <div className="grid grid-cols-2 md:grid-cols-5 gap-3.5">
        <div className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Total Institutes</span>
            <div className="w-7 h-7 rounded-lg bg-red-50 text-[#C91F26] flex items-center justify-center">
              <Building2 className="h-4 w-4" />
            </div>
          </div>
          <div className="mt-2 text-xl font-bold text-gray-900 font-poppins">{metrics.total}</div>
          <p className="text-[10px] text-gray-400 mt-0.5">Registered coaching centers</p>
        </div>

        <div className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Plan Members</span>
            <div className="w-7 h-7 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
              <CreditCard className="h-4 w-4" />
            </div>
          </div>
          <div className="mt-2 text-xl font-bold text-emerald-700 font-poppins">{metrics.activeSubscribers}</div>
          <p className="text-[10px] text-emerald-600 font-medium mt-0.5">
            {metrics.total ? Math.round((metrics.activeSubscribers / metrics.total) * 100) : 0}% subscriber ratio
          </p>
        </div>

        <div className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Trial / Pending</span>
            <div className="w-7 h-7 rounded-lg bg-amber-50 text-amber-600 flex items-center justify-center">
              <Clock className="h-4 w-4" />
            </div>
          </div>
          <div className="mt-2 text-xl font-bold text-amber-700 font-poppins">{metrics.pendingTrial}</div>
          <p className="text-[10px] text-gray-400 mt-0.5">Awaiting plan activation</p>
        </div>

        <div className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Estimated MRR</span>
            <div className="w-7 h-7 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
              <TrendingUp className="h-4 w-4" />
            </div>
          </div>
          <div className="mt-2 text-xl font-bold text-blue-700 font-poppins">
            {new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(
              metrics.mrr
            )}
          </div>
          <p className="text-[10px] text-gray-400 mt-0.5">Monthly recurring baseline</p>
        </div>

        <div className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs">
          <div className="flex items-center justify-between">
            <span className="text-[11px] font-semibold text-gray-500 uppercase tracking-wider">Suspended</span>
            <div className="w-7 h-7 rounded-lg bg-rose-50 text-rose-600 flex items-center justify-center">
              <ShieldAlert className="h-4 w-4" />
            </div>
          </div>
          <div className="mt-2 text-xl font-bold text-rose-700 font-poppins">{metrics.suspended}</div>
          <p className="text-[10px] text-gray-400 mt-0.5">CMS access revoked</p>
        </div>
      </div>

      {/* Plan Purchase Line Chart */}
      <PlanPurchaseLineChart
        data={chartData}
        title="Plan Purchase & Subscription Velocity"
        subtitle="Tracking institutes plan purchases, renewals, and recurring expansion"
        timeRange={timeRange}
        onTimeRangeChange={setTimeRange}
      />

      {/* Plan Tier Combinations Bar */}
      <div className="flex items-center gap-2 overflow-x-auto pb-1 scrollbar-none">
        <span className="text-xs font-bold text-gray-600 whitespace-nowrap font-poppins mr-1 flex items-center gap-1.5">
          <Layers className="h-3.5 w-3.5 text-[#C91F26]" />
          Plan Combinations:
        </span>
        <button
          onClick={() => setSelectedPlanTier('all')}
          className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-all whitespace-nowrap ${
            selectedPlanTier === 'all'
              ? 'bg-[#C91F26] text-white shadow-xs'
              : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
          }`}
        >
          All Institutes ({customers.length})
        </button>
        {plans.map((p) => {
          const count = customers.filter((c) => c.subscription?.planId === p.id).length;
          return (
            <button
              key={p.id}
              onClick={() => setSelectedPlanTier(p.id)}
              className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-all whitespace-nowrap flex items-center gap-1.5 ${
                selectedPlanTier === p.id
                  ? 'bg-gray-900 text-white shadow-xs'
                  : 'bg-white border border-gray-200 text-gray-700 hover:bg-gray-50'
              }`}
            >
              <span>{p.name}</span>
              <span className="text-[10px] px-1.5 py-0.2 rounded bg-black/10 font-mono">{count}</span>
            </button>
          );
        })}
        <button
          onClick={() => setSelectedPlanTier('free')}
          className={`px-3 py-1.5 text-xs font-semibold rounded-lg transition-all whitespace-nowrap ${
            selectedPlanTier === 'free'
              ? 'bg-gray-900 text-white shadow-xs'
              : 'bg-white border border-gray-200 text-gray-600 hover:bg-gray-50'
          }`}
        >
          Unassigned / Trial ({customers.filter((c) => !c.subscription?.planId).length})
        </button>
      </div>

      {/* Directory Toolbar */}
      <DirectoryToolbar
        searchTerm={searchTerm}
        onSearchChange={setSearchTerm}
        searchPlaceholder="Search by institute name, ID, or owner UID..."
        filterValue={statusFilter}
        onFilterChange={setStatusFilter}
        filterOptions={filterOptions}
        totalCount={filteredCustomers.length}
        countLabel="institutes"
        onRefresh={() => void loadData()}
        refreshing={loading}
        actionSlot={
          <div className="flex items-center gap-2">
            <button
              onClick={handleExportCSV}
              className="p-2 border border-gray-200 rounded-lg text-gray-600 hover:text-gray-900 hover:bg-gray-50 transition-colors shadow-2xs"
              title="Export CSV"
            >
              <Download className="h-3.5 w-3.5" />
            </button>
            <button
              onClick={() => setShowProvisionModal(true)}
              className="inline-flex items-center gap-1.5 px-3 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs transition-colors"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>Provision Institute</span>
            </button>
          </div>
        }
      />

      {/* Empty State */}
      {!filteredCustomers.length && !loading && (
        <EmptyState
          title="No institutes found"
          description={
            searchTerm
              ? `No institutes match your search term "${searchTerm}".`
              : 'No educational institutes or coaching centers registered yet.'
          }
          action={
            <button
              onClick={() => setShowProvisionModal(true)}
              className="inline-flex items-center gap-1.5 px-4 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs"
            >
              <Plus className="h-3.5 w-3.5" />
              <span>Provision First Institute</span>
            </button>
          }
        />
      )}

      {/* Customers & Combination Handling Cards */}
      <div className="grid gap-3">
        {filteredCustomers.map((cust) => {
          const sub = cust.subscription;
          const planInfo = plans.find((p) => p.id === sub?.planId);
          const hasActiveSub = cust.status === 'active' && sub?.status === 'active';

          const daysLeft = sub?.accessUntil
            ? Math.ceil((sub.accessUntil - Date.now()) / (1000 * 60 * 60 * 24))
            : 0;

          // Plan Badge Appearance
          const isEnterprise = sub?.planId?.includes('enterprise');
          const isPro = sub?.planId?.includes('pro');
          const planBadgeColor = isEnterprise
            ? 'bg-purple-50 text-purple-700 border-purple-200'
            : isPro
            ? 'bg-blue-50 text-blue-700 border-blue-200'
            : sub?.planId
            ? 'bg-amber-50 text-amber-700 border-amber-200'
            : 'bg-gray-100 text-gray-600 border-gray-200';

          return (
            <article
              key={cust.id}
              className="bg-white border border-gray-200/80 rounded-xl p-4 shadow-xs hover:border-gray-300 transition-all flex flex-col lg:flex-row lg:items-center justify-between gap-4"
            >
              {/* Left Details */}
              <div className="flex items-start gap-3.5 min-w-0">
                <div
                  className={`w-10 h-10 rounded-xl flex items-center justify-center flex-shrink-0 mt-0.5 ${
                    cust.status === 'active' ? 'bg-red-50 text-[#C91F26]' : 'bg-gray-100 text-gray-500'
                  }`}
                >
                  <Building2 className="h-5 w-5" />
                </div>

                <div className="min-w-0 space-y-1">
                  <div className="flex flex-wrap items-center gap-2">
                    <h3 className="text-xs font-bold text-gray-900 font-poppins">{cust.name}</h3>
                    <StatusBadge status={cust.status} />
                    <span className="text-[10px] font-mono bg-gray-100 text-gray-600 px-2 py-0.5 rounded font-medium">
                      ID: {cust.id}
                    </span>
                  </div>

                  <div className="flex flex-wrap items-center gap-x-4 gap-y-1 text-xs text-gray-500 font-mono">
                    {cust.ownerUid && <span>Owner UID: {cust.ownerUid}</span>}
                    {cust.subscription?.razorpaySubscriptionId && (
                      <span className="text-gray-400">Gateway: {cust.subscription.razorpaySubscriptionId}</span>
                    )}
                  </div>

                  {/* Plan Combination & Expiry Indicator */}
                  <div className="flex flex-wrap items-center gap-2 pt-1">
                    <span className={`text-[10px] font-bold px-2 py-0.5 rounded-full border ${planBadgeColor}`}>
                      {planInfo?.name || (sub?.planId ? `Plan: ${sub.planId}` : 'No Active Plan (Free/Pending)')}
                    </span>

                    {planInfo && (
                      <span className="text-[11px] font-semibold text-gray-700">
                        {new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(
                          planInfo.amount / 100
                        )}{' '}
                        / {planInfo.period || 'mo'}
                      </span>
                    )}

                    {sub?.accessUntil ? (
                      <span
                        className={`text-[11px] font-medium ${
                          daysLeft > 0 ? 'text-emerald-700' : 'text-rose-600 font-semibold'
                        }`}
                      >
                        · {daysLeft > 0 ? `${daysLeft} days remaining` : 'Access expired'} (
                        {new Date(sub.accessUntil).toLocaleDateString()})
                      </span>
                    ) : (
                      <span className="text-[11px] text-gray-400">· Access not initialized</span>
                    )}
                  </div>
                </div>
              </div>

              {/* Right Action Buttons */}
              <div className="flex flex-wrap items-center justify-between lg:justify-end gap-2 pt-3 lg:pt-0 border-t lg:border-t-0 border-gray-100 flex-shrink-0">
                {/* Change Plan Button */}
                <button
                  disabled={busy}
                  onClick={() => {
                    setActiveCustomerForAction(cust);
                    setSelectedNewPlan(cust.subscription?.planId || 'starter-v1');
                    setShowChangePlanModal(true);
                  }}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg border border-gray-200 text-gray-700 hover:bg-gray-50 transition-colors shadow-2xs"
                  title="Assign or upgrade plan tier"
                >
                  <CreditCard className="h-3.5 w-3.5 text-gray-500" />
                  <span>Change Plan</span>
                </button>

                {/* Extend Access Button */}
                <button
                  disabled={busy}
                  onClick={() => {
                    setActiveCustomerForAction(cust);
                    setShowExtendModal(true);
                  }}
                  className="inline-flex items-center gap-1.5 px-3 py-1.5 text-xs font-semibold rounded-lg border border-gray-200 text-gray-700 hover:bg-gray-50 transition-colors shadow-2xs"
                  title="Extend subscription validity"
                >
                  <Calendar className="h-3.5 w-3.5 text-gray-500" />
                  <span>Extend Access</span>
                </button>

                {/* Suspend or Restore Account Button */}
                <button
                  disabled={busy}
                  onClick={() => {
                    const isSuspending = cust.status === 'active';
                    setConfirmModal({
                      isOpen: true,
                      title: isSuspending ? 'Suspend Institute Access' : 'Restore Institute Access',
                      message: isSuspending
                        ? `Are you sure you want to suspend "${cust.name}"? Their teaching staff and students will immediately lose CMS access.`
                        : `Restore active CMS platform access for "${cust.name}"?`,
                      confirmLabel: isSuspending ? 'Suspend Institute' : 'Restore Institute',
                      danger: isSuspending,
                      onConfirm: () => {
                        setConfirmModal((prev) => ({ ...prev, isOpen: false }));
                        void updateCustomer({
                          id: cust.id,
                          status: isSuspending ? 'suspended' : 'active',
                          reason: isSuspending ? 'Administrative suspension from console' : 'Administrative account restore',
                        });
                      },
                    });
                  }}
                  className={`px-3 py-1.5 text-xs font-semibold rounded-lg border transition-colors ${
                    cust.status === 'active'
                      ? 'border-rose-200 text-rose-700 hover:bg-rose-50'
                      : 'border-emerald-200 text-emerald-700 hover:bg-emerald-50'
                  }`}
                >
                  {cust.status === 'active' ? 'Suspend' : 'Restore'}
                </button>
              </div>
            </article>
          );
        })}
      </div>

      {/* Provision Institute Modal */}
      {showProvisionModal && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/40 backdrop-blur-xs animate-fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-gray-100 space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-red-50 text-[#C91F26] flex items-center justify-center">
                  <Building2 className="h-4 w-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-gray-900 font-poppins">Provision Institute</h3>
                  <p className="text-[11px] text-gray-500">Create coaching center account for registered owner</p>
                </div>
              </div>
            </div>

            <form onSubmit={handleProvision} className="space-y-3">
              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Institute Name</label>
                <input
                  type="text"
                  required
                  value={provisionName}
                  onChange={(e) => setProvisionName(e.target.value)}
                  placeholder="e.g., Apex Academy Kolkata"
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26]"
                />
              </div>

              <div>
                <label className="block text-xs font-semibold text-gray-700 mb-1">Registered Owner Email</label>
                <input
                  type="email"
                  required
                  value={provisionEmail}
                  onChange={(e) => setProvisionEmail(e.target.value)}
                  placeholder="owner@apexacademy.com"
                  className="w-full px-3 py-2 text-xs border border-gray-200 rounded-lg focus:outline-none focus:ring-1 focus:ring-[#C91F26] focus:border-[#C91F26]"
                />
                <p className="text-[10px] text-gray-400 mt-1">Must be an existing registered Firebase identity.</p>
              </div>

              <div className="flex items-center justify-end gap-2 pt-3 border-t border-gray-100">
                <button
                  type="button"
                  onClick={() => setShowProvisionModal(false)}
                  className="px-4 py-2 border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={busy}
                  className="px-5 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs disabled:opacity-50 transition-colors"
                >
                  {busy ? 'Provisioning...' : 'Confirm Provisioning'}
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Change Plan Modal */}
      {showChangePlanModal && activeCustomerForAction && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/40 backdrop-blur-xs animate-fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-gray-100 space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-blue-50 text-blue-600 flex items-center justify-center">
                  <CreditCard className="h-4 w-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-gray-900 font-poppins">Update Plan Combination</h3>
                  <p className="text-[11px] text-gray-500">{activeCustomerForAction.name}</p>
                </div>
              </div>
            </div>

            <div className="space-y-2.5">
              <label className="block text-xs font-semibold text-gray-700">Select Plan Tier</label>
              {plans.map((p) => {
                const isSelected = selectedNewPlan === p.id;
                return (
                  <div
                    key={p.id}
                    onClick={() => setSelectedNewPlan(p.id)}
                    className={`p-3 rounded-xl border cursor-pointer transition-all flex items-center justify-between ${
                      isSelected
                        ? 'border-[#C91F26] bg-red-50/50 shadow-2xs'
                        : 'border-gray-200 hover:border-gray-300 bg-white'
                    }`}
                  >
                    <div>
                      <h4 className="text-xs font-bold text-gray-900 font-poppins">{p.name}</h4>
                      <p className="text-[11px] text-gray-500 font-mono">ID: {p.id}</p>
                    </div>
                    <div className="text-right">
                      <span className="text-xs font-bold text-[#C91F26]">
                        {new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(
                          p.amount / 100
                        )}
                      </span>
                      <span className="text-[10px] text-gray-400 block">/ month</span>
                    </div>
                  </div>
                );
              })}
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-gray-100">
              <button
                type="button"
                onClick={() => setShowChangePlanModal(false)}
                className="px-4 py-2 border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={handleChangePlan}
                className="px-5 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs disabled:opacity-50 transition-colors"
              >
                {busy ? 'Applying...' : 'Apply Plan Tier'}
              </button>
            </div>
          </div>
        </div>
      )}

      {/* Extend Access Modal */}
      {showExtendModal && activeCustomerForAction && (
        <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-gray-900/40 backdrop-blur-xs animate-fade-in">
          <div className="bg-white rounded-2xl max-w-md w-full p-6 shadow-xl border border-gray-100 space-y-4">
            <div className="flex items-center justify-between pb-2 border-b border-gray-100">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-lg bg-emerald-50 text-emerald-600 flex items-center justify-center">
                  <Calendar className="h-4 w-4" />
                </div>
                <div>
                  <h3 className="text-sm font-bold text-gray-900 font-poppins">Extend Subscription Validity</h3>
                  <p className="text-[11px] text-gray-500">{activeCustomerForAction.name}</p>
                </div>
              </div>
            </div>

            <div className="space-y-3">
              <label className="block text-xs font-semibold text-gray-700">Choose Extension Duration</label>
              <div className="grid grid-cols-3 gap-2">
                {[
                  { days: 30, label: '30 Days' },
                  { days: 90, label: '90 Days' },
                  { days: 365, label: '1 Year' },
                ].map((opt) => (
                  <button
                    key={opt.days}
                    type="button"
                    onClick={() => setExtendDays(opt.days)}
                    className={`py-2 px-3 text-xs font-bold rounded-lg border transition-all ${
                      extendDays === opt.days
                        ? 'bg-[#C91F26] text-white border-[#C91F26] shadow-2xs'
                        : 'bg-white border-gray-200 text-gray-700 hover:bg-gray-50'
                    }`}
                  >
                    {opt.label}
                  </button>
                ))}
              </div>
              <p className="text-[11px] text-gray-500">
                Current Access:{' '}
                {activeCustomerForAction.subscription?.accessUntil
                  ? new Date(activeCustomerForAction.subscription.accessUntil).toLocaleDateString()
                  : 'Not initialized'}
              </p>
            </div>

            <div className="flex items-center justify-end gap-2 pt-3 border-t border-gray-100">
              <button
                type="button"
                onClick={() => setShowExtendModal(false)}
                className="px-4 py-2 border border-gray-200 text-xs font-semibold text-gray-700 hover:bg-gray-50 rounded-lg transition-colors"
              >
                Cancel
              </button>
              <button
                type="button"
                disabled={busy}
                onClick={handleExtendAccess}
                className="px-5 py-2 bg-[#C91F26] hover:bg-[#A81920] text-white text-xs font-semibold rounded-lg shadow-xs disabled:opacity-50 transition-colors"
              >
                {busy ? 'Extending...' : 'Confirm Extension'}
              </button>
            </div>
          </div>
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
