//
//  SecurityToken.swift
//  chain3swift
//
//  Created by Dmitry on 12/11/2018.
//  Copyright © 2018 Bankex Foundation. All rights reserved.
//
//  Modifications copyright © 2018 Liwei Zhang. All rights reserved.
//

import Foundation
import PromiseKit
import BigInt

/** ISecurityToken.sol
 * ERC20 events
 ``` solidity
 event Transfer(address indexed from, address indexed to, uint256 value);
 event Approval(address indexed owner, address indexed spender, uint256 value);
 ```
 
 * Mint events
 ``` solidity
 event Minted(address indexed _to, uint256 _value);
 event Burnt(address indexed _burner, uint256 _value);
 ```
 */
public class SecurityToken {
    /// Token address
    public let address: Address
    /// Transaction Options
    public var options: Chain3Options = .default
    /// Password to unlock private key for sender address
    public var password: String = "BANKEXFOUNDATION"
    
    /// Represents Address as ERC20 token (with standart password and options)
    /// - parameter address: Token address
    public init(_ address: Address) {
        self.address = address
    }
    
    /// Represents Address as ERC20 token
    /// - parameter address: Token address
    /// - parameter from: Sender address
    /// - parameter address: Password to decrypt sender's private key
    public init(_ address: Address, from: Address, password: String) {
        self.address = address
        options.from = from
        self.password = password
    }
    public func decimals() throws -> BigUInt {
        return try address.call("decimals()").wait().uint256()
    }
    
    public func totalSupply() throws -> BigUInt {
        return try address.call("totalSupply()").wait().uint256()
    }
    
    public func balance(of owner: Address) throws -> BigUInt {
        return try address.call("balanceOf(address)", owner).wait().uint256()
    }
    
    public func allowance(owner: Address, spender: Address) throws -> BigUInt {
        return try address.call("allowance(address,address)", owner, spender).wait().uint256()
    }
    
    public func transfer(to: Address, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("transfer(address,uint256)", to, value).wait()
    }
    
    public func transfer(from: Address, to: Address, spender: Address) throws -> TransactionSendingResult {
        return try address.send("transferFrom(address,address,uint256)", from, to, spender).wait()
    }
    
    public func approve(spender: Address, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("approve(address,uint256)", spender, value).wait()
    }
    
    public func decreaseApproval(spender: Address, subtractedValue: BigUInt) throws -> TransactionSendingResult {
        return try address.send("decreaseApproval(address,uint256)", spender, subtractedValue).wait()
    }
    
    public func increaseApproval(spender: Address, addedValue: BigUInt) throws -> TransactionSendingResult {
        return try address.send("increaseApproval(address,uint256)", spender, addedValue).wait()
    }
    
    /**
     transfer, transferFrom must respect the result of verifyTransfer
     solidity interface:
     ``` solidity
     function verifyTransfer(address _from, address _to, uint256 _value) external returns (bool success);
     ```
     */
    public func verifyTransfer(from: Address, to: Address, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("verifyTransfer(address,address,value)", from, to, value).wait()
    }
    
    /**
     Mints new tokens and assigns them to the target _investor.
     Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     - parameter investor: Address the tokens will be minted to
     - parameter value: is the amount of tokens that will be minted to the investor
     
     solidity interface:
     ``` solidity
     function mint(address _investor, uint256 _value) external returns (bool success);
     ```
     */
    public func mint(investor: Address, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("mint(address,uint256)", investor, value).wait()
    }
    
