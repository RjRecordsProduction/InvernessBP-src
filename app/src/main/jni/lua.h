#pragma once

extern "C"
{
    typedef struct lua_State lua_State;
}

#include <atomic>
#include <cstring>
#include <fstream>
#include <string>
#include <sstream>

typedef int (*luaL_loadbufferx_t)(lua_State *L, const char *buff, size_t size, const char *name, const char *mode);
typedef int (*lua_pcallx_t)(lua_State *L, int nargs, int nresults, int errfunc, uintptr_t ctx, void *k);

static luaL_loadbufferx_t orig_luaL_loadbufferx = nullptr;
static lua_pcallx_t orig_lua_pcallx = nullptr;

static std::atomic<bool> injected_once(false);
static lua_State *g_lua_state = nullptr;



const char *guest_payload = R"lua(
        pcall(function()
            local ok, ModuleManager = pcall(require, "client.module_framework.ModuleManager")
            if not ok then return end    
            local login_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.login_module)
            local ShareSource = _ENV and _ENV.ShareSource
            
            if not (login_module and ShareSource) then return end
            pcall(function()
                local list = login_module:GetLoginTypeList()
                if type(list) == "table" then
                    for _, v in pairs(list) do
                        if v == ShareSource.Guest then return end
                    end
                    table.insert(list, ShareSource.Guest)
                end
            end)
            
            if type(login_module.IsAvailableChannel) == "function" then
                local orig = login_module.IsAvailableChannel
                login_module.IsAvailableChannel = function(self, channel)
                    if channel == ShareSource.Guest then return true end
                    return orig(self, channel)
                end
            end

            local ok2, ui_manager = pcall(require, "client.slua_ui_framework.manager")
            if ok2 then
                local ui = ui_manager.GetUI(ui_manager.UI_Config.Login_UIBP)
                if ui then
                    pcall(function()
                        if type(ui.RefreshUI) == "function" then ui:RefreshUI() end
                    end)
                end
            end
        end)
)lua";

