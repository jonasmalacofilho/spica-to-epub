enum HDef {
	Wordspace;
	Text(text:String);
	Emph(h:HElem);
	Bold(h:HElem);
	Footnote(h:HElem);
	HGroup(h:HElem);
	HList(li:Array<HElem>);
	HEmpty;
}

enum VDef {
	Paragraph(h:HElem);
	Chapter(name:HElem);
	Section(name:HElem);
	Quotation(h:HElem);
	VGroup(v:VElem);
	VList(li:Array<VElem>);
	VEmpty;
}

typedef HElem = GenElem<HDef>;
typedef VElem = GenElem<VDef>;

