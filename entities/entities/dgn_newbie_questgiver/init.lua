AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
include( "shared.lua" )

local pos = Vector(803.30023193359, -1123.6060791016, -143.96875)
local ang = Angle(-1.9900013208389, 135.69975280762, 0)


function ENT:PostInit()
	self:SetPos(pos)
	self:SetAngles(ang)
end