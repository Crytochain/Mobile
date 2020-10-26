package geth
import (
	"errors"
	"math/big"
	"github.com/Cryptochain-VON/common"
)
type BigInt struct {
	bigint *big.Int
}
func NewBigInt(x int64) *BigInt {
	return &BigInt{big.NewInt(x)}
}
func (bi *BigInt) GetBytes() []byte {
	return bi.bigint.Bytes()
}
func (bi *BigInt) String() string {
	return bi.bigint.String()
}
func (bi *BigInt) GetInt64() int64 {
	return bi.bigint.Int64()
}
func (bi *BigInt) SetBytes(buf []byte) {
	bi.bigint.SetBytes(common.CopyBytes(buf))
}
func (bi *BigInt) SetInt64(x int64) {
	bi.bigint.SetInt64(x)
}
func (bi *BigInt) Sign() int {
	return bi.bigint.Sign()
}
func (bi *BigInt) SetString(x string, base int) {
	bi.bigint.SetString(x, base)
}
type BigInts struct{ bigints []*big.Int }
func NewBigInts(size int) *BigInts {
	return &BigInts{
		bigints: make([]*big.Int, size),
	}
}
func (bi *BigInts) Size() int {
	return len(bi.bigints)
}
func (bi *BigInts) Get(index int) (bigint *BigInt, _ error) {
	if index < 0 || index >= len(bi.bigints) {
		return nil, errors.New("index out of bounds")
	}
	return &BigInt{bi.bigints[index]}, nil
}
func (bi *BigInts) Set(index int, bigint *BigInt) error {
	if index < 0 || index >= len(bi.bigints) {
		return errors.New("index out of bounds")
	}
	bi.bigints[index] = bigint.bigint
	return nil
}
func (bi *BigInt) GetString(base int) string {
	return bi.bigint.Text(base)
}
