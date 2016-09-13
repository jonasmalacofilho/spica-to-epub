class Main {
	static function main()
	{
		try {
			for (f in Sys.args()) {
				var tex = Parser.parse(f);
				sys.io.File.saveContent('$f.ast.json', haxe.Json.stringify(tex, "  "));
			}
		} catch (err:String) {
			if (err != "Aborted")
				js.Lib.rethrow();
		}
	}
}

