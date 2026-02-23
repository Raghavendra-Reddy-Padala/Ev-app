class TextStrings {
  static const baseUrl = 'https://ev-api.aks2.mellob.in/';
  static const login = 'Login';
  static const tc =
      'By clicking continue, you agree to our Terms of Service and Privacy Policy.';
  static const createAcc = 'Create an account';
  static const createAccText1 =
      'Enter your phone number to signup for this app';
  static const signup = 'Sign up';
  static const loginText1 = 'or continue with';
  static const google = 'Google';
  static const GetOtp = 'Get OTP';
  static const otp1 = 'Phone Verification';
  static const otp2 = 'Please type the verification code';
  static const otp3 = 'sent to +91';
  static const otp4 = 'If you didn\'t receive a code';
  static const otp5 = 'Resend';
  static const continueStr = 'Continue';
  static const distance = 'Distance';

  static const selectPlan = 'Select a Plan';

  static const pay = 'Pay';

  static const subscription = 'Subscription';
  static const createGroup = 'Groups';
  static const currSubs = 'Current Subscription';
  static const preSubs = 'Previous Subscription';
  static const charges = 'Subscription Charges';
  static const security = 'Security Deposit';
  static const plan = 'Weekly Unlimeted';
  static const plantime = '4 days left';
  static const plantime2 = 'Expired';
  static const date = "26 May,2023";
  static const date2 = "26 April,2023";
  static const time = "(11.30AM)";
  static const cost = "₹349";
  static const cost2 = "₹500";
  static const cost3 = "₹849";

  static const account = "Account";
  static const name = "Sahithi";
  static const fullNameValue = "Sahithi Reddy";
  static const fullName = "Full Name";
  static const phone = "Phone";
  static const phoneValue = "9999999999";
  static const emailValue = "abcd@xvz.com";
  static const email = "Email";
  static const dark = "Dark";
  static const distanceCovered = "8Kms";
  static const trips = "4 Trips";

  static const issue = 'Report an issue for a better experience.';
  static const issueHead = 'Report an issue';
  static const consern = 'Type your consern';
  static const battery = 'Battery';
  static const brake = 'Brake';
  static const chain = 'Chain';
  static const pendal = 'Pendal';
  static const seat = 'Seat';
  static const submit = 'Submit';
  static const tyre = 'Tyre';

  static const help = 'Help and FAQ';
  static const about = 'About';
  static const logout = 'Logout';
  static const graphHead = 'Time Travelled';

  static const faq = 'FAQ';
  static const faqHead = 'How can we help you?';
  static const ques1 = 'What electric cycle options are available?';
  static const ques2 = 'What plans are available for renting electric cycles?';
  static const ques3 = 'How can I view my order summary?';
  static const ques4 = 'How do I rent a bike after selecting a plan?';
  static const ques5 = 'Can I return the bike anywhere?';
  static const ans1 =
      'You can choose from L Series, F Series  and E Series electric cycles, each displaying unique features such as frame number, Top speed, Range and charge Time.';
  static const ans2 =
      'You can choose from Hourly and Monthly plans,each displaying charges, Validity, and a Refundable security Deposit.';
  static const ans3 =
      'After selecting a plan, an order summary header will popup at the bottom, showing your name, wallet balance, and payment details.';
  static const ans4 =
      'A QR Code is provided. Simply use the scan button to unlock your selected bike.';
  static const ans5 =
      'No, Please return your bike only at the designated Hub. The system restricts within a certain distance';

  static const my_trips = 'My Trips';
  static const activity = 'Activity';
}

class AssetsStrings {
  static const String lightLogo = 'assets/company/Logo.png';
  static const String darkLogo = 'assets/company/Logo-Black.png';
  static const String svgLogo = 'assets/company/logo.svg';
  static const String google = 'assets/images/google.png';
  static const String location = 'assets/images/location.png';
  static const String distMarker = 'assets/images/dist_marker.png';
  static const String token = 'assets/images/token.png';
  static const String cycle = 'assets/images/cycle.png';
  static const String arrow = 'assets/images/arrow.png';
  static const String home = 'assets/images/home.png';
  static const String rider = 'assets/images/rider.png';
  static const String wallet = 'assets/images/wallet.png';
  static const String profile = 'assets/images/profile.png';

  static const String distance = 'assets/images/distance.png';
  static const String bike = 'assets/images/bike.png';

  static const String battery = 'assets/images/battery.png';
  static const String brake = 'assets/images/brake.png';
  static const String chain = 'assets/images/chain.png';
  static const String pedal = 'assets/images/pedal.png';
  static const String seat = 'assets/images/seat.png';
  static const String tyre = 'assets/images/tyre.png';
  static const String appbarIcon = 'assets/images/appbarIcon.png';
}

class AnimationStrings {
  static const String success = 'assets/animations/success.json';
}
class MapStyles {
  // Enhanced realistic street view style
  static const String realisticStreet = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#bdbdbd"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#dadada"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#c9c9c9"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  }
]
''';

  // Enhanced realistic with buildings and 3D feel
  static const String urbanRealistic = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "elementType": "labels.icon",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "poi.business",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#a5d68c"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#447530"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#ffffff"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels",
    "stylers": [
      {
        "visibility": "on"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#fdfcf8"
      }
    ]
  },
  {
    "featureType": "road.arterial",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#757575"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#fee379"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#616161"
      }
    ]
  },
  {
    "featureType": "road.local",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9e9e9e"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#e5e5e5"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#eeeeee"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#73b9ff"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#4d80cc"
      }
    ]
  }
]
''';

  // Dark mode realistic
  static const String realisticDark = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#263c3f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6b9a76"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#38414e"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#212a37"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9ca5b3"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#746855"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#1f2835"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#f3d19c"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2f3948"
      }
    ]
  },
  {
    "featureType": "transit.station",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#d59563"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#515c6d"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#17263c"
      }
    ]
  }
]
''';

  // Keep your existing styles as fallback
  static const String customLight = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#f5f5f5"
      }
    ]
  }
]
''';

  static const String customDark = '''
[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#242f3e"
      }
    ]
  }
]
''';
}