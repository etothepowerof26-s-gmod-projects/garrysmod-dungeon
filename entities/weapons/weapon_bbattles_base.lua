-- Custom weapon base extracted from TTT base
AddCSLuaFile()

if CLIENT then
    SWEP.DrawCrosshair = false
    SWEP.ViewModelFOV = 82
    SWEP.ViewModelFlip = true
    SWEP.CSMuzzleFlashes = true
end

SWEP.Base = "weapon_base"
SWEP.Category = "Boss Battles"
SWEP.Spawnable = false
SWEP.IsGrenade = false
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false
SWEP.Primary.Sound = Sound("Weapon_Pistol.Empty")
SWEP.Primary.Recoil = 1.5
SWEP.Primary.Damage = 1
SWEP.Primary.NumShots = 1
SWEP.Primary.Cone = 0.02
SWEP.Primary.Delay = 0.15
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.ClipMax = -1
SWEP.Primary.BulletTake = 1
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.ClipMax = -1
SWEP.HeadshotMultiplier = 2.7
SWEP.StoredAmmo = 0
SWEP.IsDropped = false
SWEP.DeploySpeed = 1.4
SWEP.PrimaryAnim = ACT_VM_PRIMARYATTACK
SWEP.ReloadAnim = ACT_VM_RELOAD
SWEP.Modifiers = {}
SWEP.Traits = {}

function SWEP:PrimaryAttack(worldsnd)
    self:SetNextSecondaryFire(CurTime() + self.Primary.Delay)
    self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
    if not self:CanPrimaryAttack() then return end
    local ProccedTraits = {}

    if next(self.Traits) ~= nil then
        for k, v in pairs(self.Traits) do
            if v:CanProc() then
                table.insert(ProccedTraits, v)
                v:Proc(self)
            end
        end
    end

    if not worldsnd then
        self:EmitSound(self.Primary.Sound, self.Primary.SoundLevel)
    elseif SERVER then
        sound.Play(self.Primary.Sound, self:GetPos(), self.Primary.SoundLevel)
    end

    self:ShootBullet(self.Primary.Damage, self.Primary.Recoil, self.Primary.NumShots, self:GetPrimaryCone())
    self:TakePrimaryAmmo(self.Primary.BulletTake)

    for k, v in pairs(ProccedTraits) do
        v:Cleanup(self)
    end

    local owner = self:GetOwner()
    if not IsValid(owner) or owner:IsNPC() or (not owner.ViewPunch) then return end
    owner:ViewPunch(Angle(util.SharedRandom(self:GetClass(), -0.2, -0.1, 0) * self.Primary.Recoil, util.SharedRandom(self:GetClass(), -0.1, 0.1, 1) * self.Primary.Recoil, 0))
end

function SWEP:DryFire(setnext)
    if CLIENT and LocalPlayer() == self:GetOwner() then
        self:EmitSound("Weapon_Pistol.Empty")
    end

    setnext(self, CurTime() + 0.2)
    self:Reload()
end

function SWEP:CanPrimaryAttack()
    if not IsValid(self:GetOwner()) then return end

    if self:Clip1() <= 0 then
        self:DryFire(self.SetNextPrimaryFire)

        return false
    end

    return true
end

function SWEP:CanSecondaryAttack()
    if not IsValid(self:GetOwner()) then return end

    if self:Clip2() <= 0 then
        self:DryFire(self.SetNextSecondaryFire)

        return false
    end

    return true
end

local function Sparklies(attacker, tr, dmginfo)
    if tr.HitWorld and tr.MatType == MAT_METAL then
        local eff = EffectData()
        eff:SetOrigin(tr.HitPos)
        eff:SetNormal(tr.HitNormal)
        util.Effect("cball_bounce", eff)
    end
end

function SWEP:ShootBullet(dmg, recoil, numbul, cone)
    local sights = self:GetIronsights()

    -- or (not self.FixedIronsights) then
    if (not sights) then
        self:SendWeaponAnim(self.PrimaryAnim)
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
    elseif (sights and not self.FixedIronsights) then
        self:SendWeaponAnim(self.PrimaryAnim)
        self:GetOwner():SetAnimation(PLAYER_ATTACK1)
        self.FixedIronsights = true
    end

    self:GetOwner():MuzzleFlash()
    numbul = numbul or 1
    cone = cone or 0.01
    local bullet = {}
    bullet.Num = numbul
    bullet.Src = self:GetOwner():GetShootPos()
    bullet.Dir = self:GetOwner():GetAimVector()
    bullet.Spread = Vector(cone, cone, 0)
    bullet.Tracer = 4
    bullet.TracerName = self.Tracer or "Tracer"
    bullet.Force = 10
    bullet.Damage = dmg
    bullet.Callback = Sparklies
    self:GetOwner():FireBullets(bullet)
    -- Owner can die after firebullets
    if (not IsValid(self:GetOwner())) or (not self:GetOwner():Alive()) or self:GetOwner():IsNPC() then return end

    if ((game.SinglePlayer() and SERVER) or ((not game.SinglePlayer()) and CLIENT and IsFirstTimePredicted())) then
        -- reduce recoil if ironsighting
        recoil = sights and (recoil * 0.6) or recoil
        local eyeang = self:GetOwner():EyeAngles()
        eyeang.pitch = eyeang.pitch - recoil
        self:GetOwner():SetEyeAngles(eyeang)
    end
