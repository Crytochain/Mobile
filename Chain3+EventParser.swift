//
//  Chain3+TransactionIntermediate.swift
//  chain3swift-iOS
//
//  Created by Alexander Vlasov on 26.02.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import BigInt
import Foundation
import PromiseKit

extension Chain3Contract {
    /// An event parser to fetch events produced by smart-contract related transactions. Should not be constructed manually, but rather by calling the corresponding function on the Chain3Contract object.
    public struct EventParser: EventParserProtocol {
        public var contract: ContractProtocol
        public var eventName: String
        public var filter: EventFilter?
        var chain3: Chain3
        public init? (chain3 chain3Instance: Chain3, eventName: String, contract: ContractProtocol, filter: EventFilter? = nil) {
            guard let _ = contract.allEvents.index(of: eventName) else { return nil }
            self.eventName = eventName
            chain3 = chain3Instance
            self.contract = contract
            self.filter = filter
        }
        
        /**
         Parses the transaction for events matching the EventParser settings.
         - parameter transaction: chain3swift native LBRTransaction object
         - returns: array of events
         - important: This call is synchronous
         */
        public func parseTransaction(_ transaction: LBRTransaction) throws -> [EventParserResultProtocol] {
            return try parseTransactionPromise(transaction).wait()
        }

        /**
         Parses the transaction for events matching the EventParser settings.
         - parameter hash: Transaction hash
         - returns: array of events
         - important: This call is synchronous
         */
        public func parseTransactionByHash(_ hash: Data) throws -> [EventParserResultProtocol] {
            return try parseTransactionByHashPromise(hash).wait()
        }
        
        /**
         Parses the block for events matching the EventParser settings.
         - parameter blockNumber: LBR network block number
         - returns: array of events
         - important: This call is synchronous
         */
        public func parseBlockByNumber(_ blockNumber: UInt64) throws -> [EventParserResultProtocol] {
            return try parseBlockByNumberPromise(blockNumber).wait()
        }

        /**
         Parses the block for events matching the EventParser settings.
         - parameter block: Native chain3swift block object
         - returns: array of events
         - important: This call is synchronous
         */
        public func parseBlock(_ block: Block) throws -> [EventParserResultProtocol] {
            return try parseBlockPromise(block).wait()
        }
    }
}

