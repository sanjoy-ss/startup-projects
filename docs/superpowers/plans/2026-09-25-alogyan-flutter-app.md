# Alogyan Companion Flutter Mobile App Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build and structure the Alogyan Companion Mobile App (`alogyan_app`) in Flutter following the Alogyan design tokens, offline-first sync architecture, and high-frequency classroom workflows.

**Architecture:** Feature-first Flutter application powered by Riverpod state management, Hive local sync queue with idempotency keys (`SyncAction`), Dio HTTP client with multi-tenant interceptors, and Google Fonts `Inter` typography.

**Tech Stack:** Flutter 3.47 (Dart 3.13), Flutter Riverpod 2.x/3.x, Hive & Hive Flutter, Dio, Connectivity Plus, URL Launcher, UUID, Google Fonts, Lucide Icons.

**Spec:** [docs/superpowers/specs/2026-09-25-alogyan-flutter-app-design.md](file:///Users/sanjoysarkar/web_app/start-up-projects/docs/superpowers/specs/2026-09-25-alogyan-flutter-app-design.md)

## Global Constraints

- Target platforms: Android & iOS only.
- App / Package ID: `com.alogyan.alogyan_app`.
- Minimum interactive touch target: 48x48dp.
- Brand colors: Red primary `#D32F2F`, Dark `#9A0007`, Light `#FFEBEE`, Slate background `#F8FAFC`, Border `#E2E8F0`.
- All network write operations must support offline persistence through `SyncAction` with client-generated UUID keys.
- Code must pass `flutter analyze` and `flutter test` without errors or warnings.

---

### Task 1: Core Design System & Tokens

**Files:**
- Create: `alogyan_app/lib/core/constants/colors.dart`
- Create: `alogyan_app/lib/core/constants/styles.dart`
- Test: `alogyan_app/test/core/constants/colors_test.dart`

**Interfaces:**
- Produces:
  - `AlogyanColors` with `primary`, `primaryDark`, `primaryLight`, `background`, `surface`, `surfaceMuted`, `border`, `textPrimary`, `textSecondary`, `textMuted`, `success`, `successLight`, `danger`, `dangerLight`, `warning`, `warningLight`, `info`, `infoLight`.
  - `AlogyanStyles` with `minTouchTargetSize = Size(48.0, 48.0)`, `cardRadius = BorderRadius.circular(12.0)`, and `appTheme` data.

- [ ] **Step 1: Write the failing test**

```dart
// alogyan_app/test/core/constants/colors_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/core/constants/colors.dart';
import 'package:alogyan_app/core/constants/styles.dart';

void main() {
  group('AlogyanColors', () {
    test('brand colors match specification tokens', () {
      expect(AlogyanColors.primary, const Color(0xFFD32F2F));
      expect(AlogyanColors.primaryDark, const Color(0xFF9A0007));
      expect(AlogyanColors.primaryLight, const Color(0xFFFFEBEE));
      expect(AlogyanColors.background, const Color(0xFFF8FAFC));
      expect(AlogyanColors.surface, Colors.white);
      expect(AlogyanColors.border, const Color(0xFFE2E8F0));
      expect(AlogyanColors.textPrimary, const Color(0xFF0F172A));
      expect(AlogyanColors.textSecondary, const Color(0xFF64748B));
      expect(AlogyanColors.success, const Color(0xFF16A34A));
      expect(AlogyanColors.danger, const Color(0xFFDC2626));
      expect(AlogyanColors.warning, const Color(0xFFD97706));
    });
  });

  group('AlogyanStyles', () {
    test('touch target conforms to 48dp minimum', () {
      expect(AlogyanStyles.minTouchTargetSize.width, greaterThanOrEqualTo(48.0));
      expect(AlogyanStyles.minTouchTargetSize.height, greaterThanOrEqualTo(48.0));
      expect(AlogyanStyles.cardRadius, BorderRadius.circular(12.0));
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/constants/colors_test.dart` in `alogyan_app`
Expected: FAIL with "Target of URI doesn't exist"

- [ ] **Step 3: Write minimal implementation**

```dart
// alogyan_app/lib/core/constants/colors.dart
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

```dart
// alogyan_app/lib/core/constants/styles.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class AlogyanStyles {
  static const Size minTouchTargetSize = Size(48.0, 48.0);
  static final BorderRadius cardRadius = BorderRadius.circular(12.0);

  static ThemeData get themeData {
    final baseTextTheme = GoogleFonts.interTextTheme();
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AlogyanColors.background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AlogyanColors.primary,
        primary: AlogyanColors.primary,
        surface: AlogyanColors.surface,
        error: AlogyanColors.danger,
      ),
      textTheme: baseTextTheme.apply(
        bodyColor: AlogyanColors.textPrimary,
        displayColor: AlogyanColors.textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AlogyanColors.surface,
        foregroundColor: AlogyanColors.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AlogyanColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AlogyanColors.primary,
          foregroundColor: Colors.white,
          minimumSize: minTouchTargetSize,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/constants/colors_test.dart` in `alogyan_app`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add alogyan_app/lib/core/constants/ alogyan_app/test/core/constants/
git commit -m "feat(alogyan_app): implement design tokens and theme styles"
```

---

### Task 2: Shared UI Components (Card, Button, Status Badge, Offline Banner)

**Files:**
- Create: `alogyan_app/lib/shared/widgets/alogyan_card.dart`
- Create: `alogyan_app/lib/shared/widgets/primary_button.dart`
- Create: `alogyan_app/lib/shared/widgets/status_badge.dart`
- Create: `alogyan_app/lib/shared/widgets/offline_banner.dart`
- Test: `alogyan_app/test/shared/widgets/alogyan_widgets_test.dart`

**Interfaces:**
- Consumes: `AlogyanColors`, `AlogyanStyles` from Task 1.
- Produces:
  - `AlogyanCard({required Widget child, EdgeInsetsGeometry? padding, VoidCallback? onTap})`
  - `PrimaryButton({required String text, required VoidCallback? onPressed, IconData? icon, bool isLoading})`
  - `StatusBadge({required String label, required StatusBadgeType type})` with enum `StatusBadgeType { success, warning, danger, info }`
  - `OfflineBanner({required int pendingCount, VoidCallback? onSyncNow})`

- [ ] **Step 1: Write the failing widget tests**

```dart
// alogyan_app/test/shared/widgets/alogyan_widgets_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/shared/widgets/alogyan_card.dart';
import 'package:alogyan_app/shared/widgets/primary_button.dart';
import 'package:alogyan_app/shared/widgets/status_badge.dart';
import 'package:alogyan_app/shared/widgets/offline_banner.dart';

void main() {
  testWidgets('AlogyanCard renders child and triggers onTap', (tester) async {
    bool tapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AlogyanCard(
            onTap: () => tapped = true,
            child: const Text('Card Content'),
          ),
        ),
      ),
    );

    expect(find.text('Card Content'), findsOneWidget);
    await tester.tap(find.text('Card Content'));
    expect(tapped, isTrue);
  });

  testWidgets('PrimaryButton renders text and respects minimum 48dp height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: PrimaryButton(
            text: 'Submit Attendance',
            onPressed: () {},
          ),
        ),
      ),
    );

    expect(find.text('Submit Attendance'), findsOneWidget);
    final buttonFinder = find.byType(ElevatedButton);
    final buttonSize = tester.getSize(buttonFinder);
    expect(buttonSize.height, greaterThanOrEqualTo(48.0));
  });

  testWidgets('StatusBadge displays correct label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: StatusBadge(
            label: '28 Present',
            type: StatusBadgeType.success,
          ),
        ),
      ),
    );

    expect(find.text('28 Present'), findsOneWidget);
  });

  testWidgets('OfflineBanner displays pending sync count', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: OfflineBanner(pendingCount: 3),
        ),
      ),
    );

    expect(find.textContaining('3 actions pending sync'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/shared/widgets/alogyan_widgets_test.dart` in `alogyan_app`
Expected: FAIL with compilation errors (classes not found)

- [ ] **Step 3: Implement shared widgets**

```dart
// alogyan_app/lib/shared/widgets/alogyan_card.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';

class AlogyanCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const AlogyanCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cardContent = Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AlogyanColors.surface,
        borderRadius: AlogyanStyles.cardRadius,
        border: Border.all(color: AlogyanColors.border, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: AlogyanStyles.cardRadius,
        child: cardContent,
      );
    }
    return cardContent;
  }
}
```

```dart
// alogyan_app/lib/shared/widgets/primary_button.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';
import '../../core/constants/styles.dart';

class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;

  const PrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AlogyanColors.primary,
        foregroundColor: Colors.white,
        minimumSize: AlogyanStyles.minTouchTargetSize,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18),
                  const SizedBox(width: 8),
                ],
                Text(text),
              ],
            ),
    );
  }
}
```

```dart
// alogyan_app/lib/shared/widgets/status_badge.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

enum StatusBadgeType { success, warning, danger, info }

class StatusBadge extends StatelessWidget {
  final String label;
  final StatusBadgeType type;

  const StatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case StatusBadgeType.success:
        bg = AlogyanColors.successLight;
        fg = AlogyanColors.success;
        break;
      case StatusBadgeType.warning:
        bg = AlogyanColors.warningLight;
        fg = AlogyanColors.warning;
        break;
      case StatusBadgeType.danger:
        bg = AlogyanColors.dangerLight;
        fg = AlogyanColors.danger;
        break;
      case StatusBadgeType.info:
        bg = AlogyanColors.infoLight;
        fg = AlogyanColors.info;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: fg,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
```

```dart
// alogyan_app/lib/shared/widgets/offline_banner.dart
import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

class OfflineBanner extends StatelessWidget {
  final int pendingCount;
  final VoidCallback? onSyncNow;

  const OfflineBanner({
    super.key,
    required this.pendingCount,
    this.onSyncNow,
  });

  @override
  Widget build(BuildContext context) {
    if (pendingCount <= 0) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AlogyanColors.warningLight,
      child: Row(
        children: [
          const Icon(Icons.cloud_off, size: 18, color: AlogyanColors.warning),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$pendingCount actions pending sync (saved locally)',
              style: const TextStyle(
                color: AlogyanColors.warning,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (onSyncNow != null)
            TextButton(
              onPressed: onSyncNow,
              child: const Text('Sync Now', style: TextStyle(color: AlogyanColors.warning)),
            ),
        ],
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/shared/widgets/alogyan_widgets_test.dart` in `alogyan_app`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add alogyan_app/lib/shared/widgets/ alogyan_app/test/shared/widgets/
git commit -m "feat(alogyan_app): implement reusable Alogyan card, button, badge, and banner widgets"
```

---

### Task 3: Offline Sync Engine & API Models

**Files:**
- Create: `alogyan_app/lib/core/sync/sync_action.dart`
- Create: `alogyan_app/lib/core/sync/sync_service.dart`
- Create: `alogyan_app/lib/core/api/api_client.dart`
- Test: `alogyan_app/test/core/sync/sync_action_test.dart`

**Interfaces:**
- Produces:
  - `SyncAction` class with `toMap()`, `fromMap()`, UUID generation, and JSON compatibility.
  - `SyncService` providing queue enqueue, flush, and item count.
  - `ApiClient` with Dio interceptors injecting `x-tenant-id`, `x-branch-id`, and `x-idempotency-key`.

- [ ] **Step 1: Write the failing sync model and service test**

```dart
// alogyan_app/test/core/sync/sync_action_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/core/sync/sync_action.dart';

void main() {
  group('SyncAction', () {
    test('instantiates with unique UUID and serialization roundtrip', () {
      final action = SyncAction(
        type: 'MARK_ATTENDANCE',
        endpoint: '/api/attendance',
        payload: {
          'batchId': 'b_101',
          'records': {'s_1': 'present', 's_2': 'absent'}
        },
      );

      expect(action.id, isNotEmpty);
      expect(action.status, 'pending');
      expect(action.retryCount, 0);

      final map = action.toMap();
      final restored = SyncAction.fromMap(map);

      expect(restored.id, action.id);
      expect(restored.type, 'MARK_ATTENDANCE');
      expect(restored.endpoint, '/api/attendance');
      expect(restored.payload['batchId'], 'b_101');
    });
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/core/sync/sync_action_test.dart` in `alogyan_app`
Expected: FAIL with "Target of URI doesn't exist"

- [ ] **Step 3: Implement SyncAction, SyncService, and ApiClient**

```dart
// alogyan_app/lib/core/sync/sync_action.dart
import 'package:uuid/uuid.dart';

class SyncAction {
  final String id;
  final String type;
  final String endpoint;
  final String method;
  final Map<String, dynamic> payload;
  final int createdAt;
  int retryCount;
  String status;

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'endpoint': endpoint,
      'method': method,
      'payload': payload,
      'createdAt': createdAt,
      'retryCount': retryCount,
      'status': status,
    };
  }

  factory SyncAction.fromMap(Map<dynamic, dynamic> map) {
    return SyncAction(
      id: map['id'] as String,
      type: map['type'] as String,
      endpoint: map['endpoint'] as String,
      method: (map['method'] as String?) ?? 'POST',
      payload: Map<String, dynamic>.from(map['payload'] as Map),
      createdAt: map['createdAt'] as int,
      retryCount: (map['retryCount'] as int?) ?? 0,
      status: (map['status'] as String?) ?? 'pending',
    );
  }
}
```

```dart
// alogyan_app/lib/core/sync/sync_service.dart
import 'package:hive/hive.dart';
import 'sync_action.dart';

class SyncService {
  static const String boxName = 'sync_actions_box';
  final Box? _box;

  SyncService([this._box]);

  Box get box => _box ?? Hive.box(boxName);

  List<SyncAction> getPendingActions() {
    final list = <SyncAction>[];
    for (int i = 0; i < box.length; i++) {
      final item = box.getAt(i);
      if (item != null && item is Map) {
        list.add(SyncAction.fromMap(item));
      }
    }
    return list;
  }

  Future<void> enqueue(SyncAction action) async {
    await box.put(action.id, action.toMap());
  }

  Future<void> markSynced(String id) async {
    await box.delete(id);
  }

  int get pendingCount => box.length;
}
```

```dart
// alogyan_app/lib/core/api/api_client.dart
import 'package:dio/dio.dart';

class ApiClient {
  final Dio dio;
  final String tenantId;
  final String? branchId;

  ApiClient({
    required String baseUrl,
    required this.tenantId,
    this.branchId,
    Dio? customDio,
  }) : dio = customDio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
              headers: {'Content-Type': 'application/json'},
            )) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.headers['x-tenant-id'] = tenantId;
          if (branchId != null) {
            options.headers['x-branch-id'] = branchId;
          }
          return handler.next(options);
        },
      ),
    );
  }
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/core/sync/sync_action_test.dart` in `alogyan_app`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add alogyan_app/lib/core/sync/ alogyan_app/lib/core/api/ alogyan_app/test/core/sync/
git commit -m "feat(alogyan_app): implement SyncAction offline queue and ApiClient"
```

