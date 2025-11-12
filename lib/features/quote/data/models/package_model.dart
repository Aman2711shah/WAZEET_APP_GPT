import 'package:json_annotation/json_annotation.dart';

part 'package_model.g.dart';

/// Model matching the actual excel-to-json-4.json schema from freezone-import/
@JsonSerializable(anyMap: true)
class PackageRow {
  final String? freezone;
  final String? packageName;
  @JsonKey(name: 'NoOfActivitiesAllowed')
  final String? noOfActivitiesAllowed;
  @JsonKey(name: 'NoOfShareholdersAllowed')
  final String? noOfShareholdersAllowed;
  @JsonKey(name: 'NoOfVisasIncluded')
  final String? noOfVisasIncluded;
  final String? tenureYears;
  final String? priceAed;
  final String? immigrationCardFee;
  @JsonKey(name: 'EChannelFee')
  final String? eChannelFee;
  final String? visaCostAed;
  final String? medicalFee;
  final String? emiratesIdFee;
  final String? changeOfStatusFee;
  final String? otherCostsNotes;
  final String? visaEligibility;
  final bool? isActive;
  final String? importedAt;

  const PackageRow({
    this.freezone,
    this.packageName,
    this.noOfActivitiesAllowed,
    this.noOfShareholdersAllowed,
    this.noOfVisasIncluded,
    this.tenureYears,
    this.priceAed,
    this.immigrationCardFee,
    this.eChannelFee,
    this.visaCostAed,
    this.medicalFee,
    this.emiratesIdFee,
    this.changeOfStatusFee,
    this.otherCostsNotes,
    this.visaEligibility,
    this.isActive,
    this.importedAt,
  });

  factory PackageRow.fromJson(Map json) => _$PackageRowFromJson(json);
  Map<String, dynamic> toJson() => _$PackageRowToJson(this);
}
