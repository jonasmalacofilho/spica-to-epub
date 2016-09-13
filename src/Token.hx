enum TokenDef {
	TEof;
	TWordspace;
	TBreakspace;
	TComment(comment:String);
	TBraceOpen;
	TBraceClose;
	TBracketOpen;
	TBracketClose;
	TMathOpenDisplay;
	TMathCloseDisplay;
	TSequence(name:String);
	TText(text:String);
}

typedef Token = GenElem<TokenDef>;

