//
//  Chain3+Methods.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 21.12.2017.
//  Copyright © 2017 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation

public struct JsonRpcMethod: Encodable, Equatable {
    public var api: String
    public var parameters: Int
    public init(api: String, parameters: Int) {
        self.api = api
        self.parameters = parameters
    }
    public static let gasPrice = JsonRpcMethod(api: "mc_gasPrice", parameters: 0)
    public static let blockNumber = JsonRpcMethod(api: "mc_blockNumber", parameters: 0)
    public static let getNetwork = JsonRpcMethod(api: "net_version", parameters: 0)
    public static let sendRawTransaction = JsonRpcMethod(api: "mc_sendRawTransaction", parameters: 1)
    public static let sendTransaction = JsonRpcMethod(api: "mc_sendTransaction", parameters: 1)
    public static let estimateGas = JsonRpcMethod(api: "mc_estimateGas", parameters: 1)
    public static let call = JsonRpcMethod(api: "mc_call", parameters: 2)
    public static let getTransactionCount = JsonRpcMethod(api: "mc_getTransactionCount", parameters: 2)
    public static let getBalance = JsonRpcMethod(api: "mc_getBalance", parameters: 2)
    public static let getCode = JsonRpcMethod(api: "mc_getCode", parameters: 2)
    public static let getStorageAt = JsonRpcMethod(api: "mc_getStorageAt", parameters: 2)
    public static let getTransactionByHash = JsonRpcMethod(api: "mc_getTransactionByHash", parameters: 1)
    public static let getTransactionReceipt = JsonRpcMethod(api: "mc_getTransactionReceipt", parameters: 1)
    public static let getAccounts = JsonRpcMethod(api: "mc_accounts", parameters: 0)
    public static let getBlockByHash = JsonRpcMethod(api: "mc_getBlockByHash", parameters: 2)
    public static let getBlockByNumber = JsonRpcMethod(api: "mc_getBlockByNumber", parameters: 2)
    public static let personalSign = JsonRpcMethod(api: "mc_sign", parameters: 1)
    public static let unlockAccount = JsonRpcMethod(api: "personal_unlockAccount", parameters: 1)
    public static let getLogs = JsonRpcMethod(api: "mc_getLogs", parameters: 1)
    public static let txPoolStatus = JsonRpcMethod(api: "txpool_status", parameters: 0)
    public static let txPoolInspect = JsonRpcMethod(api: "txpool_inspect", parameters: 0)
    public static let txPoolContent = JsonRpcMethod(api: "txpool_content", parameters: 0)
    // vnode
    public static let vnVnodeAddress = JsonRpcMethod(api: "vnode_address", parameters: 0)
    public static let vnScsService = JsonRpcMethod(api: "vnode_scsService", parameters: 0)
    public static let vnServiceCfg = JsonRpcMethod(api: "vnode_serviceCfg", parameters: 0)
    public static let vnShowToPublic = JsonRpcMethod(api: "vnode_showToPublic", parameters: 0)
    public static let vnVnodeIP = JsonRpcMethod(api: "vnode_vnodeIP", parameters: 0)
    // scs
    public static let scsDirectCall = JsonRpcMethod(api: "scs_directCall", parameters: 1)
    public static let scsGetBlock = JsonRpcMethod(api: "scs_getBlock", parameters: 2)
    public static let scsGetBlockNumber = JsonRpcMethod(api: "scs_getBlockNumber", parameters: 1)
    public static let scsGetDappState = JsonRpcMethod(api: "scs_getDappState", parameters: 1)
    public static let scsGetMicroChainList = JsonRpcMethod(api: "scs_getMicroChainList", parameters: 0)
    public static let scsGetMicroChainInfo = JsonRpcMethod(api: "scs_getMicroChainInfo", parameters: 1)
    public static let scsGetNonce = JsonRpcMethod(api: "scs_getNonce", parameters: 2)
    public static let scsGetSCSId = JsonRpcMethod(api: "scs_getSCSId", parameters: 0)
    public static let scsGetTransactionReceipt = JsonRpcMethod(api: "scs_getTransactionReceipt", parameters: 2)
}

public struct JsonRpcRequestFabric {
    public static func prepareRequest(_ method: JsonRpcMethod, parameters: [Encodable]) -> JsonRpcRequest {
        var request = JsonRpcRequest(method: method)
        let pars = JsonRpcParams(params: parameters)
        request.params = pars
        return request
    }
}
