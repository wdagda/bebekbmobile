import 'dart:convert';
import 'package:crypto/crypto.dart';

class HashUtil {
  static String hashPassword(String password) {
    // Salt untuk keamanan extra
    const salt = 'duck_farm_salt_2024';
    final salted = '$salt$password';
    final bytes = utf8.encode(salted);
    return sha256.convert(bytes).toString();
  }

  static bool verifyPassword(String plainPassword, String storedHash) {
    return hashPassword(plainPassword) == storedHash;
  }
}
