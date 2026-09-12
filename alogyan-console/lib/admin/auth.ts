import 'server-only';
import { adminAuth, adminDb } from '@/lib/firebase-admin';
import type { NextRequest } from 'next/server';

export const CONSOLE_COOKIE = 'alogyan-console-session';
export const roles = ['super_admin','content_manager','teacher_manager','review_moderator','analytics_viewer','digital_marketer','billing_manager','support'] as const;
export type AdminSession = { uid: string; username: string; email: string; role: string; permissions: Record<string, boolean> };
export function permissionsFor(role: string): Record<string, boolean> {
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
export async function staffFor(uid: string): Promise<AdminSession | null> {
 const doc = await adminDb.collection('platformStaff').doc(uid).get();
 const data = doc.data();
 if (!data || data.is_active !== true || !roles.includes(data.role)) return null;
 return { uid, username: data.username || data.email, email: data.email, role: data.role, permissions: permissionsFor(data.role) };
}
export async function verifyAdminToken(token: string): Promise<AdminSession | null> {
 try { const identity = await adminAuth.verifySessionCookie(token, true); return await staffFor(identity.uid); } catch { return null; }
}
export function assertOrigin(req: NextRequest) {
 if (!['GET','HEAD','OPTIONS'].includes(req.method) && req.headers.get('origin') !== req.nextUrl.origin) throw new Error('AUTH_ORIGIN');
}
