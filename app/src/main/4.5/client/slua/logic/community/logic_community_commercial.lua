local logic_community_commercial = {}
local curVersion = 0
local CHECK_COMPONENT_DELAY = 5
local FRIEND_WIDGET_TLOG_TYPES = {
  [TLogEventDefine.CardCollection_Widget_Item] = true,
  [TLogEventDefine.Naruto_Activity_Widget_Item] = true
}
function logic_community_commercial.GetSceneAndJumpChain(_TLogEventDefine)
  if _TLogEventDefine == TLogEventDefine.LobbyShop then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D4%26game_scene%3DEventWidgetShop%26from_scene%3D1"
  elseif _TLogEventDefine == TLogEventDefine.LobbyActivityBanner then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D4%26game_scene%3DEventWidgetBanner%26from_scene%3D1"
  elseif _TLogEventDefine == TLogEventDefine.Pass then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D4%26game_scene%3DEventWidgetRP%26from_scene%3D1"
  elseif _TLogEventDefine == TLogEventDefine.CollectMain then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D4%26game_scene%3DEventWidgetCollection%26from_scene%3D1"
  elseif _TLogEventDefine == TLogEventDefine.LobbyTheme_Widget_Item then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D0%26game_scene%3DFriendWidgetPlant%26from_scene%3D1"
  elseif _TLogEventDefine == TLogEventDefine.CardCollection_Widget_Item then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D0%26game_scene%3DExchangeCardWidget%26from_scene%3D1"
  elseif _TLogEventDefine == TLogEventDefine.Naruto_Activity_Widget_Item then
    return "game://?module=100030?deeplink=igamesdk%3A%2F%2Fmeemo%2Fadd_widget_guide%3F%26type%3D0%26game_scene%3DNarutoWidget%26from_scene%3D1"
  end
  return ""
end
function logic_community_commercial.GameToClubAndReport(_TLogEventDefine)
  log(bWriteLog and "logic_store_desktop_component.ReportAddStoreComponentToDesktop TLogEventDefine: " .. tostring(_TLogEventDefine))
  local jumpUrl = logic_community_commercial.GetSceneAndJumpChain(_TLogEventDefine)
  logic_community_commercial.ReportCommercialComponentEvent(TLogEventDefine.COMMUNITY_COMMERCIAL_COMPONENT_INSTALL, _TLogEventDefine)
  if jumpUrl and jumpUrl ~= "" and FRIEND_WIDGET_TLOG_TYPES[_TLogEventDefine] then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuideCache) or {}
    data[_TLogEventDefine] = true
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuideCache)
  end
  GlobalData.JumpUrl(jumpUrl)
  local timer_ticker = require("common.time_ticker")
  timer_ticker.AddTimerOnce(CHECK_COMPONENT_DELAY, function()
    logic_community_commercial.CheckCommercialComponentAdded(_TLogEventDefine, true)
  end)
end
function logic_community_commercial.CheckCommercialComponentAdded(_TLogEventDefine, bNotTLog)
  if GlobalData.IsBLUEHOLE() or GlobalData.IsJapanOrKorea() then
    return true
  end
  logic_community_commercial.SetClientVersionAndResetCache()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCommercialCache) or {}
  local bAdd = false
  local logic_activity_util = require("client.slua.logic.lobby.logic_activity_util")
  local desktopToolType = logic_activity_util.GetActivityDesktopToolType()
  log(bWriteLog and "logic_community_commercial.CheckCommercialComponentAdded desktopToolType: " .. tostring(desktopToolType))
  if desktopToolType and desktopToolType & ActivityDesktopToolType.Commercial ~= 0 then
    data.bAddSuccess = true
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eCommercialCache)
    log(bWriteLog and "logic_community_commercial.CheckCommercialComponentAdded already added")
    bAdd = true
  end
  local _ = not bNotTLog and logic_community_commercial.ReportCommercialComponentEvent(TLogEventDefine.COMMUNITY_COMMERCIAL_COMPONENT_INSTALLING, _TLogEventDefine, bAdd)
  if not bAdd and data.bAddSuccess then
    log(bWriteLog and "logic_community_commercial.CheckCommercialComponentAdded bAddSuccess")
    bAdd = true
  end
  return bAdd
end
function logic_community_commercial.CheckFriendWidgetAdded(_TLogEventDefine)
  log_format("logic_community_commercial.CheckFriendWidgetAdded. _TLogEventDefine=%s", _TLogEventDefine)
  if GlobalData.IsBLUEHOLE() or GlobalData.IsJapanOrKorea() then
    return true
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eFrienDeskTopTooldGuideCache) or {}
  log_tree("logic_community_commercial.CheckFriendWidgetAdded. data = ", data)
  if not _TLogEventDefine or data[_TLogEventDefine] then
  end
  local bAdd = false
  local logic_activity_util = require("client.slua.logic.lobby.logic_activity_util")
  local desktopToolType = logic_activity_util.GetActivityDesktopToolType()
  log(bWriteLog and "logic_community_commercial.CheckFriendWidgetAdded desktopToolType: " .. tostring(desktopToolType))
  if desktopToolType and desktopToolType & ActivityDesktopToolType.Friend ~= 0 then
    bAdd = true
  end
  return bAdd
end
function logic_community_commercial.SetClientVersionAndResetCache()
  if curVersion == 0 then
    local version = Client.GetApplicationVersion()
    local StringUtil = require("common.string_util")
    local result = StringUtil.Split(version, ".")
    if result and 3 <= #result then
      local str = string.format("%s%s%s", result[1], result[2], result[3])
      curVersion = tonumber(str)
      log(bWriteLog and "logic_community_commercial:GetClientVersionAndResetCache curVersion :" .. str)
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCommercialCache) or {}
  if data.version then
    if data.version ~= curVersion then
      PlayerPrefsSystem.SaveTableToFile_N({version = curVersion}, PlayerPrefsSystem.ePlayerPrefsType.eCommercialCache)
    end
  else
    data.version = curVersion
    PlayerPrefsSystem.SaveTableToFile_N(data, PlayerPrefsSystem.ePlayerPrefsType.eCommercialCache)
  end
end
function logic_community_commercial.ReportCommercialComponentEvent(TLogEventDefine, TLogEventDefineSoucre, bAdd)
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCommercialCache) or {}
  data.LastScene = TLogEventDefineSoucre
  if bAdd == nil then
    data.bAdding = nil
  else
    data.bAdding = bAdd
  end
  data.bAddSuccess = data.bAddSuccess or false
  local TLogReasonStr = json.encode(data)
  log(bWriteLog and "logic_community_commercial.ReportCommercialComponentEvent TLogEventDefine: " .. tostring(TLogEventDefine) .. " TLogReasonStr: " .. tostring(TLogReasonStr))
  tlog_report_utils.ReportTLogEvent(TLogEventDefine, 0, TLogReasonStr)
end
return logic_community_commercial