local logic_memory_warning = {}
function logic_memory_warning:OnInitialize()
  self.bHaveShow = nil
end
function logic_memory_warning:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_INGAME_REPLAY, EVENTID_CLIENT_RECORD_MEMORY_WARNING, self.OnPeriodUpdate, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_MEMORY_WARNING_TIP, self.ShowMemoryWarningTip, self)
end
function logic_memory_warning:OnPeriodUpdate()
  log(bWriteLog and "[mxiliu] logic_memory_warning.OnPeriodUpdate start ")
  local uGameState = slua_GameFrontendHUD:GetGameState()
  if slua.isValid(uGameState) then
    log(bWriteLog and "[mxiliu] logic_memory_warning.OnPeriodUpdate EGameModeType " .. tostring(uGameState.GameModeType))
    local EGameModeType = import("EGameModeType")
    if uGameState.GameModeType == EGameModeType.ETypicalGameMode or uGameState.GameModeType == EGameModeType.EActivityGameMode then
      self.bHaveShow = true
    else
      log(bWriteLog and "[mxiliu] logic_memory_warning.OnPeriodUpdate need not warning")
    end
  end
end
function logic_memory_warning:CheckCanShow()
  log(bWriteLog and "[mxiliu] logic_memory_warning.CheckCanShow start ")
  if not self.bHaveShow then
    log(bWriteLog and "[mxiliu] logic_memory_warning.bHaveShow false")
    return true
  end
  self.bHaveShow = false
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eWarningTips) or ""
  local version_util = require("client.common.version_util")
  local OriginVersion = Client.GetAppVersion()
  local ClientVersion = version_util.GetMainFormat(OriginVersion)
  if saveData and saveData ~= "" and not (version_util.CompareVersionStandard(ClientVersion, saveData) > 0) then
    log(bWriteLog and "[mxiliu] ReplayTipPopVersion[%s], ClientVersion[%s] already pop tip")
    return true
  end
  return false
end
function logic_memory_warning:ShowMemoryWarningTip()
  log(bWriteLog and "[mxiliu] logic_memory_warning.ShowMemoryWarningTip start ")
  if self:CheckCanShow() then
    return
  end
  local content = LocUtil.GetLocalizeResStr(62933)
  local jumpBtn = {
    callback = function()
      log(bWriteLog and "[mxiliu] logic_memory_warning popup tip jump")
      local jumpkey = "bRecordWonderfulReplayOpen"
      local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
      local WonderfulReplaySwitch1 = SettingModule:GetOptionValue("bRecordWonderfulReplayOpen")
      local WonderfulReplaySwitch2 = SettingModule:GetOptionValue("DeathPlaybackSwitch")
      if WonderfulReplaySwitch1 == true and WonderfulReplaySwitch2 == true then
      elseif WonderfulReplaySwitch1 == true and WonderfulReplaySwitch2 ~= true then
        jumpkey = "DeathPlaybackSwitch"
      else
        jumpkey = "bRecordWonderfulReplayOpen"
      end
      local SettingUtil = require("client.slua.logic.setting.setting_util")
      local SettingMacro = require("client.slua.logic.setting.setting_macro")
      SettingUtil.Enter("Game", "Game_Advanced", jumpkey)
    end
  }
  local onShowCallback = function()
    log(bWriteLog and "[mxiliu] logic_memory_warning popup tip on show")
    local version_util = require("client.common.version_util")
    local OriginVersion = Client.GetAppVersion()
    local ClientVersion = version_util.GetMainFormat(OriginVersion)
    local savedata = ClientVersion
    log(bWriteLog and "[mxiliu] logic_memory_warning popup savedata is" .. savedata)
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefsSystem.SaveTableToFile_N(savedata, PlayerPrefsSystem.ePlayerPrefsType.eWarningTips)
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  RightPopSystem.ShowPopupTip(content, true, nil, jumpBtn, 10, nil, onShowCallback)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_memory_warning = class(CModuleBase, nil, logic_memory_warning)
return Clogic_memory_warning