class Lexer extends hxparse.Lexer implements hxparse.RuleBuilder {
	static function mk(lex:hxparse.Lexer, def:TokenDef, ?pos:Pos):Token
		return {
			def:def,
			pos:(pos != null ? pos : lex.curPos())
		}

	public static var tokens = @:rule [
		"" => mk(lexer, TEof),
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

