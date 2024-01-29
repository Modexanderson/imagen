
import 'package:flutter/material.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import '../models/entitlement.dart';

class RevenueCatProvider extends ChangeNotifier {
  RevenueCatProvider() {
    init();
  }

  final _entitlement = Entitlement.free;
  Entitlement get entitlement => _entitlement;

  Future init() async {
    Purchases.addCustomerInfoUpdateListener((customerInfo) {
      updataCustomerStatus();
    });
  }

  Future updataCustomerStatus() async {
    final customerInfo = await Purchases.getCustomerInfo();

    final entitlements = customerInfo.entitlements.active.values.toList();

    entitlements.isEmpty ? Entitlement.free : Entitlement.allCourses;

    notifyListeners();  
  }
}