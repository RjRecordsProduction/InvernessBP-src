local Lobby_InviteFriend_BP = require("client.slua.umg.lobby.FriendList.Lobby_InviteFriend_BP_Data")
function Lobby_InviteFriend_BP:ShowFriendGift()
  local sendlist = self:CreateUidList(self.ChoseToGift)
  UIManager.ShowUI(UIManager.UI_Config.Lobby_Popup_Theme_FriendGift_UIBP, sendlist)
  local BasicDataTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataTLogReport)
  BasicDataTLogReport:ReportImmediate(TLogEventDefine.Click_Friend_Query_Gift)
end
function Lobby_InviteFriend_BP:CanShowGiftUI()
  local SingleTrainTool = require("GameLua.Mod.SingleTraining.GamePlay.Data.SingleTrainTool")
  return not SingleTrainTool.IsSelfInTraining()
end
function Lobby_InviteFriend_BP:ShowFriendEnableGifted()
  if not self:CanShowGiftUI() then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Button_Gift, true, true)
  if self.bCanShowtips then
    self:GiftTipsShow()
  end
end
function Lobby_InviteFriend_BP:HideFriendEnableGifted()
  self:SetWidgetVisible(self.UIRoot.Button_Gift, false)
  self.bCanShowtips = false
end
function Lobby_InviteFriend_BP:RefreshEnableToGiftList()
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
  local allData = self.ReuseFall:GetSetData()
  self.EnableToGiftList = {}
  local index = 1
  for i = 1, #allData do
    if queryQuickFriends and allData[i].itemType == "Friend" and queryQuickFriends[allData[i].uid] then
      self.EnableToGiftList[index] = allData[i]
      index = index + 1
    end
  end
  return self.EnableToGiftList
end
function Lobby_InviteFriend_BP:CheckEnableGifted(itemdata, bgoDown)
  local allData = self.ReuseFall:GetSetData()
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
  if queryQuickFriends and queryQuickFriends[itemdata.uid] then
    return true
  end
  local itemIndex
  for i = 1, #allData do
    if allData[i].uid == itemdata.uid then
      itemIndex = i
      break
    end
  end
  if not itemIndex then
    return false
  end
  if #allData < 5 then
    for i = 1, #allData do
      if self.EnableToGiftList[i] then
        return true
      end
    end
  end
  if bgoDown then
    for i = 1, 5 do
      local checkIndex = itemIndex - i
      if 1 <= checkIndex and queryQuickFriends and queryQuickFriends[allData[checkIndex].uid] then
        return true
      end
    end
  else
    for i = 1, 5 do
      local checkIndex = itemIndex + i
      if checkIndex <= #allData and queryQuickFriends and queryQuickFriends[allData[checkIndex].uid] then
        return true
      end
    end
  end
  return false
end
function Lobby_InviteFriend_BP:ResortGiftList(itemdata, bgoDown)
  local allData = self.EnableToGiftList
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
  local friendsMax = 5
  if 5 > logic_send_gift:GetGiftLeft() then
    friendsMax = logic_send_gift:GetGiftLeft()
    for i = 1, #self.ChoseToGift do
      if i > logic_send_gift:GetGiftLeft() then
        self.ChoseToGift[i] = nil
      end
    end
  end
  if #allData < 5 then
    local newlist = {}
    for i = 1, #allData do
      if queryQuickFriends[allData[i].uid] then
        newlist[i] = allData[i]
        if newlist[i] then
          newlist[i].bisShowIcon = false
          newlist[i].bisChosen = true
        end
      end
    end
    self.ChoseToGift = newlist
    return
  end
  local itemIndex
  for i = 1, #allData do
    if allData[i].uid == itemdata.uid then
      itemIndex = i
      break
    end
  end
  if not itemIndex then
    return
  end
  if bgoDown then
    local startIndex = math.max(1, itemIndex - 4)
    for i = 1, friendsMax do
      if queryQuickFriends[allData[i].uid] then
        self.ChoseToGift[i] = allData[startIndex + i - 1]
        if self.ChoseToGift[i] then
          self.ChoseToGift[i].bisShowIcon = false
          self.ChoseToGift[i].bisChosen = true
        end
      end
    end
  else
    local startIndex = math.min(#allData - 4, itemIndex)
    for i = 1, friendsMax do
      if queryQuickFriends[allData[i].uid] then
        self.ChoseToGift[i] = allData[startIndex + i - 1]
        if self.ChoseToGift[i] then
          self.ChoseToGift[i].bisShowIcon = false
          self.ChoseToGift[i].bisChosen = true
        end
      end
    end
  end
end
function Lobby_InviteFriend_BP:GiftTipsShow()
  local version = string.match(Client.GetAppVersion(), "%d.%d.%d")
  local logic_friend_group_tools = require("client.slua.logic.friend.logic_friend_group_tools")
  if version ~= "3.7.0" and not self.TipHasbeenSeen() then
    self.tipsUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_giftTips, UIManager.UI_Config.Common_Tips_Right_UIBP, LocUtil.GetLocalizeResStr(68651))
    self:SetWidgetVisible(self.UIRoot.Tips, true)
    self:AddTimerOnce(5, function()
      self:SetWidgetVisible(self.UIRoot.Tips, false)
    end)
  end
