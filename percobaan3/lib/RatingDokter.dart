import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'WaktuTemu.dart';

class RatingDokter extends StatefulWidget {
  final int userId;
  final String token;
  final int idDokter;

  RatingDokter({
    required this.userId,
    required this.token,
    required this.idDokter,
  });

  @override
  _RatingDokterState createState() => _RatingDokterState();
}

class Review {
  final String name;
  final String image;
  final double rating;
  final String date;
  final String review;

  Review({
    required this.name,
    required this.image,
    required this.rating,
    required this.date,
    required this.review,
  });
}

class _RatingDokterState extends State<RatingDokter> {
  String _name = '';
  String _profession = '';
  double _rating = 0.0;
  String _imageUrl = '';
  String _description = '';
  List<Review> _reviews = [];

  @override
  void initState() {
    super.initState();
    _fetchDokterById(widget.idDokter);
    _fetchReviews();
  }

  Future<void> _fetchDokterById(int id) async {
    try {
      final response = await http.get(
        Uri.parse('http://127.0.0.1:8000/api/dokters/${widget.idDokter}'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          _name = responseData['fullname'];
          _profession = responseData['keterangan'];
          _rating = responseData['rating'].toDouble();
          _imageUrl = responseData['image_url'];
          _description = responseData['deskripsi'];
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _fetchReviews() async {
    // Hardcoded reviews
    List<Review> reviews = [
      Review(
        name: 'Ahmad',
        image: 'assets/ahmad.png',
        rating: 4.5,
        date: 'Juni 10, 2024',
        review: 'Dokternya ramah sekali dan saya langsung sehat.',
      ),
      Review(
        name: 'Anita',
        image: 'assets/anita.png',
        rating: 5.0,
        date: 'June 8, 2024',
        review: 'Pelayanan nya bagus sekali saya suka saya suka!',
      ),
    ];

    setState(() {
      _reviews = reviews;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Rating Dokter'),
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
          child: Stack(
            children: [
              Container(
                color: Color.fromARGB(255, 157, 186, 199).withOpacity(0.5),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: MediaQuery.of(context).size.height * 0.4),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(_name, style: TextStyle(fontSize: 25)),
                          SizedBox(height: 15),
                          Text(_profession, style: TextStyle(fontSize: 18)),
                          SizedBox(height: 20),
                          // Menampilkan bintang rating
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.yellow),
                              SizedBox(width: 5),
                              Text(
                                '$_rating',
                                style: TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Deskripsi',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            _description,
                            style: TextStyle(fontSize: 14),
                          ),
                          SizedBox(height: 20),
                          Divider(height: 1, color: Colors.black),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Ulasan',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  // Tambahkan navigasi ke halaman 'see all' di sini
                                },
                                child: Text(
                                  "See All",
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color: Colors.blue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          // Daftar ulasan
                          Column(
                            children: _reviews.map((review) {
                              return buildReview(
                                context,
                                review.name,
                                review.image,
                                review.rating,
                                review.date,
                                review.review,
                              );
                            }).toList(),
                          ),
                          SizedBox(height: 20),
                          // Tombol buat janji temu
                          GestureDetector(
                            onTap: () {
                              // Navigasi ke halaman janji temu
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => WaktuTemu(
                                          userId: widget.userId,
                                          token: widget.token,
                                          idDokter: widget.idDokter,
                                        )),
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.only(
                                top: 16.0,
                                left: 16.0,
                                right: 16.0,
                                bottom:
                                    MediaQuery.of(context).viewInsets.bottom +
                                        16.0,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Center(
                                    child: Container(
                                      width: 200,
                                      padding:
                                          EdgeInsets.symmetric(vertical: 10.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          // Navigasi ke halaman janji temu
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => WaktuTemu(
                                                      userId: widget.userId,
                                                      token: widget.token,
                                                      idDokter: widget.idDokter,
                                                    )),
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF0A535A),
                                          foregroundColor: Colors.white,
                                        ),
                                        child: Text('Buat Janji temu'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  child: Image.network(
                    _imageUrl, // Gunakan _imageUrl langsung tanpa widget
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildReview(BuildContext context, String name, String image,
      double rating, String date, String review) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8.0),
      ),
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage: AssetImage(image),
              ),
              SizedBox(width: 8.0),
              Expanded(
                child: Text(
                  name,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Row(
            children: [
              Icon(Icons.star, color: Colors.yellow),
              SizedBox(width: 5),
              Text(
                '$rating',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(width: 8.0),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.0),
          Text(
            review,
            style: TextStyle(
              fontSize: 14.0,
            ),
          ),
        ],
      ),
    );
  }
}
