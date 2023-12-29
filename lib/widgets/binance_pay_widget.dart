// import 'dart:math';

import 'package:binance_pay/binance_pay.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:uuid/uuid.dart';
import 'package:provider/provider.dart';

import '../models/.env.dart';
import 'package:imagen/widgets/snack_bar.dart';
import '../services/authentification_service.dart';
import '../services/database/user_database_helper.dart';
import 'default_progress_indicator.dart';

class BinancePayState extends ChangeNotifier {
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

Future<void> createBinancePayOrder(BuildContext context, double amount) async {
  String userUid = AuthentificationService().currentUser.uid;

  BinancePay pay = BinancePay(
    apiKey: binanceApiKey,
    apiSecretKey: binanceSecretKey,
  );

  String tradeNo = generateMerchantTradeNo();
  String referenceGoodsId = generateReferenceGoodsId();

  RequestBody requestBody = RequestBody(
    merchantTradeNo: tradeNo,
    orderAmount: amount.toString(),
    currency: 'USDT',
    goodsType: '02',
    goodsCategory: '6000',
    referenceGoodsId: referenceGoodsId,
    goodsName: 'Imagen credit',
    goodsDetail: 'Credit purchase for Imagen mobile app',
    terminalType: 'APP',
  );
  OrderResponse response = await pay.createOrder(body: requestBody);
  String prepayId =
      response.data!.prepayId; // Obtain prepayId from the response

  try {
    if (response.status == 'SUCCESS') {
      String deepLink = response.data!.deeplink;
      String universalLink = response.data!.universalUrl;

      if (await canLaunchUrl(Uri.parse(deepLink))) {
        await launchUrl(Uri.parse(deepLink));
        print(deepLink);
      } else {
        if (await canLaunchUrl(Uri.parse(universalLink))) {
          await launchUrl(Uri.parse(universalLink));
        } else {
          ShowSnackBar().showSnackBar(
              context, AppLocalizations.of(context)!.couldNotLaunchBinance);
          print('Could not launch $deepLink');
        }
      }

      // Query the order status using the prepayId
      QueryResponse queryResponse = await pay.queryOrder(
        prepayId: prepayId,
        merchantTradeNo: tradeNo,
      );

      debugPrint(queryResponse.data.status);

      switch (queryResponse.data.status) {
        case 'INITIAL':
          print('Order is in the initial state. Waiting for payment...');
          break;
        case 'PENDING':
          print('Payment is pending. Waiting for completion...');
          break;
        case 'PAID':
          print('Payment successful. Updating user credits...');
          // Update user's credits after successful payment
          await UserDatabaseHelper().updateCreditsAfterPayment(userUid, amount);
          break;
        case 'CANCELED':
          print('Order has been canceled by the user or system.');
          break;
        case 'ERROR':
          print('Error processing the order.');
          break;
        case 'REFUNDING':
          print('Refund process is in progress.');
          break;
        case 'REFUNDED':
          print('Order has been refunded.');
          break;
        case 'EXPIRED':
          print('Order has expired and cannot be paid.');
          break;
        default:
          print('Unknown order status: ${queryResponse.data.status}');
          break;
      }
    } else {
      ShowSnackBar().showSnackBar(
          context, AppLocalizations.of(context)!.errorCreatingBinanceOrder);
      print('Error creating Binance Pay order: ${response.errorMessage}');
    }
  } catch (error) {
    print('Error during Binance Pay order creation: $error');
  } finally {
    // Close the order if necessary
    // Uncomment the following lines if you want to close the order
    // CloseResponse closeResponse = await pay.closeOrder(
    //   prepayId: prepayId,
    //   merchantTradeNo: tradeNo,
    // );
    // debugPrint(closeResponse.status);
  }
}

Widget binancePayWidget() {
  return Consumer<BinancePayState>(
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
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              DefaultProgressIndicator(),
                              SizedBox(height: 16),
                              Text(AppLocalizations.of(context)!
                                  .creatingBinanceOrder),
                            ],
                          ),
                        );
                      },
                    );

                    try {
                      // Wait for the asynchronous operation to complete
                      await createBinancePayOrder(context, amount);
                    } finally {
                      // Close the loading spinner dialog using the key
                      Navigator.of(key.currentContext!).pop();
                    }

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
