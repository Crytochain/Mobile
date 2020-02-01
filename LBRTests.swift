//
//  chain3swiftLBRTests.swift
//  chain3swift-iOS_Tests
//
//  Created by Георгий Фесенко on 02/07/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import XCTest
import BigInt

@testable import chain3swift

class LBRTests: XCTestCase {
    var localNodeFound = false
    var provider: Chain3HttpProvider? = nil
    var localSCSNodeFound = false
    var scsProvider: Chain3HttpProvider? = nil
    let addrOfBalanceCheck = "0xd04967d333fe17fe2707186608e5fc9d1447310c"
    let receivingTestnetAddr = "0x4c18080dd971ffeb4bc32097353741deae9685f3"
    let hashOfTxToInspect = "0x14138b41d26b2925d3b9b66d916cf41dcd62b37756db98fd1d75b66ef1a122eb"
    let contractAddrToCall = "0x574195ecFfDE7c86D4387B04ad1c5aefe1e40383"
    let keystoreJSONStr = """
{"address":"d04967d333fe17fe2707186608e5fc9d1447310c","crypto":{"cipher":"aes-128-ctr","ciphertext":"eb01902340c3fee86982a613cafb7a0eb0db26d9bf9bc35426e200c81b5a0a66","cipherparams":{"iv":"d755d852d8bdbecfe572865e894cdbe4"},"kdf":"scrypt","kdfparams":{"dklen":32,"n":262144,"p":1,"r":8,"salt":"d8ae42bf4021fa214ffce36dd175f95eaa93ce3a645898efdd91bc34b9e7f549"},"mac":"042fcbbaa48d8edc142d31e25cb6a8e413cae612326ef18791b7977241d6fc6a"},"id":"9f59ca5b-d3b9-47c0-81e5-14b89142498e","version":3}
"""
    let contractJsonStr = "[{\"constant\":false,\"inputs\":[{\"name\":\"x\",\"type\":\"uint256\"}],\"name\":\"set\",\"outputs\":[],\"payable\":false,\"stateMutability\":\"nonpayable\",\"type\":\"function\"},{\"constant\":true,\"inputs\":[],\"name\":\"get\",\"outputs\":[{\"name\":\"\",\"type\":\"uint256\"}],\"payable\":false,\"stateMutability\":\"view\",\"type\":\"function\"}]"
    let microChainAddressStr = "0xA4A1A503a02077146C620cb431B589a9d1DA55B6"
    let scsTxHash = "0x53bfd4754adc408f0d03b37161936423f523fd007248d182a40325918a797081"
    override func setUp() {
        let url = URL(string: "http://127.0.0.1:8545")!
        if let p = Chain3HttpProvider(url, network: 101, keystoreManager: nil) {
            provider = p
            localNodeFound = true
            Chain3.default = Chain3(provider: provider!)
        } else {
            localNodeFound = false
            print("local node not found")
        }
        let urlP = URL(string: "http://127.0.0.1:23456")!
        // network if here for SCS Chain3 is meaningless since we do not need to sign any thing for SCS requests. Its sole purpose is for local signing.
        if let scsP = Chain3HttpProvider(urlP, network: 101, keystoreManager: nil) {
            scsProvider = scsP
            localSCSNodeFound = true
        } else {
            localSCSNodeFound = false
            print("local SCS node not found")
        }
    }
    
    func testGetBalance() throws {
        let chain3 = Chain3(provider: provider!)
        let address = Address(addrOfBalanceCheck)
        let balance = try chain3.mc.getBalance(address: address)
        let balString = balance.string(units: .mc, decimals: 3)
        print(balString)
    }
    
    func testGetBalancePromise() {
        do {
            let chain3 = Chain3(provider: provider!)
            let balance = try chain3.mc.getBalancePromise(address: addrOfBalanceCheck).wait()
            print(balance)
        } catch {
            print(error)
        }
    }
    
