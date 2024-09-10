import 'package:sirkl/models/report_dto.dart';
import 'package:sirkl/networks/request.dart';
import 'package:sirkl/networks/urls.dart';

class ReportRepo {
  static Future<void> report(ReportDto reportDto) async {
    SRequests req = SRequests(SUrls.baseURL);
    await req.post(url: SUrls.signalmentReport, body: reportDto.toJson());
  }
}
