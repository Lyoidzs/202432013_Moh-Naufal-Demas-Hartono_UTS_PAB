
import 'package:flutter_test/flutter_test.dart';
import 'package:uts/main.dart';

void main() {
  testWidgets('Aplikasi InventarisKu berhasil dibuka',
      (WidgetTester tester) async {
    await tester.pumpWidget(const InventarisKu());

    // Memastikan judul aplikasi muncul
    expect(find.text('InventarisKu'), findsOneWidget);

    // Memastikan tiga menu utama tersedia
    expect(find.text('Inventaris'), findsOneWidget);
    expect(find.text('Peminjaman'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);

    // Memastikan daftar inventaris muncul
    expect(find.text('Daftar Inventaris'), findsOneWidget);

    // Memastikan data barang ditampilkan
    expect(find.text('Laptop Asus'), findsOneWidget);
    expect(find.text('Proyektor Epson'), findsOneWidget);
    expect(find.text('Kamera Canon'), findsOneWidget);
    expect(find.text('Kursi Lipat'), findsOneWidget);
  });
}
