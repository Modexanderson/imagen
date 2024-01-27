// import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get/get.dart';
import 'package:imagen/screens/card_payment_screen.dart';

import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../controllers/payment_controller.dart';
import 'default_progress_indicator.dart';

class StripePayState extends ChangeNotifier {
  double selectedAmount = 5.0;
  TextEditingController customAmountController = TextEditingController();

  void updateSelectedAmount(double amount) {
    selectedAmount = amount;
    notifyListeners();
  }
}

String generateReferenceGoodsId() {
  // Create a new instance of the Uuid class
  const uuid = Uuid();

  // Generate a unique ID
  String referenceGoodsId = uuid.v4();

  return referenceGoodsId;
}

Widget StripePayWidget() {
  final PaymentController controller = Get.put(PaymentController());
  return Consumer<StripePayState>(
    builder: (context, state, _) {
      return AlertDialog(
        title: Text(
          AppLocalizations.of(context)!.selectAmount,
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: SingleChildScrollView(
            child: Column(
              // mainAxisSize: MainAxisSize.min,
              children: [
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 3,
                  crossAxisSpacing: 10.0,
                  mainAxisSpacing: 10.0,
                  childAspectRatio: (70 / 70),
                  children: [
                    for (var amount in [5, 10, 15, 20, 50, 100])
                      GestureDetector(
                        onTap: () {
                          state.updateSelectedAmount(amount.toDouble());
                          state.customAmountController.clear();
                        },
                        child: SizedBox(
                          width: 150,
                          height: 60,
                          child: Card(
                            color: state.selectedAmount == amount.toDouble()
                                ? Theme.of(context).appBarTheme.backgroundColor
                                : Colors.white,
                            child: SizedBox(
                              height: 50,
                              child: Center(
                                child: Text(
                                  '\$ $amount',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: state.selectedAmount ==
                                            amount.toDouble()
                                        ? Colors.white
                                        : Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                CupertinoTextField(
                  controller: state.customAmountController,
                  keyboardType: TextInputType.number,
                  placeholder: AppLocalizations.of(context)!.enterAmount,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  style: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.black,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 16.0),
                  placeholderStyle: const TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                  prefix: const Padding(
                    padding: EdgeInsets.only(left: 16.0, right: 8.0),
                    child: Text(
                      '\$',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  onTap: () {
                    state.updateSelectedAmount(0.0);
                  },
                )
              ],
            ),
          ),
        ),
        actions: <Widget>[
          Row(
            children: [
              Expanded(
                child: CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.cancel),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: CupertinoDialogAction(
                  child: Text(AppLocalizations.of(context)!.confirm),
                  onPressed: () async {
                    // Create a GlobalKey for the loading spinner dialog
                    final GlobalKey<State> key = GlobalKey<State>();
                    var amount = 0.0;
                    if (state.customAmountController.text.isEmpty) {
                      amount = state.selectedAmount;
                    } else {
                      amount =
                          double.tryParse(state.customAmountController.text) ??
                              0.0;
                      state.updateSelectedAmount(
                          amount); // Deselect the amount in the card
                    }

                    Navigator.of(context).pop();
                    // Show loading spinner while creating Binance Pay order
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          key: key,
                          content: const Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DefaultProgressIndicator(),
                              // SizedBox(height: 16),
                              // Text(AppLocalizations.of(context)!
                              //     .creatingBinanceOrder),
                            ],
                          ),
                        );
                      },
                    );

                    try {
                      // Wait for the asynchronous operation to complete
                    await controller.makePayment(context: context, amount: amount, currency: 'USD');
                    } finally {
                      // Close the loading spinner dialog using the key
                      Navigator.of(key.currentContext!).pop();
                    }


                    // Navigator.push(
                    //     context,
                    //     MaterialPageRoute(
                    //       builder: (context) => StripePaymentScreen(
                    //         amount: amount,
                    //       ),
                    //     ));

                    print(state.selectedAmount);
                  },
                ),
              ),
            ],
          ),
        ],
      );
    },
  );
}