end

function SWEP:GetPrimaryCone()
    local cone = self.Primary.Cone or 0.2
    -- 10% accuracy bonus when sighting

    return self:GetIronsights() and (cone * 0.85) or cone
end

function SWEP:GetHeadshotMultiplier(victim, dmginfo)
    return self.HeadshotMultiplier
end

function SWEP:IsEquipment()
    return WEPS.IsEquipment(self)
end

function SWEP:DrawWeaponSelection()
end

function SWEP:SecondaryAttack()
    if self.NoSights or (not self.IronSightsPos) then return end
    self:SetIronsights(not self:GetIronsights())
    self:SetNextSecondaryFire(CurTime() + 0.3)
end

function SWEP:Deploy()
    self:SetIronsights(false)

    return true
end

function SWEP:Reload()
    if (self:Clip1() == self.Primary.ClipSize or self:GetOwner():GetAmmoCount(self.Primary.Ammo) <= 0) then return end
    self:DefaultReload(self.ReloadAnim)
    self:SetIronsights(false)
end

function SWEP:OnRestore()
    self.NextSecondaryAttack = 0
    self:SetIronsights(false)
end

function SWEP:Ammo1()
    return IsValid(self:GetOwner()) and self:GetOwner():GetAmmoCount(self.Primary.Ammo) or false
end

-- The OnDrop() hook is useless for this as it happens AFTER the drop. OwnerChange
-- does not occur when a drop happens for some reason. Hence this thing.
function SWEP:PreDrop()
    if SERVER and IsValid(self:GetOwner()) and self.Primary.Ammo ~= "none" then
        local ammo = self:Ammo1()

        -- Do not drop ammo if we have another gun that uses this type
        for _, w in pairs(self:GetOwner():GetWeapons()) do
            if IsValid(w) and w ~= self and w:GetPrimaryAmmoType() == self:GetPrimaryAmmoType() then
                ammo = 0
            end
        end

        self.StoredAmmo = ammo

        if ammo > 0 then
            self:GetOwner():RemoveAmmo(ammo, self.Primary.Ammo)
        end
    end
end

function SWEP:DampenDrop()
    -- For some reason gmod drops guns on death at a speed of 400 units, which
    -- catapults them away from the body. Here we want people to actually be able
    -- to find a given corpse's weapon, so we override the velocity here and call
    -- this when dropping guns on death.
    local phys = self:GetPhysicsObject()

    if IsValid(phys) then
        phys:SetVelocityInstantaneous(Vector(0, 0, -75) + phys:GetVelocity() * 0.001)
        phys:AddAngleVelocity(phys:GetAngleVelocity() * -0.99)
    end
end

local SF_WEAPON_START_CONSTRAINED = 1

-- Picked up by player. Transfer of stored ammo and such.
--[[
function SWEP:Equip(newowner)
	if SERVER then
		
	end
end

function SWEP:Holster()
	if SERVER then
		
	end
end

]]
function SWEP:Equip(newowner)
    if SERVER then
        if self:IsOnFire() then
            self:Extinguish()
        end

        if self.Modifiers.mobility then
            newowner:SetRunSpeed(newowner:GetRunSpeed() * self.Modifiers.mobility)
            newowner:SetWalkSpeed(newowner:GetWalkSpeed() * self.Modifiers.mobility)
            newowner:SetCrouchedWalkSpeed(newowner:GetCrouchedWalkSpeed() * self.Modifiers.mobility)
        end

        if self:HasSpawnFlags(SF_WEAPON_START_CONSTRAINED) then
            -- If this weapon started constrained, unset that spawnflag, or the
            -- weapon will be re-constrained and float
            local flags = self:GetSpawnFlags()
            local newflags = bit.band(flags, bit.bnot(SF_WEAPON_START_CONSTRAINED))
            self:SetKeyValue("spawnflags", newflags)
        end
    end

    if SERVER and IsValid(newowner) and self.StoredAmmo > 0 and self.Primary.Ammo ~= "none" then
        local ammo = newowner:GetAmmoCount(self.Primary.Ammo)
        local given = math.min(self.StoredAmmo, self.Primary.ClipMax - ammo)
        newowner:GiveAmmo(given, self.Primary.Ammo)
        self.StoredAmmo = 0
    end
end

