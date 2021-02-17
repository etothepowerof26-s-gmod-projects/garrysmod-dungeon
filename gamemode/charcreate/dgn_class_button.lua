local PANEL = {}

function PANEL:Init()
	self:SetImage("icon16/stop.png")
	self:SetSize(200, 200)
	self:SetTooltip("")
end

function PANEL:DoClick()
	Derma_Query(
		"Are you sure you want to choose this class?\nThis action is final. You cannot change your class later.",
		"",
		"Yeah",
		function()
			CCREATE.Frame:Close()
			CCREATE.Frame = nil
		end,
		"Nah",
		function() end
	)
end

function PANEL:Paint(w, h)
	surface.SetDrawColor(255, 255, 255, 255)

	-- TODO: get the list of other class buttons and hide them
	
	if self:IsHovered() then
		surface.SetDrawColor(0, 255, 255, 255)

		if self.Tooltip then
			local x, y = self:GetPos()
			x = x + w + 20

			self.Tooltip:SetPos(x, y)
			self.Tooltip:Show()
		end

		local parent = self:GetParent()
		if parent.Buttons then
			for i = 1, #parent.Buttons do
				local button = parent.Buttons[i]

				if i ~= self.ID then
					button:Hide()
				end
			end
		end
	else
		if self.Tooltip then
			self.Tooltip:Hide()
		end

		local parent = self:GetParent()
		if parent.Buttons then
			for i = 1, #parent.Buttons do
				local button = parent.Buttons[i]

				if i ~= self.ID then
					button:Show()
				end
			end
		end
	end

	surface.DrawRect(0, 0, w, h)
end

vgui.Register( "DGN_ClassButton", PANEL, "DImageButton" )