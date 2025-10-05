extension StringExtension on String {
  String get generateTitle {
    return substring(0, 8);
  }

  //capitalize first letter
  String get capitalizeFirstLetter {
    return this[0].toUpperCase() + substring(1);
  }
}
