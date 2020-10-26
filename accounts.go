package geth
import (
	"errors"
	"time"
	"github.com/Cryptochain-VON/accounts"
	"github.com/Cryptochain-VON/accounts/keystore"
	"github.com/Cryptochain-VON/common"
	"github.com/Cryptochain-VON/crypto"
)
const (
	StandardScryptN = int(keystore.StandardScryptN)
	StandardScryptP = int(keystore.StandardScryptP)
	LightScryptN = int(keystore.LightScryptN)
	LightScryptP = int(keystore.LightScryptP)
)
type Account struct{ account accounts.Account }
type Accounts struct{ accounts []accounts.Account }
func (a *Accounts) Size() int {
	return len(a.accounts)
}
func (a *Accounts) Get(index int) (account *Account, _ error) {
	if index < 0 || index >= len(a.accounts) {
		return nil, errors.New("index out of bounds")
	}
	return &Account{a.accounts[index]}, nil
}
func (a *Accounts) Set(index int, account *Account) error {
	if index < 0 || index >= len(a.accounts) {
		return errors.New("index out of bounds")
	}
	a.accounts[index] = account.account
	return nil
}
func (a *Account) GetAddress() *Address {
	return &Address{a.account.Address}
}
func (a *Account) GetURL() string {
	return a.account.URL.String()
}
type KeyStore struct{ keystore *keystore.KeyStore }
func NewKeyStore(keydir string, scryptN, scryptP int) *KeyStore {
	return &KeyStore{keystore: keystore.NewKeyStore(keydir, scryptN, scryptP)}
}
func (ks *KeyStore) HasAddress(address *Address) bool {
	return ks.keystore.HasAddress(address.address)
}
func (ks *KeyStore) GetAccounts() *Accounts {
	return &Accounts{ks.keystore.Accounts()}
}
func (ks *KeyStore) DeleteAccount(account *Account, passphrase string) error {
	return ks.keystore.Delete(account.account, passphrase)
}
func (ks *KeyStore) SignHash(address *Address, hash []byte) (signature []byte, _ error) {
	return ks.keystore.SignHash(accounts.Account{Address: address.address}, common.CopyBytes(hash))
}
func (ks *KeyStore) SignTx(account *Account, tx *Transaction, chainID *BigInt) (*Transaction, error) {
	if chainID == nil { 
		chainID = new(BigInt)
	}
	signed, err := ks.keystore.SignTx(account.account, tx.tx, chainID.bigint)
	if err != nil {
		return nil, err
	}
	return &Transaction{signed}, nil
}
func (ks *KeyStore) SignHashPassphrase(account *Account, passphrase string, hash []byte) (signature []byte, _ error) {
	return ks.keystore.SignHashWithPassphrase(account.account, passphrase, common.CopyBytes(hash))
}
func (ks *KeyStore) SignTxPassphrase(account *Account, passphrase string, tx *Transaction, chainID *BigInt) (*Transaction, error) {
	if chainID == nil { 
		chainID = new(BigInt)
	}
	signed, err := ks.keystore.SignTxWithPassphrase(account.account, passphrase, tx.tx, chainID.bigint)
	if err != nil {
		return nil, err
	}
	return &Transaction{signed}, nil
}
func (ks *KeyStore) Unlock(account *Account, passphrase string) error {
	return ks.keystore.TimedUnlock(account.account, passphrase, 0)
}
func (ks *KeyStore) Lock(address *Address) error {
	return ks.keystore.Lock(address.address)
}
func (ks *KeyStore) TimedUnlock(account *Account, passphrase string, timeout int64) error {
	return ks.keystore.TimedUnlock(account.account, passphrase, time.Duration(timeout))
}
func (ks *KeyStore) NewAccount(passphrase string) (*Account, error) {
	account, err := ks.keystore.NewAccount(passphrase)
	if err != nil {
		return nil, err
	}
	return &Account{account}, nil
}
func (ks *KeyStore) UpdateAccount(account *Account, passphrase, newPassphrase string) error {
	return ks.keystore.Update(account.account, passphrase, newPassphrase)
}
func (ks *KeyStore) ExportKey(account *Account, passphrase, newPassphrase string) (key []byte, _ error) {
	return ks.keystore.Export(account.account, passphrase, newPassphrase)
}
func (ks *KeyStore) ImportKey(keyJSON []byte, passphrase, newPassphrase string) (account *Account, _ error) {
	acc, err := ks.keystore.Import(common.CopyBytes(keyJSON), passphrase, newPassphrase)
	if err != nil {
		return nil, err
	}
	return &Account{acc}, nil
}
func (ks *KeyStore) ImportECDSAKey(key []byte, passphrase string) (account *Account, _ error) {
	privkey, err := crypto.ToECDSA(common.CopyBytes(key))
	if err != nil {
		return nil, err
	}
	acc, err := ks.keystore.ImportECDSA(privkey, passphrase)
	if err != nil {
		return nil, err
	}
	return &Account{acc}, nil
}
func (ks *KeyStore) ImportPreSaleKey(keyJSON []byte, passphrase string) (ccount *Account, _ error) {
	account, err := ks.keystore.ImportPreSaleKey(common.CopyBytes(keyJSON), passphrase)
	if err != nil {
		return nil, err
	}
	return &Account{account}, nil
}
