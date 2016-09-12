enum TokenDef {
	TEof;
	TBraceOpen;
	TBraceClose;
	TBracketOpen;
	TBracketClose;
	TMathOpenDisplay;
	TMathCloseDisplay;
	TWordspace;
	TSequence(name:String);
	TText(text:String);
}

typedef Token = {
	def:TokenDef,
	pos:Pos
}