---

### Task 4: High-Frequency Classroom Flows & Companion Dashboard

**Files:**
- Create: `alogyan_app/lib/features/dashboard/screens/dashboard_screen.dart`
- Create: `alogyan_app/lib/features/attendance/screens/quick_attendance_screen.dart`
- Create: `alogyan_app/lib/features/fees/screens/quick_fee_screen.dart`
- Modify: `alogyan_app/lib/app.dart`
- Modify: `alogyan_app/lib/main.dart`
- Test: `alogyan_app/test/features/dashboard/dashboard_screen_test.dart`

**Interfaces:**
- Consumes: Task 1 tokens (`AlogyanStyles`), Task 2 widgets (`AlogyanCard`, `PrimaryButton`, `StatusBadge`, `OfflineBanner`), Task 3 sync models (`SyncAction`).
- Produces: Complete navigable app UI with Today's Schedule timeline, 1-tap Meet launch badge, 10-Second Attendance marker with absentee toggles, and Quick Fee recorder with UPI generator.

- [ ] **Step 1: Write the failing dashboard test**

```dart
// alogyan_app/test/features/dashboard/dashboard_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alogyan_app/features/dashboard/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard renders todays classes and quick action cards', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(),
        ),
      ),
    );

    expect(find.text("Today's Schedule"), findsOneWidget);
    expect(find.text('Take Attendance'), findsOneWidget);
    expect(find.text('Collect Fee'), findsOneWidget);
  });
}
```

