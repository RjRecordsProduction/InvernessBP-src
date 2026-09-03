local logic_lobby_bubble = {lobbyMidBottomBannerBubble = nil}
local LobbyBubbleConfig = require("client.slua.logic.lobby_bubble.LobbyBubbleConfig")
local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
local TimeUtil = require("client.common.time_util")
function logic_lobby_bubble.on_get_bubble_info_rsp(bubbleDataList)
  log_tree("xcc logic_lobby_bubble.on_get_bubble_info_rsp", bubbleDataList)
  local ActivityBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ActivityBubbleModule)
  if not bubbleDataList or type(bubbleDataList) ~= "table" or not next(bubbleDataList) then
    log(bWriteLog and "ActivityBubbleModule on_get_bubble_info_rsp bubbleDataList = nil")
    ActivityBubbleModule:HandleBubbleData(nil)
    logic_lobby_bubble.ShowLobbyBottomBannerBubbleUI(nil)
    return
  end
  local activityBubbleData, lobbyMidBottomBannerBubble
  local realLobbyBubbleDataList = {}
  local realLobbyBubbleIndexList = {}
  local SpecialOfferBubbleModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.SpecialOfferBubbleModule)
  for _, bubbleData in pairs(bubbleDataList) do
    if bubbleData.from_type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.SpecialOffer_End then
      if not bubbleData.item_id then
        SpecialOfferBubbleModule:HandleBubbleData(bubbleData)
      end
    elseif bubbleData.from_type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Activity then
      if not activityBubbleData then
        activityBubbleData = bubbleData
        ActivityBubbleModule:HandleBubbleData(bubbleData)
      end
    elseif bubbleData.from_type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.LobbyBottomBanner then
      lobbyMidBottomBannerBubble = bubbleData
    elseif bubbleData.item_id then
      realLobbyBubbleDataList[bubbleData.item_id] = bubbleData
      table.insert(realLobbyBubbleIndexList, bubbleData.item_id)
    end
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local bubbleCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eLobbyBubble) or {}
  log_tree("xcc logic_lobby_bubble.on_get_bubble_info_rsp bubbleCache", bubbleCache)
  local preShowBubbleNum = bubbleCache.todayShowBubbleNum
  local preLoginTime = bubbleCache.LoginTime
  bubbleCache.todayShowBubbleNum = nil
  bubbleCache.LoginTime = nil
  bubbleCache.HaveShowBubbleNum = nil
  for _, bubbleData in pairs(realLobbyBubbleDataList) do
    local IdStr = tostring(bubbleData.item_id)
    bubbleData.LastClickServerTime = 0
    if bubbleCache[IdStr] then
      bubbleData.LastClickServerTime = bubbleCache[IdStr] and bubbleCache[IdStr].LastClickServerTime or 0
      bubbleCache[IdStr] = nil
    end
  end
  for _, bubbleData in pairs(bubbleCache) do
    if logic_lobby_bubble.CheckBubbleAllowShow(bubbleData) then
      realLobbyBubbleDataList[bubbleData.item_id] = bubbleData
      table.insert(realLobbyBubbleIndexList, bubbleData.item_id)
    end
  end
  local todayShowBubbleNum = 0
  if preLoginTime and TimeUtil.IsToday(preLoginTime) then
    todayShowBubbleNum = preShowBubbleNum
  else
    preLoginTime = TimeUtil.GetServerTimeInSec()
  end
  local maxLobbyBubbleNum = tonumber(CDataTable.GetTableData("SystemConfig", "MaxLobbyBubbleNum").ConfigValue)
  local canShowBubbleNum = #realLobbyBubbleIndexList or 0
  if 0 < canShowBubbleNum and todayShowBubbleNum < maxLobbyBubbleNum then
    local xrandom = require("client.common.uibase.xrandom")
    local curBubbleItemId = realLobbyBubbleIndexList[xrandom.Random2(1, canShowBubbleNum + 1)]
    local curBubbleData = realLobbyBubbleDataList[curBubbleItemId]
    EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_BUBBLE_UPDATE, curBubbleData)
    todayShowBubbleNum = todayShowBubbleNum + 1
  end
  LobbySystem.LobbyBubbleList = realLobbyBubbleDataList
  LobbySystem.LobbyBubbleList.  LobbySystem.LobbyBubbleList.LoginTime = preLoginTime
  PlayerPrefsSystem.SaveTableToFile_N(LobbySystem.LobbyBubbleList, PlayerPrefsSystem.ePlayerPrefsType.eLobbyBubble)
  logic_lobby_bubble.ShowLobbyBottomBannerBubbleUI(lobbyMidBottomBannerBubble)
