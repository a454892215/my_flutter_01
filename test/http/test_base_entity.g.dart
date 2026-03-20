// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'test_base_entity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TestBaseEntity _$TestBaseEntityFromJson(Map<String, dynamic> json) =>
    TestBaseEntity(
      code: (json['code'] as num).toInt(),
      msg: json['msg'] as String,
    );

Map<String, dynamic> _$TestBaseEntityToJson(TestBaseEntity instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
    };
