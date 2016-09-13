import haxe.ds.GenericStack.GenericCell;

class Parser {
	var lexer:Lexer;
	var next:GenericCell<Token>;

	function mk<T>(def:T, pos:Pos):GenElem<T>
		return { def:def, pos:pos };

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

	function unpop(t:Token)
	{
		next = new GenericCell(t, next);
	}

	function helem(?before:TokenDef):HElem
	{
		var start = peek().pos;
		var li = [];
		while (true) {
			switch pop() {
			case { def:TEof }:
				break;
			case { def:TBreakspace }:
				break;
			case x if (before != null && x.def.equals(before)):
				unpop(x);
				break;
			case { def:TBraceOpen }:
				li.push(helem(TBraceClose));
				assert(pop().def.match(TBraceClose));
			case { def:TBracketOpen }:
				li.push(helem(TBracketClose));
				assert(pop().def.match(TBraceClose));
			case { def:TWordspace }:
				li.push(mk(Wordspace, peek().pos));
			case { def:TText(text) }:
				li.push(mk(Text(text), peek().pos));
			case { def:TComment(_)|TSequence("break"|"sloppy"|"fussy") }:
				// discard
			case defer if (defer.def.match(TSequence(_))):
				unpop(defer);
				break;
			case other:
				unpop(other);
				break;
			}
		}
		return switch li {
			case []: mk(HEmpty, start.span(peek().pos));
			case [i]: i;
			case _: mk(HList(li), li[0].pos.span(li[li.length-1].pos));
		}
	}

	function velem(?before:TokenDef):VElem
	{
		var start = peek().pos;
		var li = [];
		while (true) {
			switch pop() {
			case { def:TEof }:
				break;
			case x if (before != null && x.def.equals(before)):
				unpop(x);
				break;
			case { def:TBraceOpen }:
				li.push(velem(TBraceClose));
				assert(pop().def.match(TBraceClose));
			case { def:TBracketOpen }:
				li.push(velem(TBracketClose));
				assert(pop().def.match(TBraceClose));
			case t if (t.def.match(TText(_))):
				unpop(t);
				var p = helem(before);
				li.push(mk(Paragraph(p), p.pos));
			case { def:TWordspace|TBreakspace|TComment(_)|TSequence("clearpage"|"sloppy"|"fussy") }:
				// discard
			case other:
				// discard, but trace
				trace(Std.string(other));
			}
		}
		return switch li {
			case []: mk(VEmpty, start.span(peek().pos));
			case [i]: i;
			case _: mk(VList(li), li[0].pos.span(li[li.length-1].pos));
		}
	}

	function new(lexer:Lexer)
	{
		this.lexer = lexer;
	}

	public static function parse(path:String)
	{
		var lex = new Lexer(path);
		var parser = new Parser(lex);
		return parser.velem();
	}
}

