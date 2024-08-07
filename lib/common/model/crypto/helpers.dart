import 'package:flutter/material.dart';
import 'package:sirkl/common/model/crypto/chain_data_wrapper.dart';
import 'package:sirkl/common/model/crypto/chain_metadata.dart';
import 'package:web3modal_flutter/web3modal_flutter.dart';

String getChainName(String chain) {
  try {
    return ChainDataWrapper.chains
        .where((element) => element.w3mChainInfo.namespace == chain)
        .first
        .w3mChainInfo
        .chainName;
  } catch (e) {
    debugPrint('[ExampleApp] getChainName, Invalid chain: $chain');
  }
  return 'Unknown';
}

ChainMetadata getChainMetadataFromChain(String namespace) {
  try {
    return ChainDataWrapper.chains
        .where((element) => element.w3mChainInfo.namespace == namespace)
        .first;
  } catch (_) {
    return ChainMetadata(
      color: Colors.blue,
      type: ChainType.eip155,
      w3mChainInfo: W3MChainPresets.chains.values.firstWhere(
        (e) => e.namespace == namespace,
      ),
    );
  }
}
