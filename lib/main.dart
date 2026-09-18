import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'الأيوبي - الجرد اليومي',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.red,
          primary: Colors.red[800],
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const InventoryScreen()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.redAccent, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.asset(
                  'assets/splash_image.jpg',
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 35),
            const Text(
              'أسطورة الهارثة وشمال البصرة',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InventoryItem {
  final String id;
  final String name;
  final String category;
  int quantity;
  double price;
  final bool isCustomPrice;
  TextEditingController? priceController;

  InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.price,
    this.isCustomPrice = false,
    this.priceController,
  });
}

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late List<InventoryItem> items;
  final TextEditingController _cashController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _initItems();
    _checkAndResetDailyData();
  }

  @override
  void dispose() {
    _cashController.dispose();
    _searchController.dispose();
    for (var item in items) {
      item.priceController?.dispose();
    }
    super.dispose();
  }

  void _initItems() {
    items = [
      InventoryItem(
          id: 'sim_new',
          name: 'شريحة خط جديد',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 3000),
      InventoryItem(
          id: 'sim_replacement',
          name: 'شريحة بدل ضائع',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'sim_hala',
          name: 'خط زيارة هله لاين',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),
      InventoryItem(
          id: 'sim_yooz_new',
          name: 'خط يوز الجديد (يووز)',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),
      InventoryItem(
          id: 'sim_gold',
          name: 'سيم كارت الذهبي / الذهبي بلس',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),
      InventoryItem(
          id: 'sim_platinum',
          name: 'خط بلاتينيوم / بلاتينيوم بلس',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),
      InventoryItem(
          id: 'sim_red_platinum',
          name: 'خطوط ريد بلاتينيوم (1 إلى 7)',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),
      InventoryItem(
          id: 'sim_yaqoot',
          name: 'خط ياقوت / ياقوت بلس / ياقوت بلس بلس',
          category: 'الشرائح والخطوط (Sim Cards)',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),

      InventoryItem(
          id: 'card_5k',
          name: 'كارت رصيد 5,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'card_10k',
          name: 'كارت رصيد 10,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'card_15k',
          name: 'كارت رصيد 15,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 15000),
      InventoryItem(
          id: 'card_25k',
          name: 'كارت رصيد 25,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 25000),
      InventoryItem(
          id: 'card_35k',
          name: 'كارت رصيد 35,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 35000),
      InventoryItem(
          id: 'card_50k',
          name: 'كارت رصيد 50,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 50000),
      InventoryItem(
          id: 'card_100k',
          name: 'كارت رصيد 100,000 د.ع',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 100000),
      InventoryItem(
          id: 'direct_transfer',
          name: 'تحويل رصيد مباشر (1,000 د.ع)',
          category: 'الرصيد والتعبئة (Recharge & Balance)',
          quantity: 0,
          price: 1000),

      InventoryItem(
          id: 'red_15_m',
          name: 'RED 15 الشهري (رصيد 45,000 + 200 رسالة)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 15000),
      InventoryItem(
          id: 'red_20_m',
          name: 'RED 20 الشهري (رصيد 72,000 + 200 رسالة)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 20000),
      InventoryItem(
          id: 'red_25_m',
          name: 'RED 25 الشهري (رصيد 108,000 + 200 رسالة)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 25000),
      InventoryItem(
          id: 'red_30_m',
          name: 'RED 30 الشهري (رصيد 144,000 + 500 رسالة)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 30000),
      InventoryItem(
          id: 'red_15_3m',
          name: 'RED 15 (3 أشهر - ادفع شهرين والثالث مجاناً)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 30000),
      InventoryItem(
          id: 'red_20_3m',
          name: 'RED 20 (3 أشهر - ادفع شهرين والثالث مجاناً)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 40000),
      InventoryItem(
          id: 'red_25_3m',
          name: 'RED 25 (3 أشهر - ادفع شهرين والثالث مجاناً)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 50000),
      InventoryItem(
          id: 'red_30_3m',
          name: 'RED 30 (3 أشهر - ادفع شهرين والثالث مجاناً)',
          category: 'عروض RED الشهيرة',
          quantity: 0,
          price: 60000),

      InventoryItem(
          id: 'social_300m_d',
          name: '300MB اليومية (1 يوم - واتساب + فايبر)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 1250),
      InventoryItem(
          id: 'social_600m_d',
          name: '600MB اليومية (1 يوم - واتساب + فايبر)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 2000),
      InventoryItem(
          id: 'social_3g_w',
          name: '3GB الأسبوعية (7 أيام - واتساب + فايبر + فيسبوك)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'social_5g_w',
          name: '5GB الأسبوعية (7 أيام - واتساب + فايبر + فيسبوك + سناب)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 7000),
      InventoryItem(
          id: 'social_5g_m',
          name: '5GB الشهرية (30 يوم - واتساب + فايبر + فيسبوك + سناب)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'social_10g_m',
          name: '10GB الشهرية (30 يوم - واتساب + فايبر + فيسبوك + سناب)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 15000),
      InventoryItem(
          id: 'social_20g_m',
          name: '20GB الشهرية (30 يوم - + يوتيوب)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 25000),
      InventoryItem(
          id: 'social_30g_m',
          name: '30GB الشهرية (30 يوم - + يوتيوب + إنستغرام + تيك توك)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 30000),
      InventoryItem(
          id: 'social_50g_m',
          name: '50GB الشهرية (30 يوم - + يوتيوب + إنستغرام + تيك توك)',
          category: 'باقات فري سوشيال+',
          quantity: 0,
          price: 35000),

      InventoryItem(
          id: 'unl_3g_d',
          name: 'اليومية بلا حدود (3GB بلا حدود - 1 يوم)',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 3000),
      InventoryItem(
          id: 'unl_20g_w',
          name: 'الأسبوعية بلا حدود (20GB بلا حدود - 7 أيام)',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 12000),
      InventoryItem(
          id: 'unl_100g_m',
          name: 'الشهرية بلا حدود (100GB بلا حدود - 30 يوم)',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 40000),
      InventoryItem(
          id: 'unl_monthly_30d',
          name: 'شهري بلا حدود 30 يوم',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 45000),
      InventoryItem(
          id: 'unl_monthly_4w_50k',
          name: 'شهري أربعة أسابيع (50,000 د.ع)',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 50000),
      InventoryItem(
          id: 'unl_250g_m',
          name: 'الشهرية المميزة بلا حدود (250GB بلا حدود - 30 يوم)',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 50000),
      InventoryItem(
          id: 'unl_monthly_4w_60k',
          name: 'شهري أربعة أسابيع (60,000 د.ع)',
          category: 'باقات إنترنت 4G بلا حدود',
          quantity: 0,
          price: 60000),

      InventoryItem(
          id: 'extra_2_8g_w',
          name: 'الأكسترا الأسبوعية (2.8GB + 104 دقيقة - 7 أيام)',
          category: 'باقات الأكسترا (Extra Bundles)',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'extra_5_5g_20d',
          name: 'الأكسترا (5.5GB + 208 دقيقة - 20 يوم)',
          category: 'باقات الأكسترا (Extra Bundles)',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'extra_10g_m',
          name: 'الأكسترا الشهرية (10GB + 375 دقيقة + 2 كوين)',
          category: 'باقات الأكسترا (Extra Bundles)',
          quantity: 0,
          price: 15000),
      InventoryItem(
          id: 'extra_16g_m',
          name: 'الأكسترا الشهرية (16GB + 600 دقيقة + 6 كوين)',
          category: 'باقات الأكسترا (Extra Bundles)',
          quantity: 0,
          price: 20000),
      InventoryItem(
          id: 'extra_24g_m',
          name: 'الأكسترا الشهرية (24GB + 900 دقيقة + 1 كوين)',
          category: 'باقات الأكسترا (Extra Bundles)',
          quantity: 0,
          price: 25000),
      InventoryItem(
          id: 'extra_36g_m',
          name: 'الأكسترا الشهرية (36GB + 1200 دقيقة + 9 كوين)',
          category: 'باقات الأكسترا (Extra Bundles)',
          quantity: 0,
          price: 30000),

      InventoryItem(
          id: 'roam_passport_1g',
          name: 'باقة باسبورت 1GB (3 أيام)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'roam_turkey_1g',
          name: 'باقة تركيا 1GB (3 أيام)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'roam_qatar_5g',
          name: 'باقة قطر 5GB (1 يوم)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 5000),
      InventoryItem(
          id: 'roam_turkey_2g',
          name: 'باقة تركيا 2GB (7 أيام)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'roam_qatar_10g',
          name: 'باقة قطر 10GB (7 أيام)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'roam_passport_2g',
          name: 'باقة باسبورت 2GB (7 أيام)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'roam_turkey_10g',
          name: 'باقة تركيا 10GB (14 يوم)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 20000),
      InventoryItem(
          id: 'roam_iran_uae_d',
          name: 'باقة إيران والإمارات اليومية (1GB + 10 دقائق)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 3000),
      InventoryItem(
          id: 'roam_iran_uae_w',
          name: 'باقة إيران والإمارات الأسبوعية (2GB + 25 دقيقة)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'roam_hajj_d',
          name: 'باقة الحج والعمرة اليومية (1GB + 10 دقائق)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 3000),
      InventoryItem(
          id: 'roam_hajj_w',
          name: 'باقة الحج والعمرة الأسبوعية (2GB + 25 دقيقة)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 10000),
      InventoryItem(
          id: 'roam_inflight_2g',
          name: 'باقة إنترنت داخل الطائرة 2GB (1 يوم)',
          category: 'باقات التجوال الدولي',
          quantity: 0,
          price: 15000),

      InventoryItem(
          id: 'device_myfi',
          name: 'جهاز ماي فاي 4G (MyFi) - مع نقاط نجوم',
          category: 'أجهزة وإكسسوارات الشبكة',
          quantity: 0,
          price: 0,
          isCustomPrice: true,
          priceController: TextEditingController()),
      InventoryItem(
          id: 'device_semi_data',
          name: 'سيمي داتا 30 ألف (Semi Data)',
          category: 'أجهزة وإكسسوارات الشبكة',
          quantity: 0,
          price: 30000),

      _createYoozItem('yooz_5_calls', 'يووز 5 - مكالمات أكثر'),
      _createYoozItem('yooz_5_net', 'يووز 5 - أنترنيت أكثر'),
      _createYoozItem('yooz_5_mix', 'يووز 5 - ميكس'),
      _createYoozItem('yooz_10_calls', 'يووز 10 - مكالمات أكثر'),
      _createYoozItem('yooz_10_net', 'يووز 10 - أنترنيت أكثر'),
      _createYoozItem('yooz_10_mix', 'يووز 10 - ميكس'),
      _createYoozItem('yooz_15_calls', 'يووز 15 - مكالمات أكثر'),
      _createYoozItem('yooz_15_net', 'يووز 15 - أنترنيت أكثر'),
      _createYoozItem('yooz_15_mix', 'يووز 15 - ميكس'),
      _createYoozItem('yooz_20_calls', 'يووز 20 - مكالمات أكثر'),
      _createYoozItem('yooz_20_net', 'يووز 20 - أنترنيت أكثر'),
      _createYoozItem('yooz_20_mix', 'يووز 20 - ميكس'),
      _createYoozItem('yooz_25_calls', 'يووز 25 - مكالمات أكثر'),
      _createYoozItem('yooz_25_net', 'يووز 25 - أنترنيت أكثر'),
      _createYoozItem('yooz_25_mix', 'يووز 25 - ميكس'),
      _createYoozItem('yooz_30_calls', 'يووز 30 - مكالمات أكثر'),
      _createYoozItem('yooz_30_net', 'يووز 30 - أنترنيت أكثر'),
      _createYoozItem('yooz_30_mix', 'يووز 30 - ميكس'),
      _createYoozItem('yooz_40_calls', 'يووز 40 - مكالمات أكثر'),
      _createYoozItem('yooz_40_net', 'يووز 40 - أنترنيت أكثر'),
      _createYoozItem('yooz_40_mix', 'يووز 40 - ميكس'),
      _createYoozItem('yooz_millionaire', 'خط يووز المليوني'),
    ];
  }

  InventoryItem _createYoozItem(String id, String name) {
    return InventoryItem(
      id: id,
      name: name,
      category: 'خدمات يوز',
      quantity: 0,
      price: 0,
      isCustomPrice: true,
      priceController: TextEditingController(),
    );
  }

  Future<void> _checkAndResetDailyData() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final todayString =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final lastSavedDate = prefs.getString('last_inventory_date') ?? '';

    if (lastSavedDate != todayString) {
      for (var item in items) {
        item.quantity = 0;
        await prefs.setInt('qty_${item.id}', 0);
      }
      await prefs.setString('cash_amount', '');
      await prefs.setString('last_inventory_date', todayString);
    } else {
      setState(() {
        for (var item in items) {
          item.quantity = prefs.getInt('qty_${item.id}') ?? 0;
          if (item.isCustomPrice) {
            final savedPrice = prefs.getDouble('price_${item.id}') ?? 0;
            item.price = savedPrice;
            if (savedPrice > 0) {
              item.priceController?.text = savedPrice.toInt().toString();
            }
          }
        }
        _cashController.text = prefs.getString('cash_amount') ?? '';
      });
    }
    setState(() {});
  }

  Future<void> _updateQuantity(InventoryItem item, int delta) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (item.quantity + delta >= 0) {
        item.quantity += delta;
        prefs.setInt('qty_${item.id}', item.quantity);
      }
    });
  }

  Future<void> _updateCustomPrice(InventoryItem item, String val) async {
    final prefs = await SharedPreferences.getInstance();
    final newPrice = double.tryParse(val) ?? 0.0;
    setState(() {
      item.price = newPrice;
    });
    await prefs.setDouble('price_${item.id}', newPrice);
  }

  Future<void> _updateCashAmount(String val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cash_amount', val);
  }

  Future<void> _generatePdfAndFinish() async {
    final pdf = pw.Document();

    final fontData = await rootBundle.load("assets/Cairo-Regular.ttf");
    final boldFontData = await rootBundle.load("assets/Cairo-Bold.ttf");

    final ttfRegular = pw.Font.ttf(fontData);
    final ttfBold = pw.Font.ttf(boldFontData);

    final soldItems = items.where((item) => item.quantity > 0).toList();
    final double calculatedTotal =
        items.fold(0, (sum, item) => sum + (item.quantity * item.price));
    final double cashAmount = double.tryParse(_cashController.text) ?? 0.0;
    final double totalMismatch = cashAmount - calculatedTotal;

    const String noteText = 'لم يتم إضافة السعر';

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        textDirection: pw.TextDirection.rtl,
        build: (pw.Context context) {
          return [
            pw.Container(
              alignment: pw.Alignment.center,
              padding: const pw.EdgeInsets.all(12),
              decoration: const pw.BoxDecoration(
                color: PdfColors.red800,
                borderRadius: pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Text(
                'تقرير الجرد اليومي - تطبيق الأيوبي',
                style: pw.TextStyle(
                  font: ttfBold,
                  fontSize: 18,
                  color: PdfColors.white,
                ),
              ),
            ),
            pw.SizedBox(height: 16),
            soldItems.isEmpty
                ? pw.Center(
                    child: pw.Text(
                      'لا توجد عناصر مجروءة (الكمية صفر للجميع)',
                      style: pw.TextStyle(font: ttfRegular, fontSize: 14),
                    ),
                  )
                : pw.TableHelper.fromTextArray(
                    context: context,
                    border: pw.TableBorder.all(
                        color: PdfColors.grey400, width: 0.8),
                    headerStyle: pw.TextStyle(
                      font: ttfBold,
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                    headerDecoration:
                        const pw.BoxDecoration(color: PdfColors.red700),
                    cellStyle: pw.TextStyle(font: ttfRegular, fontSize: 9),
                    cellAlignment: pw.Alignment.center,
                    headers: [
                      'الفئة',
                      'اسم الخدمة',
                      'العدد',
                      'السعر',
                      'الإجمالي'
                    ],
                    data: soldItems.map((item) {
                      final bool hasPrice = item.price > 0;
                      return [
                        item.category,
                        item.name,
                        '${item.quantity}',
                        hasPrice ? '${item.price.toInt()} د.ع' : noteText,
                        hasPrice
                            ? '${(item.quantity * item.price).toInt()} د.ع'
                            : noteText,
                      ];
                    }).toList(),
                  ),
            pw.SizedBox(height: 20),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('المجموع الحسابي الكلي للجرد:',
                          style: pw.TextStyle(font: ttfBold, fontSize: 11)),
                      pw.Text('${calculatedTotal.toInt()} د.ع',
                          style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 11,
                              color: PdfColors.blue900)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('المبلغ النقدي المستلم:',
                          style: pw.TextStyle(font: ttfRegular, fontSize: 11)),
                      pw.Text('${cashAmount.toInt()} د.ع',
                          style: pw.TextStyle(font: ttfRegular, fontSize: 11)),
                    ],
                  ),
                  pw.SizedBox(height: 6),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('الفارق المالي (العجز / الزيادة):',
                          style: pw.TextStyle(font: ttfBold, fontSize: 11)),
                      pw.Text('${totalMismatch.toInt()} د.ع',
                          style: pw.TextStyle(
                              font: ttfBold,
                              fontSize: 11,
                              color: totalMismatch < 0
                                  ? PdfColors.red900
                                  : PdfColors.green900)),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where((item) {
      return item.name.contains(_searchQuery) ||
          item.category.contains(_searchQuery);
    }).toList();

    final Map<String, List<InventoryItem>> groupedItems = {};
    for (var item in filteredItems) {
      groupedItems.putIfAbsent(item.category, () => []).add(item);
    }

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('نظام جرد مبيعات آسياسيل - الأيوبي',
              style: TextStyle(color: Colors.white, fontSize: 18)),
          backgroundColor: Colors.red[800],
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'بحث عن خدمة أو فئة...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8)),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _cashController,
                keyboardType: TextInputType.number,
                onChanged: _updateCashAmount,
                decoration: const InputDecoration(
                  labelText: 'المبلغ النقدي المستلم (الموجود في الصندوق)',
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: ListView(
                  children: groupedItems.entries.map((entry) {
                    return ExpansionTile(
                      initiallyExpanded: true,
                      title: Text(entry.key,
                          style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[900])),
                      children: entry.value.map((item) {
                        return Card(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              children: [
                                ListTile(
                                  title: Text(item.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  subtitle:
                                      Text('العدد المجروء: ${item.quantity}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                          icon: const Icon(Icons.remove_circle,
                                              color: Colors.red),
                                          onPressed: () =>
                                              _updateQuantity(item, -1)),
                                      Text('${item.quantity}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                      IconButton(
                                          icon: const Icon(Icons.add_circle,
                                              color: Colors.green),
                                          onPressed: () =>
                                              _updateQuantity(item, 1)),
                                    ],
                                  ),
                                ),
                                if (item.isCustomPrice)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16.0, vertical: 4.0),
                                    child: TextField(
                                      controller: item.priceController,
                                      keyboardType: TextInputType.number,
                                      onChanged: (val) =>
                                          _updateCustomPrice(item, val),
                                      decoration: const InputDecoration(
                                        labelText:
                                            'إدخال السعر يدوياً (اختياري)',
                                        hintText: 'اتركه فارغاً ليكون بدون سعر',
                                        isDense: true,
                                        border: OutlineInputBorder(),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[800],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _generatePdfAndFinish,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text(
                    'طباعة وتصدير تقرير الجرد (PDF)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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