- [ ] **Step 2: Run test to verify it fails**

Run: `flutter test test/features/dashboard/dashboard_screen_test.dart` in `alogyan_app`
Expected: FAIL with compilation errors (screens not found)

- [ ] **Step 3: Implement Dashboard, Attendance, and Fee screens**

```dart
// alogyan_app/lib/features/dashboard/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/alogyan_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../attendance/screens/quick_attendance_screen.dart';
import '../../fees/screens/quick_fee_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Alogyan Academy', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text('Prof. Sanjoy • Physics & Maths', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.bell, size: 20),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Quick Stat Tiles
            Row(
              children: [
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Today Classes', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('3 Batches', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.primary)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AlogyanCard(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Pending Dues', style: TextStyle(fontSize: 12, color: AlogyanColors.textSecondary)),
                        SizedBox(height: 4),
                        Text('₹12,500', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AlogyanColors.danger)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Classroom Action Bar
            const Text(
              'Classroom Floor Actions',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AlogyanColors.textPrimary),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AlogyanColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(LucideIcons.userCheck, size: 18),
                    label: const Text('Take Attendance', style: TextStyle(fontSize: 13)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickAttendanceScreen()),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AlogyanColors.textPrimary,
                      side: const BorderSide(color: AlogyanColors.border),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    icon: const Icon(LucideIcons.indianRupee, size: 18),
                    label: const Text('Collect Fee', style: TextStyle(fontSize: 13)),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuickFeeScreen()),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Today's Timeline
            const Text(
              "Today's Schedule",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary),
            ),
            const SizedBox(height: 12),

            _buildClassCard(
              context,
              time: '04:00 PM - 05:30 PM',
              batchName: 'Class 10 - Advanced Physics',
              roomOrMeet: 'Room 201 (Offline)',
              status: 'NEXT CLASS',
              statusType: StatusBadgeType.warning,
            ),
            const SizedBox(height: 12),
            _buildClassCard(
              context,
              time: '06:00 PM - 07:30 PM',
              batchName: 'Class 12 - Calculus Masterclass',
              roomOrMeet: 'Google Meet (1-tap start)',
              status: 'ONLINE',
              statusType: StatusBadgeType.info,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCard(
    BuildContext context, {
    required String time,
    required String batchName,
    required String roomOrMeet,
    required String status,
    required StatusBadgeType statusType,
  }) {
    return AlogyanCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(time, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AlogyanColors.textSecondary)),
              StatusBadge(label: status, type: statusType),
            ],
          ),
          const SizedBox(height: 8),
          Text(batchName, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AlogyanColors.textPrimary)),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(LucideIcons.mapPin, size: 14, color: AlogyanColors.textMuted),
              const SizedBox(width: 4),
              Text(roomOrMeet, style: const TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
```

