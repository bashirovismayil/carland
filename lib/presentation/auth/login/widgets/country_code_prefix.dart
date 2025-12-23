import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:carcat/core/constants/enums/enums.dart';

class CountryCodePrefix extends StatelessWidget {
  const CountryCodePrefix({
    super.key,
    required this.countryCodeNotifier,
    required this.onTap,
  });

  final ValueNotifier<CountryCode> countryCodeNotifier;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<CountryCode>(
      valueListenable: countryCodeNotifier,
      builder: (context, countryCode, _) {
        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.only(left: 12, right: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildPhoneIcon(),
                const SizedBox(width: 8),
                _buildCountryCode(countryCode),
                const Icon(Icons.keyboard_arrow_down, size: 18, color: Colors.grey),
                _buildDivider(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPhoneIcon() => Padding(
    padding: const EdgeInsets.all(12.0),
    child: SvgPicture.asset(
      'assets/svg/phone.svg',
      width: 20,
      height: 20,
      colorFilter: ColorFilter.mode(Colors.grey.shade500, BlendMode.srcIn),
    ),
  );

  Widget _buildCountryCode(CountryCode code) => Text(
    code.code,
    style: const TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: Color(0xDA8A8A8A),
    ),
  );

  Widget _buildDivider() => Container(
    height: 24,
    width: 1,
    color: Colors.grey.shade300,
    margin: const EdgeInsets.only(left: 8),
  );
}