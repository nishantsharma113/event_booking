import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../providers/turf_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/booking_provider.dart';
import 'package:go_router/go_router.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  @override
  void initState() {
    super.initState();
    // Ensure admin aggregates are loaded when dashboard opens
    Future.microtask(() {
      if (!mounted) return;
      context.read<AuthProvider>().loadUsers();
      context.read<TurfProvider>().loadTurfs();
      context.read<BookingProvider>().loadAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 900;
    final turfProvider = context.watch<TurfProvider?>();
    final authProvider = context.watch<AuthProvider?>();
    final bookingProvider = context.watch<BookingProvider?>();

    return Scaffold(
      appBar: AppBar(title: const Text("Admin Dashboard")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            // Summary cards
            LayoutBuilder(
              builder: (context, constraints) {
                final cross = isWide ? 4 : 2;
                return GridView.count(
                  crossAxisCount: cross,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 2.6,
                  children: [
                    _SummaryCard(
                      label: 'Total Turfs',
                      value: (turfProvider?.turfs.length ?? 0).toString(),
                      icon: Icons.stadium_outlined,
                    ),
                    _SummaryCard(
                      label: 'Total Bookings',
                      value: (bookingProvider?.totalBookings ?? 0).toString(),
                      icon: Icons.event_available_outlined,
                    ),
                    _SummaryCard(
                      label: 'Total Users',
                      value: (authProvider?.totalUsers ?? 0).toString(),
                      icon: Icons.people_outline,
                    ),
                    _SummaryCard(
                      label: 'Revenue',
                      value: '₹${(bookingProvider?.totalRevenue ?? 0).toStringAsFixed(0)}',
                      icon: Icons.currency_rupee_outlined,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            // Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Monthly Revenue', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 12),
                    AspectRatio(
                      aspectRatio: 16 / 6,
                      child: LineChart(
                        LineChartData(
                          titlesData: FlTitlesData(
                            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, m) {
                              const months = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];
                              final idx = v.toInt();
                              return Padding(padding: const EdgeInsets.only(top: 4), child: Text(months[idx % 12]));
                            })),
                            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
                          ),
                          gridData: FlGridData(show: true),
                          borderData: FlBorderData(show: true),
                          lineBarsData: [
                            LineChartBarData(
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(show: false),
                              spots: [
                                for (final entry in (bookingProvider?.computeMonthlyRevenueFiltered() ?? List<double>.filled(12, 0)).asMap().entries)
                                  FlSpot(entry.key.toDouble(), entry.value),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Quick Actions
            Text('Quick Actions', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _ActionButton(
                  icon: Icons.stadium_outlined,
                  label: 'Manage Turfs',
                  onTap: () => context.go('/admin/turfs'),
                ),
                _ActionButton(
                  icon: Icons.schedule,
                  label: 'Manage Slots',
                  onTap: () => context.go('/admin/slots'),
                ),
                _ActionButton(
                  icon: Icons.event_note,
                  label: 'Manage Bookings',
                  onTap: () => context.go('/admin/bookings'),
                ),
                _ActionButton(
                  icon: Icons.people_alt_outlined,
                  label: 'Manage Users',
                  onTap: () => context.go('/admin/users'),
                ),
                _ActionButton(
                  icon: Icons.assessment_outlined,
                  label: 'Reports',
                  onTap: () => context.go('/admin/reports'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: OutlinedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(label),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _SummaryCard({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label),
                  Text(value, style: Theme.of(context).textTheme.titleLarge),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
