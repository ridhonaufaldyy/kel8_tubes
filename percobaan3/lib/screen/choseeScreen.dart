import 'package:flutter/material.dart';

import '../MyBotNavBar.dart';
import '../home_page.dart';
import 'succesScreen.dart';
import 'cod_page.dart'; // Import halaman Cash On Delivery

class ChooseScreen extends StatefulWidget {
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

  const ChooseScreen({
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
  });

  @override
  State<ChooseScreen> createState() => _ChooseScreenState();
}

class _ChooseScreenState extends State<ChooseScreen> {
  int _selectedRadio = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          "Metode Pembayaran",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/background.png'),
              fit: BoxFit.cover,
              colorFilter: ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.dstATop,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 52.0),
              child: Column(
                children: [
                  Container(
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildRadioButtons(),
                          SizedBox(height: 22),
                          Divider(color: Colors.black, height: 1),
                          SizedBox(height: 22),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text("Silakan lakukan pembayaran"),
                              SizedBox(height: 12),
                              Text("Total"),
                              SizedBox(height: 12),
                              Center(
                                child: Container(
                                  width: MediaQuery.of(context).size.width * 0.5,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: Colors.greenAccent,
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Center(
                                      child: Text(
                                        "Rp.${50000 + widget.doctorprice}", // Menampilkan total harga
                                        style: TextStyle(
                                          fontSize: 22,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color.fromRGBO(9, 82, 89, 1)),
                    ),
                    onPressed: () {
                      if (_selectedRadio == 4) { // Jika memilih "Bayar di Tempat"
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CashOnDeliveryPage(
                              selectedCategory: widget.selectedCategory,
                              name: widget.name,
                              phoneNumber: widget.phoneNumber,
                              address: widget.address,
                              doctorName: widget.doctorName,
                              doctorId: widget.doctorId,
                              doctorprice: widget.doctorprice,
                              metodePembayaran: _getSelectedMethod(),
                              userId :widget.userId,
                              token :widget.token,
                              poliId :widget.poliId
                            ),
                          ),
                        );
                      } else { // Jika memilih opsi pembayaran lainnya
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SuccessPage(
                              selectedCategory: widget.selectedCategory,
                              name: widget.name,
                              phoneNumber: widget.phoneNumber,
                              address: widget.address,
                              doctorName: widget.doctorName,
                              doctorId: widget.doctorId,
                              doctorprice: widget.doctorprice,
                              userId :widget.userId,
                              token :widget.token,
                              poliId :widget.poliId,
                              metodePembayaran: _getSelectedMethod(),


                              // paymentMethod: _getSelectedMethod(), // Mengirim metode pembayaran yang dipilih
                            ),
                          ),
                        );
                      }
                    },
                    child: Text(
                      'Bayar',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    height: 300,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRadioButtons() {
    return Column(
      children: [
        _buildRadioButton(0, 'DANA', 'assets/dana.png'),
        _buildRadioButton(1, 'OVO', 'assets/ovo.png'),
        _buildRadioButton(2, 'Gopay', 'assets/gopay.png'),
        _buildRadioButton(3, 'ShopeePay', 'assets/shopeepay.png'),
        _buildRadioButton(4, 'Bayar di Tempat', 'assets/cod.png'), // Menambahkan opsi "Bayar di Tempat"
      ],
    );
  }

  Widget _buildRadioButton(int value, String text, String imagePath) {
    return ListTile(
      leading: Container(
        width: 50,
        height: 50,
        child: Image.asset(
          imagePath,
        ),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Radio<int>(
        value: value,
        groupValue: _selectedRadio,
        onChanged: (int? newValue) {
          setState(() {
            _selectedRadio = newValue!;
          });
        },
      ),
    );
  }

  // Mendapatkan metode pembayaran yang dipilih berdasarkan nilai radio button
  String _getSelectedMethod() {
    switch (_selectedRadio) {
      case 0:
        return 'DANA';
      case 1:
        return 'OVO';
      case 2:
        return 'Gopay';
      case 3:
        return 'ShopeePay';
      case 4:
        return 'Bayar di Tempat';
      default:
        return ''; // Jika tidak ada yang dipilih
    }
  }
}
