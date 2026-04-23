import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:assetflow_mobile/core/theme/app_theme.dart';
import 'package:assetflow_mobile/core/widgets/app_button.dart';
import 'package:assetflow_mobile/features/auth/providers/auth_provider.dart';
import 'package:assetflow_mobile/features/auth/screens/login_screen.dart';

// Minimal fake AuthNotifier — overrides login to never call real AuthService
class _FakeAuthNotifier extends AuthNotifier {
  _FakeAuthNotifier() : super();

  @override
  Future<void> login(String email, String password) async {}

  @override
  Future<void> checkAuth() async {}
}

void main() {
  // ─── AppButton ────────────────────────────────────────────────────────────────

  group('AppButton', () {
    Widget wrap(Widget child) => MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: Center(child: child)),
        );

    testWidgets('metin doğru render edilir', (tester) async {
      await tester.pumpWidget(wrap(
        AppButton(text: 'Kaydet', onPressed: () {}),
      ));
      expect(find.text('Kaydet'), findsOneWidget);
    });

    testWidgets('isLoading=true iken CircularProgressIndicator gösterilir', (tester) async {
      await tester.pumpWidget(wrap(
        const AppButton(text: 'Yükleniyor', isLoading: true),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Yükleniyor'), findsNothing);
    });

    testWidgets('onPressed çağrılır', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        AppButton(text: 'Tıkla', onPressed: () => tapped = true),
      ));
      await tester.tap(find.byType(AppButton));
      expect(tapped, isTrue);
    });

    testWidgets('onPressed=null iken tıklama bir şey yapmaz', (tester) async {
      await tester.pumpWidget(wrap(
        const AppButton(text: 'Pasif'),
      ));
      // Should not throw
      await tester.tap(find.byType(AppButton), warnIfMissed: false);
      expect(find.text('Pasif'), findsOneWidget);
    });

    testWidgets('danger varyantı render edilir', (tester) async {
      await tester.pumpWidget(wrap(
        AppButton(
          text: 'Sil',
          variant: AppButtonVariant.danger,
          onPressed: () {},
        ),
      ));
      expect(find.text('Sil'), findsOneWidget);
    });

    testWidgets('isFullWidth=true SizedBox.expand içerir', (tester) async {
      await tester.pumpWidget(wrap(
        AppButton(text: 'Tam', isFullWidth: true, onPressed: () {}),
      ));
      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  // ─── LoginScreen form validasyon ─────────────────────────────────────────────

  group('LoginScreen form validasyonu', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    Widget buildScreen() {
      return ProviderScope(
        overrides: [
          authProvider.overrideWith((_) => _FakeAuthNotifier()),
        ],
        child: MaterialApp(
          theme: AppTheme.lightTheme,
          home: const LoginScreen(),
        ),
      );
    }

    testWidgets('e-posta ve şifre alanları render edilir', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Giriş Yap'), findsOneWidget);
    });

    testWidgets('boş form gönderilince e-posta hatası gösterilir', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();

      expect(find.text('E-posta gerekli'), findsOneWidget);
    });

    testWidgets('boş form gönderilince şifre hatası gösterilir', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();

      expect(find.text('Şifre gerekli'), findsOneWidget);
    });

    testWidgets('@ içermeyen e-posta format hatası verir', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'gecersiz-email');
      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();

      expect(find.text('Geçerli bir e-posta girin'), findsOneWidget);
    });

    testWidgets('geçerli e-posta girince e-posta hatası kaybolur', (tester) async {
      await tester.pumpWidget(buildScreen());
      await tester.pump();

      final fields = find.byType(TextFormField);
      await tester.enterText(fields.first, 'kullanici@sirket.com');
      await tester.tap(find.text('Giriş Yap'));
      await tester.pump();

      expect(find.text('E-posta gerekli'), findsNothing);
      expect(find.text('Geçerli bir e-posta girin'), findsNothing);
    });
  });
}
