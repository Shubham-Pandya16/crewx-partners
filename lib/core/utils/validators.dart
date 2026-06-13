class Validators {
  static String? phone(String? v) {
    if (v == null || v.isEmpty) return 'Enter your mobile number';
    if (v.length != 10) return 'Enter a valid 10-digit number';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(v)) return 'Invalid Indian mobile number';
    return null;
  }

  static String? required(String? v) =>
      (v == null || v.trim().isEmpty) ? 'This field is required' : null;

  static String? email(String? v) {
    if (v == null || v.isEmpty) return 'Enter your email';
    if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
      return 'Enter a valid email';
    return null;
  }

  static String? gst(String? v) {
    if (v == null || v.isEmpty) return null; // optional
    if (v.length != 15) return 'GST number must be 15 characters';
    return null;
  }

  static String? pan(String? v) {
    if (v == null || v.isEmpty) return null; // optional
    if (v.length != 10) return 'PAN must be 10 characters';
    if (!RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$').hasMatch(v.toUpperCase()))
      return 'Enter a valid PAN';
    return null;
  }
}
