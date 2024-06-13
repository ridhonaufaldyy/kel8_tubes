import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'RatingDokter.dart';

// Definisi model Dokter
class Dokter {
  final String fullName;
  final String email;
  final String telphone;
  final int idPoliklinik;
  final String keterangan;
  final int rating;
  final int harga;
  final String deskripsi;
  final String imageUrl;
  final int idDokter;
  late final KategoriDokter category; // Menambahkan properti category

  Dokter({
    required this.fullName,
    required this.email,
    required this.telphone,
    required this.idPoliklinik,
    required this.keterangan,
    required this.rating,
    required this.harga,
    required this.deskripsi,
    required this.imageUrl,
    required this.idDokter,
  });

  factory Dokter.fromJson(Map<String, dynamic> json) {
    return Dokter(
      fullName: json['fullname'],
      email: json['email'],
      telphone: json['telphone'],
      idPoliklinik: json['id_poliklinik'],
      keterangan: json['keterangan'],
      rating: json['rating'],
      harga: json['harga'],
      deskripsi: json['deskripsi'],
      imageUrl: json['image_url'],
      idDokter: json['id_dokter'],
    );
  }
}

class JanjiTemuPage extends StatefulWidget {
  final int userId;
  final String token;

  JanjiTemuPage({
    required this.userId,
    required this.token,
  });

  @override
  _JanjiTemuState createState() => _JanjiTemuState();
}

class _JanjiTemuState extends State<JanjiTemuPage> {
  // int _selectedIndex = 0;
  KategoriDokter? _selectedCategory;
  List<Dokter> _dokterList = [];

  TextEditingController _searchController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    // Panggil fungsi untuk mengambil data dari endpoint saat initState dipanggil
    _fetchData();
  }

  // Fungsi untuk mengambil data dari endpoint
Future<void> _fetchData() async {
  try {
    // Ganti 'your_token' dengan token yang Anda miliki
    // final String token = 'your_token';

    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/api/dokters/?skip=0&limit=100'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json', // Optional, sesuaikan dengan kebutuhan Anda
      },
    );
    if (response.statusCode == 200) {
      final List<dynamic> responseData = jsonDecode(response.body);
      // Konversi data JSON menjadi list Dokter
      final List<Dokter> dokterList = responseData.map((data) {
        final dokter = Dokter.fromJson(data);
        dokter.category = _mapPoliklinikToCategory(dokter.idPoliklinik);
        return dokter;
      }).toList();
      setState(() {
        _dokterList = dokterList;
      });
    } else {
      // Handle error response
      print('Error: ${response.statusCode}');
    }
  } catch (e) {
    // Handle network error
    print('Error: $e');
  }
}
  void _onCategorySelected(KategoriDokter category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        title: Text('Janji Temu Dokter'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(64.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchText = value;
                });
              },
              decoration: const InputDecoration(
                hintText: 'Cari dokter...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            _KategoriDokter(onCategorySelected: _onCategorySelected),
            SizedBox(height: 24.0),
            _buildPilihDokter(),
            SizedBox(height: 24.0),
          ],
        ),
      ),
    );
  }

  // Fungsi untuk membangun widget Pilih Dokter dengan kategori yang dipilih
  Widget _buildPilihDokter() {
    final List<Dokter> filteredDoctors = _dokterList
        .where((doctor) =>
            (_selectedCategory == null ||
                doctor.idPoliklinik == _selectedCategory!.index) &&
            (doctor.fullName.toLowerCase().contains(_searchText.toLowerCase())))
        .toList();

    return Column(
      children: [
        SectionTitle(
          title: 'Pilih Dokter',
          action: 'See all',
          onPressed: () {},
        ),
        const SizedBox(height: 8.0),
        ListView.separated(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          separatorBuilder: (context, index) {
            return Divider(
              height: 24.0,
              color: Colors.teal,
            );
          },
          itemCount: filteredDoctors.length,
          itemBuilder: (context, index) {
            final doctor = filteredDoctors[index];
            return DoctorListTile(
              doctor: doctor,
              userId:
                  widget.userId, // Meneruskan userId dari widget JanjiTemuPage
              token: widget.token, // Meneruskan token dari widget JanjiTemuPage
            );
          },
        ),
      ],
    );
  }
}

