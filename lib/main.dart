import 'package:flutter/material.dart';

void main() {
  runApp(const InventarisKu());
}

// =====================================================
// MODEL BARANG (STRUKTUR DATA TETAP)
// =====================================================

class Barang {
  String nama;
  String kategori;
  int jumlah;
  String kondisi;
  String gambar;

  Barang({
    required this.nama,
    required this.kategori,
    required this.jumlah,
    required this.kondisi,
    required this.gambar,
  });
}

// =====================================================
// MODEL PEMINJAMAN (STRUKTUR DATA TETAP)
// =====================================================

class Peminjaman {
  String namaPeminjam;
  String namaBarang;
  int jumlah;
  String tanggal;
  String status;

  Peminjaman({
    required this.namaPeminjam,
    required this.namaBarang,
    required this.jumlah,
    required this.tanggal,
    this.status = 'Dipinjam',
  });
}

// =====================================================
// DATA DUMMY BARANG
// =====================================================

List<Barang> dataBarang = [
  Barang(
    nama: 'Laptop Asus',
    kategori: 'Elektronik',
    jumlah: 10,
    kondisi: 'Baik',
    gambar:
        'https://images.unsplash.com/photo-1496181133206-80ce9b88a853?w=500',
  ),
  Barang(
    nama: 'Proyektor Epson',
    kategori: 'Elektronik',
    jumlah: 5,
    kondisi: 'Baik',
    gambar:
        'https://images.unsplash.com/photo-1535016120720-40c646be5580?w=500',
  ),
  Barang(
    nama: 'Kamera Canon',
    kategori: 'Dokumentasi',
    jumlah: 4,
    kondisi: 'Baik',
    gambar:
        'https://images.unsplash.com/photo-1516035069371-29a1b244cc32?w=500',
  ),
  Barang(
    nama: 'Kursi Lipat',
    kategori: 'Perlengkapan',
    jumlah: 20,
    kondisi: 'Cukup Baik',
    gambar: 'assets/images/kursi.jpeg',
  ),
];

// =====================================================
// DATA DUMMY PEMINJAMAN
// =====================================================

List<Peminjaman> dataPeminjaman = [
  Peminjaman(
    namaPeminjam: 'Andi',
    namaBarang: 'Laptop Asus',
    jumlah: 2,
    tanggal: '09-11-2026',
  ),
  Peminjaman(
    namaPeminjam: 'Budi',
    namaBarang: 'Kamera Canon',
    jumlah: 1,
    tanggal: '08-11-2026',
    status: 'Dikembalikan',
  ),
];

// =====================================================
// APLIKASI UTAMA
// =====================================================

class InventarisKu extends StatelessWidget {
  const InventarisKu({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'InventarisKu',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FB),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E293B),
          elevation: 0,
        ),
      ),
      home: const HalamanUtama(),
    );
  }
}

// =====================================================
// HALAMAN UTAMA
// =====================================================

class HalamanUtama extends StatefulWidget {
  const HalamanUtama({super.key});

  @override
  State<HalamanUtama> createState() => _HalamanUtamaState();
}

class _HalamanUtamaState extends State<HalamanUtama> {
  int indexTab = 0;

  // Menghitung stok yang masih tersedia
  int barangTersedia(Barang barang) {
    int dipinjam = 0;

    for (var p in dataPeminjaman) {
      if (p.namaBarang == barang.nama && p.status == 'Dipinjam') {
        dipinjam += p.jumlah;
      }
    }

    return barang.jumlah - dipinjam;
  }

  int get totalBarang {
    return dataBarang.fold(0, (sum, item) => sum + item.jumlah);
  }

  int get totalDipinjam {
    return dataPeminjaman
        .where((p) => p.status == 'Dipinjam')
        .length;
  }

  void tambahBarang(Barang barang) {
    setState(() {
      dataBarang.add(barang);
    });
  }

