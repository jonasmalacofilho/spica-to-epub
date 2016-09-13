import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Main {
	static function main()
	{
		try {
			switch Sys.args() {
			case [input, output]:
				var tex = Parser.parse(input);
				FileSystem.createDirectory(output);
				File.saveContent(Path.join([output, "ast.json"]), haxe.Json.stringify(tex, "  "));
			case other:
				assert(false, other, "Usage: epubify <input-root> <output-dir>");
			}
		} catch (err:String) {
			if (err != "Aborted")
				js.Lib.rethrow();
		}
	}
}

