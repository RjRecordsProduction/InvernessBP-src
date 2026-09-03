local logic_moment_bubble_tips = {autoHideBubbleTipsTime = 5}
local Enum_BubbleTipsType = {GlobalNotify = 1, PersonalNotify = 2}
logic_moment_bubble_tips.local Enum_BubbleTipsID = {
  BackGround = 10002,
  Message = 10003,
  Square = 10004
}
logic_moment_bubble_tips.local moment_macro = require("client.slua.logic.moment.moment_macro")
local ImageBgTipsPathCfg = {
  [moment_macro.ENUM_TAB_LIMIT_TYPE.FRIEND] = "/Game/UMG/Texture/Lobby_NoAtlas/Moment/Moment_TopTips_Friend_Bg.Moment_TopTips_Friend_Bg",
  [moment_macro.ENUM_TAB_LIMIT_TYPE.HOT] = "/Game/UMG/Texture/Lobby_NoAtlas/Moment/Moment_TopTips_Hot_Bg.Moment_TopTips_Hot_Bg",
  [moment_macro.ENUM_TAB_LIMIT_TYPE.SQUARE] = "/Game/UMG/Texture/Lobby_NoAtlas/Moment/Moment_TopTips_Hot_Bg.Moment_TopTips_Hot_Bg"
}
logic_moment_bubble_tips.local Enum_ModuleIndex = {
  friend_recent_moments = 1,
  hot_moments = 2,
  square_moments = 3
}
local C_SendIndexList = {
  Enum_ModuleIndex.friend_recent_moments,
  Enum_ModuleIndex.hot_moments,
  Enum_ModuleIndex.square_moments
}
local recordShowPopTipsInfo, isRemovedBubbleTips, isRemovePersonalBubble, allBubbleTipsConfig, hasClickBubbleIDList, checkPersonalTipsConfig, hasShowedBubbleIDList, cachePopTipsList
local newSquareCount = 0
local isGetSquareList
local _IsHaveNewBackGround = function()
  local logic_moment_background = require("client.slua.logic.moment.logic_moment_background")
  if not logic_moment_background.HasNew() then
    return false
  end
  local localRedDotFileTb = logic_moment_background.GetLocalRedDotFileTb()
  if localRedDotFileTb[1] ~= nil then
    return false
  end
  return true
end
local _IsHaveFriendMsgNew = function()
  local moment_reddot_data = require("client.slua.logic.moment.moment_reddot_data")
  local momentRedPoint = moment_reddot_data.GetData()
  if not momentRedPoint or not momentRedPoint.has_new_fri_msgs then
    return false
  end
  return true
end
local _InitPersonalBubbleCheckCfg = function()
  if checkPersonalTipsConfig ~= nil then
    return checkPersonalTipsConfig
  end
  checkPersonalTipsConfig = {
    [Enum_BubbleTipsID.BackGround] = _IsHaveNewBackGround,
    [Enum_BubbleTipsID.Message] = _IsHaveFriendMsgNew
  }
  return checkPersonalTipsConfig
end
local _GetBubbleTipsCfgByBubbleID = function(bubbleID)
  if not allBubbleTipsConfig then
    return
  end
  for _, v in ipairs(allBubbleTipsConfig) do
    if v.BubbleID == bubbleID then
      return v
    end
  end
  return nil
end
local _InitData = function()
  recordShowPopTipsInfo = nil
  isRemovedBubbleTips = nil
  allBubbleTipsConfig = nil
  hasClickBubbleIDList = nil
  checkPersonalTipsConfig = nil
  isRemovePersonalBubble = nil
  hasShowedBubbleIDList = nil
  cachePopTipsList = nil
  newSquareCount = 0
  isGetSquareList = nil
