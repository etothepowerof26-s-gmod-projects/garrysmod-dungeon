ENT.Base = "base_nextbot";
ENT.PrintName = "Zombie";

ENT.Author = 'twentysix';

ENT.AutomaticFrameAdvance  = true;

ENT.Spawnable = false;
ENT.AdminSpawnable = true;

ENT.MinEXPFromKill = 1;
ENT.MaxEXPFromKill = 4;

function ENT:SetupDataTables()
	self:NetworkVar("Int", 0, "MobLevel")

	self:NetworkVar("Bool", 0, "Special")
end

-- total health
function ENT:TotalMobHealth()
	-- default is mobl evel * 10
	return self:GetMobLevel() * 10
end

-- called serverside
function ENT:DefaultVars()
	self:SetMobLevel(1)

	for i = 1, 100 do
		if math.random(1, 2) == 1 then break; end

		self:SetMobLevel(self:GetMobLevel() + 1)
	end

	if math.Rand(0,1) < 1 / 25 or _G.TW_FORCE_SPAWN then
		_G.TW_FORCE_SPAWN = nil
		self:SetMobLevel(25 + (5 * math.random(0, 5)))
		self:SetSpecial(true)
		PrintMessage(3, "A special " .. self.PrintName .. " has spawned! Kill it for extra loot!")
	end
end

-- Revenant: models/monster/moub/morbus_epidemia.mdl
-- Morbus: models/monster/moub/morbus_rock.mdl
