// import 'package:flutter/material.dart';

// class PaymentScreen extends StatefulWidget {
//   final String selectedCategory;
//   final String name;
//   final String phoneNumber;
//   final String address;
//   final String doctorName;
//   final String schedule;

//   PaymentScreen({
//     required this.selectedCategory,
//     required this.name,
//     required this.phoneNumber,
//     required this.address,
//     required this.doctorName,
//     required this.schedule,
//   });

//   @override
//   State<PaymentScreen> createState() => _PaymentScreenState();
// }

// class _PaymentScreenState extends State<PaymentScreen> {
//   int _selectedIndex = 0;
//   bool isCallConnected = false;

//   @override
//   Widget build(BuildContext context) {
//     print("doctorName = ${widget.doctorName}");
//     return Scaffold(
//       extendBodyBehindAppBar: true,
//       appBar: AppBar(
//         centerTitle: true,
//         backgroundColor: Colors.transparent,
//         elevation: 0.0,
//         title: const Text(
//           "Pembayaran",
//           style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: SingleChildScrollView(
//         child: Container(
//           decoration: BoxDecoration(
//             image: DecorationImage(
//               image: const AssetImage('assets/background.png'),
//               fit: BoxFit.cover,
//               colorFilter: ColorFilter.mode(
//                 Colors.black.withOpacity(0.4),
//                 BlendMode.dstATop,
//               ),
//             ),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Padding(
//               padding: const EdgeInsets.only(top: 120.0),
//               child: Column(
//                 children: [
//                   Container(
//                     decoration: const BoxDecoration(
//                       borderRadius: BorderRadius.all(Radius.circular(15)),
//                       color: Color.fromRGBO(217, 217, 217, 1),
//                     ),
//                     child: Padding(
//                       padding: const EdgeInsets.all(12.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Center(
//                             child: Text(
//                               'Rumah Sakit Healthhease',
//                               style: TextStyle(
//                                   fontSize: 12, fontWeight: FontWeight.w600),
//                             ),
//                           ),
//                           const SizedBox(
//                             height: 22,
//                           ),
//                           Row(
//                             children: [
//                               const Text('Poli'),
//                               const SizedBox(
//                                 width: 12,
//                               ),
//                               Text(('${widget.doctorName}' == 'Dr. Wafiq M
