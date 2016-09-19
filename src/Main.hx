import haxe.io.Path;
import sys.FileSystem;
import sys.io.File;

class Main {
	static function prepareSourceMaps()
	{
		try {
			var sms = js.Lib.require("source-map-support");
			sms.install();
			haxe.CallStack.wrapCallSite = sms.wrapCallSite;
		} catch (e:Dynamic) {
			trace("WARNING: could not prepare source map support:", e);
		}
	}

	static function main()
	{
#if debug
		prepareSourceMaps();
#end
		try {
			switch Sys.args() {
			case [new Path(_) => input, new Path(_) => output]:
				var tex = Parser.parse(input.toString());
				FileSystem.createDirectory(output.toString());
				File.saveContent(Path.join([output.toString(), "ast.json"]), haxe.Json.stringify(tex, "  "));
				var settings:Config = tink.Json.parse(File.getContent(Path.join([input.dir, "epub.json"])));
				var writer = new Writer(Path.join([output.toString(), '${input.file}.epub']), settings);
				writer.write(tex);
			case other:
				assert(false, other, "Usage: epubify <input-root> <output-dir>");
			}
		} catch (err:String) {
			if (err != "Aborted")
				js.Lib.rethrow();
		}
	}
}

