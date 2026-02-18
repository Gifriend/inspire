import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:inspire/core/models/announcement/announcement_model.dart';

part 'announcement_lecturer_state.freezed.dart';

@freezed
abstract class AnnouncementLecturerState with _$AnnouncementLecturerState {
  const factory AnnouncementLecturerState.initial() = _Initial;
  const factory AnnouncementLecturerState.loading() = _Loading;
  const factory AnnouncementLecturerState.loaded(List<AnnouncementModel> announcements) = _Loaded;
  const factory AnnouncementLecturerState.creating() = _Creating;
  const factory AnnouncementLecturerState.created(AnnouncementModel announcement) = _Created;
  const factory AnnouncementLecturerState.deleting() = _Deleting;
  const factory AnnouncementLecturerState.deleted() = _Deleted;
  const factory AnnouncementLecturerState.error(String message) = _Error;
}