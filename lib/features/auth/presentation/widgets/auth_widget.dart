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
  BuildContext? context,
}) {
  final cs = context != null ? Theme.of(context).colorScheme : null;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        labelText,
        style: TextStyle(
          fontSize: 12,
          color: cs?.onSurface ?? darkTextColor,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        validator: validator,
        cursorColor: cs?.primary ?? peerPicksGreen,
        decoration: InputDecoration(
          hintText: hintText,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: cs?.surfaceContainerHighest ?? Colors.grey.shade100,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: cs?.outlineVariant ?? Colors.grey.shade300,
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(
              color: cs?.primary ?? peerPicksGreen,
              width: 2.0,
            ),
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
  Color? color,
  BuildContext? context,
}) {
  final cs = context != null ? Theme.of(context).colorScheme : null;
  final btnColor = color ?? cs?.primary ?? peerPicksGreen;

  return GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        color: btnColor,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: btnColor.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
            color: cs?.onPrimary ?? Colors.white,
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

Widget socialCircle(IconData icon, Color iconColor, {BuildContext? context}) {
  final cs = context != null ? Theme.of(context).colorScheme : null;

  return Container(
    width: 45,
    height: 45,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: cs?.outlineVariant ?? Colors.grey.shade400),
      color: cs?.surface ?? Colors.white,
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

Widget buildSocialRow({BuildContext? context}) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      socialCircle(
        FontAwesomeIcons.facebookF,
        const Color(0xFF1877F2),
        context: context,
      ),
      const SizedBox(width: 20),
      socialCircle(
        FontAwesomeIcons.github,
        const Color(0xFF333333),
        context: context,
      ),
      const SizedBox(width: 20),
      socialCircle(FontAwesomeIcons.google, Colors.red, context: context),
    ],
  );
}