end
function Lobby_InviteFriend_BP.TipHasbeenSeen()
  local haveSeen = false
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local giftSendRecordTime = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eOpenTeamupSideBarGiftSendTimes)
  if not giftSendRecordTime then
    giftSendRecordTime = {}
    giftSendRecordTime.show_times = 1
    giftSendRecordTime.time_Show = currentTime
  elseif giftSendRecordTime.time_Show and TimeUtil.IsSameDay(giftSendRecordTime.time_Show, currentTime) then
    haveSeen = true
  else
    haveSeen = false
    if giftSendRecordTime.show_times < 3 then
      giftSendRecordTime.show_times = giftSendRecordTime.show_times + 1
      giftSendRecordTime.time_Show = currentTime
    else
      return true
    end
  end
  playerPrefsSystem.SaveTableToFile_N(giftSendRecordTime, playerPrefsSystem.ePlayerPrefsType.eOpenTeamupSideBarGiftSendTimes)
  log_tree("giftSendRecordTime = ", giftSendRecordTime)
  log(bWriteLog and string.format("Lobby_InviteFriend_BP:TipHasbeenSeen haveSeen = %s", haveSeen))
  return haveSeen
end
function Lobby_InviteFriend_BP:QueryQuickGiftScucess()
  self:RefreshEnableToGiftList()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local giftSendRecordTime = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eOpenTeamupSideBarGiftSendTimes)
  if giftSendRecordTime == nil then
    giftSendRecordTime = {}
    giftSendRecordTime.show_times = 4
  else
    giftSendRecordTime.show_times = 4
  end
  playerPrefsSystem.SaveTableToFile_N(giftSendRecordTime, playerPrefsSystem.ePlayerPrefsType.eOpenTeamupSideBarGiftSendTimes)
end
function Lobby_InviteFriend_BP:RefreshEnableToGiftListAndChoseToGift()
  self:RefreshEnableToGiftList()
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
  if self.EnableToGiftList and next(self.EnableToGiftList) then
    if self.ChoseToGift and next(self.ChoseToGift) and self.ChoseToGift[next(self.ChoseToGift)] ~= 0 then
      for k, v in pairs(self.ChoseToGift) do
        if not queryQuickFriends[v.uid] then
          local topIndex = self:GetTopofChoseToGift()
          self:ResortGiftList(self.ChoseToGift[topIndex], true)
          break
        end
      end
    else
    end
  else
    self:HideFriendEnableGifted()
  end
end
function Lobby_InviteFriend_BP:GetTopofChoseToGift()
  local top = 0
  local logic_send_gift = require("client.slua.logic.gift.logic_send_gift")
  local queryQuickFriends = logic_send_gift:GetQueryQuickFriends()
  for k, v in ipairs(self.ChoseToGift) do
    if queryQuickFriends[v.uid] then
      top = k
      break
    end
  end
  return top
end
function Lobby_InviteFriend_BP:CreateUidList(ChoseToGift)
  local list = {}
  for index = 1, #ChoseToGift do
    list[index] = {
      uid = ChoseToGift[index].uid,
      bisShowIcon = ChoseToGift[index].bisShowIcon,
      bisChosen = ChoseToGift[index].bisChosen
    }
  end
  return list
end