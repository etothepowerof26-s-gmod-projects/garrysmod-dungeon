ENT.Type      = "ai"
ENT.Base      = "base_ai"

ENT.PrintName = "Dungeon NPC"
ENT.Author    = "twentysix"

ENT.AutomaticFrameAdvance = true

function ENT:SetAutomaticFrameAdvance( b )
	self.AutomaticFrameAdvance = b
end

ENT.GenderTable = {
	["models/alyx.mdl"           ] = "female";
	["models/barney.mdl"         ] = "male";
	["models/player/p2_chell.mdl"] = "female";
	["models/mossman.mdl"        ] = "female";
	["models/player/odessa.mdl"  ] = "male";
	["models/gman.mdl"           ] = "male";
	["models/barney.mdl"         ] = "male";
	["models/eli.mdl"            ] = "male";
	["models/monk.mdl"           ] = "male";
	["models/odessa.mdl"         ] = "male";
}

ENT.Sounds = {
	["explode"] = {
		"ambient/explosions/explode_1.wav",
		"ambient/explosions/explode_2.wav",
		"ambient/explosions/explode_3.wav",
		"ambient/explosions/explode_4.wav",
		"ambient/explosions/explode_5.wav",
		"ambient/explosions/explode_6.wav",
		"ambient/explosions/explode_7.wav",
		"ambient/explosions/explode_8.wav",
		"ambient/explosions/explode_9.wav"
	}	
}

ENT.VoiceLines = {
	["male"] = {
		["talk"] = {
			"vo/npc/male01/hi01.wav",
			"vo/npc/male01/hi02.wav"
		},
		["hurt"] = {
			"vo/trainyard/male01/cit_hit01.wav",
			"vo/trainyard/male01/cit_hit02.wav",
			"vo/trainyard/male01/cit_hit03.wav",
			"vo/trainyard/male01/cit_hit04.wav",
			"vo/trainyard/male01/cit_hit05.wav"
		}
	},
	["female"] = {
		["talk"] = {
			"vo/npc/female01/hi01.wav",
			"vo/npc/female01/hi02.wav"
		},
		["hurt"] = {
			"vo/trainyard/female01/cit_hit01.wav",
			"vo/trainyard/female01/cit_hit02.wav",
			"vo/trainyard/female01/cit_hit03.wav",
			"vo/trainyard/female01/cit_hit04.wav",
			"vo/trainyard/female01/cit_hit05.wav"
		}	
	}
}

function ENT:GetGender()
	local mdl = self:GetModel()
	if mdl:lower():find("female") then
		return "female"
	elseif mdl:lower():find("male") then
		return "male"
	end
	
	if self.GenderTable[mdl] then
		return self.GenderTable[mdl]
	end
	
	return "unknown"
end
