local luagc_strategy = {}
local StepGCTime = 0.001
local BattleStepGCTime = 5.0E-4
local MaxStepGCTime = 0.003
local LowerMemory = 5120
local UpperMemory = 20480
local advanceStrategy = false
local local local local local local Client_GetDevicePlatformName = Client.GetDevicePlatformName
local slua_setGCParam = slua.setGCParam
local timerID
function luagc_strategy.OnPostSceneLoad(_, _, gameState)
  print(bWriteLog and "luagc_strategy.OnPostSceneLoad")
  if timerID then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(timerID)
    timerID = nil
  end
  collectgarbage("stop")
  if gameState.current == GameStatus.Fighting then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    if MatchModeMgrSystem.IsSocialIslandMode() or PlanPH_GamePlay_Tools.IsPHomeMode() or MatchModeMgrSystem.IsCreativeMode() then
      print(bWriteLog and "luagc_strategy.OnPostSceneLoad lua gc in social land")
      local ScriptHelperEngine = import("ScriptHelperEngine")
      if advanceStrategy or ScriptHelperEngine.IsLowMemoryDevice() then
        luagc_strategy.Advance()
      else
        slua_setGCParam(BattleStepGCTime, 500, 0)
      end
    else
      local ScriptHelperEngine = import("ScriptHelperEngine")
      local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
      if Client_GetDevicePlatformName() == DevicePlatformNameMacros.IOS and ScriptHelperEngine.IsLowMemoryDevice() then
        slua_setGCParam(MaxStepGCTime * 18, 5000, 0)
      else
        local STExtraGameInstance = import("STExtraGameInstance")
        local uSTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
        local fpsconfig = uSTExtraBlueprintFunctionLibrary.GetConsoleVariableFloatValue("t.MaxFPS")
        local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
        local settingConfig = LogicSettingGraphics.GetSettingConfig()
        local gameInstance = STExtraGameInstance.GetInstance()
        local deviceLevel = gameInstance:GetDeviceLevel()
        if settingConfig.BattleFPS > 6 then
          print(bWriteLog and "luagc_strategy. open luagc and set interval as 37s when fps is extend to 60" .. settingConfig.BattleFPS)
          local optSwitch120 = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableLuaGCInterval120", 1)
          if optSwitch120 == 1 then
            slua_setGCParam(BattleStepGCTime, 500, 50)
          else
            slua_setGCParam(BattleStepGCTime, 500, 0)
          end
        else
          print(bWriteLog and "luagc_strategy. open luagc when fps is less than 60" .. settingConfig.BattleFPS)
          local optSwitch = HDmpveRemote.HDmpveRemoteConfigGetInt("EnableLuaGCInterval", 1)
          if optSwitch == 1 then
            slua_setGCParam(BattleStepGCTime, 500, 30)
          else
            slua_setGCParam(BattleStepGCTime, 500, 0)
          end
        end
      end
    end
  else
    slua_setGCParam(StepGCTime, 1000, 0)
  end
end
local _Lerp = function(a, b, t)
  local r = a + (b - a) * t
  if a > r then
    return a
  end
  if b < r then
    return b
  end
  return r
end
local _Saturate = function(t)
  if t < 0 then
    return 0
  end
  if 1 < t then
    return 1
  end
  return t
end
local _InvLerp = function(a, b, t)
  return _Saturate((t - a) / (b - a))
end
function luagc_strategy.Advance()
  local luaStartMemory = collectgarbage("count")
  local time_ticker = require("common.time_ticker")
  timerID = time_ticker.AddTimerLoop(0, function()
    local currentMemory = collectgarbage("count")
    local deltaMemory = currentMemory - luaStartMemory
    local factor = _InvLerp(LowerMemory, UpperMemory, deltaMemory)
    local stepTime = _Lerp(StepGCTime, MaxStepGCTime, factor)
    slua_setGCParam(stepTime, 1000, 0)
  end, TIMER_INFINITE, 5)
end
function luagc_strategy.UnregistControlEvent()
end
function luagc_strategy.OpenAdvanceStrategy()
  advanceStrategy = true
end
return luagc_strategy