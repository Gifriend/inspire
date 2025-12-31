import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';

part 'announcement_state.freezed.dart';

@freezed
abstract class AnnouncementState with _$AnnouncementState {
  const factory AnnouncementState.initial() = _Initial;
  const factory AnnouncementState.loading() = _Loading;
  const factory AnnouncementState.loaded(List<AnnouncementModel> announcements) = _Loaded;
  const factory AnnouncementState.error(String message) = _Error;
}

@freezed
abstract class AnnouncementDetailState with _$AnnouncementDetailState {
  const factory AnnouncementDetailState.initial() = _DetailInitial;
  const factory AnnouncementDetailState.loading() = _DetailLoading;
  const factory AnnouncementDetailState.loaded(AnnouncementModel announcement) = _DetailLoaded;
  const factory AnnouncementDetailState.error(String message) = _DetailError;
}
