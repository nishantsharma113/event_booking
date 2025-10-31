// Manage slots screen
import 'package:event_booking/core/utils/library.dart';


import '../../providers/slot_provider.dart';

import '../../models/slot.dart';

class ManageSlotsScreen extends StatelessWidget {
  const ManageSlotsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final slotProv = context.watch<SlotProvider>();
    final turfProv = context.watch<TurfProvider>();

    final monthStart = slotProv.visibleMonth;
    final monthLabel = '${_monthName(monthStart.month)} ${monthStart.year}';

    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.canPop()
              : context.go('/admin/dashboard'),
        ),
        title: const Text('Manage Slots'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: slotProv.selectedTurfId,
                    hint: const Text('Select turf'),
                    items: [
                      for (final t in turfProv.turfs)
                        DropdownMenuItem(value: t.id, child: Text(t.name)),
                    ],
                    onChanged: (v) {
                      slotProv.setTurf(v);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                FilledButton.icon(
                  onPressed: slotProv.selectedTurfId == null
                      ? null
                      : () => slotProv.loadSlots(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Load'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                IconButton(
                  onPressed: () {
                    final prev = DateTime(
                      monthStart.year,
                      monthStart.month - 1,
                      1,
                    );
                    slotProv.setMonth(prev);
                    slotProv.loadSlots();
                  },
                  icon: const Icon(Icons.chevron_left),
                ),
                Text(
                  monthLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                  onPressed: () {
                    final next = DateTime(
                      monthStart.year,
                      monthStart.month + 1,
                      1,
                    );
                    slotProv.setMonth(next);
                    slotProv.loadSlots();
                  },
                  icon: const Icon(Icons.chevron_right),
                ),
                const Spacer(),
                FilledButton.icon(
                  onPressed: slotProv.selectedTurfId == null
                      ? null
                      : () async {
                          final created = await showDialog<Slot>(
                            context: context,
                            builder: (_) =>
                                _SlotDialog(turfId: slotProv.selectedTurfId!),
                          );
                          if (created != null) {
                            await slotProv.addSlot(created);
                          }
                        },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Slot'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: slotProv.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      children: [
                        for (final s in slotProv.slots)
                          Card(
                            child: ListTile(
                              title: Text(
                                '${s.date.toString().substring(0, 10)}  •  ${s.timeRange}',
                              ),
                              subtitle: Text(
                                '₹${s.price.toStringAsFixed(0)}  •  ${s.isBooked ? 'Booked' : 'Available'}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      final updated = await showDialog<Slot>(
                                        context: context,
                                        builder: (_) => _SlotDialog(
                                          existing: s,
                                          turfId: s.turfId,
                                        ),
                                      );
                                      if (updated != null) {
                                        await slotProv.updateSlotItem(updated);
                                      }
                                    },
                                    icon: const Icon(Icons.edit),
                                  ),
                                  IconButton(
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('Delete slot?'),
                                          content: const Text(
                                            'This cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel'),
                                            ),
                                            FilledButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (confirm == true) {
                                        await slotProv.deleteSlotById(s.id);
                                      }
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SlotDialog extends StatefulWidget {
  final Slot? existing;
  final String turfId;
  const _SlotDialog({this.existing, required this.turfId});

  @override
  State<_SlotDialog> createState() => _SlotDialogState();
}

class _SlotDialogState extends State<_SlotDialog> {
  final _formKey = GlobalKey<FormState>();
  late DateTime _date;
  late TextEditingController _timeRange;
  late TextEditingController _price;
  bool _isBooked = false;

  @override
  void initState() {
    super.initState();
    _date = widget.existing?.date ?? DateTime.now();
    _timeRange = TextEditingController(
      text: widget.existing?.timeRange ?? '10:00 - 11:00',
    );
    _price = TextEditingController(
      text: widget.existing?.price.toString() ?? '0',
    );
    _isBooked = widget.existing?.isBooked ?? false;
  }

  @override
  void dispose() {
    _timeRange.dispose();
    _price.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Slot' : 'Edit Slot'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(child: Text('${_date.toLocal()}'.split(' ')[0])),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: _date,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) setState(() => _date = picked);
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              TextFormField(
                controller: _timeRange,
                decoration: const InputDecoration(
                  labelText: 'Time Range (e.g., 10:00 - 11:00)',
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final d = double.tryParse(v);
                  if (d == null || d <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              CheckboxListTile(
                value: _isBooked,
                onChanged: (v) => setState(() => _isBooked = v ?? false),
                title: const Text('Booked'),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (_formKey.currentState?.validate() != true) return;
            final slot = Slot(
              id: widget.existing?.id ?? 'temp',
              turfId: widget.turfId,
              date: _date,
              timeRange: _timeRange.text.trim(),
              price: double.parse(_price.text.trim()),
              isBooked: _isBooked,
            );
            Navigator.pop(context, slot);
          },
          child: Text(widget.existing == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}

String _monthName(int m) {
  const names = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return names[(m - 1) % 12];
}
