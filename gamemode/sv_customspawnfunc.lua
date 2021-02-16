concommand.Add("CreateZombie", function(ply)
	local sp = ply:GetEyeTrace().HitPos

	local e = ents.Create("tw_zombie")
	e:SetPos(sp)
	e:Spawn()

	
end)

concommand.Add("CreateS", function(ply)
	local sp = ply:GetEyeTrace().HitPos

	local e = ents.Create("tw_slayer_revenant")
	e:SetPos(sp)
	e:Spawn()

	PrintTable(e:GetSequenceList())
	
end)


concommand.Add("CreateSz", function(ply)
	local sp = ply:GetEyeTrace().HitPos

	local e = ents.Create("tw_slayer_revenant_ex")
	e:SetPos(sp)
	e:Spawn()

	PrintTable(e:GetSequenceList())
	
end)


concommand.Add("CreateSa", function(ply)
	local sp = ply:GetEyeTrace().HitPos

	local e = ents.Create("tw_slayer_morbus")
	e:SetPos(sp)
	e:Spawn()

	PrintTable(e:GetSequenceList())
	
end)