-- level up

function GM:CanPlayerLevelUp(ply)
	return (ply:GetExperience() >= ply:GetNeededExp())
end

function GM:HandlePlayerLV(ply)

	while (self:CanPlayerLevelUp(ply)) do
		-- if (!self:CanPlayerLevelUp(ply)) then return; end

		ply:SetExperience(ply:GetExperience() - ply:GetNeededExp())
		ply:SetPLevel(ply:GetPLevel() + 1)
		ply:SetNeededExp(DUNGEON.GetNeededExperience(ply:GetPLevel()))

		PrintMessage(3, string.format("Level up! %s is now level %s", ply:Nick(), ply:GetPLevel()))
	end
	-- dunno lol

end

-- damage and experience


util.AddNetworkString("DGN_DeathNotice")
function GM:HandleProperEnemyDeath(ply, enm, t)

	if (not t) then t = 2; end
	
	// don't know if it's the right call
	local pos = enm:GetPos()

	net.Start("DGN_DeathNotice")

		-- gamemode.Call( "AddDeathNotice", "Anubis the Enlightened one( Lv.25 )", 69, "weapon_ar2", ply:Nick(), ply:Team() )
		local pretty_name = "Lv." .. tostring(enm:GetMobLevel()) .. " " .. enm.PrintName
		local wclass = ply:GetActiveWeapon():GetClass()

		net.WriteString(pretty_name)
		-- was gonna write team but enemies are just 2
		net.WriteInt(t, 8)
		net.WriteString(wclass)
		net.WriteString(ply:Nick())
		net.WriteInt(ply:Team(), 8)

	net.SendPVS(pos)

end

function GM:ProcessExperienceMultiplier(ply, enemy, exp)

	local total
	
	// just for lols
	total = 1

	return total -- exp * total

end

hook.Add( "PlayerShouldTakeDamage", "DGN_PreventSelfDmg", function( ply, attacker )
	if (ply == attacker) then
		return false
	end
end)

function GM:PlayerHurt( victim, attacker, remaining, taken )
	--if (victim == attacker) then
	--	return
	--end
	local pos = victim:GetPos()
	local is_crit = false 
	local filter = ents.FindInPVS(pos)
	if remaining <= 0 then
		is_crit = true
	end
	Hitmark(victim, -taken, pos, is_crit, filter)
end

function GM:ScaleNPCDamage( npc, hitgroup, dmg )

	local pl
	if IsValid(dmg:GetAttacker()) and dmg:GetAttacker():IsPlayer() then
		pl = dmg:GetAttacker()
	else
		if IsValid(dmg:GetInflictor()) and dmg:GetInflictor():IsPlayer() then
			pl = dmg:GetInflictor()
		end
	end

	
	
	
	// dmg calc
	local REALDMG = dmg:GetDamage()

	// randomize with range
	REALDMG = math.random(REALDMG * 0.8, REALDMG * 1.2)
	
	// strength
	local str = pl:GetStrength()
	if str > 0 then
		REALDMG = REALDMG + (3 + math.ceil(str / 10))
		REALDMG = REALDMG * (1 + str / 150)
	end

	// pl:SetStrength(pl:GetStrength() + 1)
	--PrintMessage(3, dmg:GetDamage() .. " -> " .. REALDMG)
	--PrintMessage(3, tostring(pl:GetStrength()) .. " (" .. (REALDMG - dmg:GetDamage()) .. " added)")
	
	// critical hits
	local c_ch = math.Clamp(pl:GetCritChance(), 0, 100)
	local c_cd = pl:GetCritDamage()
	local is_crit = false

	if (math.random(0, 100) <= c_ch) then
		REALDMG = REALDMG * (1 + c_cd / 100)
		--PrintMessage(3, "CRIT!")
		is_crit = true
	end


	// ceil the damage so no decimal
	REALDMG = math.ceil(REALDMG)
	dmg:SetDamage(REALDMG)

	-- insert hitmark code here
	local pos = dmg:GetDamagePosition() + (VectorRand(-1, 1) * 30)
	local filter = ents.FindInPVS(npc:GetPos())

	Hitmark(npc, -REALDMG, pos, is_crit, filter)
	


	--[[local pos = npc:GetPos()
	net.Start("DGN_Indicator")
		net.WriteEntity(npc)
		net.WriteInt(dmg:GetDamage(), 32)
	net.SendPVS(pos)]]

	-- PrintMessage(3, dmg:GetDamage())

end