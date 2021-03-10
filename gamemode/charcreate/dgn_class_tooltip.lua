local PANEL = {}

function PANEL:Init()
    self:Hide()
    self:SetSize(350, 500)
end

function PANEL:Paint(w, h)
    if not self.Character then return end
    local CLASS = self.Character.Name
    local Desc = self.Character.FlavorText
    local basehp = self.Character.BaseStats.health
    local basedef = self.Character.BaseStats.defense
    local basestr = self.Character.BaseStats.strength
    local baseintel = self.Character.BaseStats.intelligence
    local ability = self.Character.Abilities
    local border = 5
    local offx, offy = border, border
    surface.SetDrawColor(60, 60, 60, 255)
    surface.DrawRect(0, 0, w, h)
    surface.SetFont("TW_ClassNameFont")

    do
        local tw, th = surface.GetTextSize(CLASS)
        surface.SetTextColor(255, 255, 255, 255)
        surface.SetTextPos(border, border)
        surface.DrawText(CLASS)
        offy = offy + th
    end

    surface.SetFont("TW_ClassDescFont")

    do
        local tw, th = surface.GetTextSize(Desc)
        surface.SetTextPos(border, offy)
        surface.DrawText(Desc)
        offy = offy + th * 2
    end

    do
        local txt = "Base Health: %s"
        txt = txt:format(basehp)
        local tw, th = surface.GetTextSize(txt)
        surface.SetTextColor(255, 60, 60, 255)
        surface.SetTextPos(border, offy)
        surface.DrawText(txt)
        offy = offy + th
    end

    do
        local txt = "Base Defense: %s"
        txt = txt:format(basedef)
        local tw, th = surface.GetTextSize(txt)
        surface.SetTextColor(60, 255, 60, 255)
        surface.SetTextPos(border, offy)
        surface.DrawText(txt)
        offy = offy + th
    end

    do
        local txt = "Base Strength: %s"
        txt = txt:format(basestr)
        local tw, th = surface.GetTextSize(txt)
        surface.SetTextColor(255, 0, 0, 255)
        surface.SetTextPos(border, offy)
        surface.DrawText(txt)
        offy = offy + th
    end

    do
        local txt = "Base Intelligence: %s"
        txt = txt:format(baseintel)
        local tw, th = surface.GetTextSize(txt)
        surface.SetTextColor(0, 127, 255, 255)
        surface.SetTextPos(border, offy)
        surface.DrawText(txt)
        offy = offy + th * 2
    end

    for k, v in pairs(ability) do
        local txt = "* %s Class Ability: %s"
        txt = txt:format(v.type == "a" and "Active" or "Passive", v.name)
        local tw, th = surface.GetTextSize(txt)
        surface.SetTextColor(255, 255, 0, 255)
        surface.SetTextPos(border, offy)
        surface.DrawText(txt)
        offy = offy + th

        if not CCREATE.CachedMarkups[CLASS] then
            CCREATE.CachedMarkups[CLASS] = {}
        end

        if not CCREATE.CachedMarkups[CLASS][k] then
            local m = markup.Parse("<font=TW_ClassDescFont><color=255,255,255>" .. v.desc, self:GetWide() - border * 2)
            CCREATE.CachedMarkups[CLASS][k] = m
        end

        local m = CCREATE.CachedMarkups[CLASS][k]
        m:Draw(offx, offy)
        offy = offy + m:GetHeight()

        do
            local txt = "Cooldown: %ss"
            txt = txt:format(v.cooldown)
            local tw, th = surface.GetTextSize(txt)
            surface.SetTextColor(60, 255, 0, 255)
            surface.SetTextPos(border, offy)
            surface.DrawText(txt)
            offy = offy + th * 2
        end
    end

    self:SetTall(offy + border)
end

vgui.Register("DGN_Tooltip", PANEL, "DPanel")