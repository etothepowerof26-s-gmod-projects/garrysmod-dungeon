print("ayoaa")


local CCREATE = {}




if CLIENT then

	CCREATE.CachedMarkups = {}

	local FONT = "Trebuchet"
	
	surface.CreateFont( "TW_ClassNameFont", {
		font = FONT,
		size = 36,
		weight = 900,
		blursize = 0,
		antialias = true,
		outline = true
	} )
	
	surface.CreateFont( "TW_ClassDescFont", {
		font = FONT,
		size = 20,
		weight = 900,
		blursize = 0,
		antialias = true,
		outline = true
	} )

	function CCREATE:CreateClassButton()
		if not (self.Frame) then
			return
		end

		local CLASS = "Warrior"
		local Desc = "Highly valued swordsman."
		local basehp = 115
		local basedef = 50
		local basestr = 20
		local baseintel = 100
		local ability = {
			["Dash"] = {
				desc = "Dash towards an opponent, sending you flying towards them and dealing damage upon impact. Also gives additional strength upon dashing.\n<color=255,0,0>Requires level 5 to use.",
				type = "a",
				cooldown = 60 --seconds
			},
			["Shredder"] = {
				desc = "For a duration, you shred a portion of an enemy's health, giving back <color=255,0,0>10%</color><color=255,255,255> of the damage as health.\n<color=255,0,0>Requires level 15 to use.",
				type = "a",
				cooldown = 15
			}
		}


		local a = vgui.Create("DPanel", self.Frame) -- this is like a tooltip
		a:Hide()
		a:SetSize(350, 500)
		function a:Paint(w, h)
			-- calculate total width

			local border = 5
			local offx = border
			local offy = border

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

			for k,v in pairs(ability) do
				do
					local txt = "* %s Class Ability: %s"
					txt = txt:format(v.type=="a" and "Active" or "Passive",k)
					local tw, th = surface.GetTextSize(txt)
					surface.SetTextColor(255, 255, 0, 255)
					surface.SetTextPos(border, offy)
					surface.DrawText(txt)
					offy = offy + th
				end

				do
					if not CCREATE.CachedMarkups[CLASS] then
						CCREATE.CachedMarkups[CLASS] = {}
					end
					if not CCREATE.CachedMarkups[CLASS][k] then
						local m = markup.Parse("<font=TW_ClassDescFont><color=255,255,255>" .. v.desc, self:GetWide() - border*2)
						CCREATE.CachedMarkups[CLASS][k] = m
					end
					local m = CCREATE.CachedMarkups[CLASS][k]
					m:Draw(offx,offy)
					--local txt = "%s"
					--txt = txt:format(k)
					--local tw, th = surface.GetTextSize(txt)
					--surface.SetTextColor(255, 255, 0, 255)
					--surface.SetTextPos(border, offy)
					--surface.DrawText(txt)
					offy = offy + m:GetHeight()
				end

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


		local b = vgui.Create("DImageButton", self.Frame)
		b:SetImage("icon16/stop.png")
		b:SetSize(200, 200)
		b:SetTooltip("")
		function b:DoClick()
			Derma_Query(
				"Are you sure you want to choose this class?\nThis action is final. You cannot change your class later.",
				"",
				"Yeah",
				function()
					self:GetParent():Close()
				end,
				"Nah",
				function() end
			)
		end
		function b:Paint(w, h)
			surface.SetDrawColor(255, 255, 255, 255)
			if self:IsHovered() then
				surface.SetDrawColor(0, 255, 255, 255)
				local np = {self:GetPos()}
				np[1] = np[1] + w + 20
				a:SetPos(unpack(np))
				a:Show()
				if CCREATE.coolbuttons then
					for i = 1, #CCREATE.coolbuttons do
						if self.ID and self.ID == i then
							continue 
						else
							CCREATE.coolbuttons[i]:Hide()
						end
					end
				end
			else
				a:Hide()
				if CCREATE.coolbuttons then
					for i = 1, #CCREATE.coolbuttons do
						if self.ID and self.ID == i then
							continue 
						else
							CCREATE.coolbuttons[i]:Show()
						end
					end
				end
			end
			surface.DrawRect(0, 0, w, h)
		end
		
		return b
	end

	function CCREATE:Init()
		if not (self.Frame) then
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
			
			self.coolbuttons = {}

			local button1 = self:CreateClassButton()
			print(button1)
			button1:SetPos(fr:GetWide() / 4 - button1:GetWide() / 2, fr:GetTall() / 2 - button1:GetTall() / 2)
			self.coolbuttons[#self.coolbuttons + 1] = button1
			button1.ID = #self.coolbuttons
			local button1 = self:CreateClassButton()
			print(button1)
			button1:SetPos(fr:GetWide() / 2 - button1:GetWide() / 2, fr:GetTall() / 2 - button1:GetTall() / 2)
			self.coolbuttons[#self.coolbuttons + 1] = button1
			button1.ID = #self.coolbuttons
			local button1 = self:CreateClassButton()
			print(button1)
			button1:SetPos(fr:GetWide() / 2 + fr:GetWide() / 4 - button1:GetWide() / 2, fr:GetTall() / 2 - button1:GetTall() / 2)
			self.coolbuttons[#self.coolbuttons + 1] = button1
			button1.ID = #self.coolbuttons
			


			timer.Simple(5, function()
				--fr:Close()
			end)


		end
	end

	concommand.Add("testccreate", function()
		CCREATE:Init()
	end)

end



 



-- DUNGEON.CharacterCreate = CCREATE