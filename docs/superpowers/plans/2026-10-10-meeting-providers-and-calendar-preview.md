# Meeting Providers & Google Calendar Preview Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement Google Meet, Zoom, and extensible Custom meeting provider configurations with default selection, Google Calendar access, an interactive calendar preview section, and batch scheduling integration in Alogyan Teacher CMS.

**Architecture:** A unified `TeacherMeetingSettings` Firestore document stored at `teachers/{teacherId}/settings/meetings`, merged with existing Google Calendar OAuth integration, coupled with dedicated settings & preview API routes, polished modular settings components in the CMS Integrations tab, and provider auto-fill in `BatchForm.tsx`.

**Tech Stack:** Next.js 16 (App Router), React 19, TypeScript, Firebase Admin / Firestore, Tailwind CSS, Material Symbols.

**Spec:** `docs/superpowers/specs/2026-10-10-meeting-providers-and-calendar-preview-design.md`

## Global Constraints
- Target codebase: `alogyan-teachers-cms`
- Next.js App Router conventions with `verifyOwnerTenant(req)` or `assertAuthorized(req)` server-side guards.
- Encrypt sensitive client secrets with AES-256-GCM before writing to Firestore.
- Non-breaking changes: retain backwards compatibility with existing batches and existing Google Calendar OAuth endpoints.
- Strict TypeScript: no `any` where types are definable, code must pass `npx tsc --noEmit`.

---

### Task 1: Meeting Provider Domain Types & Batch Schema Update

**Files:**
- Modify: `types/index.ts:140-155`

**Interfaces:**
- Produces:
  - `MeetingProviderType`: `'google_meet' | 'zoom' | 'custom'`
  - `GoogleMeetConfig`
  - `ZoomConfig`
  - `CustomMeetingProvider`
  - `TeacherMeetingSettings`
  - `CalendarPreviewItem`
  - `Batch.meetingProvider?: string`

- [ ] **Step 1: Add Meeting Provider & Calendar Preview Types**
Add the following interfaces to `types/index.ts`:

```typescript
// ============================
// MEETING PROVIDERS & CALENDAR PREVIEW
// ============================
export type MeetingProviderType = 'google_meet' | 'zoom' | 'custom';

export interface GoogleMeetConfig {
  enabled: boolean;
  mode: 'calendar_auto' | 'permanent_link';
  permanentLink?: string;
  autoSyncBatches: boolean;
  defaultReminderMins: number;
}

export interface ZoomConfig {
  enabled: boolean;
  mode: 'pmi' | 'api';
  pmiLink?: string;
  meetingId?: string;
  passcode?: string;
  hostKey?: string;
  apiCredentials?: {
    accountId?: string;
    clientId?: string;
    clientSecretEncrypted?: string;
    hasCredentials?: boolean;
  };
}

export interface CustomMeetingProvider {
  id: string;
  name: string;
  meetingUrl: string;
  instructions?: string;
  enabled: boolean;
  createdAt: string;
}

export interface TeacherMeetingSettings {
  defaultProvider: 'google_meet' | 'zoom' | string;
  googleMeet: GoogleMeetConfig;
  zoom: ZoomConfig;
  customProviders: CustomMeetingProvider[];
  updatedAt?: string;
}

export interface CalendarPreviewItem {
  batchId: string;
  batchName: string;
  subject: string;
  day: string;
  startTime: string;
  endTime: string;
  durationMins: number;
  provider: 'google_meet' | 'zoom' | 'custom';
  providerName: string;
  meetingLink?: string;
  googleEventUrl?: string;
  googleEventId?: string;
  syncStatus: 'synced' | 'pending' | 'unlinked';
  studentCount: number;
}
```

- [ ] **Step 2: Update Batch interface in `types/index.ts`**
In `types/index.ts`, add `meetingProvider?: string;` to the `Batch` interface alongside `meetingLink`.

- [ ] **Step 3: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 4: Commit**
```bash
git add types/index.ts
git commit -m "feat(types): add meeting provider and calendar preview types"
```

