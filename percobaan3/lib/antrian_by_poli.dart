import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AntrianPage extends StatefulWidget {
  final int userId;
  final String token;
  final int poliId;
  final String poliName;

  AntrianPage({
    required this.userId,
    required this.token,
    required this.poliId,
    required this.poliName,
  });

  @override
  _AntrianPageState createState() => _AntrianPageState();
}

class _AntrianPageState extends State<AntrianPage> {
  late Future<List<QueueItemData>> futureQueueItems;

  @override
  void initState() {
    super.initState();
    futureQueueItems = fetchQueueItems();
  }

Future<List<QueueItemData>> fetchQueueItems() async {
  final response = await http.get(
    Uri.parse('http://127.0.0.1:8000/queue/${widget.poliId}'),
    headers: {
      'Authorization': 'Bearer ${widget.token}',
    },
  );

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<QueueItemData> queueItems = [];

    for (var item in data) {
      try {
        QueueItemData queueItem = QueueItemData.fromJson(item);
        if (queueItem.statusPembayaran == 'sudah_bayar') {
          queueItems.add(queueItem);
        }
      } catch (e) {
        // Jika ada error parsing data, bisa diabaikan atau di-handle sesuai kebutuhan
        print('Error parsing data: $e');
      }
    }
    return queueItems;
  } else {
    throw Exception('Failed to load queue items');
  }
}

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
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.black),
                    onPressed: () {
                      Navigator.pop(context); // Kembali ke halaman sebelumnya
                    },
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        'Antrian Poli ${widget.poliName}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Antrian Sekarang',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: FutureBuilder<List<QueueItemData>>(
                future: futureQueueItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No queue items found'));
                  } else {
                    List<QueueItemData> queueItems = snapshot.data!;
                    queueItems.sort((a, b) {
                      if (a.status == QueueStatus.processing) return -1;
                      if (b.status == QueueStatus.processing) return 1;
                      return a.queueNumber.compareTo(b.queueNumber);
                    });
                    QueueItemData topItem = queueItems.removeAt(0);

                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Container(
                            padding: EdgeInsets.all(16.0),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: const Color.fromRGBO(8, 82, 89, 1).withOpacity(0.8),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Text(
                                    topItem.queueNumber.toString(),
                                    style: TextStyle(
                                      fontSize: 48,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Center(
                                  child: Text(
                                    'Nama: ${topItem.patientName}',
                                    style: TextStyle(
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 16.0),
                        Text(
                          'Status Antrian',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Expanded(
                          child: ListView(
                            padding: EdgeInsets.symmetric(vertical: 20.0),
                            children: queueItems.map((item) {
                              return QueueItem(
                                status: item.status,
                                queueNumber: item.queueNumber,
                                patientName: item.patientName,
                                compact: true,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class QueueItemData {
  final QueueStatus status;
  final int queueNumber;
  final String patientName;
  final String statusPembayaran;

  QueueItemData({
    required this.status,
    required this.queueNumber,
    required this.patientName,
    required this.statusPembayaran,
  });

  factory QueueItemData.fromJson(Map<String, dynamic> json) {
    return QueueItemData(
      status: QueueStatusExtension.fromString(json['status_antrian']),
      queueNumber: json['no_antrian'],
      patientName: json['nama_pasien'],
      statusPembayaran: json['status_pembayaran'],
    );
  }
}

enum QueueStatus { missed, completed, pending, processing }

extension QueueStatusExtension on QueueStatus {
  static QueueStatus fromString(String status) {
    switch (status) {
      case 'missed':
        return QueueStatus.missed;
      case 'completed':
        return QueueStatus.completed;
      case 'pending':
        return QueueStatus.pending;
      case 'processing':
        return QueueStatus.processing;
      default:
        throw Exception('Invalid queue status');
    }
  }

  String toShortString() {
    return toString().split('.').last;
  }
}

class QueueItem extends StatelessWidget {
  final QueueStatus status;
  final int queueNumber;
  final String patientName;
  final bool compact;

  const QueueItem({
    Key? key,
    required this.status,
    required this.queueNumber,
    required this.patientName,
    this.compact = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Color statusColor = Colors.grey;
    String statusText;

    switch (status) {
      case QueueStatus.missed:
        statusColor = Colors.red;
        statusText = 'Terlewat';
        break;
      case QueueStatus.completed:
        statusColor = Colors.green;
        statusText = 'Selesai';
        break;
      case QueueStatus.pending:
        statusColor = Colors.orange;
        statusText = 'Menunggu';
        break;
      case QueueStatus.processing:
        statusColor = Colors.blue;
        statusText = 'Diproses';
        break;
    }

    Color backgroundColor = status == QueueStatus.processing ? Colors.green : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          height: compact ? 80 : 100,
          width: double.infinity,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: compact ? 80 : 100,
                width: compact ? 80 : 100,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                ),
                child: Center(
                  child: Text(
                    queueNumber.toString(),
                    style: TextStyle(
                      fontSize: compact ? 24 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: $statusText',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 16 : 18,
                        ),
                      ),
                      Text(
                        'Nama: $patientName',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: compact ? 16 : 18,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (status == QueueStatus.pending)
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Tambahkan logika untuk memproses antrian di sini
                    },
                    child: Text('Proses'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
