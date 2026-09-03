local ui_show_queue_config = {}
ui_show_queue_config.TimerInterval = 5
ui_show_queue_config.ReShowDelayTime = 0.1
ui_show_queue_config.DefaultOrder = 999
ui_show_queue_config.EShowLobbyType = {
  Lobby_2D = 1,
  MainCity = 2,
  XMission = 3,
  WOW = 4,
  SocialIsland = 5,
  Home = 6,
  Fighting = 7,
  UGCMineMain = 8,
  Supply = 9,
  CollectionHall = 10,
  Lobby_2D_Mid_Page = 11,
  UGCFindWorkHall = 12
}
local EShowLobbyType = ui_show_queue_config.EShowLobbyType
ui_show_queue_config.EPlayerType = {
  Main = 200,
  ShortReturn = 202,
  NewBie = 203,
  AtRisk = 204,
  LongReturn = 205
}
ui_show_queue_config.EPlayerReturnType = {
  None = 0,
  LoginTotalCountLimit = 1,
  FirstDayLimit = 2,
  FirstDayTotalCountLimit = 3,
  FirstDayOrLoginTotalCountLimit = 4
}
ui_show_queue_config.EUIBigType = {
  Slap = 1,
  Guide = 2,
  Normal = 3,
  Popup = 4
}
ui_show_queue_config.EUISmallType = {
  Normal = 1,
  Slap = 2,
  Guide = 3,
  Popup_Middle = 4,
  Popup_RightBottom = 5,
  Popup_Top = 6
}
ui_show_queue_config.ECantAddReason = {
  None = 0,
  ReturnFirstDayLimit = 1,
  ReturnLoginTotalCountLimit = 2,
  ReturnFirstDayTotalCountLimit = 3,
  ReturnFirstDayOrLoginTotalCountLimit = 4,
  ShowCountLimit = 5
}
ui_show_queue_config.InTargetLobbyFuncTable = {
  [EShowLobbyType.Lobby_2D] = function()
    return GameStatus.IsIn2DLobby()
  end,
  [EShowLobbyType.MainCity] = function()
    return GameStatus.IsInMainCity()
  end,
  [EShowLobbyType.XMission] = function()
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    return LogicTxMissionMain.IsInXMission()
  end,
  [EShowLobbyType.WOW] = function()
    local topUIName = UIManager.GetTopUIName()
    local top_ui_list = {}
    table.insert(top_ui_list, UIManager.UI_Config.mode_selection_main.keyName)
    table.insert(top_ui_list, UIManager.UI_Config.ModeSelection_Wow_UIBP.keyName)
    for k, v in pairs(top_ui_list) do
      local keyName = v
      if topUIName == keyName then
        return true
      end
    end
    if topUIName == "" and UIManager.IsUIShow(UIManager.UI_Config.UGC_Hall_UIBP) then
      return true
    end
    return false
  end,
  [EShowLobbyType.SocialIsland] = function()
    return GameStatus.IsSocialIslandMode()
  end,
  [EShowLobbyType.Home] = function()
    local bIsInFightingStatus = GameStatus.GetGameStatus() == GameStatus.Fighting
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    return PlanPH_GamePlay_Tools.IsPHomeMode(bIsInFightingStatus)
  end,
  [EShowLobbyType.Fighting] = function()
    local bIsInFightingStatus = GameStatus.GetGameStatus() == GameStatus.Fighting
    if not bIsInFightingStatus then
      return false
    end
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    if GameStatus.IsIn2DLobby() or GameStatus.IsInMainCity() or LogicTxMissionMain.IsInXMission() or GameStatus.IsSocialIslandMode() or PlanPH_GamePlay_Tools.IsPHomeMode(bIsInFightingStatus) then
      return false
    end
    return true
  end,
  [EShowLobbyType.UGCMineMain] = function()
    local topUIName = UIManager.GetTopUIName()
    local keyName = UIManager.UI_Config.ugc_mine_main.keyName
    if topUIName == keyName then
      return true
    end
    return false
  end,
  [EShowLobbyType.Supply] = function()
    local topUIName = UIManager.GetTopUIName()
    local keyName1 = UIManager.UI_Config.NewSupplySystem.keyName
    local keyName2 = UIManager.UI_Config.NewSupplySystemJK.keyName
    if topUIName == keyName1 or topUIName == keyName2 then
      return true
    end
    return false
  end,
  [EShowLobbyType.CollectionHall] = function()
    return GameStatus.IsCollectionHallMode()
  end,
  [EShowLobbyType.Lobby_2D_Mid_Page] = function()
    if not GameStatus.IsIn2DLobby() then
      log_warning(bWriteLog and "InTargetLobbyFuncTable - Lobby_2D_Mid_Page - not in 2D lobby")
      return false
    end
    local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    local visibility = lobbyMain:GetVisibility()
    if visibility == UEnums.ESlateVisibility.Collapsed then
      log_warning(bWriteLog and "InTargetLobbyFuncTable - Lobby_2D_Mid_Page - lobbyMain is nil or hidden")
      return false
    end
    local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
    local curPage = Lobby_Main_Control.curPage
    local toPage = Lobby_Main_Control.toPage
    log_format("InTargetLobbyFuncTable - Lobby_2D_Mid_Page - curPage: %s, toPage: %s", curPage, toPage)
    if curPage ~= ENUM_LobbyPageType.Mid or toPage ~= ENUM_LobbyPageType.Mid then
      log_warning(bWriteLog and "InTargetLobbyFuncTable - Lobby_2D_Mid_Page - not in mid page")
      return false
    end
    return true
  end,
  [EShowLobbyType.UGCFindWorkHall] = function()
    local topUIName = UIManager.GetTopUIName()
    local keyName = UIManager.UI_Config.UGCMainPanelFindWorksHall.keyName
    if topUIName == keyName then
      return true
    end
    return false
  end
}
ui_show_queue_config.GMReturnStruct = {
  uiPlayerTypeConfigID = 0,
  registerDay = 0,
  timeSpanIndex = 0,
  startTime = 0,
  endTime = 0,
  currentCount = 0,
  limitCount = 0,
  returnType = 0,
  returnParam = 0,
  returnLoginCount = 0,
  returnFirstDay = 0,
  returnLimitEndTime = 0,
  cantAddReason = 0
}
ui_show_queue_config.LqcUIConfigTemplate = {
  UIKey = 0,
  KeyName = "",
  Param = "",
  BigType = 0,
  SmallType = 0,
  LobbyType = "",
  UIStackCheck = false,
  IsUnlimited = false
}
ui_show_queue_config.QueueElementStruct = {
  args = nil,
  lqcUIConfig = nil,
  addQueueTime = 0,
  addQueueServerTime = 0,
  sortWeight = 0
}
ui_show_queue_config.ParamTable = {
  IsConfig = true,
  QueueUIKey = nil,
  Param1 = "",
  IgnorePlayerType = false,
  SortWeightOffset = 0
}
function ui_show_queue_config.GetParamTable(queueUIKey, param1, ignorePlayerType, sortWeightOffset)
  local TableUtil = require("common.table_util")
  local result = TableUtil.FastCopyTable(ui_show_queue_config.ParamTable)
  result.QueueUIKey = queueUIKey
  result.Param1 = param1 or ""
  result.IgnorePlayerType = ignorePlayerType
  result.SortWeightOffset = tonumber(sortWeightOffset) or 0
  return result
end
return ui_show_queue_config