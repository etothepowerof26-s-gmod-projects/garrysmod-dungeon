do
	local MAGE = {}

	MAGE.Name = "Mage"
	MAGE.FlavorText = "Magic man do magic stuff."
	MAGE.Icon = "icon16/stop.png"

	MAGE.BaseStats = {
		health = 90,
		defense = 35,
		strength = 0,
		intelligence = 250
	}

	MAGE.Abilities = {
		{
			name = "Fireball",
			desc = "Every attack gives a 15% chance to shoot out a fireball. The fireball's damage depends on how much Intelligence you have.",
			type = "p",
			cooldown = 20,
			reqlevel = 0
		}
	}

	CCREATE.Classes[#CCREATE.Classes + 1] = MAGE
end