---

### Task 2: Meeting Providers Server Utilities (`lib/meeting-providers.ts`)

**Files:**
- Create: `lib/meeting-providers.ts`

**Interfaces:**
- Consumes: `TeacherMeetingSettings`, `GoogleMeetConfig`, `ZoomConfig`, `CustomMeetingProvider` from `@/types`
- Produces:
  - `getDefaultMeetingSettings(): TeacherMeetingSettings`
  - `getTeacherMeetingSettings(teacherId: string): Promise<TeacherMeetingSettings>`
  - `saveTeacherMeetingSettings(teacherId: string, settings: Partial<TeacherMeetingSettings>): Promise<TeacherMeetingSettings>`
  - `validateMeetingSettings(input: unknown): { isValid: boolean; error?: string; cleanSettings?: TeacherMeetingSettings }`

- [ ] **Step 1: Implement `lib/meeting-providers.ts`**
Create `lib/meeting-providers.ts`:
```typescript
import 'server-only';

import { FieldValue } from 'firebase-admin/firestore';
import { adminDb } from '@/lib/firebase-admin';
import type { TeacherMeetingSettings, CustomMeetingProvider } from '@/types';
import { encryptSecret } from '@/lib/google-calendar';

export function getDefaultMeetingSettings(): TeacherMeetingSettings {
  return {
    defaultProvider: 'google_meet',
    googleMeet: {
      enabled: true,
      mode: 'calendar_auto',
      permanentLink: '',
      autoSyncBatches: true,
      defaultReminderMins: 60,
    },
    zoom: {
      enabled: false,
      mode: 'pmi',
      pmiLink: '',
      meetingId: '',
      passcode: '',
      hostKey: '',
    },
    customProviders: [],
  };
}

export function validateMeetingUrl(url: string): boolean {
  if (!url) return false;
  try {
    const parsed = new URL(url);
    return parsed.protocol === 'https:' || parsed.protocol === 'http:';
  } catch {
    return false;
  }
}

export async function getTeacherMeetingSettings(teacherId: string): Promise<TeacherMeetingSettings> {
  const doc = await adminDb.collection('teachers').doc(teacherId).collection('settings').doc('meetings').get();
  if (!doc.exists) {
    return getDefaultMeetingSettings();
  }
  const data = doc.data() as Partial<TeacherMeetingSettings>;
  const defaults = getDefaultMeetingSettings();
  return {
    defaultProvider: data.defaultProvider || defaults.defaultProvider,
    googleMeet: {
      ...defaults.googleMeet,
      ...(data.googleMeet || {}),
    },
    zoom: {
      ...defaults.zoom,
      ...(data.zoom || {}),
      apiCredentials: data.zoom?.apiCredentials ? {
        accountId: data.zoom.apiCredentials.accountId || '',
        clientId: data.zoom.apiCredentials.clientId || '',
        hasCredentials: Boolean(data.zoom.apiCredentials.clientSecretEncrypted),
      } : undefined,
    },
    customProviders: Array.isArray(data.customProviders) ? data.customProviders : [],
    updatedAt: data.updatedAt,
  };
}

export async function saveTeacherMeetingSettings(
  teacherId: string,
  input: Partial<TeacherMeetingSettings>
): Promise<TeacherMeetingSettings> {
  const current = await getTeacherMeetingSettings(teacherId);

  const updated: TeacherMeetingSettings = {
    defaultProvider: input.defaultProvider || current.defaultProvider,
    googleMeet: {
      enabled: Boolean(input.googleMeet?.enabled ?? current.googleMeet.enabled),
      mode: input.googleMeet?.mode === 'permanent_link' ? 'permanent_link' : 'calendar_auto',
      permanentLink: typeof input.googleMeet?.permanentLink === 'string' ? input.googleMeet.permanentLink.trim() : current.googleMeet.permanentLink,
      autoSyncBatches: Boolean(input.googleMeet?.autoSyncBatches ?? current.googleMeet.autoSyncBatches),
      defaultReminderMins: Number(input.googleMeet?.defaultReminderMins || current.googleMeet.defaultReminderMins || 60),
    },
    zoom: {
      enabled: Boolean(input.zoom?.enabled ?? current.zoom.enabled),
      mode: input.zoom?.mode === 'api' ? 'api' : 'pmi',
      pmiLink: typeof input.zoom?.pmiLink === 'string' ? input.zoom.pmiLink.trim() : current.zoom.pmiLink,
      meetingId: typeof input.zoom?.meetingId === 'string' ? input.zoom.meetingId.trim() : current.zoom.meetingId,
      passcode: typeof input.zoom?.passcode === 'string' ? input.zoom.passcode.trim() : current.zoom.passcode,
      hostKey: typeof input.zoom?.hostKey === 'string' ? input.zoom.hostKey.trim() : current.zoom.hostKey,
    },
    customProviders: Array.isArray(input.customProviders)
      ? input.customProviders.map((cp: CustomMeetingProvider) => ({
          id: cp.id || `custom_${Date.now()}_${Math.random().toString(36).substring(2, 7)}`,
          name: (cp.name || 'Custom Provider').trim(),
          meetingUrl: (cp.meetingUrl || '').trim(),
          instructions: (cp.instructions || '').trim(),
          enabled: cp.enabled !== false,
          createdAt: cp.createdAt || new Date().toISOString(),
        }))
      : current.customProviders,
  };

  await adminDb.collection('teachers').doc(teacherId).collection('settings').doc('meetings').set({
    ...updated,
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });

  return updated;
}
```

