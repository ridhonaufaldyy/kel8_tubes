import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'ProfilePage.dart';

class EditProfilePage extends StatefulWidget {

  final int userId;
  final String token;

  EditProfilePage({
    required this.userId,
    required this.token,
  });

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>(); // Digunakan untuk mengelola form
  TextEditingController _nameController = TextEditingController();
  TextEditingController _nikController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _phoneNumberController = TextEditingController();
  TextEditingController _usernameController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUserData();
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
      _nameController.text = responseData['fullname'];
      _nikController.text = responseData['nik'];
      _emailController.text = responseData['email'];
      _phoneNumberController.text = responseData['telphone'];
      _usernameController.text = responseData['username'];
    } else {
      print('Failed to fetch user data: ${response.body}');
    }
  }

    Future<void> updateUser() async {
    final url = Uri.parse('http://127.0.0.1:8000/edit_users/${widget.userId}'); // Ganti dengan URL API Anda

    final response = await http.put(
      url,
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'username': _usernameController.text,
        'password': _passwordController.text,
        'fullname': _nameController.text,
        'nik': _nikController.text,
        'email': _emailController.text,
        'telphone': _phoneNumberController.text,
      }),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      // Berhasil
      print('User updated successfully');
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Sukses"),
            content: Text("Profil Anda telah berhasil diperbarui"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage(userId: widget.userId, token: widget.token)),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      // Gagal
      print('Failed to update user: ${response.body}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi Username';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi Email';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: 'Fullname',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi Fullname';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _nikController,
                  decoration: InputDecoration(
                    labelText: 'NIK',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'isi NIK';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _phoneNumberController,
                  decoration: InputDecoration(
                    labelText: 'Nomor telepon',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Isi nomor telepon';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),
              Container(
                decoration: BoxDecoration(
                  color: Colors.greenAccent,
                  borderRadius: BorderRadius.circular(5.0),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x3F000000),
                      blurRadius: 4,
                      offset: Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(10),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'isi Password';
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(height: 20,),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    updateUser();
                  }
                },
                child: Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
