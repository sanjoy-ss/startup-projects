# Alogyan Companion Flutter Mobile App - Design Specification

- **Date**: 2026-09-25
- **Project**: `alogyan_app` (Companion Flutter App in `start-up-projects` root)
- **Target Platforms**: Android & iOS
- **Package Identifier**: `com.alogyan.alogyan_app`
- **Specification Source**: [alogyan-flutter-app SKILL](file:///Users/sanjoysarkar/web_app/start-up-projects/.agents/skills/alogyan-flutter-app/SKILL.md)

---

## 1. Problem Statement & Philosophy

The Web CMS ([`alogyan-teachers-cms`](file:///Users/sanjoysarkar/web_app/start-up-projects/alogyan-teachers-cms)) functions as the central control tower (analytics, multi-branch setup, certificate designer, GST invoicing, CRM).

The **`alogyan_app`** Flutter mobile application is a high-speed, pocket companion tailored for the classroom floor and mobile tutors. It adheres strictly to:
1. **The 10-Second Rule**: Primary tasks (taking batch attendance, launching class links, logging payment) execute in under 10 seconds.
2. **Offline-First Guarantee**: Actions persist immediately to a local idempotency queue (`SyncAction`) with optimistic UI updates and auto-sync when online.
3. **Ruthless Minimalism**: No multi-branch builders or report designers on mobile; phone consumes master settings from CMS.

---

## 2. Architecture & Directory Layout

The application utilizes **Feature-First Architecture** with **Riverpod 2.x** and **Hive** local persistence.

```
alogyan_app/
├── lib/
│   ├── app.dart                        # MaterialApp.router with Alogyan theme
│   ├── main.dart                       # Entry point, initializes Hive, Riverpod ProviderScope
│   ├── core/
│   │   ├── api/
│   │   │   ├── api_client.dart         # Dio HTTP client with Auth & Tenant interceptors
│   │   │   ├── api_endpoints.dart      # REST endpoints matching Next.js CMS routes
│   │   │   └── error_handler.dart      # Failure models & mapping
│   │   ├── constants/
│   │   │   ├── colors.dart             # AlogyanColors (Brand Red + Slate tokens)
│   │   │   └── styles.dart             # Touch targets, card styles, radii
│   │   ├── network/
│   │   │   └── network_info.dart       # Online/offline state monitoring (connectivity_plus)
│   │   ├── sync/
│   │   │   ├── sync_action.dart        # SyncAction model with UUID & idempotency key
│   │   │   ├── sync_queue_box.dart     # Hive queue box storage
│   │   │   └── sync_service.dart       # Background auto-sync worker
│   │   └── utils/
│   │       ├── upi_helper.dart         # UPI QR / deep link generator
│   │       └── whatsapp_launcher.dart  # WhatsApp message deep links
│   ├── features/
│   │   ├── auth/                       # Teacher authentication flow
│   │   ├── dashboard/                  # Today's schedule, countdown & quick actions
│   │   ├── attendance/                 # 10-second rapid batch attendance
│   │   ├── fees/                       # Quick fee collection & UPI QR
│   │   └── students/                   # Fast roster search & 1-tap call/WhatsApp
│   └── shared/
│       ├── widgets/
│       │   ├── alogyan_card.dart       # Border 1px slate-200, radius 12, elevation 0
│       │   ├── primary_button.dart     # Brand red primary button
│       │   ├── status_badge.dart       # Present/Absent/Paid pill badges
│       │   └── offline_banner.dart     # Floating indicator when actions are syncing
│       └── models/                     # Shared DTOs matching CMS types
└── test/
    └── widget_test.dart
```

---

## 3. Design System & Tokens

### 3.1 Color Palette (`AlogyanColors`)
- **Brand Primary**:
  - `primary`: `#D32F2F`
  - `primaryDark`: `#9A0007`
  - `primaryHover`: `#B71C1C`
  - `primaryLight`: `#FFEBEE`
- **Surfaces & Neutrals**:
  - `background`: `#F8FAFC` (Slate-50)
  - `surface`: `#FFFFFF`
  - `surfaceMuted`: `#F1F5F9` (Slate-100)
  - `border`: `#E2E8F0` (Slate-200)
- **Typography**:
  - Font Family: `Inter` (via `google_fonts`)
  - Primary: `#0F172A` (Slate-900)
  - Secondary: `#64748B` (Slate-500)
  - Muted: `#94A3B8` (Slate-400)
- **Semantic Feedback**:
  - `success`: `#16A34A` / `successLight`: `#DCFCE7`
  - `danger`: `#DC2626` / `dangerLight`: `#FEE2E2`
  - `warning`: `#D97706` / `warningLight`: `#FEF3C7`
  - `info`: `#2563EB` / `infoLight`: `#DBEAFE`

### 3.2 Dimensions & Touch Targets
- Minimum touch target: `48x48dp` (optimized for attendance tap toggling).
- Card decoration: Elevation 0, 1dp border (`AlogyanColors.border`), `BorderRadius.circular(12)`.

---

## 4. Dependencies (`pubspec.yaml`)

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.5.1
  dio: ^5.4.3
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^6.0.3
  url_launcher: ^6.2.6
  uuid: ^4.4.0
  intl: ^0.19.0
  google_fonts: ^6.2.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
```

---

## 5. Offline-First Synchronization Protocol

### 5.1 Data Model: `SyncAction`
Each offline action stores:
* `id` (`String`): UUID v4 generated on device (used as `X-Idempotency-Key`).
* `type` (`String`): `'MARK_ATTENDANCE' | 'COLLECT_FEE' | 'CREATE_STUDENT'`.
* `endpoint` (`String`): Matching backend API route (e.g. `/api/attendance`).
* `method` (`String`): `'POST'` or `'PATCH'`.
* `payload` (`Map<String, dynamic>`): Serialized action parameters.
* `createdAt` (`int`): Timestamp in milliseconds.
* `status` (`String`): `'pending' | 'syncing' | 'failed' | 'synced'`.
* `retryCount` (`int`): Failed attempt counter.

### 5.2 Flow
1. User marks attendance or collects fee -> Optimistic UI update immediately.
2. `SyncAction` recorded to Hive box (`sync_queue`).
3. If online (`connectivity_plus`), trigger `SyncService.flush()`.
4. If offline, the queue persists. On network reconnection, drain queue sequentially with `X-Idempotency-Key`.

---

## 6. Verification & Quality Gates

- `flutter analyze` must pass with zero issues.
- `flutter test` must pass default tests.
- UI elements verify proper contrast, touch targets >= 48dp, and clean Alogyan styling.