    /**
     Mints new tokens and assigns them to the target _investor.
     Can only be called by the STO attached to the token (Or by the ST owner if there's no STO attached yet)
     - parameter investor: Address the tokens will be minted to
     - parameter value: is The amount of tokens that will be minted to the investor
     - parameter data: Data to indicate validation
     
     solidity interface:
     ``` solidity
     function mintWithData(address _investor, uint256 _value, bytes _data) external returns (bool success);
     ```
     */
    public func mint(investor: Address, value: BigUInt, data: Data) throws -> TransactionSendingResult {
        return try address.send("mintWithData(address,uint256,bytes)", investor, value, data).wait()
    }
    
    
    /**
     Used to burn the securityToken on behalf of someone else
     - parameter from: Address for whom to burn tokens
     - parameter value: No. of tokens to be burned
     - parameter data: Data to indicate validation
     
     solidity interface:
     ``` solidity
     function burnFromWithData(address _from, uint256 _value, bytes _data) external;
     ```
     */
    public func burn(from: Address, value: BigUInt, data: Data) throws -> TransactionSendingResult {
        return try address.send("burnFromWithData(address,uint256,bytes)", from, value, data).wait()
    }
    
    
    /**
     Used to burn the securityToken
     - parameter value: No. of tokens to be burned
     - parameter data: Data to indicate validation
     
     solidity interface:
     ``` solidity
     function burnWithData(uint256 _value, bytes _data) external;
     ```
     */
    public func burn(value: BigUInt, data: Data) throws -> TransactionSendingResult {
        return try address.send("burnWithData(uint256 _value, bytes _data)", value, data).wait()
    }
    
    /**
     Permissions this to a Permission module, which has a key of 1
     If no Permission return false - note that IModule withPerm will allow ST owner all permissions anyway
     this allows individual modules to override this logic if needed (to not allow ST owner all permissions)
     
     solidity interface:
     ``` solidity
     function checkPermission(address _delegate, address _module, bytes32 _perm) external view returns (bool);
     ```
     */
    
    public func checkPermission(delegate: Address, module: Address, perm: Data) throws -> Bool {
        return try address.call("checkPermission(address,address,bytes32)", delegate, module, perm).wait().bool()
    }
    
    public struct Module {
        /// Module name
        public var name: String
        /// Module address
        public var address: Address
        /// Module factory address
        public var factoryAddress: Address
        /// Module archived
        public var isArchived: Bool
        /// Module type
        public var type: UInt8
        /// Module index
        public var index: BigUInt
        /// Name index
        public var nameIndex: BigUInt
        public init(_ response: Chain3DataResponse) throws {
            name = try response.string()
            address = try response.address()
            factoryAddress = try response.address()
            isArchived = try response.bool()
            type = try response.uint8()
            index = try response.uint256()
            nameIndex = try response.uint256()
        }
    }
    /**
     Returns module list for a module type
     - parameter address: Address of the module
     
     solidity interface:
     ``` solidity
     function getModule(address _module) external view returns(bytes32, address, address, bool, uint8, uint256, uint256);
     ```
     */
    public func module(at address: Address) throws -> Module {
        let result = try self.address.call("getModule(address)", address).wait()
        let module = try Module(result)
        return module
    }
    
    /**
     Returns module list for a module name
     - parameter name: Name of the module
     - returns: address[] List of modules with this name
     
     solidity interface:
     ``` solidity
     function getModulesByName(bytes32 _name) external view returns (address[]);
     ```
     */
    public func modules(with name: String) throws -> [Address] {
        return try address.call("getModulesByName(bytes32)", name).wait().array { try $0.address() }
    }
    
    /**
     Returns module list for a module type
     - parameter type: Type of the module
     - returns: address[] List of modules with this type
     
     solidity interface:
     ``` solidity
     function getModulesByType(uint8 _type) external view returns (address[]);
     ```
     */
    public func modules(with type: UInt8) throws -> [Address] {
        return try address.call("getModulesByType(uint8)", type).wait().array { try $0.address() }
    }
    
    
    /**
     Queries totalSupply at a specified checkpoint
     - parameter checkpointId: Checkpoint ID to query as of
     
     solidity interface:
     ``` solidity
     function totalSupplyAt(uint256 _checkpointId) external view returns (uint256);
     ```
     */
    public func totalSupply(at checkpointId: BigUInt) throws -> BigUInt {
        return try address.call("totalSupplyAt(uint256)", checkpointId).wait().uint256()
    }
    
    /**
     Queries balance at a specified checkpoint
     - parameter investor: Investor to query balance for
     - parameter checkpointId: Checkpoint ID to query as of
     
     solidity interface:
     ``` solidity
     function balanceOfAt(address _investor, uint256 _checkpointId) external view returns (uint256);
     ```
     */
    public func balance(at investor: Address, checkpointId: BigUInt) throws -> BigUInt {
        return try address.call("balanceOfAt(address,uint256)").wait().uint256()
    }
    
