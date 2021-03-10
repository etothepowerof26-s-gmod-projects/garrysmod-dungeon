--
local L = Log("datastore")
DATASTORE = DATASTORE or {}
file.CreateDir("gdungeon_data")

function DATASTORE.FormatPlayerID(ply)
    return tostring(ply:AccountID())
end

--[[
Model(flatfile)

Store char data into DATASTORE.Cache[FormatPlayerID(ply)]
Modify it whenever
On player leave
	Save data changes
On player join
	Check data existance
	If so
		Open menu for char create / load char
	Else
		Open char create
When player creates char
	Store into cache
	Save the cache
]]
function DATASTORE.PrepareCharData(ply)
    -- DCHARID
    local char = {}
    char.id = ply:GetDCharID()
    char.class = ply:GetDClassID()
    local realclasstable = CCREATE.Classes[char.class]

    if not realclasstable then
        L("UH WHAT?", ply, realclasstable)
        error("trying to save with invalid class id")
    end

    char.basestats = realclasstable.BaseStats -- some godawful amount
    char.level = ply:GetPLevel()
    char.exp = ply:GetExperience()
    char.nexp = ply:GetNeededExp()
    -- todo: fill inventory
    char.items = {}
    char.items.equipped = {}

    return char
end

DATASTORE.PlayerDataCache = DATASTORE.PlayerDataCache or {}

hook.Add("PlayerDisconnected", "DATA_Save", function(ply)
    L("Player leave:", ply)
end)

hook.Add("PlayerFullLoad", "DATA_Load", function(ply)
    L("Player join:", ply)
end)