import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';

part 'announcement_koorprodi_state.freezed.dart';

@freezed
abstract class AnnouncementKoorprodiState with _$AnnouncementKoorprodiState {
  const factory AnnouncementKoorprodiState.initial() = _Initial;
  const factory AnnouncementKoorprodiState.loading() = _Loading;
  const factory AnnouncementKoorprodiState.loaded(List<AnnouncementModel> announcements) = _Loaded;
  const factory AnnouncementKoorprodiState.creating() = _Creating;
  const factory AnnouncementKoorprodiState.created(AnnouncementModel announcement) = _Created;
  const factory AnnouncementKoorprodiState.deleting() = _Deleting;
  const factory AnnouncementKoorprodiState.deleted() = _Deleted;
  const factory AnnouncementKoorprodiState.error(String message) = _Error;
}
