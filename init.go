package geth
import (
	"os"
	"runtime"
	"github.com/Cryptochain-VON/log"
)
func init() {
	log.Root().SetHandler(log.LvlFilterHandler(log.LvlInfo, log.StreamHandler(os.Stderr, log.TerminalFormat(false))))
	runtime.GOMAXPROCS(runtime.NumCPU())
}
