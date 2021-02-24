include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Think()
	--if (!self.WantedPos) then return end

	if not self.Matrixa then
		self.Matrixa = Matrix()
		self.Matrixa:SetAngles(self:GetAngles())
	end

	self:DisableMatrix("RenderMultiply")
	self.Matrixa:Rotate(Angle(0, 0, FrameTime() * 850))
	self:EnableMatrix("RenderMultiply", self.Matrixa)

	--local a = self:GetAngles()
	--a.y = (a.y + 35) % 360
	--self:SetAngles(a)
	--self:SetPos(LerpVector(0.1, self:GetPos(), self.WantedPos))
end