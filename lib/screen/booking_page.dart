import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/booking.dart';
import '../models/provider.dart';
import '../state/app_state.dart';
import '../utils/booking_rules.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.provider});
  final ProviderProfile provider;
  @override
  State<BookingPage> createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final formKey = GlobalKey<FormState>();
  final customer = TextEditingController();
  final phone = TextEditingController();
  final address = TextEditingController();
  final description = TextEditingController();
  DateTime? date;
  String? slot;
  int hours = 1;
  final slots = const ['8–10 AM', '10 AM–12 PM', '1–3 PM', '3–5 PM'];
  @override
  void dispose() { customer.dispose(); phone.dispose(); address.dispose(); description.dispose(); super.dispose(); }
  bool _dateAllowed(DateTime value) => value.weekday != DateTime.sunday && value.difference(DateTime.now()).inHours >= 24 && value.difference(DateTime.now()).inDays <= 30;
  Future<void> _pickDate() async {
    final picked = await showDatePicker(context: context, firstDate: DateTime.now().add(const Duration(days: 1)), lastDate: DateTime.now().add(const Duration(days: 30)), initialDate: DateTime.now().add(const Duration(days: 1)));
    if (picked != null && _dateAllowed(picked)) setState(() => date = picked);
  }
  Future<void> _submit() async {
    if (!formKey.currentState!.validate() || date == null || slot == null) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete every field.'))); return; }
    final state = context.read<AppState>();
    final booking = Booking(id: 'FX-${_dateId(date!)}-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}', providerId: widget.provider.id, providerName: widget.provider.name, category: widget.provider.categoryId, date: date!, slot: slot!, customerName: customer.text.trim(), phone: phone.text.trim(), address: address.text.trim(), hours: hours, description: description.text.trim(), total: calculateTotal(hourlyRate: widget.provider.hourlyRate, hours: hours, date: date!));
    try {
      await state.addBooking(booking);
      if (!mounted) return;
      await showDialog<void>(context: context, builder: (_) => AlertDialog(title: const Text('Booking confirmed'), content: Text('Your booking ID is ${booking.id}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Done'))]));
      if (mounted) Navigator.pop(context);
    } on StateError catch (error) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error.message))); }
  }
  String _dateId(DateTime value) => '${value.year}${value.month.toString().padLeft(2, '0')}${value.day.toString().padLeft(2, '0')}';
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final total = date == null ? 500 + widget.provider.hourlyRate * hours : calculateTotal(hourlyRate: widget.provider.hourlyRate, hours: hours, date: date!);
    return Scaffold(appBar: AppBar(title: const Text('Book a service')), body: Form(key: formKey, child: ListView(padding: const EdgeInsets.all(20), children: [
      Text('Booking with ${widget.provider.name}', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      const SizedBox(height: 18),
      TextFormField(controller: customer, decoration: const InputDecoration(labelText: 'Customer name'), validator: (v) => v == null || !RegExp(r'^[a-zA-Z ]{3,}$').hasMatch(v.trim()) ? 'Use at least 3 letters' : null),
      const SizedBox(height: 12),
      TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number'), validator: (v) => v == null || !isValidPhone(v) ? 'Use 07XXXXXXXX or +947XXXXXXXX' : null),
      const SizedBox(height: 12),
      TextFormField(controller: address, maxLines: 2, decoration: const InputDecoration(labelText: 'Address'), validator: (v) => v == null || v.trim().length < 10 ? 'Enter at least 10 characters' : null),
      const SizedBox(height: 16),
      OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.event), label: Text(date == null ? 'Choose date' : '${date!.day}/${date!.month}/${date!.year}')),
      const SizedBox(height: 14),
      Text('Time slot', style: Theme.of(context).textTheme.titleMedium),
      Wrap(spacing: 8, children: slots.map((item) { final available = date == null || state.isSlotFree(widget.provider.id, date!, item); return ChoiceChip(label: Text(item), selected: slot == item, onSelected: available ? (_) => setState(() => slot = item) : null); }).toList()),
      const SizedBox(height: 14),
      Row(children: [const Text('Estimated hours'), IconButton(onPressed: hours > 1 ? () => setState(() => hours--) : null, icon: const Icon(Icons.remove_circle_outline)), Text('$hours'), IconButton(onPressed: hours < 8 ? () => setState(() => hours++) : null, icon: const Icon(Icons.add_circle_outline))]),
      TextFormField(controller: description, maxLines: 3, maxLength: 300, decoration: const InputDecoration(labelText: 'Job description'), validator: (v) => v == null || v.trim().length < 10 ? 'Enter at least 10 characters' : null),
      const SizedBox(height: 14),
      Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(children: [Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Labour'), Text('LKR ${widget.provider.hourlyRate * hours}')]), const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Visiting charge'), Text('LKR 500')]), if (date?.weekday == DateTime.saturday) Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Saturday surcharge'), Text('LKR ${(widget.provider.hourlyRate * hours * .15).round()}')]), const Divider(), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Total', style: TextStyle(fontWeight: FontWeight.bold)), Text('LKR $total', style: const TextStyle(fontWeight: FontWeight.bold))])]))),
      const SizedBox(height: 12),
      FilledButton(onPressed: _submit, child: const Text('Confirm booking')),
    ])));
  }
}
