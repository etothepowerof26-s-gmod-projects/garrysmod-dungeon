

resource.AddFile( "models/monster/moub/morbus_epidemia.mdl" )
resource.AddFile( "models/monster/moub/morbus_pestis.mdl" )
resource.AddFile( "models/monster/moub/morbus_rock.mdl" )

local Player = FindMetaTable("Player")





function Player:InSlayerQuest()
	return self:GetPData("Dungeon_SlayerQuestID", "false") != "false"
end



//saveload
function Player:GetSlayerKillCount()
	if (!self:GetNWBool("SlayerLoaded", true)) then
		self:LoadCurrentSlayerKills()
		return 0
	end
	return self:GetNWInt("SlayerRemainingKills", 0)
end
function Player:LoadCurrentSlayerKills()
	local pdata = tonumber(string.Trim(self:GetPData("SlayerKills", "0")))
	self:SetNWInt("SlayerRemainingKills", pdata)

	pdata = tonumber(string.Trim(self:GetPData("SlayerNeededKills", "0")))
	self:SetNWInt("SlayerKillGoal", pdata)

	self:SetNWBool("SlayerLoaded", true)
end
function Player:SaveSlayerKills()

end

-- 
SLAYER = {}
SLAYER.Bosses = {
	{
		id = "Morbus",
		description = "Formed the same way that zombies did, but was able to mutate into a being of unimaginable strength.",
		levels = {
			{
				spawn_minibosses = false,
				kills = 25,
				health = 1000,
				ent = "tw_slayer_morbus",
				player_exp = 150
			},
			{
				spawn_minibosses = false,
				kills = 50,
				health = 2500,
				ent = "tw_slayer_morbus",
				player_exp = 350
			},
			{
				spawn_minibosses = true,
				miniboss_table = {
					base_chance = 25,
					roll_max = 1000,
					weights = {
						1000
					},
					ents = {
						{
							ent = "tw_slayer_revenant",
							kills = 10,
							player_exp = 100,
						}
					}
				},
				kills = 80,
				health = 1000,
				ent = "tw_slayer_morbus"
			},
		}
	}
}

function Player:StartSlayerQuest(boss_name, level)
	if not boss_name then return end
	if not level then level = 1 end
	local quest_data
	local questdata_index
	for i = 1, #SLAYER.Bosses do
		questdata_index = i
		local boss = SLAYER.Bosses[i]
		if boss.id == boss_name then
			quest_data = boss
			break
		end
	end
	if not quest_data then
		self:ChatPrint("Invalid slayer quest data. ID=" .. boss_name .. ",LV=" .. tostring(level))
		return
	end
	--[[
	local pdata = tonumber(string.Trim(self:GetPData("SlayerKills", "0")))
	self:SetNWInt("SlayerRemainingKills", pdata)

	pdata = tonumber(string.Trim(self:GetPData("SlayerNeededKills", "0")))
	self:SetNWInt("SlayerKillGoal", pdata)
	]]

	local needed = quest_data.levels[level].kills
	self:SetPData("SlayerNeededKills", needed)
	self:SetNWInt("SlayerKillGoal", needed)

	self:SetPData("SlayerKills", "0")
	self:SetNWInt("SlayerRemainingKills", 0)

	self:SetPData("SlayerLevel", level)
	self:SetNWInt("SlayerLevel", level)

	self:SetPData("Dungeon_SlayerQuestID", questdata_index)
	self:SetNWInt("Dungeon_SlayerQuestID", questdata_index)

	self:ChatPrint(string.format("You have started a level %s %s slayer quest.", level, quest_data.id))

end

concommand.Add("doslayer", function(ply)
	ply:StartSlayerQuest("Morbus", 1)
	ply:SetStrength(1e5)
end)
concommand.Add("doslayer2", function(ply)
	ply:StartSlayerQuest("Morbus", 2)
	ply:SetStrength(1e5)
end)
concommand.Add("doslayer3", function(ply)
	ply:StartSlayerQuest("Morbus", 3)
	ply:SetStrength(1e5)
end)

-- hook.Run("HandleProperEnemyDeath", pl, self)
hook.Add("HandleProperEnemyDeath", "Slayer", function(pl, ent)
	

	if not pl then return end

	if (pl:GetNWString("Dungeon_SlayerQuestID", "") != "") then
		-- PrintMessage(3, "SLAYERQUEST")
		local needed = pl:GetNWInt("SlayerKillGoal", 0)
		local curr = pl:GetNWInt("SlayerRemainingKills", 0)
		if curr == needed and curr == 0 then
			-- no quest so wtf
			return
		end

		curr = curr + 1
		pl:SetNWInt("SlayerRemainingKills", curr)

		-- PrintMessage(3, tostring(curr) .. "/" .. tostring(needed))
		-- print("AAAAAAAAAAAAAAAAAAA")

		local boss_id = pl:GetNWInt("Dungeon_SlayerQuestID", -1)
		if boss_id < 0 then return end

		local quest_data = SLAYER.Bosses[boss_id]
		if not quest_data then return end

		local slayer_level = pl:GetNWInt("SlayerLevel", 0)
		if not slayer_level or slayer_level == 0 then return end

		local lv = quest_data.levels[slayer_level]
		local do_miniboss = lv.spawn_minibosses
		if do_miniboss and math.random() < 1/lv.miniboss_table.base_chance then
			local miniboss_chance = math.random(1, lv.miniboss_table.roll_max)
			local the_miniboss
			for i = 1, #lv.miniboss_table.weights do
				local w = lv.miniboss_table.weights[i]
				-- print(w, i, miniboss_chance)
				if w >= miniboss_chance then
					the_miniboss = i
					-- print("SET")
				end
			end

			-- PrintTable(lv.miniboss_table.ents)
			-- print(i)

			the_miniboss = lv.miniboss_table.ents[the_miniboss]
			local e = ents.Create(the_miniboss.ent)
			e:SetPos(ent:GetPos())
			-- TODO: Improve miniboss spawn. Search for an area (preferrably on top of the enemy that just died)
			e:Spawn()

			--PrintMessage(3, "nice miniboss tho")
		end

		if (curr > needed - 1) then
			-- clear slayer data as they're fighting their bosses
			pl:SetNWString("Dungeon_SlayerQuestID", "")
			pl:SetNWInt("SlayerRemainingKills", 0)
			pl:SetNWInt("SlayerKillGoal", 0)
			-- PrintMessage(3, "SPAWNED SLAYER BOSS")
		end
	end
end)