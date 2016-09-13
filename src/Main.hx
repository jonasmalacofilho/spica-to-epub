class Main {
	static function main()
	{
		for (f in Sys.args()) {
			var tex = Parser.parse(f);
			sys.io.File.saveContent('$f.ast.json', haxe.Json.stringify(tex, "  "));
		}
	}
}

