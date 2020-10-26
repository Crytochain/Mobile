package geth
import (
	"errors"
	ethereum "github.com/Cryptochain-VON"
	"github.com/Cryptochain-VON/common"
)
type Subscription struct {
	sub ethereum.Subscription
}
func (s *Subscription) Unsubscribe() {
	s.sub.Unsubscribe()
}
type CallMsg struct {
	msg ethereum.CallMsg
}
func NewCallMsg() *CallMsg {
	return new(CallMsg)
}
func (msg *CallMsg) GetFrom() *Address    { return &Address{msg.msg.From} }
func (msg *CallMsg) GetGas() int64        { return int64(msg.msg.Gas) }
func (msg *CallMsg) GetGasPrice() *BigInt { return &BigInt{msg.msg.GasPrice} }
func (msg *CallMsg) GetValue() *BigInt    { return &BigInt{msg.msg.Value} }
func (msg *CallMsg) GetData() []byte      { return msg.msg.Data }
func (msg *CallMsg) GetTo() *Address {
	if to := msg.msg.To; to != nil {
		return &Address{*msg.msg.To}
	}
	return nil
}
func (msg *CallMsg) SetFrom(address *Address)  { msg.msg.From = address.address }
func (msg *CallMsg) SetGas(gas int64)          { msg.msg.Gas = uint64(gas) }
func (msg *CallMsg) SetGasPrice(price *BigInt) { msg.msg.GasPrice = price.bigint }
func (msg *CallMsg) SetValue(value *BigInt)    { msg.msg.Value = value.bigint }
func (msg *CallMsg) SetData(data []byte)       { msg.msg.Data = common.CopyBytes(data) }
func (msg *CallMsg) SetTo(address *Address) {
	if address == nil {
		msg.msg.To = nil
		return
	}
	msg.msg.To = &address.address
}
type SyncProgress struct {
	progress ethereum.SyncProgress
}
func (p *SyncProgress) GetStartingBlock() int64 { return int64(p.progress.StartingBlock) }
func (p *SyncProgress) GetCurrentBlock() int64  { return int64(p.progress.CurrentBlock) }
func (p *SyncProgress) GetHighestBlock() int64  { return int64(p.progress.HighestBlock) }
func (p *SyncProgress) GetPulledStates() int64  { return int64(p.progress.PulledStates) }
func (p *SyncProgress) GetKnownStates() int64   { return int64(p.progress.KnownStates) }
type Topics struct{ topics [][]common.Hash }
func NewTopics(size int) *Topics {
	return &Topics{
		topics: make([][]common.Hash, size),
	}
}
func NewTopicsEmpty() *Topics {
	return NewTopics(0)
}
func (t *Topics) Size() int {
	return len(t.topics)
}
func (t *Topics) Get(index int) (hashes *Hashes, _ error) {
	if index < 0 || index >= len(t.topics) {
		return nil, errors.New("index out of bounds")
	}
	return &Hashes{t.topics[index]}, nil
}
func (t *Topics) Set(index int, topics *Hashes) error {
	if index < 0 || index >= len(t.topics) {
		return errors.New("index out of bounds")
	}
	t.topics[index] = topics.hashes
	return nil
}
func (t *Topics) Append(topics *Hashes) {
	t.topics = append(t.topics, topics.hashes)
}
type FilterQuery struct {
	query ethereum.FilterQuery
}
func NewFilterQuery() *FilterQuery {
	return new(FilterQuery)
}
func (fq *FilterQuery) GetFromBlock() *BigInt    { return &BigInt{fq.query.FromBlock} }
func (fq *FilterQuery) GetToBlock() *BigInt      { return &BigInt{fq.query.ToBlock} }
func (fq *FilterQuery) GetAddresses() *Addresses { return &Addresses{fq.query.Addresses} }
func (fq *FilterQuery) GetTopics() *Topics       { return &Topics{fq.query.Topics} }
func (fq *FilterQuery) SetFromBlock(fromBlock *BigInt)    { fq.query.FromBlock = fromBlock.bigint }
func (fq *FilterQuery) SetToBlock(toBlock *BigInt)        { fq.query.ToBlock = toBlock.bigint }
func (fq *FilterQuery) SetAddresses(addresses *Addresses) { fq.query.Addresses = addresses.addresses }
func (fq *FilterQuery) SetTopics(topics *Topics)          { fq.query.Topics = topics.topics }