extension Chain3Contract.EventParser {
    /**
     Parses the transaction for events matching the EventParser settings.
     - parameter transaction: chain3swift native LBRTransaction object
     - returns: promise that returns array of events
     - important: This call is synchronous
     */
    public func parseTransactionPromise(_ transaction: LBRTransaction) -> Promise<[EventParserResultProtocol]> {
        let queue = chain3.requestDispatcher.queue
        do {
            guard let hash = transaction.hash else {
                throw Chain3Error.processingError("Failed to get transaction hash") }
            return parseTransactionByHashPromise(hash)
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }

    /**
     Parses the transaction for events matching the EventParser settings.
     - parameter hash: Transaction hash
     - returns: promise that returns array of events
     - important: This call is synchronous
     */
    public func parseTransactionByHashPromise(_ hash: Data) -> Promise<[EventParserResultProtocol]> {
        let queue = chain3.requestDispatcher.queue
        return chain3.mc.getTransactionReceiptPromise(hash).map(on: queue) { receipt throws -> [EventParserResultProtocol] in
            guard let results = parseReceiptForLogs(receipt: receipt, contract: self.contract, eventName: self.eventName, filter: self.filter) else {
                throw Chain3Error.processingError("Failed to parse receipt for events")
            }
            return results
        }
    }

    /**
     Parses the block for events matching the EventParser settings.
     - parameter blockNumber: LBR network block number
     - returns: promise that returns array of events
     - important: This call is synchronous
     */
    public func parseBlockByNumberPromise(_ blockNumber: UInt64) -> Promise<[EventParserResultProtocol]> {
        let queue = chain3.requestDispatcher.queue
        do {
            if filter != nil && (filter?.fromBlock != nil || filter?.toBlock != nil) {
                throw Chain3Error.inputError("Can not mix parsing specific block and using block range filter")
            }
            return chain3.mc.getBlockByNumberPromise(blockNumber).then(on: queue) { res in
                self.parseBlockPromise(res)
            }
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }

    /**
     Parses the block for events matching the EventParser settings.
     - parameter block: Native chain3swift block object
     - returns: promise that returns array of events
     - important: This call is synchronous
     */
    public func parseBlockPromise(_ block: Block) -> Promise<[EventParserResultProtocol]> {
        let queue = chain3.requestDispatcher.queue
        do {
            guard let bloom = block.logsBloom else {
                throw Chain3Error.processingError("Block doesn't have a bloom filter log")
            }
            if contract.address != nil {
                let addressPresent = block.logsBloom?.test(topic: contract.address!.addressData)
                if addressPresent != true {
                    let returnPromise = Promise<[EventParserResultProtocol]>.pending()
                    queue.async {
                        returnPromise.resolver.fulfill([EventParserResultProtocol]())
                    }
                    return returnPromise.promise
                }
            }
            guard let eventOfSuchTypeIsPresent = self.contract.testBloomForEventPrecence(eventName: self.eventName, bloom: bloom) else {
                throw Chain3Error.processingError("Error processing bloom for events")
            }
            if !eventOfSuchTypeIsPresent {
                let returnPromise = Promise<[EventParserResultProtocol]>.pending()
                queue.async {
                    returnPromise.resolver.fulfill([EventParserResultProtocol]())
                }
                return returnPromise.promise
            }
            return Promise { seal in

                var pendingEvents: [Promise<[EventParserResultProtocol]>] = [Promise<[EventParserResultProtocol]>]()
                for transaction in block.transactions {
                    switch transaction {
                    case .null:
                        seal.reject(Chain3Error.processingError("No information about transactions in block"))
                        return
                    case let .transaction(tx):
                        guard let hash = tx.hash else {
                            seal.reject(Chain3Error.processingError("Failed to get transaction hash"))
                            return
                        }
                        let subresultPromise = self.parseTransactionByHashPromise(hash)
                        pendingEvents.append(subresultPromise)
                    case let .hash(hash):
                        let subresultPromise = self.parseTransactionByHashPromise(hash)
                        pendingEvents.append(subresultPromise)
                    }
                }
                when(resolved: pendingEvents).done(on: queue) { (results: [Result<[EventParserResultProtocol]>]) throws in
                    var allResults = [EventParserResultProtocol]()
                    for res in results {
                        guard case let .fulfilled(subresult) = res else {
                            throw Chain3Error.processingError("Failed to parse event for one transaction in block")
                        }
                        allResults.append(contentsOf: subresult)
                    }
                    seal.fulfill(allResults)
                }.catch(on: queue) { err in
                    seal.reject(err)
                }
            }
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}

extension Chain3Contract {
    /**
     Fetches events by doing a lookup on "indexed" parameters of the event. Smart-contract developer can make some of event values "indexed" for such fast queries.
     - parameter eventName: Event name, should be present in ABI interface of the contract
     - parameter filter: EventFilter object setting the block limits for query
     - parameter joinWithReceipts: Bool indicating whether TransactionReceipt should be fetched separately for every matched transaction
     - returns: array of events
     - important: This call is synchronous
     */
    public func getIndexedEvents(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) throws -> [EventParserResultProtocol] {
        return try getIndexedEventsPromise(eventName: eventName, filter: filter, joinWithReceipts: joinWithReceipts).wait()
    }
    
    /**
     Fetches events by doing a lookup on "indexed" parameters of the event. Smart-contract developer can make some of event values "indexed" for such fast queries.
     - parameter eventName: Event name, should be present in ABI interface of the contract
     - parameter filter: EventFilter object setting the block limits for query
     - parameter joinWithReceipts: Bool indicating whether TransactionReceipt should be fetched separately for every matched transaction
     - returns: promise that returns array of events
     - important: This call is synchronous
     */
    public func getIndexedEventsPromise(eventName: String?, filter: EventFilter, joinWithReceipts: Bool = false) -> Promise<[EventParserResultProtocol]> {
        let queue = chain3.requestDispatcher.queue
        do {
            guard let rawContract = self.contract as? ContractV2 else {
                throw Chain3Error.nodeError("ABIv1 is not supported for this method")
            }
            guard let preEncoding = encodeTopicToGetLogs(contract: rawContract, eventName: eventName, filter: filter) else {
                throw Chain3Error.processingError("Failed to encode topic for request")
            }
            //            var event: ABIv2.Element.Event? = nil
            if eventName != nil {
                guard let _ = rawContract.events[eventName!] else {
                    throw Chain3Error.processingError("No such event in a contract")
                }
                //                event = ev
            }
            let request = JsonRpcRequestFabric.prepareRequest(.getLogs, parameters: [preEncoding])
            let fetchLogsPromise = chain3.dispatch(request).map(on: queue) { response throws -> [EventParserResult] in
                guard let value: [EventLog] = response.getValue() else {
                    if response.error != nil {
                        throw Chain3Error.nodeError(response.error!.message)
                    }
                    throw Chain3Error.nodeError("Empty or malformed response")
                }
                let allLogs = value
                let decodedLogs = allLogs.compactMap({ (log) -> EventParserResult? in
                    let (n, d) = self.contract.parseEvent(log)
                    guard let evName = n, let evData = d else { return nil }
                    var res = EventParserResult(eventName: evName, transactionReceipt: nil, contractAddress: log.address, decodedResult: evData)
                    res.eventLog = log
                    return res
                }).filter { (res: EventParserResult?) -> Bool in
                    if eventName != nil {
                        if res != nil && res?.eventName == eventName && res!.eventLog != nil {
                            return true
                        }
                    } else {
                        if res != nil && res!.eventLog != nil {
                            return true
                        }
                    }
                    return false
                }
                return decodedLogs
            }
            if !joinWithReceipts {
                return fetchLogsPromise.mapValues(on: queue) { res -> EventParserResultProtocol in
                    res as EventParserResultProtocol
                }
            }
            return fetchLogsPromise.thenMap(on: queue) { singleEvent in
                self.chain3.mc.getTransactionReceiptPromise(singleEvent.eventLog!.transactionHash).map(on: queue) { receipt in
                    var joinedEvent = singleEvent
                    joinedEvent.transactionReceipt = receipt
                    return joinedEvent as EventParserResultProtocol
                }
            }
        } catch {
            let returnPromise = Promise<[EventParserResultProtocol]>.pending()
            queue.async {
                returnPromise.resolver.reject(error)
            }
            return returnPromise.promise
        }
    }
}
