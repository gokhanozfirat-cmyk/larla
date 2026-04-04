import 'dart:async';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import '../l10n/app_strings.dart';

class SupportPage extends StatefulWidget {
  const SupportPage({super.key});

  @override
  State<SupportPage> createState() => _SupportPageState();
}

class _SupportPageState extends State<SupportPage> {
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _loading = true;

  // Google Play Console'da tanımlayacağınız ürün ID'leri
  static const Set<String> _productIds = {
    'bronze_supporter', // Bronz Destekçi - 50 TL
    'silver_supporter', // Gümüş Destekçi - 250 TL
    'gold_supporter', // Altın Destekçi - 1000 TL
    'diamond_supporter', // Elmas Destekçi - 10000 TL
  };

  Map<String, SupportPackage> _packageInfo(AppStrings t) {
    return {
      'bronze_supporter': SupportPackage(
        name: t.supportPackageName('bronze_supporter'),
        icon: Icons.workspace_premium,
        color: const Color(0xFFCD7F32),
        description: t.supportPackageDescription('bronze_supporter'),
        price: '50 TL',
      ),
      'silver_supporter': SupportPackage(
        name: t.supportPackageName('silver_supporter'),
        icon: Icons.workspace_premium,
        color: Colors.grey.shade400,
        description: t.supportPackageDescription('silver_supporter'),
        price: '250 TL',
      ),
      'gold_supporter': SupportPackage(
        name: t.supportPackageName('gold_supporter'),
        icon: Icons.workspace_premium,
        color: const Color(0xFFFFD700),
        description: t.supportPackageDescription('gold_supporter'),
        price: '1.000 TL',
      ),
      'diamond_supporter': SupportPackage(
        name: t.supportPackageName('diamond_supporter'),
        icon: Icons.diamond,
        color: const Color(0xFFB9F2FF),
        description: t.supportPackageDescription('diamond_supporter'),
        price: '10.000 TL',
      ),
    };
  }

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Satın alma stream'ini dinle
    final purchaseUpdated = _inAppPurchase.purchaseStream;
    _subscription = purchaseUpdated.listen(
      _onPurchaseUpdate,
      onDone: () => _subscription.cancel(),
      onError: (error) => print('Purchase stream error: $error'),
    );

    // Store mevcut mu kontrol et
    _isAvailable = await _inAppPurchase.isAvailable();

    if (_isAvailable) {
      await _loadProducts();
    }

    setState(() {
      _loading = false;
    });
  }

  Future<void> _loadProducts() async {
    final response = await _inAppPurchase.queryProductDetails(_productIds);

    if (response.error != null) {
      print('Error loading products: ${response.error}');
    }

    if (response.notFoundIDs.isNotEmpty) {
      print('Products not found: ${response.notFoundIDs}');
    }

    setState(() {
      _products = response.productDetails;
      // Fiyata göre sırala
      _products.sort((a, b) {
        final order = [
          'bronze_supporter',
          'silver_supporter',
          'gold_supporter',
          'diamond_supporter'
        ];
        return order.indexOf(a.id).compareTo(order.indexOf(b.id));
      });
    });
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        _showLoadingDialog();
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          _hideLoadingDialog();
          _showErrorDialog(
            purchaseDetails.error?.message ??
                AppStrings.of(context).scheduleError,
          );
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          _hideLoadingDialog();
          _showThankYouDialog(purchaseDetails.productID);
        }

        if (purchaseDetails.pendingCompletePurchase) {
          _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _hideLoadingDialog() {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  void _showErrorDialog(String message) {
    final t = AppStrings.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.supportError),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  void _showThankYouDialog(String productId) {
    final t = AppStrings.of(context);
    final package = _packageInfo(t)[productId];
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.favorite, color: Colors.red),
            const SizedBox(width: 8),
            Text(t.thankYou),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              package?.icon ?? Icons.workspace_premium,
              size: 64,
              color: package?.color ?? Colors.amber,
            ),
            const SizedBox(height: 16),
            Text(
              t.supportNowYouAre(package?.name ?? t.supporter),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              t.supportThanksBody,
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(t.ok),
          ),
        ],
      ),
    );
  }

  Future<void> _buyProduct(ProductDetails product) async {
    final purchaseParam = PurchaseParam(productDetails: product);
    // Consumable olarak satın al (tekrar satın alınabilir)
    await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppStrings.of(context);
    final packageInfo = _packageInfo(t);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.support),
        backgroundColor: Colors.green,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green, Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.favorite,
                      size: 80,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      t.supportPageTitle,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.supportPageSubtitle,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.green.shade800,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Her durumda paketleri göster
                    if (_products.isNotEmpty)
                      // Yüklenen ürünleri göster
                      ..._products.map((product) => _buildSupportCard(
                            productId: product.id,
                            package: packageInfo[product.id]!,
                            product: product,
                          ))
                    else
                      // Ürünler yüklenemezse varsayılan kartları göster
                      ...packageInfo.entries.map((entry) => _buildSupportCard(
                            productId: entry.key,
                            package: entry.value,
                            product: null,
                          )),
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Text(
                      '💚 ${t.supportFooter}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSupportCard({
    required String productId,
    required SupportPackage package,
    ProductDetails? product,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: package.color, width: 2),
      ),
      child: InkWell(
        onTap: () {
          if (product != null && _isAvailable) {
            _buyProduct(product);
          } else {
            // Mağaza kullanılamıyorsa bilgi göster
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(AppStrings.of(context).purchaseUnavailable),
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: package.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  package.icon,
                  size: 36,
                  color: package.color,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      package.name,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: package.color.computeLuminance() > 0.5
                            ? Colors.black87
                            : package.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      package.description,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: package.color,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  product?.price ?? AppStrings.of(context).playPriceLoading,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: package.color.computeLuminance() > 0.5
                        ? Colors.black87
                        : Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportPackage {
  final String name;
  final IconData icon;
  final Color color;
  final String description;
  final String price;

  SupportPackage({
    required this.name,
    required this.icon,
    required this.color,
    required this.description,
    required this.price,
  });
}
