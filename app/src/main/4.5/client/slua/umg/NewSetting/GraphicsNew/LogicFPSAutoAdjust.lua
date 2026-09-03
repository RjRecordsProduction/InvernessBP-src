local LogicFPSAutoAdjust = {RESULT_ADJUST_FPS_LEVEL_60FPS = 6, RESULT_ADJUST_FPS_LEVEL_40FPS = 5}
function LogicFPSAutoAdjust:Initialize()
  printf("LogicFPSAutoAdjust:Initialize")
end
function LogicFPSAutoAdjust:OnInitialize()
end
function LogicFPSAutoAdjust:OnDestroy()
end
function LogicFPSAutoAdjust:RegistEvents()
  self:AddCommonEventWithConditions(EVENTTYPE_ACCOUNT, EVENTID_BATTLE_RESULT_ON_END_PHASE, {
    [1] = "ResultRankingProtectLogic"
  }, self.ProcessBattleResultOnEndPhase, self)
end
function LogicFPSAutoAdjust:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Lobby then
    local UIUtil = require("client.common.ui_util")
    local GameInstance = UIUtil.GetGameInstance()
    GameInstance:ExecuteCMD("t.OverrideMaxFPS", 0)
  end
end
function LogicFPSAutoAdjust:TempLimitBattleResult()
  printf("LogicFPSAutoAdjust:TempLimitBattleResult")
  local UIUtil = require("client.common.ui_util")
  local GameInstance = UIUtil.GetGameInstance()
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  local SettingConfig = LogicSettingGraphics.GetSettingConfig()
  if SettingConfig.BattleFPS > LogicFPSAutoAdjust.RESULT_ADJUST_FPS_LEVEL_60FPS then
    GameInstance:ExecuteCMD("t.OverrideMaxFPS", 60)
  end
end
function LogicFPSAutoAdjust:ProcessBattleResultOnEndPhase()
  self:TempLimitBattleResult()
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicFPSAutoAdjust = class(CModuleBase, nil, LogicFPSAutoAdjust)
return CLogicFPSAutoAdjust