    /**
     Creates a checkpoint that can be used to query historical balances / totalSuppy
     
     solidity interface:
     ``` solidity
     function createCheckpoint() external returns (uint256);
     ```
     */
    public func createCheckpoint() throws -> TransactionSendingResult {
        return try address.send("createCheckpoint()").wait()
    }
    
    
    /**
     Gets length of investors array
     NB - this length may differ from investorCount if the list has not been pruned of zero-balance investors
     - returns: Length
     
     solidity interface:
     ``` solidity
     function getInvestors() external view returns (address[]);
     ```
     */
    public func investors() throws -> [Address] {
        return try address.call("getInvestors()").wait().array { try $0.address() }
    }
    
    /**
     returns an array of investors at a given checkpoint
     NB - this length may differ from investorCount as it contains all investors that ever held tokens
     - parameter checkpointId: Checkpoint id at which investor list is to be populated
     - returns: list of investors
     
     solidity interface:
     ``` solidity
     function getInvestorsAt(uint256 _checkpointId) external view returns(address[]);
     ```
     */
    public func investors(at checkpointId: BigUInt) throws -> [Address] {
        return try address.call("getInvestorsAt(uint256)").wait().array { try $0.address() }
    }
    
    /**
     generates subset of investors
     NB - can be used in batches if investor list is large
     - parameter start: Position of investor to start iteration from
     - parameter end: Position of investor to stop iteration at
     - returns: list of investors
     
     solidity interface:
     ``` solidity
     function iterateInvestors(uint256 _start, uint256 _end) external view returns(address[]);
     ```
     */
    public func iterateInvestors(start: BigUInt, end: BigUInt) throws -> [Address] {
        return try address.call("iterateInvestors(uint256,uint256)",start,end).wait().array { try $0.address() }
    }
    
    /**
     Gets current checkpoint ID
     - returns: Id
     
     solidity interface:
     ``` solidity
     function currentCheckpointId() external view returns (uint256);
     ```
     */
    public func currentCheckpointId() throws -> BigUInt {
        return try address.call("currentCheckpointId()").wait().uint256()
    }
    
    /**
     Gets an investor at a particular index
     - parameter index: Index to return address from
     - returns: Investor address
     
     solidity interface:
     ``` solidity
     function investors(uint256 _index) external view returns (address);
     ```
     */
    public func investors(index: BigUInt) throws -> Address {
        return try address.call("investors(uint256)", index).wait().address()
    }
    
    /**
     Allows the owner to withdraw unspent POLY stored by them on the ST or any ERC20 token.
     @dev Owner can transfer POLY to the ST which will be used to pay for modules that require a POLY fee.
     - parameter tokenContract: Address of the ERC20Basic compliance token
     - parameter value: Amount of POLY to withdraw
     
     solidity interface:
     ``` solidity
     function withdrawERC20(address _tokenContract, uint256 _value) external;
     ```
     */
    public func withdrawERC20(tokenContract: Address, value: BigUInt) throws -> TransactionSendingResult {
        return try address.send("withdrawERC20(address,uint256)", tokenContract, value).wait()
    }
    
    /**
     Allows owner to approve more POLY to one of the modules
     - parameter module: Module address
     - parameter budget: New budget
     
     solidity interface:
     ``` solidity
     function changeModuleBudget(address _module, uint256 _budget) external;
     ```
     */
    public func changeModuleBudget(module: Address, budget: BigUInt) throws -> TransactionSendingResult {
        return try address.send("changeModuleBudget(address,uint256)", module, budget).wait()
    }
    
    /**
     Changes the tokenDetails
     - parameter newTokenDetails: New token details
     
     solidity interface:
     ``` solidity
     function updateTokenDetails(string _newTokenDetails) external;
     ```
     */
    public func updateTokenDetails(newTokenDetails: String) throws -> TransactionSendingResult {
        return try address.send("updateTokenDetails(string)", newTokenDetails).wait()
    }
    
