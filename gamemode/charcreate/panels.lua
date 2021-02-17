--
include("DGN_BaseMenu.lua")

net.Receive("DGN_CCREATE_ShowMenu", function()
	local f = vgui.Create("DGN_BaseMenu")

	function f:DrawRest(w,h)
		surface.SetTextColor(255, 255, 255, 255)
		surface.SetFont("Trebuchet24")
		local txt = "Loading... please wait"
		local tw, th = surface.GetTextSize(txt)
		surface.SetTextPos(ScrW() / 2 - tw / 2, ScrH() / 2 - ScrH() / 15 - th / 2)
		surface.DrawText(txt)
	end

	timer.Simple(5, function()
		f:Close()
	end)
end)