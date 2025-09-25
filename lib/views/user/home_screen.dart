// User home screen
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../providers/turf_provider.dart';
import '../../models/turf.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _sortBy = 'name';
  double _maxPrice = 2000;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
    
    // Load turfs when home screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TurfProvider>().loadTurfs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Turf> get _filteredTurfs {
    final turfProvider = context.watch<TurfProvider>();
    var turfs = turfProvider.turfs.where((turf) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final matchesSearch = turf.name.toLowerCase().contains(_searchQuery) ||
            turf.location.toLowerCase().contains(_searchQuery) ||
            (turf.description?.toLowerCase().contains(_searchQuery) ?? false);
        if (!matchesSearch) return false;
      }

      // Price filter
      if (turf.pricePerHour > _maxPrice) return false;

      return true;
    }).toList();

    // Sort
    turfs.sort((a, b) {
      switch (_sortBy) {
        case 'price_low':
          return a.pricePerHour.compareTo(b.pricePerHour);
        case 'price_high':
          return b.pricePerHour.compareTo(a.pricePerHour);
        case 'rating':
          return b.rating.compareTo(a.rating);
        default:
          return a.name.compareTo(b.name);
      }
    });

    return turfs;
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final crossAxisCount = isWide ? 4 : 2;
    final turfProvider = context.watch<TurfProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your turf'),
        actions: [
          IconButton(
            onPressed: () => turfProvider.loadTurfs(),
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh turfs',
          ),
          IconButton(
            onPressed: () => _showFilterDialog(),
            icon: const Icon(Icons.filter_alt_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search turfs by name, location...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        onPressed: () {
                          _searchController.clear();
                        },
                        icon: const Icon(Icons.clear),
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Active filters
            if (_searchQuery.isNotEmpty || _maxPrice < 2000 || _sortBy != 'name')
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (_searchQuery.isNotEmpty)
                    Chip(
                      label: Text('Search: $_searchQuery'),
                      onDeleted: () => _searchController.clear(),
                    ),
                  if (_maxPrice < 2000)
                    Chip(
                      label: Text('Max: ₹${_maxPrice.toStringAsFixed(0)}'),
                      onDeleted: () => setState(() => _maxPrice = 2000),
                    ),
                  if (_sortBy != 'name')
                    Chip(
                      label: Text('Sort: ${_getSortLabel(_sortBy)}'),
                      onDeleted: () => setState(() => _sortBy = 'name'),
                    ),
                ],
              ),
            
            const SizedBox(height: 16),
            
            // Results count
            Text(
              '${_filteredTurfs.length} turfs found',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (turfProvider.errorMessage != null)
              Container(
                padding: const EdgeInsets.all(8),
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: Colors.red.shade600, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Error: ${turfProvider.errorMessage}',
                        style: TextStyle(color: Colors.red.shade600, fontSize: 12),
                      ),
                    ),
                    TextButton(
                      onPressed: () => turfProvider.loadTurfs(),
                      child: const Text('Retry', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            
            // Turfs grid
            Expanded(
              child: turfProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredTurfs.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text('No turfs found', style: TextStyle(fontSize: 18)),
                              Text('Try adjusting your search or filters'),
                            ],
                          ),
                        )
                      : GridView.builder(
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            childAspectRatio: isWide ? 1.6 : 0.9,
                          ),
                          itemCount: _filteredTurfs.length,
                          itemBuilder: (context, index) {
                            final turf = _filteredTurfs[index];
                            return _TurfCard(
                              turf: turf,
                              onTap: () => context.go('/turf/${turf.id}'),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (i) {
          if (i == 1) context.go('/my-bookings');
          if (i == 2) context.go('/profile');
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.event_note_outlined), label: 'Bookings'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }


  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Filter & Sort'),
          content: SizedBox(
            width: 300,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Sort options
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Sort by:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  initialValue: _sortBy,
                  items: const [
                    DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
                    DropdownMenuItem(value: 'price_low', child: Text('Price: Low to High')),
                    DropdownMenuItem(value: 'price_high', child: Text('Price: High to Low')),
                    DropdownMenuItem(value: 'rating', child: Text('Rating')),
                  ],
                  onChanged: (value) {
                    setDialogState(() => _sortBy = value ?? 'name');
                  },
                ),
                const SizedBox(height: 16),
                
                // Price filter
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Max Price:', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 8),
                Slider(
                  value: _maxPrice,
                  min: 100,
                  max: 2000,
                  divisions: 19,
                  label: '₹${_maxPrice.toStringAsFixed(0)}',
                  onChanged: (value) {
                    setDialogState(() => _maxPrice = value);
                  },
                ),
                Text('₹${_maxPrice.toStringAsFixed(0)} per hour'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _sortBy = 'name';
                  _maxPrice = 2000;
                });
                Navigator.pop(context);
              },
              child: const Text('Reset'),
            ),
            FilledButton(
              onPressed: () {
                setState(() {});
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  String _getSortLabel(String sortBy) {
    switch (sortBy) {
      case 'price_low':
        return 'Price: Low to High';
      case 'price_high':
        return 'Price: High to Low';
      case 'rating':
        return 'Rating';
      default:
        return 'Name A-Z';
    }
  }
}

class _TurfCard extends StatelessWidget {
  final Turf turf;
  final VoidCallback onTap;

  const _TurfCard({
    required this.turf,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Card(
        clipBehavior: Clip.hardEdge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                color: Colors.green.shade100,
                child: const Center(child: Icon(Icons.image, size: 48)),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(turf.name, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.place, size: 16),
                      const SizedBox(width: 4),
                      Expanded(child: Text(turf.location, maxLines: 1, overflow: TextOverflow.ellipsis)),
                    ],
                  ),
                  if (turf.description != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      turf.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('₹${turf.pricePerHour.toStringAsFixed(0)}/hr', style: const TextStyle(fontWeight: FontWeight.w600)),
                      Row(children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(turf.rating.toStringAsFixed(1)),
                      ]),
                    ],
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