  void tambahPeminjaman(Peminjaman peminjaman) {
    setState(() {
      dataPeminjaman.add(peminjaman);
    });
  }

  // ===================================================
  // FUNGSI PENGEMBALIAN BARANG
  // ===================================================

  Future<void> kembalikanBarang(Peminjaman peminjaman) async {
    final konfirmasi = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Konfirmasi Pengembalian',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Apakah barang berikut sudah dikembalikan?'),
              const SizedBox(height: 15),
              Text('Nama Barang: ${peminjaman.namaBarang}'),
              Text('Peminjam: ${peminjaman.namaPeminjam}'),
              Text('Jumlah: ${peminjaman.jumlah}'),
              Text('Tanggal Pinjam: ${peminjaman.tanggal}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ya, Kembalikan'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (konfirmasi == true) {
      setState(() {
        peminjaman.status = 'Dikembalikan';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Barang berhasil dikembalikan!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  // ===================================================
  // TAMPILAN UTAMA DAN TAB CONTROLLER
  // ===================================================

  @override
  Widget build(BuildContext context) {
    final halaman = [
      halamanInventaris(),
      halamanPeminjaman(),
      halamanRiwayat(),
    ];

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'InventarisKu',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          bottom: TabBar(
            onTap: (index) {
              setState(() {
                indexTab = index;
              });
            },
            tabs: const [
              Tab(icon: Icon(Icons.inventory_2), text: 'Inventaris'),
              Tab(icon: Icon(Icons.assignment), text: 'Peminjaman'),
              Tab(icon: Icon(Icons.history), text: 'Riwayat'),
            ],
          ),
        ),
        body: halaman[indexTab],
        floatingActionButton: indexTab == 0
            ? FloatingActionButton.extended(
                onPressed: () async {
                  final hasil = await Navigator.push<Barang>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FormBarang(),
                    ),
                  );

                  if (hasil != null) {
                    tambahBarang(hasil);
                  }
                },
                icon: const Icon(Icons.add),
                label: const Text('Tambah Barang'),
              )
            : indexTab == 1
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      final hasil = await Navigator.push<Peminjaman>(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormPeminjaman(
                            barang: dataBarang,
                            tersedia: barangTersedia,
                          ),
                        ),
                      );

                      if (hasil != null) {
                        tambahPeminjaman(hasil);
                      }
                    },
                    icon: const Icon(Icons.add),
                    label: const Text('Pinjam Barang'),
                  )
                : null,
      ),
    );
  }

  // ===================================================
  // HALAMAN INVENTARIS
  // ===================================================

  Widget halamanInventaris() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: kartuStatistik(
                  'Total Barang',
                  '$totalBarang',
                  Icons.inventory,
                  Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: kartuStatistik(
                  'Sedang Dipinjam',
                  '$totalDipinjam',
                  Icons.assignment,
                  Colors.orange,
                ),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Daftar Inventaris',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 10),
        Expanded(
          child: dataBarang.isEmpty
              ? const Center(child: Text('Belum ada data barang'))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: dataBarang.length,
                  itemBuilder: (context, index) {
                    final barang = dataBarang[index];

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: SizedBox(
                                width: 95,
                                height: 95,
                                child: gambarBarang(barang.gambar),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    barang.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text('Kategori: ${barang.kategori}'),
                                  Text('Jumlah: ${barang.jumlah}'),
                                  Text('Tersedia: ${barangTersedia(barang)}'),
                                  Text('Kondisi: ${barang.kondisi}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  // Menampilkan gambar dari assets atau internet.
  // Jika gambar kosong, tampilkan ikon inventaris.
  Widget gambarBarang(String gambar) {
    if (gambar.isEmpty) {
      return Container(
        color: Colors.blue.shade50,
        child: const Icon(
          Icons.inventory_2,
          size: 40,
          color: Colors.blue,
        ),
      );
    }

    if (gambar.startsWith('assets/')) {
      return Image.asset(
        gambar,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.blue.shade50,
            child: const Icon(
              Icons.broken_image,
              size: 40,
              color: Colors.blue,
            ),
          );
        },
      );
    }

    return Image.network(
      gambar,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: Colors.blue.shade50,
          child: const Icon(
            Icons.inventory_2,
            size: 40,
            color: Colors.blue,
          ),
        );
      },
    );
  }

  // ===================================================
  // HALAMAN PEMINJAMAN
  // ===================================================

  Widget halamanPeminjaman() {
    final daftar = dataPeminjaman
        .where((p) => p.status == 'Dipinjam')
        .toList();

    return daftar.isEmpty
        ? const Center(child: Text('Belum ada barang yang dipinjam'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: daftar.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final p = daftar[index];

              return Card(
                color: Colors.white,
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE0ECFF),
                    child: Icon(Icons.person, color: Colors.blue),
                  ),
                  title: Text(
                    p.namaPeminjam,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    '${p.namaBarang}\n'
                    'Jumlah: ${p.jumlah} | Tanggal: ${p.tanggal}',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    tooltip: 'Kembalikan barang',
                    icon: const Icon(
                      Icons.assignment_return,
                      color: Colors.green,
                    ),
                    onPressed: () => kembalikanBarang(p),
                  ),
                ),
              );
            },
          );
  }

  // ===================================================
  // HALAMAN RIWAYAT DAN PENGEMBALIAN
  // ===================================================

  Widget halamanRiwayat() {
    return dataPeminjaman.isEmpty
        ? const Center(child: Text('Belum ada riwayat peminjaman'))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: dataPeminjaman.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 10),
            itemBuilder: (context, index) {
              final p = dataPeminjaman[index];
              final aktif = p.status == 'Dipinjam';

              return Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: aktif
                                ? Colors.orange.shade100
                                : Colors.green.shade100,
                            child: Icon(
                              aktif ? Icons.access_time : Icons.check_circle,
                              color: aktif ? Colors.orange : Colors.green,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  p.namaBarang,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text('Peminjam: ${p.namaPeminjam}'),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: aktif
                                  ? Colors.orange.shade100
                                  : Colors.green.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              p.status,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: aktif
                                    ? Colors.orange.shade900
                                    : Colors.green.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24),
                      Text('Jumlah Barang: ${p.jumlah}'),
                      Text('Tanggal Pinjam: ${p.tanggal}'),
                      if (aktif) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => kembalikanBarang(p),
                            icon: const Icon(Icons.assignment_return),
                            label: const Text('Kembalikan Barang'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ] else ...[
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Barang telah dikembalikan',
                                  style: TextStyle(
                                    color: Colors.green.shade800,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
  }

  // ===================================================
  // KARTU STATISTIK
  // ===================================================

  Widget kartuStatistik(
    String judul,
    String nilai,
    IconData icon,
    Color warna,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: warna.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: warna, size: 30),
          const SizedBox(height: 10),
          Text(
            nilai,
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: warna,
            ),
          ),
          Text(judul, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// =====================================================
// FORM TAMBAH BARANG
// =====================================================

class FormBarang extends StatefulWidget {
  const FormBarang({super.key});

  @override
  State<FormBarang> createState() => _FormBarangState();
}

class _FormBarangState extends State<FormBarang> {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final jumlahController = TextEditingController();

  String kategori = 'Elektronik';
  String kondisi = 'Baik';

  @override
  void dispose() {
    namaController.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  void simpanBarang() {
    if (formKey.currentState!.validate()) {
      final barang = Barang(
        nama: namaController.text.trim(),
        kategori: kategori,
        jumlah: int.parse(jumlahController.text),
        kondisi: kondisi,
        // Barang baru tidak wajib menggunakan URL gambar.
        gambar: '',
      );

      Navigator.pop(context, barang);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Inventaris')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Formulir Barang Baru',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Nama Barang'),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama barang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.inventory),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama barang wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Kategori'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: kategori,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  'Elektronik',
                  'Dokumentasi',
                  'Perlengkapan',
                  'Lainnya',
                ].map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      kategori = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              const Text('Jumlah Barang'),
              const SizedBox(height: 8),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan jumlah barang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }

                  final jumlah = int.tryParse(value);
                  if (jumlah == null || jumlah <= 0) {
                    return 'Masukkan jumlah yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Kondisi Barang'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: kondisi,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: ['Baik', 'Cukup Baik', 'Rusak'].map((item) {
                  return DropdownMenuItem(value: item, child: Text(item));
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      kondisi = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: simpanBarang,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Barang'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// FORM PEMINJAMAN BARANG
// =====================================================

class FormPeminjaman extends StatefulWidget {
  final List<Barang> barang;
  final int Function(Barang) tersedia;

  const FormPeminjaman({
    super.key,
    required this.barang,
    required this.tersedia,
  });

  @override
  State<FormPeminjaman> createState() => _FormPeminjamanState();
}

class _FormPeminjamanState extends State<FormPeminjaman> {
  final formKey = GlobalKey<FormState>();

  final namaController = TextEditingController();
  final jumlahController = TextEditingController();

  String? barangDipilih;
  DateTime tanggal = DateTime.now();

  @override
  void dispose() {
    namaController.dispose();
    jumlahController.dispose();
    super.dispose();
  }

  Future<void> pilihTanggal() async {
    final hasil = await showDatePicker(
      context: context,
      initialDate: tanggal,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );

    if (hasil != null) {
      setState(() {
        tanggal = hasil;
      });
    }
  }

  String formatTanggal(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.year}';
  }

  void simpanPeminjaman() {
    if (!formKey.currentState!.validate()) {
      return;
    }

    final barang = widget.barang.firstWhere(
      (b) => b.nama == barangDipilih,
    );

    final jumlah = int.parse(jumlahController.text);

    if (jumlah > widget.tersedia(barang)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Jumlah melebihi stok yang tersedia'),
        ),
      );
      return;
    }

    final peminjaman = Peminjaman(
      namaPeminjam: namaController.text.trim(),
      namaBarang: barangDipilih!,
      jumlah: jumlah,
      tanggal: formatTanggal(tanggal),
    );

    Navigator.pop(context, peminjaman);
  }

  @override
  Widget build(BuildContext context) {
    final barangTersedia = widget.barang
        .where((b) => widget.tersedia(b) > 0)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Form Peminjaman')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Catat Peminjaman Barang',
                style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Text('Nama Peminjam'),
              const SizedBox(height: 8),
              TextFormField(
                controller: namaController,
                decoration: const InputDecoration(
                  hintText: 'Masukkan nama peminjam',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Nama peminjam wajib diisi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Pilih Barang'),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: barangDipilih,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                hint: const Text('Pilih barang inventaris'),
                items: barangTersedia.map((b) {
                  return DropdownMenuItem(
                    value: b.nama,
                    child: Text(
                      '${b.nama} (Tersedia: ${widget.tersedia(b)})',
                    ),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    barangDipilih = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Pilih barang terlebih dahulu';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Jumlah Dipinjam'),
              const SizedBox(height: 8),
              TextFormField(
                controller: jumlahController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  hintText: 'Masukkan jumlah barang',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Jumlah wajib diisi';
                  }

                  final jumlah = int.tryParse(value);
                  if (jumlah == null || jumlah <= 0) {
                    return 'Masukkan jumlah yang valid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              const Text('Tanggal Peminjaman'),
              const SizedBox(height: 8),
              InkWell(
                onTap: pilihTanggal,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_month),
                  ),
                  child: Text(formatTanggal(tanggal)),
                ),
              ),
              const SizedBox(height: 25),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed:
                      barangTersedia.isEmpty ? null : simpanPeminjaman,
                  icon: const Icon(Icons.save),
                  label: const Text('Simpan Peminjaman'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
