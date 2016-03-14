A `performIfResponds` proxy for NSObject. Never use `-respondsToSelector` again.

For example, this:

	if([self.delegate respondsToSelector:@selector(fooForBar:]) {
		foo = [self.delegate fooForBar:self]:
	}

becomes this:

	foo = [[self.delegate performOrReturn:nil] fooForBar:self]:

See [bou.io/PerformIfResponds](http://bou.io/PerformIfResponds.html) for more details.