import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:geolocator/geolocator.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/dashboard/dashboard_bloc.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../core/utils/time_converter.dart';
import '../minigame/egg_catch_game.dart';
import '../chatbot/chatbot_page.dart';
import '../maps/maps_page.dart';
import '../search/search_page.dart';
 
class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}
 
class _DashboardPageState extends State<DashboardPage> {
  Currency _selectedCurrency = Currency.IDR;
 
  @override
  void initState() {
    super.initState();
    _load();
  }
 
  Future<void> _load() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthSuccess) return;
 
    double lat = -7.5596, lon = 110.8304; // Default: Boyolali
    try {
      final perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.always || perm == LocationPermission.whileInUse) {
        final pos = await Geolocator.getCurrentPosition();
        lat = pos.latitude; lon = pos.longitude;
      }
    } catch (_) {}
 
    if (mounted) {
      context.read<DashboardBloc>().add(
        LoadDashboardEvent(userId: authState.userId, lat: lat, lon: lon),
      );
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
 
    return Scaffold(
      appBar: AppBar(
        title: Row(children: [
          Icon(Icons.egg_alt_rounded, color: cs.primary),
          const SizedBox(width: 8),
          const Text('Duck Farm Manager'),
        ]),
        actions: [
          // Currency switcher
          PopupMenuButton<Currency>(
            icon: const Icon(Icons.currency_exchange),
            tooltip: 'Ganti Mata Uang',
            onSelected: (c) => setState(() => _selectedCurrency = c),
            itemBuilder: (_) => Currency.values.map((c) =>
              PopupMenuItem(value: c, child: Text(CurrencyFormatter.currencyName(c)))).toList(),
          ),
          IconButton(icon: const Icon(Icons.search), onPressed: () =>
            Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchPage()))),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      body: BlocBuilder<DashboardBloc, DashboardState>(
        builder: (ctx, state) {
          if (state is DashboardLoading || state is DashboardInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is DashboardError) {
            return Center(child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline, size: 48, color: cs.error),
                const SizedBox(height: 8),
                Text(state.message),
                TextButton(onPressed: _load, child: const Text('Coba lagi')),
              ],
            ));
          }
          if (state is! DashboardLoaded) return const SizedBox();
 
          return RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // ── Waktu multi-zona
                _TimeZoneCard(),
                const SizedBox(height: 12),
 
                // ── Cuaca
                if (state.cuaca != null) _WeatherCard(cuaca: state.cuaca!),
                const SizedBox(height: 12),
 
                // ── Summary Cards
                Text('Ringkasan Hari Ini', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GridView.count(
                  crossAxisCount: 2, shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
                  children: [
                    _SummaryCard(label: 'Total Kandang',   value: '${state.totalKandang}',     icon: Icons.home_rounded,    color: cs.primaryContainer),
                    _SummaryCard(label: 'Total Bebek',     value: '${state.totalBebek} ekor',  icon: Icons.pets,            color: cs.secondaryContainer),
                    _SummaryCard(label: 'Produksi Hari Ini', value: '${state.produksiHariIni} butir', icon: Icons.egg_rounded, color: cs.tertiaryContainer),
                    _SummaryCard(label: 'Pakan Kritis',   value: '${state.pakanHampirHabis} item', icon: Icons.warning_amber_rounded, color: cs.errorContainer),
                  ],
                ),
                const SizedBox(height: 16),
 
                // ── Stok Produk
                Text('Stok Produk', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(children: [
                  Expanded(child: _StokCard(label: 'Telur Mentah', jumlah: state.stokMentah, icon: '🥚', currency: _selectedCurrency, hargaSatuan: 2500)),
                  const SizedBox(width: 10),
                  Expanded(child: _StokCard(label: 'Telur Asin',   jumlah: state.stokAsin,   icon: '🧂', currency: _selectedCurrency, hargaSatuan: 4000)),
                  const SizedBox(width: 10),
                  Expanded(child: _StokCard(label: 'Kerupuk',      jumlah: state.stokKerupuk, icon: '🍘', currency: _selectedCurrency, hargaSatuan: 15000)),
                ]),
                const SizedBox(height: 16),
 
                // ── Chart 7 hari
                Text('Produksi 7 Hari Terakhir', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                _ProduksiChart(chartData: state.chart7Hari),
                const SizedBox(height: 16),
 
                // ── Quick Actions
                Text('Fitur Lainnya', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Wrap(spacing: 10, runSpacing: 10, children: [
                  _QuickAction(label: 'Peta Kandang', icon: Icons.map_rounded, onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const MapsPage()))),
                  _QuickAction(label: 'DuckBot AI', icon: Icons.smart_toy_rounded, onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const ChatbotPage()))),
                  _QuickAction(label: 'Mini Game', icon: Icons.sports_esports_rounded, onTap: () =>
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const EggCatchGame()))),
                ]),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }
}
 
