# Design Spec: Meeting Providers & Google Calendar Preview in Teacher CMS

**Date:** 2026-10-10  
**Status:** Draft / Approved Design  
**Author:** Pair Programming Agent & Teacher CMS Team  
**Target Application:** `alogyan-teachers-cms`

---

## 1. Overview & Objectives

Teachers and coaching centers conducting online or hybrid classes need reliable, flexible meeting tools. Currently, the CMS only features a basic Google Calendar OAuth toggle and a generic meeting link input.

This design introduces a first-class, extensible **Meeting Providers & Live Class Suite**:
1. **Google Meet Configuration & Calendar Access**: Connect Google Calendar OAuth, configure permanent Google Meet fallback links, control auto-sync preferences and reminder intervals.
2. **Zoom Configuration**: Immediate setup using Zoom Personal Meeting Room (PMI link, Meeting ID, Passcode, Host Key), with optional Server-to-Server OAuth credentials.
3. **Extensible Custom Providers**: Support for third-party or custom video solutions (e.g., Microsoft Teams, Jitsi Meet, Cisco Webex, proprietary LMS rooms) with custom links and instructions.
4. **Default Provider Setting**: Designate any provider as the default for the teacher's institute, automatically pre-filling links during batch scheduling.
5. **Interactive Calendar Preview Section**: A visual schedule inspector displaying the teacher's scheduled classes across the week, complete with meeting links, provider badges, Google Calendar sync status, and student attendee counts.
6. **Batch Scheduling Integration**: Enhanced `BatchForm.tsx` where online/hybrid classes allow selecting the configured provider with auto-filled links and one-click Google Calendar sync.

---

## 2. Architecture & Data Model

### 2.1 Types (`types/index.ts` & `types/meeting.ts`)

