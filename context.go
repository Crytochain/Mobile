package geth
import (
	"context"
	"time"
)
type Context struct {
	context context.Context
	cancel  context.CancelFunc
}
func NewContext() *Context {
	return &Context{
		context: context.Background(),
	}
}
func (c *Context) WithCancel() *Context {
	child, cancel := context.WithCancel(c.context)
	return &Context{
		context: child,
		cancel:  cancel,
	}
}
func (c *Context) WithDeadline(sec int64, nsec int64) *Context {
	child, cancel := context.WithDeadline(c.context, time.Unix(sec, nsec))
	return &Context{
		context: child,
		cancel:  cancel,
	}
}
func (c *Context) WithTimeout(nsec int64) *Context {
	child, cancel := context.WithTimeout(c.context, time.Duration(nsec))
	return &Context{
		context: child,
		cancel:  cancel,
	}
}
