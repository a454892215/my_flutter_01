class UserInfo {
  String? userName;
  int? age;
  String? address;
  String? email;
  String? phone;

  UserInfo({this.userName, this.age, this.address, this.email, this.phone});

  UserInfo.fromJson(dynamic json) {
    userName = json['userName'];
    age = json['age'];
    address = json['address'];
    email = json['email'];
    phone = json['phone'];
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['userName'] = userName;
    map['age'] = age;
    map['address'] = address;
    map['email'] = email;
    map['phone'] = phone;
    return map;
  }
}
