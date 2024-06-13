import 'package:flutter/material.dart';
import 'package:latihanflutter/screen/choseeScreen.dart';

class OrderScreen extends StatefulWidget {
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

  OrderScreen({
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
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: const Text(
          "Pemesanan",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Padding(
              padding: const EdgeInsets.only(top: 120.0),
              child: Column(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(15)),
                      color: Color.fromRGBO(217, 217, 217, 1),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              'Detail Pasien',
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600),
                            ),
                          ),
                          const SizedBox(
                            height: 22,
                          ),
                          Text('Kategori: ${widget.selectedCategory}'),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('Nama: ${widget.name}'),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('Nomor Telepon: ${widget.phoneNumber}'),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('Alamat: ${widget.address}'),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('Nama Dokter: ${widget.doctorName}'),
                          const SizedBox(
                            height: 12,
                          ),
                          Text('ID Dokter: ${widget.doctorId}'),
                          const SizedBox(
                            height: 12,
                          ),
                          const Center(
                            child: Text(
                              'Tagihan',
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(
                            height: 22,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Konsultasi dokter'),
                                  Text('Rp.${widget.doctorprice} '),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  const Text('Administrasi Rumah Sakit'),
                                  const Text('Rp.50000'),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 22,
                          ),
                          const Divider(
                            color: Colors.black,
                            height: 1,
                          ),
                          const SizedBox(
                            height: 22,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const Text('Total'),
                              Text('${widget.doctorprice + 50000}'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Color.fromRGBO(9, 82, 89, 1)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChooseScreen(
                            selectedCategory: widget.selectedCategory,
                            name: widget.name,
                            phoneNumber: widget.phoneNumber,
                            address: widget.address,
                            doctorName: widget.doctorName,
                            doctorId: widget.doctorId,
                            doctorprice: widget.doctorprice,
                            userId :widget.userId,
                            token :widget.token,
                            poliId :widget.poliId
                          ),
                        ),
                      );
                    },
                    child: const Text(
                      'Lanjutkan',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Container(
                    height: 350,
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
