package geth
import (
	"github.com/Cryptochain-VON/whisper/shhclient"
	whisper "github.com/Cryptochain-VON/whisper/whisperv6"
)
type WhisperClient struct {
	client *shhclient.Client
}
func NewWhisperClient(rawurl string) (client *WhisperClient, _ error) {
	rawClient, err := shhclient.Dial(rawurl)
	return &WhisperClient{rawClient}, err
}
func (wc *WhisperClient) GetVersion(ctx *Context) (version string, _ error) {
	return wc.client.Version(ctx.context)
}
func (wc *WhisperClient) GetInfo(ctx *Context) (info *Info, _ error) {
	rawInfo, err := wc.client.Info(ctx.context)
	return &Info{&rawInfo}, err
}
func (wc *WhisperClient) SetMaxMessageSize(ctx *Context, size int32) error {
	return wc.client.SetMaxMessageSize(ctx.context, uint32(size))
}
func (wc *WhisperClient) SetMinimumPoW(ctx *Context, pow float64) error {
	return wc.client.SetMinimumPoW(ctx.context, pow)
}
func (wc *WhisperClient) MarkTrustedPeer(ctx *Context, enode string) error {
	return wc.client.MarkTrustedPeer(ctx.context, enode)
}
func (wc *WhisperClient) NewKeyPair(ctx *Context) (string, error) {
	return wc.client.NewKeyPair(ctx.context)
}
func (wc *WhisperClient) AddPrivateKey(ctx *Context, key []byte) (string, error) {
	return wc.client.AddPrivateKey(ctx.context, key)
}
func (wc *WhisperClient) DeleteKeyPair(ctx *Context, id string) (string, error) {
	return wc.client.DeleteKeyPair(ctx.context, id)
}
func (wc *WhisperClient) HasKeyPair(ctx *Context, id string) (bool, error) {
	return wc.client.HasKeyPair(ctx.context, id)
}
func (wc *WhisperClient) GetPublicKey(ctx *Context, id string) ([]byte, error) {
	return wc.client.PublicKey(ctx.context, id)
}
func (wc *WhisperClient) GetPrivateKey(ctx *Context, id string) ([]byte, error) {
	return wc.client.PrivateKey(ctx.context, id)
}
func (wc *WhisperClient) NewSymmetricKey(ctx *Context) (string, error) {
	return wc.client.NewSymmetricKey(ctx.context)
}
func (wc *WhisperClient) AddSymmetricKey(ctx *Context, key []byte) (string, error) {
	return wc.client.AddSymmetricKey(ctx.context, key)
}
func (wc *WhisperClient) GenerateSymmetricKeyFromPassword(ctx *Context, passwd string) (string, error) {
	return wc.client.GenerateSymmetricKeyFromPassword(ctx.context, passwd)
}
func (wc *WhisperClient) HasSymmetricKey(ctx *Context, id string) (bool, error) {
	return wc.client.HasSymmetricKey(ctx.context, id)
}
func (wc *WhisperClient) GetSymmetricKey(ctx *Context, id string) ([]byte, error) {
	return wc.client.GetSymmetricKey(ctx.context, id)
}
func (wc *WhisperClient) DeleteSymmetricKey(ctx *Context, id string) error {
	return wc.client.DeleteSymmetricKey(ctx.context, id)
}
func (wc *WhisperClient) Post(ctx *Context, message *NewMessage) (string, error) {
	return wc.client.Post(ctx.context, *message.newMessage)
}
type NewMessageHandler interface {
	OnNewMessage(message *Message)
	OnError(failure string)
}
func (wc *WhisperClient) SubscribeMessages(ctx *Context, criteria *Criteria, handler NewMessageHandler, buffer int) (*Subscription, error) {
	ch := make(chan *whisper.Message, buffer)
	rawSub, err := wc.client.SubscribeMessages(ctx.context, *criteria.criteria, ch)
	if err != nil {
		return nil, err
	}
	go func() {
		for {
			select {
			case message := <-ch:
				handler.OnNewMessage(&Message{message})
			case err := <-rawSub.Err():
				if err != nil {
					handler.OnError(err.Error())
				}
				return
			}
		}
	}()
	return &Subscription{rawSub}, nil
}
func (wc *WhisperClient) NewMessageFilter(ctx *Context, criteria *Criteria) (string, error) {
	return wc.client.NewMessageFilter(ctx.context, *criteria.criteria)
}
func (wc *WhisperClient) DeleteMessageFilter(ctx *Context, id string) error {
	return wc.client.DeleteMessageFilter(ctx.context, id)
}
func (wc *WhisperClient) GetFilterMessages(ctx *Context, id string) (*Messages, error) {
	rawFilterMessages, err := wc.client.FilterMessages(ctx.context, id)
	if err != nil {
		return nil, err
	}
	res := make([]*whisper.Message, len(rawFilterMessages))
	copy(res, rawFilterMessages)
	return &Messages{res}, nil
}