    /**
     Allows the owner to change token granularity
     - parameter granularity: Granularity level of the token
     
     solidity interface:
     ``` solidity
     function changeGranularity(uint256 _granularity) external;
     ```
     */
    public func changeGranularity(granularity: BigUInt) throws -> TransactionSendingResult {
        return try address.send("changeGranularity(uint256)", granularity).wait()
    }
    
    /**
     Removes addresses with zero balances from the investors list
     - parameter start: Index in investors list at which to start removing zero balances
     - parameter iters: Max number of iterations of the for loop
     NB - pruning this list will mean you may not be able to iterate over investors on-chain as of a historical checkpoint
     
     solidity interface:
     ``` solidity
     function pruneInvestors(uint256 _start, uint256 _iters) external;
     ```
     */
    public func pruneInvestors(start: BigUInt, iters: BigUInt) throws -> TransactionSendingResult {
        return try address.send("pruneInvestors(uint256,uint256)", start, iters).wait()
    }
    
    /**
     Freezes all the transfers
     
     solidity interface:
     ``` solidity
     function freezeTransfers() external;
     ```
     */
    public func freezeTransfers() throws -> TransactionSendingResult {
        return try address.send("freezeTransfers()").wait()
    }
    
    /**
     Un-freezes all the transfers
     
     solidity interface:
     ``` solidity
     function unfreezeTransfers() external;
     ```
     */
    public func unfreezeTransfers() throws -> TransactionSendingResult {
        return try address.send("unfreezeTransfers()").wait()
    }
    
    /**
     Ends token minting period permanently
     
     solidity interface:
     ``` solidity
     function freezeMinting() external;
     ```
     */
    public func freezeMinting() throws -> TransactionSendingResult {
        return try address.send("freezeMinting()").wait()
    }
    
    /**
     Mints new tokens and assigns them to the target investors.
     Can only be called by the STO attached to the token or by the Issuer (Security Token contract owner)
     - parameter investors: A list of addresses to whom the minted tokens will be delivered
     - parameter values: A list of the amount of tokens to mint to corresponding addresses from _investor[] list
     - returns: Success
     
     solidity interface:
     ``` solidity
     function mintMulti(address[] _investors, uint256[] _values) external returns (bool success);
     ```
     */
    public func mintMulti(investors: [Address], values: [BigUInt]) throws -> TransactionSendingResult {
        return try address.send("mintMulti(address[],uint256[])", investors, values).wait()
    }
    
    /**
     function used to attach a module to the security token
     E.G.: On deployment (through the STR) ST gets a TransferManager module attached to it
     to control restrictions on transfers.
     You are allowed to add a new moduleType if:
     - there is no existing module of that type yet added
     - the last member of the module list is replacable
     - parameter moduleFactory: is the address of the module factory to be added
     - parameter data: is data packed into bytes used to further configure the module (See STO usage)
     - parameter maxCost: max amount of POLY willing to pay to module. (WIP)
     
     
     solidity interface:
     ``` solidity
     function addModule(
     address _moduleFactory,
     bytes _data,
     uint256 _maxCost,
     uint256 _budget
     ) external;
     ```
     */
    public func addModule(moduleFactory: Address, data: Data, maxCost: BigUInt, budget: BigUInt) throws -> TransactionSendingResult {
        return try address.send("addModule(address,bytes,uint256,uint256)", moduleFactory, data, maxCost, budget).wait()
    }
    
    /**
     Archives a module attached to the SecurityToken
     - parameter module: address of module to archive
     
     solidity interface:
     ``` solidity
     function archiveModule(address _module) external;
     ```
     */
    public func archive(module: Address) throws -> TransactionSendingResult {
        return try address.send("archiveModule(address)", module).wait()
    }
    
    /**
     Unarchives a module attached to the SecurityToken
     - parameter module: address of module to unarchive
     
     solidity interface:
     ``` solidity
     function unarchiveModule(address _module) external;
     ```
     */
    public func unarchive(module: Address) throws -> TransactionSendingResult {
        return try address.send("unarchiveModule(address)", module).wait()
    }
    
