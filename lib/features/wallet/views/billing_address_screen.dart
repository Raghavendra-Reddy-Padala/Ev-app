import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:mjollnir/features/wallet/controller/wallet_controller.dart';
import 'package:mjollnir/shared/constants/colors.dart';

class BillingAddressScreen extends StatefulWidget {
  const BillingAddressScreen({super.key});

  @override
  State<BillingAddressScreen> createState() => _BillingAddressScreenState();
}

class _BillingAddressScreenState extends State<BillingAddressScreen> {
  final WalletController controller = Get.find<WalletController>();
  final _formKey = GlobalKey<FormState>();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();
  bool _isLoading = false;

  String _selectedCountry = 'IN';

  // All ISO 3166-1 alpha-2 country codes with names, sorted alphabetically
  static const List<MapEntry<String, String>> _allCountries = [
    MapEntry('IN', 'India'),
    MapEntry('US', 'United States'),
    MapEntry('GB', 'United Kingdom'),
    MapEntry('AF', 'Afghanistan'),
    MapEntry('AL', 'Albania'),
    MapEntry('DZ', 'Algeria'),
    MapEntry('AD', 'Andorra'),
    MapEntry('AO', 'Angola'),
    MapEntry('AG', 'Antigua and Barbuda'),
    MapEntry('AR', 'Argentina'),
    MapEntry('AM', 'Armenia'),
    MapEntry('AU', 'Australia'),
    MapEntry('AT', 'Austria'),
    MapEntry('AZ', 'Azerbaijan'),
    MapEntry('BS', 'Bahamas'),
    MapEntry('BH', 'Bahrain'),
    MapEntry('BD', 'Bangladesh'),
    MapEntry('BB', 'Barbados'),
    MapEntry('BY', 'Belarus'),
    MapEntry('BE', 'Belgium'),
    MapEntry('BZ', 'Belize'),
    MapEntry('BJ', 'Benin'),
    MapEntry('BT', 'Bhutan'),
    MapEntry('BO', 'Bolivia'),
    MapEntry('BA', 'Bosnia and Herzegovina'),
    MapEntry('BW', 'Botswana'),
    MapEntry('BR', 'Brazil'),
    MapEntry('BN', 'Brunei'),
    MapEntry('BG', 'Bulgaria'),
    MapEntry('BF', 'Burkina Faso'),
    MapEntry('BI', 'Burundi'),
    MapEntry('KH', 'Cambodia'),
    MapEntry('CM', 'Cameroon'),
    MapEntry('CA', 'Canada'),
    MapEntry('CV', 'Cape Verde'),
    MapEntry('CF', 'Central African Republic'),
    MapEntry('TD', 'Chad'),
    MapEntry('CL', 'Chile'),
    MapEntry('CN', 'China'),
    MapEntry('CO', 'Colombia'),
    MapEntry('KM', 'Comoros'),
    MapEntry('CG', 'Congo'),
    MapEntry('CR', 'Costa Rica'),
    MapEntry('HR', 'Croatia'),
    MapEntry('CU', 'Cuba'),
    MapEntry('CY', 'Cyprus'),
    MapEntry('CZ', 'Czech Republic'),
    MapEntry('DK', 'Denmark'),
    MapEntry('DJ', 'Djibouti'),
    MapEntry('DM', 'Dominica'),
    MapEntry('DO', 'Dominican Republic'),
    MapEntry('EC', 'Ecuador'),
    MapEntry('EG', 'Egypt'),
    MapEntry('SV', 'El Salvador'),
    MapEntry('GQ', 'Equatorial Guinea'),
    MapEntry('ER', 'Eritrea'),
    MapEntry('EE', 'Estonia'),
    MapEntry('ET', 'Ethiopia'),
    MapEntry('FJ', 'Fiji'),
    MapEntry('FI', 'Finland'),
    MapEntry('FR', 'France'),
    MapEntry('GA', 'Gabon'),
    MapEntry('GM', 'Gambia'),
    MapEntry('GE', 'Georgia'),
    MapEntry('DE', 'Germany'),
    MapEntry('GH', 'Ghana'),
    MapEntry('GR', 'Greece'),
    MapEntry('GD', 'Grenada'),
    MapEntry('GT', 'Guatemala'),
    MapEntry('GN', 'Guinea'),
    MapEntry('GW', 'Guinea-Bissau'),
    MapEntry('GY', 'Guyana'),
    MapEntry('HT', 'Haiti'),
    MapEntry('HN', 'Honduras'),
    MapEntry('HK', 'Hong Kong'),
    MapEntry('HU', 'Hungary'),
    MapEntry('IS', 'Iceland'),
    MapEntry('ID', 'Indonesia'),
    MapEntry('IR', 'Iran'),
    MapEntry('IQ', 'Iraq'),
    MapEntry('IE', 'Ireland'),
    MapEntry('IL', 'Israel'),
    MapEntry('IT', 'Italy'),
    MapEntry('JM', 'Jamaica'),
    MapEntry('JP', 'Japan'),
    MapEntry('JO', 'Jordan'),
    MapEntry('KZ', 'Kazakhstan'),
    MapEntry('KE', 'Kenya'),
    MapEntry('KI', 'Kiribati'),
    MapEntry('KR', 'Korea, South'),
    MapEntry('KW', 'Kuwait'),
    MapEntry('KG', 'Kyrgyzstan'),
    MapEntry('LA', 'Laos'),
    MapEntry('LV', 'Latvia'),
    MapEntry('LB', 'Lebanon'),
    MapEntry('LS', 'Lesotho'),
    MapEntry('LR', 'Liberia'),
    MapEntry('LY', 'Libya'),
    MapEntry('LI', 'Liechtenstein'),
    MapEntry('LT', 'Lithuania'),
    MapEntry('LU', 'Luxembourg'),
    MapEntry('MK', 'North Macedonia'),
    MapEntry('MG', 'Madagascar'),
    MapEntry('MW', 'Malawi'),
    MapEntry('MY', 'Malaysia'),
    MapEntry('MV', 'Maldives'),
    MapEntry('ML', 'Mali'),
    MapEntry('MT', 'Malta'),
    MapEntry('MH', 'Marshall Islands'),
    MapEntry('MR', 'Mauritania'),
    MapEntry('MU', 'Mauritius'),
    MapEntry('MX', 'Mexico'),
    MapEntry('FM', 'Micronesia'),
    MapEntry('MD', 'Moldova'),
    MapEntry('MC', 'Monaco'),
    MapEntry('MN', 'Mongolia'),
    MapEntry('ME', 'Montenegro'),
    MapEntry('MA', 'Morocco'),
    MapEntry('MZ', 'Mozambique'),
    MapEntry('MM', 'Myanmar'),
    MapEntry('NA', 'Namibia'),
    MapEntry('NR', 'Nauru'),
    MapEntry('NP', 'Nepal'),
    MapEntry('NL', 'Netherlands'),
    MapEntry('NZ', 'New Zealand'),
    MapEntry('NI', 'Nicaragua'),
    MapEntry('NE', 'Niger'),
    MapEntry('NG', 'Nigeria'),
    MapEntry('NO', 'Norway'),
    MapEntry('OM', 'Oman'),
    MapEntry('PK', 'Pakistan'),
    MapEntry('PW', 'Palau'),
    MapEntry('PS', 'Palestine'),
    MapEntry('PA', 'Panama'),
    MapEntry('PG', 'Papua New Guinea'),
    MapEntry('PY', 'Paraguay'),
    MapEntry('PE', 'Peru'),
    MapEntry('PH', 'Philippines'),
    MapEntry('PL', 'Poland'),
    MapEntry('PT', 'Portugal'),
    MapEntry('QA', 'Qatar'),
    MapEntry('RO', 'Romania'),
    MapEntry('RU', 'Russia'),
    MapEntry('RW', 'Rwanda'),
    MapEntry('SA', 'Saudi Arabia'),
    MapEntry('SN', 'Senegal'),
    MapEntry('RS', 'Serbia'),
    MapEntry('SC', 'Seychelles'),
    MapEntry('SL', 'Sierra Leone'),
    MapEntry('SG', 'Singapore'),
    MapEntry('SK', 'Slovakia'),
    MapEntry('SI', 'Slovenia'),
    MapEntry('SB', 'Solomon Islands'),
    MapEntry('SO', 'Somalia'),
    MapEntry('ZA', 'South Africa'),
    MapEntry('SS', 'South Sudan'),
    MapEntry('ES', 'Spain'),
    MapEntry('LK', 'Sri Lanka'),
    MapEntry('SD', 'Sudan'),
    MapEntry('SR', 'Suriname'),
    MapEntry('SE', 'Sweden'),
    MapEntry('CH', 'Switzerland'),
    MapEntry('SY', 'Syria'),
    MapEntry('TW', 'Taiwan'),
    MapEntry('TJ', 'Tajikistan'),
    MapEntry('TZ', 'Tanzania'),
    MapEntry('TH', 'Thailand'),
    MapEntry('TL', 'Timor-Leste'),
    MapEntry('TG', 'Togo'),
    MapEntry('TO', 'Tonga'),
    MapEntry('TT', 'Trinidad and Tobago'),
    MapEntry('TN', 'Tunisia'),
    MapEntry('TR', 'Turkey'),
    MapEntry('TM', 'Turkmenistan'),
    MapEntry('TV', 'Tuvalu'),
    MapEntry('UG', 'Uganda'),
    MapEntry('UA', 'Ukraine'),
    MapEntry('AE', 'UAE'),
    MapEntry('UY', 'Uruguay'),
    MapEntry('UZ', 'Uzbekistan'),
    MapEntry('VU', 'Vanuatu'),
    MapEntry('VE', 'Venezuela'),
    MapEntry('VN', 'Vietnam'),
    MapEntry('YE', 'Yemen'),
    MapEntry('ZM', 'Zambia'),
    MapEntry('ZW', 'Zimbabwe'),
  ];

