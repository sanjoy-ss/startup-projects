# Teacher CMS Lite & Admin RBAC Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a clean, professional login screen with 1-click test personas, an Admin Batch management & RBAC system with faculty-to-batch assignments, and a mobile-first "Teacher CMS Lite" phone interface featuring today's schedule, 1-tap attendance, and direct student contact shortcuts.

**Architecture:** Extend Next.js 16 App Router in `alogyan-teachers-cms` with role-aware layouts: an enhanced Admin management interface (`/batches` & `/settings/staff`) with batch assignment bindings, and a dedicated, lightweight mobile-first interface (`/dashboard/teacher-lite` and mobile bottom navigation) for teachers on phone screens. Modernized login with quick persona switching for seamless testing and demonstration.

**Tech Stack:** Next.js 16 (App Router), React 19, TypeScript, Tailwind CSS, Lucide Icons / Material Symbols, TanStack Query, Firebase Auth / Firestore.

**Spec:** [docs/superpowers/specs/2026-09-28-teacher-cms-lite-and-admin-rbac-design.md](file:///Users/sanjoysarkar/web_app/start-up-projects/docs/superpowers/specs/2026-09-28-teacher-cms-lite-and-admin-rbac-design.md)

## Global Constraints

- Must work flawlessly on phone screens (responsive, minimum touch target 44px, no horizontal scroll).
- Preserve existing data schemas in `types/index.ts` while extending with optional fields (`assignedTeacherId`, `teacherName`).
- Strict RBAC: Teachers only view and edit attendance/notes/grades for their assigned batches (`assignedBatchIds`).
- Keep code clean, performant, and adhering to Alogyan design tokens.

---

### Task 1: Clean & Professional Login UI/UX with Quick Persona Switcher

**Files:**
- Create: `components/auth/QuickPersonaSwitcher.tsx`
- Modify: `app/(auth)/login/page.tsx`
- Modify: `components/auth/EmailForm.tsx`
- Modify: `components/auth/PhoneForm.tsx`

**Interfaces:**
- Produces: `QuickPersonaSwitcher` component rendering 1-click login test personas:
  - 🛡️ "Director / Admin" (email: `admin@alogyan.com`, role: `owner`)
  - 👨‍🏫 "Faculty / Teacher" (email: `teacher@alogyan.com`, role: `teacher`)
- Updates `app/(auth)/login/page.tsx` to a high-converting, minimal, sleek card with smooth tab switching between Email and Phone OTP.

- [ ] **Step 1: Create QuickPersonaSwitcher component**

```tsx
// components/auth/QuickPersonaSwitcher.tsx
'use client';

import React from 'react';

interface QuickPersonaSwitcherProps {
  onSelectPersona: (email: string, role: 'owner' | 'teacher') => void;
  isLoading?: boolean;
}

export default function QuickPersonaSwitcher({
  onSelectPersona,
  isLoading = false,
}: QuickPersonaSwitcherProps) {
  return (
    <div className="mt-6 pt-5 border-t border-gray-100 dark:border-gray-800">
      <div className="flex items-center justify-between mb-2.5">
        <span className="text-xs font-semibold text-gray-500 uppercase tracking-wider">
          Quick Demo Login
        </span>
        <span className="text-[11px] bg-red-50 text-red-700 px-2 py-0.5 rounded-full font-medium">
          Instant Access
        </span>
      </div>
      <div className="grid grid-cols-2 gap-2.5">
        <button
          type="button"
          disabled={isLoading}
          onClick={() => onSelectPersona('director@alogyan.com', 'owner')}
          className="flex flex-col items-start p-2.5 rounded-xl border border-gray-200 hover:border-red-600 hover:bg-red-50/40 transition-all text-left group"
        >
          <div className="flex items-center gap-1.5 text-xs font-bold text-gray-800 group-hover:text-red-700">
            <span>🛡️</span> Director / Admin
          </div>
          <span className="text-[11px] text-gray-400 mt-0.5">
            Full Batches & RBAC
          </span>
        </button>

        <button
          type="button"
          disabled={isLoading}
          onClick={() => onSelectPersona('teacher@alogyan.com', 'teacher')}
          className="flex flex-col items-start p-2.5 rounded-xl border border-gray-200 hover:border-red-600 hover:bg-red-50/40 transition-all text-left group"
        >
          <div className="flex items-center gap-1.5 text-xs font-bold text-gray-800 group-hover:text-red-700">
            <span>👨‍🏫</span> Faculty / Teacher
          </div>
          <span className="text-[11px] text-gray-400 mt-0.5">
            Teacher Lite (Phone)
          </span>
        </button>
      </div>
    </div>
  );
}
```

- [ ] **Step 2: Update `app/(auth)/login/page.tsx` with modern UI and persona handler**
- [ ] **Step 3: Test login page on desktop & mobile viewport, verify quick persona selection**
- [ ] **Step 4: Commit login changes**

```bash
git add components/auth/QuickPersonaSwitcher.tsx app/\(auth\)/login/page.tsx
git commit -m "feat(auth): clean professional login UI with instant persona switcher"
```

---

### Task 2: Admin Batch Management with Faculty Assignment

**Files:**
- Modify: `types/index.ts` (add `assignedTeacherId?: string`, `assignedTeacherName?: string` to `Batch`)
- Modify: `app/(dashboard)/batches/new/page.tsx`
- Modify: `app/(dashboard)/batches/page.tsx`

**Interfaces:**
- Consumes: `UserProfile` from `/api/staff` where `role === 'teacher'`.
- Produces: Batch forms and cards displaying assigned teacher with quick reassignment.

- [ ] **Step 1: Extend Batch interface in `types/index.ts`**
Add:
```typescript
assignedTeacherId?: string;
assignedTeacherName?: string;
```
- [ ] **Step 2: Add Teacher dropdown to Batch creation in `app/(dashboard)/batches/new/page.tsx`**
- [ ] **Step 3: Display assigned teacher avatar and badge on batch cards in `app/(dashboard)/batches/page.tsx`**
- [ ] **Step 4: Verify batch creation with assigned teacher**
- [ ] **Step 5: Commit batch updates**

```bash
git add types/index.ts app/\(dashboard\)/batches/
git commit -m "feat(batches): add teacher assignment and faculty schedule view"
```

---

### Task 3: Admin Staff & Role-Based Access Control (RBAC) with Batch Binding

**Files:**
- Modify: `app/(dashboard)/settings/staff/page.tsx`
- Modify: `lib/rbac.ts`

**Interfaces:**
- Consumes: Batches list from `/api/batches`.
- Produces: Enhanced Staff Edit modal where selecting role `teacher` renders a multi-select checklist of active batches for `assignedBatchIds`.

- [ ] **Step 1: In `app/(dashboard)/settings/staff/page.tsx`, fetch available batches for teacher assignment**
- [ ] **Step 2: Add "Assigned Batches" multi-select section in the Staff Modal when `formData.role === 'teacher'`**
- [ ] **Step 3: Update staff table list to show assigned batches count and names**
- [ ] **Step 4: Verify staff creation/edit with assigned batches**
- [ ] **Step 5: Commit staff RBAC updates**

```bash
git add app/\(dashboard\)/settings/staff/page.tsx lib/rbac.ts
git commit -m "feat(rbac): implement teacher-batch assignment in staff settings"
```

---

### Task 4: Teacher CMS Lite - Mobile Shell, Today's Schedule & Bottom Navigation

**Files:**
- Create: `components/teacher-lite/TeacherLiteShell.tsx`
- Create: `components/teacher-lite/TeacherBottomNav.tsx`
- Create: `components/teacher-lite/TeacherTodaySchedule.tsx`
- Create: `app/(dashboard)/teacher-lite/page.tsx`
- Modify: `app/(dashboard)/dashboard/page.tsx` (redirect or prompt for Teacher Lite on mobile)

**Interfaces:**
- Consumes: Current user session (`role === 'teacher'` or admin preview mode).
- Produces: Dedicated mobile-first layout with fixed bottom navigation bar:
  - `today` (Timeline of today's classes + quick attendance CTA)
  - `batches` (My assigned batches)
  - `attendance` (1-tap attendance sheet)
  - `academic` (Marks & notes)
  - `profile` (Account info)

- [ ] **Step 1: Create `TeacherBottomNav.tsx` with thumb-friendly touch targets**
- [ ] **Step 2: Create `TeacherTodaySchedule.tsx` showing active/upcoming classes for today**
- [ ] **Step 3: Create `TeacherLiteShell.tsx` unifying header, content, and bottom navigation**
- [ ] **Step 4: Create `app/(dashboard)/teacher-lite/page.tsx`**
- [ ] **Step 5: Test on mobile viewport (375px - 430px iPhone sizes)**
- [ ] **Step 6: Commit Teacher Lite shell**

```bash
git add components/teacher-lite/ app/\(dashboard\)/teacher-lite/
git commit -m "feat(teacher-lite): mobile shell, today schedule and bottom navigation"
```

---

### Task 5: Teacher CMS Lite - 1-Tap Attendance & WhatsApp Parent Alert

**Files:**
- Create: `components/teacher-lite/TeacherAttendanceSheet.tsx`
- Modify: `app/(dashboard)/teacher-lite/page.tsx`

**Interfaces:**
- Consumes: Selected batch ID and student roster.
- Produces:
  - 1-tap "Mark All Present" toggle.
  - Large touch targets for Present (Green), Absent (Red), Late (Yellow).
  - Real-time attendance counters.
  - "Send WhatsApp to Absent Parents" action generating `wa.me` links with customizable absentee text.

- [ ] **Step 1: Implement `TeacherAttendanceSheet.tsx` with fast local state and batch selector**
- [ ] **Step 2: Add WhatsApp absentee notification generator**
- [ ] **Step 3: Connect to attendance submission API**
- [ ] **Step 4: Verify attendance marking and WhatsApp message formatting**
- [ ] **Step 5: Commit attendance sheet**

```bash
git add components/teacher-lite/TeacherAttendanceSheet.tsx app/\(dashboard\)/teacher-lite/
git commit -m "feat(teacher-lite): 1-tap touch attendance sheet with WhatsApp parent alerts"
```

---

### Task 6: Teacher CMS Lite - Student Roster with Direct Phone/WhatsApp & Quick Academic Tools

**Files:**
- Create: `components/teacher-lite/TeacherBatchRoster.tsx`
- Create: `components/teacher-lite/TeacherAcademicQuickGrading.tsx`
- Modify: `app/(dashboard)/teacher-lite/page.tsx`

**Interfaces:**
- Consumes: Assigned batch student list.
- Produces:
  - Student card with direct `tel:` call button and WhatsApp chat button.
  - Quick test mark scoring inputs with numeric touch keypad support.
  - Quick homework/note upload trigger.

- [ ] **Step 1: Implement `TeacherBatchRoster.tsx` with direct call and WhatsApp actions**
- [ ] **Step 2: Implement `TeacherAcademicQuickGrading.tsx` for quick score entry**
- [ ] **Step 3: Connect all tabs in `TeacherLiteShell`**
- [ ] **Step 4: Verify phone calling and WhatsApp links on mobile**
- [ ] **Step 5: Commit student roster and academic tools**

```bash
git add components/teacher-lite/ app/\(dashboard\)/teacher-lite/
git commit -m "feat(teacher-lite): student phone contacts and quick academic grading"
```

---

### Task 7: Admin "Preview as Teacher" Switcher & Full End-to-End Verification

**Files:**
- Modify: `components/layout/Header.tsx` (add "Teacher View (Mobile)" switcher button)
- Run typecheck and build validation

**Interfaces:**
- Allows an Admin to jump directly into the Teacher Lite view to inspect the mobile experience.
- Full verification of all acceptance criteria.

- [ ] **Step 1: Add "Preview Teacher Lite" button in Admin Header**
- [ ] **Step 2: Run `pnpm run build` or Next.js type check in `alogyan-teachers-cms`**
- [ ] **Step 3: Fix any lint or compilation errors**
- [ ] **Step 4: Commit integration enhancements**

```bash
git add components/layout/Header.tsx
git commit -m "feat: add admin teacher preview switch and verify build"
```
