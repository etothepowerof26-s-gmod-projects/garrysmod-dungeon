ENT.PrintName = "Bone Rang Ent"
ENT.Author = "twentysix"

ENT.Type = "anim"
ENT.Base = "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar("Entity", 0, "BoneThrower")
	self:NetworkVar("Vector", 0, "Want")
end