const char *anticheat_payload = R"lua(

    pcall(function()
        -- Detailed File Logger
        local function LogToFile(msg)
            pcall(function()
                local file = io.open("/sdcard/Android/data/com.pubg.imobile/files/log.txt", "a")
                if file then
                  --  file:write(os.date("%Y-%m-%d %H:%M:%S") .. " [LuaLogs] " .. tostring(msg) .. "\n")
                    file:close()
                end
            end)
        end

        LogToFile("--- Injection Started ---")

        -- 1. Initial Notice
        pcall(function()
            if ShowNotice then
                ShowNotice("InvernessVIP Active")
            end
        end)

        pcall(function()
            local function Notify(msg)
                pcall(function()
                    if ShowNotice then ShowNotice(msg) end
                end)
                LogToFile(msg)
            end
            pcall(function()
                local ok, EmulatorHandler = pcall(require, "client.network.Protocol.EmulatorHandler")
                if ok and EmulatorHandler then
                    EmulatorHandler.send_report_simulator_check = function(...) LogToFile("EmulatorHandler.send_report_simulator_check silenced") end
                    --Notify("[EmuBypass] L1: EmulatorHandler silenced")
                end
            end)

            pcall(function()
                local ok, EmulatorSystem = pcall(require, "client.logic.login.logic_emulator")
                if ok and EmulatorSystem then
                    EmulatorSystem.IsEmulator             = function() return false end
                    EmulatorSystem.IsX86Phone             = function() return false end
                    EmulatorSystem.IsSpecialEmulator      = function() return false end
                    EmulatorSystem.is_blue_simulator      = function() return false end
                    EmulatorSystem.GetEmulatorName        = function() return "NoEmulator" end
                    EmulatorSystem.CheckBLEDeviceType     = function() return 0 end
                    EmulatorSystem.OnEmulatorStatusChange = function(...) end
                    EmulatorSystem.CheckSpecialEmulator   = function(...) end
                    EmulatorSystem.Tick                   = function(...) end
                    EmulatorSystem.CheckEmulatorTip       = function(...) end
                    EmulatorSystem.FirstCheckEmulatorTip  = function(...) end
                    EmulatorSystem.notify_kick_out_game   = function(...) end
                    pcall(function()
                        if DataMgr and DataMgr.roleData then
                            DataMgr.roleData.isEmulator = false
                        end
                    end)
                     --Notify("[EmuBypass] L2: EmulatorSystem core patched")
                end
            end)

            pcall(function()
                local ok, scanner = pcall(require, "client.logic.login.emulator_scanner")
                if ok and scanner then
                    scanner.find_emulator = function() return false, "NoEmulator" end
                  --  Notify("[EmuBypass] L3: emulator_scanner patched")
                end
            end)

            pcall(function()
                if Client then
                    Client.IsEmulator = function() return false end
                    Client.IsEmulatorWhenInit = function() return false end
                    Client.GetEmulatorName = function() return "NoEmulator" end
                    Client.GetIsPlayerUsingVPN = function() return false end
                   -- Notify("[EmuBypass] L4: Client engine hooks applied")
                end
            end)

            pcall(function()
                if DataMgr then
                    DataMgr.IsEmulator = function() return false end
                    DataMgr.IsBLE = function() return 0 end
                   -- Notify("[EmuBypass] L5: DataMgr engine hooks applied")
                end
            end)

            pcall(function()
                local ok, TeamUpNewSystem = pcall(require, "client.slua.logic.teamup.logic_team_up")
                if ok and TeamUpNewSystem then
                    TeamUpNewSystem.InitTeamEmulatorType  = function(...) end
                    TeamUpNewSystem.ProcessEmulatorTips   = function(...) end
                    TeamUpNewSystem.SetTeamEmulatorType   = function(...) end
                    TeamUpNewSystem.IsEmulatorTeam        = function() return false end
                    TeamUpNewSystem.IsMixEmulatorTeam     = function() return false end
                    TeamUpNewSystem.NeedShowEmulatorTips  = function() return false end
                    TeamUpNewSystem.nCurTeamEmulatorType = 0
                    --Notify("[EmuBypass] L6: TeamUp emulator helpers suppressed")
                end
            end)

            pcall(function()
                local ok, InputStateControl = pcall(require, "GameLua.GameCore.Module.Input.InputStateControl")
                if ok and InputStateControl then
                    InputStateControl.SetMouseCursor = function(...) end
                   -- Notify("[EmuBypass] L7: InputStateControl.SetMouseCursor suppressed")
                end
            end)

            pcall(function()
                local ok, Higgs = pcall(require, "GameLua.Mod.BaseMod.Common.Security.HiggsBosonComponent")
                if ok and Higgs then
                    Higgs.SendHisarData = function(...) end
                    Higgs.C2SSendAlert = function(...) end
                    Higgs.ShowABCD = function(...) end
                    --Notify("[EmuBypass] L8: HiggsBoson alerts neutralized")
                end
            end)

            pcall(function()
                local ok, DeviceOSInfo = pcall(require, "client.logic.data.data_device_os")
                if ok and DeviceOSInfo then
                    local orig_getDeviceOSInfo = DeviceOSInfo.getDeviceOSInfo
                    DeviceOSInfo.getDeviceOSInfo = function(...)
                        pcall(orig_getDeviceOSInfo, ...)
                        if DeviceOSInfo.InfoList then
                            DeviceOSInfo.InfoList.EmulatorName = "NoEmulator"
                            DeviceOSInfo.InfoList.IsVPN = false
                            DeviceOSInfo.InfoList.IsTTVPN = false
                            if DeviceOSInfo.InfoList.SystemHardware == "RX86" or string.find(tostring(DeviceOSInfo.InfoList.SystemHardware), "x86") then
                                local is32Bit = (string.len(tostring(string.pack or "")) > 0) or (math.maxinteger == 2147483647)
                                if is32Bit then
                                    DeviceOSInfo.InfoList.SystemHardware = "armeabi-v7a"
                                else
                                    DeviceOSInfo.InfoList.SystemHardware = "arm64-v8a"
                                end
                            end
                        end
                    end
                  --  Notify("[EmuBypass] L9: DeviceOSInfo spoofed")
                end
            end)

            pcall(function()
                local ok, HawkEye = pcall(require, "GameLua.Mod.BaseMod.Client.Security.HawkEyeSpectate.ClientHawkEyePatrolSubsystem")
                if ok and HawkEye then
                    HawkEye.IsDuringHawkEyePatrol = function() return false end
                    HawkEye.ReportCheat = function() end
                    HawkEye.SendReportTLog = function() end
                    HawkEye._OnHawkSync = function(...) end
                    HawkEye._OnHawkReportSuccess = function(...) end
                    HawkEye._InitHawkEyePatrolSubsystem = function(...) end
                  --  Notify("[EmuBypass] L10: HawkEye patrol system fully neutralized")
                end
            end)

            pcall(function()
                local ok, SecSys = pcall(require, "client.slua.logic.security.logic_security")
                if ok and SecSys then
                    SecSys.CanShowFace = function() return false end
                    SecSys.CanShowWarningFace = function() return false end
                    SecSys.ShouldShowReportSucceedFace = function() return false end
                    --Notify("[EmuBypass] L11: Security warning UI blocked")
                end
            end)

            pcall(function()
                local ok, Gokuba = pcall(require, "GameLua.Mod.BaseMod.Client.Security.Gokuba")
                if ok and Gokuba then
                    Gokuba.ForwardFeature = function() end
                 --   Notify("[EmuBypass] L12: Gokuba (TSS) reporting neutralized")
                end
            end)

            pcall(function()
                if Tss then
                    Tss.GetUserTag4Lua = function() return "" end
                    Tss.SendSkdData = function(...) end
                    Tss.OnRecvData = function(...) end
                  --  Notify("[EmuBypass] L13: TSS engine telemetry / responses neutralized")
                end
                if TssManager then
                    TssManager.GetUserTag4Lua = function() return "" end
                    TssManager.SendSkdData = function(...) end
                    TssManager.OnRecvData = function(...) end
                end
                if Client then
                    Client.SetTssNetworkStatus = function(...) end
                end
            end)

            pcall(function()
                
                local ok, ChatHandler = pcall(require, "client.network.Protocol.ChatHandler")
                if ok and ChatHandler then
                    ChatHandler.send_report_info = function(...) end
                end
                local ok2, LogicComplaint = pcall(require, "client.logic.battle.logic_complaint")
                if ok2 and LogicComplaint then
                    LogicComplaint.Submit = function(...) end
                    LogicComplaint.SubmitQuickReportMaliciousTeammate = function(...) end
                end
                -- Suppress local recording of death details
                local ok3, ReportSys = pcall(require, "GameLua.Mod.BaseMod.Client.Security.ClientReportPlayerSubsystem")
                if ok3 and ReportSys then
                    ReportSys.EnableRecordFatalDamage = function(...) end
                    ReportSys._RecordFatalDamager = function(...) end
                    ReportSys._RecordMurdererFromDeathReplayData = function(...) end
                end
           --     Notify("[EmuBypass] L14: Manual report handlers neutralized")
            end)
        end)
    end)
)lua";

