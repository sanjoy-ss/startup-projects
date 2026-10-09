'use client';

import React, { useState, useMemo } from 'react';
import { TrendingUp, ShoppingBag, CreditCard, Calendar, ArrowUpRight } from 'lucide-react';

export interface PlanPurchasePoint {
  label: string;
  purchases: number;
  renewals: number;
  revenue: number;
  activeMembers: number;
}

interface PlanPurchaseLineChartProps {
  data: PlanPurchasePoint[];
  title?: string;
  subtitle?: string;
  timeRange: '7d' | '30d' | '90d' | '12m';
  onTimeRangeChange?: (range: '7d' | '30d' | '90d' | '12m') => void;
  showSecondary?: boolean;
}

export default function PlanPurchaseLineChart({
  data,
  title = 'Plan Purchases & Subscription Trajectory',
  subtitle = 'Institutes & centers membership subscriptions and renewals',
  timeRange,
  onTimeRangeChange,
  showSecondary = true,
}: PlanPurchaseLineChartProps) {
  const [hoveredIndex, setHoveredIndex] = useState<number | null>(null);

  // SVG Dimension Constants
  const svgWidth = 720;
  const svgHeight = 220;
  const paddingLeft = 45;
  const paddingRight = 25;
  const paddingTop = 25;
  const paddingBottom = 35;

  const chartWidth = svgWidth - paddingLeft - paddingRight;
  const chartHeight = svgHeight - paddingTop - paddingBottom;

  // Maximum value calculation for proportional scaling
  const maxPurchaseVal = useMemo(() => {
    const maxVal = Math.max(
      ...data.map((d) => (showSecondary ? Math.max(d.purchases, d.renewals) : d.purchases)),
      5
    );
    return Math.ceil(maxVal * 1.25);
  }, [data, showSecondary]);

  // Aggregate totals
  const totalPurchases = useMemo(
    () => data.reduce((acc, curr) => acc + curr.purchases, 0),
    [data]
  );
  const totalRevenue = useMemo(
    () => data.reduce((acc, curr) => acc + curr.revenue, 0),
    [data]
  );
  const totalRenewals = useMemo(
    () => data.reduce((acc, curr) => acc + curr.renewals, 0),
    [data]
  );

  // Compute coordinate points
  const points = useMemo(() => {
    if (!data.length) return [];
    const stepX = data.length > 1 ? chartWidth / (data.length - 1) : chartWidth / 2;

    return data.map((d, i) => {
      const x = paddingLeft + (data.length > 1 ? i * stepX : chartWidth / 2);
      const yPrimary = paddingTop + chartHeight - (d.purchases / maxPurchaseVal) * chartHeight;
      const ySecondary = paddingTop + chartHeight - (d.renewals / maxPurchaseVal) * chartHeight;
      return { x, yPrimary, ySecondary, ...d };
    });
  }, [data, chartWidth, chartHeight, maxPurchaseVal]);

  // Construct smooth bezier path for primary line
  const primaryPathD = useMemo(() => {
    if (!points.length) return '';
    if (points.length === 1) return `M ${points[0].x} ${points[0].yPrimary}`;

    let d = `M ${points[0].x} ${points[0].yPrimary}`;
    for (let i = 0; i < points.length - 1; i++) {
      const current = points[i];
      const next = points[i + 1];
      const controlX1 = current.x + (next.x - current.x) / 2;
      const controlY1 = current.yPrimary;
      const controlX2 = current.x + (next.x - current.x) / 2;
      const controlY2 = next.yPrimary;
      d += ` C ${controlX1} ${controlY1}, ${controlX2} ${controlY2}, ${next.x} ${next.yPrimary}`;
    }
    return d;
  }, [points]);

  // Construct area fill path underneath primary line
  const primaryAreaD = useMemo(() => {
    if (!points.length || !primaryPathD) return '';
    const lastX = points[points.length - 1].x;
    const firstX = points[0].x;
    const baseY = paddingTop + chartHeight;
    return `${primaryPathD} L ${lastX} ${baseY} L ${firstX} ${baseY} Z`;
  }, [primaryPathD, points, chartHeight]);

  // Construct secondary line path
  const secondaryPathD = useMemo(() => {
    if (!showSecondary || !points.length) return '';
    if (points.length === 1) return `M ${points[0].x} ${points[0].ySecondary}`;

    let d = `M ${points[0].x} ${points[0].ySecondary}`;
    for (let i = 0; i < points.length - 1; i++) {
      const current = points[i];
      const next = points[i + 1];
      const controlX1 = current.x + (next.x - current.x) / 2;
      const controlY1 = current.ySecondary;
      const controlX2 = current.x + (next.x - current.x) / 2;
      const controlY2 = next.ySecondary;
      d += ` C ${controlX1} ${controlY1}, ${controlX2} ${controlY2}, ${next.x} ${next.ySecondary}`;
    }
    return d;
  }, [points, showSecondary]);

  // Grid tick values (4 steps)
  const yTicks = [0, Math.round(maxPurchaseVal * 0.33), Math.round(maxPurchaseVal * 0.66), maxPurchaseVal];

  const activePoint = hoveredIndex !== null ? points[hoveredIndex] : null;

  return (
    <div className="bg-white border border-gray-200/80 rounded-xl p-5 shadow-xs space-y-4">
      {/* Top Header & Range Controls */}
      <div className="flex flex-col sm:flex-row sm:items-center justify-between gap-3 pb-3 border-b border-gray-100">
        <div>
          <div className="flex items-center gap-2">
            <h3 className="text-xs font-bold uppercase tracking-wider text-gray-900 font-poppins flex items-center gap-2">
              <TrendingUp className="h-4 w-4 text-[#C91F26]" />
              {title}
            </h3>
            <span className="text-[10px] font-semibold bg-red-50 text-[#C91F26] px-2 py-0.5 rounded-full border border-red-200/60">
              Live Trend
            </span>
          </div>
          <p className="text-[11px] text-gray-500 mt-0.5">{subtitle}</p>
        </div>

        <div className="flex items-center gap-3 self-start sm:self-auto">
          {/* Legend */}
          <div className="flex items-center gap-3 text-xs text-gray-500 font-medium">
            <div className="flex items-center gap-1.5">
              <span className="w-2.5 h-2.5 rounded-full bg-[#C91F26]"></span>
              <span>Purchases</span>
            </div>
            {showSecondary && (
              <div className="flex items-center gap-1.5">
                <span className="w-2.5 h-2.5 rounded-full bg-blue-500"></span>
                <span>Renewals</span>
              </div>
            )}
          </div>

          {/* Timeframe selector */}
          {onTimeRangeChange && (
            <div className="flex items-center bg-gray-100 p-0.5 rounded-lg border border-gray-200/80">
              {(['7d', '30d', '90d', '12m'] as const).map((r) => (
                <button
                  key={r}
                  onClick={() => onTimeRangeChange(r)}
                  className={`px-2.5 py-1 text-[11px] font-semibold rounded-md transition-all ${
                    timeRange === r
                      ? 'bg-white text-[#C91F26] shadow-2xs font-bold'
                      : 'text-gray-600 hover:text-gray-900'
                  }`}
                >
                  {r.toUpperCase()}
                </button>
              ))}
            </div>
          )}
        </div>
      </div>

      {/* Mini KPI Highlights Strip */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3 bg-gray-50/70 border border-gray-200/60 rounded-xl p-3 text-xs">
        <div>
          <span className="text-[11px] text-gray-500 font-medium block">Total Plan Purchases</span>
          <div className="flex items-baseline gap-1.5 mt-0.5">
            <span className="text-base font-bold text-gray-900 font-poppins">{totalPurchases}</span>
            <span className="text-[10px] font-semibold text-emerald-600 flex items-center">
              <ArrowUpRight className="h-3 w-3" /> +14.2%
            </span>
          </div>
        </div>

        <div>
          <span className="text-[11px] text-gray-500 font-medium block">Gross Revenue</span>
          <div className="flex items-baseline gap-1.5 mt-0.5">
            <span className="text-base font-bold text-gray-900 font-poppins">
              {new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(
                totalRevenue
              )}
            </span>
          </div>
        </div>

        <div>
          <span className="text-[11px] text-gray-500 font-medium block">Recurring Renewals</span>
          <div className="flex items-baseline gap-1.5 mt-0.5">
            <span className="text-base font-bold text-gray-900 font-poppins">{totalRenewals}</span>
            <span className="text-[10px] text-gray-400">cycles</span>
          </div>
        </div>

        <div>
          <span className="text-[11px] text-gray-500 font-medium block">Conversion Health</span>
          <div className="flex items-baseline gap-1.5 mt-0.5">
            <span className="text-base font-bold text-emerald-600 font-poppins">96.4%</span>
            <span className="text-[10px] text-gray-400">on-time</span>
          </div>
        </div>
      </div>

      {/* SVG Interactive Line Chart Container */}
      <div className="relative w-full overflow-hidden select-none">
        <svg
          viewBox={`0 0 ${svgWidth} ${svgHeight}`}
          className="w-full h-auto overflow-visible font-sans"
          onMouseLeave={() => setHoveredIndex(null)}
        >
          <defs>
            {/* Red Area Gradient */}
            <linearGradient id="planPurchaseFill" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#C91F26" stopOpacity="0.22" />
              <stop offset="90%" stopColor="#C91F26" stopOpacity="0.0" />
            </linearGradient>

            {/* Blue Secondary Gradient */}
            <linearGradient id="planRenewalFill" x1="0" y1="0" x2="0" y2="1">
              <stop offset="0%" stopColor="#3B82F6" stopOpacity="0.12" />
              <stop offset="90%" stopColor="#3B82F6" stopOpacity="0.0" />
            </linearGradient>

            {/* Drop Shadow for points */}
            <filter id="pointShadow" x="-20%" y="-20%" width="140%" height="140%">
              <feDropShadow dx="0" dy="1.5" stdDeviation="1.5" floodColor="#C91F26" floodOpacity="0.3" />
            </filter>
          </defs>

          {/* Horizontal Grid Lines & Y-Ticks */}
          {yTicks.map((tickVal) => {
            const yPos = paddingTop + chartHeight - (tickVal / maxPurchaseVal) * chartHeight;
            return (
              <g key={tickVal}>
                <line
                  x1={paddingLeft}
                  y1={yPos}
                  x2={svgWidth - paddingRight}
                  y2={yPos}
                  stroke="#F3F4F6"
                  strokeWidth="1"
                  strokeDasharray="4 4"
                />
                <text
                  x={paddingLeft - 8}
                  y={yPos + 3.5}
                  textAnchor="end"
                  fontSize="10"
                  fill="#9CA3AF"
                  fontWeight="500"
                >
                  {tickVal}
                </text>
              </g>
            );
          })}

          {/* Area Fill Under Primary Line */}
          {primaryAreaD && <path d={primaryAreaD} fill="url(#planPurchaseFill)" />}

          {/* Secondary Line (Renewals) */}
          {showSecondary && secondaryPathD && (
            <path
              d={secondaryPathD}
              fill="none"
              stroke="#3B82F6"
              strokeWidth="2"
              strokeDasharray="4 3"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          )}

          {/* Primary Line (Purchases) */}
          {primaryPathD && (
            <path
              d={primaryPathD}
              fill="none"
              stroke="#C91F26"
              strokeWidth="2.5"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          )}

          {/* Interactive Hover Guides and Points */}
          {points.map((pt, index) => {
            const isHovered = hoveredIndex === index;
            return (
              <g
                key={index}
                className="cursor-pointer"
                onMouseEnter={() => setHoveredIndex(index)}
              >
                {/* Invisible wide hitbox for smooth mouseover */}
                <rect
                  x={pt.x - (chartWidth / (points.length * 2))}
                  y={paddingTop}
                  width={chartWidth / points.length}
                  height={chartHeight + paddingBottom}
                  fill="transparent"
                />

                {/* Vertical Cursor Guide when Hovered */}
                {isHovered && (
                  <line
                    x1={pt.x}
                    y1={paddingTop}
                    x2={pt.x}
                    y2={paddingTop + chartHeight}
                    stroke="#C91F26"
                    strokeWidth="1.5"
                    strokeDasharray="3 3"
                    opacity="0.85"
                  />
                )}

                {/* Secondary Dot */}
                {showSecondary && (
                  <circle
                    cx={pt.x}
                    cy={pt.ySecondary}
                    r={isHovered ? 4.5 : 2.5}
                    fill="#3B82F6"
                    stroke="#FFFFFF"
                    strokeWidth="1.5"
                    className="transition-all duration-150"
                  />
                )}

                {/* Primary Dot */}
                <circle
                  cx={pt.x}
                  cy={pt.yPrimary}
                  r={isHovered ? 5.5 : 3.5}
                  fill="#C91F26"
                  stroke="#FFFFFF"
                  strokeWidth="2"
                  filter={isHovered ? 'url(#pointShadow)' : undefined}
                  className="transition-all duration-150"
                />

                {/* X-Axis Label */}
                <text
                  x={pt.x}
                  y={paddingTop + chartHeight + 16}
                  textAnchor="middle"
                  fontSize="10"
                  fill={isHovered ? '#111827' : '#6B7280'}
                  fontWeight={isHovered ? '700' : '500'}
                >
                  {pt.label}
                </text>
              </g>
            );
          })}
        </svg>

        {/* Floating Tooltip Box */}
        {activePoint && (
          <div
            className="absolute pointer-events-none z-10 transition-transform duration-75"
            style={{
              left: `${(activePoint.x / svgWidth) * 100}%`,
              top: `${(activePoint.yPrimary / svgHeight) * 100}%`,
              transform: 'translate(-50%, -120%)',
            }}
          >
            <div className="bg-gray-900 text-white px-3 py-2 rounded-lg shadow-xl text-xs space-y-1 min-w-[140px] border border-gray-700">
              <div className="font-bold text-[11px] text-gray-300 pb-1 border-b border-gray-800 flex items-center justify-between">
                <span>{activePoint.label}</span>
                <span className="text-gray-400 font-mono text-[10px]">Telemetry</span>
              </div>
              <div className="flex items-center justify-between gap-3 text-xs">
                <span className="text-gray-400 flex items-center gap-1.5">
                  <span className="w-2 h-2 rounded-full bg-[#C91F26]"></span>
                  Purchases:
                </span>
                <strong className="text-white font-mono">{activePoint.purchases} plans</strong>
              </div>
              {showSecondary && (
                <div className="flex items-center justify-between gap-3 text-xs">
                  <span className="text-gray-400 flex items-center gap-1.5">
                    <span className="w-2 h-2 rounded-full bg-blue-400"></span>
                    Renewals:
                  </span>
                  <strong className="text-white font-mono">{activePoint.renewals}</strong>
                </div>
              )}
              <div className="flex items-center justify-between gap-3 text-xs pt-1 border-t border-gray-800">
                <span className="text-gray-400">Revenue:</span>
                <strong className="text-emerald-400 font-mono">
                  {new Intl.NumberFormat('en-IN', { style: 'currency', currency: 'INR', maximumFractionDigits: 0 }).format(
                    activePoint.revenue
                  )}
                </strong>
              </div>
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
