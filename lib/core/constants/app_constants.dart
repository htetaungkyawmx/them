class AppConstants {
  // App Info
  static const String appName = 'မြန်မာ Dating App';
  static const String appVersion = '1.0.0';

  // API Endpoints
  static const String baseUrl = 'http://your-server-url:3000';
  static const String socketUrl = 'http://your-server-url:3000';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String themeKey = 'theme_mode';

  // Pagination
  static const int defaultPageSize = 20;
  static const int maxImageUpload = 6;

  // Location
  static const double defaultSearchRadius = 50.0; // kilometers
  static const int maxSearchRadius = 100;

  // Cache Duration
  static const int cacheDays = 7;

  // Animation Durations
  static const Duration animationSlow = Duration(milliseconds: 500);
  static const Duration animationNormal = Duration(milliseconds: 300);
  static const Duration animationFast = Duration(milliseconds: 150);
}

class AppStrings {
  // Authentication
  static const String welcome = 'မင်္ဂလာပါ';
  static const String welcomeSubtitle = 'သင့်အတွက် အထူးသင့်တော်ဆုံးသူကို ရှာဖွေလိုက်ပါ';
  static const String email = 'အီးမေးလ်';
  static const String password = 'စကားဝှက်';
  static const String confirmPassword = 'စကားဝှက် အတည်ပြုရန်';
  static const String login = 'ဝင်ရောက်မည်';
  static const String signup = 'စာရင်းသွင်းမည်';
  static const String forgotPassword = 'စကားဝှက် မေ့နေပါသလား?';
  static const String noAccount = 'အကောင့်မရှိသေးဘူးလား?';
  static const String haveAccount = 'အကောင့်ရှိပြီးသားလား?';
  static const String orContinueWith = 'သို့မဟုတ်';
  static const String googleLogin = 'Google ဖြင့် ဝင်ရောက်မည်';
  static const String phoneLogin = 'ဖုန်းနံပါတ်ဖြင့် ဝင်ရောက်မည်';

  // Profile
  static const String editProfile = 'ပရိုဖိုင်ကို ပြင်ဆင်မည်';
  static const String myPhotos = 'ကျွန်ုပ်၏ ဓာတ်ပုံများ';
  static const String aboutMe = 'ကျွန်ုပ်အကြောင်း';
  static const String interests = 'စိတ်ဝင်စားမှုများ';
  static const String basicInfo = 'အခြေခံ အချက်အလက်များ';
  static const String location = 'တည်နေရာ';
  static const String age = 'အသက်';
  static const String gender = 'လိင်';
  static const String occupation = 'အလုပ်အကိုင်';
  static const String education = 'ပညာအရည်အချင်း';

  // Matching
  static const String discover = 'ရှာဖွေမည်';
  static const String likes = 'စိတ်ဝင်စားမှုများ';
  static const String matches = 'ကိုက်ညီမှုများ';
  static const String swipeToLike = 'စိတ်ဝင်စားရန် ပွတ်ဆွဲပါ';
  static const String superLike = 'အထူးစိတ်ဝင်စားသည်';
  static const String pass = 'မကြိုက်ပါ';

  // Chat
  static const String messages = 'စာတိုများ';
  static const String typeMessage = 'စာရိုက်ရန်...';
  static const String send = 'ပို့မည်';
  static const String online = 'အွန်လိုင်း';
  static const String offline = 'အော့ဖ်လိုင်း';
  static const String typing = 'စာရိုက်နေသည်...';

  // Errors
  static const String error = 'အမှား';
  static const String networkError = 'အင်တာနက် ချိတ်ဆက်မှု မရှိပါ';
  static const String serverError = 'ဆာဗာချိတ်ဆက်မှု အဆင်မပြေပါ';
  static const String unknownError = 'အမှားတစ်ခု ဖြစ်ပွားခဲ့ပါသည်';
}