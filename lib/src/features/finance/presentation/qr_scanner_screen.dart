import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../common_widgets/glass_container.dart';
import '../../../constants/app_theme.dart';
import 'package:flutter_pay_upi/flutter_pay_upi_manager.dart';
import 'package:flutter_pay_upi/model/upi_app_model.dart';
import 'dart:io';
import '../domain/finance_models.dart';
import '../data/finance_repository.dart';

class QRScannerScreen extends ConsumerStatefulWidget {
  const QRScannerScreen({super.key});

  @override
  ConsumerState<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends ConsumerState<QRScannerScreen> {
  MobileScannerController cameraController = MobileScannerController();
  String? scannedData;
  bool showPaymentSheet = false;
  List<UpiApp> installedUpiApps = [];
  final _amountController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInstalledUpiApps();
  }

  Future<void> _loadInstalledUpiApps() async {
    try {
      List<UpiApp> apps = [];
      if (Platform.isAndroid) {
        apps = await FlutterPayUpiManager.getListOfAndroidUpiApps();
      } else if (Platform.isIOS) {
        // Handle iOS apps if needed, though they return a different model
      }
      if (mounted) {
        setState(() {
          installedUpiApps = apps;
        });
      }
    } catch (e) {
      debugPrint('Error loading UPI apps: $e');
    }
  }

  @override
  void dispose() {
    cameraController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (showPaymentSheet && scannedData != null) {
      return _buildPaymentSheet();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() {
                    scannedData = barcode.rawValue;
                    showPaymentSheet = true;
                  });
                  break;
                }
              }
            },
          ),
          
          // Scanner Overlay
          CustomPaint(
            painter: ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),
          
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 28),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        'Scan QR',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const SizedBox(width: 48), // Spacer
                    ],
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.only(bottom: 60),
                  child: Text(
                    'Align QR code within the frame',
                    style: GoogleFonts.outfit(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSheet() {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () {
                          setState(() {
                            showPaymentSheet = false;
                            scannedData = null;
                            _amountController.clear();
                          });
                        },
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Send Payment',
                        style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  GlassContainer(
                    blur: 15,
                    opacity: 0.1,
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getPayeeName(scannedData ?? ''),
                          style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getPayeeVpa(scannedData ?? ''),
                          style: GoogleFonts.outfit(fontSize: 12, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  GlassContainer(
                    blur: 15,
                    opacity: 0.1,
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Amount', style: GoogleFonts.outfit(fontSize: 14, color: Colors.white60)),
                        TextField(
                          controller: _amountController,
                          style: GoogleFonts.outfit(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                          decoration: const InputDecoration(
                            prefixText: '₹ ',
                            prefixStyle: TextStyle(color: Colors.white, fontSize: 32),
                            hintText: '0.00',
                            border: InputBorder.none,
                            hintStyle: TextStyle(color: Colors.white24),
                          ),
                          keyboardType: TextInputType.number,
                          autofocus: true,
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  Text('Select App to Pay', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
                  const SizedBox(height: 16),
                  
                  if (installedUpiApps.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text('No UPI apps found on this device', style: GoogleFonts.outfit(color: Colors.white54)),
                      ),
                    )
                  else
                    ...installedUpiApps.map((app) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _buildUPIAppButton(app),
                    )),
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUPIAppButton(UpiApp app) {
    return GlassContainer(
      blur: 10,
      opacity: 0.08,
      padding: const EdgeInsets.all(16),
      onTap: () => _initiatePayment(app),
      child: Row(
        children: [
          if (app.icon != null)
            Image.memory(
              app.icon!,
              width: 32,
              height: 32,
            )
          else
            const Icon(Icons.payment, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Text(app.name ?? 'UPI App', style: GoogleFonts.outfit(fontSize: 16, color: Colors.white)),
          const Spacer(),
          const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        ],
      ),
    );
  }

  void _initiatePayment(UpiApp app) {
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter an amount')));
      return;
    }
    
    // QR code data is often a URI like upi://pay?pa=...&pn=...
    final payeeVpa = _getPayeeVpa(scannedData!);
    final payeeName = _getPayeeName(scannedData!);

    FlutterPayUpiManager.startPayment(
      paymentApp: app.app!,
      payeeVpa: payeeVpa, 
      payeeName: payeeName,
      transactionId: 'TR${DateTime.now().millisecondsSinceEpoch}',
      payeeMerchantCode: '',
      description: 'Payment via Aura App',
      amount: _amountController.text,
      currency: 'INR',
      response: (upiResponse, amount) {
        debugPrint('Payment Success: ${upiResponse.status}');
        if (upiResponse.status == 'SUCCESS') {
          // Persist the expense to Firestore
          ref.read(financeRepositoryProvider).addExpense(
            Expense(
              id: '',
              title: 'UPI Payment: $payeeName',
              amount: double.tryParse(_amountController.text) ?? 0,
              category: ExpenseCategory.other,
              date: DateTime.now(),
            ),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Payment Status: ${upiResponse.status}')));
        if (upiResponse.status == 'SUCCESS') {
          Navigator.pop(context);
        }
      },
      error: (errorMessage) {
        debugPrint('Payment Error: $errorMessage');
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $errorMessage')));
      },
    );
  }

  String _getPayeeVpa(String data) {
    try {
      final uri = Uri.parse(data);
      return uri.queryParameters['pa'] ?? data;
    } catch (e) {
      return data;
    }
  }

  String _getPayeeName(String data) {
    try {
      final uri = Uri.parse(data);
      final pn = uri.queryParameters['pn'];
      if (pn != null && pn.isNotEmpty) {
        return Uri.decodeComponent(pn);
      }
      return 'Unknown Recipient';
    } catch (e) {
      return 'Unknown Recipient';
    }
  }
}

class ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final scanArea = size.shortestSide * 0.7;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanArea,
      height: scanArea,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, backgroundPaint);

    final borderPaint = Paint()
      ..color = AppTheme.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)), borderPaint);
    
    // Add corners for better visual
    final cornerPaint = Paint()
      ..color = AppTheme.indigo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    
    const cornerLength = 30.0;
    
    // Top Left
    canvas.drawLine(Offset(rect.left, rect.top + cornerLength), Offset(rect.left, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.top), Offset(rect.left + cornerLength, rect.top), cornerPaint);
    
    // Top Right
    canvas.drawLine(Offset(rect.right - cornerLength, rect.top), Offset(rect.right, rect.top), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.top), Offset(rect.right, rect.top + cornerLength), cornerPaint);
    
    // Bottom Left
    canvas.drawLine(Offset(rect.left, rect.bottom - cornerLength), Offset(rect.left, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.left, rect.bottom), Offset(rect.left + cornerLength, rect.bottom), cornerPaint);
    
    // Bottom Right
    canvas.drawLine(Offset(rect.right - cornerLength, rect.bottom), Offset(rect.right, rect.bottom), cornerPaint);
    canvas.drawLine(Offset(rect.right, rect.bottom), Offset(rect.right, rect.bottom - cornerLength), cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
