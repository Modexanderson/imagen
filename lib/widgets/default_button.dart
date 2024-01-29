import 'package:flutter/material.dart';

import '../models/size_config.dart';

class DefaultButton extends StatelessWidget {
  final String? text;
  final Function? press;
  // final Color color;
  const DefaultButton({
    Key? key,
    this.text,
    this.press,
    // this.color = kPrimaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double doubleValue = MediaQuery.of(context).orientation == Orientation.landscape
        ? 150.0 // Set your double value for landscape
        : 56.0;
    return SizedBox(
      width: double.infinity,
      height: getProportionateScreenHeight(doubleValue),
      child: ElevatedButton(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(
              Theme.of(context).colorScheme.secondary),
          elevation: MaterialStateProperty.all(10),
          fixedSize:
              MaterialStateProperty.all(const Size.fromWidth(double.maxFinite)),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          padding: MaterialStateProperty.all<EdgeInsetsGeometry>(
            const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
          ),
        ),
        onPressed: () {
          press!();
        },
        child: Text(
          text!,
          style: TextStyle(
            fontSize: getProportionateScreenWidth(18),
            // color: Colors.white,
          ),
        ),
      ),
    );
  }
}
