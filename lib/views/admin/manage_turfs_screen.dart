// Manage turfs screen
import 'dart:developer';
import 'dart:io';

import 'package:event_booking/core/utils/library.dart';
import 'package:event_booking/core/widgets/custom_image.dart';

class ManageTurfsScreen extends StatefulWidget {
  const ManageTurfsScreen({super.key});

  @override
  State<ManageTurfsScreen> createState() => _ManageTurfsScreenState();
}

class _ManageTurfsScreenState extends State<ManageTurfsScreen> {
  String searchText = '';

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TurfProvider>();
    final List<Turf> filteredTurfs = provider.turfs.where((t) {
      final query = searchText.toLowerCase();
      return t.name.toLowerCase().contains(query) ||
          t.location.toLowerCase().contains(query);
    }).toList();
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.canPop()
              ? context.canPop()
              : context.go('/admin/dashboard'),
        ),
        title: const Text('Manage Turfs'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // final created = await showDialog<Turf>(
          //   context: context,
          //   builder: (context) => _TurfDialog(),
          // );
          // if (created != null) {
          //   await provider.addTurf(created);
          // }

          final created = await showModalBottomSheet<Turf>(
            context: context,
            isScrollControlled: true,
            builder: (context) => _TurfDialog(),
          );
          log("created turf: ${created!.images.toString()}");
          await provider.addTurf(created);
        },
        child: const Icon(Icons.add),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search turfs...',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 0,
                          horizontal: 16,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchText = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  provider.isLoading == false
                      ? IconButton(
                          onPressed: () => provider.loadTurfs(),
                          icon: Icon(Icons.refresh),
                        )
                      : SizedBox(),

                  const SizedBox(width: 12),
                  if (provider.isLoading) const CircularProgressIndicator(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: filteredTurfs.isEmpty
                  ? Center(child: Text('No turfs found.'))
                  : ListView(
                      children: List.generate(filteredTurfs.length, (idx) {
                        final t = filteredTurfs[idx];

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: Container(
                            decoration: ShapeDecoration(
                              color: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              shadows: [
                                BoxShadow(
                                  color: Color(0x0C000000),
                                  blurRadius: 54,
                                  offset: Offset(6, 6),
                                  spreadRadius: 0,
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: t.images!.isNotEmpty
                                            ? Image.network(
                                                t.images!.first.toString(),
                                                width: 70,
                                                height: 70,
                                                fit: BoxFit.cover,
                                              )
                                            : Container(
                                                width: 70,
                                                height: 70,
                                                color: Colors.grey[200],
                                                child: const Icon(
                                                  Icons.image,
                                                  size: 36,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                      const SizedBox(width: 20),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              t.name,
                                              style: Theme.of(
                                                context,
                                              ).textTheme.titleMedium,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              t.location,
                                              style: TextStyle(
                                                color: Colors.grey[700],
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              '₹${t.pricePerHour.toStringAsFixed(0)} / hr',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.green[800],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Tooltip(
                                        message: 'Edit',
                                        child: TextButton(
                                          child: const Text('Edit'),
                                          onPressed: () async {
                                            final updated =
                                                await showModalBottomSheet<
                                                  Turf
                                                >(
                                                  context: context,
                                                  isScrollControlled: true,
                                                  builder: (context) =>
                                                      _TurfDialog(existing: t),
                                                );
                                            if (updated != null) {
                                              await provider.updateTurfItem(
                                                updated,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                      Tooltip(
                                        message: 'Delete',
                                        child: TextButton(
                                          child: const Text('Delete'),
                                          onPressed: () async {
                                            final confirm = await showDialog<bool>(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                title: const Text(
                                                  'Delete turf?',
                                                ),
                                                content: Text(
                                                  'Delete ${t.name}? This cannot be undone.',
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          false,
                                                        ),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  FilledButton(
                                                    onPressed: () =>
                                                        Navigator.pop(
                                                          context,
                                                          true,
                                                        ),
                                                    child: const Text('Delete'),
                                                  ),
                                                ],
                                              ),
                                            );
                                            if (confirm == true) {
                                              await provider.deleteTurfById(
                                                t.id,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
    return Material(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom, // This is crucial!
          left: 16,
          right: 16,
          top: 16,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              spacing: 15,
              children: [
                Text(
                  widget.existing == null ? 'Add Turf' : 'Edit Turf',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
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
                if (widget.existing?.images != null &&
                    widget.existing!.images!.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    children: List.generate(widget.existing!.images!.length, (
                      idx,
                    ) {
                      final imgUrl = widget.existing!.images![idx];
                      return Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.grey,
                                  width: 1.0,
                                ),
                              ),
                              child: CustomImage(
                                imagePath: imgUrl,
                                width: 70,
                                height: 70,
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                          ),

                          IconButton(
                            style: ButtonStyle(
                              padding: WidgetStatePropertyAll<EdgeInsets>(
                                EdgeInsets.all(0),
                              ),
                              minimumSize: WidgetStatePropertyAll<Size>(
                                Size(15, 15),
                              ),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Container(
                              width: 20,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red,
                                  width: 1.0,
                                ),
                              ),
                              child: Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 15,
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                widget.existing!.images!.removeAt(idx);
                              });
                            },
                          ),
                        ],
                      );
                    }),
                  ),
                  const SizedBox(height: 8),
                ],
                FutureBuilder<List<String>>(
                  future: null,
                  builder: (context, snapshot) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ElevatedButton.icon(
                          icon: Icon(Icons.upload),
                          label: Text('Upload Images'),
                          onPressed: () async {
                            // Pick multiple images using image_picker
                            final picker = ImagePicker();
                            final pickedFiles = await picker.pickMultiImage();
                            if (pickedFiles.isNotEmpty) {
                              // For demonstration, just use the file paths as image URLs
                              // In a real app, upload these files to a server and get URLs
                              final newImages = pickedFiles
                                  .map((f) => f.path)
                                  .toList();

                              setState(() {
                                if (widget.existing != null) {
                                  widget.existing!.images!.addAll(newImages);
                                } else {
                                  context.read<TurfProvider>().uploadImages(
                                    newImages,
                                  );
                                  //uploadedImages = newImages;
                                }
                                // For now, just print or use as needed
                                // Example: _uploadedImages.addAll(newImages);
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        if (snapshot.hasData && snapshot.data!.isNotEmpty)
                          Wrap(
                            spacing: 8,
                            children: List.generate(snapshot.data!.length, (
                              idx,
                            ) {
                              final img = snapshot.data![idx];
                              return Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      img,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      // Remove image from list and call setState
                                    },
                                  ),
                                ],
                              );
                            }),
                          ),

                        widget.existing == null
                            ? Consumer<TurfProvider>(
                                builder: (_, controller, _) {
                                  return Wrap(  
                                    spacing: 8,
                                    children: List.generate(
                                      controller.uploadedImages.length,
                                      (idx) {
                                        final img =
                                            controller.uploadedImages[idx];
                                        return Stack(
                                          alignment: Alignment.topRight,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 8.0,
                                                  ),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                  border: Border.all(
                                                    color: Colors.grey,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(8),

                                                  child: Image.file(
                                                    File(img),
                                                    width: 70,
                                                    height: 70,
                                                    fit: BoxFit.cover,
                                                  ),
                                                ),
                                              ),
                                            ),

                                            IconButton(
                                              style: ButtonStyle(
                                                padding:
                                                    WidgetStatePropertyAll<
                                                      EdgeInsets
                                                    >(EdgeInsets.all(0)),
                                                minimumSize:
                                                    WidgetStatePropertyAll<
                                                      Size
                                                    >(Size(15, 15)),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              icon: Container(
                                                width: 20,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(
                                                    color: Colors.red,
                                                    width: 1.0,
                                                  ),
                                                ),
                                                child: Icon(
                                                  Icons.close,
                                                  color: Colors.red,
                                                  size: 15,
                                                ),
                                              ),
                                              onPressed: () {
                                                controller.removeImage(img);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  );
                                },
                              )
                            : SizedBox(),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: () {
                        final provider = context.read<TurfProvider>();
                        if (_formKey.currentState?.validate() != true) return;
                        final turf = Turf(
                          id: widget.existing?.id ?? 'temp',
                          name: _name.text.trim(),
                          location: _location.text.trim(),
                          pricePerHour: double.parse(_price.text.trim()),
                          description: _description.text.trim().isEmpty
                              ? null
                              : _description.text.trim(),
                          images: provider.uploadedImages.isNotEmpty
                              ? provider.uploadedImages
                              : widget.existing?.images ?? [],
                        );
                        Navigator.pop(context, turf);
                      },
                      child: Text(widget.existing == null ? 'Add' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
