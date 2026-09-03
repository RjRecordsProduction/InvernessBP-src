local LogicPeakGamePopup = {}
function LogicPeakGamePopup:DefineAndResetData()
end
function LogicPeakGamePopup:OnInitialize()
end
function LogicPeakGamePopup:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PEAK_GAME_START_GAME_POPUP, self.TryShowPeakGameStartGamePopup, self)
end
function LogicPeakGamePopup:OnLogin(bReLogin)
end
function LogicPeakGamePopup:OnLogOut()
end
function LogicPeakGamePopup:OnPreSwitchGameStatus(preState, nextState)
end
function LogicPeakGamePopup:OnPostSwitchGameStatus(preState, nextState)
end
function LogicPeakGamePopup:TryShowPeakGameStartGamePopup()
  log(bWriteLog and "LogicPeakGamePopup:TryShowPeakGameStartGamePopup")
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  LogicPeakGame:ReqPeakGameTimeInfo(true)
  LogicPeakGame:ReqPeakGameInfo(false)
  self:AddTimerOnce(1, function()
    log(bWriteLog and "LogicPeakGamePopup:TryShowPeakGameStartGamePopup timer once")
    self:ShowPeakGameStartGamePopup()
  end)
end
function LogicPeakGamePopup:ShowPeakGameStartGamePopup()
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup")
  if LobbySystem.isInMatch then
    log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup in Match")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.ePeakGameStartGamePopup) or {}
  local nLastPlayTime = tLocalCache.nLastPlayTime or 0
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup nLastPlayTime = " .. tostring(nLastPlayTime))
  local TimeUtil = require("client.common.time_util")
  local bSameDay = TimeUtil.IsSameDay(nLastPlayTime, TimeUtil.GetServerTimeInSec())
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup bSameDay = " .. tostring(bSameDay))
  if bSameDay then
    return
  end
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  local bInOpenTime = LogicPeakGameUtil.IsInOpenTime()
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup bInOpenTime = " .. tostring(bInOpenTime))
  if not bInOpenTime then
    return
  end
  local zone_id = LogicPeakGameUtil.GetCurSelectZoneId()
  local LogicPeakGame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicPeakGame)
  local dayBeginTS, dayEndTS = LogicPeakGame:GetPeakGameTodayValidTime(zone_id)
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup dayBeginTS = " .. tostring(dayBeginTS) .. " dayEndTS = " .. tostring(dayEndTS))
  if not (dayBeginTS and dayEndTS) or TimeUtil.UnixTimeBetween(dayBeginTS, dayEndTS) ~= 0 then
    log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup time invalid")
    return
  end
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local rating = LogicPeakGameSegmentUtil.GetSelfCurZonePeakGameRating()
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup rating = " .. tostring(rating))
  local PeakGameConfig = require("client.logic.PeakGame.PeakGameConfig")
  if not rating or rating == PeakGameConfig.DefaultPeakGameRating then
    log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup rating invalid")
    return
  end
  tLocalCache.nLastPlayTime = TimeUtil.GetServerTimeInSec()
  log(bWriteLog and "LogicPeakGamePopup:ShowPeakGameStartGamePopup tLocalCache.nLastPlayTime = " .. tostring(tLocalCache.nLastPlayTime))
  PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.ePeakGameStartGamePopup)
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local configtable = ui_show_queue_config.GetParamTable(nil, "PeakGame")
  local content = LocUtil.GetLocalizeResStr(68448)
  local path = "/Game/UMG/Texture_200/Atlas/Teamplatform/Frames/TeamPlatform_BG_PeakGame_png.TeamPlatform_BG_PeakGame_png"
  local jumpInfo = {
    bShowJumpBtn = true,
    callback = function()
      local mode_selection_macro = require("client.slua.logic.mode_selection.mode_selection_macro")
      UIManager.ShowUI(UIManager.UI_Config.mode_selection_main, {viewId = 90069})
    end
  }
  RightPopSystem.CommonPopup(configtable, "", content, path, jumpInfo, 10)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicPeakGamePopup = class(CModuleBase, nil, LogicPeakGamePopup)
return CLogicPeakGamePopup