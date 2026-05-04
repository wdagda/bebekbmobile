import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/kandang/kandang_bloc.dart';
import '../../../data/models/all_models.dart';

class KandangFormPage extends StatefulWidget {
  final KandangModel? kandang;
  const KandangFormPage({super.key, this.kandang});
  @override
  State<KandangFormPage> createState() => _KandangFormPageState();
}

class _KandangFormPageState extends State<KandangFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _kapCtrl = TextEditingController();
  final _lokasiCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  double? _lat, _lon;
  bool _loadingGPS = false;
  bool get _isEdit => widget.kandang != null;

  @override
  void initState() {
    super.initState();
    if (_isEdit) {
      final k = widget.kandang!;
      _namaCtrl.text = k.nama;
      _kapCtrl.text = k.kapasitas.toString();
      _lokasiCtrl.text = k.lokasi ?? '';
      _descCtrl.text = k.deskripsi ?? '';
      _lat = k.latitude;
      _lon = k.longitude;
    }
  }

  @override
  void dispose() {
    _namaCtrl.dispose();
    _kapCtrl.dispose();
    _lokasiCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickGPS() async {
    setState(() => _loadingGPS = true);
    try {
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.deniedForever) {
        if (mounted)
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Izin GPS ditolak permanen. Buka settings.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        return;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _lat = pos.latitude;
        _lon = pos.longitude;
      });
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal ambil GPS: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
    } finally {
      setState(() => _loadingGPS = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Edit Kandang' : 'Tambah Kandang')),
      body: BlocListener<KandangBloc, KandangState>(
        listener: (ctx, state) {
          if (state is KandangSuccess) Navigator.pop(ctx);
          if (state is KandangError)
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: cs.error,
                behavior: SnackBarBehavior.floating,
              ),
            );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Nama
                TextFormField(
                  controller: _namaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Kandang *',
                    prefixIcon: Icon(Icons.home_rounded),
                  ),
                  validator: (v) =>
                      (v?.trim().isEmpty ?? true) ? 'Nama wajib diisi' : null,
                  textCapitalization: TextCapitalization.words,
                ),
                const SizedBox(height: 14),

                // ── Kapasitas
                TextFormField(
                  controller: _kapCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Kapasitas (ekor) *',
                    prefixIcon: Icon(Icons.pets),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n <= 0)
                      return 'Masukkan angka kapasitas yang valid';
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // ── Lokasi text
                TextFormField(
                  controller: _lokasiCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nama Lokasi',
                    prefixIcon: Icon(Icons.place_outlined),
                  ),
                ),
                const SizedBox(height: 14),

                // ── GPS Picker
                Card(
                  color: _lat != null
                      ? cs.primaryContainer
                      : cs.surfaceContainerHighest,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.my_location,
                              color: _lat != null ? cs.primary : cs.outline,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Koordinat GPS',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        if (_lat != null)
                          Text(
                            '📍 Lat: ${_lat!.toStringAsFixed(6)}, Lon: ${_lon!.toStringAsFixed(6)}',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: cs.primary),
                          )
                        else
                          Text(
                            'Belum ada koordinat',
                            style: Theme.of(
                              context,
                            ).textTheme.bodySmall?.copyWith(color: cs.outline),
                          ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: _loadingGPS ? null : _pickGPS,
                          icon: _loadingGPS
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.gps_fixed),
                          label: Text(
                            _loadingGPS
                                ? 'Mengambil lokasi...'
                                : 'Ambil Lokasi Sekarang',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // ── Deskripsi
                TextFormField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Deskripsi',
                    prefixIcon: Icon(Icons.notes),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // ── Simpan
                BlocBuilder<KandangBloc, KandangState>(
                  builder: (ctx, state) => FilledButton.icon(
                    onPressed: state is KandangLoading
                        ? null
                        : () => _submit(ctx),
                    icon: const Icon(Icons.save_rounded),
                    label: Text(
                      _isEdit ? 'Perbarui Kandang' : 'Simpan Kandang',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _submit(BuildContext ctx) {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = ctx.read<AuthBloc>().state;
    if (auth is! AuthSuccess) return;

    final kandang = KandangModel(
      id: widget.kandang?.id,
      nama: _namaCtrl.text.trim(),
      kapasitas: int.parse(_kapCtrl.text),
      lokasi: _lokasiCtrl.text.trim().isEmpty ? null : _lokasiCtrl.text.trim(),
      latitude: _lat,
      longitude: _lon,
      deskripsi: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      userId: auth.userId,
      createdAt: widget.kandang?.createdAt ?? DateTime.now().toIso8601String(),
    );

    if (_isEdit) {
      ctx.read<KandangBloc>().add(UpdateKandangEvent(kandang));
    } else {
      ctx.read<KandangBloc>().add(AddKandangEvent(kandang));
    }
  }
}
