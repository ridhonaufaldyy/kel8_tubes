import 'package:flutter/material.dart';
import '../MyBotNavBar.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pembayaran Sukses',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SuccessPage(),
    );
  }
}

class SuccessPage extends StatefulWidget {
  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'), // Ganti dengan gambar latar belakang yang sesuai
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sukses.png',
                height: 200, // Sesuaikan dengan ukuran gambar
              ),
              SizedBox(height: 20),
              Text(
                'Pembayaran Berhasil',
                style: TextStyle(
                  fontSize: 28, // Ukuran teks sedikit besar
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Data pembayaran sudah berhasil diproses',
                style: TextStyle(
                  fontSize: 16, // Ukuran teks kecil
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              // ElevatedButton(
              //   onPressed: () {
              //     // Ganti dengan navigasi ke halaman yang sesuai
              //   },
              //   child: Text('Lihat Antrian'), // Ubah teks tombol
              // ),
            ],
          ),
        ),
      ),
      // bottomNavigationBar: MyBottomNavigationBar(
      //   selectedIndex: _selectedIndex,
      //   onItemTapped: (index) {
      //     setState(() {
      //       _selectedIndex = index;
      //     });
      //   },
      // ),
    );
  }
}
