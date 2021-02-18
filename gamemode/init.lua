AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")

-- all the methods here
include("dgn_core.lua")
-- skills
-- slayer
include("slayer.lua")
-- custom spawn func
include("sv_customspawnfunc.lua")

function GM:DefaultPlyStats(ply)
		ply:SetPLevel(1)
		ply:SetExperience(0)
		ply:SetNeededExp(DUNGEON.GetNeededExperience(ply:GetPLevel()))
		ply:SetDefense(0)
		ply:SetMana(20)
		ply:SetMaxMana(20)
		ply:SetCritChance(5)
		ply:SetCritDamage(50)
		ply:SetStrength(10)
end

function GM:PlayerInitialSpawn(ply)

	ply:SetModel("models/player/kleiner.mdl")

	// for the full load mechanism
	ply:SetVar("NotFullyLoaded", true)
	ply:SetVar("StartLoadTime", SysTime())

	ply:SetTeam(420)

	-- GAMEMODE:PlayerSpawnAsSpectator(ply)

end 

function GM:PlayerSpawn(ply)

	--timer.Simple(3,function()
		--local w = ply:Give("tw_ttt_m16")
		--w:SetClip1(99999)
	--end)
	ply:SetTeam(420)
	-- ply:SendLua[[hook.Remove("CalcView", "DGN_SpawnNoLoad")]]

	if not ply.TESTLOAD then
		GAMEMODE:PlayerSpawnAsSpectator(ply)
	else
		ply:SetTeam(TEAM_UNASSIGNED)
		ply:UnSpectate()
	end
		self:DefaultPlyStats(ply)


	--[[if !ply.SAFE then
		GAMEMODE:PlayerSpawnAsSpectator(ply)
		ply.SAFE = false;
	end]]

end

function GM:PlayerFullLoad(ply)
	print("Player", ply, "fully loaded.")

	
	net.Start("DGN_CCREATE_ShowMenu")
	net.Send(ply)

	timer.Simple(0.5, function()
		self:DefaultPlyStats(ply)

		CCREATE:SendClassesTo(ply)
	end)


	// this is temporary
	--ply.SAFE = true
	--ply:UnSpectate()
	--ply:SetTeam(1)
	--ply:Spawn()
	--ply:SendLua[[hook.Remove("CalcView", "DGN_SpawnNoLoad")]]
	--DUNGEON:SendStartMenu(ply)
end

concommand.Add("testshowcmenu", function(ply)
ply.SentClassData = false
net.Start("DGN_CCREATE_ShowMenu")
		net.Send(ply)
		CCREATE:SendClassesTo(ply)
end)

function GM:CanPlayerSuicide(ply)
	print(ply)
	if (ply:GetObserverMode() == OBS_MODE_ROAMING) then
		return false
	end
	return !false;
end
function GM:GetFallDamage( ply, speed )
	local c = math.max( 0, math.ceil( 0.2418 * speed - 120.75 ) )
	// print(math.ceil( 0.2418 * speed - 141.75 ))
	return c
end 

---
-- Modified version of
-- https://github.com/yumi-xx/gmod-streamstage/blob/master/gamemodes/stream/gamemode/init.lua#L7
---

hook.Add("SetupMove", "FullLoadSetup", function(ply, _, cmd)
	if (ply:GetVar("NotFullyLoaded", true) && !cmd:IsForced()) then
		ply:SetVar("NotFullyLoaded", false)
		GAMEMODE:PlayerFullLoad(ply)
	end
end)