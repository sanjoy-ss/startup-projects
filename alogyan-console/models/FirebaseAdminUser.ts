// models/FirebaseAdminUser.ts
import { Timestamp } from 'firebase/firestore';

export type AdminRole = 
  | 'super_admin' 
  | 'content_manager' 
  | 'teacher_manager' 
  | 'review_moderator' 
  | 'analytics_viewer' 
  | 'digital_marketer';

export interface AdminPermissions {
  can_manage_teachers: boolean;
  can_manage_reviews: boolean;
  can_manage_content: boolean;
  can_view_analytics: boolean;
  can_manage_admins: boolean;
  can_manage_marketing: boolean;
}

export interface FirebaseAdminUser {
  uid: string;
  username: string;
  email: string;
  role: AdminRole;
  permissions: AdminPermissions;
  is_active: boolean;
  last_login: Timestamp | null;
  created_by: string;
  created_at: Timestamp;
  updated_at: Timestamp;
}

export interface AdminUserData {
  uid: string;
  username: string;
  email: string;
  role: AdminRole;
  permissions: AdminPermissions;
  is_active: boolean;
}

/**
 * Convert Firestore admin user to safe data object (without sensitive fields)
 */
export function toAdminUserData(admin: FirebaseAdminUser): AdminUserData {
  return {
    uid: admin.uid,
    username: admin.username,
    email: admin.email,
    role: admin.role,
    permissions: admin.permissions,
    is_active: admin.is_active
  };
}

/**
 * Check if admin has a specific permission
 */
export function checkPermission(admin: FirebaseAdminUser, permission: keyof AdminPermissions): boolean {
  return admin.permissions[permission] === true;
}

/**
 * Get role display name
 */
export function getRoleDisplayName(role: AdminRole): string {
  const roleNames: Record<AdminRole, string> = {
    'super_admin': 'Super Admin',
    'content_manager': 'Content Manager',
    'teacher_manager': 'Teacher Manager',
    'review_moderator': 'Review Moderator',
    'analytics_viewer': 'Analytics Viewer',
    'digital_marketer': 'Digital Marketer'
  };
  return roleNames[role];
}

/**
 * Validate admin role
 */
export function isValidRole(role: string): role is AdminRole {
  const validRoles: AdminRole[] = [
    'super_admin',
    'content_manager',
    'teacher_manager',
    'review_moderator',
    'analytics_viewer',
    'digital_marketer'
  ];
  return validRoles.includes(role as AdminRole);
}

export default FirebaseAdminUser;