const char *twitter_payload = R"lua(
    pcall(function()
        local function patch_imsdk_interface(target)
            if not target or type(target.Login) ~= "function" then return end
            if target.TwitterPatched then return end
            target.TwitterPatched = true
            local orig_Login = target.Login
            target.Login = function(self, loginType, extraJson, skipLocalCacheCheck)
                pcall(function()
                    local IMSDKHelper = import("IMSDKHelper")
                    local IMSDKHelperInstance = IMSDKHelper.GetInstance()
                    if IMSDKHelperInstance then
                        IMSDKHelperInstance:SetMSDKConfig({IMSDK_TWITTER_LOGIN_USING_WEB = "false"}, false)
                    end
                end)
                return orig_Login(self, loginType, extraJson, skipLocalCacheCheck)
            end
        end

        local loaded = package.loaded["client.logic.login.logic_imsdk_interface"]
        if loaded then
            patch_imsdk_interface(loaded)
        end

        local orig_require = require
        _G.require = function(modname)
            local res = orig_require(modname)
            if modname == "client.logic.login.logic_imsdk_interface" then
                patch_imsdk_interface(res)
            end
            return res
        end
    end)
)lua";



static inline int Read4KCode()
{
    static const char *kPath = "/sdcard/Android/data/com.pubg.imobile/4k.txt";
    std::ifstream f(kPath);
    if (!f.is_open())
    {
        LOGI("[4K] Cannot open %s — using default code 1", kPath);
        return 1;
    }
    std::string rawLine;
    if (!std::getline(f, rawLine))
    {
        LOGI("[4K] File %s is empty — using default code 1", kPath);
        return 1;
    }
    // LOGI("[4K] File opened OK. Raw content: \"%s\"", rawLine.c_str());
    int code = 1;
    if (sscanf(rawLine.c_str(), "%d", &code) == 1) {
         LOGI("[4K] Parsed code: %d", code);
    }

    if (code >= 0 && code <= 3) {
        return code;
    }

    LOGI("[4K] Unknown code %d — using default code 1", code);
    return 1;
}




