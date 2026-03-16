import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:ayrnow/providers/auth_provider.dart';
import 'package:ayrnow/main.dart';

void main() {
  testWidgets('App loads with AYRNOW branding', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: const AyrnowApp(),
      ),
    );
    await tester.pump();
    expect(find.text('AYRNOW'), findsWidgets);
  });
}