  // Valid country codes set for quick lookup
  static final Set<String> _validCodes =
      _allCountries.map((e) => e.key).toSet();

  @override
  void initState() {
    super.initState();
    _loadExistingAddress();
  }

  void _loadExistingAddress() {
    final addr = controller.billingAddress;
    if (addr.isNotEmpty) {
      _streetController.text = addr['street'] ?? '';
      _cityController.text = addr['city'] ?? '';
      _stateController.text = addr['state'] ?? '';
      _zipcodeController.text = addr['zipcode'] ?? '';
      final country = addr['country'] ?? '';
      if (country.isNotEmpty && _validCodes.contains(country.toUpperCase())) {
        _selectedCountry = country.toUpperCase();
      }
    }
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success = await controller.updateBillingAddress(
      street: _streetController.text.trim(),
      city: _cityController.text.trim(),
      state: _stateController.text.trim(),
      zipcode: _zipcodeController.text.trim(),
      country: _selectedCountry,
    );

    setState(() => _isLoading = false);

    if (success) {
      Get.snackbar('Success', 'Billing address saved!');
      Get.back(result: true);
    } else {
      Get.snackbar('Error', 'Failed to save billing address');
    }
  }

  @override
  void dispose() {
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Billing Address'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.location_on,
                        color: AppColors.primary, size: 28),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Set Billing Address',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Required for processing payments',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Street Address
              _buildLabel('Street Address'),
              SizedBox(height: 8.h),
              _buildTextField(
                controller: _streetController,
                hint: '123 Main St, Apt 4B',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Street address is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Enter at least 3 characters';
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // City & State Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('City'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _cityController,
                          hint: 'Mumbai',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'City is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Enter at least 2 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('State'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _stateController,
                          hint: 'Maharashtra',
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'State is required';
                            }
                            if (value.trim().length < 2) {
                              return 'Enter at least 2 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16.h),

              // Zipcode & Country Row
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('ZIP / Postal Code'),
                        SizedBox(height: 8.h),
                        _buildTextField(
                          controller: _zipcodeController,
                          hint: '400001',
                          keyboardType: TextInputType.text,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'ZIP code is required';
                            }
                            if (value.trim().length < 3) {
                              return 'Enter at least 3 characters';
                            }
                            if (value.trim().length > 10) {
                              return 'Max 10 characters';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildLabel('Country'),
                        SizedBox(height: 8.h),
                        _buildCountryDropdown(),
                      ],
                    ),
                  ),
                ],
              ),

              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveAddress,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save Address',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),

              SizedBox(height: 16.h),

              // Info text
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'Your billing address is required by our payment provider for compliance.',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
          color: Colors.grey.shade400,
          fontSize: 14.sp,
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 12.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: AppColors.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: const BorderSide(color: Colors.red),
        ),
        errorStyle: TextStyle(fontSize: 11.sp),
      ),
    );
  }

  Widget _buildCountryDropdown() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedCountry,
          isExpanded: true,
          menuMaxHeight: 300.h,
          items: _allCountries.map((e) {
            return DropdownMenuItem(
              value: e.key,
              child: Text(
                '${e.key} - ${e.value}',
                style: TextStyle(fontSize: 13.sp),
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (value) {
            if (value != null) {
              setState(() => _selectedCountry = value);
            }
          },
        ),
      ),
    );
  }
}
