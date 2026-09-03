-- ============================================================
--  SRC HUB Vehicle Fly With Horn (Made By XThrlen)
--
--  Horn HOLD   = UP | Horn Stop = HOVER
--  Speed       = Hover Fly | L/R = turn
--  Back tap    = Back | Back HOLD = Slowly LAND
-- ============================================================

local TXtime_ticker = require('common.time_ticker')

local CFG = {
    RiseSpeed    = 650,
    FallSpeed    = 420,
    FlyForwardMax = 2600,
    FlyBackMax   = 1400,
    FlyAccel     = 4500,
    Damp         = 2.0,
    TurnRate     = 110,
    TapBackTime  = 0.25,
    LightMass    = 150,    -- Vehicle Weight
    ServerSync   = true,   -- server impulse sync ON
    SyncInterval = 0.05,
}

_G.XThrlen_Config  = CFG
_G.XThrlen_Enabled = true

local S = { veh=nil, lastVeh=nil, flying=false,
            vx=0, vy=0, downT=0, lockZ=nil,
            lastLandZ=nil, landT=0, syncT=0,
            savedMass=nil, mc=nil }

local function GetMyVehicle()
    local ok, veh = pcall(function()
        if not slua_GameFrontendHUD then return nil end
        local pc = slua_GameFrontendHUD:GetPlayerController()
        if not pc or not slua.isValid(pc) then return nil end
        local ch = pc.GetPlayerCharacterSafety and pc:GetPlayerCharacterSafety() or nil
        if not ch or not slua.isValid(ch) then return nil end
        return ch:GetCurrentVehicle()
    end)
    if ok and veh and slua.isValid(veh) then return veh end
    return nil
end

local function ReadInputs(veh)
    local inp = { down=false, fwd=false, steer=0 }
    pcall(function()
        local mc = veh:GetMovementComponent()
        if not mc or not slua.isValid(mc) then return end
        local rb = tonumber(mc.RawBrakeInput) or 0
        local bi = tonumber(mc.BrakeInput) or 0
        local rt = tonumber(mc.RawThrottleInput) or 0
        local ti = tonumber(mc.ThrottleInput) or 0
        local st = tonumber(mc.RawSteeringInput) or 0
        if rb > 0.05 or bi > 0.05 or rt < -0.05 or ti < -0.05 then inp.down = true end
        if rt > 0.05 or ti > 0.05 then inp.fwd = true end
        if st > 0.05 or st < -0.05 then inp.steer = st end
        if not (inp.down or inp.fwd or inp.steer ~= 0) then
            local rs = mc.ReplicatedState
            if rs then
                if (tonumber(rs.BrakeInput) or 0) > 0.05 then inp.down = true end
                if (tonumber(rs.ThrottleInput) or 0) > 0.05 then inp.fwd = true end
                local s2 = tonumber(rs.SteeringInput) or 0
                if s2 > 0.05 or s2 < -0.05 then inp.steer = s2 end
            end
        end
    end)
    return inp
end

-- WEOW SRC HUB
local SETV_MODE = 0
local function SetVel(rc, vec)
    if SETV_MODE ~= 2 then
        if pcall(function() rc:SetAllPhysicsLinearVelocity(vec, false) end) then
            SETV_MODE = 1
            return true
        end
        SETV_MODE = 2
    end
    local ok = pcall(function() rc:SetPhysicsLinearVelocity(vec, false, "None") end)
    if not ok then
        ok = pcall(function() rc:SetPhysicsLinearVelocity(vec, false) end)
    end
    return ok
end

local ANG_MODE = 0
local function SetAngVel(rc, vx, vy, vz)
    if ANG_MODE ~= 2 then
        if pcall(function() rc:SetPhysicsAngularVelocityInDegrees(FVector(vx, vy, vz), false, "None") end) then
            ANG_MODE = 1
            return true
        end
        ANG_MODE = 2
    end
    return pcall(function() rc:SetPhysicsAngularVelocity(FVector(vx, vy, vz), false, "None") end)
end

local function SaveAndLighten(veh)
    pcall(function()
        local mc = veh:GetMovementComponent()
        if mc and slua.isValid(mc) then
            S.mc = mc
            local okM, mval = pcall(function() return tonumber(mc.Mass) end)
            S.savedMass = (okM and mval) or nil
            pcall(function() mc.Mass = CFG.LightMass end)
        end
    end)
end

local function RestoreMass()
    pcall(function()
        if S.mc and slua.isValid(S.mc) and S.savedMass then
            S.mc.Mass = S.savedMass
        end
    end)
    S.mc, S.savedMass = nil, nil
end

local function EnterFly()
    SaveAndLighten(S.veh)
    S.flying, S.vx, S.vy = true, 0, 0
    S.downT, S.lockZ, S.landT, S.lastLandZ = 0, nil, 0, nil
    print('[SRCHUB] FLY ON')