end
local _InitBubbleTipsConfig = function()
  if allBubbleTipsConfig and 0 < #allBubbleTipsConfig then
    return
  end
  if not allBubbleTipsConfig then
    allBubbleTipsConfig = {}
  end
  local tipsCfg = CDataTable.GetTable("MomentBubbleTipsCfg")
  local version_util = require("client.common.version_util")
  local currVersion = Client.GetAppVersion()
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips InitBubbleTipsConfig, currVersion is:" .. tostring(currVersion))
  for _, v in pairs(tipsCfg) do
    if v.Version and v.Version ~= "" and version_util.HigherVersion(currVersion, v.Version) then
      local oneTips = {
        BubbleID = v.BubbleID,
        BubbleType = v.BubbleType,
        BubbleSort = v.BubbleSort,
        Content = v.Content
      }
      table.insert(allBubbleTipsConfig, oneTips)
    end
  end
  log_tree(bWriteLog and "[v_wllwu] allBubbleTipsConfig ", allBubbleTipsConfig)
  if #allBubbleTipsConfig <= 1 then
    return
  end
  table.sort(allBubbleTipsConfig, function(a, b)
    return a.BubbleSort < b.BubbleSort
  end)
end
local _IsCanInsertUID = function(uidList, uid)
  if not uidList or not uid then
    log_error(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:IsCanInsertUID error, uid = " .. tostring(uid))
    return
  end
  local TableUtil = require("common.table_util")
  if TableUtil.Find(uidList, uid) < 0 then
    return true
  end
  return false
end
function logic_moment_bubble_tips:OnInitialize()
  logic_moment_bubble_tips.__super.OnInitialize(self)
  _InitData()
end
function logic_moment_bubble_tips:OnLogOut()
  _InitData()
end
function logic_moment_bubble_tips:ClearRecordData()
  self:RemoveDelayShowTimer()
  cachePopTipsList = nil
  recordShowPopTipsInfo = nil
  newSquareCount = 0
  isGetSquareList = nil
end
function logic_moment_bubble_tips:ShowNewMomentCountBubbleTips(tabType, str, uidList)
  local momentMainUI = UIManager.GetUI(UIManager.UI_Config.MomentMain)
  if not momentMainUI or not momentMainUI:IsShow() then
    return
  end
  if not str or str == "" then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:ShowNewMomentCountBubbleTips str is empty, tabType = " .. tostring(tabType))
    return
  end
  local Moment_PopupTip_UIBP = UIManager.GetUI(UIManager.UI_Config.Moment_PopupTip_UIBP)
  if Moment_PopupTip_UIBP and Moment_PopupTip_UIBP:IsShow() then
    local isFind = false
    if cachePopTipsList then
      for _, v in pairs(cachePopTipsList) do
        if v.tabType == tabType then
          v.          v.          isFind = true
          break
        end
      end
    end
    if not isFind then
      if not cachePopTipsList then
        cachePopTipsList = {}
      end
      local cacheTipInfo = {
        tabType = tabType,
        str = str,
              }
      table.insert(cachePopTipsList, cacheTipInfo)
    end
    UIManager.CloseUI(UIManager.UI_Config.Moment_PopupTip_UIBP)
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Moment_PopupTip_UIBP, tabType, str, uidList)
end
function logic_moment_bubble_tips:CheckAndPopNextTips()
  if not cachePopTipsList or #cachePopTipsList <= 0 then
    return
  end
  local tipInfo = cachePopTipsList[1]
  if tipInfo.tabType and tipInfo.str then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:CheckAndPopNextTips " .. tostring(tipInfo.tabType))
    self:RemoveDelayShowTimer()
    self.delayShowNextTipTimer = self:AddTimerOnce(0.3, function()
      UIManager.ShowUI(UIManager.UI_Config.Moment_PopupTip_UIBP, tipInfo.tabType, tipInfo.str, tipInfo.uidList)
    end)
  end
  table.remove(cachePopTipsList, 1)
end
function logic_moment_bubble_tips:RemoveDelayShowTimer()
  if self.delayShowNextTipTimer then
    self:RemoveTimer(self.delayShowNextTipTimer)
    self.delayShowNextTipTimer = nil
  end
end
function logic_moment_bubble_tips:GetBubbleTipsID()
  _InitBubbleTipsConfig()
  _InitPersonalBubbleCheckCfg()
  if not allBubbleTipsConfig or #allBubbleTipsConfig <= 0 then
    return
  end
  for _, v in ipairs(allBubbleTipsConfig) do
    if v.BubbleType == Enum_BubbleTipsType.GlobalNotify and not isRemovedBubbleTips then
      if not hasClickBubbleIDList or not hasClickBubbleIDList[v.BubbleID] then
        return v.BubbleID
      end
    elseif checkPersonalTipsConfig and checkPersonalTipsConfig[v.BubbleID] and not isRemovePersonalBubble then
      local checkShowFunc = checkPersonalTipsConfig[v.BubbleID]
      if checkShowFunc() then
        return v.BubbleID
      end
    end
  end
  return nil
