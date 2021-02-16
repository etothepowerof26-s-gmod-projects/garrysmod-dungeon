// https://github.com/CapsAdmin/rpg_hitmarks/blob/master/lua/autorun/hitmark.lua

if CLIENT then
	local white = surface.GetTextureID("vgui/white")

	function surface.DrawLineEx(x1,y1, x2,y2, w, skip_tex)
		w = w or 1
		if not skip_tex then surface.SetTexture(white) end
		
		local dx,dy = x1-x2, y1-y2
		local ang = math.atan2(dx, dy)
		local dst = math.sqrt((dx * dx) + (dy * dy))
		
		x1 = x1 - dx * 0.5
		y1 = y1 - dy * 0.5
		
		surface.DrawTexturedRectRotated(x1, y1, w, dst, math.deg(ang))
	end

	function surface.DrawCircleEx(x, y, rad, color, res, ...)
		res = res or 16
			
		surface.SetDrawColor(color)
		
		local spacing = (res/rad) - 0.1
		
		for i = 0, res do		
			local i1 = ((i+0) / res) * math.pi * 2
			local i2 = ((i+1 + spacing) / res) * math.pi * 2
			
			surface.DrawLineEx(
				x + math.sin(i1) * rad, 
				y + math.cos(i1) * rad, 
				
				x + math.sin(i2) * rad, 
				y + math.cos(i2) * rad, 
				...
			)
		end
	end

	local font = "hitmark"
	local font_blur = font .. "_blur"

	surface.CreateFont(
		font,
		{
			font = "Gabriola",
			size = 100,
			weight = 30,
			antialias = true,
		}
	)

	surface.CreateFont(
		font_blur,
		{
			font = "Gabriola",
			size = 100,
			weight = 30,
			antialias = true,
			blursize = 2,
		}
	)

	local font_crit_blur = font .. "_crit_blur"

	surface.CreateFont(
		font_crit_blur,
		{
			font = "Gabriola",
			size = 100,
			weight = 30,
			antialias = true,
			additive = true,
			blursize = 4,
		}
	)

	local font_name = "hitmark_name"
	local font_name_blur = font .. "_name_blur"

	surface.CreateFont(
		font_name,
		{
			font = "Candara",
			size = 20,
			weight = 30,
			antialias = true,
		}
	)

	surface.CreateFont(
		font_name_blur,
		{
			font = "Candara",
			size = 20,
			weight = 30,
			antialias = true,
			blursize = 2,
		}
	)

	local line_mat = Material("particle/Particle_Glow_04")

	local line_width = 8
	local line_height = -31
	local max_bounce = 2
	local bounce_plane_height = 5

	local life_time = 3
	local hitmarks = {}
	local height_offset = 0

	local infobars = {}

	local health_mat = Material("gui/gradient")
	
	hook.Add("HUDPaint", "hitmarks", function()
		if hook.Call("HideHitmarks") then
			return
		end

		if table.Count(hitmarks) > 0 then
			local d = FrameTime()

			surface.SetFont(font)

			for key, data in pairs(hitmarks) do
				local t = RealTime() + data.offset

				local fraction =  (data.life - t) / life_time

				if fraction <= 0 then
					hitmarks[key] = nil
					continue
				end

				local pos = data.real_pos

				if data.ent:IsValid() then
					pos = data.ent:LocalToWorld(data.real_pos)
				end

				local fade = math.Clamp(fraction ^ 0.25, 0, 1)
				-- print(fraction,)

				if data.bounced < max_bounce then
					data.vel = data.vel + Vector(0,0,-0.25)
					data.vel = data.vel * 0.99
				else
					data.vel = data.vel * 0.85
				end

				if data.pos.z < -bounce_plane_height and data.bounced < max_bounce then
					data.vel.z = -data.vel.z * 0.5
					data.pos.z = -bounce_plane_height

					data.bounced = data.bounced + 1

					if data.bounced == max_bounce then
						data.vel.z = data.vel.z * -1
					end
				end

				data.pos = data.pos + data.vel * d * 25

				pos = (pos + data.pos + Vector(0, 0, bounce_plane_height)):ToScreen()

				local txt = math.Round(Lerp(math.Clamp(fraction-0.95, 0, 1), data.dmg, 0))

				if data.deadbeef then
					txt = string.format("%X", txt)
				end

				if data.dmg == 0 then
					txt = "MISS"
				elseif data.dmg > 0 then
					txt = "+" .. txt
				end

				if pos.visible then

					local x = pos.x + data.pos.x
					local y = pos.y + data.pos.y

					local w, h = surface.GetTextSize(txt)
					local hoffset = data.height_offset * -h * 0.5

					if data.dmg == 0 then
						surface.SetDrawColor(255, 255, 255, 255 * fade)
					elseif data.rec then
						surface.SetDrawColor(100, 255, 100, 255 * fade)
					else
						surface.SetDrawColor(255, 100, 100, 255 * fade)
					end

					surface.SetMaterial(line_mat)

					surface.DrawLineEx(
						x - w,
						hoffset + y + h + line_height,

						x - w + w * 3,
						hoffset + y + h + line_height,
						line_width,
						true
					)

					if data.crt then
						for i = 1, 5 do
							surface.SetTextPos(x, hoffset + y)
							local c = HSVToColor((t*500)%360, 0.75, 1)
							surface.SetTextColor(c.r, c.g, c.b, 255 * fade)
							surface.SetFont(font_crit_blur)
							surface.DrawText(txt)
						end
					else
						for i = 1, 5 do
							surface.SetTextPos(x, hoffset + y)

							surface.SetTextColor(0, 0, 0, 255 * fade)
							surface.SetFont(font_blur)
							surface.DrawText(txt)
						end
					end

					surface.SetTextPos(x, hoffset + y)

					surface.SetTextColor(255, 255, 255, 255 * fade)
					surface.SetFont(font)
					surface.DrawText(txt)
				end
			end
		end
		
		for key, data in pairs(infobars) do
			local ent = data.ent

			if ent:IsValid() then
				local t = RealTime()
				local fraction = (data.time - t) / life_time * 2

				local name

				if ent:IsPlayer() then
					name = ent:Nick()
				else
					name = language.GetPhrase(ent:GetClass())
					name = name .. " Lv." .. (ent.GetMobLevel and ent:GetMobLevel() or 1)
				end

				

				local pos = (ent:EyePos() + Vector(0, 0, 16)):ToScreen()

				if pos.visible then
					local cur = ent.hm_cur_health
					local max = ent.hm_max_health

					if max == 0 or cur > max then
						max = 100
						cur = 100
					end

					local fade = 1-- math.Clamp(fraction ^ 0.25, 0, 1)
					if fraction < 2 then
						fade = fraction / 2
					end

					if (ent:Health() <= 0) then
						cur = 0
					end


					surface.SetFont(font_name)

					local w, h = surface.GetTextSize(name)
					
					surface.SetMaterial(health_mat	)
					
					surface.SetDrawColor(255, 255, 255, 255 * fade)
					surface.DrawLineEx(
						pos.x - 5 - 128 - 2,
						pos.y + h - 2,

						pos.x + 256 - 5 - 128 + 2,
						pos.y + h - 2,

						6 + 3,
						true
					)
					
					surface.SetDrawColor(255, 0, 0, 255 * fade)
					surface.DrawLineEx(
						pos.x - 5 - 128,
						pos.y + h - 2,

						pos.x + 256 - 5 - 128,
						pos.y + h - 2,

						6,
						true
					)

					surface.SetDrawColor(0, 255, 0, 255 * fade)
					surface.DrawLineEx(
						pos.x - 5 - 128,
						pos.y + h - 2,

						(pos.x + (256 * math.Clamp(cur / max, 0, 1))) - 5 - 128,
						pos.y + h - 2,

						6,
						true
					)

					surface.SetTextColor(0, 0, 0, 255 * fade)

					for i = 1, 15 do
						surface.SetTextPos(pos.x - 128, pos.y)
						surface.SetFont(font_name_blur)
						surface.DrawText(name)
					end

					surface.SetTextColor(255, 255, 255, 255 * fade)
					surface.SetTextPos(pos.x - 128, pos.y)
					surface.SetFont(font_name)
					surface.DrawText(name)
				end

				if fraction <= 0 then
					infobars[key] = nil
				end
			end
		end
	end)

	function Hitmark(ent, dmg, pos, crt, deadbeef)
		ent = ent or NULL
		dmg = dmg or 0
		pos = pos or ent:EyePos()

		if ent:IsValid() then
			pos = ent:WorldToLocal(pos)
		end

		local rec = dmg > 0

		local vel = VectorRand()
		local offset = math.random() * 10

		height_offset = (height_offset + 1)%5

		table.insert(
			hitmarks,
			{
				ent = ent,
				real_pos = pos,
				dmg = dmg,
				crt = crt,

				life = RealTime() + offset + life_time + math.random(),
				dir = vel,
				pos = Vector(),
				vel = vel,
				rec = rec,

				deadbeef = deadbeef,
				offset = offset,
				height_offset = height_offset,

				bounced = 0,
			}
		)
		
		for k,v in pairs(infobars) do
			if v.ent == ent then	
				infobars[k] = nil
			end
		end
		
		table.insert(infobars, {ent = ent, time = RealTime() + life_time * 2})
	end

	net.Receive("hitmark", function()
		local ent = net.ReadEntity()
		local dmg = math.Round(net.ReadFloat())
		local pos = net.ReadVector()
		local crt = net.ReadBit() == 1
		local cur = math.Round(net.ReadFloat())
		local max = math.Round(net.ReadFloat())

		ent.hm_cur_health = cur
		ent.hm_max_health = max

		Hitmark(ent, dmg, pos, crt)
	end)
