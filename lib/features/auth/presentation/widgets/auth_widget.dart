import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

const Color peerPicksGreen = Color(0xFF75A638);
const Color darkTextColor = Color(0xFF333333);

Widget buildAuthTextFormField({
  required TextEditingController controller,
  required String? Function(String?) validator,
  required String labelText,
  required String hintText,
  TextInputType keyboardType = TextInputType.text,
  bool obscureText = false,
  Widget? suffixIcon,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: const TextStyle(
          fontSize: 12,
          color: darkTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        cursorColor: peerPicksGreen,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300, width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: peerPicksGreen, width: 2.0),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
      ),
    ],
  );
}

Widget buildActionButton({
  required String text,
  required VoidCallback onTap,
  Color color = peerPicksGreen,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    ),
  );
}

Widget buildVisibilityToggle({
  required bool isVisible,
  required Function() toggleFunction,
}) {
  return IconButton(
    icon: Icon(
      isVisible ? Icons.visibility_off : Icons.visibility,
      color: Colors.grey,
      size: 20,
    ),
    onPressed: toggleFunction,
  );
}

Widget socialCircle(IconData icon, Color iconColor) {
  return Container(
    width: 45,
    height: 45,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: Colors.grey.shade400),
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Center(child: FaIcon(icon, size: 22, color: iconColor)),
  );
}

Widget buildSocialRow() {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      socialCircle(FontAwesomeIcons.facebookF, const Color(0xFF1877F2)),
      const SizedBox(width: 20),
      socialCircle(FontAwesomeIcons.github, darkTextColor),
      const SizedBox(width: 20),
      socialCircle(FontAwesomeIcons.google, Colors.red),
    ],
  );
}