- [ ] **Step 2: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**
```bash
git add lib/meeting-providers.ts
git commit -m "feat(meetings): add server meeting provider utilities and Firestore persistence"
```

---

### Task 3: Meeting Settings API Route (`app/api/settings/meetings/route.ts`)

**Files:**
- Create: `app/api/settings/meetings/route.ts`

**Interfaces:**
- Consumes: `verifyOwnerTenant`, `getTeacherMeetingSettings`, `saveTeacherMeetingSettings`, `getGoogleIntegration`
- Produces:
  - `GET /api/settings/meetings`: returns `{ settings, googleCalendar: { connected, email, calendarId } }`
  - `PUT /api/settings/meetings`: updates meeting settings

- [ ] **Step 1: Implement `app/api/settings/meetings/route.ts`**
```typescript
import { NextRequest } from 'next/server';
import { verifyOwnerTenant } from '@/lib/platform/owner';
import { errorResponse, successResponse } from '@/lib/api-response';
import { getGoogleIntegration } from '@/lib/google-calendar';
import { getTeacherMeetingSettings, saveTeacherMeetingSettings } from '@/lib/meeting-providers';
import type { TeacherMeetingSettings } from '@/types';

export async function GET(req: NextRequest) {
  try {
    const teacherId = await verifyOwnerTenant(req);
    const [settings, googleIntegration] = await Promise.all([
      getTeacherMeetingSettings(teacherId),
      getGoogleIntegration(teacherId),
    ]);

    return successResponse({
      settings,
      googleCalendar: {
        connected: googleIntegration?.status === 'connected',
        googleAccountEmail: googleIntegration?.googleAccountEmail || null,
        calendarId: googleIntegration?.calendarId || null,
      },
    });
  } catch (error: unknown) {
    const err = error as Error;
    if (err.message?.startsWith('AUTH_')) return errorResponse(err.message, 'Unauthorized', 401);
    return errorResponse('INTERNAL_ERROR', 'Unable to load meeting settings', 500);
  }
}

export async function PUT(req: NextRequest) {
  try {
    const teacherId = await verifyOwnerTenant(req);
    const body = await req.json() as Partial<TeacherMeetingSettings>;
    const updated = await saveTeacherMeetingSettings(teacherId, body);

    return successResponse({ settings: updated });
  } catch (error: unknown) {
    const err = error as Error;
    if (err.message?.startsWith('AUTH_')) return errorResponse(err.message, 'Unauthorized', 401);
    return errorResponse('INTERNAL_ERROR', 'Unable to save meeting settings', 500);
  }
}
```

