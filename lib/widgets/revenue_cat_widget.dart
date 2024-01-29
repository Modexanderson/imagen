import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:uuid/uuid.dart';

import '../api/purchase_api.dart';
import '../services/authentification_service.dart';
import '../services/database/user_database_helper.dart';
import 'default_progress_indicator.dart';

class RenenueCatState extends ChangeNotifier {
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

Widget revenueCatWidget(List<Package> packages) {
  // List<Package> packages = [];

  

  return LayoutBuilder(builder: (context, constraints) {
    return Consumer<RenenueCatState>(
      builder: (context, state, _) {
        return AlertDialog(
          title: const Text('Select Amount'),
          content: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              child: Column(
                // mainAxisSize: MainAxisSize.min,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: packages.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          3, // Adjust the cross axis count as needed
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                      childAspectRatio:
                          (70 / 70), // Adjust the aspect ratio as needed
                    ),
                    itemBuilder: ((context, index) {
                      final package = packages[index];
                      return buildPackage(context, package);
                    }),

                    // children: [
                    // for (var amount in [5, 10, 15, 20, 50, 100])

                    // ],
                  ),

                  const SizedBox(height: 10),
                  // CupertinoTextField(
                  //   controller: state.customAmountController,
                  //   keyboardType: TextInputType.number,
                  //   placeholder: 'Enter Amount',
                  //   inputFormatters: <TextInputFormatter>[
                  //     FilteringTextInputFormatter.allow(
                  //         RegExp(r'^\d+\.?\d{0,2}')),
                  //   ],
                  //   style: const TextStyle(
                  //     fontSize: 16.0,
                  //     color: Colors.black,
                  //   ),
                  //   decoration: BoxDecoration(
                  //     color: Colors.grey[200],
                  //     borderRadius: BorderRadius.circular(8.0),
                  //   ),
                  //   padding: const EdgeInsets.symmetric(
                  //       vertical: 12.0, horizontal: 16.0),
                  //   placeholderStyle: const TextStyle(
                  //     fontSize: 16.0,
                  //     color: Colors.grey,
                  //   ),
                  //   prefix: const Padding(
                  //     padding: EdgeInsets.only(left: 16.0, right: 8.0),
                  //     child: Text(
                  //       '\$',
                  //       style: TextStyle(
                  //         fontSize: 16.0,
                  //         color: Colors.black,
                  //       ),
                  //     ),
                  //   ),
                  //   onTap: () {
                  //     state.updateSelectedAmount(0.0);
                  //   },
                  // )
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
                      final GlobalKey<State> key = GlobalKey<State>();

                     
                      Navigator.of(context).pop();
                      // Show loading spinner while creating Binance Pay order
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            key: key,
                            content: const DefaultProgressIndicator(),
                          );
                        },
                      );

                      try {
                        // Wait for the asynchronous operation to complete
                        // await createBinancePayOrder(context, amount);
                      } finally {
                        // Close the loading spinner dialog using the key
                        Navigator.of(key.currentContext!).pop();
                      }

                      if (kDebugMode) {
                        print(state.selectedAmount);
                      }
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  });
}

Widget buildPackage(BuildContext context, Package package) {
  String userUid = AuthentificationService().currentUser.uid;
  final product = package.storeProduct;

  return GestureDetector(
    onTap: () async {
      final isSuccess = await PurchaseApi.purchasePackage(package);
      if (isSuccess) {
        await UserDatabaseHelper().updateRevenueCatPayment(userUid, package);
      }
    },
    child: SizedBox(
      width: 150,
      height: 60,
      child: Card(
        
        child: SizedBox(
          height: 50,
          child: Center(
            child: Text(
              product.title,
              style: const TextStyle(
                fontSize: 20,
               
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
