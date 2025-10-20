import 'dart:async';
import 'dart:io';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'ad_service.dart';

class PurchaseService {
  static final PurchaseService instance = PurchaseService._init();
  PurchaseService._init();

  final InAppPurchase _iap = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  
  static const String _adsRemovedKey = 'ads_removed';
  bool _adsRemoved = false;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];

  bool get adsRemoved => _adsRemoved;
  bool get isAvailable => _isAvailable;
  List<ProductDetails> get products => _products;

  Future<void> initialize() async {
    // Check if IAP is available
    _isAvailable = await _iap.isAvailable();
    
    if (!_isAvailable) {
      print('In-app purchases not available');
      return;
    }

    // Load ads removed status from local storage
    await _loadAdsRemovedStatus();

    // Listen to purchase updates
    _subscription = _iap.purchaseStream.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) {
        print('Purchase stream error: $error');
      },
    );

    // Load products
    await _loadProducts();

    // Restore previous purchases
    await restorePurchases();
  }

  Future<void> _loadAdsRemovedStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _adsRemoved = prefs.getBool(_adsRemovedKey) ?? false;
    AdService.instance.setAdsRemoved(_adsRemoved);
  }

  Future<void> _saveAdsRemovedStatus(bool removed) async {
    _adsRemoved = removed;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_adsRemovedKey, removed);
    AdService.instance.setAdsRemoved(removed);
  }

  Future<void> _loadProducts() async {
    if (!_isAvailable) return;

    final Set<String> productIds = {AppConfig.removeAdsProductId};
    final ProductDetailsResponse response = await _iap.queryProductDetails(productIds);

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    _products = response.productDetails;
  }

  // Handle purchase updates
  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      _handlePurchase(purchase);
    }
  }

  Future<void> _handlePurchase(PurchaseDetails purchase) async {
    if (purchase.status == PurchaseStatus.purchased ||
        purchase.status == PurchaseStatus.restored) {
      // Verify purchase (in production, verify with your backend)
      final bool valid = await _verifyPurchase(purchase);

      if (valid) {
        // Grant entitlement (remove ads)
        if (purchase.productID == AppConfig.removeAdsProductId) {
          await _saveAdsRemovedStatus(true);
        }
      }
    }

    if (purchase.status == PurchaseStatus.error) {
      print('Purchase error: ${purchase.error}');
    }

    // Complete the purchase
    if (purchase.pendingCompletePurchase) {
      await _iap.completePurchase(purchase);
    }
  }

  Future<bool> _verifyPurchase(PurchaseDetails purchase) async {
    // In production, send the purchase to your backend for verification
    // For now, we'll just return true
    return true;
  }

  // Purchase the remove ads product
  Future<bool> purchaseRemoveAds() async {
    if (!_isAvailable) {
      print('In-app purchases not available');
      return false;
    }

    final ProductDetails? productDetails = _products.firstWhere(
      (product) => product.id == AppConfig.removeAdsProductId,
      orElse: () => throw Exception('Product not found'),
    );

    if (productDetails == null) {
      print('Remove ads product not found');
      return false;
    }

    final PurchaseParam purchaseParam = PurchaseParam(
      productDetails: productDetails,
    );

    try {
      final bool success = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );
      return success;
    } catch (e) {
      print('Error purchasing: $e');
      return false;
    }
  }

  // Restore previous purchases
  Future<void> restorePurchases() async {
    if (!_isAvailable) return;

    try {
      await _iap.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
    }
  }

  // Get price of remove ads product
  String? getRemoveAdsPrice() {
    try {
      final product = _products.firstWhere(
        (p) => p.id == AppConfig.removeAdsProductId,
      );
      return product.price;
    } catch (e) {
      return null;
    }
  }

  void dispose() {
    _subscription.cancel();
  }
}
