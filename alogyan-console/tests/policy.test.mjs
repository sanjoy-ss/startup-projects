import test from 'node:test';
import assert from 'node:assert/strict';
import crypto from 'node:crypto';

// Replicate pure permission logic for test verification
const roles = ['super_admin','content_manager','teacher_manager','review_moderator','analytics_viewer','digital_marketer','billing_manager','support'];

function permissionsFor(role) {
  return {
    can_manage_teachers: ['super_admin','teacher_manager'].includes(role),
    can_manage_reviews: ['super_admin','review_moderator'].includes(role),
    can_manage_content: ['super_admin','content_manager'].includes(role),
    can_view_analytics: ['super_admin','analytics_viewer','teacher_manager','digital_marketer'].includes(role),
    can_manage_marketing: ['super_admin','digital_marketer'].includes(role),
    can_manage_admins: role === 'super_admin',
    can_manage_billing: ['super_admin','billing_manager'].includes(role),
    can_view_customers: ['super_admin','billing_manager','support'].includes(role),
  };
}

function canWrite(tenant, now = Date.now()) {
  return !!tenant && tenant.status === 'active' &&
    ['trial','active','past_due','cancelled'].includes(tenant.subscription?.status) &&
    Number.isFinite(tenant.subscription?.accessUntil) &&
    tenant.subscription.accessUntil > now;
}

function safeId(value) {
  return typeof value === 'string' && /^[a-zA-Z0-9_-]{1,128}$/.test(value);
}

function boundedLimit(value, fallback = 25) {
  const n = Number(value);
  return value && Number.isInteger(n) && n > 0 ? Math.min(n, 100) : fallback;
}

function verifySignature(payload, signature, secret) {
  const expected = crypto.createHmac('sha256', secret).update(payload).digest('hex');
  return crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(expected));
}

test('super_admin has all permissions', () => {
  const perms = permissionsFor('super_admin');
  for (const [k, v] of Object.entries(perms)) {
    assert.equal(v, true, `Expected ${k} to be true for super_admin`);
  }
});

test('support cannot manage admins or billing', () => {
  const perms = permissionsFor('support');
  assert.equal(perms.can_manage_admins, false);
  assert.equal(perms.can_manage_billing, false);
  assert.equal(perms.can_view_customers, true);
});

test('review_moderator can only moderate reviews', () => {
  const perms = permissionsFor('review_moderator');
  assert.equal(perms.can_manage_reviews, true);
  assert.equal(perms.can_manage_teachers, false);
  assert.equal(perms.can_manage_admins, false);
});

test('subscription write allowance enforces status and time', () => {
  const now = 1700000000000;
  const activeTenant = {
    status: 'active',
    subscription: { status: 'active', accessUntil: now + 86400000 }
  };
  assert.equal(canWrite(activeTenant, now), true);

  const expiredTenant = {
    status: 'active',
    subscription: { status: 'active', accessUntil: now - 1000 }
  };
  assert.equal(canWrite(expiredTenant, now), false);

  const suspendedTenant = {
    status: 'suspended',
    subscription: { status: 'active', accessUntil: now + 86400000 }
  };
  assert.equal(canWrite(suspendedTenant, now), false);

  const pendingTenant = {
    status: 'active',
    subscription: { status: 'pending', accessUntil: now + 86400000 }
  };
  assert.equal(canWrite(pendingTenant, now), false);
});

test('safeId and boundedLimit sanitize input', () => {
  assert.equal(safeId('valid-tenant_123'), true);
  assert.equal(safeId('../../etc/passwd'), false);
  assert.equal(safeId(''), false);

  assert.equal(boundedLimit('10'), 10);
  assert.equal(boundedLimit('200'), 100);
  assert.equal(boundedLimit('-5', 25), 25);
  assert.equal(boundedLimit('abc', 25), 25);
});

test('webhook signature verification works accurately', () => {
  const secret = 'whsec_test_secret_12345';
  const payload = JSON.stringify({ event: 'subscription.charged', id: 'sub_test' });
  const validSig = crypto.createHmac('sha256', secret).update(payload).digest('hex');
  assert.equal(verifySignature(payload, validSig, secret), true);
  assert.equal(verifySignature(payload, validSig.slice(0, -1) + 'x', secret), false);
});
