import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../home_page.dart';
// import 'package:latihanflutter/main.dart';

class AntrianSaya extends StatefulWidget {
  final int userId;
  final String token;

  AntrianSaya({
    required this.userId,
    required this.token,
  });

  @override
  _AntrianSayaState createState() => _AntrianSayaState();
}

class _AntrianSayaState extends State<AntrianSaya> {
  int queueNumber = 0;
  int poliId = 0;
  String paymentStatus = ''; // Menyimpan status pembayaran
  late Stream<int> queueNumberStream;
  late StreamSubscription<int> queueNumberSubscription;

  @override
  void initState() {
    super.initState();
    fetchQueueInfo();
    // Langkah 1: Mulai mendengarkan perubahan status pembayaran secara real-time
    startListeningToPaymentStatus();
  }

  @override
  void dispose() {
    queueNumberSubscription.cancel();
    super.dispose();
  }

  void startListeningToPaymentStatus() {
    // Langkah 2: Mulai mendengarkan perubahan status pembayaran
    queueNumberStream = getStatusStream();
    queueNumberSubscription = queueNumberStream.listen((int newQueueNumber) {
      setState(() {
        queueNumber = newQueueNumber;
      });
    });
  }

  // Langkah 3: Metode untuk mengambil status pembayaran secara real-time
  Stream<int> getStatusStream() async* {
    while (true) {
      final apiUrl = 'http://127.0.0.1:8000/antrian/${widget.userId}';
      try {
        final response = await http.get(
          Uri.parse(apiUrl),
          headers: <String, String>{
            'Authorization': 'Bearer ${widget.token}',
          },
        );

        if (response.statusCode == 200) {
          final responseData = json.decode(response.body);
          final newPaymentStatus = responseData['status_pembayaran'];
          if (newPaymentStatus == 'sudah_bayar') {
            yield responseData['no_antrian'];
          }
        } else {
          throw Exception('Failed to fetch queue information');
        }
      } catch (e) {
        print('Error: $e');
        yield -999; // Jika terjadi kesalahan, kirimkan kode status khusus
      }
      await Future.delayed(Duration(seconds: 5)); // Periksa setiap 5 detik
    }
  }

Future<void> fetchQueueInfo() async {
  final apiUrl = 'http://127.0.0.1:8000/antrian/${widget.userId}';
  try {
    final response = await http.get(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Authorization': 'Bearer ${widget.token}',
      },
    );

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        poliId = responseData['poliId'] ?? 0;
        paymentStatus = responseData['status_pembayaran'] ?? '';
        if (paymentStatus == 'sudah_bayar') {
          queueNumber = responseData['no_antrian'] ?? 0;
        }
      });
    } else {
      throw Exception('Failed to fetch queue information');
    }
  } catch (e) {
    print('Error: $e');
    setState(() {
      queueNumber = -999;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    String poliLabel = '';

    // Mengubah poliId menjadi label yang sesuai
    switch (poliId) {
      case 1:
        poliLabel = 'U';
        break;
      case 2:
        poliLabel = 'G';
        break;
      case 3:
        poliLabel = 'M';
        break;
      case 4:
        poliLabel = 'K';
        break;
      default:
        poliLabel = 'KOSONG';
    }

    // Menampilkan nomor antrian atau loading berdasarkan status pembayaran
    Widget queueStatusWidget;
    if (paymentStatus == 'sudah_bayar') {
      queueStatusWidget = Text(
        '$poliLabel-$queueNumber',
        style: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: Colors.blue,
        ),
      );
    } else {
      queueStatusWidget = CircularProgressIndicator(); // Tampilkan loading
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Nomor Antrian'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Nomor Antrian Anda:',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            queueStatusWidget, // Widget yang menampilkan nomor antrian atau loading
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>HomeScreen(
              userId: widget.userId,
              token: widget.token
              )),
            );

              },
              child: Text('Kembali'),
            ),

          ],
        ),
      ),
    );
  }
}
