-- print("ayoaa")


CCREATE = {}

if SERVER then

	// load all vgui menus before the actual panel logic
	AddCSLuaFile("dgn_class_tooltip.lua")
	AddCSLuaFile("dgn_class_button.lua")
	AddCSLuaFile("dgn_basemenu.lua")
	AddCSLuaFile("dgn_charcreate.lua")

	AddCSLuaFile("panels.lua")

	// serverside stuff
	include("classes.lua")

end

if CLIENT then

	CCREATE.CachedMarkups = {}

	include("panels.lua")

end



 



-- DUNGEON.CharacterCreate = CCREATE