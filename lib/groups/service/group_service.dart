import 'package:get/get.dart';
import 'package:sirkl/common/constants.dart' as con;

class GroupService extends GetConnect{
  Future<Response<List<dynamic>>> retrieveGroups() => get('${con.URL_SERVER}group/retrieve');
}