end
function logic_lobby_bubble.CheckBubbleAllowShow(bubbleData)
  if bubbleData and bubbleData.item_id and not wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(bubbleData.item_id) then
    local nowTime = TimeUtil.GetServerTimeInSec()
    if bubbleData.start_time and bubbleData.end_time and nowTime > bubbleData.start_time and nowTime < bubbleData.end_time then
      local bIsTimeValid = bubbleData.LastClickServerTime == 0 or nowTime > bubbleData.LastClickServerTime + 86400
      local bAllow = false
      if bubbleData.from_type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Rp then
        if UnknowPassSystem.Season and UnknowPassSystem.Season == 53 then
          bAllow = UnknowPassSystem.IsBuyElite and bIsTimeValid
        else
          bAllow = bIsTimeValid
        end
      elseif bubbleData.from_type == LobbyBubbleConfig.Enum_Lobby_Bubble_Type.Rp_CriticalHit then
        bAllow = not UnknowPassSystem.IsBuyElite and bIsTimeValid
      else
        bAllow = bIsTimeValid
      end
      return bAllow
    end
  end
  return false
end
function logic_lobby_bubble.ReportBubbleTLog(bCheck, bClick, bubble_id)
  if bCheck then
    if LobbySystem.canReportOneExposure.store_tips then
      LobbySystem.canReportOneExposure.store_tips = false
    else
      return
    end
  end
  if bubble_id then
    gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_LobbyBubble, bubble_id, 0)
    local TLogReasonStrTable = {
      event_name = gem_report_utils.SubEventName_LobbyBubble,
      item_id = bubble_id,
      click = bClick or false
    }
    local TLogReasonStr = json.encode(TLogReasonStrTable)
    ClientSendTLogReport(TLogEventDefine.ExposureEntrance, 0, TLogReasonStr)
    log(bWriteLog and "TLog new format, LobbySystem.ExposureReportInLobby MallBubble, reason : " .. tostring(eventType) .. " reasonStr : " .. tostring(TLogReasonStr))
  end
end
function logic_lobby_bubble.CheckTimeValid(bubbleData)
  local startTime = bubbleData.start_time
  local endTime = bubbleData.end_time
  if not startTime or not endTime then
    return false
  end
  local nowTime = TimeUtil.GetServerTimeInSec()
  if startTime > nowTime or endTime < nowTime then
    return false
  end
  return true
end
function logic_lobby_bubble.ShowLobbyBottomBannerBubbleUI(tBubbleData)
  logic_lobby_bubble.lobbyMidBottomBannerBubble = tBubbleData
  local tValidBubbleData = logic_lobby_bubble.GetBottomBannerBubbleData()
  EventSystem:postEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_LOBBY_BUBBLE_MID_BOTTOM_UPDATE)
end
function logic_lobby_bubble.GetBottomBannerBubbleData()
  local tBubbleData = logic_lobby_bubble.lobbyMidBottomBannerBubble
  if tBubbleData and tBubbleData.id and logic_lobby_bubble.CheckTimeValid(tBubbleData) then
    return tBubbleData
  end
end
return logic_lobby_bubble