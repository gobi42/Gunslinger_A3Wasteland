//	@file Name: FAR_Player_Unconscious.sqf
//	@file Author: Farooq, AgentRev

#include "FAR_defines.sqf"

disableSerialization;

private ["_unit", "_killer", "_names"];
_unit = _this select 0;
//_killer = _this select 1;

_unit setCaptive true;

if (_unit == player) then
{
	if (createDialog "ReviveBlankGUI") then
	{
		(findDisplay 910) displayAddEventHandler ["KeyDown", "_this select 1 == 1"]; // blocks Esc to prevent closing
	};

	[100] call BIS_fnc_bloodEffect;
	FAR_cutTextLayer cutText ["", "BLACK OUT"];
};

waitUntil {!isNil {_unit getVariable "FAR_killerSuspects"}};

_unit allowDamage true;
_unit setDamage 0.5;

if (!isPlayer _unit) then
{
	{ _unit disableAI _x } forEach ["MOVE","FSM","TARGET","AUTOTARGET"];
};

// Find killer
_killer = _unit call FAR_findKiller;
_unit setVariable ["FAR_killerPrimeSuspect", _killer];

// Injury message
if (FAR_EnableDeathMessages && difficultyEnabled "deathMessages" && !isNil "_killer") then
{
	[_unit, _killer] spawn
	{
		_unit = _this select 0;
		_killer = _this select 1;

		if (isPlayer _unit || FAR_Debugging) then
		{
			_names = [toArray name _unit];

			if (!isNull _killer && {(isPlayer _killer || FAR_Debugging) && (_killer != _unit) && (vehicle _killer != vehicle _unit)}) then
			{
				_names set [1, toArray name _killer];
			};

			FAR_deathMessage = _names;
			publicVariable "FAR_deathMessage";
			["FAR_deathMessage", _names] call FAR_public_EH;
		};
	};
};

_unit spawn
{
	_unit = _this;
	[_unit, "AinjPpneMstpSnonWrflDnon"] call switchMoveGlobal;

	sleep 1;

	_unlimitedStamina = ["A3W_unlimitedStamina"] call isConfigOn;

	while {UNCONSCIOUS(_unit)} do
	{
		if (animationState _unit != "AinjPpneMstpSnonWrflDnon") then
		{
			[_unit, "AinjPpneMstpSnonWrflDnon"] call switchMoveGlobal;
		};

		if (_unit == player && cameraView != "INTERNAL") then
		{
			player switchCamera "INTERNAL";
		};

		if (!STABILIZED(_unit)) then
		{
			if (_unlimitedStamina) then
			{
				_unit setFatigue 0.4;
			}
			else
			{
				_unit setFatigue (0.4 max getFatigue _unit);
			};
		};
		sleep 0.1;
	};

	if (_unit == player && !alive player) then
	{
		player switchCamera "EXTERNAL";
	};
};

// Eject unit if inside vehicle
_unit spawn
{
	private ["_vehicle", "_unconscious"];
	_unit = _this;

	waitUntil
	{
		sleep 0.1;
		_vehicle = vehicle _unit;
		_unconscious = UNCONSCIOUS(_unit);
		((isTouchingGround _vehicle || (getPos _vehicle) select 2 < 1) && {vectorMagnitude velocity _unit < 1}) || !_unconscious
	};

	if (_unconscious && _vehicle != _unit) then
	{
		unassignVehicle _unit;
		moveOut _unit;
	};
};

sleep 2;

if (isPlayer _unit) then
{
	if (_unit == player) then
	{
		FAR_cutTextLayer cutText ["", "BLACK IN"];
		closeDialog 910;

		if (createDialog "ReviveGUI") then
		{
			(findDisplay 911) displayAddEventHandler ["KeyDown", "_this select 1 == 1"]; // blocks Esc to prevent closing
		};
	};

	// Mute ACRE
	_unit setVariable ["ace_sys_wounds_uncon", true];
};

_unit spawn
{
	_unit = _this;

	for "_i" from 1 to FAR_BleedOut step 3 do
	{
		if (!UNCONSCIOUS(_unit) || STABILIZED(_unit)) exitWith {};

		[((_i / FAR_BleedOut) * 20) + 80] spawn BIS_fnc_bloodEffect;
		sleep 3;
	};
};

_bleedStart = diag_tickTime;
_bleedOut = _bleedStart + FAR_BleedOut;

private ["_reviveGUI", "_progBar", "_progText", "_reviveText", "_bleedPause", "_treatedBy"];

if (_unit == player) then
{
	_reviveGUI = findDisplay 911;
	_progBar = _reviveGUI displayCtrl 9110;
	_progText = _reviveGUI displayCtrl 9111;
	_reviveText = _reviveGUI displayCtrl 9113;
};