class DoctorListTile extends StatelessWidget {
  const DoctorListTile({
    Key? key,
    required this.doctor,
    required this.userId, // Tambahkan parameter userId
    required this.token, // Tambahkan parameter token
  }) : super(key: key);

  final Dokter doctor;
  final int userId; // Deklarasikan userId
  final String token; // Deklarasikan token

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      onTap: () {},
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 30.0,
        backgroundColor: colorScheme.background,
        // Menggunakan Image.network untuk menampilkan gambar dari URL
        backgroundImage: NetworkImage('${doctor.imageUrl}'),
      ),
      title: Text(
        doctor.fullName,
        style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            doctor.keterangan,
            style: textTheme.bodyMedium!.copyWith(
              color: Colors.teal,
            ),
          ),
          const SizedBox(height: 8.0),
          Row(
            children: [
              Icon(
                Icons.star,
                color: Color(0xFF095259),
                size: 16,
              ),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toString(),
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                doctor.harga.toString(),
                style: textTheme.bodySmall!.copyWith(
                  color: colorScheme.onBackground.withOpacity(0.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RatingDokter(
                userId: userId, // Teruskan userId
                token: token, // Teruskan token
                idDokter: doctor.idDokter, // Teruskan idDokter dari dokter yang dipilih
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF0A535A),
        ),
        child: const Text(
          'Buat Janji',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}

class _KategoriDokter extends StatelessWidget {
  final Function(KategoriDokter) onCategorySelected;

  const _KategoriDokter({Key? key, required this.onCategorySelected})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SectionTitle(
          title: 'Kategori',
          action: 'See all',
          onPressed: () {},
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: KategoriDokter.values
              .map(
                (category) => Expanded(
                  child: GestureDetector(
                    onTap: () => onCategorySelected(category),
                    child: TextLabel(
                      label: category.name,
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({
    Key? key,
    required this.title,
    this.action,
    this.onPressed,
  }) : super(key: key);

  final String title;
  final String? action;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
        ),
        if (action != null)
          TextButton(
            onPressed: onPressed,
            child: Text(
              action!,
              style: textTheme.bodyMedium!.copyWith(
                decoration: TextDecoration.underline,
                color: colorScheme.secondary,
              ),
            ),
          ),
      ],
    );
  }
}

class TextLabel extends StatelessWidget {
  const TextLabel({
    Key? key,
    required this.label,
    this.onTap,
  }) : super(key: key);

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          const SizedBox(height: 8.0),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Definisi enum KategoriDokter
enum KategoriDokter {
  dokterUmum,
  dokterAnak,
  dokterKandungan,
  dokterGigi,
  dokterMata,
// Tambahkan kategori lainnya di sini
}

extension KategoriDokterExtension on KategoriDokter {
  String get name {
    switch (this) {
      case KategoriDokter.dokterUmum:
        return "Dokter Umum";
      case KategoriDokter.dokterAnak:
        return "Dokter Anak";
      case KategoriDokter.dokterGigi:
        return "Dokter Gigi";
      case KategoriDokter.dokterMata:
        return "Dokter Mata";
      case KategoriDokter.dokterKandungan:
        return "Dokter Kandungan";
      default:
        return "";
    }
  }
}

// Tambahkan case baru untuk kategori dokter berdasarkan id_poliklinik
KategoriDokter _mapPoliklinikToCategory(int idPoliklinik) {
  switch (idPoliklinik) {
    case 1:
      return KategoriDokter.dokterUmum;
    case 2:
      return KategoriDokter.dokterGigi;
    case 3:
      return KategoriDokter.dokterMata;
    case 4:
      return KategoriDokter.dokterKandungan;
    default:
      return KategoriDokter.dokterUmum;
  }
}
