--[[

local fr = vgui.Create("DFrame")
self.Frame = fr

fr:SetTitle("")
fr:SetSize(ScrW(), ScrH())
fr:ShowCloseButton(false)
fr:MakePopup()
function fr.Paint(_s,w,h)
surface.SetDrawColor(0, 0, 0, 255)
surface.DrawRect(0, 0, w, h)

surface.SetTextColor(255, 255, 255, 255)
surface.SetFont("Trebuchet24")
local txt = "Choose a class:"
local tw, th = surface.GetTextSize(txt)
surface.SetTextPos(ScrW() / 2 - tw / 2, ScrH() / 4 - th / 2)
surface.DrawText(txt)
end
]]
local PANEL = {}

function PANEL:Init()
    self:SetTitle("")
    self:SetSize(ScrW(), ScrH())
    self:ShowCloseButton(false)
    self:MakePopup()
end

function PANEL:Paint(w, h)
    surface.SetDrawColor(0, 0, 0, 255)
    surface.DrawRect(0, 0, w, h)

    if self.DrawRest then
        self:DrawRest(w, h)
    end
end

function PANEL:DrawRest(w, h)
end

vgui.Register("DGN_BaseMenu", PANEL, "DFrame")