import 'package:sirkl/models/notification_added_admin_dto.dart';
import 'package:sirkl/models/notification_dto.dart';
import 'package:sirkl/models/notification_register_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class NotificationRepo {
  static Future<List<NotificationDto>> retrieveNotifications(
      {required String id, required String offset}) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.retrieveNotifications(id, offset));
    return (res.jsonBody() as List<dynamic>)
        .map((e) => NotificationDto.fromJson(e))
        .toList();
  }

  static Future<void> deleteNotification(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.delete(url: SUrls.notificationById(id));
  }

  static Future<bool> retrieveHasUnreadNotification(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.notificationUnreadNotif(id));
    return res.body == 'true';
  }

  static Future<void> registerNotification(
      NotificationRegisterDto notification) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(
        url: SUrls.notificationRegister, body: notification.toJson());
  }

  static Future<void> notifyAddedInGroup(
      NotificationAddedAdminDto notificationAddedAdminDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(
        url: SUrls.notificationAddedInGroup,
        body: notificationAddedAdminDto.toJson());
  }

  static Future<void> notifyUserAsAdmin(
      NotificationAddedAdminDto notificationAddedAdminDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(
        url: SUrls.notificationUpgradedAsAdmin,
        body: notificationAddedAdminDto.toJson());
  }

  static Future<void> notifyUserInvitedToJoinPayingGroup(
      NotificationAddedAdminDto notificationAddedAdminDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(
        url: SUrls.notificationInvitedToJoinPayingGroup,
        body: notificationAddedAdminDto.toJson());
  }
}
