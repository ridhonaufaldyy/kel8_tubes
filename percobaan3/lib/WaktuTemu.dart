import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class WaktuTemu extends StatefulWidget {
  final int userId;
  final String token;
  final int idDokter;

  WaktuTemu({
    required this.userId,
    required this.token,
    required this.idDokter,
  });

  @override
  _WaktuTemuState createState() => _WaktuTemuState();
}

class _WaktuTemuState extends State<WaktuTemu> {
  String _name = '';
  String _profession = '';
  String _imageUrl = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _fetchDokterById(widget.idDokter);
  }

  Future<void> _fetchDokterById(int id) async {
    try {
      final response = await http.get(
          Uri.parse('http://127.0.0.1:8000/api/dokters/${widget.idDokter}')); // Ganti URL dengan URL API yang sesuai
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _name = responseData['fullname'];
          _profession = responseData['keterangan'];
          _imageUrl = responseData['image_url'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

void _submitData() async {
  try {
    final response = await http.post(
      Uri.parse('http://127.0.0.1:8000/janji_temu/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer ${widget.token}', // Tambahkan token sebagai authorization header
      },
      body: jsonEncode({
        'id_user': widget.userId,
        'id_dokter': widget.idDokter,
        'waktu_pertemuan': _selectedDate.toIso8601String(), // Menggunakan format ISO 8601 untuk waktu pertemuan
      }),
    );
    if (response.statusCode == 200) {
      // Parse respons JSON
      final responseData = jsonDecode(response.body);
      final waktuPertemuan = DateTime.parse(responseData['waktu_pertemuan']);
      final idJanjiTemu = responseData['id'];

      // Menampilkan pesan konfirmasi
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Janji Temu Berhasil Dibuat'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('ID Janji Temu: $idJanjiTemu'),
              Text('Waktu Pertemuan: $waktuPertemuan'),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      print('Error: ${response.statusCode}');
    }
  } catch (error) {
    print('Error: $error');
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Jadwal Temu Dokter'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: MediaQuery.of(context).size.height * 0.4,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: NetworkImage(_imageUrl),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_name, style: TextStyle(fontSize: 25)),
                    SizedBox(height: 15),
                    Text(_profession, style: TextStyle(fontSize: 18)),
                    SizedBox(height: 20),
                    Text('Tanggal Temu: ${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: Text('Atur Tanggal Temu'),
                    ),
                    SizedBox(height: 20),
                    Text('Waktu Temu: ${_selectedTime.hour}:${_selectedTime.minute}'),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: Text('Atur Waktu Temu'),
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _submitData,
                        child: Text('Buat Janji Temu'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
