import 'package:flutter/material.dart';
// import 'MyBotNavBar.dart';
import 'antrian_by_poli.dart';

class QueuePage extends StatefulWidget {
  final int userId;
  final String token;

  QueuePage({
    required this.userId,
    required this.token,
  });

  @override
  _QueuePageState createState() => _QueuePageState();
}

class _QueuePageState extends State<QueuePage> {
  // int _selectedIndex = 1;

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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Daftar Antrian',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 30),
                Expanded(
                  child: ListView(
                    children: [
                      buildAntrianButton(context, 'Antrian Poli Umum', 1),
                      SizedBox(height: 25),
                      buildAntrianButton(context, 'Antrian Poli Gigi', 2),
                      SizedBox(height: 25),
                      buildAntrianButton(context, 'Antrian Poli Mata', 3),
                      SizedBox(height: 25),
                      buildAntrianButton(context, 'Antrian Poli Kandungan', 4),
                    ],
                  ),
                ),
              ],
            ),
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

  Widget buildAntrianButton(BuildContext context, String text, int poliId) {
    return Container(
      width: 250,
      height: 100, // Perbesar tinggi tombol
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.all(16), // Perbesar padding
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Ini membuat bentuk bulat
          ),
        ),
        onPressed: () {
          String poliName;
          switch (poliId) {
            case 1:
              poliName = 'Umum';
              break;
            case 2:
              poliName = 'Gigi';
              break;
            case 3:
              poliName = 'Mata';
              break;
            case 4:
              poliName = 'Kandungan';
              break;
            default:
              poliName = 'Umum';
          }

          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AntrianPage(
              userId: widget.userId,
              token: widget.token, 
              poliId: poliId, 
              poliName: poliName)),
          );
        },
        child: Text(
          text,
          style: TextStyle(fontSize: 24), // Perbesar ukuran teks
        ),
      ),
    );
  }
}