function SWEP:Holster()
    if SERVER then
        if self.Modifiers.mobility then
            local newowner = self:GetOwner()
            newowner:SetRunSpeed(newowner:GetRunSpeed() / self.Modifiers.mobility)
            newowner:SetWalkSpeed(newowner:GetWalkSpeed() / self.Modifiers.mobility)
            newowner:SetCrouchedWalkSpeed(newowner:GetCrouchedWalkSpeed() / self.Modifiers.mobility)
        end
    end

    return true
end

function SWEP:SetIronsights(b)
    if (b ~= self:GetIronsights()) then
        self:SetIronsightsPredicted(b)
        self:SetIronsightsTime(CurTime())

        if CLIENT then
            self:CalcViewModel()
        end
    end
end

function SWEP:GetIronsights()
    return self:GetIronsightsPredicted()
end

--- Dummy functions that will be replaced when SetupDataTables runs. These are
--- here for when that does not happen (due to e.g. stacking base classes)
function SWEP:GetIronsightsTime()
    return -1
end

function SWEP:SetIronsightsTime()
end

function SWEP:GetIronsightsPredicted()
    return false
end

function SWEP:SetIronsightsPredicted()
end

-- Set up ironsights dt bool. Weapons using their own DT vars will have to make
-- sure they call this.
function SWEP:SetupDataTables()
    self:NetworkVar("Bool", 3, "IronsightsPredicted")
    self:NetworkVar("Float", 3, "IronsightsTime")
end

function SWEP:Initialize()
    if CLIENT and self:Clip1() == -1 then
        self:SetClip1(self.Primary.DefaultClip)
    else
        self:SetIronsights(false)
    end

    self:SetDeploySpeed(self.DeploySpeed)

    -- compat for gmod update
    if self.SetHoldType then
        self:SetHoldType(self.HoldType or "pistol")
    end
end

function SWEP:CalcViewModel()
    if (not CLIENT) or (not IsFirstTimePredicted()) then return end
    self.bIron = self:GetIronsights()
    self.fIronTime = self:GetIronsightsTime()
    self.fCurrentTime = CurTime()
    self.fCurrentSysTime = SysTime()
end

-- Note that if you override Think in your SWEP, you should call
-- BaseClass.Think(self) so as not to break ironsights
function SWEP:Think()
    self:CalcViewModel()
end

function SWEP:DyingShot()
    local fired = false

    if self:GetIronsights() then
        self:SetIronsights(false)
        if self:GetNextPrimaryFire() > CurTime() then return fired end
        local owner = self:GetOwner()

        -- Owner should still be alive here
        if IsValid(owner) then
            local punch = self.Primary.Recoil or 5
            -- Punch view to disorient aim before firing dying shot
            local eyeang = owner:EyeAngles()
            eyeang.pitch = eyeang.pitch - math.Rand(-punch, punch)
            eyeang.yaw = eyeang.yaw - math.Rand(-punch, punch)
            owner:SetEyeAngles(eyeang)
            owner.dying_wep = self
            self:PrimaryAttack(true)
            fired = true
        end
    end

    return fired
end

local boss_lowered = CreateConVar("boss_ironsights_lowered", "1", FCVAR_ARCHIVE)
local host_timescale = GetConVar("host_timescale")
local LOWER_POS = Vector(0, 0, -2)
local IRONSIGHT_TIME = 0.25

function SWEP:GetViewModelPosition(pos, ang)
    if (not self.IronSightsPos) or (self.bIron == nil) then return pos, ang end
    local bIron = self.bIron
    local time = self.fCurrentTime + (SysTime() - self.fCurrentSysTime) * game.GetTimeScale() * host_timescale:GetFloat()

    if bIron then
        self.SwayScale = 0.3
        self.BobScale = 0.1
    else
        self.SwayScale = 1.0
        self.BobScale = 1.0
    end

    local fIronTime = self.fIronTime
    if (not bIron) and fIronTime < time - IRONSIGHT_TIME then return pos, ang end
    local mul = 1.0

    if fIronTime > time - IRONSIGHT_TIME then
        mul = math.Clamp((time - fIronTime) / IRONSIGHT_TIME, 0, 1)

        if not bIron then
            mul = 1 - mul
        end
    end

    local offset = self.IronSightsPos + (boss_lowered:GetBool() and LOWER_POS or vector_origin)

    if self.IronSightsAng then
        ang = ang * 1
        ang:RotateAroundAxis(ang:Right(), self.IronSightsAng.x * mul)
        ang:RotateAroundAxis(ang:Up(), self.IronSightsAng.y * mul)
        ang:RotateAroundAxis(ang:Forward(), self.IronSightsAng.z * mul)
    end

    pos = pos + offset.x * ang:Right() * mul
    pos = pos + offset.y * ang:Forward() * mul
    pos = pos + offset.z * ang:Up() * mul

    return pos, ang
end