using StringTools;

@:enum abstract Mimetype(String) {
	public var Gif = "image/gif";
	public var Jpeg = "image/jpeg";
	public var Png = "image/png";
	public var Svg = "image/svg+xml";
	public var Xhtml = "application/xhml+xml";
	public var Css = "text/css";
	public var JavaScript = "text/javascript";
}

class PkgFile {
	public var mimetype(default,null):Mimetype;
	public var path(default,null):String;
	public var buf(default,null) = new StringBuf();

	public function new(mimetype, path)
	{
		this.mimetype = mimetype;
		this.path = path;
	}
}

class Writer {
	var epubPath:String;
	var cfg:Config;
	var debug = true;
	var files = new Map<String,PkgFile>();

	function htmlDoc(path:String, velem:VElem)
	{
		return "body";
	}

	function writePkgDoc(name, entry)
	{
		var f = new PkgFile(Xhtml, '$name.opf');
		f.buf.add('
			<package version="3.0" unique-identifier="$name-id">
				<metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
					<dc:identifier id="$name-id">${cfg.identifier}</dc:identifier>
					<dc:title>${cfg.title}</dc:title>
					<dc:language>${cfg.language}</dc:language>
					<dc:source id="src-id">${cfg.source}</dc:source>
				</metadata>
				<manifest>
				</manifest>
			</package>
		'.doctrim());
		return files[f.path] = f;
	}

	function writeMeta(root:String)
	{
		var f = new PkgFile(Xhtml, "META_INF/container.xml");
		f.buf.add('
			<?xml version="1.0"?>
			<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
				<rootfiles>
					<rootfile full-path="${root.htmlEscape()}" media-type="application/oebps-package+xml" />
				</rootfiles>
			</container>
		'.doctrim());
		return files[f.path] = f;
	}

	public function write(velem:VElem)
	{
		var main = "html";
		var mainEntry = htmlDoc(main, velem);
		var mainPkg = writePkgDoc(main, mainEntry);
		writeMeta(mainPkg.path);

		if (debug) {
			for (f in files) {
				var dp = haxe.io.Path.join(['$epubPath.d', f.path]);
				sys.FileSystem.createDirectory(new haxe.io.Path(dp).dir);
				sys.io.File.saveContent(dp, f.buf.toString());
			}
		}
	}

	public function new(epubPath:String, cfg:Config)
	{
		this.epubPath = epubPath;
		this.cfg = cfg;
	}
}

