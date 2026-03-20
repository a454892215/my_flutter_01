import 'package:json_annotation/json_annotation.dart';
/// 创建一个类，并严格遵守以下四个要素：
///  dart run build_runner build --delete-conflicting-outputs
/// 1. 声明关联的生成文件 (格式: 文件名.g.dart) 引用的文件名必须与当前文件名完全一致
part 'test_base_entity.g.dart';

@JsonSerializable()
class TestBaseEntity {
 // @JsonKey(name: 'code2') /// 2. 字段映射 (类似 Gson 的 @SerializedName)
  final int code;

  final String msg;

  TestBaseEntity({required this.code, required this.msg, });

  /// 3. 固定写法：反序列化构造函数
  factory TestBaseEntity.fromJson(Map<String, dynamic> json) => _$TestBaseEntityFromJson(json);

  /// 4. 固定写法：序列化方法
  Map<String, dynamic> toJson() => _$TestBaseEntityToJson(this);
}
