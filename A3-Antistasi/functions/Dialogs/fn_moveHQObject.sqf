if (player != theBoss) exitWith {["Move HQ", "Only Player Commander is allowed to move HQ assets"] call A3A_fnc_customHint;};
private ["_thingX","_playerX","_id","_sites","_markerX","_size","_positionX"];

_thingX = _this select 0;
_playerX = _this select 1;
_id = _this select 2;

if (!(isNull attachedTo _thingX)) exitWith {["Move HQ", "The asset you want to move is being moved by another player"] call A3A_fnc_customHint;};
if (vehicle _playerX != _playerX) exitWith {["Move HQ", "You cannot move HQ assets while in a vehicle"] call A3A_fnc_customHint;};

if ({!(isNull _x)} count (attachedObjects _playerX) != 0) exitWith {["Move HQ", "You have other things attached, you cannot move this"] call A3A_fnc_customHint;};
_sites = markersX select {sidesX getVariable [_x,sideUnknown] == teamPlayer};
_markerX = [_sites,_playerX] call BIS_fnc_nearestPosition;
_size = [_markerX] call A3A_fnc_sizeMarker;
_positionX = getMarkerPos _markerX;
if (_playerX distance2D _positionX > _size) exitWith {["Move HQ", "This asset needs to be closer to it relative zone center to be able to be moved"] call A3A_fnc_customHint;};

_thingX setVariable ["objectBeingMoved", true];

_thingX removeAction _id;
_thingX attachTo [_playerX,[0,2,1]];

private _fnc_placeObject = {
	params [["_thingX", objNull], ["_playerX", objNull], ["_dropObjectActionIndex", -1]];

	if (isNull _thingX) exitWith {diag_log "[Antistasi] Error, trying to place invalid HQ object"};
	if (isNull _playerX) exitWith {diag_log "[Antistasi] Error, trying to place HQ object with invalid player"};

	if (!(_thingX getVariable ["objectBeingMoved", false])) exitWith {};

	if (_playerX == attachedTo _thingX) then {
		detach _thingX;
	};

	if (_dropObjectActionIndex != -1) then {
		_playerX removeAction _dropObjectActionIndex;
	};

	_thingX setVelocity [0,0,0];		// some objects never lose their velocity when detached, becoming lethal
	_thingX setVectorUp surfaceNormal position _thingX;
	_thingX setPosATL [getPosATL _thingX select 0,getPosATL _thingX select 1,0.1];

	_thingX setVariable ["objectBeingMoved", false];
	_thingX addAction ["Move this asset", A3A_fnc_moveHQObject,nil,0,false,true,"","(_this == theBoss)"];
};

private _actionX = _playerX addAction ["Drop Here", {
	(_this select 3) params ["_thingX", "_fnc_placeObject"];

	[_thingX, player, (_this select 2)] call _fnc_placeObject;
}, [_thingX, _fnc_placeObject],0,false,true,"",""];

waitUntil {sleep 1; (_playerX != attachedTo _thingX) or (vehicle _playerX != _playerX) or (_playerX distance2D _positionX > (_size-3)) or !([_playerX] call A3A_fnc_canFight) or (!isPlayer _playerX)};

[_thingX, _playerX, _actionX] call _fnc_placeObject;

if (vehicle _playerX != _playerX) exitWith {["Move HQ", "You cannot move HQ assets while in a vehicle"] call A3A_fnc_customHint;};

if  (_playerX distance2D _positionX > _size) exitWith {["Move HQ", "This asset cannot be moved more far away for its zone center"] call A3A_fnc_customHint;};
