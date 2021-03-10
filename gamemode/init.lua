AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("datastore/init.lua")
-- all the methods here
include("dgn_core.lua")
-- skills
-- slayer
include("slayer.lua")
-- custom spawn func
include("sv_customspawnfunc.lua")
include("npc/init.lua")
include("enemyspawner/init.lua")

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
    -- for the full load mechanism
    ply:SetVar("NotFullyLoaded", true)
    ply:SetVar("StartLoadTime", SysTime())
    ply:SetTeam(420)
    self:DefaultPlyStats(ply)
    -- GAMEMODE:PlayerSpawnAsSpectator(ply)
end

function GM:PlayerSpawn(ply)
    ply:SetupHands(ply)
    ply:SetTeam(420)

    -- ply:SendLua[[hook.Remove("CalcView", "DGN_SpawnNoLoad")]]
    if ply:GetDClassID() == 0 and not ply:IsBot() then
        GAMEMODE:PlayerSpawnAsSpectator(ply)
    else
        ply:SetTeam(TEAM_UNASSIGNED)
        ply:UnSpectate()

        timer.Simple(2, function()
            local w = ply:Give("tw_ttt_m16")
            w:SetClip1(99999)
            ply:Give("tw_bonerang")
            ply:Give("weapon_crowbar")
        end)
    end
end

function GM:PlayerFullLoad(ply)
    print("Player", ply, "fully loaded.")
    net.Start("DGN_CCREATE_ShowMenu")
    net.Send(ply)

    timer.Simple(0.5, function()
        self:DefaultPlyStats(ply)
        CCREATE:SendClassesTo(ply)
    end)
end

function GM:CanPlayerSuicide(ply)
    print(ply)
    if (ply:GetObserverMode() == OBS_MODE_ROAMING) then return false end

    return not false
end

function GM:GetFallDamage(ply, speed)
    local c = math.max(0, math.ceil(0.2418 * speed - 120.75))
    if (GAMEMODE.WarriorDashCache[ply]) then return 0 end

    return c
end

---
-- Modified version of
-- https://github.com/yumi-xx/gmod-streamstage/blob/master/gamemodes/stream/gamemode/init.lua#L7
---
hook.Add("SetupMove", "FullLoadSetup", function(ply, _, cmd)
    if (ply:GetVar("NotFullyLoaded", true) and not cmd:IsForced()) then
        ply:SetVar("NotFullyLoaded", false)
        hook.Run("PlayerFullLoad", ply)
        -- GAMEMODE:PlayerFullLoad(ply)
    end
end)

function GM:PostGamemodeLoaded()
    Log("gdungeon")("Gamemode has fully loaded.")
    --[[hook.Add("Tick", "DGN_TickPostGamemodeLoad", function()
		hook.Remove("Tick", "DGN_TickPostGamemodeLoad")
		local L = Log("gdungeon")

		http.Fetch("https://api.github.com/repos/etothepowerof26-s-gmod-projects/garrysmod-dungeon/commits/master", function(body)
			local tab = util.JSONToTable(body)
			local latest = tab.commit.tree.sha:sub(1, 8)
			L("Gamemode is fully loaded. Running version", latest, "from", tab.commit.author.date)
		end)
	end)]]
end

function GM:PlayerSetHandsModel(ply, ent)
    local simplemodel = player_manager.TranslateToPlayerModelName(ply:GetModel())
    local info = player_manager.TranslatePlayerHands(simplemodel)

    if (info) then
        ent:SetModel(info.model)
        ent:SetSkin(info.skin)
        ent:SetBodyGroups(info.body)
    end
end