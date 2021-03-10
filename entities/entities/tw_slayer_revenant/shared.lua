ENT.Base = "tw_zombie"
ENT.PrintName = "Revenant"
ENT.Author = 'twentysix'
ENT.AutomaticFrameAdvance = true
ENT.Spawnable = false
ENT.AdminSpawnable = true
ENT.MinEXPFromKill = 100
ENT.MaxEXPFromKill = 750

-- total health
function ENT:TotalMobHealth()
    -- default is mobl evel * 10
    return 10000
end

-- called serverside
function ENT:DefaultVars()
    self:SetMobLevel(125)
    --for i = 1, 100 do
    --	if math.random(1, 2) == 1 then break; end
    --
    --	self:SetMobLevel(self:GetMobLevel() + 1)
    --end
    --if math.Rand(0,1) < 1 / 25 or _G.TW_FORCE_SPAWN then
    --	_G.TW_FORCE_SPAWN = nil
    --	self:SetMobLevel(25 + (5 * math.random(0, 5)))
    --	self:SetSpecial(true)
    --	PrintMessage(3, "A special " .. self.PrintName .. " has spawned! Kill it for extra loot!")
    --end
end
-- Revenant: models/monster/moub/morbus_epidemia.mdl
-- Morbus: models/monster/moub/morbus_rock.mdl