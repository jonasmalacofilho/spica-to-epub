using StringTools;

class Writer {
	var path:String;
	var debug = true;
	var buf = new Map<String,String>();

	function rvertical(velem:VElem)
	{
		return "body";
	}

	function writeMeta(root:String)
	{
		buf["META_INF/container.xml"] = '
			<?xml version="1.0"?>
			<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:container">
				<rootfiles>
					<rootfile full-path="${root.htmlEscape()}" media-type="application/oebps-package+xml" />
				</rootfiles>
			</container>
		'.doctrim();
	}

	public function write(velem:VElem)
	{
		var root = "pub/index.html";
		buf[root] = "header";
		buf[root] += rvertical(velem);

		writeMeta(root);

		if (debug) {
			for (p in buf.keys()) {
				var dp = haxe.io.Path.join(['$path.d', p]);
				sys.FileSystem.createDirectory(new haxe.io.Path(dp).dir);
				sys.io.File.saveContent(dp, buf[p]);
			}
		}
	}

	public function new(path:String)
	{
		this.path = path;
	}
}

