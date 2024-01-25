// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:imagen/widgets/default_button.dart';

import '../models/.env.dart';
import '../widgets/response_card.dart';

class StripePaymentScreen extends StatefulWidget {
  final double amount;

  const StripePaymentScreen({required this.amount, super.key});
  @override
  _StripePaymentScreenState createState() => _StripePaymentScreenState();
}

class _StripePaymentScreenState extends State<StripePaymentScreen> {
  final controller = CardFormEditController();

  @override
  void initState() {
    controller.addListener(update);
    super.initState();
  }

  void update() => setState(() {});
  @override
  void dispose() {
    controller.removeListener(update);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(CupertinoIcons.back),
            onPressed: () async {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Card Form',
                  style: Theme.of(context).textTheme.headlineSmall),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  for (final tag in ['No Webhook']) Chip(label: Text(tag)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CardFormField(
                    controller: controller,
                    countryCode: 'US',
                    style: CardFormStyle(
                      borderRadius: 2,
                      borderColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey[900],
                      textColor: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.grey[900],
                      placeholderColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.grey[900],
                    ),
                  ),
                  DefaultButton(
                    press: () {
                      _handlePayPress(amount: widget.amount);
                    },
                    text: 'Confirm',
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => controller.focus(),
                          child: const Text('Focus'),
                        ),
                        const SizedBox(width: 12),
                        OutlinedButton(
                          onPressed: () => controller.blur(),
                          child: const Text('Blur'),
                        ),
                      ],
                    ),
                  ),
                  const Divider(),
                  const SizedBox(height: 20),
                  ResponseCard(
                    response: controller.details.toJson().toString(),
                  )
                ],
              ),
            )
          ],
        )));
  }

// class CardPaymentScreen extends StatefulWidget {
//   final double amount;

//   const CardPaymentScreen(
//     this.amount, {
//     super.key,
//   });
//   @override
//   _CardPaymentScreenState createState() => _CardPaymentScreenState();
// }

// class _CardPaymentScreenState extends State<CardPaymentScreen> {
//   CardDetails _card = CardDetails();
//   bool? _saveCard = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             Container(
//                 margin: const EdgeInsets.all(16),
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: Colors.grey[200],
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: const Text(
//                     'If you don\'t want to or can\'t rely on the CardField you'
//                     ' can use the dangerouslyUpdateCardDetails in combination with '
//                     'your own card field implementation. \n\n'
//                     'Please beware that this will potentially break PCI compliance: '
//                     'https://stripe.com/docs/security/guide#validating-pci-compliance')),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: Row(
//                 children: [
//                   Expanded(
//                     flex: 2,
//                     child: TextField(
//                       decoration: const InputDecoration(hintText: 'Number'),
//                       onChanged: (number) {
//                         setState(() {
//                           _card = _card.copyWith(number: number);
//                         });
//                       },
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     width: 80,
//                     child: TextField(
//                       decoration: const InputDecoration(hintText: 'Exp. Year'),
//                       onChanged: (number) {
//                         setState(() {
//                           _card = _card.copyWith(
//                               expirationYear: int.tryParse(number));
//                         });
//                       },
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     width: 80,
//                     child: TextField(
//                       decoration: const InputDecoration(hintText: 'Exp. Month'),
//                       onChanged: (number) {
//                         setState(() {
//                           _card = _card.copyWith(
//                               expirationMonth: int.tryParse(number));
//                         });
//                       },
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                   Container(
//                     padding: const EdgeInsets.symmetric(horizontal: 4),
//                     width: 80,
//                     child: TextField(
//                       decoration: const InputDecoration(hintText: 'CVC'),
//                       onChanged: (number) {
//                         setState(() {
//                           _card = _card.copyWith(cvc: number);
//                         });
//                       },
//                       keyboardType: TextInputType.number,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             CheckboxListTile(
//               value: _saveCard,
//               onChanged: (value) {
//                 setState(() {
//                   _saveCard = value;
//                 });
//               },
//               title: const Text('Save card during payment'),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16),
//               child: DefaultButton(
//                 press: () {
//                   _handlePayPress(amount: widget.amount.toString());
//                 },
//                 text: 'Confirm',
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

  Future<void> _handlePayPress({required double amount}) async {
    if (!controller.details.complete) {
      return;
    }

    try {
      // 1. Gather customer billing information (ex. email)

      const billingDetails = BillingDetails(
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mocked data for tests

      // 2. Create payment method
      final paymentMethod = await Stripe.instance.createPaymentMethod(
          params: const PaymentMethodParams.card(
        paymentMethodData: PaymentMethodData(
          billingDetails: billingDetails,
        ),
      ));

      // 3. call API to create PaymentIntent
      final paymentIntentResult = await callNoWebhookPayEndpointMethodId(
        useStripeSdk: true,
        amount: amount.toString(),
        paymentMethodId: paymentMethod.id,
        currency: 'usd', // mocked data
        items: ['id-1'],
      );

      if (paymentIntentResult['error'] != null) {
        // Error during creating or confirming Intent
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${paymentIntentResult['error']}')));
        return;
      }

      if (paymentIntentResult['clientSecret'] != null &&
          paymentIntentResult['requiresAction'] == null) {
        // Payment succedeed

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Success!: The payment was confirmed successfully!')));
        return;
      }

      if (paymentIntentResult['clientSecret'] != null &&
          paymentIntentResult['requiresAction'] == true) {
        // 4. if payment requires action calling handleNextAction
        final paymentIntent = await Stripe.instance
            .handleNextAction(paymentIntentResult['clientSecret']);

        // todo handle error
        /*if (cardActionError) {
        Alert.alert(
        `Error code: ${cardActionError.code}`,
        cardActionError.message
        );
      } else*/

        if (paymentIntent.status == PaymentIntentsStatus.RequiresConfirmation) {
          // 5. Call API to confirm intent
          await confirmIntent(paymentIntent.id);
        } else {
          // Payment succedeed
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Error: ${paymentIntentResult['error']}')));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
      rethrow;
    }
  }

  Future<void> confirmIntent(String paymentIntentId) async {
    final result = await callNoWebhookPayEndpointIntentId(
        paymentIntentId: paymentIntentId);
    if (result['error'] != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${result['error']}')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Success!: The payment was confirmed successfully!')));
    }
  }

  final kApiUrl = 'https://api.stripe.com/v1/payment_intents';
  Future<Map<String, dynamic>> callNoWebhookPayEndpointIntentId({
    required String paymentIntentId,
  }) async {
    final url = Uri.parse('$kApiUrl/charge-card-off-session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'paymentIntentId': paymentIntentId}),
    );
    return json.decode(response.body);
  }

  Future<Map<String, dynamic>> callNoWebhookPayEndpointMethodId({
    required bool useStripeSdk,
    required String paymentMethodId,
    required String currency,
    required String amount,
    List<String>? items,
  }) async {
    final url = Uri.parse('$kApiUrl/pay-without-webhooks');
    Map<String, dynamic> body = {
      'amount': amount,
      'currency': currency,
      'useStripeSdk': true,
      'payment_method_types[]': 'card',
    };
    final response = await http.post(
      url,
      headers: {
        'Authorization':
            'Bearer $stripeSecretKey', // Replace with your Stripe secret key
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: body,
    );
    return json.decode(response.body);
  }

  calculateAmount(String amount) {
    final a = (int.parse(amount)) * 100;
    return a.toString();
  }
}
