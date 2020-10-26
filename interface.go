package geth
import (
	"errors"
	"math/big"
	"github.com/Cryptochain-VON/common"
)
type Interface struct {
	object interface{}
}
func NewInterface() *Interface {
	return new(Interface)
}
func (i *Interface) SetBool(b bool)                 { i.object = &b }
func (i *Interface) SetBools(bs *Bools)             { i.object = &bs.bools }
func (i *Interface) SetString(str string)           { i.object = &str }
func (i *Interface) SetStrings(strs *Strings)       { i.object = &strs.strs }
func (i *Interface) SetBinary(binary []byte)        { b := common.CopyBytes(binary); i.object = &b }
func (i *Interface) SetBinaries(binaries *Binaries) { i.object = &binaries.binaries }
func (i *Interface) SetAddress(address *Address)    { i.object = &address.address }
func (i *Interface) SetAddresses(addrs *Addresses)  { i.object = &addrs.addresses }
func (i *Interface) SetHash(hash *Hash)             { i.object = &hash.hash }
func (i *Interface) SetHashes(hashes *Hashes)       { i.object = &hashes.hashes }
func (i *Interface) SetInt8(n int8)                 { i.object = &n }
func (i *Interface) SetInt16(n int16)               { i.object = &n }
func (i *Interface) SetInt32(n int32)               { i.object = &n }
func (i *Interface) SetInt64(n int64)               { i.object = &n }
func (i *Interface) SetInt8s(bigints *BigInts) {
	ints := make([]int8, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, int8(bi.Int64()))
	}
	i.object = &ints
}
func (i *Interface) SetInt16s(bigints *BigInts) {
	ints := make([]int16, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, int16(bi.Int64()))
	}
	i.object = &ints
}
func (i *Interface) SetInt32s(bigints *BigInts) {
	ints := make([]int32, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, int32(bi.Int64()))
	}
	i.object = &ints
}
func (i *Interface) SetInt64s(bigints *BigInts) {
	ints := make([]int64, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, bi.Int64())
	}
	i.object = &ints
}
func (i *Interface) SetUint8(bigint *BigInt)  { n := uint8(bigint.bigint.Uint64()); i.object = &n }
func (i *Interface) SetUint16(bigint *BigInt) { n := uint16(bigint.bigint.Uint64()); i.object = &n }
func (i *Interface) SetUint32(bigint *BigInt) { n := uint32(bigint.bigint.Uint64()); i.object = &n }
func (i *Interface) SetUint64(bigint *BigInt) { n := bigint.bigint.Uint64(); i.object = &n }
func (i *Interface) SetUint8s(bigints *BigInts) {
	ints := make([]uint8, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, uint8(bi.Uint64()))
	}
	i.object = &ints
}
func (i *Interface) SetUint16s(bigints *BigInts) {
	ints := make([]uint16, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, uint16(bi.Uint64()))
	}
	i.object = &ints
}
func (i *Interface) SetUint32s(bigints *BigInts) {
	ints := make([]uint32, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, uint32(bi.Uint64()))
	}
	i.object = &ints
}
func (i *Interface) SetUint64s(bigints *BigInts) {
	ints := make([]uint64, 0, bigints.Size())
	for _, bi := range bigints.bigints {
		ints = append(ints, bi.Uint64())
	}
	i.object = &ints
}
func (i *Interface) SetBigInt(bigint *BigInt)    { i.object = &bigint.bigint }
func (i *Interface) SetBigInts(bigints *BigInts) { i.object = &bigints.bigints }
func (i *Interface) SetDefaultBool()      { i.object = new(bool) }
func (i *Interface) SetDefaultBools()     { i.object = new([]bool) }
func (i *Interface) SetDefaultString()    { i.object = new(string) }
func (i *Interface) SetDefaultStrings()   { i.object = new([]string) }
func (i *Interface) SetDefaultBinary()    { i.object = new([]byte) }
func (i *Interface) SetDefaultBinaries()  { i.object = new([][]byte) }
func (i *Interface) SetDefaultAddress()   { i.object = new(common.Address) }
func (i *Interface) SetDefaultAddresses() { i.object = new([]common.Address) }
func (i *Interface) SetDefaultHash()      { i.object = new(common.Hash) }
func (i *Interface) SetDefaultHashes()    { i.object = new([]common.Hash) }
func (i *Interface) SetDefaultInt8()      { i.object = new(int8) }
func (i *Interface) SetDefaultInt8s()     { i.object = new([]int8) }
func (i *Interface) SetDefaultInt16()     { i.object = new(int16) }
func (i *Interface) SetDefaultInt16s()    { i.object = new([]int16) }
func (i *Interface) SetDefaultInt32()     { i.object = new(int32) }
func (i *Interface) SetDefaultInt32s()    { i.object = new([]int32) }
func (i *Interface) SetDefaultInt64()     { i.object = new(int64) }
func (i *Interface) SetDefaultInt64s()    { i.object = new([]int64) }
func (i *Interface) SetDefaultUint8()     { i.object = new(uint8) }
func (i *Interface) SetDefaultUint8s()    { i.object = new([]uint8) }
func (i *Interface) SetDefaultUint16()    { i.object = new(uint16) }
func (i *Interface) SetDefaultUint16s()   { i.object = new([]uint16) }
func (i *Interface) SetDefaultUint32()    { i.object = new(uint32) }
func (i *Interface) SetDefaultUint32s()   { i.object = new([]uint32) }
func (i *Interface) SetDefaultUint64()    { i.object = new(uint64) }
func (i *Interface) SetDefaultUint64s()   { i.object = new([]uint64) }
func (i *Interface) SetDefaultBigInt()    { i.object = new(*big.Int) }
func (i *Interface) SetDefaultBigInts()   { i.object = new([]*big.Int) }
func (i *Interface) GetBool() bool            { return *i.object.(*bool) }
func (i *Interface) GetBools() *Bools         { return &Bools{*i.object.(*[]bool)} }
func (i *Interface) GetString() string        { return *i.object.(*string) }
func (i *Interface) GetStrings() *Strings     { return &Strings{*i.object.(*[]string)} }
func (i *Interface) GetBinary() []byte        { return *i.object.(*[]byte) }
func (i *Interface) GetBinaries() *Binaries   { return &Binaries{*i.object.(*[][]byte)} }
func (i *Interface) GetAddress() *Address     { return &Address{*i.object.(*common.Address)} }
func (i *Interface) GetAddresses() *Addresses { return &Addresses{*i.object.(*[]common.Address)} }
func (i *Interface) GetHash() *Hash           { return &Hash{*i.object.(*common.Hash)} }
func (i *Interface) GetHashes() *Hashes       { return &Hashes{*i.object.(*[]common.Hash)} }
func (i *Interface) GetInt8() int8            { return *i.object.(*int8) }
func (i *Interface) GetInt16() int16          { return *i.object.(*int16) }
func (i *Interface) GetInt32() int32          { return *i.object.(*int32) }
func (i *Interface) GetInt64() int64          { return *i.object.(*int64) }
func (i *Interface) GetInt8s() *BigInts {
	val := i.object.(*[]int8)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetInt64(int64(v))})
	}
	return bigints
}
func (i *Interface) GetInt16s() *BigInts {
	val := i.object.(*[]int16)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetInt64(int64(v))})
	}
	return bigints
}
func (i *Interface) GetInt32s() *BigInts {
	val := i.object.(*[]int32)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetInt64(int64(v))})
	}
	return bigints
}
func (i *Interface) GetInt64s() *BigInts {
	val := i.object.(*[]int64)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetInt64(v)})
	}
	return bigints
}
func (i *Interface) GetUint8() *BigInt {
	return &BigInt{new(big.Int).SetUint64(uint64(*i.object.(*uint8)))}
}
func (i *Interface) GetUint16() *BigInt {
	return &BigInt{new(big.Int).SetUint64(uint64(*i.object.(*uint16)))}
}
func (i *Interface) GetUint32() *BigInt {
	return &BigInt{new(big.Int).SetUint64(uint64(*i.object.(*uint32)))}
}
func (i *Interface) GetUint64() *BigInt {
	return &BigInt{new(big.Int).SetUint64(*i.object.(*uint64))}
}
func (i *Interface) GetUint8s() *BigInts {
	val := i.object.(*[]uint8)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetUint64(uint64(v))})
	}
	return bigints
}
func (i *Interface) GetUint16s() *BigInts {
	val := i.object.(*[]uint16)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetUint64(uint64(v))})
	}
	return bigints
}
func (i *Interface) GetUint32s() *BigInts {
	val := i.object.(*[]uint32)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetUint64(uint64(v))})
	}
	return bigints
}
func (i *Interface) GetUint64s() *BigInts {
	val := i.object.(*[]uint64)
	bigints := NewBigInts(len(*val))
	for i, v := range *val {
		bigints.Set(i, &BigInt{new(big.Int).SetUint64(v)})
	}
	return bigints
}
func (i *Interface) GetBigInt() *BigInt   { return &BigInt{*i.object.(**big.Int)} }
func (i *Interface) GetBigInts() *BigInts { return &BigInts{*i.object.(*[]*big.Int)} }
type Interfaces struct {
	objects []interface{}
}
func NewInterfaces(size int) *Interfaces {
	return &Interfaces{objects: make([]interface{}, size)}
}
func (i *Interfaces) Size() int {
	return len(i.objects)
}
func (i *Interfaces) Get(index int) (iface *Interface, _ error) {
	if index < 0 || index >= len(i.objects) {
		return nil, errors.New("index out of bounds")
	}
	return &Interface{object: i.objects[index]}, nil
}
func (i *Interfaces) Set(index int, object *Interface) error {
	if index < 0 || index >= len(i.objects) {
		return errors.New("index out of bounds")
	}
	i.objects[index] = object.object
	return nil
}
