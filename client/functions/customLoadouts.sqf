private ["_player", "_uniform", "_vest", "_headgear", "_goggles"];
_player = _this;

if ((getPlayerUID _player) in ["76561198079546085"]) then { 
// "Remove existing items";
removeAllWeapons _player;
removeAllItems _player;
removeAllAssignedItems _player;
removeUniform _player;
removeVest _player;
removeBackpack _player;
removeHeadgear _player;
removeGoggles _player;
 
// "Add containers";
_player forceAddUniform "Night1_RS";
_player addItemToUniform "FirstAidKit";
_player addHeadgear "H_HelmetO_oucamo";
_player addGoggles "G_Tactical_Black";
_player addVest "V_PlateCarrierIAGL_dgtl";
_player addItemToVest "30Rnd_556x45_Stanag";
_player addItemToVest "30Rnd_556x45_Stanag";
_player addItemToVest "30Rnd_556x45_Stanag";
_player addItemToVest "30Rnd_45ACP_MAG_SMG_01";
_player addItemToVest "30Rnd_45ACP_MAG_SMG_01";
_player addItemToVest "30Rnd_45ACP_MAG_SMG_01";
_player addBackpack "B_Carryall_oucamo";
_player addItemToBackpack "ToolKit";
_player addItemToBackpack "FirstAidKit";
_player addItemToBackpack "DemoCharge_Remote_Mag";
_player addItemToBackpack "DemoCharge_Remote_Mag";
_player addItemToBackpack "30Rnd_556x45_Stanag";
_player addItemToBackpack "30Rnd_556x45_Stanag";
_player addItemToBackpack "30Rnd_556x45_Stanag";
_player addItemToBackpack "30Rnd_556x45_Stanag";
_player addItemToBackpack "30Rnd_556x45_Stanag";
_player addItemToBackpack "30Rnd_45ACP_MAG_SMG_01";
_player addItemToBackpack "30Rnd_45ACP_MAG_SMG_01";
_player addItemToBackpack "30Rnd_45ACP_MAG_SMG_01";
_player addItemToBackpack "30Rnd_45ACP_MAG_SMG_01";
_player addItemToBackpack "30Rnd_45ACP_MAG_SMG_01";
 
// "Add weapons";
_player addWeapon "hlc_rifle_RU5562";
_player addPrimaryWeaponItem "hlc_muzzle_556NATO_KAC";
_player addPrimaryWeaponItem "FHQ_acc_ANPEQ15_black";
_player addPrimaryWeaponItem "FHQ_optic_AC12136";
_player addWeapon "ag_mp9_sidearm";
_player addHandgunItem "MP9_suppressor";
_player addHandgunItem "FHQ_optic_AC11704";
 
// "Add items";
_player addItem "ItemMap";
_player addItem "ItemCompass";
_player addItem "ItemWatch";
_player addItem "ItemRadio";
_player addItem "Rangefinder";
};