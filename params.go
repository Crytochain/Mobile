package geth
import (
	"encoding/json"
	"github.com/Cryptochain-VON/core"
	"github.com/Cryptochain-VON/p2p/discv5"
	"github.com/Cryptochain-VON/params"
)
func MainnetGenesis() string {
	return ""
}
func RopstenGenesis() string {
	enc, err := json.Marshal(core.DefaultRopstenGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}
func RinkebyGenesis() string {
	enc, err := json.Marshal(core.DefaultRinkebyGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}
func GoerliGenesis() string {
	enc, err := json.Marshal(core.DefaultGoerliGenesisBlock())
	if err != nil {
		panic(err)
	}
	return string(enc)
}
func FoundationBootnodes() *Enodes {
	nodes := &Enodes{nodes: make([]*discv5.Node, len(params.MainnetBootnodes))}
	for i, url := range params.MainnetBootnodes {
		nodes.nodes[i] = discv5.MustParseNode(url)
	}
	return nodes
}
