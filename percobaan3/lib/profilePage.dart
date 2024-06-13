import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'MyBotNavBar.dart';
import 'home_page.dart';
import 'editProfile.dart';
import 'login_screen.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  final String token;

  ProfilePage({
    required this.userId,
    required this.token,
  });

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  int _selectedIndex = 3; // Indeks halaman profil
  String fullName = '';
  String nik = '';
  String telphone = '';
  String email = '';
  bool isLoading = true;

  void logout() 
  {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()), 
      (Route<dynamic> route) => false
    );
  }

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> fetchUserData() async {
    final url = Uri.parse('http://127.0.0.1:8000/get_users/${widget.userId}');
    print('Fetching data from $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body);
      setState(() {
        fullName = responseData['fullname'];
        nik = responseData['nik'];
        telphone = responseData['telphone'];
        email = responseData['email'];
        isLoading = false;
      });
      print('Full name: $fullName, NIK: $nik, Telphone: $telphone, Email: $email');
    } else {
      print('Failed to fetch user data: ${response.body}');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    CircleAvatar(
                      radius: 70,
                      backgroundImage: NetworkImage('https://via.placeholder.com/150'),
                    ),
                    SizedBox(height: 20),
                    Text(
                      fullName,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'NIK: $nik',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 10),
                    Divider(
                      thickness: 2,
                    ),
                    SizedBox(height: 10),
                    _buildProfileInfo('Telphone', telphone),
                    SizedBox(height: 10),
                    _buildProfileInfo('Email', email),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        print('menuju edit profile');
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => EditProfilePage(
                            userId: widget.userId,
                            token: widget.token, 
                          )),
                        );
                      },
                      child: Text('Ubah Profil'),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        print('Session berakhir');
                        logout();
                      },
                      child: Text('Keluar'),
                    ),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: MyBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
        userId: widget.userId,
        token: widget.token,
      ),
    );
  }

  Widget _buildProfileInfo(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          value,
          style: TextStyle(fontSize: 18),
        ),
      ],
    );
  }
}
