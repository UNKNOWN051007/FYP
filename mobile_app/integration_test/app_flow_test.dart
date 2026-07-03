// End-to-end UI test of the salary → COL → negotiation linkage.
//
// Drives the REAL app (real Supabase auth, real backend at BACKEND_URL)
// exactly like a user: login → predict → COL check card → low offer →
// negotiation leverage → Full analysis → COL tab prefilled.
//
// Prerequisites:
//   - backend running on BACKEND_URL from assets/.env (localhost:8000)
//   - chromedriver on port 4444
// Run:
//   flutter drive --driver=test_driver/integration_test.dart \
//     --target=integration_test/app_flow_test.dart -d chrome
//
// NOTE: never use pumpAndSettle here — AnimatedBackground runs infinite
// animations, so the tree never settles. Use pumpUntil instead.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wagewise/main.dart' as app;
import 'package:wagewise/widgets/common_widgets.dart';

// Dedicated pre-confirmed test account (created via Supabase admin API by
// scratchpad/create_test_user.py) — do NOT use the developer's real account
// here: its password changes when the reset-password flow is manually tested.
const _email = 'wagewise.uitest@wagewise-test.dev';
const _password = 'UiTest#2026!';

String visibleTexts(WidgetTester tester) {
  final texts = find
      .byType(Text)
      .evaluate()
      .map((e) => (e.widget as Text).data ?? '')
      .where((s) => s.trim().isNotEmpty)
      .toList();
  return texts.join(' | ');
}

Future<void> pumpUntil(
  WidgetTester tester,
  Finder finder, {
  Duration timeout = const Duration(seconds: 30),
  String? reason,
}) async {
  final deadline = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(deadline)) {
    await tester.pump(const Duration(milliseconds: 200));
    if (finder.evaluate().isNotEmpty) return;
  }
  fail('Timed out waiting for $finder${reason != null ? ' — $reason' : ''}\n'
      'Visible texts: ${visibleTexts(tester)}');
}

/// Focus the field, enter text via IME, then fall back to setting the
/// controller directly if the IME route didn't stick (desktop flakiness).
Future<void> typeInto(WidgetTester tester, Finder field, String text) async {
  await tester.tap(field);
  await tester.pump(const Duration(milliseconds: 150));
  await tester.enterText(field, text);
  await tester.pump(const Duration(milliseconds: 150));
  final tf = tester.widget<TextField>(field);
  if ((tf.controller?.text ?? '') != text) {
    tf.controller?.text = text;
    await tester.pump(const Duration(milliseconds: 150));
  }
}

