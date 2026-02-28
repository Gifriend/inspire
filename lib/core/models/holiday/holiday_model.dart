/// Model for a single Indonesian public holiday from Nager.Date API
/// Source: https://date.nager.at/api/v3/PublicHolidays/{year}/ID
class HolidayModel {
  final String date;       // "2026-01-01"
  final String localName;  // "Tahun Baru" (Indonesian name)
  final String name;       // "New Year's Day" (English name)

  const HolidayModel({
    required this.date,
    required this.localName,
    required this.name,
  });

  factory HolidayModel.fromJson(Map<String, dynamic> json) => HolidayModel(
        date: json['date'] as String,
        localName: json['localName'] as String? ?? json['name'] as String? ?? '',
        name: json['name'] as String? ?? '',
      );
}
