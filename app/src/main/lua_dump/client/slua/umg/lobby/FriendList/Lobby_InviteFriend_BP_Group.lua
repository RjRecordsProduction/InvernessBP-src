local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
function Lobby_InviteFriend_BP:OnSelectTagOption(widget, data, isCheck)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local state = logic_friend_list_ui:GetState()
  if state == FLMacros.ENUM_STATE.FRIENDS_TOP then
    ShowNotice(73513)
    return
  end
  if not isCheck then
    return
  end
  self:OnClickCancelSearch(false)
  self.UIRoot.ReuseFall:ScrollToStart()
  self.List:ScrollToItem(1)
  self:OnSelectFriendTag()
  if not data or not data.data then
    return
  end
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  local buttonType = TLogEventDefine.Click_Friend_Select_Group
  local res = data.data.ID
  tlog_report_utils.ReportTLogEvent(buttonType, res)
end
function Lobby_InviteFriend_BP:OnFirstClickSelectCallBack()
  if self.bShowComboBoxGuide then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_ScreenGuid, false)
    self.bShowComboBoxGuide = false
    local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
    logic_friend_group_tools.SetHasShowDropGuide()
  end
end
function Lobby_InviteFriend_BP:OnClickSelectCallBack()
  log(bWriteLog and "Lobby_InviteFriend_BP:OnClickSelectCallBack()")
  local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
  tlog_report_utils.ReportTLogEvent(TLogEventDefine.Click_Friend_Select)
end
function Lobby_InviteFriend_BP:OnClearTagSelectCallBack()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Menu, false)
  self.UIRoot.ReuseFall:ScrollToStart()
  self.List:ScrollToItem(1)
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  logic_friend_group:ResetSelectGroupList()
  logic_friend_group:SetFoldingFirstGroup(false)
  self:SetOneTabData(true)
end
function Lobby_InviteFriend_BP:OnSelectFriendTag()
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  logic_friend_group:ResetSelectGroupList()
  logic_friend_group:SetFoldingFirstGroup(true)
  self:SetOneTabData(true)
end
function Lobby_InviteFriend_BP:RefreshTagList()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local bShow = logic_friend_list_ui:GetShowReuseFall()
  local tabID = logic_friend_list_ui:GetTabID()
  log(bWriteLog and string.format("Lobby_InviteFriend_BP:RefreshTagList %s %s", bShow, tabID))
  if not bShow or tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    self:SetWidgetVisible(self.Common_ScreenBox_UIBP, false)
    return
  end
  self:SetWidgetVisible(self.Common_ScreenBox_UIBP, true)
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  local tabID = logic_friend_list_ui:GetTabID()
  local groupData = logic_friend_group:GetFriendTagsDataByType(tabID)
  if groupData and next(groupData) then
    self.Common_ScreenBox_UIBP:SetData(groupData, 1)
  end