Future<void> selectDropdown(WidgetTester tester, String hint, String value) async {
  // Tap the DropdownButton itself, not its hint Text (hit-area flakiness).
  final dropdown = find.ancestor(
    of: find.text(hint),
    matching: find.byType(DropdownButton<String>),
  );
  await tester.ensureVisible(dropdown);
  await tester.pump(const Duration(milliseconds: 200));
  await tester.tap(dropdown, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 400));
  // Long menus build lazily — scroll the freshly opened menu (the last
  // Scrollable in the tree) until the item exists, like a user would.
  if (find.text(value).evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      find.text(value),
      100,
      scrollable: find.byType(Scrollable).last,
      maxScrolls: 60,
    );
    await tester.pump(const Duration(milliseconds: 200));
  }
  // NOTE: poll a plain finder — .last throws on empty sets during the loop.
  await pumpUntil(tester, find.text(value), reason: 'dropdown menu "$hint"');
  await tester.tap(find.text(value).last, warnIfMissed: false);
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('login → predict → COL card → offer → negotiation → full analysis',
      (tester) async {
    // Clear persisted state (Supabase session, theme) so every run starts
    // logged-out. A stale expired session otherwise makes Supabase.initialize
    // throw from its internal recovery future, aborting the test at ~5s.
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    app.main(); // async void: dotenv + Supabase load, then runApp
    await tester.pump(const Duration(milliseconds: 500));

    // ── Splash → Login OR straight to Main (persisted session) ────
    final loginBtn = find.widgetWithText(GradientButton, 'Sign In');
    final mainNav = find.byIcon(Icons.bar_chart_outlined);
    final bootDeadline = DateTime.now().add(const Duration(seconds: 30));
    while (DateTime.now().isBefore(bootDeadline) &&
        loginBtn.evaluate().isEmpty &&
        mainNav.evaluate().isEmpty) {
      await tester.pump(const Duration(milliseconds: 200));
    }

    if (mainNav.evaluate().isEmpty) {
      // Fresh state — sign in with the dedicated test account.
      await typeInto(tester, find.byType(TextField).at(0), _email);
      await typeInto(tester, find.byType(TextField).at(1), _password);
      // The email must actually RENDER in the field before tapping Sign In.
      await pumpUntil(tester, find.text(_email),
          timeout: const Duration(seconds: 5), reason: 'email rendered in field');
      await tester.tap(loginBtn);
      await pumpUntil(tester, mainNav,
          timeout: const Duration(seconds: 45), reason: 'main scaffold after login');
    }

    // ── Salary tab: fill the chained form ─────────────────────────
    // Tap can miss during post-boot layout shifts — retry until the form shows.
    for (var i = 0; i < 10 && find.text('Select industry').evaluate().isEmpty; i++) {
      await tester.tap(find.byIcon(Icons.bar_chart_outlined), warnIfMissed: false);
      await tester.pump(const Duration(milliseconds: 500));
    }
    await pumpUntil(tester, find.text('Select industry'), reason: 'salary form');

    // Job title must be locked until an industry is picked.
    expect(find.text('Select an industry first'), findsOneWidget);

    await selectDropdown(tester, 'Select industry', 'Information Technology');
    await selectDropdown(tester, 'Select job title', 'Software Engineer');
    await selectDropdown(tester, 'Select education', "Bachelor's Degree");
    await selectDropdown(tester, 'Select city', 'Kuala Lumpur');

    await tester.ensureVisible(find.widgetWithText(GradientButton, 'Predict My Salary'));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.tap(find.widgetWithText(GradientButton, 'Predict My Salary'));

    // ── Results + automatic COL check (market rate) ───────────────
    await pumpUntil(tester, find.text('Cost of Living Check'),
        timeout: const Duration(seconds: 30), reason: 'prediction results');
    await pumpUntil(tester, find.text('Net salary (after EPF/SOCSO/tax)'),
        timeout: const Duration(seconds: 20), reason: 'COL card populated');
    expect(find.textContaining('market rate'), findsOneWidget);
    expect(find.textContaining('living wage'), findsWidgets);

    // ── Low offer → negotiation leverage note ─────────────────────
    await tester.ensureVisible(find.byType(TextField).first);
    await typeInto(tester, find.byType(TextField).first, '1800');
    await tester.pump(const Duration(milliseconds: 200));
    await tester.ensureVisible(find.text('Evaluate'));
    await tester.tap(find.text('Evaluate'));

    await pumpUntil(tester, find.textContaining('Below Kuala Lumpur living wage'),
        timeout: const Duration(seconds: 30), reason: 'offer COL check (1800 < living wage)');
    await pumpUntil(tester, find.textContaining('Negotiation leverage'),
        timeout: const Duration(seconds: 10), reason: 'negotiation leverage note');
    expect(find.textContaining('your offer'), findsOneWidget);

    // ── Full analysis → COL tab prefilled + auto-evaluated ────────
    await tester.ensureVisible(find.text('Full analysis'));
    await tester.tap(find.text('Full analysis'));

    await pumpUntil(tester, find.text('Deductions'),
        timeout: const Duration(seconds: 30), reason: 'COL tab auto-evaluation');
    expect(find.text('EPF (11%)'), findsOneWidget);
    // Salary field carried over from the offer.
    expect(find.widgetWithText(TextField, '1800'), findsOneWidget,
        reason: 'COL salary field prefilled with the offer amount');

    // Drain in-flight async work (HTTP, Supabase saves) so nothing completes
    // with an error AFTER the test returns ("failed after it had already
    // completed").
    for (var i = 0; i < 40; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Windows accessibility can flip semantics ON mid-test; the binding then
    // owns a SemanticsHandle that trips the end-of-test check. Simulate the
    // platform turning it off so the binding disposes its handle first.
    tester.platformDispatcher.semanticsEnabledTestValue = false;
    await tester.pump(const Duration(milliseconds: 100));
  });
}
