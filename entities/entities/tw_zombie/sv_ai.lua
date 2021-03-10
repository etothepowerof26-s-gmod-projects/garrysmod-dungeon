AccessorFunc(ENT, "Enemy", "Enemy")
local d = 7500
local f = 2500

function ENT:HaveEnemy()
    local enemy = self:GetEnemy()

    if (enemy and IsValid(enemy)) then
        if (self:GetRangeTo(enemy:GetPos()) > self.LoseTargetDist) then
            return self:FindEnemy()
        elseif (enemy:IsPlayer() and not enemy:Alive()) then
            return self:FindEnemy()
        end

        return true
    else
        return self:FindEnemy()
    end
end

function ENT:FindEnemy()
    local _ents = ents.FindInSphere(self:GetPos(), self.SearchRadius)

    for k, v in ipairs(_ents) do
        if (v:IsPlayer() and v ~= self:GetEnemy() and v:Alive()) then
            self:SetEnemy(v)

            return true
        end
    end

    self:SetEnemy(nil)

    return false
end

local durs = {
    [1] = 0.88417232036591,
    [2] = 0.76662129163742,
    [3] = 0.70267575979233,
    [4] = 0.67455780506134,
    [5] = 1.2570521831512,
    [6] = 1.7414058446884,
    [7] = 0.92979592084885,
    [8] = 1.6043537855148,
    [9] = 1.4407255649567,
    [10] = 1.1410430669785,
    [11] = 1.1386847496033,
    [12] = 1.1612697839737,
    [13] = 1.0219501256943,
    [14] = 1.5796825885773
}

function ENT:ChaseEnemy(options)
    if not self:HaveEnemy() then return end
    local enemy = self:GetEnemy()
    local options = options or {}
    local path = Path("Follow")
    path:SetMinLookAheadDistance(options.lookahead or 300)
    path:SetGoalTolerance(options.tolerance or 20)
    path:Compute(self, enemy:GetPos())
    if (not path:IsValid()) then return "failed" end

    while (path:IsValid()) do
        local en = enemy
        if not IsValid(en) then break end

        if (path:GetAge() > 0.25) then
            path:Compute(self, en:GetPos())
        end

        path:Update(self)

        if (self.loco:IsStuck()) then
            self:HandleStuck()

            return "stuck"
        end

        if not self.LastSound then
            self.LastSound = SysTime()
            self.NextSound = math.random(1, 14)
            -- durs[self.NextSound]
            self:EmitSound('npc/zombie/zombie_voice_idle' .. self.NextSound .. '.wav')
        end

        if SysTime() > self.LastSound + durs[self.NextSound] + math.random(55, 550) / 100 then
            self.LastSound = SysTime()
            self.NextSound = math.random(1, 14)
            self:EmitSound('npc/zombie/zombie_voice_idle' .. self.NextSound .. '.wav')
        end

        local lastSoundDur = .25

        --if self.Mods.berserk then
        --	lastSoundDur = lastSoundDur / 3
        --end
        if en:GetPos():DistToSqr(self:GetPos()) < d and SysTime() > self.LastSound + lastSoundDur then
            self:DoAttack()
            break
        end

        coroutine.yield()
    end

    return "ok"
end

function ENT:DoAttack()
    self.attacking = true
    local en = self:GetEnemy()
    local ang = (self:EyePos() - en:GetPos()):Angle()
    --print(ang)
    local name
    local speed = 1

    --if self.Mods.berserk then
    --	speed = speed * 3
    --end
    local anims = {"B", "D", "E", "F"}

    local len = self:SetSequence("attack" .. anims[math.random(1, #anims)])
    self:ResetSequenceInfo()
    self:SetCycle(0)
    self:SetPlaybackRate(speed)
    self:EmitSound('npc/zombie/zo_attack' .. math.random(1, 2) .. '.wav')
    -- divided by 2 so its still the correct length
    coroutine.wait((len / speed) / 2)

    if en:GetPos():DistToSqr(self:GetPos()) < d then
        local d = DamageInfo()
        d:SetDamage(self:GetSpecial() and 55 or 15)
        d:SetDamageForce(en:GetForward())
        d:SetDamagePosition(en:GetPos() + Vector(0, 0, en:OBBCenter().z) + en:GetForward() * 5)
        d:SetDamageType(DMG_SLASH)
        d:SetAttacker(self)
        d:SetInflictor(self)
        en:TakeDamageInfo(d)
        self:EmitSound('npc/zombie/claw_strike' .. math.random(1, 3) .. '.wav')
    end

    coroutine.wait((len / speed) / 2)
    coroutine.wait(.2 / speed)
    self.attacking = nil
end

function ENT:Think()
    local en = self:GetEnemy()

    if self.attacking and IsValid(en) and (en.Alive and en:Alive() or (en:Health() > 0)) then
        if not self.lookat then
            self.lookat = (en:GetPos() - self:GetPos()):Angle()
            self.lookat.p = 0
        end

        self:SetAngles(LerpAngle(.2, self:GetAngles(), self.lookat))
    else
        self.lookat = nil
    end
end

function ENT:RunBehaviour()
    while true do
        self:StartActivity(ACT_WALK)
        self.loco:SetDesiredSpeed(120)
        self:ChaseEnemy()
        coroutine.yield()
    end
end