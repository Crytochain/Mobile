package geth
import (
	"math/big"
	"strings"
	"github.com/Cryptochain-VON/accounts/abi"
	"github.com/Cryptochain-VON/accounts/abi/bind"
	"github.com/Cryptochain-VON/accounts/keystore"
	"github.com/Cryptochain-VON/common"
	"github.com/Cryptochain-VON/core/types"
)
type Signer interface {
	Sign(*Address, *Transaction) (tx *Transaction, _ error)
}
type MobileSigner struct {
	sign bind.SignerFn
}
func (s *MobileSigner) Sign(addr *Address, unsignedTx *Transaction) (signedTx *Transaction, _ error) {
	sig, err := s.sign(types.EIP155Signer{}, addr.address, unsignedTx.tx)
	if err != nil {
		return nil, err
	}
	return &Transaction{sig}, nil
}
type CallOpts struct {
	opts bind.CallOpts
}
func NewCallOpts() *CallOpts {
	return new(CallOpts)
}
func (opts *CallOpts) IsPending() bool    { return opts.opts.Pending }
func (opts *CallOpts) GetGasLimit() int64 { return 0 /* TODO(karalabe) */ }
func (opts *CallOpts) SetPending(pending bool)     { opts.opts.Pending = pending }
func (opts *CallOpts) SetGasLimit(limit int64)     { /* TODO(karalabe) */ }
func (opts *CallOpts) SetContext(context *Context) { opts.opts.Context = context.context }
func (opts *CallOpts) SetFrom(addr *Address)       { opts.opts.From = addr.address }
type TransactOpts struct {
	opts bind.TransactOpts
}
func NewTransactOpts() *TransactOpts {
	return new(TransactOpts)
}
func NewKeyedTransactOpts(keyJson []byte, passphrase string) (*TransactOpts, error) {
	key, err := keystore.DecryptKey(keyJson, passphrase)
	if err != nil {
		return nil, err
	}
	return &TransactOpts{*bind.NewKeyedTransactor(key.PrivateKey)}, nil
}
func (opts *TransactOpts) GetFrom() *Address    { return &Address{opts.opts.From} }
func (opts *TransactOpts) GetNonce() int64      { return opts.opts.Nonce.Int64() }
func (opts *TransactOpts) GetValue() *BigInt    { return &BigInt{opts.opts.Value} }
func (opts *TransactOpts) GetGasPrice() *BigInt { return &BigInt{opts.opts.GasPrice} }
func (opts *TransactOpts) GetGasLimit() int64   { return int64(opts.opts.GasLimit) }
func (opts *TransactOpts) SetFrom(from *Address) { opts.opts.From = from.address }
func (opts *TransactOpts) SetNonce(nonce int64)  { opts.opts.Nonce = big.NewInt(nonce) }
func (opts *TransactOpts) SetSigner(s Signer) {
	opts.opts.Signer = func(signer types.Signer, addr common.Address, tx *types.Transaction) (*types.Transaction, error) {
		sig, err := s.Sign(&Address{addr}, &Transaction{tx})
		if err != nil {
			return nil, err
		}
		return sig.tx, nil
	}
}
func (opts *TransactOpts) SetValue(value *BigInt)      { opts.opts.Value = value.bigint }
func (opts *TransactOpts) SetGasPrice(price *BigInt)   { opts.opts.GasPrice = price.bigint }
func (opts *TransactOpts) SetGasLimit(limit int64)     { opts.opts.GasLimit = uint64(limit) }
func (opts *TransactOpts) SetContext(context *Context) { opts.opts.Context = context.context }
type BoundContract struct {
	contract *bind.BoundContract
	address  common.Address
	deployer *types.Transaction
}
func DeployContract(opts *TransactOpts, abiJSON string, bytecode []byte, client *EthereumClient, args *Interfaces) (contract *BoundContract, _ error) {
	parsed, err := abi.JSON(strings.NewReader(abiJSON))
	if err != nil {
		return nil, err
	}
	addr, tx, bound, err := bind.DeployContract(&opts.opts, parsed, common.CopyBytes(bytecode), client.client, args.objects...)
	if err != nil {
		return nil, err
	}
	return &BoundContract{
		contract: bound,
		address:  addr,
		deployer: tx,
	}, nil
}
func BindContract(address *Address, abiJSON string, client *EthereumClient) (contract *BoundContract, _ error) {
	parsed, err := abi.JSON(strings.NewReader(abiJSON))
	if err != nil {
		return nil, err
	}
	return &BoundContract{
		contract: bind.NewBoundContract(address.address, parsed, client.client, client.client, client.client),
		address:  address.address,
	}, nil
}
func (c *BoundContract) GetAddress() *Address { return &Address{c.address} }
func (c *BoundContract) GetDeployer() *Transaction {
	if c.deployer == nil {
		return nil
	}
	return &Transaction{c.deployer}
}
func (c *BoundContract) Call(opts *CallOpts, out *Interfaces, method string, args *Interfaces) error {
	if len(out.objects) == 1 {
		result := out.objects[0]
		if err := c.contract.Call(&opts.opts, result, method, args.objects...); err != nil {
			return err
		}
		out.objects[0] = result
	} else {
		results := make([]interface{}, len(out.objects))
		copy(results, out.objects)
		if err := c.contract.Call(&opts.opts, &results, method, args.objects...); err != nil {
			return err
		}
		copy(out.objects, results)
	}
	return nil
}
func (c *BoundContract) Transact(opts *TransactOpts, method string, args *Interfaces) (tx *Transaction, _ error) {
	rawTx, err := c.contract.Transact(&opts.opts, method, args.objects...)
	if err != nil {
		return nil, err
	}
	return &Transaction{rawTx}, nil
}
func (c *BoundContract) RawTransact(opts *TransactOpts, calldata []byte) (tx *Transaction, _ error) {
	rawTx, err := c.contract.RawTransact(&opts.opts, calldata)
	if err != nil {
		return nil, err
	}
	return &Transaction{rawTx}, nil
}
func (c *BoundContract) Transfer(opts *TransactOpts) (tx *Transaction, _ error) {
	rawTx, err := c.contract.Transfer(&opts.opts)
	if err != nil {
		return nil, err
	}
	return &Transaction{rawTx}, nil
}