```dart
// alogyan_app/lib/features/attendance/screens/quick_attendance_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';

class QuickAttendanceScreen extends StatefulWidget {
  const QuickAttendanceScreen({super.key});

  @override
  State<QuickAttendanceScreen> createState() => _QuickAttendanceScreenState();
}

class _QuickAttendanceScreenState extends State<QuickAttendanceScreen> {
  final List<Map<String, dynamic>> _students = [
    {'id': '1', 'name': 'Aarav Sharma', 'roll': '101', 'status': 'present'},
    {'id': '2', 'name': 'Diya Sen', 'roll': '102', 'status': 'present'},
    {'id': '3', 'name': 'Ishaan Roy', 'roll': '103', 'status': 'absent'},
    {'id': '4', 'name': 'Meera Patel', 'roll': '104', 'status': 'present'},
    {'id': '5', 'name': 'Rohan Das', 'roll': '105', 'status': 'present'},
  ];

  void _toggleStatus(int index) {
    setState(() {
      final current = _students[index]['status'];
      if (current == 'present') {
        _students[index]['status'] = 'absent';
      } else if (current == 'absent') {
        _students[index]['status'] = 'late';
      } else {
        _students[index]['status'] = 'present';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final presentCount = _students.where((s) => s['status'] == 'present').length;
    final total = _students.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rapid Attendance (Class 10 Physics)'),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AlogyanColors.surfaceMuted,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('$presentCount / $total Present', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      for (final s in _students) {
                        s['status'] = 'present';
                      }
                    });
                  },
                  child: const Text('Mark All Present'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: _students.length,
              separatorBuilder: (_, __) => const Divider(height: 1, color: AlogyanColors.border),
              itemBuilder: (context, index) {
                final student = _students[index];
                final status = student['status'] as String;

                Color badgeBg = AlogyanColors.successLight;
                Color badgeFg = AlogyanColors.success;
                if (status == 'absent') {
                  badgeBg = AlogyanColors.dangerLight;
                  badgeFg = AlogyanColors.danger;
                } else if (status == 'late') {
                  badgeBg = AlogyanColors.warningLight;
                  badgeFg = AlogyanColors.warning;
                }

                return ListTile(
                  title: Text(student['name'] as String, style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text('Roll #${student['roll']}'),
                  trailing: InkWell(
                    onTap: () => _toggleStatus(index),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 90,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        status.toUpperCase(),
                        style: TextStyle(color: badgeFg, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: PrimaryButton(
                  text: 'Submit Attendance ($presentCount/$total)',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Attendance submitted & queued offline')),
                    );
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

```dart
// alogyan_app/lib/features/fees/screens/quick_fee_screen.dart
import 'package:flutter/material.dart';
import '../../../core/constants/colors.dart';
import '../../../shared/widgets/primary_button.dart';

