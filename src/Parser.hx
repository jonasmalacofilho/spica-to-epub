import haxe.ds.GenericStack.GenericCell;

class Parser {
	var curPos:Pos;
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
		curPos = c.elt.pos;
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
			case { def:TBraceOpen, pos:pos }:
				var group = HGroup(helem(TBraceClose));
				var end = pop();
				assert(end.def.match(TBraceClose));
				li.push(mk(group, pos.span(end.pos)));
			case { def:TBracketOpen, pos:pos }:
				var group = HGroup(helem(TBracketClose));
				var end = pop();
				assert(end.def.match(TBracketClose));
				li.push(mk(group, pos.span(end.pos)));
			case { def:TWordspace }:
				li.push(mk(Wordspace, peek().pos));
			case { def:TText(text) }:
				li.push(mk(Text(text), peek().pos));
			case { def:TSequence("manuscriptit"|"textit"), pos:pos }:
				assert(peek().def.match(TBraceOpen));
				var inner = helem();
				li.push(mk(Emph(inner), pos.span(inner.pos)));
			case { def:TSequence("manuscriptbf"|"textbf"), pos:pos }:
				assert(peek().def.match(TBraceOpen));
				var inner = helem();
				li.push(mk(Bold(inner), pos.span(inner.pos)));
			case { def:TSequence("footnote"), pos:pos }:
				assert(peek().def.match(TBraceOpen));
				var note = helem();
				li.push(mk(Footnote(note), pos.span(note.pos)));
			case { def:TSequence("mbox"), pos:pos }:
				assert(peek().def.match(TBraceOpen));
				var contents = helem();
				li.push(mk(HGroup(contents), pos.span(contents.pos)));
			case { def:TSequence("omission"), pos:pos }:
				li.push(mk(Text("[...]"), pos));
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
			case { def:TBraceOpen, pos:pos }:
				var group = VGroup(velem(TBraceClose));
				var end = pop();
				assert(end.def.match(TBraceClose));
				li.push(mk(group, pos.span(end.pos)));
			case { def:TBracketOpen, pos:pos }:
				var group = VGroup(velem(TBracketClose));
				var end = pop();
				assert(end.def.match(TBracketClose));
				li.push(mk(group, pos.span(end.pos)));
			case t if (t.def.match(TText(_)|TSequence("manuscriptit"|"textit"|"manuscriptbf"|"textbf"|"omission"|"footnote"|"mbox"))):
				unpop(t);
				var p = helem(before);
				li.push(mk(Paragraph(p), p.pos));
			case { def:TSequence("begin"), pos:pos }:
				var next = [pop().def, pop().def, pop().def];  // HACK: pattern matcher evaluates out of order
				switch next {
				case [TBraceOpen, TText("quotation"), TBraceClose]:
					var quote = helem(TSequence("end"));  // HACK
					var end = [pop(), pop(), pop(), pop()];
					assert(end[0].def.match(TSequence("end")), end[0]);
					assert(end[1].def.match(TBraceOpen), end[1]);
					assert(end[2].def.match(TText("quotation")), end[2]);
					assert(end[3].def.match(TBraceClose), end[3]);
					li.push(mk(Quotation(quote), pos.span(end[3].pos)));
				case [open, type, close]:
					// HACK: just ignore it for now
					trace(Std.string([open, type, close]));
				}
			case { def:TSequence("chapter"), pos:pos }:
				assert(peek().def.match(TBraceOpen));
				var name = helem();
				li.push(mk(Chapter(name), pos.span(name.pos)));
			case { def:TSequence("section"), pos:pos }:
				assert(peek().def.match(TBraceOpen));
				var name = helem();
				li.push(mk(Chapter(name), pos.span(name.pos)));
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
		try {
			return parser.velem();
		} catch (err:Dynamic) {
			Sys.println(err);
			Sys.println('Last peeked ${parser.curPos}');
			Sys.print(haxe.CallStack.toString(haxe.CallStack.exceptionStack()));
			throw "Aborted";
		}
	}
}