while {UNCONSCIOUS(_unit) && diag_tickTime < _bleedOut} do
{
	_dmg = damage _unit;

	if (_unit getVariable ["FAR_handleStabilize", false]) then
	{
		_unit setDamage 0.25;
		_unit setVariable ["FAR_handleStabilize", nil, true];
		_unit setVariable ["FAR_treatedBy", nil, true];
		_treatedBy = nil;
	}
	else
	{
		_currentlyTreatedBy = _unit getVariable ["FAR_treatedBy", objNull];

		if (alive _currentlyTreatedBy) then
		{
			if (isNil "_treatedBy") then
			{
				_treatedBy = _currentlyTreatedBy;
				_bleedPause = diag_tickTime - _bleedStart;

				if (_unit == player) then
				{
					_progText ctrlSetText "Being treated...";
				};
			};

			_bleedStart = diag_tickTime - _bleedPause;
		}
		else
		{
			if (!isNil "_treatedBy") then
			{
				_treatedBy = nil;
				_bleedPause = nil;
				_unit setVariable ["FAR_treatedBy", nil, true];
			};
		};
	};

	if (_dmg < 0.5) then // assume healing by medic
	{
		if (!STABILIZED(_unit)) then
		{
			_unit setVariable ["FAR_isStabilized", 1, true];

			if (isPlayer _unit) then
			{
				//Unit has been stabilized. Disregard bleedout timer and umute player
				_unit setVariable ["ace_sys_wounds_uncon", false];
			};
		};

		if (_unit == player) then
		{
			_progBar progressSetPosition 1;
			_progBar ctrlSetForegroundColor [0,0.75,0,1];
			_progText ctrlSetText "Stabilized";
			player setVariable ["FAR_iconBlink", nil, true];

			//(FAR_cutTextLayer + 1) cutText [format ["\n\nYou have been stabilized\n\n%1", call FAR_CheckFriendlies], "PLAIN DOWN", 0.01];
		};

		_bleedStart = diag_tickTime;
	};

	_bleedOut = _bleedStart + (FAR_BleedOut * ((1 - (_dmg max 0.5)) / 0.5));

	if (_unit == player) then
	{
		if (_dmg >= 0.5 && isNil "_treatedBy") then
		{
			_remaining = ceil (_bleedOut - diag_tickTime);
			_mins = floor (_remaining / 60);
			_secs = _remaining - (_mins * 60);
			_time = format ["%1:%2%3", _mins, if (_secs < 10) then { "0" } else { "" }, _secs];

			_progBar progressSetPosition ((_bleedOut - diag_tickTime) / FAR_BleedOut);
			_progText ctrlSetText _time;

			//(FAR_cutTextLayer + 1) cutText [format ["\n\nBleedout in %1\n\n%2", _time, call FAR_CheckFriendlies], "PLAIN DOWN"];
		};

		_reviveText ctrlSetStructuredText parseText (call FAR_CheckFriendlies);
	};

	_draggedBy = DRAGGED_BY(_unit);

	if (!isNull _draggedBy && {!alive _draggedBy || UNCONSCIOUS(_draggedBy)}) then
	{
		if (attachedTo _unit == _draggedBy) then
		{
			detach _unit;
			sleep 0.01;
		};

		if (!isPlayer attachedTo _unit) then
		{
			_unit setVariable ["FAR_draggedBy", nil, true];
		};
	};

	sleep 0.1;
};

if (alive _unit && !UNCONSCIOUS(_unit)) then // Player got revived
{
	_unit setDamage 0;
	_unit setVariable ["FAR_killerPrimeSuspect", nil];
	_unit setVariable ["FAR_killerVehicle", nil];
	_unit setVariable ["FAR_killerAmmo", nil];
	_unit setVariable ["FAR_killerSuspects", nil];
	_unit setVariable ["FAR_isStabilized", 0, true];
	_unit setVariable ["FAR_iconBlink", nil, true];
	_unit setCaptive false;

	if (isPlayer _unit) then
	{
		[] spawn fn_savePlayerData;

		// Unmute ACRE
		_unit setVariable ["ace_sys_wounds_uncon", false];

		if (["A3W_unlimitedStamina"] call isConfigOn) then
		{
			_unit enableFatigue false;
		};
	}
	else
	{
		{ _unit enableAI _x } forEach ["MOVE","FSM","TARGET","AUTOTARGET"];
	};

	_unit playMove format ["AmovPpneMstpSrasW%1Dnon", _unit call getMoveWeapon];
}
else // Player bled out
{
	_unit setDamage 1;

	if (!isPlayer _unit) then
	{
		_unit setVariable ["FAR_isUnconscious", 0, true];
		_unit setVariable ["FAR_draggedBy", nil, true];
		_unit setVariable ["FAR_treatedBy", nil, true];
	};
};

if (_unit == player) then
{
	closeDialog 911;
};
