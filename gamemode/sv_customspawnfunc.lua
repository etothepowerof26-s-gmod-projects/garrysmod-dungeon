concommand.Add("CreateZombie", function(ply)
    local sp = ply:GetEyeTrace().HitPos
    local e = ents.Create("tw_zombie")
    e:SetPos(sp)
    e:Spawn()
end)

concommand.Add("CreateZ", function(ply)
    local max = 25
    local sp = ply:GetPos()

    for i = 1, max do
        local ang = (360 / max) * (i - 1)
        local d = math.rad(ang)
        local xo = math.sin(d)
        local yo = math.cos(d)
        local e = ents.Create("tw_zombie")
        e:SetPos(sp + Vector(xo * 600, yo * 600, 0))
        e:Spawn()
    end
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

concommand.Add("CreateBr", function(ply)
    local sp = ply:GetEyeTrace().HitPos
    local e = ents.Create("drhax")
    e:SetPos(sp)
    e:Spawn()
end)
--PrintTable(e:GetSequenceList())