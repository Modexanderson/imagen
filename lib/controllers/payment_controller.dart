// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:imagen/widgets/snack_bar.dart';

import '../models/.env.dart';
import '../services/authentification_service.dart';
import '../services/database/user_database_helper.dart';

class PaymentController extends GetxController {
  Map<String, dynamic>? paymentIntentData;

  Future<void> makePayment(
      {required BuildContext context,
      required double amount,
      required String currency}) async {
    String userUid = AuthentificationService().currentUser.uid;

    try {
      paymentIntentData =
          await createPaymentIntent(context, amount.toString(), currency);
      if (paymentIntentData != null) {
        await Stripe.instance.initPaymentSheet(
            paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Prospects',
          customerId: paymentIntentData!['customer'],
          paymentIntentClientSecret: paymentIntentData!['client_secret'],
          customerEphemeralKeySecret: paymentIntentData!['ephemeralKey'],
        ));
        displayPaymentSheet(context: context, userUid: userUid, amount: amount);
      }
    } catch (e, s) {
      print('exception:$e$s');
    }
  }

  displayPaymentSheet(
      {required BuildContext context,
      required String userUid,
      required double amount}) async {
    try {
      await Stripe.instance.presentPaymentSheet();
      await UserDatabaseHelper().updateCreditsAfterPayment(userUid, amount);
      Navigator.of(context).pop();
      // ShowSnackBar().showSnackBar(context, AppLocalizations.of(context)!.)
      // Get.snackbar('Payment', 'Payment Successful',
      //     snackPosition: SnackPosition.BOTTOM,
      //     backgroundColor: Colors.green,
      //     colorText: Colors.white,
      //     margin: const EdgeInsets.all(10),
      //     duration: const Duration(seconds: 2));
    } on Exception catch (e) {
      if (e is StripeException) {
        ShowSnackBar()
            .showSnackBar(context, e.error.localizedMessage.toString());
        print("Error from Stripe: ${e.error.localizedMessage}");
      } else {
        ShowSnackBar().showSnackBar(context, e.toString());
        print("Unforeseen error: ${e}");
      }
    } catch (e) {
      print("exception:$e");
    }
  }

  //  Future<Map<String, dynamic>>
  createPaymentIntent(
      BuildContext context, String amount, String currency) async {
    try {
      Map<String, dynamic> body = {
        'amount': calculateAmount(amount),
        'currency': currency,
        'payment_method_types[]': 'card'
      };
      var response = await http.post(
          Uri.parse('https://api.stripe.com/v1/payment_intents'),
          body: body,
          headers: {
            'Authorization': 'Bearer $stripeTestSecretKey',
            'Content-Type': 'application/x-www-form-urlencoded'
          });
      return jsonDecode(response.body);
    } catch (err) {
      ShowSnackBar().showSnackBar(context, err.toString());
      print('err charging user: ${err.toString()}');
    }
  }

  calculateAmount(String amount) {
    if (amount.isEmpty) {
      // Handle the case where amount is null or empty
      return '0';
    }

    try {
      final numericAmount = double.parse(amount);
      final intAmount = (numericAmount * 100).toInt();
      return intAmount.toString();
    } catch (e) {
      // Handle the case where amount cannot be parsed as a number
      return '0';
    }
  }
}
