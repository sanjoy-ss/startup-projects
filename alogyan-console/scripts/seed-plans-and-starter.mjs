import { initializeApp, cert, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const account = process.env.FIREBASE_SERVICE_ACCOUNT_B64
  ? JSON.parse(Buffer.from(process.env.FIREBASE_SERVICE_ACCOUNT_B64, 'base64').toString())
  : null;
initializeApp({ credential: account ? cert(account) : applicationDefault() });

const db = getFirestore();

const plans = [
  {
    id: 'starter',
    name: 'Starter Plan',
    tier: 'starter',
    description: 'Essential management toolkit for independent tutors and single-campus academies.',
    amount: 99900,
    currency: 'INR',
    period: 'monthly',
    interval: 1,
    totalCount: 12,
    active: true,
    popular: false,
    maxStudents: 100,
    maxBatches: 10,
    maxBranches: 2,
    features: [
      'Up to 100 Enrolled Students',
      'Up to 10 Active Batches',
      '2 Branch Locations (Main + Secondary)',
      'QR & Manual Daily Attendance',
      'Student Fee Collection & Receipts',
      'Digital Study Notes & Materials',
      'Exams, Grading & Report Cards',
      'Instant Email Alerts to Parents',
      'Standard Email & In-App Support',
    ],
    highlightBadge: 'Popular for Tutors',
  },
  {
    id: 'pro',
    name: 'Pro Academy',
    tier: 'pro',
    description: 'Advanced automation, parent communication, and financial reporting for expanding institutes.',
    amount: 249900,
    currency: 'INR',
    period: 'monthly',
    interval: 1,
    totalCount: 12,
    active: true,
    popular: true,
    maxStudents: 500,
    maxBatches: 50,
    maxBranches: 5,
    features: [
      'Up to 500 Enrolled Students',
      'Up to 50 Active Batches',
      '5 Campus / Branch Locations',
      'Everything in Starter Plan',
      'Automated Invoicing & GST Numbering',
      'WhatsApp & Telegram Broadcasts',
      'Staff RBAC with Granular Permissions',
      'Google Calendar Batch Sync',
      'Branch KPI & Profit-Loss Analytics',
      'Verified Listing Badge on Discovery',
      'Priority Support (Response < 4h)',
    ],
    highlightBadge: 'Most Popular',
  },
  {
    id: 'enterprise',
    name: 'Enterprise Network',
    tier: 'enterprise',
    description: 'Multi-campus coaching networks requiring custom limits, custom branding, and dedicated SLAs.',
    amount: 499900,
    currency: 'INR',
    period: 'monthly',
    interval: 1,
    totalCount: 12,
    active: true,
    popular: false,
    maxStudents: 2500,
    maxBatches: 250,
    maxBranches: 25,
    features: [
      '2,500+ Students & Unlimited Batches',
      'Up to 25 Campus Locations',
      'All Pro Automation & Analytics',
      'Dedicated Customer Success Manager',
      'Custom Domain (academy.yourbrand.com)',
      'Featured Top Placement on Alogyan Discovery',
      'White-Glove Data Migration Assistance',
      '99.9% Uptime SLA & 24/7 Phone Support',
    ],
    highlightBadge: 'For Large Institutes',
  },
];

console.log('--- SEEDING PLANS ---');
for (const plan of plans) {
  const ref = db.collection('plans').doc(plan.id);
  await ref.set({
    ...plan,
    updatedAt: new Date(),
    createdAt: new Date(),
  }, { merge: true });
  console.log(`✅ Plan ${plan.id} (${plan.name}) seeded.`);
}

console.log('\n--- SETTING STARTER PLAN FOR admin@alogyan.com ---');
const tenantId = 'VfdZZKJHA9VMdqZfvglOWacK32g1';
const tenantRef = db.collection('tenants').doc(tenantId);
await tenantRef.set({
  name: 'Alogyan Academy',
  subscription: {
    status: 'active',
    planId: 'starter',
    planName: 'Starter Plan',
    tier: 'starter',
    amount: 99900,
    currency: 'INR',
    period: 'monthly',
    interval: 1,
    accessUntil: 4102444800000, // Active until 2100
    cancelAtPeriodEnd: false,
    startedAt: new Date(),
  },
  updatedAt: new Date(),
}, { merge: true });

console.log(`✅ Tenant ${tenantId} updated to Starter Plan with active subscription.`);
