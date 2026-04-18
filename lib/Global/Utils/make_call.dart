import '../../index/index_main.dart';

class MakeCall {
  /// **📞 Make a Direct Call**
  static void makePhoneCall(String phoneNumber) async {
    String phone = convertToEnglishNumbers(phoneNumber);
    final Uri url = Uri.parse('tel:$phone');

    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      
    }
  }

  static String convertToEnglishNumbers(String input) {
    final arabicToEnglish = {
      '٠': '0',
      '١': '1',
      '٢': '2',
      '٣': '3',
      '٤': '4',
      '٥': '5',
      '٦': '6',
      '٧': '7',
      '٨': '8',
      '٩': '9',
    };

    return input.split('').map((char) => arabicToEnglish[char] ?? char).join();
  }
}
