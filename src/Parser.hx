import haxe.ds.GenericStack.GenericCell;

class Parser {
	var lexer:Lexer;
	var next:GenericCell<Token>;

	function peek(offset=0):Token
	{
		if (next == null)
			next = new GenericCell(lexer.token(Lexer.tokens), null);
		var c = next;
		while (offset-- > 0) {
			if (c.next == null)
				c.next = new GenericCell(lexer.token(Lexer.tokens), null);
			c = c.next;
		}
		assert(c.elt != null);
		return c.elt;
	}

	function pop()
	{
		var ret = peek();
		next = next.next;
		return ret;
	}

	function new(lexer:Lexer)
	{
		this.lexer = lexer;
	}

	public static function parse(path:String)
	{
		var lex = new Lexer(path);
		var parser = new Parser(lex);
		while (true) {
			var tok = parser.pop();
			trace(Std.string(tok));
			if (tok.def.match(TEof)) break;
		}
	}
}

