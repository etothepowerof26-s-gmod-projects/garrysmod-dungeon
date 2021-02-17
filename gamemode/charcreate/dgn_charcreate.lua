surface.CreateFont( "TW_ClassNameFont", {
	font = "Trebuchet",
	size = 36,
	weight = 900,
	blursize = 0,
	antialias = true,
	outline = true
} )

surface.CreateFont( "TW_ClassDescFont", {
	font = "Trebuchet",
	size = 20,
	weight = 900,
	blursize = 0,
	antialias = true,
	outline = true
} )

local PANEL = {}

function PANEL:Init()
	PrintTable(CCREATE.CachedCharList)

	for i = 1, #CCREATE.CachedCharList do
		local button = self:GenerateClassButton(i)

		local x = self:GetWide() / (#CCREATE.CachedCharList + 1)
		x = x * i
		x = x - button:GetWide() / 2

		local y = self:GetTall() / 2 - button:GetTall() / 2

		button:SetPos(x, y)
	end

	-- self:Remove()
end

function PANEL:GenerateClassButton(classid)
	if not CCREATE.CachedCharList[classid] then
		error("SOME S(tuff) HAS GONE DOWN.")
		return
	end

	local class = CCREATE.CachedCharList[classid]

	local border = 5

	local tooltip = vgui.Create('DGN_Tooltip', self)
	tooltip.Character = class

	local button = vgui.Create("DGN_ClassButton", self)
	button.Tooltip = tooltip
	button.ID = classid

	if not self.Buttons then
		self.Buttons = {button}
	else
		self.Buttons[#self.Buttons + 1] = button
	end
	
	return button
end

function PANEL:DrawRest(w, h)
	surface.SetFont("Trebuchet24")
	surface.SetTextColor(255, 255, 255, 255)
	local txt = "Choose a class:"
	local tw, th = surface.GetTextSize(txt)
	surface.SetTextPos(ScrW() / 2 - tw / 2, ScrH() / 4 - th / 2)
	surface.DrawText(txt)
end

vgui.Register( "DGN_CharCreateMenu", PANEL, "DGN_BaseMenu" )