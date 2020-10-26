package geth
import (
	"errors"
	"fmt"
	"github.com/Cryptochain-VON/common"
)
type Strings struct{ strs []string }
func (s *Strings) Size() int {
	return len(s.strs)
}
func (s *Strings) Get(index int) (str string, _ error) {
	if index < 0 || index >= len(s.strs) {
		return "", errors.New("index out of bounds")
	}
	return s.strs[index], nil
}
func (s *Strings) Set(index int, str string) error {
	if index < 0 || index >= len(s.strs) {
		return errors.New("index out of bounds")
	}
	s.strs[index] = str
	return nil
}
func (s *Strings) String() string {
	return fmt.Sprintf("%v", s.strs)
}
type Bools struct{ bools []bool }
func (bs *Bools) Size() int {
	return len(bs.bools)
}
func (bs *Bools) Get(index int) (b bool, _ error) {
	if index < 0 || index >= len(bs.bools) {
		return false, errors.New("index out of bounds")
	}
	return bs.bools[index], nil
}
func (bs *Bools) Set(index int, b bool) error {
	if index < 0 || index >= len(bs.bools) {
		return errors.New("index out of bounds")
	}
	bs.bools[index] = b
	return nil
}
func (bs *Bools) String() string {
	return fmt.Sprintf("%v", bs.bools)
}
type Binaries struct{ binaries [][]byte }
func (bs *Binaries) Size() int {
	return len(bs.binaries)
}
func (bs *Binaries) Get(index int) (binary []byte, _ error) {
	if index < 0 || index >= len(bs.binaries) {
		return nil, errors.New("index out of bounds")
	}
	return common.CopyBytes(bs.binaries[index]), nil
}
func (bs *Binaries) Set(index int, binary []byte) error {
	if index < 0 || index >= len(bs.binaries) {
		return errors.New("index out of bounds")
	}
	bs.binaries[index] = common.CopyBytes(binary)
	return nil
}
func (bs *Binaries) String() string {
	return fmt.Sprintf("%v", bs.binaries)
}
