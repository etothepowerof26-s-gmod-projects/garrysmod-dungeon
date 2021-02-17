CCREATE.Classes = {}

util.AddNetworkString("DGN_CCREATE_Request")
util.AddNetworkString("DGN_CCREATE_ShowMenu")
util.AddNetworkString("DGN_CCREATE_RequestCharacterListOption")

function CCREATE:SendClassData(ply, class)
	net.Start("DGN_CCREATE_RequestCharacterListOption")
		net.WriteString(class.Name)
		net.WriteString(class.FlavorText)
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

	if (ply.SentClassData) then return end
	ply.SentClassData = true

	net.Start("DGN_CCREATE_Request")
		net.WriteUInt(#self.Classes, 4)
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

do
	local WARRIOR = {}

	WARRIOR.Name = "Warrior"
	WARRIOR.FlavorText = "Highly valued swordsman."

	WARRIOR.BaseStats = {
		health = 115,
		defense = 50,
		strength = 20,
		intelligence = 100
	}

	WARRIOR.Abilities = {
		{
			name = "Dash",
			desc = "Dash towards an opponent, sending you flying towards them and dealing damage upon impact. Also gives additional strength upon dashing.",
			type = "a",
			cooldown = 60,
			reqlevel = 5
		},
		{
			name = "Shredder",
			desc = "For a duration, you shred a portion of an enemy's health, giving back <color=255,0,0>10%</color><color=255,255,255> of the damage as health.",
			type = "a",
			cooldown = 15,
			reqlevel = 15
		}
	}

	CCREATE.Classes[#CCREATE.Classes + 1] = WARRIOR
end