import 'package:azlistview/azlistview.dart';

class Example extends ISuspensionBean{
  String? name;
  String? tagIndex;

  Example({
    this.name,
    this.tagIndex
  });

  Example.fromJson(Map<String, dynamic> json) : name = json['name'];

  Map<String, dynamic> toJson() => {
    'name': name,
//        'tagIndex': tagIndex,
//        'namePinyin': namePinyin,
//        'isShowSuspension': isShowSuspension
  };

  @override
  String getSuspensionTag() => tagIndex!;

}