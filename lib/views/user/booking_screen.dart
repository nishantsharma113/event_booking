// Booking screen
import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  DateTime date = DateTime.now();
  String? selectedSlot;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _startTestPayment() {
    var options = {
      'key': 'rzp_test_1DP5mmOlF5G5ag', // Razorpay test key
      'amount': 120000, // Amount in paise (₹1200)
      'name': 'Green Field Arena',
      'description': 'Test Booking Payment',
      'prefill': {'contact': '9123456789', 'email': 'test@razorpay.com'},
      'external': {'wallets': ['paytm']}
    };
    _razorpay.open(options);
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Successful: ${response.paymentId}')),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment Failed: ${response.message}')),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('External Wallet: ${response.walletName}')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Booking')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isWide
            ? Row(
                children: [
                  Expanded(child: _BookingSummary(date: date, slot: selectedSlot)),
                  const SizedBox(width: 24),
                  Expanded(child: _SlotPicker(onChange: (s) => setState(() => selectedSlot = s))),
                ],
              )
            : ListView(
                children: [
                  _BookingSummary(date: date, slot: selectedSlot),
                  const SizedBox(height: 16),
                  _SlotPicker(onChange: (s) => setState(() => selectedSlot = s)),
                ],
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton(
            onPressed: selectedSlot == null ? null : _startTestPayment,
            child: const Text('Pay and Book (Razorpay Test)'),
          ),
        ),
      ),
    );
  }
}

class _BookingSummary extends StatelessWidget {
  final DateTime date;
  final String? slot;
  const _BookingSummary({required this.date, required this.slot});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Green Field Arena', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text('Date: ${date.toLocal().toString().split(' ').first}'),
            const SizedBox(height: 8),
            Text('Slot: ${slot ?? '-'}'),
            const SizedBox(height: 8),
            const Text('Total: ₹1200'),
          ],
        ),
      ),
    );
  }
}

class _SlotPicker extends StatelessWidget {
  final ValueChanged<String> onChange;
  const _SlotPicker({required this.onChange});

  @override
  Widget build(BuildContext context) {
    final slots = List.generate(8, (i) => '${10 + i}:00 - ${11 + i}:00');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final s in slots)
              ChoiceChip(
                label: Text(s),
                selected: false,
                onSelected: (_) => onChange(s),
              ),
          ],
        ),
      ),
    );
  }
}

