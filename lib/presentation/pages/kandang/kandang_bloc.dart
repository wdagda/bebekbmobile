import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/database/dao/kandang_dao.dart';
import '../../../data/models/all_models.dart';

// ── Events
abstract class KandangEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadKandangEvent extends KandangEvent {
  final int userId;
  LoadKandangEvent(this.userId);
}

class AddKandangEvent extends KandangEvent {
  final KandangModel kandang;
  AddKandangEvent(this.kandang);
}

class UpdateKandangEvent extends KandangEvent {
  final KandangModel kandang;
  UpdateKandangEvent(this.kandang);
}

class DeleteKandangEvent extends KandangEvent {
  final int id;
  DeleteKandangEvent(this.id);
}

class SearchKandangEvent extends KandangEvent {
  final String keyword;
  final int userId;
  SearchKandangEvent(this.keyword, this.userId);
}

// ── States
abstract class KandangState extends Equatable {
  @override
  List<Object?> get props => [];
}

class KandangInitial extends KandangState {}

class KandangLoading extends KandangState {}

class KandangError extends KandangState {
  final String message;
  KandangError(this.message);
}

class KandangLoaded extends KandangState {
  final List<KandangModel> list;
  KandangLoaded(this.list);
  @override
  List<Object?> get props => [list];
}

class KandangSuccess extends KandangState {
  final String message;
  KandangSuccess(this.message);
}

// ── BLoC
class KandangBloc extends Bloc<KandangEvent, KandangState> {
  final _dao = KandangDao();

  KandangBloc() : super(KandangInitial()) {
    on<LoadKandangEvent>(_onLoad);
    on<AddKandangEvent>(_onAdd);
    on<UpdateKandangEvent>(_onUpdate);
    on<DeleteKandangEvent>(_onDelete);
    on<SearchKandangEvent>(_onSearch);
  }

  Future<void> _onLoad(LoadKandangEvent e, Emitter<KandangState> emit) async {
    emit(KandangLoading());
    try {
      final list = await _dao.getAll(e.userId);
      emit(KandangLoaded(list.map(KandangModel.fromMap).toList()));
    } catch (err) {
      emit(KandangError('Gagal memuat kandang: $err'));
    }
  }

  Future<void> _onAdd(AddKandangEvent e, Emitter<KandangState> emit) async {
    try {
      await _dao.insert(e.kandang.toMap());
      emit(const KandangSuccess('Kandang berhasil ditambahkan'));
    } catch (err) {
      emit(KandangError('Gagal menambah kandang: $err'));
    }
  }

  Future<void> _onUpdate(
    UpdateKandangEvent e,
    Emitter<KandangState> emit,
  ) async {
    try {
      await _dao.update(e.kandang.toMap());
      emit(const KandangSuccess('Kandang berhasil diperbarui'));
    } catch (err) {
      emit(KandangError('Gagal memperbarui kandang: $err'));
    }
  }

  Future<void> _onDelete(
    DeleteKandangEvent e,
    Emitter<KandangState> emit,
  ) async {
    try {
      await _dao.delete(e.id);
      emit(const KandangSuccess('Kandang berhasil dihapus'));
    } catch (err) {
      emit(KandangError('Gagal menghapus kandang: $err'));
    }
  }

  Future<void> _onSearch(
    SearchKandangEvent e,
    Emitter<KandangState> emit,
  ) async {
    emit(KandangLoading());
    try {
      final result = await _dao.search(e.keyword, e.userId);
      emit(KandangLoaded(result.map(KandangModel.fromMap).toList()));
    } catch (err) {
      emit(KandangError('Gagal mencari: $err'));
    }
  }
}
