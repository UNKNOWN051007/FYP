import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = [
    _AppLocalizationsDelegate(),
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ms'),
    Locale('zh'),
    Locale('ta'),
  ];

  static const Map<String, Map<String, String>> _t = {
    'en': {
      'appName': 'WageWise',
      'tagline': 'Fair Wage Navigator',
      'loading': 'Loading...',
      'error': 'Something went wrong',
      'retry': 'Retry',
      'save': 'Save',
      'cancel': 'Cancel',
      'next': 'Next',
      'skip': 'Skip',
      'getStarted': 'Get Started',
      'login': 'Login',
      'register': 'Register',
      'email': 'Email',
      'password': 'Password',
      'confirmPassword': 'Confirm Password',
      'fullName': 'Full Name',
      'signIn': 'Sign In',
      'signOut': 'Sign Out',
      'createAccount': 'Create Account',
      'noAccount': "Don't have an account? Register",
      'haveAccount': 'Already have an account? Login',
      'onboarding1Title': 'Know Your Worth',
      'onboarding1Desc':
          'Get AI-powered salary predictions based on your profile and the Malaysian job market.',
      'onboarding2Title': 'Negotiate with Confidence',
      'onboarding2Desc':
          'Practice salary negotiations with our AI coach and walk into interviews prepared.',
      'onboarding3Title': 'Know Your Rights',
      'onboarding3Desc':
          'Understand your labour rights under Malaysian law before signing any contract.',
      'greeting': 'Hello',
      'marketInsight': 'Market Insight',
      'avgFreshGrad': 'Avg Fresh Grad Salary',
      'quickActions': 'Quick Actions',
      'salaryCheck': 'Salary Check',
      'negotiate': 'Negotiate',
      'myRights': 'My Rights',
      'livingCost': 'Living Cost',
      'recentPredictions': 'Recent Predictions',
      'tipOfDay': 'Tip of the Day',
      'salaryHeading': 'Salary Intelligence',
      'jobTitle': 'Job Title',
      'industry': 'Industry',
      'educationLevel': 'Education Level',
      'yearsExperience': 'Years of Experience',
      'location': 'Location',
      'predictButton': 'Predict My Salary',
      'salaryRange': 'Salary Range',
      'entryLevel': 'Entry',
      'marketRate': 'Market',
      'seniorLevel': 'Senior',
      'offerEvaluation': 'Evaluate Your Offer',
      'enterOffer': 'Enter offer amount (RM)',
      'evaluate': 'Evaluate',
      'belowMarket': 'Below Market',
      'atMarket': 'At Market',
      'aboveMarket': 'Above Market',
      'newPrediction': 'New Prediction',
      'chatbotHeading': 'AI Assistant',
      'labourRights': 'Labour Rights',
      'negotiation': 'Negotiation',
      'contractReview': 'Contract',
      'typeMessage': 'Type a message...',
      'sources': 'Sources',
      'colHeading': 'Cost of Living',
      'grossSalary': 'Gross Monthly Salary (RM)',
      'selectCities': 'Select Cities',
      'evaluateButton': 'Evaluate',
      'deductions': 'Deductions',
      'netSalary': 'Net Take-Home',
      'expenses': 'Monthly Expenses',
      'disposableIncome': 'Disposable Income',
      'meetsLivingWage': 'Meets Living Wage',
      'belowLivingWage': 'Below Living Wage',
      'profileHeading': 'Profile',
      'language': 'Language',
      'settings': 'Settings',
      'english': 'English',
      'bahasa': 'Bahasa',
      'chinese': '中文',
      'tamil': 'தமிழ்',
      'signOutConfirm': 'Are you sure you want to sign out?',
      'version': 'v1.0 · TAR UMT FYP 2026',
      'comfortable': 'Comfortable',
      'tight': 'Tight',
      'deficit': 'Deficit',
    },
    'ms': {
      'appName': 'WageWise',
      'tagline': 'Panduan Gaji Adil',
      'loading': 'Memuatkan...',
      'error': 'Sesuatu telah berlaku',
      'retry': 'Cuba semula',
      'save': 'Simpan',
      'cancel': 'Batal',
      'next': 'Seterusnya',
      'skip': 'Langkau',
      'getStarted': 'Mulakan',
      'login': 'Log masuk',
      'register': 'Daftar',
      'email': 'E-mel',
      'password': 'Kata laluan',
      'confirmPassword': 'Sahkan Kata Laluan',
      'fullName': 'Nama Penuh',
      'signIn': 'Log Masuk',
      'signOut': 'Log Keluar',
      'createAccount': 'Buat Akaun',
      'noAccount': 'Tiada akaun? Daftar',
      'haveAccount': 'Sudah ada akaun? Log masuk',
      'onboarding1Title': 'Tahu Nilai Anda',
      'onboarding1Desc':
          'Dapatkan ramalan gaji berasaskan AI berdasarkan profil anda dan pasaran kerja Malaysia.',
      'onboarding2Title': 'Berunding dengan Yakin',
      'onboarding2Desc':
          'Berlatih rundingan gaji dengan jurulatih AI kami dan bersedia untuk temuduga.',
      'onboarding3Title': 'Tahu Hak Anda',
      'onboarding3Desc':
          'Fahami hak buruh anda di bawah undang-undang Malaysia sebelum menandatangani kontrak.',
      'greeting': 'Hai',
      'marketInsight': 'Pandangan Pasaran',
      'avgFreshGrad': 'Gaji Purata Graduan Baru',
      'quickActions': 'Tindakan Pantas',
      'salaryCheck': 'Semak Gaji',
      'negotiate': 'Runding',
      'myRights': 'Hak Saya',
      'livingCost': 'Kos Sara Hidup',
      'recentPredictions': 'Ramalan Terkini',
      'tipOfDay': 'Petua Hari Ini',
      'salaryHeading': 'Ramalan Gaji',
      'jobTitle': 'Jawatan',
      'industry': 'Industri',
      'educationLevel': 'Tahap Pendidikan',
      'yearsExperience': 'Tahun Pengalaman',
      'location': 'Lokasi',
      'predictButton': 'Ramal Gaji Saya',
      'salaryRange': 'Julat Gaji',
      'entryLevel': 'Permulaan',
      'marketRate': 'Pasaran',
      'seniorLevel': 'Senior',
      'offerEvaluation': 'Nilai Tawaran Anda',
      'enterOffer': 'Masukkan jumlah tawaran (RM)',
      'evaluate': 'Nilai',
      'belowMarket': 'Di bawah pasaran',
      'atMarket': 'Setara pasaran',
      'aboveMarket': 'Melebihi pasaran',
      'newPrediction': 'Ramalan Baru',
      'chatbotHeading': 'Pembantu AI',
      'labourRights': 'Hak Buruh',
      'negotiation': 'Rundingan',
      'contractReview': 'Kontrak',
      'typeMessage': 'Taip mesej...',
      'sources': 'Sumber',
      'colHeading': 'Kos Sara Hidup',
      'grossSalary': 'Gaji Kasar Bulanan (RM)',
      'selectCities': 'Pilih Bandar',
      'evaluateButton': 'Nilai',
      'deductions': 'Potongan',
      'netSalary': 'Gaji Bersih',
      'expenses': 'Perbelanjaan Bulanan',
      'disposableIncome': 'Pendapatan Budi Bicara',
      'meetsLivingWage': 'Memenuhi Gaji Sara Hidup',
      'belowLivingWage': 'Di bawah Gaji Sara Hidup',
      'profileHeading': 'Profil',
      'language': 'Bahasa',
      'settings': 'Tetapan',
      'english': 'English',
      'bahasa': 'Bahasa',
      'chinese': '中文',
      'tamil': 'தமிழ்',
      'signOutConfirm': 'Adakah anda pasti mahu log keluar?',
      'version': 'v1.0 · TAR UMT FYP 2026',
      'comfortable': 'Selesa',
      'tight': 'Ketat',
      'deficit': 'Defisit',
    },
    'zh': {
      'appName': 'WageWise',
      'tagline': '公平薪资导航',
      'loading': '加载中...',
      'error': '出现错误',
      'retry': '重试',
      'save': '保存',
      'cancel': '取消',
      'next': '下一步',
      'skip': '跳过',
      'getStarted': '开始使用',
      'login': '登录',
      'register': '注册',
      'email': '电子邮件',
      'password': '密码',
      'confirmPassword': '确认密码',
      'fullName': '全名',
      'signIn': '登录',
      'signOut': '退出登录',
      'createAccount': '创建账户',
      'noAccount': '没有账户？注册',
      'haveAccount': '已有账户？登录',
      'onboarding1Title': '了解您的价值',
      'onboarding1Desc': '根据您的个人资料和马来西亚就业市场获取AI驱动的薪资预测。',
      'onboarding2Title': '自信地谈判',
      'onboarding2Desc': '与我们的AI教练练习薪资谈判，为面试做好准备。',
      'onboarding3Title': '了解您的权利',
      'onboarding3Desc': '在签署任何合同之前，了解马来西亚法律下的劳工权利。',
      'greeting': '你好',
      'marketInsight': '市场洞察',
      'avgFreshGrad': '应届毕业生平均薪资',
      'quickActions': '快速操作',
      'salaryCheck': '薪资查询',
      'negotiate': '谈判',
      'myRights': '我的权利',
      'livingCost': '生活成本',
      'recentPredictions': '最近预测',
      'tipOfDay': '每日小贴士',
      'salaryHeading': '薪资智能',
      'jobTitle': '职位',
      'industry': '行业',
      'educationLevel': '教育程度',
      'yearsExperience': '工作年限',
      'location': '地点',
      'predictButton': '预测我的薪资',
      'salaryRange': '薪资范围',
      'entryLevel': '入门',
      'marketRate': '市场',
      'seniorLevel': '高级',
      'offerEvaluation': '评估您的薪资',
      'enterOffer': '输入薪资金额 (RM)',
      'evaluate': '评估',
      'belowMarket': '低于市场',
      'atMarket': '符合市场',
      'aboveMarket': '高于市场',
      'newPrediction': '新预测',
      'chatbotHeading': 'AI助手',
      'labourRights': '劳工权利',
      'negotiation': '谈判',
      'contractReview': '合同',
      'typeMessage': '输入消息...',
      'sources': '来源',
      'colHeading': '生活成本',
      'grossSalary': '月薪总额 (RM)',
      'selectCities': '选择城市',
      'evaluateButton': '评估',
      'deductions': '扣除项',
      'netSalary': '实际收入',
      'expenses': '月度开支',
      'disposableIncome': '可支配收入',
      'meetsLivingWage': '达到生活工资',
      'belowLivingWage': '低于生活工资',
      'profileHeading': '个人资料',
      'language': '语言',
      'settings': '设置',
      'english': 'English',
      'bahasa': 'Bahasa',
      'chinese': '中文',
      'tamil': 'தமிழ்',
      'signOutConfirm': '确定要退出登录吗？',
      'version': 'v1.0 · TAR UMT FYP 2026',
      'comfortable': '舒适',
      'tight': '紧张',
      'deficit': '赤字',
    },
    'ta': {
      'appName': 'WageWise',
      'tagline': 'நியாயமான ஊதிய வழிகாட்டி',
      'loading': 'ஏற்றுகிறது...',
      'error': 'பிழை ஏற்பட்டது',
      'retry': 'மீண்டும் முயற்சி',
      'save': 'சேமி',
      'cancel': 'ரத்து செய்',
      'next': 'அடுத்து',
      'skip': 'தவிர்',
      'getStarted': 'தொடங்குங்கள்',
      'login': 'உள்நுழைய',
      'register': 'பதிவு செய்',
      'email': 'மின்னஞ்சல்',
      'password': 'கடவுச்சொல்',
      'confirmPassword': 'கடவுச்சொல்லை உறுதிப்படுத்துங்கள்',
      'fullName': 'முழு பெயர்',
      'signIn': 'உள்நுழைய',
      'signOut': 'வெளியேறு',
      'createAccount': 'கணக்கு உருவாக்கு',
      'noAccount': 'கணக்கு இல்லையா? பதிவு செய்யுங்கள்',
      'haveAccount': 'ஏற்கனவே கணக்கு உள்ளதா? உள்நுழைய',
      'onboarding1Title': 'உங்கள் மதிப்பை அறியுங்கள்',
      'onboarding1Desc':
          'மலேசிய வேலை சந்தையின் அடிப்படையில் AI வழிகாட்டும் சம்பள கணிப்புகளைப் பெறுங்கள்.',
      'onboarding2Title': 'நம்பிக்கையுடன் பேரம் பேசுங்கள்',
      'onboarding2Desc':
          'எங்கள் AI பயிற்சியாளருடன் சம்பள பேச்சுவார்த்தை பயிற்சி செய்யுங்கள்.',
      'onboarding3Title': 'உங்கள் உரிமைகளை அறியுங்கள்',
      'onboarding3Desc':
          'எந்த ஒப்பந்தத்திலும் கையெழுத்திடுவதற்கு முன் மலேசிய தொழிலாளர் உரிமைகளை புரிந்துகொள்ளுங்கள்.',
      'greeting': 'வணக்கம்',
      'marketInsight': 'சந்தை நுண்ணறிவு',
      'avgFreshGrad': 'புதிய பட்டதாரி சராசரி சம்பளம்',
      'quickActions': 'விரைவு செயல்கள்',
      'salaryCheck': 'சம்பள சரிபார்ப்பு',
      'negotiate': 'பேரம் பேசு',
      'myRights': 'என் உரிமைகள்',
      'livingCost': 'வாழ்க்கை செலவு',
      'recentPredictions': 'சமீபத்திய கணிப்புகள்',
      'tipOfDay': 'இன்றைய குறிப்பு',
      'salaryHeading': 'சம்பள நுண்ணறிவு',
      'jobTitle': 'பணி தலைப்பு',
      'industry': 'தொழில்துறை',
      'educationLevel': 'கல்வி நிலை',
      'yearsExperience': 'அனுபவ ஆண்டுகள்',
      'location': 'இடம்',
      'predictButton': 'என் சம்பளத்தை கணிக்கவும்',
      'salaryRange': 'சம்பள வரம்பு',
      'entryLevel': 'தொடக்க',
      'marketRate': 'சந்தை',
      'seniorLevel': 'மூத்த',
      'offerEvaluation': 'உங்கள் சலுகையை மதிப்பிடுங்கள்',
      'enterOffer': 'சலுகை தொகையை உள்ளிடுங்கள் (RM)',
      'evaluate': 'மதிப்பிடு',
      'belowMarket': 'சந்தைக்கு கீழே',
      'atMarket': 'சந்தை விலையில்',
      'aboveMarket': 'சந்தைக்கு மேலே',
      'newPrediction': 'புதிய கணிப்பு',
      'chatbotHeading': 'AI உதவியாளர்',
      'labourRights': 'தொழிலாளர் உரிமைகள்',
      'negotiation': 'பேச்சுவார்த்தை',
      'contractReview': 'ஒப்பந்தம்',
      'typeMessage': 'செய்தி தட்டச்சு செய்யுங்கள்...',
      'sources': 'ஆதாரங்கள்',
      'colHeading': 'வாழ்க்கை செலவு',
      'grossSalary': 'மொத்த மாத சம்பளம் (RM)',
      'selectCities': 'நகரங்களை தேர்ந்தெடுங்கள்',
      'evaluateButton': 'மதிப்பிடு',
      'deductions': 'கழிவுகள்',
      'netSalary': 'நிகர சம்பளம்',
      'expenses': 'மாத செலவுகள்',
      'disposableIncome': 'செலவிடக்கூடிய வருமானம்',
      'meetsLivingWage': 'வாழ்க்கை ஊதியத்தை பூர்த்தி செய்கிறது',
      'belowLivingWage': 'வாழ்க்கை ஊதியத்திற்கு கீழே',
      'profileHeading': 'சுயவிவரம்',
      'language': 'மொழி',
      'settings': 'அமைப்புகள்',
      'english': 'English',
      'bahasa': 'Bahasa',
      'chinese': '中文',
      'tamil': 'தமிழ்',
      'signOutConfirm': 'வெளியேற விரும்புகிறீர்களா?',
      'version': 'v1.0 · TAR UMT FYP 2026',
      'comfortable': 'வசதியான',
      'tight': 'இறுக்கமான',
      'deficit': 'பற்றாக்குறை',
    },
  };

  String _s(String key) {
    final lang = locale.languageCode;
    return _t[lang]?[key] ?? _t['en']![key] ?? key;
  }

  String get appName => _s('appName');
  String get tagline => _s('tagline');
  String get loading => _s('loading');
  String get error => _s('error');
  String get retry => _s('retry');
  String get save => _s('save');
  String get cancel => _s('cancel');
  String get next => _s('next');
  String get skip => _s('skip');
  String get getStarted => _s('getStarted');
  String get login => _s('login');
  String get register => _s('register');
  String get email => _s('email');
  String get password => _s('password');
  String get confirmPassword => _s('confirmPassword');
  String get fullName => _s('fullName');
  String get signIn => _s('signIn');
  String get signOut => _s('signOut');
  String get createAccount => _s('createAccount');
  String get noAccount => _s('noAccount');
  String get haveAccount => _s('haveAccount');
  String get onboarding1Title => _s('onboarding1Title');
  String get onboarding1Desc => _s('onboarding1Desc');
  String get onboarding2Title => _s('onboarding2Title');
  String get onboarding2Desc => _s('onboarding2Desc');
  String get onboarding3Title => _s('onboarding3Title');
  String get onboarding3Desc => _s('onboarding3Desc');
  String get greeting => _s('greeting');
  String get marketInsight => _s('marketInsight');
  String get avgFreshGrad => _s('avgFreshGrad');
  String get quickActions => _s('quickActions');
  String get salaryCheck => _s('salaryCheck');
  String get negotiate => _s('negotiate');
  String get myRights => _s('myRights');
  String get livingCost => _s('livingCost');
  String get recentPredictions => _s('recentPredictions');
  String get tipOfDay => _s('tipOfDay');
  String get salaryHeading => _s('salaryHeading');
  String get jobTitle => _s('jobTitle');
  String get industry => _s('industry');
  String get educationLevel => _s('educationLevel');
  String get yearsExperience => _s('yearsExperience');
  String get location => _s('location');
  String get predictButton => _s('predictButton');
  String get salaryRange => _s('salaryRange');
  String get entryLevel => _s('entryLevel');
  String get marketRate => _s('marketRate');
  String get seniorLevel => _s('seniorLevel');
  String get offerEvaluation => _s('offerEvaluation');
  String get enterOffer => _s('enterOffer');
  String get evaluate => _s('evaluate');
  String get belowMarket => _s('belowMarket');
  String get atMarket => _s('atMarket');
  String get aboveMarket => _s('aboveMarket');
  String get newPrediction => _s('newPrediction');
  String get chatbotHeading => _s('chatbotHeading');
  String get labourRights => _s('labourRights');
  String get negotiation => _s('negotiation');
  String get contractReview => _s('contractReview');
  String get typeMessage => _s('typeMessage');
  String get sources => _s('sources');
  String get colHeading => _s('colHeading');
  String get grossSalary => _s('grossSalary');
  String get selectCities => _s('selectCities');
  String get evaluateButton => _s('evaluateButton');
  String get deductions => _s('deductions');
  String get netSalary => _s('netSalary');
  String get expenses => _s('expenses');
  String get disposableIncome => _s('disposableIncome');
  String get meetsLivingWage => _s('meetsLivingWage');
  String get belowLivingWage => _s('belowLivingWage');
  String get profileHeading => _s('profileHeading');
  String get language => _s('language');
  String get settings => _s('settings');
  String get english => _s('english');
  String get bahasa => _s('bahasa');
  String get chinese => _s('chinese');
  String get tamil => _s('tamil');
  String get signOutConfirm => _s('signOutConfirm');
  String get version => _s('version');
  String get comfortable => _s('comfortable');
  String get tight => _s('tight');
  String get deficit => _s('deficit');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      ['en', 'ms', 'zh', 'ta'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
