package geth
import (
	"errors"
	"github.com/Cryptochain-VON/p2p/discv5"
)
type Enode struct {
	node *discv5.Node
}
func NewEnode(rawurl string) (enode *Enode, _ error) {
	node, err := discv5.ParseNode(rawurl)
	if err != nil {
		return nil, err
	}
	return &Enode{node}, nil
}
type Enodes struct{ nodes []*discv5.Node }
func NewEnodes(size int) *Enodes {
	return &Enodes{
		nodes: make([]*discv5.Node, size),
	}
}
func NewEnodesEmpty() *Enodes {
	return NewEnodes(0)
}
func (e *Enodes) Size() int {
	return len(e.nodes)
}
func (e *Enodes) Get(index int) (enode *Enode, _ error) {
	if index < 0 || index >= len(e.nodes) {
		return nil, errors.New("index out of bounds")
	}
	return &Enode{e.nodes[index]}, nil
}
func (e *Enodes) Set(index int, enode *Enode) error {
	if index < 0 || index >= len(e.nodes) {
		return errors.New("index out of bounds")
	}
	e.nodes[index] = enode.node
	return nil
}
func (e *Enodes) Append(enode *Enode) {
	e.nodes = append(e.nodes, enode.node)
}
