include("shared.lua")

-- Character creation
-- include( "dgn/cl_char.lua" )

local TIME = 0
local ROT_SPEED = 5
hook.Remove("CalcView", "DGN_SpawnNoLoad", function( ply, pos, angles, fov )
	TIME = TIME + FrameTime()

	local view = {
		origin = Vector(0, 0, 0),
		angles = Angle(0, (TIME % (360 / ROT_SPEED)) * ROT_SPEED, 0),
		fov = fov,
		drawviewer = false
	}

	return view
end)


local bar_color = Color(0,0,0,161)
local bar_xp_color = Color(31, 253, 124)
 
local frac_lerp
local show_exp_lerp
local xpbar_height = 15

hook.Add("HUDPaint", "DGN_HUD", function()

	local ply = LocalPlayer();
	if (!ply:Alive()) then return; end

	local exp, need = ply:GetExperience(), ply:GetNeededExp()

	local xpbar_width = ScrW() / 4
	
	local xpbar_x = ScrW() / 2 - xpbar_width / 2
	local xpbar_y = ScrH() / 2 -- + ScrH() / 3

	surface.SetDrawColor(bar_color:Unpack())
	surface.DrawRect(xpbar_x, xpbar_y, xpbar_width, xpbar_height)

	-- draw the experience
	local frac = exp / need -- TODO: change based on experience
	local padding = 2

	if not frac_lerp then frac_lerp = 0 end
	if not show_exp_lerp then show_exp_lerp = 0 end

	frac_lerp = Lerp(FrameTime() * 3, frac_lerp, frac)

	-- print(math.Round(frac_lerp, 1), frac)
	if (math.Round(frac_lerp, 3) != math.Round(frac, 3)) then
		show_exp_lerp = Lerp(FrameTime() * 3, show_exp_lerp, 1)
	else
		show_exp_lerp = Lerp(FrameTime() * 3, show_exp_lerp, 0)
	end

	surface.SetDrawColor(bar_xp_color)
	surface.DrawRect(xpbar_x + padding, xpbar_y + padding, (xpbar_width * frac_lerp) - padding * 2, xpbar_height - padding * 2)
 
	-- level / exp
	surface.SetFont("TargetID")
	do
		local t = "Level "
		t = t .. LocalPlayer():GetPLevel()
		local tw, th = surface.GetTextSize(t)
		surface.SetTextColor(color_white:Unpack())
		surface.SetTextPos(ScrW() / 2 - tw / 2, xpbar_y - th)
		surface.DrawText(t)
	end

	do --show_exp_lerp
		local t = "%s / %s (%s%%)"	
		t = t:format(tostring(exp), tostring(need), math.Round((exp / need) * 100, 1))
		local tw, th = surface.GetTextSize(t)
		local r,g,b,a = 255, 255, 255, 255
		a = a * (show_exp_lerp)
		surface.SetTextColor(r,g,b,a)
		surface.SetTextPos(ScrW() / 2 - tw / 2, xpbar_y + th)
		surface.DrawText(t)
	end
	
end)



net.Receive('DGN_DeathNotice', function(len)
--[[
	net.WriteString(pretty_name)
		-- was gonna write team but enemies are just 2
		net.WriteInt(t, 8)
		net.WriteString(wclass)
		net.WriteString(ply:Nick())
		net.WriteInt(ply:Team(), 8)
]]
	local pretty_name = net.ReadString()
	local enm_team = net.ReadInt(8)
	local wclass = net.ReadString()
	local nick = net.ReadString()
	local ply_team = net.ReadInt(8)

	// after the fact I realize that this is backwards.
	// just swapped the arguments for now, will change later (probably not)
	gamemode.Call( "AddDeathNotice", nick, ply_team, wclass, pretty_name, enm_team, wclass)
end)

concommand.Add( "asdadasds", function()
	local ply = Entity(1)
	gamemode.Call( "AddDeathNotice", "Anubis the Enlightened one( Lv.25 )", 69, "weapon_ar2", ply:Nick(), ply:Team() )
end )