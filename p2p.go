package geth
import (
	"errors"
	"github.com/Cryptochain-VON/p2p"
)
type NodeInfo struct {
	info *p2p.NodeInfo
}
func (ni *NodeInfo) GetID() string              { return ni.info.ID }
func (ni *NodeInfo) GetName() string            { return ni.info.Name }
func (ni *NodeInfo) GetEnode() string           { return ni.info.Enode }
func (ni *NodeInfo) GetIP() string              { return ni.info.IP }
func (ni *NodeInfo) GetDiscoveryPort() int      { return ni.info.Ports.Discovery }
func (ni *NodeInfo) GetListenerPort() int       { return ni.info.Ports.Listener }
func (ni *NodeInfo) GetListenerAddress() string { return ni.info.ListenAddr }
func (ni *NodeInfo) GetProtocols() *Strings {
	protos := []string{}
	for proto := range ni.info.Protocols {
		protos = append(protos, proto)
	}
	return &Strings{protos}
}
type PeerInfo struct {
	info *p2p.PeerInfo
}
func (pi *PeerInfo) GetID() string            { return pi.info.ID }
func (pi *PeerInfo) GetName() string          { return pi.info.Name }
func (pi *PeerInfo) GetCaps() *Strings        { return &Strings{pi.info.Caps} }
func (pi *PeerInfo) GetLocalAddress() string  { return pi.info.Network.LocalAddress }
func (pi *PeerInfo) GetRemoteAddress() string { return pi.info.Network.RemoteAddress }
type PeerInfos struct {
	infos []*p2p.PeerInfo
}
func (pi *PeerInfos) Size() int {
	return len(pi.infos)
}
func (pi *PeerInfos) Get(index int) (info *PeerInfo, _ error) {
	if index < 0 || index >= len(pi.infos) {
		return nil, errors.New("index out of bounds")
	}
	return &PeerInfo{pi.infos[index]}, nil
}
