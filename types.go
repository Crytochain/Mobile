package geth
import (
	"encoding/json"
	"errors"
	"fmt"
	"github.com/Cryptochain-VON/common"
	"github.com/Cryptochain-VON/core/types"
	"github.com/Cryptochain-VON/rlp"
	whisper "github.com/Cryptochain-VON/whisper/whisperv6"
)
type Nonce struct {
	nonce types.BlockNonce
}
func (n *Nonce) GetBytes() []byte {
	return n.nonce[:]
}
func (n *Nonce) GetHex() string {
	return fmt.Sprintf("0x%x", n.nonce[:])
}
type Bloom struct {
	bloom types.Bloom
}
func (b *Bloom) GetBytes() []byte {
	return b.bloom[:]
}
func (b *Bloom) GetHex() string {
	return fmt.Sprintf("0x%x", b.bloom[:])
}
type Header struct {
	header *types.Header
}
func NewHeaderFromRLP(data []byte) (*Header, error) {
	h := &Header{
		header: new(types.Header),
	}
	if err := rlp.DecodeBytes(common.CopyBytes(data), h.header); err != nil {
		return nil, err
	}
	return h, nil
}
func (h *Header) EncodeRLP() ([]byte, error) {
	return rlp.EncodeToBytes(h.header)
}
func NewHeaderFromJSON(data string) (*Header, error) {
	h := &Header{
		header: new(types.Header),
	}
	if err := json.Unmarshal([]byte(data), h.header); err != nil {
		return nil, err
	}
	return h, nil
}
func (h *Header) EncodeJSON() (string, error) {
	data, err := json.Marshal(h.header)
	return string(data), err
}
func (h *Header) GetParentHash() *Hash   { return &Hash{h.header.ParentHash} }
func (h *Header) GetUncleHash() *Hash    { return &Hash{h.header.UncleHash} }
func (h *Header) GetCoinbase() *Address  { return &Address{h.header.Coinbase} }
func (h *Header) GetRoot() *Hash         { return &Hash{h.header.Root} }
func (h *Header) GetTxHash() *Hash       { return &Hash{h.header.TxHash} }
func (h *Header) GetReceiptHash() *Hash  { return &Hash{h.header.ReceiptHash} }
func (h *Header) GetBloom() *Bloom       { return &Bloom{h.header.Bloom} }
func (h *Header) GetDifficulty() *BigInt { return &BigInt{h.header.Difficulty} }
func (h *Header) GetNumber() int64       { return h.header.Number.Int64() }
func (h *Header) GetGasLimit() int64     { return int64(h.header.GasLimit) }
func (h *Header) GetGasUsed() int64      { return int64(h.header.GasUsed) }
func (h *Header) GetTime() int64         { return int64(h.header.Time) }
func (h *Header) GetExtra() []byte       { return h.header.Extra }
func (h *Header) GetMixDigest() *Hash    { return &Hash{h.header.MixDigest} }
func (h *Header) GetNonce() *Nonce       { return &Nonce{h.header.Nonce} }
func (h *Header) GetHash() *Hash         { return &Hash{h.header.Hash()} }
type Headers struct{ headers []*types.Header }
func (h *Headers) Size() int {
	return len(h.headers)
}
func (h *Headers) Get(index int) (header *Header, _ error) {
	if index < 0 || index >= len(h.headers) {
		return nil, errors.New("index out of bounds")
	}
	return &Header{h.headers[index]}, nil
}
type Block struct {
	block *types.Block
}
func NewBlockFromRLP(data []byte) (*Block, error) {
	b := &Block{
		block: new(types.Block),
	}
	if err := rlp.DecodeBytes(common.CopyBytes(data), b.block); err != nil {
		return nil, err
	}
	return b, nil
}
func (b *Block) EncodeRLP() ([]byte, error) {
	return rlp.EncodeToBytes(b.block)
}
func NewBlockFromJSON(data string) (*Block, error) {
	b := &Block{
		block: new(types.Block),
	}
	if err := json.Unmarshal([]byte(data), b.block); err != nil {
		return nil, err
	}
	return b, nil
}
func (b *Block) EncodeJSON() (string, error) {
	data, err := json.Marshal(b.block)
	return string(data), err
}
func (b *Block) GetParentHash() *Hash           { return &Hash{b.block.ParentHash()} }
func (b *Block) GetUncleHash() *Hash            { return &Hash{b.block.UncleHash()} }
func (b *Block) GetCoinbase() *Address          { return &Address{b.block.Coinbase()} }
func (b *Block) GetRoot() *Hash                 { return &Hash{b.block.Root()} }
func (b *Block) GetTxHash() *Hash               { return &Hash{b.block.TxHash()} }
func (b *Block) GetReceiptHash() *Hash          { return &Hash{b.block.ReceiptHash()} }
func (b *Block) GetBloom() *Bloom               { return &Bloom{b.block.Bloom()} }
func (b *Block) GetDifficulty() *BigInt         { return &BigInt{b.block.Difficulty()} }
func (b *Block) GetNumber() int64               { return b.block.Number().Int64() }
func (b *Block) GetGasLimit() int64             { return int64(b.block.GasLimit()) }
func (b *Block) GetGasUsed() int64              { return int64(b.block.GasUsed()) }
func (b *Block) GetTime() int64                 { return int64(b.block.Time()) }
func (b *Block) GetExtra() []byte               { return b.block.Extra() }
func (b *Block) GetMixDigest() *Hash            { return &Hash{b.block.MixDigest()} }
func (b *Block) GetNonce() int64                { return int64(b.block.Nonce()) }
func (b *Block) GetHash() *Hash                 { return &Hash{b.block.Hash()} }
func (b *Block) GetHeader() *Header             { return &Header{b.block.Header()} }
func (b *Block) GetUncles() *Headers            { return &Headers{b.block.Uncles()} }
func (b *Block) GetTransactions() *Transactions { return &Transactions{b.block.Transactions()} }
func (b *Block) GetTransaction(hash *Hash) *Transaction {
	return &Transaction{b.block.Transaction(hash.hash)}
}
type Transaction struct {
	tx *types.Transaction
}
func NewContractCreation(nonce int64, amount *BigInt, gasLimit int64, gasPrice *BigInt, data []byte) *Transaction {
	return &Transaction{types.NewContractCreation(uint64(nonce), amount.bigint, uint64(gasLimit), gasPrice.bigint, common.CopyBytes(data))}
}
func NewTransaction(nonce int64, to *Address, amount *BigInt, gasLimit int64, gasPrice *BigInt, data []byte) *Transaction {
	if to == nil {
		return &Transaction{types.NewContractCreation(uint64(nonce), amount.bigint, uint64(gasLimit), gasPrice.bigint, common.CopyBytes(data))}
	}
	return &Transaction{types.NewTransaction(uint64(nonce), to.address, amount.bigint, uint64(gasLimit), gasPrice.bigint, common.CopyBytes(data))}
}
func NewTransactionFromRLP(data []byte) (*Transaction, error) {
	tx := &Transaction{
		tx: new(types.Transaction),
	}
	if err := rlp.DecodeBytes(common.CopyBytes(data), tx.tx); err != nil {
		return nil, err
	}
	return tx, nil
}
func (tx *Transaction) EncodeRLP() ([]byte, error) {
	return rlp.EncodeToBytes(tx.tx)
}
func NewTransactionFromJSON(data string) (*Transaction, error) {
	tx := &Transaction{
		tx: new(types.Transaction),
	}
	if err := json.Unmarshal([]byte(data), tx.tx); err != nil {
		return nil, err
	}
	return tx, nil
}
func (tx *Transaction) EncodeJSON() (string, error) {
	data, err := json.Marshal(tx.tx)
	return string(data), err
}
func (tx *Transaction) GetData() []byte      { return tx.tx.Data() }
func (tx *Transaction) GetGas() int64        { return int64(tx.tx.Gas()) }
func (tx *Transaction) GetGasPrice() *BigInt { return &BigInt{tx.tx.GasPrice()} }
func (tx *Transaction) GetValue() *BigInt    { return &BigInt{tx.tx.Value()} }
func (tx *Transaction) GetNonce() int64      { return int64(tx.tx.Nonce()) }
func (tx *Transaction) GetHash() *Hash   { return &Hash{tx.tx.Hash()} }
func (tx *Transaction) GetCost() *BigInt { return &BigInt{tx.tx.Cost()} }
func (tx *Transaction) GetSigHash() *Hash { return &Hash{types.HomesteadSigner{}.Hash(tx.tx)} }
func (tx *Transaction) GetFrom(chainID *BigInt) (address *Address, _ error) {
	var signer types.Signer = types.HomesteadSigner{}
	if chainID != nil {
		signer = types.NewEIP155Signer(chainID.bigint)
	}
	from, err := types.Sender(signer, tx.tx)
	return &Address{from}, err
}
func (tx *Transaction) GetTo() *Address {
	if to := tx.tx.To(); to != nil {
		return &Address{*to}
	}
	return nil
}
func (tx *Transaction) WithSignature(sig []byte, chainID *BigInt) (signedTx *Transaction, _ error) {
	var signer types.Signer = types.HomesteadSigner{}
	if chainID != nil {
		signer = types.NewEIP155Signer(chainID.bigint)
	}
	rawTx, err := tx.tx.WithSignature(signer, common.CopyBytes(sig))
	return &Transaction{rawTx}, err
}
type Transactions struct{ txs types.Transactions }
func (txs *Transactions) Size() int {
	return len(txs.txs)
}
func (txs *Transactions) Get(index int) (tx *Transaction, _ error) {
	if index < 0 || index >= len(txs.txs) {
		return nil, errors.New("index out of bounds")
	}
	return &Transaction{txs.txs[index]}, nil
}
type Receipt struct {
	receipt *types.Receipt
}
func NewReceiptFromRLP(data []byte) (*Receipt, error) {
	r := &Receipt{
		receipt: new(types.Receipt),
	}
	if err := rlp.DecodeBytes(common.CopyBytes(data), r.receipt); err != nil {
		return nil, err
	}
	return r, nil
}
func (r *Receipt) EncodeRLP() ([]byte, error) {
	return rlp.EncodeToBytes(r.receipt)
}
func NewReceiptFromJSON(data string) (*Receipt, error) {
	r := &Receipt{
		receipt: new(types.Receipt),
	}
	if err := json.Unmarshal([]byte(data), r.receipt); err != nil {
		return nil, err
	}
	return r, nil
}
func (r *Receipt) EncodeJSON() (string, error) {
	data, err := rlp.EncodeToBytes(r.receipt)
	return string(data), err
}
func (r *Receipt) GetStatus() int               { return int(r.receipt.Status) }
func (r *Receipt) GetPostState() []byte         { return r.receipt.PostState }
func (r *Receipt) GetCumulativeGasUsed() int64  { return int64(r.receipt.CumulativeGasUsed) }
func (r *Receipt) GetBloom() *Bloom             { return &Bloom{r.receipt.Bloom} }
func (r *Receipt) GetLogs() *Logs               { return &Logs{r.receipt.Logs} }
func (r *Receipt) GetTxHash() *Hash             { return &Hash{r.receipt.TxHash} }
func (r *Receipt) GetContractAddress() *Address { return &Address{r.receipt.ContractAddress} }
func (r *Receipt) GetGasUsed() int64            { return int64(r.receipt.GasUsed) }
type Info struct {
	info *whisper.Info
}
type NewMessage struct {
	newMessage *whisper.NewMessage
}
func NewNewMessage() *NewMessage {
	nm := &NewMessage{
		newMessage: new(whisper.NewMessage),
	}
	return nm
}
func (nm *NewMessage) GetSymKeyID() string         { return nm.newMessage.SymKeyID }
func (nm *NewMessage) SetSymKeyID(symKeyID string) { nm.newMessage.SymKeyID = symKeyID }
func (nm *NewMessage) GetPublicKey() []byte        { return nm.newMessage.PublicKey }
func (nm *NewMessage) SetPublicKey(publicKey []byte) {
	nm.newMessage.PublicKey = common.CopyBytes(publicKey)
}
func (nm *NewMessage) GetSig() string                  { return nm.newMessage.Sig }
func (nm *NewMessage) SetSig(sig string)               { nm.newMessage.Sig = sig }
func (nm *NewMessage) GetTTL() int64                   { return int64(nm.newMessage.TTL) }
func (nm *NewMessage) SetTTL(ttl int64)                { nm.newMessage.TTL = uint32(ttl) }
func (nm *NewMessage) GetPayload() []byte              { return nm.newMessage.Payload }
func (nm *NewMessage) SetPayload(payload []byte)       { nm.newMessage.Payload = common.CopyBytes(payload) }
func (nm *NewMessage) GetPowTime() int64               { return int64(nm.newMessage.PowTime) }
func (nm *NewMessage) SetPowTime(powTime int64)        { nm.newMessage.PowTime = uint32(powTime) }
func (nm *NewMessage) GetPowTarget() float64           { return nm.newMessage.PowTarget }
func (nm *NewMessage) SetPowTarget(powTarget float64)  { nm.newMessage.PowTarget = powTarget }
func (nm *NewMessage) GetTargetPeer() string           { return nm.newMessage.TargetPeer }
func (nm *NewMessage) SetTargetPeer(targetPeer string) { nm.newMessage.TargetPeer = targetPeer }
func (nm *NewMessage) GetTopic() []byte                { return nm.newMessage.Topic[:] }
func (nm *NewMessage) SetTopic(topic []byte)           { nm.newMessage.Topic = whisper.BytesToTopic(topic) }
type Message struct {
	message *whisper.Message
}
func (m *Message) GetSig() []byte      { return m.message.Sig }
func (m *Message) GetTTL() int64       { return int64(m.message.TTL) }
func (m *Message) GetTimestamp() int64 { return int64(m.message.Timestamp) }
func (m *Message) GetPayload() []byte  { return m.message.Payload }
func (m *Message) GetPoW() float64     { return m.message.PoW }
func (m *Message) GetHash() []byte     { return m.message.Hash }
func (m *Message) GetDst() []byte      { return m.message.Dst }
type Messages struct {
	messages []*whisper.Message
}
func (m *Messages) Size() int {
	return len(m.messages)
}
func (m *Messages) Get(index int) (message *Message, _ error) {
	if index < 0 || index >= len(m.messages) {
		return nil, errors.New("index out of bounds")
	}
	return &Message{m.messages[index]}, nil
}
type Criteria struct {
	criteria *whisper.Criteria
}
func NewCriteria(topic []byte) *Criteria {
	c := &Criteria{
		criteria: new(whisper.Criteria),
	}
	encodedTopic := whisper.BytesToTopic(topic)
	c.criteria.Topics = []whisper.TopicType{encodedTopic}
	return c
}
func (c *Criteria) GetSymKeyID() string                 { return c.criteria.SymKeyID }
func (c *Criteria) SetSymKeyID(symKeyID string)         { c.criteria.SymKeyID = symKeyID }
func (c *Criteria) GetPrivateKeyID() string             { return c.criteria.PrivateKeyID }
func (c *Criteria) SetPrivateKeyID(privateKeyID string) { c.criteria.PrivateKeyID = privateKeyID }
func (c *Criteria) GetSig() []byte                      { return c.criteria.Sig }
func (c *Criteria) SetSig(sig []byte)                   { c.criteria.Sig = common.CopyBytes(sig) }
func (c *Criteria) GetMinPow() float64                  { return c.criteria.MinPow }
func (c *Criteria) SetMinPow(pow float64)               { c.criteria.MinPow = pow }