- [ ] **Step 2: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**
```bash
git add app/api/settings/meetings/route.ts
git commit -m "feat(api): add meeting settings GET and PUT API route"
```

---

### Task 4: Calendar Preview API Route (`app/api/settings/meetings/calendar-preview/route.ts`)

**Files:**
- Create: `app/api/settings/meetings/calendar-preview/route.ts`

**Interfaces:**
- Consumes: `verifyOwnerTenant`, `adminDb`, `ScheduleSlot`, `CalendarPreviewItem`
- Produces:
  - `GET /api/settings/meetings/calendar-preview`: returns `{ events: CalendarPreviewItem[] }`

- [ ] **Step 1: Implement Calendar Preview route**
Create `app/api/settings/meetings/calendar-preview/route.ts`:
Calculate end times from `startTime` and `durationMins`. Read the batch's `meetingProvider` (defaulting to Google Meet or Custom), `meetingLink`, and query the `calendarEvents` subcollection for synced Google Calendar links.

```typescript
import { NextRequest } from 'next/server';
import { verifyOwnerTenant } from '@/lib/platform/owner';
import { errorResponse, successResponse } from '@/lib/api-response';
import { adminDb } from '@/lib/firebase-admin';
import type { CalendarPreviewItem, ScheduleSlot } from '@/types';

function computeEndTime(startTime: string, durationMins: number): string {
  const [h, m] = startTime.split(':').map(Number);
  const totalMins = h * 60 + m + durationMins;
  const endH = Math.floor(totalMins / 60) % 24;
  const endM = totalMins % 60;
  return `${String(endH).padStart(2, '0')}:${String(endM).padStart(2, '0')}`;
}

const DAY_ORDER: Record<string, number> = {
  Mon: 1, Tue: 2, Wed: 3, Thu: 4, Fri: 5, Sat: 6, Sun: 7,
};

export async function GET(req: NextRequest) {
  try {
    const teacherId = await verifyOwnerTenant(req);
    const batchesSnapshot = await adminDb
      .collection('batches')
      .where('teacherId', '==', teacherId)
      .where('status', 'in', ['active', 'upcoming'])
      .get();

    const items: CalendarPreviewItem[] = [];

    for (const doc of batchesSnapshot.docs) {
      const data = doc.data();
      const schedule = Array.isArray(data.schedule) ? (data.schedule as ScheduleSlot[]) : [];
      const studentIds = Array.isArray(data.studentIds) ? data.studentIds : [];
      const meetingProvider = (data.meetingProvider as 'google_meet' | 'zoom' | 'custom') || 'google_meet';
      const meetingLink = typeof data.meetingLink === 'string' ? data.meetingLink : undefined;

      // Check for any synced calendar events
      const eventsSnap = await doc.ref.collection('calendarEvents').get();
      const eventMap = new Map<string, { googleEventUrl?: string; googleEventId?: string }>();
      eventsSnap.docs.forEach((e) => {
        eventMap.set(e.id, {
          googleEventUrl: e.data().googleEventUrl,
          googleEventId: e.data().googleEventId,
        });
      });

      for (const [index, slot] of schedule.entries()) {
        const slotId = `${slot.day.toLowerCase()}-${slot.startTime.replace(':', '')}-${index}`;
        const syncedEvent = eventMap.get(slotId);

        let syncStatus: CalendarPreviewItem['syncStatus'] = 'unlinked';
        if (data.calendarSyncEnabled) {
          syncStatus = syncedEvent?.googleEventId ? 'synced' : 'pending';
        }

        let providerName = 'Google Meet';
        if (meetingProvider === 'zoom') providerName = 'Zoom';
        else if (meetingProvider !== 'google_meet') providerName = 'Custom Room';

        items.push({
          batchId: doc.id,
          batchName: String(data.name || 'Batch'),
          subject: String(data.subject || ''),
          day: slot.day,
          startTime: slot.startTime,
          endTime: computeEndTime(slot.startTime, slot.durationMins),
          durationMins: slot.durationMins,
          provider: meetingProvider,
          providerName,
          meetingLink,
          googleEventUrl: syncedEvent?.googleEventUrl,
          googleEventId: syncedEvent?.googleEventId,
          syncStatus,
          studentCount: studentIds.length,
        });
      }
    }

    // Sort items by day of the week then start time
    items.sort((a, b) => {
      const dayDiff = (DAY_ORDER[a.day] || 99) - (DAY_ORDER[b.day] || 99);
      if (dayDiff !== 0) return dayDiff;
      return a.startTime.localeCompare(b.startTime);
    });

    return successResponse({ events: items });
  } catch (error: unknown) {
    const err = error as Error;
    if (err.message?.startsWith('AUTH_')) return errorResponse(err.message, 'Unauthorized', 401);
    return errorResponse('INTERNAL_ERROR', 'Unable to fetch calendar preview', 500);
  }
}
```

