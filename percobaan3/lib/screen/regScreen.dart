import 'package:flutter/material.dart';
import 'orderScreen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegScreen extends StatefulWidget {
  final int userId;
  final String token;
  final int poliId;

  RegScreen({
    required this.userId,
    required this.token,
    required this.poliId,
  });

  @override
  _RegScreenState createState() => _RegScreenState();
}

class _RegScreenState extends State<RegScreen> {
  List<String> doctorNames = [];
  List<int> doctorIds = [];
  List<int> harga = [];
  String? _selectedCategory;
  String? _selectedDoctor;
  int? _selectedDoctorId;
  int? _selectedDoctorharga;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  // final TextEditingController _complaintController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchDoctors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    // _complaintController.dispose();
    super.dispose();
  }

  Future<void> fetchDoctors() async {
    try {
      final url = Uri.parse('http://127.0.0.1:8000/doctors_poliklinik/${widget.poliId}');
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          doctorNames = data.map<String>((doctor) => doctor['fullname'] as String).toList();
          doctorIds = data.map<int>((doctor) => doctor['id_dokter'] as int).toList();
          harga = data.map<int>((doctor) => doctor['harga'] as int).toList();
        });
      } else {
        throw Exception('Failed to load doctors');
      }
    } catch (error) {
      print('Error fetching doctors: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: const AssetImage('assets/background.png'),
            fit: BoxFit.cover,
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.4),
              BlendMode.dstATop,
            ),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Center(
                    child: Text(
                      'Pendaftaran',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Color.fromRGBO(217, 217, 217, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text(
                                  "Kategori Daftar",
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(9, 82, 89, 1),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    iconEnabledColor: Colors.white,
                                    value: _selectedCategory,
                                    decoration: const InputDecoration(
                                      labelText: 'Kategori Daftar',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      labelStyle: TextStyle(color: Colors.grey),
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    items: ['Umum', 'BPJS', 'Asuransi'].map((label) {
                                      return DropdownMenuItem(
                                        value: label,
                                        child: Text(
                                          label,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      setState(() {
                                        _selectedCategory = value;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text(
                                  "Nama",
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(9, 82, 89, 1),
                                  ),
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.grey),
                                    controller: _nameController,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text(
                                  "No. Telpon",
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(9, 82, 89, 1),
                                  ),
                                  child: TextFormField(
                                    keyboardType: TextInputType.phone,
                                    style: const TextStyle(color: Colors.grey),
                                    controller: _phoneController,
                                    decoration: const InputDecoration(
                                      hintStyle: TextStyle(color: Colors.white),
                                      labelText: '+628xxx',
                                      labelStyle: TextStyle(
                                        color: Colors.grey,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text(
                                  "Alamat",
                                ),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(9, 82, 89, 1),
                                  ),
                                  child: TextFormField(
                                    style: const TextStyle(color: Colors.grey),
                                    controller: _addressController,
                                    decoration: const InputDecoration(
                                      labelText: 'Alamat',
                                      labelStyle: TextStyle(color: Colors.grey),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                          Radius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Expanded(
                                flex: 1,
                                child: Text("Nama Dokter"),
                              ),
                              const SizedBox(
                                width: 12,
                              ),
                              Expanded(
                                flex: 2,
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: const Color.fromRGBO(9, 82, 89, 1),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    iconEnabledColor: Colors.white,
                                    decoration: const InputDecoration(
                                      labelText: 'Nama Dokter',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.all(Radius.circular(12)),
                                      ),
                                      labelStyle: TextStyle(color: Colors.grey),
                                      hintStyle: TextStyle(color: Colors.grey),
                                    ),
                                    value: _selectedDoctor,
                                    items: doctorNames.map((name) {
                                      return DropdownMenuItem(
                                        value: name,
                                        child: Text(
                                          name,
                                          style: const TextStyle(color: Colors.grey),
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      final index = doctorNames.indexOf(value!);
                                      final selectedDoctorId = doctorIds[index];
                                      final selectedDoctorharga = harga[index];
                                      print('Selected Doctor: $value, ID: $selectedDoctorId, Harga: $selectedDoctorharga');
                                      setState(() {
                                        _selectedDoctor = value;
                                        _selectedDoctorId = selectedDoctorId;
                                        _selectedDoctorharga = selectedDoctorharga;
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          const Center(
                            child: Text(
                              'Pilih Jadwal',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  RegistrationNext(
                    selectedCategory: _selectedCategory ?? "",
                    name: _nameController.text,
                    phoneNumber: _phoneController.text,
                    address: _addressController.text,
                    doctorName: _selectedDoctor ?? "",
                    doctorprice: _selectedDoctorharga ?? 0,
                    doctorId: _selectedDoctorId ?? -1,
                    userId: widget.userId, // Pass the user ID
                    token: widget.token, // Pass the token
                    poliId: widget.poliId, // Pass the token
                    // complaint: _complaintController.text, // Pass the complaint text
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RegistrationNext extends StatelessWidget {
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

  const RegistrationNext({
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
    required this.poliId
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderScreen(
              selectedCategory: selectedCategory,
              name: name,
              phoneNumber: phoneNumber,
              address: address,
              doctorName: doctorName,
              doctorId: doctorId,
              doctorprice: doctorprice,
              userId :userId,
              token :token,
              poliId :poliId
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: Center(
          child: Card(
            child: Container(
              width: 111,
              height: 30,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4)),
                color: Color.fromRGBO(9, 82, 89, 1),
              ),
              child: const Center(
                child: Text(
                  "Daftar",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color.fromRGBO(255, 255, 255, 1),
                    fontFamily: 'Kadwa',
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