end
function logic_moment_bubble_tips:RemoveBubbleTips()
  isRemovedBubbleTips = true
end
function logic_moment_bubble_tips:RemovePersonalBubble(bubbleID)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:RemovePersonalBubble, bubbleID = " .. tostring(bubbleID))
  if not hasShowedBubbleIDList or not hasShowedBubbleIDList[bubbleID] then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:RemovePersonalBubble not hasShowed")
    return
  end
  isRemovePersonalBubble = true
end
function logic_moment_bubble_tips:GetBubbleTipsContent(bubbleID)
  local bubbleTipsCfg = _GetBubbleTipsCfgByBubbleID(bubbleID)
  if bubbleTipsCfg then
    local strId = bubbleTipsCfg.Content
    if strId then
      return LocUtil.GetLocalizeResStr(strId)
    end
  end
  return nil
end
function logic_moment_bubble_tips:SaveClickedBubbleIDList(bubbleIDList)
  log_tree(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:SaveClickedBubbleIDList", bubbleIDList)
  hasClickBubbleIDList = bubbleIDList
end
function logic_moment_bubble_tips:IsGlobalBubbleTips(bubbleID)
  local bubbleTipsCfg = _GetBubbleTipsCfgByBubbleID(bubbleID)
  if not (bubbleTipsCfg and bubbleTipsCfg.BubbleType) or bubbleTipsCfg.BubbleType ~= Enum_BubbleTipsType.GlobalNotify then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:IsGlobalBubbleTips not global type, bubbleID = " .. tostring(bubbleID))
    return
  end
  return true
end
function logic_moment_bubble_tips:UpdateShowBubbleTipsID(bubbleID)
  if not bubbleID then
    return
  end
  if not hasShowedBubbleIDList then
    hasShowedBubbleIDList = {}
  end
  hasShowedBubbleIDList[bubbleID] = true
end
function logic_moment_bubble_tips:UpdateIsGetSquareList()
  isGetSquareList = true
  self:PopSqureTips()
end
function logic_moment_bubble_tips:PopSqureTips()
  if newSquareCount <= 0 or not isGetSquareList then
    return
  end
  if recordShowPopTipsInfo and recordShowPopTipsInfo[Enum_ModuleIndex.square_moments] then
    return
  end
  recordShowPopTipsInfo = recordShowPopTipsInfo or {}
  recordShowPopTipsInfo[Enum_ModuleIndex.square_moments] = true
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local momentsInfo = logic_moment_data.get_square_moment_info()
  if not momentsInfo or #momentsInfo <= 0 then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:PopSqureTips momentsInfo is nil ")
    return
  end
  local uidList = {}
  for _, v in ipairs(momentsInfo) do
    if #uidList < newSquareCount then
      if _IsCanInsertUID(uidList, v.uid) then
        table.insert(uidList, v.uid)
      end
    else
      break
    end
  end
  local str = LocUtil.LocalizeResFormat(18972, newSquareCount)
  self:ShowNewMomentCountBubbleTips(moment_macro.ENUM_TAB_LIMIT_TYPE.SQUARE, str, uidList)
end
function logic_moment_bubble_tips:ReportViewInfo()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_report_view_moments_req(C_SendIndexList)
end
function logic_moment_bubble_tips:OnReportViewMomentsRsp(res, record_time)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnReportViewMomentsRsp res = " .. tostring(res) .. " record_time = " .. tostring(record_time))
end
function logic_moment_bubble_tips:ReqGetNewSquareNum()
  if recordShowPopTipsInfo and recordShowPopTipsInfo[Enum_ModuleIndex.square_moments] then
    log(bWriteLog and "[v_wllwu] send_get_new_square_moments_num_req has showed return")
    return
  end
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_get_new_square_moments_num_req()
end
function logic_moment_bubble_tips:OnGetNewSquareNumRsp(res, count)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetNewSquareNumRsp res = " .. tostring(res) .. " count = " .. tostring(count))
  if res ~= 0 then
    return
  end
  if not count or count <= 0 then
    return
  end
  newSquareCount = count
  self:PopSqureTips()
end
function logic_moment_bubble_tips:OnGetLastTimeEnterFriendTab(last_view_timestamp)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetLastTimeEnterFriendTab last_view_timestamp = " .. tostring(last_view_timestamp))
  if not last_view_timestamp or last_view_timestamp <= 0 then
    return
  end
  if recordShowPopTipsInfo and recordShowPopTipsInfo[Enum_ModuleIndex.friend_recent_moments] then
    log(bWriteLog and "[v_wllwu] OnGetLastTimeEnterFriendTab has showed return")
    return
  end
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local momentsInfo = logic_moment_data.get_fri_recent_moment_info()
  if not momentsInfo or #momentsInfo <= 0 then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetLastTimeEnterFriendTab momentsInfo is nil ")
    return
  end
  local newMomentsCount = 0
  local uidList
  for _, v in ipairs(momentsInfo) do
    if last_view_timestamp < v.post_ts then
      newMomentsCount = newMomentsCount + 1
      uidList = uidList or {}
      if _IsCanInsertUID(uidList, v.uid) then
        table.insert(uidList, v.uid)
      end
    else
      break
    end
  end
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetLastTimeEnterFriendTab newMomentsCount = " .. tostring(newMomentsCount))
  if newMomentsCount <= 0 then
    return
  end
  recordShowPopTipsInfo = recordShowPopTipsInfo or {}
  recordShowPopTipsInfo[Enum_ModuleIndex.friend_recent_moments] = true
  local str = LocUtil.LocalizeResFormat(18970, newMomentsCount)
  self:ShowNewMomentCountBubbleTips(moment_macro.ENUM_TAB_LIMIT_TYPE.FRIEND, str, uidList)
end
function logic_moment_bubble_tips:OnGetLastTimeEnterHotTab(last_view_timestamp)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetLastTimeEnterHotTab last_view_timestamp = " .. tostring(last_view_timestamp))
  if not last_view_timestamp or last_view_timestamp <= 0 then
    return
  end
  if recordShowPopTipsInfo and recordShowPopTipsInfo[Enum_ModuleIndex.hot_moments] then
    return
  end
  local logic_moment_data = require("client.slua.logic.moment.logic_moment_data")
  local momentsInfo = logic_moment_data.get_hot_moment_info()
  if not momentsInfo or #momentsInfo <= 0 then
    log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetLastTimeEnterHotTab momentsInfo is nil ")
    return
  end
  local newMomentsCount = 0
  local uidList
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, v in ipairs(momentsInfo) do
    if last_view_timestamp < v.post_ts and logic_profile:IsPlayerBanned(v.uid) == false then
      newMomentsCount = newMomentsCount + 1
      uidList = uidList or {}
      if _IsCanInsertUID(uidList, v.uid) then
        table.insert(uidList, v.uid)
      end
    end
  end
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnGetLastTimeEnterHotTab newMomentsCount = " .. tostring(newMomentsCount))
  if newMomentsCount <= 0 then
    return
  end
  recordShowPopTipsInfo = recordShowPopTipsInfo or {}
  recordShowPopTipsInfo[Enum_ModuleIndex.hot_moments] = true
  local str = LocUtil.LocalizeResFormat(18971, newMomentsCount)
  self:ShowNewMomentCountBubbleTips(moment_macro.ENUM_TAB_LIMIT_TYPE.HOT, str, uidList)
end
function logic_moment_bubble_tips:SetRemoveTips(bubble_id)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:SetRemoveTips bubble_id = " .. tostring(bubble_id))
  if not self:IsGlobalBubbleTips(bubble_id) then
    return
  end
  self:RemoveBubbleTips()
  local MomentHandler = require("client.network.Protocol.MomentHandler")
  MomentHandler.send_set_moment_bubble_req(bubble_id)
end
function logic_moment_bubble_tips:OnRemoveTipsTips(res, bubble_id)
  log(bWriteLog and "[v_wllwu] logic_moment_bubble_tips:OnRemoveTipsTips res = " .. tostring(res) .. " bubble_id = " .. tostring(bubble_id))
  if not hasClickBubbleIDList then
    hasClickBubbleIDList = {}
  end
  hasClickBubbleIDList[bubble_id] = true
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_moment_bubble_tips = class(CModuleBase, nil, logic_moment_bubble_tips)
return Clogic_moment_bubble_tips