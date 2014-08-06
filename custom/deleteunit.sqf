{deletevehicle _x} foreach units (_this select 0);
{deletevehicle _x} foreach units (_this select 1);
{deletevehicle _x} foreach units (_this select 2);
{deletevehicle _x} foreach units (_this select 3);

sleep 0.1;

deletegroup (_this select 0);
deletegroup (_this select 1);
deletegroup (_this select 2);
deletegroup (_this select 3);


true;

if (true) exitwith {};