    /**
     Removes a module attached to the SecurityToken
     - parameter module: address of module to archive
     
     solidity interface:
     ``` solidity
     function removeModule(address _module) external;
     ```
     */
    public func remove(module: Address) throws -> TransactionSendingResult {
        return try address.send("removeModule(address)", module).wait()
    }
    
    /**
     Used by the issuer to set the controller addresses
     - parameter controller: address of the controller
     
     solidity interface:
     ``` solidity
     function setController(address _controller) external;
     ```
     */
    public func set(controller: Address) throws -> TransactionSendingResult {
        return try address.send("setController(address)", module).wait()
    }
    
    /**
     Used by a controller to execute a forced transfer
     - parameter from: address from which to take tokens
     - parameter to: address where to send tokens
     - parameter value: amount of tokens to transfer
     - parameter data: data to indicate validation
     - parameter log: data attached to the transfer by controller to emit in event
     
     solidity interface:
     ``` solidity
     function forceTransfer(address _from, address _to, uint256 _value, bytes _data, bytes _log) external;
     ```
     */
    public func forceTransfer(from: Address, to: Address, value: BigUInt, data: Data, log: Data) throws -> TransactionSendingResult {
        return try address.send("forceTransfer(address,address,uint256,bytes,bytes)", from, to, value, data, log).wait()
    }
    
    /**
     Used by a controller to execute a foced burn
     - parameter from: address from which to take tokens
     - parameter value: amount of tokens to transfer
     - parameter data: data to indicate validation
     - parameter log: data attached to the transfer by controller to emit in event
     
     solidity interface:
     ``` solidity
     function forceBurn(address _from, uint256 _value, bytes _data, bytes _log) external;
     ```
     */
    public func forceBurn(from: Address, value: BigUInt, data: Data, log: Data) throws -> TransactionSendingResult {
        return try address.send("forceBurn(address,uint256,bytes,bytes)", from, value, data, log).wait()
    }
    
    /**
     Used by the issuer to permanently disable controller functionality
     @dev enabled via feature switch "disableControllerAllowed"
     
     solidity interface:
     ``` solidity
     function disableController() external;
     ```
     */
    public func disableController() throws -> TransactionSendingResult {
        return try address.send("disableController()").wait()
    }
    
    
    /**
     Used to get the version of the securityToken
     
     solidity interface:
     ``` solidity
     function getVersion() external view returns(uint8[]);
     ```
     */
    public func version() throws -> [UInt8] {
        return try address.call("getVersion()").wait().array { try $0.uint8() }
    }
    
    /**
     Gets the investor count
     
     solidity interface:
     ``` solidity
     function getInvestorCount() external view returns(uint256);
     ```
     */
    public func investorsCount() throws -> BigUInt {
        return try address.call("getInvestorCount()").wait().uint256()
    }
    
    /**
     Overloaded version of the transfer function
     - parameter to: receiver of transfer
     - parameter value: value of transfer
     - parameter data: data to indicate validation
     - returns: bool success
     
     solidity interface:
     ``` solidity
     function transferWithData(address _to, uint256 _value, bytes _data) external returns (bool success);
     ```
     */
    public func transfer(to: Address, value: BigUInt, data: Data) throws -> TransactionSendingResult {
        return try address.send("transferWithData(address,uint256,bytes)", to, value, data).wait()
    }
    /**
     Overloaded version of the transferFrom function
     - parameter from: sender of transfer
     - parameter to: receiver of transfer
     - parameter value: value of transfer
     - parameter data: data to indicate validation
     - returns: bool success
     
     solidity interface:
     ``` solidity
     function transferFromWithData(address _from, address _to, uint256 _value, bytes _data) external returns(bool);
     ```
     */
    public func transfer(from: Address, to: Address, value: BigUInt, data: Data) throws -> TransactionSendingResult {
        return try address.send("transferFromWithData(address,address,uint256,bytes)", from, to, value, data).wait()
    }
    
    /**
     Provides the granularity of the token
     - returns: uint256
     
     solidity interface:
     ``` solidity
     function granularity() external view returns(uint256);
     ```
     */
    public func granularity() throws -> BigUInt {
        return try address.call("granularity()").wait().uint256()
    }
}
