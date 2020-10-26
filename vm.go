package geth
import (
	"errors"
	"github.com/Cryptochain-VON/core/types"
)
type Log struct {
	log *types.Log
}
func (l *Log) GetAddress() *Address  { return &Address{l.log.Address} }
func (l *Log) GetTopics() *Hashes    { return &Hashes{l.log.Topics} }
func (l *Log) GetData() []byte       { return l.log.Data }
func (l *Log) GetBlockNumber() int64 { return int64(l.log.BlockNumber) }
func (l *Log) GetTxHash() *Hash      { return &Hash{l.log.TxHash} }
func (l *Log) GetTxIndex() int       { return int(l.log.TxIndex) }
func (l *Log) GetBlockHash() *Hash   { return &Hash{l.log.BlockHash} }
func (l *Log) GetIndex() int         { return int(l.log.Index) }
type Logs struct{ logs []*types.Log }
func (l *Logs) Size() int {
	return len(l.logs)
}
func (l *Logs) Get(index int) (log *Log, _ error) {
	if index < 0 || index >= len(l.logs) {
		return nil, errors.New("index out of bounds")
	}
	return &Log{l.logs[index]}, nil
}
