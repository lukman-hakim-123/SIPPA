class ValidationHelper {
  static String? validateNotEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Masukkan $fieldName';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Masukkan email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Masukkan email dengan benar';
    }
    return null;
  }

  static String? validateMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return 'Masukkan $fieldName';
    }
    if (value.length < minLength) {
      return '$fieldName harus minimal $minLength huruf';
    }
    return null;
  }

  // Fungsi untuk menggabungkan beberapa validator
  static String? validateMultiple(String? value, List<Function> validators) {
    for (var validator in validators) {
      final error = validator(value);
      if (error != null) {
        return error;
      }
    }
    return null;
  }

  static String? validateOptionalMinLength(
    String? value,
    int minLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }
    if (value.length < minLength) {
      return '$fieldName harus minimal $minLength huruf';
    }
    return null;
  }

  static String? validatePasswordOnEmailChange(
    String? value,
    String oldEmail,
    String newEmail,
  ) {
    if (oldEmail != newEmail && (value == null || value.isEmpty)) {
      return 'Password lama tidak boleh kosong';
    }
    return null;
  }

  static String? validateNumberOnly(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Masukkan $fieldName';
    }

    final regex = RegExp(r'^[0-9]+(\.[0-9]+)?$');
    if (!regex.hasMatch(value)) {
      return '$fieldName hanya boleh angka dan titik';
    }

    return null;
  }
}