end
function Lobby_InviteFriend_BP:RefreshFriendList(isInit, AllData)
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local bShowReuseFall = logic_friend_list_ui:GetShowReuseFall()
  local logic_friend_group = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_group)
  local C_FriendListDataType = logic_friend_group:GetListTypeEnum()
  local tabID = logic_friend_list_ui:GetTabID()
  local data, dataType
  local bShowWow = false
  local bHasOnline = false
  if tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    data, dataType, bHasOnline = logic_friend_group:GetWOWReuseData(AllData)
    bShowWow = true
  else
    local groupID = self:GetGroupID()
    data, dataType = logic_friend_group:GetReuseData(AllData, groupID)
  end
  logic_friend_list_ui:SetFriendList(data)
  if dataType and dataType == C_FriendListDataType.PureList then
    bShowReuseFall = false
    self.UIRoot.LoopScrollBox_1.Slot:SetOffsets(FMargin(0, 58, 0, 16))
  else
    self.UIRoot.LoopScrollBox_1.Slot:SetOffsets(FMargin(0, 0, 0, 16))
  end
  local funcName = isInit and "SetData" or "RefreshAllItems"
  local subFuncName = isInit and "SetSubData" or "RefreshAllSubItems"
  self:SetWidgetVisible(self.ReuseFall, bShowReuseFall and not bShowWow)
  self:SetWidgetVisible(self.UIRoot.LoopScrollBox_1, not bShowReuseFall and not bShowWow)
  self:SetWidgetVisible(self.UIRoot.ExtendedLoopScrollGrid_1, bShowWow, true)
  if bShowReuseFall then
    self.ReuseFall:SetData(data)
    self.List:SetData({})
    self.WOWList:SetData({})
  elseif bShowWow then
    self:SetWidgetVisible(self.UIRoot.Spacer_wow, not bHasOnline)
    self.WOWList[funcName](self.WOWList, data)
    for index, itemData in ipairs(data) do
      self.WOWList[subFuncName](self.WOWList, index, itemData.friends or {})
    end
    self.List:SetData({})
    self.ReuseFall:SetData({})
  else
    local ItemCount = self.List:GetItemCount()
    if not ItemCount or ItemCount <= 0 then
      self.List:SetData(data)
    else
      self.List[funcName](self.List, data)
    end
    self.ReuseFall:SetData({})
    self.WOWList:SetData({})
  end
  if not isInit then
    log(bWriteLog and "Lobby_InviteFriend_BP:RefreshFriendList not isInit")
    return
  end
  self:ShowListBackGround(#AllData)
  if not bShowReuseFall or tabID == FLMacros.ENUM_TAB.ENUM_WOW_TAG then
    return
  end
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
  if not queryQuickFriends or not next(queryQuickFriends) then
    self:HideFriendEnableGifted()
    self.lastIndex = 0
  else
    self:RefreshEnableToGiftList()
  end
end
function Lobby_InviteFriend_BP:GetGroupID()
  local groupID = self.Common_ScreenBox_UIBP:GetSelectData().ID
  log(bWriteLog and string.format("Lobby_InviteFriend_BP:GetGroupID %s", groupID))
  return groupID or 101
end
function Lobby_InviteFriend_BP:IsFriendTagUnGroup()
  local groupID = self:GetGroupID()
  local friend_macros = require("client.slua.logic.friend.friend_macros")
  return groupID == friend_macros.E_DefaultIDType.friendDefaultID or groupID == 0
end
function Lobby_InviteFriend_BP:IsTagUnGroup()
  local groupID = self:GetGroupID()
  local friend_macros = require("client.slua.logic.friend.friend_macros")
  return groupID == friend_macros.E_DefaultIDType.friendDefaultID or groupID == 0 or groupID == friend_macros.E_DefaultIDType.recentDefaultID
end
function Lobby_InviteFriend_BP:OnSetBeforeNewListItem(index)
  local itemData = self.ReuseFall:GetItemData(index)
  local friend_macros = require("client.slua.logic.friend.friend_macros")
  local listItemType = friend_macros.E_ListItemType
  if itemData.itemType == listItemType.Title then
    self.ReuseFall:SetCurItemClass()
    self:HideFriendEnableGifted()
  elseif itemData.itemType == listItemType.Friend then
    self.ReuseFall:SetCurItemClass("friendItem")
    local groupID = self:GetGroupID()
    local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
    local tabID = logic_friend_list_ui:GetTabID()
    local friend_macros = require("client.slua.logic.friend.friend_macros")
    local FLMacros = require("client.slua.logic.friend.refactor.friend_list_macros")
    if tabID == FLMacros.ENUM_TAB.ENUM_FRIEND_TAG and groupID == friend_macros.E_DefaultIDType.friendDefaultID then
      local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
      local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
      local difindex = self.lastIndex - index
      if queryQuickFriends then
        local UIManager = require("client.slua_ui_framework.manager")
        local bQuerySend = UIManager.IsUIShow(UIManager.UI_Config.Lobby_Popup_Theme_FriendGift_UIBP)
        if bQuerySend then
          log(bWriteLog and "Lobby_InviteFriend_BP:OnSetBeforeNewListItem bQuerySend true")
        else
          self:ResortGiftList(itemData, difindex < 0)
        end
        if self:CheckEnableGifted(itemData, difindex < 0) then
          self:ShowFriendEnableGifted()
        else
          self:HideFriendEnableGifted()
        end
        if self.giftIndex + 1 < 6 then
          self.giftIndex = self.giftIndex + 1
        else
          self.giftIndex = 1
        end
        if self.lastIndex == 0 then
          self.lastIndex = 1
        else
          self.lastIndex = index
        end
      else
        self:HideFriendEnableGifted()
      end
    else
      self:HideFriendEnableGifted()
    end
  end
end
function Lobby_InviteFriend_BP:GetPlayerListSetData()
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local bShowReuseFall = logic_friend_list_ui:GetShowReuseFall()
  if bShowReuseFall then
    return self.ReuseFall:GetSetData()
  else
    return self.List:GetSetData()
  end
end
function Lobby_InviteFriend_BP:OnGetRecentInteractData()
  log(bWriteLog and "teamup_side_bar:OnGetRecentInteractData")
  local logic_friend_list_ui = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list_ui)
  local tabID = logic_friend_list_ui:GetTabID()
  if tabID ~= FLMacros.ENUM_TAB.ENUM_RECENT_TAG then
    log(bWriteLog and "teamup_side_bar:OnGetRecentInteractData not recent tag")
    return
  end
  self:SetOneTabData(true)
end