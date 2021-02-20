--

local pos = {
	{
		ent = "dgn_newbie_questgiver",
		pos = Vector(803.30023193359, -1123.6060791016, -143.96875),
		ang = Angle(-1.9900013208389, 135.69975280762, 0)
	}
}

local function spawn()
	for i = 1, #pos do
		local data = pos[i]

		local ent = ents.Create(data.ent)
		ent:Spawn()
		ent:SetPos(data.pos)
		ent:SetAngles(data.ang)
	end
end

hook.Add("InitPostEntity", "DGN_SpawnNPCs", spawn)

hook.Add("PostCleanupMap", "DGN_Respawn", spawn)

concommand.Add("dgn_force_respawn_ents", function(ply)
	if not (ply == NULL or (IsValid(ply) and ply:IsSuperAdmin())) then
		return
	end

	for k,v in pairs(ents.FindByClass("dgn_*")) do
		if v:GetClass() == "dgn_npc" or v.Base == "dgn_npc" then
			v:Remove()
		end
	end

	spawn()
end)

concommand.Add("delall", function()
	for k,v in pairs(ents.FindByClass("tw_*")) do
		--if v:GetClass() == "dgn_npc" or v.Base == "dgn_npc" then
			v:Remove()
		--end
	end
end)-- ")