end

if SERVER then
	function Hitmark(ent, dmg, pos, crt, filter)
		ent = ent or NULL
		dmg = dmg or 0
		pos = pos or ent:EyePos()
		filter = filter or player.GetAll()

		net.Start("hitmark")
			net.WriteEntity(ent)
			net.WriteFloat(dmg)
			net.WriteVector(pos)
			net.WriteBit(crt)
			net.WriteFloat(ent.ACF and ent.ACF.Health or ent.ee_cur_hp or ent:Health())
			net.WriteFloat(ent.ACF and ent.ACF.MaxHealth or ent.ee_max_hp or ent:GetMaxHealth())
		net.Send(filter)
	end

	util.AddNetworkString("hitmark")

	hook.Remove("EntityTakeDamage", "hitmarker")
	--[[hook.Add("EntityTakeDamage", "hitmarker", function(ent, dmg)
		if not (dmg:GetAttacker():IsNPC() or dmg:GetAttacker():IsPlayer()) then return end

		local filter = {}
		for k,v in pairs(player.GetAll()) do
			if v ~= ent and v:GetPos():Distance(ent:GetPos()) < 1500 * (ent:GetModelScale() or 1) then
				table.insert(filter, v)
			end
		end

		local last_health = ent:Health()
		local health = -dmg:GetDamage()
		local pos = dmg:GetDamagePosition()
		
		if ent.ee_cur_hp then
			last_health = ent.ee_cur_hp
		end
		
		local crit = health < -100
		
		if math.random() > 0.9 then
			crit = true
			health = health * 3
			dmg:ScaleDamage(3)
		end

		timer.Simple(0.1, function()
			if ent:IsValid() then
				if ent.ee_cur_hp then
					health = -(last_health - ent.ee_cur_hp)
				elseif last_health == ent:Health() then 
					return
				end
				
				Hitmark(ent, health, pos, crit, filter)
			end
		end)
	end)]]

	hook.Add("Think", "hitmarker", function()
		for _, ply in pairs(player.GetAll()) do
			if ply.hm_last_health ~= ply:Health() then
				local diff = ply:Health() - (ply.hm_last_health or 0)
				if diff > 0 then
					Hitmark(ply, diff)
				end
				ply.hm_last_health = ply:Health()
			end
		end
	end)
end
