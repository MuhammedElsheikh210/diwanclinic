class Validators {
  // Email validation
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صحيح';
    }
    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
    }
    return null;
  }

  // Name validation
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال الاسم';
    }
    if (!RegExp(r"^[a-zA-Z\s\u0621-\u064A]+$").hasMatch(value)) {
      return 'يمكن أن يحتوي الاسم على أحرف ومسافات فقط';
    }
    if (value.length < 2) {
      return 'يجب أن يكون الاسم مكونًا من حرفين على الأقل';
    }
    return null;
  }

  // Number validation
  static String? validateNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'يجب أن يحتوي الإدخال على أرقام فقط';
    }
    if (value.length < 2) {
      return 'يجب أن يتكون الرقم من رقمين على الأقل';
    }
    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال العنوان';
    }
    if (!RegExp(r"^[a-zA-Z\s\u0621-\u064A]+$").hasMatch(value)) {
      return 'يمكن أن يحتوي العنوان على أحرف ومسافات فقط';
    }
    if (value.length < 2) {
      return 'يجب أن يكون العنوان مكونًا من حرفين على الأقل';
    }
    return null;
  }

  // Phone number validation
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهاتف';
    }
    if (!RegExp(r"^[0-9]{8,15}$").hasMatch(value)) {
      return 'يرجى إدخال رقم هاتف صالح';
    }
    return null;
  }

  // Confirm password validation
  static String? validateConfirmPassword(String? value, String? password) {
    if (value == null || value.isEmpty) {
      return 'يرجى تأكيد كلمة المرور';
    }
    if (value != password) {
      return 'كلمات المرور غير متطابقة';
    }
    return null;
  }

  // Identity number validation
  static String? validateIdentityNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال رقم الهوية';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'يجب أن يحتوي رقم الهوية على أرقام فقط';
    }
    if (value.length > 10) {
      return 'يجب ألا يزيد رقم الهوية عن 10 أرقام';
    }
    return null;
  }
}

class InputValidators {
  /// Validates if the input is not empty.
  static String? notEmpty(
    String? value, {
    String errorMessage = "هذا الحقل يجب ألا يكون فارغًا",
  }) {
    if (value == null || value.trim().isEmpty) {
      return errorMessage;
    }
    return null;
  }

  /// Validates if the input length is greater than the given length.
  static String? minLength(
    String? value,
    int minLength, {
    String errorMessage = "الإدخال قصير جدًا",
  }) {
    if (value != null && value.length < minLength) {
      return errorMessage;
    }
    return null;
  }

  /// Validates an email address.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'يرجى إدخال بريد إلكتروني صالح';
    }
    return null; // No errors, so return null
  }

  /// Validates a password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'يرجى إدخال كلمة المرور';
    }
    if (value.length < 6) {
      return 'يجب أن تكون كلمة المرور مكونة من 6 أحرف على الأقل';
    }
    return null;
  }

  /// Validates if the input is a number and does not exceed 100.
  static String? validateNumberAndMax(
    String? value, {
    int max = 100,
    String errorMessage = "القيمة يجب أن تكون رقماً وأقل من أو تساوي 100",
  }) {
    if (value == null || value.trim().isEmpty) {
      return "هذا الحقل يجب ألا يكون فارغًا";
    }
    final number = int.tryParse(value);
    if (number == null) {
      return "القيمة يجب أن تكون رقماً صحيحاً";
    }
    if (number > max) {
      return errorMessage;
    }
    return null;
  }

  /// Combines multiple validators.
  static String? Function(String?) combine(
    List<String? Function(String?)> validators,
  ) {
    return (String? value) {
      for (var validator in validators) {
        final result = validator(value);
        if (result != null) return result;
      }
      return null;
    };
  }
}

final notEmptyValidator = (String? value) => InputValidators.notEmpty(value);
