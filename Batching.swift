//
//  Promise+Batching.swift
//  chain3swift
//
//  Created by Alexander Vlasov on 17.06.2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import PromiseKit

public class JsonRpcRequestDispatcher {
    public var MAX_WAIT_TIME: TimeInterval = 0.1
    public var policy: DispatchPolicy
    public var queue: DispatchQueue

    private var provider: Chain3Provider
    private var lockQueue: DispatchQueue
    private var batches: [Batch] = [Batch]()

    init(provider: Chain3Provider, queue: DispatchQueue, policy: DispatchPolicy) {
        self.provider = provider
        self.queue = queue
        self.policy = policy
        lockQueue = DispatchQueue(label: "batchingQueue") // serial simplest queue
//        DispatchQueue(label: "batchingQueue", qos: .userInitiated)
        batches.append(Batch(provider: self.provider, capacity: 32, queue: self.queue, lockQueue: lockQueue))
    }

    internal final class Batch {
        var capacity: Int
        var promisesDict: [UInt64: (promise: Promise<JsonRpcResponse>, resolver: Resolver<JsonRpcResponse>)] = [UInt64: (promise: Promise<JsonRpcResponse>, resolver: Resolver<JsonRpcResponse>)]()
        var requests: [JsonRpcRequest] = [JsonRpcRequest]()
        var pendingTrigger: Guarantee<Void>?
        var provider: Chain3Provider
        var queue: DispatchQueue
        var lockQueue: DispatchQueue
        var triggered: Bool = false
        func add(_ request: JsonRpcRequest, maxWaitTime: TimeInterval) throws -> Promise<JsonRpcResponse> {
            if triggered {
                throw Chain3Error.nodeError("Batch is already in flight")
            }
            let requestID = request.id
            let promiseToReturn = Promise<JsonRpcResponse>.pending()
            lockQueue.async {
                if self.promisesDict[requestID] != nil {
                    promiseToReturn.resolver.reject(Chain3Error.processingError("Request ID collision"))
                }
                self.promisesDict[requestID] = promiseToReturn
                self.requests.append(request)
                if self.pendingTrigger == nil {
                    self.pendingTrigger = after(seconds: maxWaitTime).done(on: self.queue) {
                        self.trigger()
                    }
                }
                if self.requests.count == self.capacity {
                    self.trigger()
                }
            }
            return promiseToReturn.promise
        }

        func trigger() {
            lockQueue.async {
                guard !self.triggered else { return }
                self.triggered = true
                let requestsBatch = JsonRpcRequestBatch(requests: self.requests)
                self.provider.sendAsync(requestsBatch, queue: self.queue).done(on: self.queue) { batch in
                    for response in batch.responses {
                        if self.promisesDict[UInt64(response.id)] == nil {
                            for k in self.promisesDict.keys {
                                self.promisesDict[k]?.resolver.reject(Chain3Error.nodeError("Unknown request id"))
                            }
                            return
                        }
                    }
                    for response in batch.responses {
                        let promise = self.promisesDict[UInt64(response.id)]!
                        promise.resolver.fulfill(response)
                    }
                }.catch(on: self.queue) { err in
                    for k in self.promisesDict.keys {
                        self.promisesDict[k]?.resolver.reject(err)
                    }
                }
            }
        }

        init(provider: Chain3Provider, capacity: Int, queue: DispatchQueue, lockQueue: DispatchQueue) {
            self.provider = provider
            self.capacity = capacity
            self.queue = queue
            self.lockQueue = lockQueue
        }
    }

    func getBatch() throws -> Batch {
        guard case let .Batch(batchLength) = policy else {
            throw Chain3Error.inputError("Trying to batch a request when policy is not to batch")
        }
        let currentBatch = batches.last!
        if currentBatch.requests.count % batchLength == 0 || currentBatch.triggered {
            let newBatch = Batch(provider: provider, capacity: Int(batchLength), queue: queue, lockQueue: lockQueue)
            batches.append(newBatch)
            return newBatch
        }
        return currentBatch
    }

    public enum DispatchPolicy {
        case Batch(Int)
        case NoBatching
    }

    func addToQueue(request: JsonRpcRequest) -> Promise<JsonRpcResponse> {
        switch policy {
        case .NoBatching:
            return provider.sendAsync(request, queue: queue)
        case .Batch:
            let promise = Promise<JsonRpcResponse> {
                seal in
                self.lockQueue.async {
                    do {
                        let batch = try self.getBatch()
                        let internalPromise = try batch.add(request, maxWaitTime: self.MAX_WAIT_TIME)
                        internalPromise.done(on: self.queue) { resp in
                            seal.fulfill(resp)
                        }.catch(on: self.queue) { err in
                            seal.reject(err)
                        }
                    } catch {
                        seal.reject(error)
                    }
                }
            }
            return promise
        }
    }
}
