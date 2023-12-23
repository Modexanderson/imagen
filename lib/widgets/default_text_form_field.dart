import 'package:flutter/material.dart';

class DefaultTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final String labelText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final AutovalidateMode autovalidateMode;

  const DefaultTextFormField({super.key, 
    required this.controller,
    required this.hintText,
    required this.labelText,
    this.obscureText = false,
    this.keyboardType,
    this.suffixIcon,
    this.validator,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        labelText: labelText,
        suffixIcon: suffixIcon,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
      validator: validator,
      autovalidateMode: autovalidateMode,
    );
  }
}





// import 'package:flutter/cupertino.dart';

// class DefaultCupertinoTextFormField extends StatelessWidget {
//   final TextEditingController controller;
//   final String hintText;
//   final String labelText;

//   DefaultCupertinoTextFormField({
//     required this.controller,
//     required this.hintText,
//     required this.labelText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return CupertinoFormRow(
//       padding: EdgeInsets.all(8.0),
//       child: CupertinoTextField(
//         controller: controller,
//         placeholder: hintText,
//         clearButtonMode: OverlayVisibilityMode.editing,
//         prefix: Padding(
//           padding: EdgeInsets.all(8.0),
//           child: Text(labelText),
//         ),
//         decoration: BoxDecoration(
//           border: Border(
//             bottom: BorderSide(
//               color: CupertinoColors.inactiveGray,
//               width: 0.0,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
