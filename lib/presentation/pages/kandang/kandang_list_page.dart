import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/kandang/kandang_bloc.dart';
import '../../../data/models/all_models.dart';
import 'kandang_form_page.dart';
import 'kandang_detail_page.dart';
 
class KandangListPage extends StatefulWidget {
  const KandangListPage({super.key});
  @override
  State<KandangListPage> createState() => _KandangListPageState();
}
 
class _KandangListPageState extends State<KandangListPage> {
  final _searchCtrl = TextEditingController();
  bool _searching = false;
 
  @override
  void initState() {
    super.initState();
    _loadAll();
  }
 
  void _loadAll() {
    final auth = context.read<AuthBloc>().state;
    if (auth is AuthSuccess) {
      context.read<KandangBloc>().add(LoadKandangEvent(auth.userId));
    }
  }
 
  void _doSearch(String keyword) {
    final auth = context.read<AuthBloc>().state;
    if (auth is! AuthSuccess) return;
    if (keyword.trim().isEmpty) {
      _loadAll();
    } else {
      context.read<KandangBloc>().add(SearchKandangEvent(keyword, auth.userId));
    }
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
 
    return Scaffold(
      appBar: AppBar(
        title: _searching
          ? TextField(
              controller: _searchCtrl,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Cari kandang...', border: InputBorder.none),
              onChanged: _doSearch,
            )
          : const Text('Manajemen Kandang'),
        actions: [
          IconButton(
            icon: Icon(_searching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() => _searching = !_searching);
              if (!_searching) { _searchCtrl.clear(); _loadAll(); }
            },
          ),
        ],
      ),
      body: BlocConsumer<KandangBloc, KandangState>(
        listener: (ctx, state) {
          if (state is KandangSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), behavior: SnackBarBehavior.floating));
            _loadAll();
          } else if (state is KandangError) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(content: Text(state.message), backgroundColor: cs.error, behavior: SnackBarBehavior.floating));
          }
        },
        builder: (ctx, state) {
          if (state is KandangLoading) return const Center(child: CircularProgressIndicator());
          if (state is KandangLoaded) {
            if (state.list.isEmpty) {
              return Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.home_outlined, size: 64, color: cs.outlineVariant),
                  const SizedBox(height: 12),
                  Text('Belum ada kandang', style: TextStyle(color: cs.outline)),
                  const SizedBox(height: 8),
                  FilledButton.tonal(
                    onPressed: () => _openForm(ctx),
                    child: const Text('Tambah Kandang'),
                  ),
                ],
              ));
            }
            return RefreshIndicator(
              onRefresh: () async => _loadAll(),
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: state.list.length,
                itemBuilder: (_, i) => _KandangTile(
                  kandang: state.list[i],
                  onTap: () => Navigator.push(ctx,
                    MaterialPageRoute(builder: (_) => KandangDetailPage(kandang: state.list[i]))),
                  onEdit: () => _openForm(ctx, kandang: state.list[i]),
                  onDelete: () => _confirmDelete(ctx, state.list[i]),
                ),
              ),
            );
          }
          return const SizedBox();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(context),
        icon: const Icon(Icons.add),
        label: const Text('Tambah Kandang'),
      ),
    );
  }
 
  void _openForm(BuildContext ctx, {KandangModel? kandang}) {
    Navigator.push(ctx, MaterialPageRoute(builder: (_) => KandangFormPage(kandang: kandang)))
        .then((_) => _loadAll());
  }
 
  void _confirmDelete(BuildContext ctx, KandangModel kandang) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Kandang'),
        content: Text('Hapus "${kandang.nama}"? Semua data bebek dan produksi akan ikut terhapus.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ctx.read<KandangBloc>().add(DeleteKandangEvent(kandang.id!));
            },
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
 
class _KandangTile extends StatelessWidget {
  final KandangModel kandang;
  final VoidCallback onTap, onEdit, onDelete;
  const _KandangTile({required this.kandang, required this.onTap, required this.onEdit, required this.onDelete});
 
  @override
  Widget build(BuildContext context) {
    final cs      = Theme.of(context).colorScheme;
    final persen  = kandang.totalBebek / kandang.kapasitas;
    final isPenuh = persen >= 0.9;
 
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(
                backgroundColor: isPenuh ? cs.errorContainer : cs.primaryContainer,
                child: Icon(Icons.home_rounded, color: isPenuh ? cs.error : cs.primary),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(kandang.nama, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                if (kandang.lokasi != null && kandang.lokasi!.isNotEmpty)
                  Text(kandang.lokasi!, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline)),
              ])),
              PopupMenuButton(
                itemBuilder: (_) => [
                  const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit), title: Text('Edit'))),
                  const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete), title: Text('Hapus'))),
                ],
                onSelected: (v) { if (v == 'edit') onEdit(); else onDelete(); },
              ),
            ]),
            const SizedBox(height: 12),
            Row(children: [
              _InfoChip(icon: Icons.pets, label: '${kandang.totalBebek}/${kandang.kapasitas} ekor'),
              const SizedBox(width: 8),
              if (kandang.lokasi != null) _InfoChip(icon: Icons.location_on_outlined, label: 'Punya lokasi GPS'),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: persen.clamp(0.0, 1.0),
                backgroundColor: cs.surfaceContainerHighest,
                color: isPenuh ? cs.error : cs.primary,
                minHeight: 6,
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
 
class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: cs.surfaceContainerHighest, borderRadius: BorderRadius.circular(8)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 12, color: cs.outline),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: cs.outline)),
      ]),
    );
  }
}
 