import 'package:sirkl/models/inbox_creation_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class InboxRepo {
  static Future<String> createInbox(InboxCreationDto inboxCreationDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res =
        await req.post(url: SUrls.inboxCreate, body: inboxCreationDto.toJson());
    return res.body;
  }

  static Future<void> updateInbox() async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.get(SUrls.inboxUpdate);
  }

  static Future<String?> ethFromEns(String ens) async {
    SRequests req = SRequests(SUrls.baseURL);
    Response res = await req.get(SUrls.inboxEthFromENS(ens));

    return res.body.toString();
  }

  static Future<void> deleteInbox(String id) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.delete(url: SUrls.inboxDeleteById(id));
  }
}
