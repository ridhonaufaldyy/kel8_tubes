import 'package:flutter/material.dart';
import 'succesScreen.dart';
import "../colors.dart"; // Import halaman SuccessScreen

class CashOnDeliveryPage extends StatelessWidget {
  final String selectedCategory;
  final String name;
  final String phoneNumber;
  final String address;
  final String doctorName;
  final int doctorId;
  final int doctorprice;
  final int userId;
  final String token;
  final int poliId;
  final String metodePembayaran;

  const CashOnDeliveryPage({
    Key? key,
    required this.selectedCategory,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.doctorName,
    required this.doctorId,
    required this.doctorprice,
    required this.userId,
    required this.token,
    required this.poliId,
    required this.metodePembayaran,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cash on Delivery'),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), // Ganti dengan nama gambar latar belakang Anda
            fit: BoxFit.cover,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.5), // Warna abu dengan opasitas 50%
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Pembayaran:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black, // Ganti warna teks jika diperlukan
                      ),
                    ),
                    SizedBox(height: 16),
                    Divider(color: Colors.black), // Garis pemisah dengan warna putih
                    SizedBox(height: 20),
                    Text(
                      'Tata Cara Pembayaran di Administrasi Rumah Sakit:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.black, // Ganti warna teks jika diperlukan
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Kunjungi bagian administrasi rumah sakit setelah menerima layanan medis.',
                      style: TextStyle(color: Colors.black), // Ganti warna teks jika diperlukan
                    ),
                    Text(
                      '2. Berikan informasi pasien dan detail perawatan kepada petugas administrasi.',
                      style: TextStyle(color: Colors.black), // Ganti warna teks jika diperlukan
                    ),
                    Text(
                      '3. Petugas akan memberikan rincian tagihan dan opsi pembayaran yang tersedia.',
                      style: TextStyle(color: Colors.black), // Ganti warna teks jika diperlukan
                    ),
                    Text(
                      '4. Pilih metode pembayaran yang sesuai, seperti kartu kredit, transfer bank, atau tunai.',
                      style: TextStyle(color: Colors.black), // Ganti warna teks jika diperlukan
                    ),
                    Text(
                      '5. Setelah pembayaran selesai, pastikan untuk meminta dan menyimpan bukti pembayaran.',
                      style: TextStyle(color: Colors.black), // Ganti warna teks jika diperlukan
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20), // Spasi antara teks tata cara pembayaran dan tombol
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => SuccessPage(
                        selectedCategory: selectedCategory,
                        name: name,
                        phoneNumber: phoneNumber,
                        address: address,
                        doctorName: doctorName,
                        doctorId: doctorId,
                        doctorprice: doctorprice,
                        metodePembayaran: metodePembayaran,
                        userId: userId,
                        token: token,
                        poliId: poliId,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Warna latar belakang hijau
                ),
                child: Text('Konfirmasi Pembayaran'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
