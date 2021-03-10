--
include("DGN_Class_Button.lua")
include("DGN_Class_Tooltip.lua")
include("DGN_BaseMenu.lua")
include("DGN_CharCreate.lua")
CCREATE.CachedCharList = {}
CCREATE.AmntChars = 0
CCREATE.Frame = nil

net.Receive("DGN_CCREATE_Request", function()
    CCREATE.AmntChars = net.ReadUInt(8)
end)

net.Receive("DGN_CCREATE_RequestCharacterListOption", function(len)
    print("ShowList", len)
    local class = {}
    class.Name = net.ReadString()
    class.FlavorText = net.ReadString()
    class.Icon = net.ReadString()

    class.BaseStats = {
        health = net.ReadUInt(16),
        defense = net.ReadUInt(16),
        strength = net.ReadUInt(16),
        intelligence = net.ReadUInt(16)
    }

    class.Abilities = {}
    local abilityamnt = net.ReadUInt(4)

    if abilityamnt > 0 then
        for i = 1, abilityamnt do
            local ability = {}
            ability.name = net.ReadString()
            ability.desc = net.ReadString()
            ability.type = net.ReadString()
            ability.cooldown = net.ReadUInt(12)
            ability.reqlevel = net.ReadUInt(8)
            class.Abilities[i] = ability
        end
    end

    CCREATE.CachedCharList[#CCREATE.CachedCharList + 1] = class

    if #CCREATE.CachedCharList == CCREATE.AmntChars then
        CCREATE.Frame:Close()
        CCREATE.Frame = nil
        -- idfk why we're clearing the frame index, it's literally getting recreated the next instant
        LocalPlayer():ChatPrint("Received!")
        CCREATE.Frame = vgui.Create("DGN_CharCreateMenu")
        --local f = CCREATE.Frame
        --timer.Simple(5, function()
        --	f:Close()
        --	CCREATE.Frame=nil
        --end)
    end
end)

net.Receive("DGN_CCREATE_ShowMenu", function()
    local f = vgui.Create("DGN_BaseMenu")
    CCREATE.Frame = f

    function f:DrawRest(w, h)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetFont("Trebuchet24")

        do
            local txt = "Loading... please wait"
            local tw, th = surface.GetTextSize(txt)
            surface.SetTextPos(ScrW() / 2 - tw / 2, ScrH() / 2 - ScrH() / 15 - th / 2)
            surface.DrawText(txt)
        end

        do
            local txt = "Got %s characters"
            txt = txt:format(CCREATE.AmntChars or 0)
            local tw, th = surface.GetTextSize(txt)
            surface.SetTextPos(ScrW() / 2 - tw / 2, ScrH() / 2 + ScrH() / 15 - th / 2)
            surface.DrawText(txt)
        end
    end
end)
--timer.Simple(5, function()
--	f:Close()
--	CCREATE.Frame=nil
--end)