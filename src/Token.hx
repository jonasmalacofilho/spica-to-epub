enum TokenDef {
	TEof;
	TBraceOpen;
	TBraceClose;
	TBracketOpen;
	TBracketClose;
	TMathOpenDisplay;
	TMathCloseDisplay;
	TWordspace;
	TBreakspace;
	TSequence(name:String);
	TText(text:String);
}

typedef Token = {
	def:TokenDef,
	pos:Pos
}

