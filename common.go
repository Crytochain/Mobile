package geth
import (
	"encoding/hex"
	"errors"
	"fmt"
	"strings"
	"github.com/Cryptochain-VON/common"
	"github.com/Cryptochain-VON/common/hexutil"
)
type Hash struct {
	hash common.Hash
}
func NewHashFromBytes(binary []byte) (hash *Hash, _ error) {
	h := new(Hash)
	if err := h.SetBytes(common.CopyBytes(binary)); err != nil {
		return nil, err
	}
	return h, nil
}
func NewHashFromHex(hex string) (hash *Hash, _ error) {
	h := new(Hash)
	if err := h.SetHex(hex); err != nil {
		return nil, err
	}
	return h, nil
}
func (h *Hash) SetBytes(hash []byte) error {
	if length := len(hash); length != common.HashLength {
		return fmt.Errorf("invalid hash length: %v != %v", length, common.HashLength)
	}
	copy(h.hash[:], hash)
	return nil
}
func (h *Hash) GetBytes() []byte {
	return h.hash[:]
}
func (h *Hash) SetHex(hash string) error {
	hash = strings.ToLower(hash)
	if len(hash) >= 2 && hash[:2] == "0x" {
		hash = hash[2:]
	}
	if length := len(hash); length != 2*common.HashLength {
		return fmt.Errorf("invalid hash hex length: %v != %v", length, 2*common.HashLength)
	}
	bin, err := hex.DecodeString(hash)
	if err != nil {
		return err
	}
	copy(h.hash[:], bin)
	return nil
}
func (h *Hash) GetHex() string {
	return h.hash.Hex()
}
type Hashes struct{ hashes []common.Hash }
func NewHashes(size int) *Hashes {
	return &Hashes{
		hashes: make([]common.Hash, size),
	}
}
func NewHashesEmpty() *Hashes {
	return NewHashes(0)
}
func (h *Hashes) Size() int {
	return len(h.hashes)
}
func (h *Hashes) Get(index int) (hash *Hash, _ error) {
	if index < 0 || index >= len(h.hashes) {
		return nil, errors.New("index out of bounds")
	}
	return &Hash{h.hashes[index]}, nil
}
func (h *Hashes) Set(index int, hash *Hash) error {
	if index < 0 || index >= len(h.hashes) {
		return errors.New("index out of bounds")
	}
	h.hashes[index] = hash.hash
	return nil
}
func (h *Hashes) Append(hash *Hash) {
	h.hashes = append(h.hashes, hash.hash)
}
type Address struct {
	address common.Address
}
func NewAddressFromBytes(binary []byte) (address *Address, _ error) {
	a := new(Address)
	if err := a.SetBytes(common.CopyBytes(binary)); err != nil {
		return nil, err
	}
	return a, nil
}
func NewAddressFromHex(hex string) (address *Address, _ error) {
	a := new(Address)
	if err := a.SetHex(hex); err != nil {
		return nil, err
	}
	return a, nil
}
func (a *Address) SetBytes(address []byte) error {
	if length := len(address); length != common.AddressLength {
		return fmt.Errorf("invalid address length: %v != %v", length, common.AddressLength)
	}
	copy(a.address[:], address)
	return nil
}
func (a *Address) GetBytes() []byte {
	return a.address[:]
}
func (a *Address) SetHex(address string) error {
	address = strings.ToLower(address)
	if len(address) >= 2 && address[:2] == "0x" {
		address = address[2:]
	}
	if length := len(address); length != 2*common.AddressLength {
		return fmt.Errorf("invalid address hex length: %v != %v", length, 2*common.AddressLength)
	}
	bin, err := hex.DecodeString(address)
	if err != nil {
		return err
	}
	copy(a.address[:], bin)
	return nil
}
func (a *Address) GetHex() string {
	return a.address.Hex()
}
type Addresses struct{ addresses []common.Address }
func NewAddresses(size int) *Addresses {
	return &Addresses{
		addresses: make([]common.Address, size),
	}
}
func NewAddressesEmpty() *Addresses {
	return NewAddresses(0)
}
func (a *Addresses) Size() int {
	return len(a.addresses)
}
func (a *Addresses) Get(index int) (address *Address, _ error) {
	if index < 0 || index >= len(a.addresses) {
		return nil, errors.New("index out of bounds")
	}
	return &Address{a.addresses[index]}, nil
}
func (a *Addresses) Set(index int, address *Address) error {
	if index < 0 || index >= len(a.addresses) {
		return errors.New("index out of bounds")
	}
	a.addresses[index] = address.address
	return nil
}
func (a *Addresses) Append(address *Address) {
	a.addresses = append(a.addresses, address.address)
}
func EncodeToHex(b []byte) string {
	return hexutil.Encode(b)
}
func DecodeFromHex(s string) ([]byte, error) {
	return hexutil.Decode(s)
}
