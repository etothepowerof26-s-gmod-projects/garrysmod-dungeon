
    function Hitmark(ent, dmg, pos, crt, filter)
        ent = ent or NULL
        dmg = dmg or 0
        pos = pos or ent:EyePos()
        filter = filter or player.GetAll()
        net.Start("hitmark")
        net.WriteEntity(ent)
        net.WriteFloat(dmg)
        net.WriteVector(pos)
        net.WriteBit(crt)
        net.WriteFloat(ent:Health())
        net.WriteFloat(ent:GetMaxHealth())
        net.Send(filter)
    end

    util.AddNetworkString("hitmark")
    hook.Remove("EntityTakeDamage", "hitmarker")

    hook.Add("Think", "hitmarker", function()
        for _, ply in pairs(player.GetAll()) do
            if ply.hm_last_health ~= ply:Health() then
                local diff = ply:Health() - (ply.hm_last_health or 0)

                if diff > 0 then
                    Hitmark(ply, diff)
                end

                ply.hm_last_health = ply:Health()
            end
        end
    end)