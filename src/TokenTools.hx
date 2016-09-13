class TokenTools {
	public static function span(left:Pos, right:Pos)
	{
		if (left.psource != right.psource) return left;
		assert(left.pmin <= right.pmin, "inverted positions", left, right);
		return new Pos(left.psource, left.pmin, right.pmax);
	}

	public static function offset(pos:Pos, left:Int, right:Int)
	{
		assert(pos.pmin + left <= pos.pmax + right, "positions will become inverted", pos);
		return new Pos(pos.psource, pos.pmin + left, pos.pmax + right);
	}
}

