import 'package:inspire/core/models/academic/mahasiswa_bimbingan_model.dart';
import 'package:inspire/core/models/khs/khs_model.dart';
import 'package:inspire/core/models/transcript/transcript_model.dart';

// ─── Mahasiswa Bimbingan List State ──────────────────────────────────────────

sealed class MahasiswaBimbinganState {
  const MahasiswaBimbinganState();
}

class MahasiswaBimbinganInitial extends MahasiswaBimbinganState {
  const MahasiswaBimbinganInitial();
}

class MahasiswaBimbinganLoading extends MahasiswaBimbinganState {
  const MahasiswaBimbinganLoading();
}

class MahasiswaBimbinganLoaded extends MahasiswaBimbinganState {
  final List<MahasiswaBimbinganModel> data;
  const MahasiswaBimbinganLoaded(this.data);
}

class MahasiswaBimbinganError extends MahasiswaBimbinganState {
  final String message;
  const MahasiswaBimbinganError(this.message);
}

// ─── PA Semester List State ───────────────────────────────────────────────────

sealed class PaSemesterListState {
  const PaSemesterListState();
}

class PaSemesterListInitial extends PaSemesterListState {
  const PaSemesterListInitial();
}

class PaSemesterListLoading extends PaSemesterListState {
  const PaSemesterListLoading();
}

class PaSemesterListLoaded extends PaSemesterListState {
  final List<String> semesters;
  const PaSemesterListLoaded(this.semesters);
}

class PaSemesterListError extends PaSemesterListState {
  final String message;
  const PaSemesterListError(this.message);
}

// ─── PA KHS State ─────────────────────────────────────────────────────────────

sealed class PaKhsState {
  const PaKhsState();
}

class PaKhsInitial extends PaKhsState {
  const PaKhsInitial();
}

class PaKhsLoading extends PaKhsState {
  const PaKhsLoading();
}

class PaKhsLoaded extends PaKhsState {
  final KhsModel data;
  const PaKhsLoaded(this.data);
}

class PaKhsError extends PaKhsState {
  final String message;
  const PaKhsError(this.message);
}

// ─── PA Transkrip State ───────────────────────────────────────────────────────

sealed class PaTranskripState {
  const PaTranskripState();
}

class PaTranskripInitial extends PaTranskripState {
  const PaTranskripInitial();
}

class PaTranskripLoading extends PaTranskripState {
  const PaTranskripLoading();
}

class PaTranskripLoaded extends PaTranskripState {
  final TranscriptModel data;
  const PaTranskripLoaded(this.data);
}

class PaTranskripError extends PaTranskripState {
  final String message;
  const PaTranskripError(this.message);
}
