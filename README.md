# chain3swift

<p align="center">
<a href="https://developer.apple.com/swift/" target="_blank">
<img src="https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat" alt="Swift 4.2">
</a>
<a href="https://developer.apple.com/swift/" target="_blank">
<img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS%20%7C%20watchOS%20%7C%20tvOS%20%7C%20Linux%20-lightgray.svg?style=flat" alt="Platforms iOS | macOS">
</a>
<a target="_blank">
<img src="https://img.shields.io/badge/Supports-CocoaPods%20%7C%20Carthage%20%7C%20SwiftPM%20-orange.svg?style=flat" alt="Compatible">
</a>
<a target="_blank">
<img src="https://img.shields.io/badge/Supports-Objective%20C-blue.svg?style=flat" alt="Compatible">
</a>
</p>

- Swift implementation of [chain3.js](https://github.com/LBRChain/chain3/) functionality
- This project was forked from [web3swift](https://github.com/BANKEX/web3swift) v2.0.4
- Interaction with remote node via JSON RPC
- Smart-contract ABI parsing
- ABI deconding (V2 is supported with return of structures from public functions. Part of 0.4.22 Solidity compiler)
- RLP encoding
- Interactions (read/write to Smart contracts)
- Local keystore management (LBR compatible)

## Requirements

Chain3swift requires Swift 4.2 and deploys to `macOS 10.10`, `iOS 9`, `watchOS 2` and `tvOS 9` and `linux`.

Don't forget to set the iOS version in a Podfile, otherwise you get an error if the deployment target is less than the latest SDK.

## Installation

- **CocoaPods:** Put this in your `Podfile`:

  ```Ruby
  pod 'chain3swift', :git => 'https://github.com/liweiz/chain3swift.git'
  ```

## Design decisions

- Not every JSON RPC function is exposed yet, priority is given to the ones required for mobile devices
- Functionality was focused on serializing and signing transactions locally on the device to send raw transactions to Ethereum network
- Requirements for password input on every transaction are indeed a design decision. Interface designers can save user passwords with the user's consent
- Public function for private key export is exposed for user convenience, but marked as UNSAFE\_ :) Normal workflow takes care of EIP155 compatibility and proper clearing of private key data from memory

## Available functions

### MC

- [Chain3 instance with RPC connection](#chain3-instance-with-rpc-connection)
- [mc.getBalance](#mcgetbalance)
- [mc.getBlockByHash](#mcgetblockbyhash)
- [mc.getBlockByNumber](#mcgetblockbynumber)
- [mc.getGasPrice](#mcgetgasprice)
- [mc.getTransactionReceipt](#mcgettransactionreceipt)
- [mc.getTransactionDetails](#mcgettransactiondetails)
- [mc.getAccounts](#mcgetaccounts)
- [personal.unlockAccountPromise](#personalunlockaccountpromise)
- [Send unsigned MC transaction](#send-unsigned-mc-transaction)
- [Send signed MC transaction](#send-signed-mc-transaction)
- [Call unsigned state-changing method on deployed contract](#call-unsigned-state-changing-method-on-deployed-contract)
- [Call signed state-changing method on deployed contract](#call-signed-state-changing-method-on-deployed-contract)
- [Call unsigned non-state-changing method on deployed contract](#call-unsigned-non-state-changing-method-on-deployed-contract)

### VNODE

- [Returns the VNODE benificial address](#returns-the-VNODE-benificial-address)
- [Returns if the VNODE enable the service for SCS servers](#returns-if-the-VNODE-enable-the-service-for-SCS-servers)
- [Returns the VNODE SCS service port to connect](#returns-the-VNODE-SCS-service-port-to-connect)
- [Returns if the VNODE enables the public view](#returns-if-the-VNODE-enables-the-public-view)
- [Returns VNODE IP for users to access](#returns-VNODE-IP-for-users-to-access)

### SCS

- [Chain3 instance with SCS RPC connection](#chain3-instance-with-SCS-RPC-connection)
- [Returns the list of MicroChains on the connecting SCS](#returns-the-list-of-MicroChains-on-the-connecting-SCS)
- [Returns the Dapp state on the MicroChain](#returns-the-Dapp-state-on-the-MicroChain)
- [Returns information about a MicroChain block by block number](#returns-information-about-a-MicroChain-block-by-block-number)
- [Returns the number of most recent block on the MicroChain](#returns-the-number-of-most-recent-block-on-the-MicroChain)
- [Returns the SCS id](#returns-the-SCS-id)
- [Returns the requested MicroChain information on the connecting SCS](#returns-the-requested-MicroChain-information-on-the-connecting-SCS)
- [Returns the nonce of scsid](#returns-the-nonce-of-scsid)
- [Returns the receipt of a transaction by transaction hash](#returns-the-receipt-of-a-transaction-by-transaction-hash)
- [Executes a new constant call of the MicroChain Dapp function without creating a transaction on the MicroChain](#executes-a-new-constant-call-of-the-MicroChain-Dapp-function-without-creating-a-transaction-on-the-MicroChain)


### Chain3 instance with RPC connection

```swift
let url = URL(string: "http://127.0.0.1:8545")!  // vnode rpc url to connect
var provider: Chain3HttpProvider? = nil
if let p = Chain3HttpProvider(url, network: 101, keystoreManager: nil) {
    provider = p
    let chain3 = Chain3(provider: provider!)
} else {
    // Handle error
}
```

### mc.getBalance

```swift
let address = Address(LBRAddressString)
let balance = try chain3.mc.getBalance(address: address)
```

### mc.getBlockByHash

```swift
let result = try chain3.mc.getBlockByHash(hashString, fullTransactions: true)
```

### mc.getBlockByNumber

```swift
let result = try chain3.mc.getBlockByNumber("latest", fullTransactions: true)
// OR
let result = try chain3.mc.getBlockByNumber(UInt64(blockNumberInt), fullTransactions: true)
// OR
let result = try chain3.mc.getBlockByNumber(UInt64(blockNumberHex), fullTransactions: true)
```

### mc.getGasPrice

```swift
let gasPrice = try chain3.mc.getGasPrice()
```

### mc.getTransactionReceipt

```swift
let response = try chain3.mc.getTransactionReceipt(hashStringOfTxToInspect)
```

### mc.getTransactionDetails

```swift
let response = try chain3.mc.getTransactionDetails(hashStringOfTxToInspect)
switch response {
case let .transaction(x):
    // process LBRTransaction instance x
default:
    // other situations
}
```

### mc.getAccounts

```swift
let accounts = try chain3.mc.getAccounts()
```

### personal.unlockAccountPromise

```swift
let response = try chain3.personal.unlockAccountPromise(account: Address(addressString), password: passwordString).wait()
```

### Send unsigned MC transaction

```swift
let fromAddr = Address(addrString)
// Have to use personal.unlock seperately first since the sendPromise's password param only works under signed tx
_ = try chain3.personal.unlockAccountPromise(account: fromAddr, password: passwordString).wait()
let gasPrice = try chain3.mc.getGasPrice()
let sendToAddress = Address(receivingAddrString)
let intermediate = try chain3.mc.sendMC(to: sendToAddress, amount: BigUInt(1))
var options = Chain3Options.default
options.from = fromAddr
options.gasPrice = gasPrice
let result = try intermediate.sendPromise(options: options).wait()
```

### Send signed MC transaction

```swift
let json = keystoreJSONString
guard let keystoreV3 = LBRKeystoreV3(json) else { // handle error }
let keystoreManager = KeystoreManager([keystoreV3])
chain3.addKeystoreManager(keystoreManager)
let gasPrice = try chain3.mc.getGasPrice()
let fromAddr = Address(addrString)
let sendToAddress = Address(receivingAddrString)
let intermediate = try chain3.mc.sendMC(to: sendToAddress, amount: BigUInt(1))
var options = Chain3Options.default
options.from = fromAddr
options.gasPrice = gasPrice
let result = try intermediate.sendPromise(password: passwordString, options: options).wait()
```

### Call unsigned state-changing method on deployed contract

```swift
let contractAddress = Address(contractAddrStringToCall)
let contract = try chain3.contract(contractABIJsonString, at: contractAddress)
var options = Chain3Options.default
options.from = Address(addrString)
// Have to use personal.unlock seperately first since the sendPromise's password param only works under signed tx
_ = try chain3.personal.unlockAccountPromise(account: Address(addrString), password: passwordString).wait()
let transactionIntermediateForSet = try contract.method(setterNameString, args: inputsArray, options: options)
let result = try transactionIntermediateForSet.sendPromise(options: options).wait()
```

### Call signed state-changing method on deployed contract

Manually and explicitly setting gas limit for the signed call is necessary here.

```swift
var options = Chain3Options.default
options.from = Address(addrString)
options.gasLimit = BigUInt(90000)
let json = keystoreJSONString
guard let keystoreV3 = LBRKeystoreV3(json) else { // Handle error }
let keystoreManager = KeystoreManager([keystoreV3])
chain3.addKeystoreManager(keystoreManager)
let contractAddress = Address(contractAddrStringToCall)
let contract = try chain3.contract(contractABIJsonString, at: contractAddress)
let transactionIntermediateForSet = try contract.method(setterNameString, args: inputsArray, options: options)
let result = try transactionIntermediateForSet.sendPromise(password: passwordString, options: options).wait()
```

### Call unsigned non-state-changing method on deployed contract

```swift
let contractAddress = Address(contractAddrStringToCall)
let contract = try chain3.contract(contractABIJsonString, at: contractAddress)
var options = Chain3Options.default
options.from = Address(addrString)
let transactionIntermediateForGet = try contract.method(getterNameString, options: options)
let value = try transactionIntermediateForGet.call(options: options)
```

### Returns the VNODE benificial address

```swift
let address = try chain3.vnode.getVnodeAddress().wait()
```

### Returns if the VNODE enable the service for SCS servers

```swift
let result = try chain3.vnode.scsServiceEnabled().wait()
```

### Returns the VNODE SCS service port to connect

```swift
let result = try chain3.vnode.getServiceCfg().wait()
```

### Returns if the VNODE enables the public view

```swift
let result = try chain3.vnode.showToPublicEnabled().wait()
```

### Returns VNODE IP for users to access

```swift
let result = try chain3.vnode.getVnodeIP().wait()
```

### Chain3 instance with SCS RPC connection

```swift
let url = URL(string: "http://127.0.0.1:23456")!
// network if here for SCS Chain3 is meaningless since we do not need to sign any thing for SCS requests. Its sole purpose is for local signing.
var provider: Chain3HttpProvider? = nil
if let p = Chain3HttpProvider(url, network: 101, keystoreManager: nil) {
    provider = p
    let scsChain3 = Chain3(provider: provider!)
} else {
    // Handle error
}
```

### Returns the list of MicroChains on the connecting SCS

```swift
let result = try scsChain3.scs.getMicroChainList().wait()
```

### Returns the Dapp state on the MicroChain

```swift
let result = try scsChain3.scs.getDappState(chainAddr: microChainAddressStr).wait()
```

### Returns information about a MicroChain block by block number

```swift
let resultA = try scsChain3.scs.getBlock(chainAddr: microChainAddressStr, UInt64(99))
let resultB = try scsChain3.scs.getBlock(chainAddr: microChainAddressStr, BigUInt(99))
```

### Returns the number of most recent block on the MicroChain

```swift
let result = try scsChain3.scs.getBlockNumber(chainAddr: microChainAddressStr).wait()
```

### Returns the SCS id

```swift
let result = try scsChain3.scs.getSCSId().wait()
```

### Returns the requested MicroChain information on the connecting SCS

```swift
let result = try scsChain3.scs.getMicroChainInfo(chainAddr: microChainAddressStr).wait()
```

### Returns the nonce of scsid

```swift
let scsid = try scsChain3.scs.getSCSId().wait()
let result = try scsChain3.scs.getNonce(chainAddr: microChainAddressStr, scsAddr: scsid.description).wait()
```

### Returns the receipt of a transaction by transaction hash

```swift
let result = try scsChain3.scs.getTransactionReceipt(chainAddr: microChainAddressStr, txHash: scsTxHash).wait()
```

### Executes a new constant call of the MicroChain Dapp function without creating a transaction on the MicroChain

```swift
let result = try scsChain3.scs.directCall(to: "0xA4A1A503a02077146C620cb431B589a9d1DA55B6", data: "0x6d4ce63c").wait()
```

## Future plans

- Full reference `chain3js` functionality

## License

chain3swift is available under the Apache License 2.0 license. See the [LICENSE](https://github.com/liweiz/chain3swift/blob/master/LICENSE.md) file for more info.