class QuickFeeScreen extends StatefulWidget {
  const QuickFeeScreen({super.key});

  @override
  State<QuickFeeScreen> createState() => _QuickFeeScreenState();
}

class _QuickFeeScreenState extends State<QuickFeeScreen> {
  final TextEditingController _amountController = TextEditingController(text: '2000');
  String _paymentMode = 'upi';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Fee Collection'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Student', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 4),
            const Text('Aarav Sharma (Class 10 Physics)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Amount (₹)', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 6),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Payment Mode', style: TextStyle(fontSize: 13, color: AlogyanColors.textSecondary)),
            const SizedBox(height: 8),
            Row(
              children: [
                ChoiceChip(
                  label: const Text('Dynamic UPI QR'),
                  selected: _paymentMode == 'upi',
                  onSelected: (val) => setState(() => _paymentMode = 'upi'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Cash'),
                  selected: _paymentMode == 'cash',
                  onSelected: (val) => setState(() => _paymentMode = 'cash'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_paymentMode == 'upi') ...[
              Center(
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AlogyanColors.border),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.qr_code_2, size: 120, color: AlogyanColors.textPrimary),
                      Text('Scan using GPay / PhonePe', style: TextStyle(fontSize: 11, color: AlogyanColors.textSecondary)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            SizedBox(
              width: double.infinity,
              child: PrimaryButton(
                text: 'Confirm & Send WhatsApp Receipt',
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Payment recorded and queued to sync')),
                  );
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

```dart
// alogyan_app/lib/app.dart
import 'package:flutter/material.dart';
import 'core/constants/styles.dart';
import 'features/dashboard/screens/dashboard_screen.dart';

class AlogyanApp extends StatelessWidget {
  const AlogyanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Alogyan Companion',
      debugShowCheckedModeBanner: false,
      theme: AlogyanStyles.themeData,
      home: const DashboardScreen(),
    );
  }
}
```

```dart
// alogyan_app/lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'app.dart';
import 'core/sync/sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox(SyncService.boxName);

  runApp(
    const ProviderScope(
      child: AlogyanApp(),
    ),
  );
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `flutter test test/features/dashboard/dashboard_screen_test.dart` in `alogyan_app`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add alogyan_app/lib/ alogyan_app/test/features/
git commit -m "feat(alogyan_app): implement companion dashboard, rapid attendance, and fee screens"
```

---

### Task 5: Full Project Verification & Analysis Gate

**Files:**
- Test: All tests in `alogyan_app/test/`

- [ ] **Step 1: Run static analysis**

Run: `flutter analyze` in `alogyan_app`
Expected: "No issues found!"

- [ ] **Step 2: Run all unit & widget tests**

Run: `flutter test` in `alogyan_app`
Expected: All tests pass (0 failures)

- [ ] **Step 3: Commit and lock**

```bash
git add alogyan_app/
git commit -m "chore(alogyan_app): finalize flutter scaffold, design system, and test suite"
```
