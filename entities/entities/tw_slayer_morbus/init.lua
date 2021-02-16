--
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")
include("shared.lua")
include("sv_ai.lua")

function ENT:Initialize()

	self:DefaultVars()

	local d = 7500
	local f = 25000

	self:SetModel("models/monster/moub/morbus_pestis.mdl")
	self:SetHealth(self:TotalMobHealth())
	self:SetMaxHealth(self:TotalMobHealth())

	self.SearchRadius = f
	self.LoseTargetDist = f * 1.25

	self:SetPos(self:GetPos() + Vector(0, 0, 100))

end

function ENT:OnKilled(dmg)
	
	-- hook.Call( "OnNPCKilled", GAMEMODE, self, dmg:GetAttacker(), dmg:GetInflictor() )

	print(SERVER, CLIENT)

	-- gamemode.Call( "AddDeathNotice", "Anubis the Enlightened one( Lv.25 )", 69, "weapon_ar2", ply:Nick(), ply:Team() )

	self:EmitSound('npc/zombie/zombie_die' .. math.random(1,3) .. '.wav')
	-- local rag = self:BecomeRagdoll(dmg)
	SafeRemoveEntityDelayed(self:BecomeRagdoll(dmg), 5)
	self:DefaultKillFunc(dmg)


	-- GAMEMODE:HandlePlayerLV(pl)

end