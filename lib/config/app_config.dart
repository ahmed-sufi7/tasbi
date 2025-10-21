class AppConfig {
  // App Information
  static const String appName = 'Digital Tasbeeh';
  static const String appVersion = '1.0.0';
  
  // Database
  static const String databaseName = 'digital_tasbi.db';
  static const int databaseVersion = 1;
  
  // AdMob IDs (Replace with your actual AdMob IDs)
  static const String androidBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  static const String iosBannerAdUnitId = 'ca-app-pub-3940256099942544/2934735716'; // Test ID
  static const String androidInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712'; // Test ID
  static const String iosInterstitialAdUnitId = 'ca-app-pub-3940256099942544/4411468910'; // Test ID
  
  // In-App Purchase
  static const String removeAdsProductId = 'remove_ads_premium';
  
  // Notification Settings
  static const String notificationChannelId = 'digital_tasbi_notifications';
  static const String notificationChannelName = 'Digital Tasbeeh Reminders';
  static const String notificationChannelDescription = 'Reminders for durood and tasbi counting';
  
  // Default Durood/Tasbeeh Presets
  static const List<Map<String, dynamic>> defaultDuroods = [
    {
      'name': 'دورود إبراهيم',
      'arabic': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ إِنَّكَ حَمِيدٌ مَجِيدٌ',
      'transliteration': 'Allahumma salli ala Muhammadin wa ala ali Muhammadin kama sallayta ala Ibrahima wa ala ali Ibrahima innaka Hameedum Majeed',
      'translation': 'O Allah, send Your mercy upon Muhammad and upon the family of Muhammad as You sent Your mercy upon Ibrahim and upon the family of Ibrahim. Indeed, You are the Praiseworthy, the Glorious.',
      'target': 100,
      'isDefault': true,
    },
    {
      'name': 'سُبْحَانَ اللّهِ',
      'arabic': 'سُبْحَانَ اللّهِ',
      'transliteration': 'Subhan Allah',
      'translation': 'Glory be to Allah',
      'target': 33,
      'isDefault': true,
    },
    {
      'name': 'الْحَمْدُ لِلّهِ',
      'arabic': 'الْحَمْدُ لِلّهِ',
      'transliteration': 'Alhamdulillah',
      'translation': 'All praise is due to Allah',
      'target': 33,
      'isDefault': true,
    },
    {
      'name': 'اللّهُ أَكْبَرُ',
      'arabic': 'اللّهُ أَكْبَرُ',
      'transliteration': 'Allahu Akbar',
      'translation': 'Allah is the Greatest',
      'target': 33,
      'isDefault': true,
    },
    {
      'name': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'arabic': 'لَا إِلَٰهَ إِلَّا ٱللَّٰهُ',
      'transliteration': 'La ilaha illallah',
      'translation': 'There is no deity except Allah',
      'target': 100,
      'isDefault': true,
    },
  ];
  
  // Animation Durations
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);
  static const Duration mediumAnimationDuration = Duration(milliseconds: 300);
  static const Duration longAnimationDuration = Duration(milliseconds: 500);
  
  // Counter Settings
  static const int maxCounterValue = 999999;
  static const int defaultTarget = 100;
  
  // History Settings
  static const int historyItemsPerPage = 20;
  static const int maxHistoryDays = 365;
}
