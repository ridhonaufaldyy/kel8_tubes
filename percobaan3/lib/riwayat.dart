import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';

class CheckupHistoryPage extends StatefulWidget {
  final int userId;
  final String token;

  CheckupHistoryPage({
    required this.userId,
    required this.token,
  });

  @override
  _CheckupHistoryPageState createState() => _CheckupHistoryPageState();
}

class _CheckupHistoryPageState extends State<CheckupHistoryPage> {
  late Future<List<CheckupHistoryItem>> _checkupHistoryFuture;

  @override
  void initState() {
    super.initState();
    _checkupHistoryFuture = fetchCheckupHistory();
  }

  Future<List<CheckupHistoryItem>> fetchCheckupHistory() async {
    final response = await http.get(
      Uri.parse('http://127.0.0.1:8000/checkup-history/${widget.userId}'),
      headers: {'Authorization': 'Bearer ${widget.token}'},
    );

    if (response.statusCode == 200) {
      List<dynamic> jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => CheckupHistoryItem.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load checkup history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Checkup'),
      ),
      body: FutureBuilder<List<CheckupHistoryItem>>(
        future: _checkupHistoryFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<CheckupHistoryItem>? checkupHistory = snapshot.data;
            return ListView.builder(
              itemCount: checkupHistory!.length,
              itemBuilder: (context, index) {
                return CheckupItem(
                  checkupHistoryItem: checkupHistory[index],
                );
              },
            );
          }
        },
      ),
    );
  }
}

class CheckupItem extends StatelessWidget {
  final CheckupHistoryItem checkupHistoryItem;

  const CheckupItem({
    Key? key,
    required this.checkupHistoryItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM dd, yyyy').format(checkupHistoryItem.tanggalPendaftaran);
    return Card(
      elevation: 3,
      child: ListTile(
        title: Text('Tanggal: $formattedDate'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nama Pasien: ${checkupHistoryItem.namaPasien}'),
            Text('Dokter: ${checkupHistoryItem.fullname}'),
            Text('Spesialis: ${checkupHistoryItem.keterangan}'),
            Text('Poliklinik: ${checkupHistoryItem.namaPoliklinik}'),
          ],
        ),
      ),
    );
  }
}

class CheckupHistoryItem {
  final DateTime tanggalPendaftaran;
  final String namaPasien;
  final String fullname;
  final String keterangan;
  final String namaPoliklinik;

  CheckupHistoryItem({
    required this.tanggalPendaftaran,
    required this.namaPasien,
    required this.fullname,
    required this.keterangan,
    required this.namaPoliklinik,
  });

  factory CheckupHistoryItem.fromJson(Map<String, dynamic> json) {
    return CheckupHistoryItem(
      tanggalPendaftaran: DateTime.parse(json['tanggal_pendaftaran']),
      namaPasien: json['nama_pasien'],
      fullname: json['fullname'],
      keterangan: json['keterangan'],
      namaPoliklinik: json['nama_poliklinik'],
    );
  }
}