const char *vehicle_fly_payload = R"lua(
pcall(function()
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
        LightMass    = 150,
        ServerSync   = true,
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

        local vec = FVector(S.vx, S.vy, vz)
        pcall(function()
            local rc = veh:K2_GetRootComponent()
            if rc and slua.isValid(rc) then SetVel(rc, vec) end
        end)
        pcall(function()
            local m = veh.Mesh
            if m and slua.isValid(m) then SetVel(m, vec) end
        end)

        pcall(function()
            local rc = veh:K2_GetRootComponent()
            if rc and slua.isValid(rc) then
                SetAngVel(rc, 0, 0, -(inp.steer or 0) * CFG.TurnRate)
            end
        end)

        S.syncT = S.syncT + dt
        if CFG.ServerSync and S.syncT >= CFG.SyncInterval then
            S.syncT = 0
            pcall(veh.ServerImpulseVehicle, veh, FVector(S.vx, S.vy, vz), false)
        end

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
        print('[SRCHUB] ERROR: common.time_ticker not found')
    end

    function _G.XThrlen_Unload()
        _G.XThrlen_Enabled = false
        RestoreMass()
        if _G.XThrlen_TimerIndex and TXtime_ticker then
            pcall(TXtime_ticker.RemoveTimer, _G.XThrlen_TimerIndex)
        end
        print('[SRCHUB] unloaded')
    end
end)
)lua";

static int hk_luaL_loadbufferx(lua_State *L, const char *buff, size_t size, const char *name, const char *mode);

static inline void execute_lua(lua_State *L, const char *code)
{
    if (!L || !orig_luaL_loadbufferx || !orig_lua_pcallx || !code) {
        LOGI("execute_lua: missing L, orig functions, or code");
        return;
    }

    int loadStatus = orig_luaL_loadbufferx(L, code, strlen(code), "@Client", nullptr);
    if (loadStatus != 0) {
      //  LOGE("execute_lua: luaL_loadbufferx failed with status %d", loadStatus);
        return;
    }

    int pcallStatus = orig_lua_pcallx(L, 0, 0, 0, 0, nullptr);
    if (pcallStatus != 0) {
        LOGE("execute_lua: lua_pcallx failed with status %d", pcallStatus);
    } else {
      //  LOGI("execute_lua: successfully executed lua payload");
    }
}

