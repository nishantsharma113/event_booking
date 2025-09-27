// Manage turfs screen
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/turf.dart';
import '../../providers/turf_provider.dart';

class ManageTurfsScreen extends StatelessWidget {
  const ManageTurfsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TurfProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Turfs')),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final created = await showDialog<Turf>(
            context: context,
            builder: (context) => _TurfDialog(),
          );
          if (created != null) {
            await provider.addTurf(created);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                FilledButton.icon(
                  onPressed: () => provider.loadTurfs(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                ),
                const SizedBox(width: 12),
                if (provider.isLoading) const CircularProgressIndicator(),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Price/hr')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: [
                    for (final t in provider.turfs)
                      DataRow(
                        cells: [
                          DataCell(Text(t.name)),
                          DataCell(Text(t.location)),
                          DataCell(
                            Text('₹${t.pricePerHour.toStringAsFixed(0)}'),
                          ),
                          DataCell(
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () async {
                                    final updated = await showDialog<Turf>(
                                      context: context,
                                      builder: (context) =>
                                          _TurfDialog(existing: t),
                                    );
                                    if (updated != null) {
                                      await provider.updateTurfItem(updated);
                                    }
                                  },
                                  icon: const Icon(Icons.edit),
                                ),
                                IconButton(
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Delete turf?'),
                                        content: Text(
                                          'Delete ${t.name}? This cannot be undone.',
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
                                      await provider.deleteTurfById(t.id);
                                    }
                                  },
                                  icon: const Icon(Icons.delete),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TurfDialog extends StatefulWidget {
  final Turf? existing;
  const _TurfDialog({this.existing});

  @override
  State<_TurfDialog> createState() => _TurfDialogState();
}

class _TurfDialogState extends State<_TurfDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _name;
  late TextEditingController _location;
  late TextEditingController _price;
  late TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.existing?.name ?? '');
    _location = TextEditingController(text: widget.existing?.location ?? '');
    _price = TextEditingController(
      text: widget.existing?.pricePerHour.toString() ?? '',
    );
    _description = TextEditingController(
      text: widget.existing?.description ?? '',
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _location.dispose();
    _price.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'Add Turf' : 'Edit Turf'),
      content: SizedBox(
        width: 420,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(labelText: 'Location'),
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              TextFormField(
                controller: _price,
                decoration: const InputDecoration(labelText: 'Price / hour'),
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Required';
                  final d = double.tryParse(v);
                  if (d == null || d <= 0) return 'Enter valid price';
                  return null;
                },
              ),
              TextFormField(
                controller: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Images upload (coming soon)',
                  style: TextStyle(color: Colors.grey),
                ),
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
            final turf = Turf(
              id: widget.existing?.id ?? 'temp',
              name: _name.text.trim(),
              location: _location.text.trim(),
              pricePerHour: double.parse(_price.text.trim()),
              description: _description.text.trim().isEmpty
                  ? null
                  : _description.text.trim(),
              images: const [],
            );
            Navigator.pop(context, turf);
          },
          child: Text(widget.existing == null ? 'Add' : 'Save'),
        ),
      ],
    );
  }
}
