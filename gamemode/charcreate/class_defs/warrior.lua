do
	local WARRIOR = {}

	WARRIOR.Name = "Warrior"
	WARRIOR.FlavorText = "Highly valued swordsman."
	WARRIOR.Icon = "icon16/stop.png"

	WARRIOR.BaseStats = {
		health = 115,
		defense = 50,
		strength = 20,
		intelligence = 100
	}

	WARRIOR.Abilities = {
		{
			name = "Dash",
			desc = "Dash towards an opponent, sending you flying towards them and dealing damage upon impact. Also gives additional strength upon dashing.",
			type = "a",
			cooldown = 60,
			reqlevel = 5
		},
		{
			name = "Shredder",
			desc = "For a duration, you shred a portion of an enemy's health, giving back <color=255,0,0>10%</color><color=255,255,255> of the damage as health.",
			type = "a",
			cooldown = 15,
			reqlevel = 15
		}
	}

	CCREATE.Classes[#CCREATE.Classes + 1] = WARRIOR
end

local ply_w_presses = setmetatable({}, { __mode = "k" })
local U = 500 ^ 2

local function fart()
	GAMEMODE.WarriorDashCache = setmetatable({}, { __mode = "k" })
end

hook.Add("PostGamemodeLoaded", "DGN_WarrCach", fart)

hook.Add( "KeyPress", "keypress_use_hi", function( ply, key )
	local class = ply:GetDClassID()
	class = CCREATE.Classes[class]

	local TIME = 0.35
	if (ply:Ping() > 50) then
		TIME = TIME + (ply:Ping() - 50) / 45
	end

	if (class.Name == "Warrior" and key == IN_FORWARD) then
		local w_presses = ply_w_presses[ply]
		if not w_presses then
			ply_w_presses[ply] = {}
			ply_w_presses[ply].amount = 1
			ply_w_presses[ply].last = SysTime()
		else
			local realtime = w_presses.last + TIME
			local within = realtime + 0.85
			if (SysTime() >= realtime and SysTime() <= within) then
				w_presses.amount = w_presses.amount + 1
				if (w_presses.amount >= 2) then
					w_presses.amount = 1
					w_presses.last = SysTime() + 5
					ply:SetVelocity(ply:GetAimVector() * 1500)
					GAMEMODE.WarriorDashCache[ply] = true
				end
			else
				if SysTime() > within then
					w_presses.last = SysTime()
					w_presses.amount = 0
				end
			end
		end
	end
end )


hook.Add("Think", "DGN_HandlePlayerFell", function()
	for k,v in pairs(GAMEMODE.WarriorDashCache) do
		if k:IsOnGround() then
			GAMEMODE.WarriorDashCache[k] = nil
			
			--[[local gent = k:GetGroundEntity()
			if (IsValid(gent) and gent != game.GetWorld()) then
				DUNGEON.HandleWarriorDash(k, gent, gent:GetPos())
			elseif (IsValid(gent) and gent == game.GetWorld()) then
				
			end]]
			local effectdata = EffectData()
			effectdata:SetOrigin( k:GetPos() )
			util.Effect( "Explosion", effectdata )
			util.BlastDamage( k, k, k:GetPos(), 500, 35 )
		end
	end
end)

if DUNGEON.HandleWarriorDash then
	fart()
end

-- npc/dog/car_impact2.wav
-- ambient/materials/roust_crash2.wav
-- 
-- physics/metal/metal_large_debris1.wav
-- physics/metal/metal_large_debris2.wav