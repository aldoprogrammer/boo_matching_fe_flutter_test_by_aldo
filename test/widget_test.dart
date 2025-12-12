import 'package:flutter_test/flutter_test.dart';
import 'package:boo_matching_fe_flutter_test_by_aldo/main.dart';
import 'package:boo_matching_fe_flutter_test_by_aldo/pages/matching_page.dart';

void main() {
  testWidgets('MatchingApp smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MatchingApp());

    // Cek apakah halaman MatchingPage muncul.
    expect(find.byType(MatchingPage), findsOneWidget);

    // Contoh interaksi placeholder: tap tombol X pertama
    // (pastikan tombol X ada di MatchingPage)
    // await tester.tap(find.byIcon(Icons.close).first);
    // await tester.pump();

    // Bisa tambah assert lain sesuai state tombol atau profil
  });
}