- [ ] **Step 2: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**
```bash
git add app/api/settings/meetings/calendar-preview/route.ts
git commit -m "feat(api): add calendar preview API route"
```

---

### Task 5: Meeting Providers Management UI Component (`components/settings/MeetingProvidersCard.tsx`)

**Files:**
- Create: `components/settings/MeetingProvidersCard.tsx`

**Interfaces:**
- Consumes: `/api/settings/meetings`, `/api/integrations/google/connect`, `/api/integrations/google/disconnect`, `api` client from `@/lib/api-client`
- Produces: `MeetingProvidersCard` component with:
  - Default Provider banner with 1-click active selector
  - Google Meet card (Calendar OAuth connection status, connect/disconnect, auto-sync, permanent link)
  - Zoom card (PMI URL, Meeting ID, Passcode, Host key, room test)
  - Custom Providers card (list, "+ Add Custom Provider" dialog, active toggle, delete)
  - "Set as Default" button for each active provider

- [ ] **Step 1: Implement `MeetingProvidersCard.tsx`**
Create `components/settings/MeetingProvidersCard.tsx` with full accessible forms, responsive layout, dark mode styles, and toast notifications.
Include:
- State management for `TeacherMeetingSettings` and `GoogleStatus`.
- Saving handler to `PUT /api/settings/meetings`.
- Modal/form for adding custom providers.
- Quick test link buttons that open meeting URLs safely.

- [ ] **Step 2: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**
```bash
git add components/settings/MeetingProvidersCard.tsx
git commit -m "feat(ui): add MeetingProvidersCard component"
```

---

### Task 6: Calendar Preview Component (`components/calendar/CalendarPreview.tsx`)

**Files:**
- Create: `components/calendar/CalendarPreview.tsx`

**Interfaces:**
- Consumes: `GET /api/settings/meetings/calendar-preview`
- Produces: `CalendarPreview` component with:
  - Filter pills for days of week (`All`, `Mon`, `Tue`, `Wed`, `Thu`, `Fri`, `Sat`, `Sun`)
  - Class schedule cards with Time, Duration, Batch Name, Subject, Provider badge
  - "Join / Test" link button and "Copy Link" button
  - Google Calendar sync badge (with clickable Google Calendar URL)
  - Student attendee count

- [ ] **Step 1: Implement `CalendarPreview.tsx`**
Create `components/calendar/CalendarPreview.tsx` with clean responsive cards, empty states, day filters, and link actions with toast notifications.

- [ ] **Step 2: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**
```bash
git add components/calendar/CalendarPreview.tsx
git commit -m "feat(ui): add CalendarPreview component"
```

---

### Task 7: Settings Page Integration (`app/(dashboard)/settings/page.tsx`)

**Files:**
- Modify: `app/(dashboard)/settings/page.tsx:835-932`

