CCREATE.Classes = {}

util.AddNetworkString("DGN_CCREATE_Request")
util.AddNetworkString("DGN_CCREATE_ShowMenu")
util.AddNetworkString("DGN_CCREATE_RequestCharacterListOption")

function CCREATE:SendClassData(ply, class)
	net.Start("DGN_CCREATE_RequestCharacterListOption")
		net.WriteString(class.Name)
		net.WriteString(class.FlavorText)
		net.WriteString(class.Icon)
		net.WriteUInt(class.BaseStats.health, 16)
		net.WriteUInt(class.BaseStats.defense, 16)
		net.WriteUInt(class.BaseStats.strength, 16)
		net.WriteUInt(class.BaseStats.intelligence, 16)

		net.WriteUInt(#class.Abilities, 4)
		if (#class.Abilities > 0) then
			for i = 1, #class.Abilities do
				local ability = class.Abilities[i]
				net.WriteString(ability.name)
				net.WriteString(ability.desc)
				net.WriteString(ability.type)
				net.WriteUInt(ability.cooldown, 12)
				net.WriteUInt(ability.reqlevel, 8)
			end
		end
	net.Send(ply)
end

function CCREATE:SendClassesTo(ply)
	if (!IsValid(ply)) then
		return
	end

	-- TODO: Use data funcs to find character data

	if (ply.SentClassData) then return end
	ply.SentClassData = true

	net.Start("DGN_CCREATE_Request")
		net.WriteUInt(#self.Classes, 8)
	net.Send(ply)

	timer.Simple(0.5, function()
		if (!IsValid(ply)) then
			-- why they leave so soon
			return
		end

		for i = 1, #self.Classes do
			self:SendClassData(ply, self.Classes[i])
		end
	end)
end

include("class_defs/warrior.lua")

include("class_defs/mage.lua")