end

local function ExitFly(reason)
    RestoreMass()
    S.flying, S.vx, S.vy = false, 0, 0
    S.downT, S.lockZ, S.landT, S.lastLandZ = 0, nil, 0, nil
    print('[SRCHUB] ' .. reason)
end

local function Tick(dt)
    if not _G.XThrlen_Enabled then return end
    dt = math.min(tonumber(dt) or 0.033, 0.1)

    local veh = GetMyVehicle()
    if veh ~= S.veh then
        if S.flying then ExitFly('EXIT VEHICLE') end
        S.veh = veh
        if veh and not S.flying then
            print('[SRCHUB] Test24 | Horn=UP | Speed=HoverFly | L/R=TURN | Back tap=Back | Back hold=LAND')
        end
    end
    S.lastVeh = veh
    if not veh then return end

    local horn = false
    pcall(function() horn = (veh.bIsUsingHorn == true) end)
    local inp = ReadInputs(veh)

    if horn and not S.flying then
        EnterFly()
    end
    if not S.flying then return end

    if inp.down then S.downT = S.downT + dt else S.downT = 0 end
    local descending = inp.down and (S.downT >= CFG.TapBackTime)
    local backing    = inp.down and not descending

    local okL, loc = pcall(veh.K2_GetActorLocation, veh)
    if not okL or not loc then return end

    -- vertical target
    local vz = 0
    if horn then
        vz = CFG.RiseSpeed
        S.lockZ = nil
    elseif descending then
        vz = -CFG.FallSpeed
        S.lockZ = nil
    else
        if S.lockZ == nil then S.lockZ = loc.Z end
        vz = (S.lockZ - loc.Z) * 3.5
        vz = math.max(math.min(vz, 350), -300)
    end

    -- horizontal integrate
    local fx, fy = 0, 0
    pcall(function()
        local f = veh:GetActorForwardVector()
        fx, fy = f.X, f.Y
    end)
    local flen = math.sqrt(fx * fx + fy * fy)
    if flen > 0.001 then fx, fy = fx / flen, fy / flen end

    if inp.fwd then
        S.vx = S.vx + fx * CFG.FlyAccel * dt
        S.vy = S.vy + fy * CFG.FlyAccel * dt
    elseif backing then
        S.vx = S.vx - fx * CFG.FlyAccel * dt
        S.vy = S.vy - fy * CFG.FlyAccel * dt
    else
        local d = math.max(0, 1 - CFG.Damp * dt)
        S.vx, S.vy = S.vx * d, S.vy * d
    end
    local hs = math.sqrt(S.vx * S.vx + S.vy * S.vy)
    local hmax = backing and CFG.FlyBackMax or CFG.FlyForwardMax
    if hs > hmax then
        local sc = hmax / hs
        S.vx, S.vy = S.vx * sc, S.vy * sc
    end

    -- apply velocity locally
    local vec = FVector(S.vx, S.vy, vz)
    pcall(function()
        local rc = veh:K2_GetRootComponent()
        if rc and slua.isValid(rc) then SetVel(rc, vec) end
    end)
    pcall(function()
        local m = veh.Mesh
        if m and slua.isValid(m) then SetVel(m, vec) end
    end)

    -- steering: yaw turn + tumble stop
    pcall(function()
        local rc = veh:K2_GetRootComponent()
        if rc and slua.isValid(rc) then
            SetAngVel(rc, 0, 0, -(inp.steer or 0) * CFG.TurnRate)
        end
    end)

    -- SERVER SYNC
    S.syncT = S.syncT + dt
    if CFG.ServerSync and S.syncT >= CFG.SyncInterval then
        S.syncT = 0
        pcall(veh.ServerImpulseVehicle, veh, FVector(S.vx, S.vy, vz), false)
    end

    -- landing detect
    if descending then
        if S.lastLandZ and math.abs(loc.Z - S.lastLandZ) < 2 then
            S.landT = S.landT + dt
        else
            S.landT = 0
        end
        S.lastLandZ = loc.Z
        if S.landT >= 0.35 then
            ExitFly('LANDED')
            return
        end
    else
        S.landT, S.lastLandZ = 0, nil
    end
end

if TXtime_ticker then
    _G.XThrlen_TimerIndex = TXtime_ticker.AddTimerLoop(0, Tick, -1, 0)
    print('[SRCHUB] Vehicle-Fly loaded!')
else
    print('[SRCHUB] ERROR: common.time_ticker nahi mila')
end

function _G.XThrlen_Unload()
    _G.XThrlen_Enabled = false
    RestoreMass()
    if _G.XThrlen_TimerIndex and TXtime_ticker then
        pcall(TXtime_ticker.RemoveTimer, _G.XThrlen_TimerIndex)
    end
    print('[SRCHUB] unloaded')
end