```typescript
export type MeetingProviderType = 'google_meet' | 'zoom' | 'custom';

export interface GoogleMeetConfig {
  enabled: boolean;
  mode: 'calendar_auto' | 'permanent_link';
  permanentLink?: string;       // e.g. https://meet.google.com/xxx-yyyy-zzz
  autoSyncBatches: boolean;     // Automatically sync online batches to Google Calendar
  defaultReminderMins: number;  // 15, 30, 60, 1440
}

export interface ZoomConfig {
  enabled: boolean;
  mode: 'pmi' | 'api';
  pmiLink?: string;             // e.g. https://zoom.us/j/1234567890?pwd=...
  meetingId?: string;           // e.g. 123 456 7890
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
  id: string;                   // unique ID (e.g. custom_17285512)
  name: string;                 // e.g. "Microsoft Teams", "Jitsi Meet"
  meetingUrl: string;           // Base room URL
  instructions?: string;        // e.g. "Use student email to log in"
  enabled: boolean;
  createdAt: string;
}

export interface TeacherMeetingSettings {
  defaultProvider: 'google_meet' | 'zoom' | string; // 'google_meet' | 'zoom' | customId
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

### 2.2 Firestore Collections

* **Meeting Settings Document**: `teachers/{teacherId}/settings/meetings`
  Stores `TeacherMeetingSettings`. Sensitive client secrets encrypted via AES-256-GCM.
* **Google Integration Document**: `teachers/{teacherId}/integrations/googleCalendar`
  Maintains Google OAuth tokens, connected account email, primary calendar ID, and sync status.
* **Batch Document Enhancements**: `batches/{batchId}`
  * `meetingProvider?: 'google_meet' | 'zoom' | string;`
  * `meetingLink?: string;`
  * `calendarSyncEnabled?: boolean;`
  * `calendarSyncStatus?: 'pending' | 'synced' | 'error';`

---

## 3. API Endpoints

### 3.1 Meeting Settings API
* **`GET /api/settings/meetings`**
  * Verifies teacher tenant authentication via `verifyOwnerTenant(req)`.
  * Fetches `teachers/{teacherId}/settings/meetings`.
  * Merges Google Calendar connection status from `integrations/googleCalendar` (`googleConnected: boolean`, `googleAccountEmail: string | null`).
  * Returns masked secrets (`hasCredentials: boolean`).
* **`PUT /api/settings/meetings`**
  * Validates URL schemes and provider fields.
  * Ensures `defaultProvider` matches an enabled provider.
  * Encrypts API secrets if provided.
  * Updates `teachers/{teacherId}/settings/meetings`.

### 3.2 Calendar Preview API
* **`GET /api/settings/meetings/calendar-preview`**
  * Fetches active batches belonging to `teacherId`.
  * Queries `batches/{batchId}/calendarEvents` for synced Google Calendar metadata.
  * Generates weekly schedule slot occurrences (Monday through Sunday) with start/end times.
  * Returns formatted `CalendarPreviewItem[]` sorted by day and time.

---

## 4. User Interface & Components

### 4.1 Settings &rarr; Integrations Tab (`app/(dashboard)/settings/page.tsx`)
Redesigned with modular cards:
1. **Default Provider Banner**:
   * Shows active default provider with one-click selector to switch between Google Meet, Zoom, or Custom.
2. **Google Meet & Calendar Access Card**:
   * Google account connection badge (`Connected: teacher@alogyan.com` or `Not Connected`).
   * "Connect Google Calendar" / "Disconnect" buttons.
   * Toggle between Calendar Auto-Link generation and Permanent Google Meet link.
   * Auto-sync online batches checkbox & reminder minutes selector.
   * "Set as Default" button.
3. **Zoom Configuration Card**:
   * Personal Meeting Room (PMI) Link input, Meeting ID, and Passcode.
   * Optional Server-to-Server OAuth inputs.
   * "Test Room Link" button.
   * "Set as Default" button.
4. **Custom & Future Providers Card**:
   * Table/list of active custom providers with name, link, and student instructions.
   * "+ Add Custom Provider" modal (Provider Name, Link, Instructions).
   * Delete & Toggle Active actions.
   * "Set as Default" button.
5. **Calendar Preview Section (`components/calendar/CalendarPreview.tsx`)**:
   * Weekly interactive schedule agenda.
   * Day-by-day pills (Mon to Sun) with class count indicators.
   * Class event cards displaying:
     * Time & duration
     * Batch name & subject
     * Provider badge (Google Meet / Zoom / Custom)
     * Quick "Join / Test Meeting" and "Copy Link" buttons
     * Google Calendar sync badge (linked / unlinked) with direct Google Calendar link
     * Enrolled student count

### 4.2 Batch Form (`components/batches/BatchForm.tsx`)
* Under **Class location** when delivery mode is `online` or `hybrid`:
  * Dropdown: **Meeting Provider** (Google Meet, Zoom, Custom). Defaults to the teacher's configured `defaultProvider`.
  * Selecting a provider auto-populates the **Meeting link** with the provider's permanent URL or PMI.
  * If Google Meet is chosen and Calendar is connected, shows Google Calendar sync checkbox and email reminder selector.
  * Allows manual override of the link per batch if desired.

---

## 5. Error Handling & Security

1. **Authentication**: All routes guarded by `verifyOwnerTenant(req)` or `assertAuthorized(req, 'batches:write')`.
2. **Secret Encryption**: Any API credentials (e.g. Zoom Client Secret) encrypted with AES-256-GCM before writing to Firestore.
3. **Link Validation**: Validation enforces valid `https://` URLs for meeting rooms.
4. **Graceful Fallbacks**: If Google Calendar is disconnected or fails, batches can continue using static Meet links or Zoom links without blocking class creation.

---

## 6. Verification Plan

1. **Unit / Route Verification**:
   * Test `GET /api/settings/meetings` returns default template when unconfigured.
   * Test `PUT /api/settings/meetings` saves and retrieves Google Meet, Zoom, and Custom providers.
   * Test `GET /api/settings/meetings/calendar-preview` generates upcoming schedule slots for batches.
2. **Settings UI Verification**:
   * Configure Google Meet link and set as default.
   * Configure Zoom PMI link/Meeting ID and set as default.
   * Add a custom provider (e.g. Microsoft Teams) and set as default.
   * Verify calendar preview accurately reflects batches and links.
3. **Batch Scheduling Verification**:
   * Create an online batch in `BatchForm.tsx`.
   * Verify the default provider is selected and link auto-filled.
   * Test switching provider changes the link.
   * Submit and verify batch is saved with correct provider and meeting link.
