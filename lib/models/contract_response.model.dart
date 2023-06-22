


import 'package:sirkl/enums/contract_response_status.enum.dart';

class ContractResponse {
  final String txId;
  final List<dynamic> result;
  final ContractResponseStatus status;
  final List<String>? error;

  ContractResponse({required this.txId, required this.result, required this.status, this.error});

  toJson() => {
    'txId': txId,
    'result': result,
    'status': status
  };

}