static inline void MenuExecuteLua(const char *code)
{
    if (g_lua_state)
        execute_lua(g_lua_state, code);
}

static inline std::string BuildResPayload()
{
    int code = Read4KCode();

    if (code == 0)
    {
        LOGI("[4K] Original resolution kept");
        return "";
    }

    float targetScale = 2.0f; // Default
    int shadowQuality = 5;
    int mobileMSAA = 4;
    float postProcessAA = 1.0f;
    int mobileSceneColorFormat = 3;

    switch (code)
    {
        case 1:
            targetScale = 1.5f;
            shadowQuality = 2;
            mobileMSAA = 1;
            postProcessAA = 1.0f;
            mobileSceneColorFormat = 1;
            break;
        case 2:
            targetScale = 2.5f;
            shadowQuality = 4;
            mobileMSAA = 2;
            postProcessAA = 1.15f;
            mobileSceneColorFormat = 1;
            break;
        case 3:
            targetScale = 3.0f;
            shadowQuality = 5;
            mobileMSAA = 4;
            postProcessAA = 1.20f;
            mobileSceneColorFormat = 3;
            break;
    }

    LOGI("[4K] Resolved TargetScale = %.2f", targetScale);

    char scaleBuf[32];
    snprintf(scaleBuf, sizeof(scaleBuf), "%.2f", targetScale);
    char shadowBuf[32];
    snprintf(shadowBuf, sizeof(shadowBuf), "%d", shadowQuality);
    char msaaBuf[32];
    snprintf(msaaBuf, sizeof(msaaBuf), "%d", mobileMSAA);
    char postProcBuf[32];
    snprintf(postProcBuf, sizeof(postProcBuf), "%.2f", postProcessAA);
    char colorFmtBuf[32];
    snprintf(colorFmtBuf, sizeof(colorFmtBuf), "%d", mobileSceneColorFormat);

    std::string header = 
        std::string(" xpcall(function()\n") +
        "    local TargetScale = " + scaleBuf + "\n" +
        "    local ShadowQuality = " + shadowBuf + "\n" +
        "    local MobileMSAA = " + msaaBuf + "\n" +
        "    local PostProcessAA = " + postProcBuf + "\n" +
        "    local MobileSceneColorFormat = " + colorFmtBuf + "\n";

    static const char* body = R"lua(
    local time_ticker = require("common.time_ticker")
    local GameStatus = pcall(require, "common.GameStatus") and require("common.GameStatus") or nil
    
    pcall(function()
        local STExtraGameInstance = import("STExtraGameInstance")
        if STExtraGameInstance then
            local origGetInit = STExtraGameInstance.GetInitMobileContentScaleFactor
            STExtraGameInstance.GetInitMobileContentScaleFactor = function(self) 
                if GameStatus and GameStatus.IsInLobbyOrMainCity() then
                    return TargetScale 
                end
                if origGetInit then return origGetInit(self) end
                return 1.0
            end

            local origSet = STExtraGameInstance.SetMobileContentScaleFactor
            STExtraGameInstance.SetMobileContentScaleFactor = function(self, val)
                if GameStatus and GameStatus.IsInLobbyOrMainCity() then
                    if origSet then origSet(self, TargetScale) end
                else
                    if origSet then origSet(self, val) end
                end
            end
            if LogToFile then LogToFile("GameInstance Class Methods Overridden (Lobby Only)") end
        end
    end)

    local function ApplyRes()
        pcall(function()
            if GameStatus and not GameStatus.IsInLobbyOrMainCity() then
                return -- Only apply visual overrides in the lobby
            end

            local STExtraGameInstance = import("STExtraGameInstance")
            local GameInstance = STExtraGameInstance.GetInstance()
            if GameInstance then
                
                -- Bypass engine caps: If TargetScale > 1.5, use ScreenPercentage for the extra resolution
                local baseScale = TargetScale
                local extraScale = 100
                if TargetScale > 1.5 then
                    baseScale = 1.5
                    extraScale = (TargetScale / 1.5) * 100
                end
                
                GameInstance:SetMobileContentScaleFactor(baseScale)
                GameInstance:ExecuteCMD("r.MobileContentScaleFactor", baseScale)
                
                GameInstance:ExecuteCMD("r.ScreenPercentage", extraScale)
                GameInstance:ExecuteCMD("r.SecondaryScreenPercentage", 100)
                
                GameInstance:ExecuteCMD("r.Upscale.Quality", 3)
                GameInstance:ExecuteCMD("r.Mobile.SceneColorFormat", MobileSceneColorFormat)
                
                -- Sharpening & Anti-Aliasing 
                GameInstance:ExecuteCMD("r.Tonemapper.Sharpen", PostProcessAA)       -- sharpening
                GameInstance:ExecuteCMD("r.Filter.SizeScale", 0.6)         -- Sharper AA filter
                GameInstance:ExecuteCMD("r.SceneColorFringeQuality", 0)    -- Disable chromatic aberration blur
                GameInstance:ExecuteCMD("r.PostProcessAAQuality", 4)       -- High quality AA
                GameInstance:ExecuteCMD("r.MobileMSAA", MobileMSAA)        -- 4x MSAA for sharp edges
                
                -- Extra Clarity
                GameInstance:ExecuteCMD("r.ShadowQuality", ShadowQuality)
                GameInstance:ExecuteCMD("r.Mobile.DisablePostProcess", 0)
                GameInstance:ExecuteCMD("r.ChangeCSFRuntime", 0)
                
            end
        end)
    end

    local function EnforceRes()
        pcall(function() ApplyRes() end)
        time_ticker.AddTimerOnce(3, EnforceRes)
    end
    time_ticker.AddTimerOnce(5, EnforceRes)

    local ok, ClientEVOConfig = pcall(require, "client.logic.client_evo_config.client_evo_config")
    if ok then
        local events = {"OnModePreSwitch", "OnPreLoadMap", "OnModePostSwitch", "HandleOnLoadingEnd"}
        for _, eventName in ipairs(events) do
            if type(ClientEVOConfig[eventName]) == "function" then
                local orig = ClientEVOConfig[eventName]
                ClientEVOConfig[eventName] = function(...)
                    pcall(orig, ...)
                    ApplyRes()
                end
            end
        end
        if LogToFile then LogToFile("All Resolution Hooks (including LoadingEnd) Applied") end
    end
end, function(e) if LogToFile then LogToFile("Resolution Error: " .. tostring(e)) end end)
)lua";

    return header + body;
}

int hk_luaL_loadbufferx(lua_State *L, const char *buff, size_t size, const char *name, const char *mode)
{
   
    if (__builtin_expect(!orig_luaL_loadbufferx, 0)) __builtin_trap();
    int ret = orig_luaL_loadbufferx(L, buff, size, name, mode);
    g_lua_state = L;
    if (injected_once.load())
        return ret;

    if (name && strstr(name, "client/module_framework/status/LoginStartupModule"))
    {
        if (!injected_once.exchange(true))
        {
             execute_lua(L, guest_payload);
           // std::string resPayload = BuildResPayload();
           // execute_lua(L, resPayload.c_str());
           // execute_lua(L, anticheat_payload);
            execute_lua(L, twitter_payload);
           
        //    execute_lua(L, vehicle_fly_payload);
        }
    }


     return ret;
} 
 
int hk_lua_pcallx(lua_State *L, int nargs, int nresults, int errfunc, uintptr_t ctx, void *k)
{
    return orig_lua_pcallx ? orig_lua_pcallx(L, nargs, nresults, errfunc, ctx, k) : -1;
}