// ── Sub-widgets ───────────────────────────────────────────────────────────────
 
class _TimeZoneCard extends StatefulWidget {
  @override
  State<_TimeZoneCard> createState() => _TimeZoneCardState();
}
class _TimeZoneCardState extends State<_TimeZoneCard> {
  late DateTime _now;
 
  @override
  void initState() {
    super.initState();
    _now = DateTime.now().toUtc();
    // Update setiap menit
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 30));
      if (!mounted) return false;
      setState(() => _now = DateTime.now().toUtc());
      return true;
    });
  }
 
  @override
  Widget build(BuildContext context) {
    final cs    = Theme.of(context).colorScheme;
    final zones = TimeConverter.allZones(_now);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: zones.entries.map((e) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(e.key, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.outline)),
              const SizedBox(height: 2),
              Text(e.value.split(' ').last, // Hanya waktu
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
              Text(e.value.split(' ').first,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline)),
            ],
          )).toList(),
        ),
      ),
    );
  }
}
 
class _WeatherCard extends StatelessWidget {
  final dynamic cuaca;
  const _WeatherCard({required this.cuaca});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Card(
      color: cs.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(children: [
          Image.network(cuaca.iconUrl, width: 52, height: 52, errorBuilder: (_, __, ___) =>
            Icon(Icons.wb_sunny_rounded, size: 48, color: cs.secondary)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cuaca.cityName, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
            Text(cuaca.description, style: tt.bodySmall?.copyWith(color: cs.onSecondaryContainer.withOpacity(0.8))),
            const SizedBox(height: 4),
            Row(children: [
              Text(cuaca.tempStr, style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: cs.onSecondaryContainer)),
              const SizedBox(width: 16),
              Icon(Icons.water_drop_outlined, size: 14, color: cs.secondary),
              Text(' ${cuaca.humidity.toStringAsFixed(0)}%', style: tt.bodySmall),
              const SizedBox(width: 8),
              Icon(Icons.air_rounded, size: 14, color: cs.secondary),
              Text(' ${cuaca.windSpeed} m/s', style: tt.bodySmall),
            ]),
          ])),
        ]),
      ),
    );
  }
}
 
class _SummaryCard extends StatelessWidget {
  final String label, value;
  final IconData icon;
  final Color color;
  const _SummaryCard({required this.label, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, size: 28, color: cs.onSurface.withOpacity(0.7)),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.onSurface.withOpacity(0.7))),
        ]),
      ),
    );
  }
}
 
class _StokCard extends StatelessWidget {
  final String label, icon;
  final int jumlah;
  final Currency currency;
  final double hargaSatuan;
  const _StokCard({required this.label, required this.jumlah, required this.icon, required this.currency, required this.hargaSatuan});
  @override
  Widget build(BuildContext context) {
    final cs   = Theme.of(context).colorScheme;
    final nilai = CurrencyFormatter.format(jumlah * hargaSatuan, currency);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(children: [
          Text(icon, style: const TextStyle(fontSize: 28)),
          const SizedBox(height: 4),
          Text('$jumlah', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.outline), textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(nilai, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: cs.primary, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}
 
class _ProduksiChart extends StatelessWidget {
  final List<Map<String, dynamic>> chartData;
  const _ProduksiChart({required this.chartData});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    if (chartData.isEmpty) {
      return Card(child: Padding(
        padding: const EdgeInsets.all(32),
        child: Center(child: Text('Belum ada data produksi', style: TextStyle(color: cs.outline))),
      ));
    }
    final spots = chartData.asMap().entries.map((e) =>
      FlSpot(e.key.toDouble(), (e.value['total'] as num).toDouble())).toList();
 
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
        child: SizedBox(
          height: 160,
          child: LineChart(LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (_) => FlLine(color: cs.outlineVariant, strokeWidth: 1),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 36,
                getTitlesWidget: (v, _) => Text('${v.toInt()}', style: const TextStyle(fontSize: 10)))),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24,
                getTitlesWidget: (v, _) {
                  final idx = v.toInt();
                  if (idx < 0 || idx >= chartData.length) return const SizedBox();
                  final tgl = (chartData[idx]['tgl'] as String).substring(5);
                  return Text(tgl, style: const TextStyle(fontSize: 9));
                })),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: cs.primary,
                barWidth: 3,
                dotData: const FlDotData(show: true),
                belowBarData: BarAreaData(
                  show: true,
                  color: cs.primary.withOpacity(0.12),
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }
}
 
class _QuickAction extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  const _QuickAction({required this.label, required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: cs.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 20, color: cs.primary),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: cs.onPrimaryContainer, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}
 