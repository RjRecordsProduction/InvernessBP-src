local logic_lobby_main_right_bottom_tab = {
  lastSaveTime = 0,
  newStatusInfo = {
    giftMsgStatus = {},
    mailMsgStatus = {}
  }
}
function logic_lobby_main_right_bottom_tab:Init()
  self.lastSaveTime = 0
  local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileName = string.format("LobbyBubble/NewMailStatusInfo")
  self.newStatusInfo = PlayerPrefs.LoadFileToTable_N(PlayerPrefs.ePlayerPrefsType.lobbyBubbleNewMailStatusInfo) or {
    giftMsgStatus = {bHasNew = false, lastNewTime = 0},
    mailMsgStatus = {bHasNew = false, lastNewTime = 0}
  }
  self.newStatusInfo.giftMsgStatus = self.newStatusInfo.giftMsgStatus or {bHasNew = false, lastNewTime = 0}
  self.newStatusInfo.mailMsgStatus = self.newStatusInfo.mailMsgStatus or {bHasNew = false, lastNewTime = 0}
  self:MailListUpdate()
end
function logic_lobby_main_right_bottom_tab:MailListUpdate()
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local mailInfoList = logic_mail.GetMailInfoList()
  if not mailInfoList or not next(mailInfoList) then
    return
  end
  for k, v in pairs(mailInfoList) do
    local mailRecvTime = tonumber(v.time) or 0
    local lastNewTime = tonumber(self.newStatusInfo.mailMsgStatus.lastNewTime) or 0
    if mailRecvTime > lastNewTime then
      self.newStatusInfo.mailMsgStatus.lastNewTime = v.time
      self.newStatusInfo.mailMsgStatus.bHasNew = true
      self.bShouldSaveToFile = true
    end
  end
end
function logic_lobby_main_right_bottom_tab:ShouldNoticeNewMail()
  if LobbySystem.CheckOpen(BP_ENUM_LOBBY_MENU_MAIL) == false then
    return false
  end
  local bHasNewGift = self:CheckNewGift()
  local bHasNewMail = self:CheckNewMail()
  return bHasNewMail or bHasNewGift
end
function logic_lobby_main_right_bottom_tab:CheckNewGift()
  local bIsInMailUI = UIManager.IsUIShow(UIManager.UI_Config.Mail_UIBP)
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  local list = giftSystem.GetGiftRecvList()
  if list and list[1] then
    local tempTime = list[1].time or 0
    if tempTime > self.newStatusInfo.giftMsgStatus.lastNewTime then
      self.bShouldSaveToFile = true
      self.newStatusInfo.giftMsgStatus.lastNewTime = tempTime
      self.newStatusInfo.giftMsgStatus.bHasNew = true
    end
  end
  list = giftSystem.GetGiftSendList()
  if list and list[1] then
    local tempTime = list[1].time or 0
    if tempTime > self.newStatusInfo.giftMsgStatus.lastNewTime then
      self.bShouldSaveToFile = true
      self.newStatusInfo.giftMsgStatus.lastNewTime = tempTime
      self.newStatusInfo.giftMsgStatus.bHasNew = true
    end
  end
  list = giftSystem.GetGiftBegList()
  if list and list[1] then
    local tempTime = list[1].time or 0
    if tempTime > self.newStatusInfo.giftMsgStatus.lastNewTime then
      self.bShouldSaveToFile = true
      self.newStatusInfo.giftMsgStatus.lastNewTime = tempTime
      self.newStatusInfo.giftMsgStatus.bHasNew = true
    end
  end
  if bIsInMailUI and self.newStatusInfo.giftMsgStatus.bHasNew then
    self.bShouldSaveToFile = true
    self.newStatusInfo.giftMsgStatus.bHasNew = false
  end
  return self.newStatusInfo.giftMsgStatus.bHasNew
end
function logic_lobby_main_right_bottom_tab:OnGetNewMail()
  self.newStatusInfo.mailMsgStatus.bHasNew = true
  local TimeUtil = require("client.common.time_util")
  self.newStatusInfo.mailMsgStatus.lastNewTime = TimeUtil.GetServerTimeInSec()
  self.bShouldSaveToFile = true
end
function logic_lobby_main_right_bottom_tab:CheckNewMail()
  local bIsInMailUI = UIManager.IsUIShow(UIManager.UI_Config.Mail_UIBP)
  self:MailListUpdate()
  local bHasNewMail = self.newStatusInfo.mailMsgStatus.bHasNew and not bIsInMailUI
  return bHasNewMail
end
function logic_lobby_main_right_bottom_tab:RemoveMailIconNewStatus()
  self:RemoveMailNewStatus()
  self:RemoveGiftMsgNewStatus()
end
function logic_lobby_main_right_bottom_tab:RemoveMailNewStatus()
  if self.newStatusInfo.mailMsgStatus and self.newStatusInfo.mailMsgStatus.bHasNew then
    self.bShouldSaveToFile = true
    self.newStatusInfo.mailMsgStatus.bHasNew = false
  end
end
function logic_lobby_main_right_bottom_tab:RemoveGiftMsgNewStatus()
  if self.newStatusInfo.giftMsgStatus and self.newStatusInfo.giftMsgStatus.bHasNew then
    self.bShouldSaveToFile = true
    self.newStatusInfo.giftMsgStatus.bHasNew = false
  end
end
function logic_lobby_main_right_bottom_tab:SaveMailIconNewStatus()
  if self.bShouldSaveToFile then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if curTime - self.lastSaveTime < 30 then
      return
    end
    log(bWriteLog and "logic_lobby_main_right_bottom_tab:SaveMailIconNewStatus - should save file now")
    local PlayerPrefs = require("client.logic.LogicPlayerPrefs.playerprefs")
    PlayerPrefs.SaveTableToFile_N(self.newStatusInfo, PlayerPrefs.ePlayerPrefsType.lobbyBubbleNewMailStatusInfo)
    self.bShouldSaveToFile = false
    self.lastSaveTime = curTime
  end
end
return logic_lobby_main_right_bottom_tab