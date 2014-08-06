//	@file Name: fn_findString.sqf
//	@file Author: AgentRev, Killzone_Kid

/*
	Parameters:
	_this select 0: String or Array - string(s) to search for
	_this select 1: String - string to check in
	_this select 2: Boolean - case sensitive search (optional, default: false)

	Returns: Number - first match position, -1 if not found
*/

private ["_needles", "_haystack", "_caseSensitive", "_checkMatch", "_hayLen", "_found", "_testArray", "_i"];

_needles = [_this, 0, [], ["",[]]] call BIS_fnc_param;
_haystack = toArray ([_this, 1, "", [""]] call BIS_fnc_param);
_caseSensitive = [_this, 2, false, [false]] call BIS_fnc_param;

if (typeName _needles == "STRING") then
{
	_needles = [_needles];
};

_checkMatch = if (_caseSensitive) then {
	{_this in [toString _testArray]}
} else {
	{_this == toString _testArray}
};

_hayLen = count _haystack;
_found = -1;

{
	_needleLen = count toArray _x;
	_testArray = +_haystack;
	_testArray resize _needleLen;

	for "_i" from _needleLen to _hayLen do
	{
		if (_x call _checkMatch) exitWith
		{
			_found = _i - _needleLen;
		};

		_testArray set [_needleLen, _haystack select _i];
		_testArray set [0, "x"];
		_testArray = _testArray - ["x"];
	};

	if (_found != -1) exitWith {};
} forEach _needles;

_found