**Interfaces:**
- Consumes: `MeetingProvidersCard`, `CalendarPreview`
- Produces: Upgraded `IntegrationsTab` rendering both `MeetingProvidersCard` and `CalendarPreview` side-by-side or stacked cleanly.

- [ ] **Step 1: Replace old Google-only card with `MeetingProvidersCard` and `CalendarPreview`**
Update `IntegrationsTab` in `app/(dashboard)/settings/page.tsx` to render:
```tsx
function IntegrationsTab({ showToast }: { showToast: (m: string, ok?: boolean) => void }) {
  const [refreshKey, setRefreshKey] = useState(0);

  return (
    <div className="space-y-8" style={{ maxWidth: 860 }}>
      <MeetingProvidersCard
        showToast={showToast}
        onSettingsChanged={() => setRefreshKey((k) => k + 1)}
      />
      <CalendarPreview key={refreshKey} showToast={showToast} />
    </div>
  );
}
```

- [ ] **Step 2: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 3: Commit**
```bash
git add app/(dashboard)/settings/page.tsx
git commit -m "feat(settings): integrate MeetingProvidersCard and CalendarPreview in Settings"
```

---

### Task 8: Batch Scheduling Integration (`components/batches/BatchForm.tsx` & batch routes)

**Files:**
- Modify: `components/batches/BatchForm.tsx:170-210`
- Modify: `app/api/batches/route.ts`
- Modify: `app/api/batches/[id]/route.ts`

**Interfaces:**
- Consumes: `TeacherMeetingSettings` from `/api/settings/meetings`
- Produces:
  - Meeting provider dropdown in `BatchForm.tsx` when delivery mode is `online` or `hybrid`.
  - Auto-fills meeting link based on selected provider.
  - Automatically persists `meetingProvider` in Firestore batch document.

- [ ] **Step 1: Update `BatchForm.tsx`**
In `BatchForm.tsx`:
- Fetch meeting settings on load.
- In `form` state, add `meetingProvider: batch?.meetingProvider || ''`.
- When `form.deliveryMode !== 'offline'`:
  - Show a **Meeting Provider** select dropdown (options: Google Meet, Zoom, and any configured Custom providers).
  - Defaults to the teacher's `settings.defaultProvider`.
  - When the provider changes: auto-populate `meetingLink` with the selected provider's URL/PMI.
  - For Google Meet: show Google Calendar auto-sync toggle.
  - Teachers can edit the `meetingLink` input anytime.

- [ ] **Step 2: Update `app/api/batches/route.ts` and `app/api/batches/[id]/route.ts`**
Ensure `meetingProvider` is accepted and persisted:
- In `app/api/batches/route.ts`: add `meetingProvider: text(body.meetingProvider, 60),` to the document creation payload.
- In `app/api/batches/[id]/route.ts`: add `'meetingProvider'` to the allowed update fields.

- [ ] **Step 3: Run TypeScript verification**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 4: Commit**
```bash
git add components/batches/BatchForm.tsx app/api/batches/route.ts app/api/batches/[id]/route.ts
git commit -m "feat(batches): add meeting provider selector and auto-fill in batch form"
```

---

### Task 9: End-to-End Verification & Sanity Checks

- [ ] **Step 1: Run TypeScript compiler check**
Run: `npx tsc --noEmit`
Expected: PASS with 0 errors.

- [ ] **Step 2: Verify in Next.js build or browser**
Check Settings Integrations tab and Batch creation form to ensure:
1. Google Meet, Zoom, and Custom provider options render smoothly.
2. Setting default provider updates seamlessly.
3. Adding custom providers (e.g. Teams, Jitsi) works as expected.
4. Calendar preview loads upcoming batches and displays provider badges and links.
5. Batch form pre-selects default provider and auto-populates link.

- [ ] **Step 3: Final Commit**
```bash
git commit --allow-empty -m "chore: complete meeting providers and calendar preview verification"
```