    func testGetBlockByHash() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.mc.getBlockByHash("0x70efbab1f558047ab81d7ecc1b4c3df3820f7adf83300c11f366e7381a8a0be1", fullTransactions: true)
        print(result)
    }
    
    func testGetBlockByNumber1() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.mc.getBlockByNumber("latest", fullTransactions: true)
        print(result)
    }
    
    func testGetBlockByNumber2() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.mc.getBlockByNumber(UInt64(1418296), fullTransactions: true)
        print(result)
        let transactions = result.transactions
        for transaction in transactions {
            switch transaction {
            case let .transaction(tx):
                print(String(describing: tx))
            default:
                break
            }
        }
    }
    
    func testGetBlockByNumber3() {
        let chain3 = Chain3(provider: provider!)
        XCTAssertNoThrow(try chain3.mc.getBlockByNumber(UInt64(0x144F3B), fullTransactions: true))
    }
    
    func testGasPrice() throws {
        let chain3 = Chain3(provider: provider!)
        let gasPrice = try chain3.mc.getGasPrice()
        print(gasPrice)
    }
    
    func testTransactionReceipt() throws {
        let chain3 = Chain3(provider: provider!)
        let response = try chain3.mc.getTransactionReceipt(hashOfTxToInspect)
        XCTAssert(response.status == .ok)
    }
    
    func testTransactionDetails() throws {
        let chain3 = Chain3(provider: provider!)
        let response = try chain3.mc.getTransactionDetails(hashOfTxToInspect)
        print(response)
        switch response {
        case let .transaction(x):
            XCTAssert(x.gasLimit == BigUInt(7000000))
        default:
            print("not a transaction object")
        }
    }
    
    func testGetTransactionDetailsPromise() {
        do {
            let chain3 = Chain3(provider: provider!)
            let result = try chain3.mc.getTransactionDetailsPromise(hashOfTxToInspect).wait()
            print(result)
            switch result {
            case let .transaction(x):
                XCTAssert(x.gasLimit == BigUInt(7000000))
            default:
                print("not a transaction object")
            }
        } catch {
            print(error)
        }
    }
    
    func testGetAccounts() throws {
        let chain3 = Chain3(provider: provider!)
        let accounts = try chain3.mc.getAccounts()
        print(accounts)
        switch accounts.count {
        case 2:
            print(2)
        default:
            XCTFail()
            return
        }
    }
    
    func testUnlockAccountPromise() throws {
        let chain3 = Chain3(provider: provider!)
        let response = try chain3.personal.unlockAccountPromise(account: Address(addrOfBalanceCheck), password: "1111").wait()
        print(response)
        switch response {
        case false:
            XCTFail()
            return
        case true:
            print(response)
        }
    }
    
    func testImportAndExport() throws {
        let json = keystoreJSONStr
        let keystore = LBRKeystoreV3(json)!
        let data = try keystore.serialize()!
        let key = try keystore.UNSAFE_getPrivateKeyData(password: "1111", account: Address(addrOfBalanceCheck)).toHexString()
        
        let keystore2 = LBRKeystoreV3(data)!
        let data2 = try keystore2.serialize()!
        let key2 = try keystore2.UNSAFE_getPrivateKeyData(password: "1111", account: Address(addrOfBalanceCheck)).toHexString()
        
        XCTAssertEqual(data,data2)
        XCTAssertEqual(key,key2)
    }
    
    func testUnsignedSendMC() throws {
        let chain3 = Chain3(provider: provider!)
        let fromAddr = Address(addrOfBalanceCheck)
        _ = try chain3.personal.unlockAccountPromise(account: fromAddr, password: "1111").wait()
        let gasPrice = try chain3.mc.getGasPrice()
        let sendToAddress = Address(receivingTestnetAddr)
        let intermediate = try chain3.mc.sendMC(to: sendToAddress, amount: BigUInt(1))
        var options = Chain3Options.default
        options.from = fromAddr
        options.gasPrice = gasPrice
        // Have to use personal.unlock seperately first since the sendPromise's password param only works under signed tx
        let result = try intermediate.sendPromise(options: options).wait()
        print(result)
    }
    
    func testSignedSendMC() throws {
        let json = keystoreJSONStr
        guard let keystoreV3 = LBRKeystoreV3(json) else { return XCTFail() }
        let chain3 = Chain3(provider: provider!)
        let keystoreManager = KeystoreManager([keystoreV3])
        chain3.addKeystoreManager(keystoreManager)
        let gasPrice = try chain3.mc.getGasPrice()
        let fromAddr = Address(addrOfBalanceCheck)
        let sendToAddress = Address(receivingTestnetAddr)
        let intermediate = try chain3.mc.sendMC(to: sendToAddress, amount: BigUInt(1))
        var options = Chain3Options.default
        options.from = fromAddr
        options.gasPrice = gasPrice
        let result = try intermediate.sendPromise(password: "1111", options: options).wait()
        print(result)
    }
    
    
    /*
     Solidity source code to deploy for testing:
     
     pragma solidity ^0.4.24;
     
     contract SetGetSign {
         uint storedData;
     
         function set(uint x) public {
            storedData = x;
         }
     
         function get() public view returns (uint) {
            return storedData;
         }
     }
     */
    
    func testUnsignedContractSetterMethod() throws {
        
        let chain3 = Chain3(provider: provider!)
        let contractAddress = Address(contractAddrToCall)
        let contract = try chain3.contract(contractJsonStr, at: contractAddress)
        var options = Chain3Options.default
        options.from = Address(addrOfBalanceCheck)
        let newUInt = UInt.random(in: 0 ..< 10)
        print(newUInt)
        // Have to use personal.unlock seperately first since the sendPromise's password param only works under signed tx
        _ = try chain3.personal.unlockAccountPromise(account: Address(addrOfBalanceCheck), password: "1111").wait()
        let transactionIntermediateForSet = try contract.method("set", args: newUInt, options: options)
        let result = try transactionIntermediateForSet.sendPromise(options: options).wait()
        print(result)
    }
    
    func testSignedContractSetterMethod() throws {
        let chain3 = Chain3(provider: provider!)
        var options = Chain3Options.default
        options.from = Address(addrOfBalanceCheck)
        options.gasLimit = BigUInt(90000)
        let newUInt = UInt.random(in: 0 ..< 10)
//        _ = try chain3.personal.unlockAccountPromise(account: Address(addrOfBalanceCheck), password: "1111").wait()
        print(newUInt)
        let json = keystoreJSONStr
        guard let keystoreV3 = LBRKeystoreV3(json) else { return XCTFail() }
        let keystoreManager = KeystoreManager([keystoreV3])
        chain3.addKeystoreManager(keystoreManager)
        let contractAddress = Address(contractAddrToCall)
        let contract = try chain3.contract(contractJsonStr, at: contractAddress)
        let transactionIntermediateForSet = try contract.method("set", args: newUInt, options: options)
        let result = try transactionIntermediateForSet.sendPromise(password: "1111", options: options).wait()
        print(result)
    }
    
    func testContractGetterMethod() throws {
        let chain3 = Chain3(provider: provider!)
        let contractAddress = Address(contractAddrToCall)
        let contract = try chain3.contract(contractJsonStr, at: contractAddress)
        var options = Chain3Options.default
        options.from = Address(addrOfBalanceCheck)
        let transactionIntermediateForGet = try contract.method("get", options: options)
        let value = try transactionIntermediateForGet.call(options: options).uint256()
        print(value)
    }
    
    func testVnodeGetVnodeAddress() throws {
        let chain3 = Chain3(provider: provider!)
        let address = try chain3.vnode.getVnodeAddress().wait()
        print(address)
    }
    
    func testVnodeScsServiceEnabled() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.vnode.scsServiceEnabled().wait()
        print(result)
    }
    
    func testVnodeGetServiceCfg() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.vnode.getServiceCfg().wait()
        print(result)
    }
    
    func testVnodeShowToPublicEnabled() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.vnode.showToPublicEnabled().wait()
        print(result)
    }
    
    func testVnodeGetVnodeIP() throws {
        let chain3 = Chain3(provider: provider!)
        let result = try chain3.vnode.getVnodeIP().wait()
        print(result)
    }
    
    func testSCSGetMicroChainList() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getMicroChainList().wait()
        print(result)
    }
    
    func testSCSGetDappState() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getDappState(chainAddr: microChainAddressStr).wait()
        print(result)
    }
    
