import 'dart:convert';
import 'package:http/http.dart' as http;

class DoctorService {
  static Future<List<String>> fetchDoctorNames() async {
    final response = await http.get(Uri.parse('URL_API_ANDA'));

    if (response.statusCode == 200) {
      // Jika permintaan berhasil, parse data JSON dan kembalikan daftar nama dokter
      List<dynamic> data = jsonDecode(response.body);
      List<String> doctorNames = data.map((e) => e['fullname'] as String).toList();
      return doctorNames;
    } else {
      // Jika permintaan gagal, lempar exception
      throw Exception('Failed to load doctor names');
    }
  }
}
