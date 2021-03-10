﻿AddCSLuaFile()
SWEP.HoldType = "ar2"

if CLIENT then
    SWEP.PrintName = "M16"
    SWEP.Slot = 2
    SWEP.ViewModelFlip = false
    SWEP.ViewModelFOV = 64
end

SWEP.Base = "weapon_bbattles_base"
SWEP.Primary.Delay = 0.2
SWEP.Primary.Recoil = 1.6
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Damage = 10
SWEP.Primary.Cone = 0.018
SWEP.Primary.ClipSize = 20
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 20
SWEP.Primary.Sound = Sound("Weapon_M4A1.Single")
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/cstrike/c_rif_m4a1.mdl"
SWEP.WorldModel = "models/weapons/w_rif_m4a1.mdl"
SWEP.IronSightsPos = Vector(-7.85, -9.2, 2.55)
SWEP.IronSightsAng = Vector(2, -3, -5)

function SWEP:SetZoom(state)
    if not (IsValid(self:GetOwner()) and self:GetOwner():IsPlayer()) then return end

    if state then
        self:GetOwner():SetFOV(55, 0.5)
    else
        self:GetOwner():SetFOV(0, 0.2)
    end
end

-- Add some zoom to ironsights for this gun
--[[function SWEP:SecondaryAttack()
   if not self.IronSightsPos then return end
   if self:GetNextSecondaryFire() > CurTime() then return end

   local bIronsights = not self:GetIronsights()

   self:SetIronsights( bIronsights )

   self:SetZoom( bIronsights )

   self:SetNextSecondaryFire( CurTime() + 0.3 )
end]]
function SWEP:PreDrop()
    self:SetZoom(false)
    self:SetIronsights(false)

    return self.BaseClass.PreDrop(self)
end

function SWEP:Reload()
    if (self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) then return end
    self:DefaultReload(ACT_VM_RELOAD)
    self:SetIronsights(false)
    self:SetZoom(false)
end

function SWEP:Holster()
    self:SetIronsights(false)
    self:SetZoom(false)

    return true
end