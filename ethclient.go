package geth
import (
	"math/big"
	"github.com/Cryptochain-VON/core/types"
	"github.com/Cryptochain-VON/ethclient"
)
type EthereumClient struct {
	client *ethclient.Client
}
func NewEthereumClient(rawurl string) (client *EthereumClient, _ error) {
	rawClient, err := ethclient.Dial(rawurl)
	return &EthereumClient{rawClient}, err
}
func (ec *EthereumClient) GetBlockByHash(ctx *Context, hash *Hash) (block *Block, _ error) {
	rawBlock, err := ec.client.BlockByHash(ctx.context, hash.hash)
	return &Block{rawBlock}, err
}
func (ec *EthereumClient) GetBlockByNumber(ctx *Context, number int64) (block *Block, _ error) {
	if number < 0 {
		rawBlock, err := ec.client.BlockByNumber(ctx.context, nil)
		return &Block{rawBlock}, err
	}
	rawBlock, err := ec.client.BlockByNumber(ctx.context, big.NewInt(number))
	return &Block{rawBlock}, err
}
func (ec *EthereumClient) GetHeaderByHash(ctx *Context, hash *Hash) (header *Header, _ error) {
	rawHeader, err := ec.client.HeaderByHash(ctx.context, hash.hash)
	return &Header{rawHeader}, err
}
func (ec *EthereumClient) GetHeaderByNumber(ctx *Context, number int64) (header *Header, _ error) {
	if number < 0 {
		rawHeader, err := ec.client.HeaderByNumber(ctx.context, nil)
		return &Header{rawHeader}, err
	}
	rawHeader, err := ec.client.HeaderByNumber(ctx.context, big.NewInt(number))
	return &Header{rawHeader}, err
}
func (ec *EthereumClient) GetTransactionByHash(ctx *Context, hash *Hash) (tx *Transaction, _ error) {
	rawTx, _, err := ec.client.TransactionByHash(ctx.context, hash.hash)
	return &Transaction{rawTx}, err
}
func (ec *EthereumClient) GetTransactionSender(ctx *Context, tx *Transaction, blockhash *Hash, index int) (sender *Address, _ error) {
	addr, err := ec.client.TransactionSender(ctx.context, tx.tx, blockhash.hash, uint(index))
	return &Address{addr}, err
}
func (ec *EthereumClient) GetTransactionCount(ctx *Context, hash *Hash) (count int, _ error) {
	rawCount, err := ec.client.TransactionCount(ctx.context, hash.hash)
	return int(rawCount), err
}
func (ec *EthereumClient) GetTransactionInBlock(ctx *Context, hash *Hash, index int) (tx *Transaction, _ error) {
	rawTx, err := ec.client.TransactionInBlock(ctx.context, hash.hash, uint(index))
	return &Transaction{rawTx}, err
}
func (ec *EthereumClient) GetTransactionReceipt(ctx *Context, hash *Hash) (receipt *Receipt, _ error) {
	rawReceipt, err := ec.client.TransactionReceipt(ctx.context, hash.hash)
	return &Receipt{rawReceipt}, err
}
func (ec *EthereumClient) SyncProgress(ctx *Context) (progress *SyncProgress, _ error) {
	rawProgress, err := ec.client.SyncProgress(ctx.context)
	if rawProgress == nil {
		return nil, err
	}
	return &SyncProgress{*rawProgress}, err
}
type NewHeadHandler interface {
	OnNewHead(header *Header)
	OnError(failure string)
}
func (ec *EthereumClient) SubscribeNewHead(ctx *Context, handler NewHeadHandler, buffer int) (sub *Subscription, _ error) {
	ch := make(chan *types.Header, buffer)
	rawSub, err := ec.client.SubscribeNewHead(ctx.context, ch)
	if err != nil {
		return nil, err
	}
	go func() {
		for {
			select {
			case header := <-ch:
				handler.OnNewHead(&Header{header})
			case err := <-rawSub.Err():
				if err != nil {
					handler.OnError(err.Error())
				}
				return
			}
		}
	}()
	return &Subscription{rawSub}, nil
}
func (ec *EthereumClient) GetBalanceAt(ctx *Context, account *Address, number int64) (balance *BigInt, _ error) {
	if number < 0 {
		rawBalance, err := ec.client.BalanceAt(ctx.context, account.address, nil)
		return &BigInt{rawBalance}, err
	}
	rawBalance, err := ec.client.BalanceAt(ctx.context, account.address, big.NewInt(number))
	return &BigInt{rawBalance}, err
}
func (ec *EthereumClient) GetStorageAt(ctx *Context, account *Address, key *Hash, number int64) (storage []byte, _ error) {
	if number < 0 {
		return ec.client.StorageAt(ctx.context, account.address, key.hash, nil)
	}
	return ec.client.StorageAt(ctx.context, account.address, key.hash, big.NewInt(number))
}
func (ec *EthereumClient) GetCodeAt(ctx *Context, account *Address, number int64) (code []byte, _ error) {
	if number < 0 {
		return ec.client.CodeAt(ctx.context, account.address, nil)
	}
	return ec.client.CodeAt(ctx.context, account.address, big.NewInt(number))
}
func (ec *EthereumClient) GetNonceAt(ctx *Context, account *Address, number int64) (nonce int64, _ error) {
	if number < 0 {
		rawNonce, err := ec.client.NonceAt(ctx.context, account.address, nil)
		return int64(rawNonce), err
	}
	rawNonce, err := ec.client.NonceAt(ctx.context, account.address, big.NewInt(number))
	return int64(rawNonce), err
}
func (ec *EthereumClient) FilterLogs(ctx *Context, query *FilterQuery) (logs *Logs, _ error) {
	rawLogs, err := ec.client.FilterLogs(ctx.context, query.query)
	if err != nil {
		return nil, err
	}
	res := make([]*types.Log, len(rawLogs))
	for i := range rawLogs {
		res[i] = &rawLogs[i]
	}
	return &Logs{res}, nil
}
type FilterLogsHandler interface {
	OnFilterLogs(log *Log)
	OnError(failure string)
}
func (ec *EthereumClient) SubscribeFilterLogs(ctx *Context, query *FilterQuery, handler FilterLogsHandler, buffer int) (sub *Subscription, _ error) {
	ch := make(chan types.Log, buffer)
	rawSub, err := ec.client.SubscribeFilterLogs(ctx.context, query.query, ch)
	if err != nil {
		return nil, err
	}
	go func() {
		for {
			select {
			case log := <-ch:
				handler.OnFilterLogs(&Log{&log})
			case err := <-rawSub.Err():
				if err != nil {
					handler.OnError(err.Error())
				}
				return
			}
		}
	}()
	return &Subscription{rawSub}, nil
}
func (ec *EthereumClient) GetPendingBalanceAt(ctx *Context, account *Address) (balance *BigInt, _ error) {
	rawBalance, err := ec.client.PendingBalanceAt(ctx.context, account.address)
	return &BigInt{rawBalance}, err
}
func (ec *EthereumClient) GetPendingStorageAt(ctx *Context, account *Address, key *Hash) (storage []byte, _ error) {
	return ec.client.PendingStorageAt(ctx.context, account.address, key.hash)
}
func (ec *EthereumClient) GetPendingCodeAt(ctx *Context, account *Address) (code []byte, _ error) {
	return ec.client.PendingCodeAt(ctx.context, account.address)
}
func (ec *EthereumClient) GetPendingNonceAt(ctx *Context, account *Address) (nonce int64, _ error) {
	rawNonce, err := ec.client.PendingNonceAt(ctx.context, account.address)
	return int64(rawNonce), err
}
func (ec *EthereumClient) GetPendingTransactionCount(ctx *Context) (count int, _ error) {
	rawCount, err := ec.client.PendingTransactionCount(ctx.context)
	return int(rawCount), err
}
func (ec *EthereumClient) CallContract(ctx *Context, msg *CallMsg, number int64) (output []byte, _ error) {
	if number < 0 {
		return ec.client.CallContract(ctx.context, msg.msg, nil)
	}
	return ec.client.CallContract(ctx.context, msg.msg, big.NewInt(number))
}
func (ec *EthereumClient) PendingCallContract(ctx *Context, msg *CallMsg) (output []byte, _ error) {
	return ec.client.PendingCallContract(ctx.context, msg.msg)
}
func (ec *EthereumClient) SuggestGasPrice(ctx *Context) (price *BigInt, _ error) {
	rawPrice, err := ec.client.SuggestGasPrice(ctx.context)
	return &BigInt{rawPrice}, err
}
func (ec *EthereumClient) EstimateGas(ctx *Context, msg *CallMsg) (gas int64, _ error) {
	rawGas, err := ec.client.EstimateGas(ctx.context, msg.msg)
	return int64(rawGas), err
}
func (ec *EthereumClient) SendTransaction(ctx *Context, tx *Transaction) error {
	return ec.client.SendTransaction(ctx.context, tx.tx)
}
