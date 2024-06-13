import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'queue_page.dart';

class SuccessPage extends StatefulWidget {
  final String selectedCategory;
  final String name;
  final String phoneNumber;
  final String address;
  final String doctorName;
  final int doctorId;
  final int doctorprice;
  final String metodePembayaran;
  final int userId;
  final String token;
  final int poliId;

  const SuccessPage({
    required this.selectedCategory,
    required this.name,
    required this.phoneNumber,
    required this.address,
    required this.doctorName,
    required this.doctorId,
    required this.doctorprice,
    required this.metodePembayaran,
    required this.userId,
    required this.token,
    required this.poliId,
  });

  @override
  _SuccessPageState createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage> {
  int _selectedIndex = 0;

Future<void> sendDataToApi() async {
  final String apiUrl = 'http://127.0.0.1:8000/pendaftaran/';
  final Map<String, dynamic> data = {
    'selectedCategory': widget.selectedCategory,
    'address': widget.address,
    'doctorId': widget.doctorId,
    'harga': widget.doctorprice + 50000,
    'metodePembayaran': widget.metodePembayaran,
    'userId': widget.userId,
    'poliId': widget.poliId,
    'keluhan': "Example keluhan",
    'nama_pasien': widget.name
  };

  try {
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}', // Menyertakan token bearer
      },
      body: jsonEncode(data),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      print('Data berhasil dikirim');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => AntrianSaya(
            userId: widget.userId,
            token: widget.token,
          ),
        ),
      );
    } else {
      print('Gagal mengirim data: ${response.body}');
      throw Exception('Failed to send data');
    }
  } catch (e) {
    print('Error: $e');
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Gagal mengirim data. Silakan coba lagi.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/sukses.png',
                height: 200,
              ),
              SizedBox(height: 20),
              Text(
                'Pembayaran Berhasil',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Data pembayaran sudah berhasil diproses',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Metode Pembayaran: ${widget.metodePembayaran}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: () async {
                  await sendDataToApi();
                },
                child: Text('Lihat Antrian'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
