enum HDef {
	Wordspace;
	Text(text:String);
	HList(li:Array<HElem>);
	HEmpty;
}

enum VDef {
	Paragraph(h:HElem);
	Chapter(name:String);
	Section(name:String);
	// SubSection(name:String);
	VList(li:Array<VElem>);
	VEmpty;
}

typedef HElem = GenElem<HDef>;
typedef VElem = GenElem<VDef>;

