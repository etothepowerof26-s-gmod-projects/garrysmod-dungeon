-- print("ayoaa")


CCREATE = {}



if SERVER then

	local L = Log("charcreate")

	// load all vgui menus before the actual panel logic
	AddCSLuaFile("dgn_class_tooltip.lua")
	AddCSLuaFile("dgn_class_button.lua")
	AddCSLuaFile("dgn_basemenu.lua")
	AddCSLuaFile("dgn_charcreate.lua")

	AddCSLuaFile("panels.lua")

	// serverside stuff
	include("classes.lua")

	net.Receive("DGN_CCREATE_Request", function(len, ply)
		local cid = net.ReadUInt(8)
		local class = CCREATE.Classes[cid]

		if not class then return end

		L("Player wanted class id", ply, cid, class.Name)

		ply:ChatPrint("You picked: " .. class.Name)
		ply:SetDClassID(cid)
		ply:Spawn()
	end)

end

if CLIENT then

	CCREATE.CachedMarkups = {}

	include("panels.lua")

end



 



-- DUNGEON.CharacterCreate = CCREATE