//    func testSCSGetBlockEarliest() throws {
//        let scsChain3 = Chain3(provider: scsProvider!)
//        let result = try scsChain3.scs.getBlock(chainAddr: microChainAddressStr, "earliest")
//        print(result)
//    }
//
//    func testSCSGetBlockLatest() throws {
//        let scsChain3 = Chain3(provider: scsProvider!)
//        let result = try scsChain3.scs.getBlock(chainAddr: microChainAddressStr, "latest")
//        print(result)
//    }
    
    func testSCSGetBlockByNumberUInt64() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getBlock(chainAddr: microChainAddressStr, UInt64(99))
        print(result)
    }
    
    func testSCSGetBlockByNumberBigUInt() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getBlock(chainAddr: microChainAddressStr, BigUInt(99))
        print(result)
    }
    
    func testSCSGetBlockNumber() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getBlockNumber(chainAddr: microChainAddressStr).wait()
        print(result.description)
    }
    
    func testSCSGetSCSId() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getSCSId().wait()
        print(result)
    }
    
    func testSCSGetMicroChainInfo() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getMicroChainInfo(chainAddr: microChainAddressStr).wait()
        print(result)
    }
    
    func testSCSGetNonce() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let scsid = try scsChain3.scs.getSCSId().wait()
        print(scsid.description)
        let result = try scsChain3.scs.getNonce(chainAddr: microChainAddressStr, scsAddr: scsid.description).wait()
        print(result)
    }
    
    func testSCSGetTransactionReceipt() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.getTransactionReceipt(chainAddr: microChainAddressStr, txHash: scsTxHash).wait()
        print(result)
    }
    
    func testSCSGetDirectCall() throws {
        let scsChain3 = Chain3(provider: scsProvider!)
        let result = try scsChain3.scs.directCall(to: "0xA4A1A503a02077146C620cb431B589a9d1DA55B6", data: "0x6d4ce63c").wait()
        print(result.hex)
    }
}

/*
 Solidity code for scs Dapp
 
 pragma solidity ^0.4.24;
 
 contract SetGetSign {
 uint storedData = 100;
 
 function set(uint x) public {
 storedData = x;
 }
 
 function get() public view returns (uint) {
 return storedData;
 }
 
 }
 */


