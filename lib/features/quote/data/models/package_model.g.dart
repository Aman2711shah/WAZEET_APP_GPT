// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PackageRow _$PackageRowFromJson(Map json) => PackageRow(
  freezone: json['freezone'] as String?,
  packageName: json['packageName'] as String?,
  noOfActivitiesAllowed: json['NoOfActivitiesAllowed'] as String?,
  noOfShareholdersAllowed: json['NoOfShareholdersAllowed'] as String?,
  noOfVisasIncluded: json['NoOfVisasIncluded'] as String?,
  tenureYears: json['tenureYears'] as String?,
  priceAed: json['priceAed'] as String?,
  immigrationCardFee: json['immigrationCardFee'] as String?,
  eChannelFee: json['EChannelFee'] as String?,
  visaCostAed: json['visaCostAed'] as String?,
  medicalFee: json['medicalFee'] as String?,
  emiratesIdFee: json['emiratesIdFee'] as String?,
  changeOfStatusFee: json['changeOfStatusFee'] as String?,
  otherCostsNotes: json['otherCostsNotes'] as String?,
  visaEligibility: json['visaEligibility'] as String?,
  isActive: json['isActive'] as bool?,
  importedAt: json['importedAt'] as String?,
);

Map<String, dynamic> _$PackageRowToJson(PackageRow instance) =>
    <String, dynamic>{
      'freezone': instance.freezone,
      'packageName': instance.packageName,
      'NoOfActivitiesAllowed': instance.noOfActivitiesAllowed,
      'NoOfShareholdersAllowed': instance.noOfShareholdersAllowed,
      'NoOfVisasIncluded': instance.noOfVisasIncluded,
      'tenureYears': instance.tenureYears,
      'priceAed': instance.priceAed,
      'immigrationCardFee': instance.immigrationCardFee,
      'EChannelFee': instance.eChannelFee,
      'visaCostAed': instance.visaCostAed,
      'medicalFee': instance.medicalFee,
      'emiratesIdFee': instance.emiratesIdFee,
      'changeOfStatusFee': instance.changeOfStatusFee,
      'otherCostsNotes': instance.otherCostsNotes,
      'visaEligibility': instance.visaEligibility,
      'isActive': instance.isActive,
      'importedAt': instance.importedAt,
    };
