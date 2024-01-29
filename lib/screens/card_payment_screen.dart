// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';

// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'package:imagen/widgets/default_button.dart';

// import '../models/.env.dart';
// import '../widgets/response_card.dart';

// class StripePaymentScreen extends StatefulWidget {
//   final double amount;

//   const StripePaymentScreen({required this.amount, super.key});
//   @override
//   _StripePaymentScreenState createState() => _StripePaymentScreenState();
// }

// class _StripePaymentScreenState extends State<StripePaymentScreen> {
//   CardFieldInputDetails? _card;
//   String _email = 'email@stripe.com';
//   bool? _saveCard = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(Icons.arrow_back_ios),
//             onPressed: () async {
//               Navigator.of(context).pop();
//             },
//           ),
//         ),
//         body: SingleChildScrollView(
//             child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Text('Card Field',
//                   style: Theme.of(context).textTheme.headlineSmall),
//             ),
//             const SizedBox(height: 4),
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 20),
//               child: Row(
//                 children: [
//                   for (final tag in ['With Webhook']) Chip(label: Text(tag)),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             Padding(
//               padding: const EdgeInsets.all(20.0),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   TextFormField(
//                     initialValue: _email,
//                     decoration: const InputDecoration(
//                         hintText: 'Email', labelText: 'Email'),
//                     onChanged: (value) {
//                       setState(() {
//                         _email = value;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   CardField(
//                     enablePostalCode: true,
//                     countryCode: 'US',
//                     postalCodeHintText: 'Enter the us postal code',
//                     onCardChanged: (card) {
//                       setState(() {
//                         _card = card;
//                       });
//                     },
//                   ),
//                   const SizedBox(height: 20),
//                   CheckboxListTile(
//                     value: _saveCard,
//                     onChanged: (value) {
//                       setState(() {
//                         _saveCard = value;
//                       });
//                     },
//                     title: const Text('Save card during payment'),
//                   ),
//                   // CardFormField(
//                   //   controller: controller,
//                   //   countryCode: 'US',
//                   //   style: CardFormStyle(
//                   //     borderRadius: 2,
//                   //     borderColor:
//                   //         Theme.of(context).brightness == Brightness.dark
//                   //             ? Colors.white
//                   //             : Colors.grey[900],
//                   //     textColor: Theme.of(context).brightness == Brightness.dark
//                   //         ? Colors.white
//                   //         : Colors.grey[900],
//                   //     placeholderColor:
//                   //         Theme.of(context).brightness == Brightness.dark
//                   //             ? Colors.white
//                   //             : Colors.grey[900],
//                   //   ),
//                   // ),
//                   DefaultButton(
//                     press: () {
//                       _handlePayPress(amount: widget.amount);
//                     },
//                     text: 'Confirm',
//                   ),

//                   const Divider(),
//                   const SizedBox(height: 20),
//                   const SizedBox(height: 20),
//                   if (_card != null)
//                     ResponseCard(
//                       response: _card!.toJson().toString(),
//                     ),
//                 ],
//               ),
//             )
//           ],
//         )));
//   }

//   final kApiUrl = 'https://api.stripe.com/v1/payment_intents';

//   Future<void> _handlePayPress({required double amount}) async {
//     if (_card == null) {
//       return;
//     }

//     // 1. fetch Intent Client Secret from backend
//     final clientSecret = await fetchPaymentIntentClientSecret(amount: amount);

//     // 2. Gather customer billing information (ex. email)
//     final billingDetails = BillingDetails(
//       email: _email,
//       phone: '+48888000888',
//       address: const Address(
//         city: 'Houston',
//         country: 'US',
//         line1: '1459  Circle Drive',
//         line2: '',
//         state: 'Texas',
//         postalCode: '77063',
//       ),
//     ); // mo mocked data for tests

//     // 3. Confirm payment with card details
//     // The rest will be done automatically using webhooks
//     // ignore: unused_local_variable
//     final paymentIntent = await Stripe.instance.confirmPayment(
//       paymentIntentClientSecret: clientSecret['clientSecret'],
//       data: const PaymentMethodParams.card(
//         paymentMethodData:  PaymentMethodData(),
//       ),
//       options: PaymentMethodOptions(
//         setupFutureUsage:
//             _saveCard == true ? PaymentIntentsFutureUsage.OffSession : null,
//       ),
//     );

//     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//         content: Text('Success!: The payment was confirmed successfully!')));
//   }

//   Future<Map<String, dynamic>> fetchPaymentIntentClientSecret(
//       {required double amount}) async {
//     final url = Uri.parse('$kApiUrl/create-payment-intent');
//     final response = await http.post(
//       url,
//       headers: {
//         'Content-Type': 'application/json',
//       },
//       body: json.encode({
//         'currency': 'usd',
//         'amount': calculateAmount(amount.toString()),
//         'payment_method_types': ['card'],
//         'request_three_d_secure': 'any',
//       }),
//     );
//     return json.decode(response.body);
//   }

//   calculateAmount(String amount) {
//     if (amount.isEmpty) {
//       // Handle the case where amount is null or empty
//       return '0';
//     }

//     try {
//       final numericAmount = double.parse(amount);
//       final intAmount = (numericAmount * 100).toInt();
//       return intAmount.toString();
//     } catch (e) {
//       // Handle the case where amount cannot be parsed as a number
//       return '0';
//     }
//   }
// }
