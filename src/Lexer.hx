using StringTools;

class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder {
	static function mk(lex:hxparse.Lexer, def:TokenDef, ?pos:Pos):Token
		return {
			def:def,
			pos:(pos != null ? pos : lex.curPos())
		}

	static function countNewlines(s:String)
	{
		var n = 0;
		for (i in 0...s.length)
			if (s.fastCodeAt(i) == "\n".code)
				n++;
		return n;
	}
	
	public static var tokens = @:rule [
		"" => mk(lexer, TEof),
		"([ \t\n]|(\r\n))+" => {
			if (countNewlines(lexer.current) <= 1)
				mk(lexer, TWordspace);
			else
				mk(lexer, TBreakspace);
		},
		"\\\\([a-zA-Z@]+)" => mk(lexer, TSequence(lexer.current.substr(1))),
		"\\\\[$\\- ,&]" => mk(lexer, TText(lexer.current.substr(1))),
		"\\\\\\\\" => mk(lexer, TWordspace),
		"\\\\\\[" => mk(lexer, TMathOpenDisplay),
		"\\\\\\]" => mk(lexer, TMathOpenDisplay),
		"{" => mk(lexer, TBraceOpen),
		"}" => mk(lexer, TBraceClose),
		"\\[" => mk(lexer, TBracketOpen),
		"\\]" => mk(lexer, TBracketClose),
		"[^\\\\{}\\[\\]]+" => mk(lexer, TText(lexer.current))
	];

	public function new(path)
	{
		var bytes = sys.io.File.getBytes(path);
		super(byte.ByteData.ofBytes(bytes), path);
	}
}

