---
name: alogyan-flutter-app
description: Use when building, architecting, or extending the Alogyan companion mobile application in Flutter for private tutors and coaching centers, implementing offline-first sync, minimal mobile workflows, Alogyan design tokens, and Firebase/REST API integrations.
---

# Alogyan Companion Flutter Mobile App: Architecture & Engineering Skill

This skill governs the architecture, UX philosophy, state management, offline-first synchronization, and design system implementation for the **Alogyan Companion Mobile App** (Flutter).

---

## 1. Executive Philosophy: Ruthless Mobile Minimalism

The Web CMS ([`alogyan-teachers-cms`](file:///Users/sanjoysarkar/web_app/start-up-projects/alogyan-teachers-cms)) is the comprehensive control tower (analytics, certificate issuance, master multi-branch configuration, GST billing, and marketing automation).

**The Flutter Mobile App is a laser-focused, pocket companion designed for the classroom floor and on-the-go interactions.**

```
┌────────────────────────────────────────────────────────┐
│                   WEB CMS (Next.js)                    │
│ • Master Multi-Branch Setup     • Certificate Designer │
│ • Granular RBAC Configuration   • Deep Financial P&L   │
│ • Bulk CSV Student Import       • CRM Marketing Studio │
└───────────────────────────▲────────────────────────────┘
                            │ REST APIs & Firestore Sync
┌───────────────────────────▼────────────────────────────┐
│              FLUTTER APP (Pocket Companion)            │
│ 1. Today's Classes & Meet Link (1-tap start)           │
│ 2. Rapid Batch Attendance (10-second mark + offline)   │
│ 3. Quick Fee Collection (UPI QR + WhatsApp receipt)    │
│ 4. Instant Student Search (1-tap Call / WhatsApp)      │
│ 5. Emergency Broadcast / Push Alert                    │
└────────────────────────────────────────────────────────┘
```

### The 3 Core Mobile Commandments:
1. **The 10-Second Rule**: Any primary classroom task (taking attendance, checking who paid, launching a class link) must take under 10 seconds.
2. **Offline-First Guarantee**: Tuition basements and semi-urban classrooms frequently drop connectivity. Actions never fail; they queue locally into an idempotent sync engine and reconcile silently.
3. **Zero Configuration**: No complex settings, branch creation, or table builders on mobile. The phone consumes master settings configured on the Web CMS.

---

## 2. Minimalist Feature Matrix (Mobile vs. Web)

| Domain | What Mobile MUST Do (Minimal & Fast) | What Stays Strictly on Web CMS |
|---|---|---|
| **Dashboard** | Today's timeline (Current/Next class, countdown, 1-tap Google Meet or room badge), quick action floating dial. | 12-month revenue charts, student growth curves, multi-branch comparative graphs. |
| **Attendance** | Batch list -> 1-tap "Mark All Present" -> toggle absentees -> Swipe to Submit -> 1-tap WhatsApp alert to parents. | Historical attendance trend matrix, attendance analytics, student dispute audits. |
| **Fees & Billing** | Student search -> Enter amount -> Show dynamic UPI QR / Record Cash -> Generate instant WhatsApp receipt text/PDF. | GST tax configuration, invoice numbering sequences, financial audit log, refunds. |
| **Students** | Fast search (name/roll/phone), student profile with quick Call/WhatsApp buttons, current due amount, attendance %. | Student enrollment wizard, document uploads, batch transfer, alumni archiving. |
| **Batches** | View active batch cards, student roster, schedule times, tap to launch online meeting. | Create batch, set syllabus/schedule rules, capacity restrictions, Google Calendar OAuth. |
| **Communications**| Send urgent announcement to selected batch ("Class delayed by 15 mins"). | Campaign creator, template approval engine, telecaller agent queues. |
| **Tests & Notes** | View upcoming tests, enter marks per student on a single numeric keypad list; view uploaded notes. | Question paper generation, PDF batch uploads, test analysis. |

---

## 3. Design System & Tokens (Flutter Specification)

The Flutter app mirrors the visual identity of Alogyan:

### 3.1 Color Palette (`AlogyanColors`)

```dart
import 'package:flutter/material.dart';

class AlogyanColors {
  // Brand Primary (Alogyan Red)
  static const Color primary = Color(0xFFD32F2F);
  static const Color primaryHover = Color(0xFFB71C1C);
  static const Color primaryLight = Color(0xFFFFEBEE);
  static const Color primaryDark = Color(0xFF9A0007);

  // Surfaces & Backgrounds
  static const Color background = Color(0xFFF8FAFC); // Slate-50
  static const Color surface = Colors.white;
  static const Color surfaceMuted = Color(0xFFF1F5F9); // Slate-100
  static const Color border = Color(0xFFE2E8F0); // Slate-200

  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate-900
  static const Color textSecondary = Color(0xFF64748B); // Slate-500
  static const Color textMuted = Color(0xFF94A3B8); // Slate-400

  // Status & Feedback
  static const Color success = Color(0xFF16A34A); // Green-600
  static const Color successLight = Color(0xFFDCFCE7);
  static const Color warning = Color(0xFFD97706); // Amber-600
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFDC2626); // Red-600
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF2563EB); // Blue-600
  static const Color infoLight = Color(0xFFDBEAFE);
}
```

### 3.2 Typography & Touch Targets
- **Font Family**: `Inter` via Google Fonts.
- **Minimum Tap Target**: 48x48dp for all actionable controls (especially attendance toggle buttons).
- **Cards**: Elevation 0, 1dp border (`AlogyanColors.border`), `BorderRadius.circular(12)`.

---

## 4. App Architecture & Project Structure

Use **Feature-First Architecture** combined with **Riverpod (2.x)** for declarative, reactive state management and **Isar / Hive** for local persistence.

```
lib/
├── app.dart                       # MaterialApp.router with Alogyan theme
├── core/
│   ├── api/
│   │   ├── api_client.dart        # Dio client with Firebase token & Tenant interceptors
│   │   ├── api_endpoints.dart     # Matches /api routes of alogyan-teachers-cms
│   │   └── error_handler.dart
│   ├── constants/
│   │   ├── colors.dart
│   │   └── styles.dart
│   ├── network/
│   │   └── network_info.dart      # Connectivity checker (online/offline)
│   ├── sync/
│   │   ├── sync_action.dart       # SyncAction model with client UUID & status
│   │   ├── sync_queue_box.dart    # Hive/Isar queue for pending actions
│   │   └── sync_service.dart      # Background auto-sync worker
│   └── utils/
│       ├── upi_helper.dart        # UPI Deep-link generator & QR builder
│       └── whatsapp_launcher.dart # Direct WhatsApp url_launcher wrapper
├── features/
│   ├── auth/                      # Firebase Phone & Google Auth
│   ├── dashboard/                 # Today's classes, quick actions, schedule
│   ├── attendance/                # Fast batch attendance sheet & absentee alerts
│   ├── fees/                      # Quick fee collection, dynamic UPI QR, receipts
│   ├── students/                  # Fast search, student card, direct call/chat
│   └── announcements/             # Instant batch broadcast
└── shared/
    ├── widgets/
    │   ├── alogyan_card.dart
    │   ├── status_badge.dart
    │   ├── primary_button.dart
    │   └── offline_banner.dart
    └── models/                    # Shared DTOs matching CMS types
```

---

## 5. Offline-First Synchronization Protocol

The mobile app implements the exact `SyncAction` pattern defined in `alogyan-teachers-cms/types/index.ts`:

```dart
// lib/core/sync/sync_action.dart
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'sync_action.g.dart';

@HiveType(typeId: 1)
class SyncAction extends HiveObject {
  @HiveField(0)
  final String id; // Client UUID (Idempotency Key)

  @HiveField(1)
  final String type; // 'MARK_ATTENDANCE' | 'COLLECT_FEE' | 'CREATE_STUDENT'

  @HiveField(2)
  final String endpoint; // e.g. '/api/attendance'

  @HiveField(3)
  final String method; // 'POST' | 'PATCH'

  @HiveField(4)
  final Map<String, dynamic> payload;

  @HiveField(5)
  final int createdAt;

  @HiveField(6)
  int retryCount;

  @HiveField(7)
  String status; // 'pending' | 'syncing' | 'failed' | 'synced'

  SyncAction({
    String? id,
    required this.type,
    required this.endpoint,
    this.method = 'POST',
    required this.payload,
    int? createdAt,
    this.retryCount = 0,
    this.status = 'pending',
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;
}
```

### Sync Flow Rule:
1. When user performs an action (e.g. "Mark Attendance"):
   - Update local state immediately (Optimistic UI update).
   - Write `SyncAction` to local Hive box.
   - If device is online, trigger `SyncService.flush()`.
   - If offline or API fails, action stays in queue with status `pending`.
   - On connectivity restore (`connectivity_plus`), drain queue in FIFO order with idempotency header `X-Idempotency-Key: {syncAction.id}`.

---

## 6. High-Frequency Mobile Workflows (Implementations)

### 6.1 Workflow 1: 10-Second Batch Attendance
Teachers do not want to click through 30 dropdowns.
- Load today's batch roster.
- Default all students to **Present** (`green`).
- Teacher only taps the 1-2 students who are **Absent** (`red`) or **Late** (`amber`).
- One-tap bottom bar: **"Submit Attendance (28/30 Present)"**.
- Immediate modal: *"Send WhatsApp notice to 2 absent parents?"* -> 1-tap sends direct localized message via WhatsApp deep link.

```dart
// State representation
class AttendanceState {
  final String batchId;
  final DateTime date;
  final Map<String, String> records; // studentId -> 'present' | 'absent' | 'late'

  AttendanceState({
    required this.batchId,
    required this.date,
    required this.records,
  });

  void markAllPresent(List<String> studentIds) {
    for (final id in studentIds) {
      records[id] = 'present';
    }
  }

  void toggleStatus(String studentId) {
    final current = records[studentId] ?? 'present';
    if (current == 'present') records[studentId] = 'absent';
    else if (current == 'absent') records[studentId] = 'late';
    else records[studentId] = 'present';
  }
}
```

### 6.2 Workflow 2: Quick Fee Collection & Dynamic UPI QR
When a parent or student pays cash or asks for UPI:
1. Tap student -> Tap **Collect Fee**.
2. Shows preset monthly fee (e.g., ₹2,000).
3. If cash: Select "Cash" -> Tap "Save & Share Receipt".
4. If UPI: Generate on-screen dynamic UPI QR with deep link (`upi://pay?pa=teacher@upi&pn=AlogyanAcademy&am=2000&tn=Fee_March_John`). Parent scans phone-to-phone.
5. Tap "Confirm Received" -> Pushes to Sync Queue -> Opens WhatsApp share dialog with preformatted text receipt:
   > *"Payment Received: ₹2,000 for John Doe (Batch: Class 10 Maths, Month: March 2026). Receipt: INV-2026-0042. Thank you! - Alogyan Academy"*

---

## 7. API Communication & Security Integration

All requests to the Next.js API (`/api/...`) MUST pass:
1. **Authorization**: Bearer ID Token from Firebase Auth (`await user.getIdToken()`).
2. **Multi-Tenancy Headers**:
   - `x-tenant-id`: Active institute ID.
   - `x-branch-id`: Selected branch ID (or empty if owner all-branch).
   - `x-idempotency-key`: `SyncAction.id` for queued requests.

```dart
// lib/core/api/api_client.dart
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ApiClient {
  final Dio dio;

  ApiClient({required String baseUrl, required String tenantId})
      : dio = Dio(BaseOptions(
          baseUrl: baseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 10),
          headers: {'Content-Type': 'application/json'},
        )) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          final token = await user.getIdToken();
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['x-tenant-id'] = tenantId;
        return handler.next(options);
      },
    ));
  }
}
```

---

## 8. Anti-Patterns & Prohibitions (What NOT To Do)

| Anti-Pattern | Correction |
|---|---|
| ❌ Implementing complex multi-branch setup wizards on mobile | Guide user to use the Web CMS for initial setup. |
| ❌ Building full report chart designers on phone | Keep dashboard to today's schedule + 3 quick numbers (Today's Classes, Pending Fees, Absent Count). |
| ❌ Blocking UI on network calls during attendance | Optimistic update + write to `SyncAction` queue immediately. Never block attendance in class. |
| ❌ Embedding complex rich-text note editors | Mobile only needs file picker (take photo of whiteboard / upload PDF) + title + batch select. |
| ❌ Overcomplicating authentication | Use phone OTP authentication or Google Sign-In with instant session recovery. |
