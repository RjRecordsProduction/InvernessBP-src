local MailRedPointData = {
  redDotCountName = "realCount",
  newCountName = "newCount",
  Enum_Gift_Red = {ReceiveGift = 1, AskGift = 2}
}
local redPoint
local isInited = false
local MailMacro = require("client.slua.logic.mail.mail_macro")
local GenerateData = function()
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    pages = {newCount = 0},
    desc = reddot_macro.SystemName.Mail
  }
  return data
end
local GenSubData = function()
  local data = {
    newCount = 0,
    SubTabs = {newCount = 0, isDynamic = true}
  }
  return data
end
local GenSecSubData = function()
  local data = {
    newCount = 0,
    SubSucTabs = {newCount = 0, isDynamic = true}
  }
  return data
end
local GenDefaultSubData = function(subID, redType)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local data = {
    newCount = 0,
    category = redType or reddot_macro.Category.Other,
      }
  return data
end
local InitRedData = function()
  local data = GenerateData()
  for _, tabType in pairs(MailMacro.Enum_Mail_Type) do
    data.pages[tabType] = GenSubData()
    if tabType == MailMacro.Enum_Mail_Type.GiftCenter then
      for _, subType in pairs(MailRedPointData.Enum_Gift_Red) do
        data.pages[tabType].SubTabs[subType] = GenSecSubData()
      end
    elseif tabType == MailMacro.Enum_Mail_Type.Security then
      for _, subType in pairs(MailMacro.Enum_Security_SubTabType) do
        data.pages[tabType].SubTabs[subType] = GenSecSubData()
      end
    end
  end
  return data
end
local GetTypeByMailId = function(mailID)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local mail_info = logic_mail.GetMailInfoById(mailID)
  if mail_info == nil then
    return
  end
  return mail_info.opt.type
end
local GetSubTypeByMailId = function(mailID)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local mail_info = logic_mail.GetMailInfoById(mailID)
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  return logic_mail_utils.GetSecureMailSubType(mail_info.opt.subtype)
end
local CheckIsCanAdd = function(mail_id)
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local mail_info = logic_mail.GetMailInfoById(mail_id)
  if not mail_info then
    return
  end
  if logic_mail_utils.IsPresentedCoin(mail_info) and logic_mail.receiveCoinMailLeftCount <= 0 then
    return false
  end
  return true
end
local GetCategoryWithSubId = function(mailID)
  local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local category = reddot_macro.Category.Other
  local sub_id = MailMacro.Enum_RedPoint_SubID.SysMsg
  local b_attach = false
  local mail_info = logic_mail.GetMailInfoById(mailID)
  if mail_info then
    if logic_mail_utils.IsWithAttach(mail_info) then
      b_attach = true
      category = reddot_macro.Category.Receive
    end
    if mail_info.opt.type == MailMacro.Enum_Mail_Type.System then
      sub_id = b_attach and MailMacro.Enum_RedPoint_SubID.SysMsgWithAttach or MailMacro.Enum_RedPoint_SubID.SysMsg
    elseif mail_info.opt.type == MailMacro.Enum_Mail_Type.Security then
      sub_id = b_attach and MailMacro.Enum_RedPoint_SubID.SecurityWithAttach or MailMacro.Enum_RedPoint_SubID.Security
    else
      sub_id = b_attach and MailMacro.Enum_RedPoint_SubID.MsgWithAttach or MailMacro.Enum_RedPoint_SubID.Msg
    end
  end
  return category, sub_id
end
function MailRedPointData.InitData()
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_LOBBY_MENU_MAIL) then
    log(bWriteLog and "[v_wllwu] MailRedPointData.InitData, Menu not Open")
    return
  end
  if isInited then
    return
  end
  isInited = true
  log(bWriteLog and "[v_wllwu] MailRedPointData.InitData enter")
  local reddot_manager = require("client.slua.logic.reddot.reddot_manager")
  local super_data = require("common.super_data")
  local data = InitRedData()
  redPoint = super_data.CreateSuperData(data)
  reddot_manager:Regist(redPoint)
  EventSystem:postEvent(EVENTTYPE_REDDOT, EVENTID_REDDOT_INIT_SYSTEM_SUPERDATA, BP_ENUM_MODULE_MAIL)
end
function MailRedPointData.CheckHasBeenInitialized()
  return isInited
end
function MailRedPointData.UpdateRedPointData(mailID, bAdd, bSendTlog)
  local tabType = GetTypeByMailId(mailID)
  local TableUtil = require("common.table_util")
  local redData
  if tabType == MailMacro.Enum_Mail_Type.Security then
    local subTabType = GetSubTypeByMailId(mailID)
    if subTabType == MailMacro.Enum_Security_SubTabType.SlapFace or subTabType == MailMacro.Enum_Security_SubTabType.WarningPenalty or subTabType == MailMacro.Enum_Security_SubTabType.TWarningPenalty then
      return
    end
    redData = TableUtil.GetTableValue(redPoint, "pages", tabType, "SubTabs", subTabType, "SubSucTabs")
  else
    redData = TableUtil.GetTableValue(redPoint, "pages", tabType, "SubTabs")
  end
  if not redData then
    return
  end
  if bAdd and CheckIsCanAdd(mailID) then
    local redCategory, subID = GetCategoryWithSubId(mailID)
    if not redData[mailID] then
      redData[mailID] = GenDefaultSubData(subID, redCategory)
    else
      redData[mailID].category = redCategory
      redData[mailID].    end
    redData[mailID].newCount = 1
  elseif redData[mailID] and redData[mailID].newCount and redData[mailID].newCount ~= 0 then
    if bSendTlog then
      MailRedPointData.SendRemoveTlog(redData[mailID].subID, mailID)
    end
    redData[mailID].newCount = 0
  end
end
function MailRedPointData.InitMailRedDotCount()
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local instance_list = {}
  local mailInfoList = logic_mail.GetMailInfoList()
  if mailInfoList then
    for mail_id, mail_info in pairs(mailInfoList) do
      if not logic_mail_utils.IsHaveRead(mail_info) and CheckIsCanAdd(mail_id) then
        instance_list[mail_id] = mail_info
      end
    end
  end
  MailRedPointData.RemoveNotPlayerClickMailRed(instance_list)
  if not next(instance_list) then
    return
  end
  for mail_id, _ in pairs(instance_list) do
    MailRedPointData.UpdateRedPointData(mail_id, true)
  end
end
local SendMailRedRemoveTLog = function(list, new_list)
  if not list then
    return
  end
  for k, v in pairs(list) do
    if type(v) == "table" and not new_list[k] and v.newCount and v.newCount ~= 0 then
      MailRedPointData.SendRemoveTlog(v.subID, k)
      v.newCount = 0
      log(bWriteLog and "[v_yibxu] ugc_mail_reddot_data DelReddot SendMailRedRemoveTLog mail_id = " .. k .. " newCount = 0")
    end
  end
end
function MailRedPointData.RemoveNotPlayerClickMailRed(newest_list)
  if not redPoint then
    return
  end
  newest_list = newest_list or {}
  for _, mail_type in pairs(MailMacro.Enum_Mail_Type) do
    local tabData = redPoint.pages[mail_type] or {}
    if mail_type == MailMacro.Enum_Mail_Type.GiftCenter then
    elseif mail_type == MailMacro.Enum_Mail_Type.Security then
      if tabData.SubTabs then
        for _, v in pairs(tabData.SubTabs) do
          if type(v) == "table" then
            SendMailRedRemoveTLog(v.SubSucTabs, newest_list)
          end
        end
      end
    else
      SendMailRedRemoveTLog(tabData.SubTabs, newest_list)
    end
  end
end
function MailRedPointData.SendRemoveTlog(subID, instance_key)
end
function MailRedPointData.UpdateGiftCenterRedPoint(subTabType, mailID, bAdd)
  local tabData = MailRedPointData.GetGiftCenterData()
  local TableUtil = require("common.table_util")
  local redData = TableUtil.GetTableValue(tabData, "SubTabs", subTabType, "SubSucTabs")
  if not redData then
    return
  end
  if not bAdd then
    if redData[mailID] then
      redData[mailID].newCount = 0
    end
    return
  end
  if not redData[mailID] then
    local subID = MailMacro.Enum_RedPoint_SubID.Gift
    local reddot_macro = require("client.slua.logic.reddot.reddot_macro")
    local category = reddot_macro.Category.Receive
    if subTabType == MailRedPointData.Enum_Gift_Red.AskGift then
      subID = MailMacro.Enum_RedPoint_SubID.AskFor
      category = reddot_macro.Category.Other
    end
    redData[mailID] = GenDefaultSubData(subID, category)
  end
  redData[mailID].newCount = 1
end
function MailRedPointData.AddGiftRecvRedDot(index, bShow)
  if index then
    MailRedPointData.UpdateGiftCenterRedPoint(MailRedPointData.Enum_Gift_Red.ReceiveGift, index, bShow)
  else
    MailRedPointData.ResetAllGiftRedDot(MailRedPointData.Enum_Gift_Red.ReceiveGift)
  end
end
function MailRedPointData.AddGiftAskRedDot(index, bShow)
  if index then
    MailRedPointData.UpdateGiftCenterRedPoint(MailRedPointData.Enum_Gift_Red.AskGift, index, bShow)
  else
    MailRedPointData.ResetAllGiftRedDot(MailRedPointData.Enum_Gift_Red.AskGift)
  end
end
local RemoveNotPlayerClickGiftRed = function(redType, new_list)
  local tabData = MailRedPointData.GetGiftDataByType(redType)
  if not tabData or not tabData.SubSucTabs then
    return
  end
  for instanceKey, v in pairs(tabData.SubSucTabs) do
    if type(instanceKey) == "table" and not new_list[instanceKey] and instanceKey.newCount and instanceKey.newCount ~= 0 then
      MailRedPointData.SendRemoveTlog(v.subID, instanceKey)
      instanceKey.newCount = 0
    end
  end
end
function MailRedPointData.ResetAllGiftRedDot(redType)
  if not redType then
    return
  end
  local giftSystem = require("client.slua.logic.store.logic_store_gift")
  local list = {}
  if redType == MailRedPointData.Enum_Gift_Red.AskGift then
    list = giftSystem.GetGiftBegList()
  elseif redType == MailRedPointData.Enum_Gift_Red.ReceiveGift then
    list = giftSystem.GetGiftRecvList()
  end
  local new_list = {}
  for _, v in pairs(list) do
    if v.read == 0 then
      new_list[v.index] = true
    end
  end
  RemoveNotPlayerClickGiftRed(redType, new_list)
  if not next(new_list) then
    return
  end
  for index, _ in pairs(new_list) do
    MailRedPointData.UpdateGiftCenterRedPoint(redType, index, true)
  end
end
function MailRedPointData.GetData()
  MailRedPointData.InitData()
  return redPoint
end
function MailRedPointData.GetMailDataByType(mailType)
  MailRedPointData.InitData()
  return redPoint.pages[mailType]
end
function MailRedPointData.GetSecTabTypeList()
  return MailMacro.Enum_Mail_Type
end
function MailRedPointData.GetSystemData()
  return MailRedPointData.GetMailDataByType(MailMacro.Enum_Mail_Type.System)
end
function MailRedPointData.GetFriendData()
  return MailRedPointData.GetMailDataByType(MailMacro.Enum_Mail_Type.Friend)
end
function MailRedPointData.GetMessageData()
  return MailRedPointData.GetMailDataByType(MailMacro.Enum_Mail_Type.MsgCenter)
end
function MailRedPointData.GetGiftCenterData()
  return MailRedPointData.GetMailDataByType(MailMacro.Enum_Mail_Type.GiftCenter)
end
function MailRedPointData.GetSecurityData()
  return MailRedPointData.GetMailDataByType(MailMacro.Enum_Mail_Type.Security)
end
function MailRedPointData.GetGiftRecvData()
  return MailRedPointData.GetGiftDataByType(MailRedPointData.Enum_Gift_Red.ReceiveGift)
end
function MailRedPointData.GetGiftAskData()
  return MailRedPointData.GetGiftDataByType(MailRedPointData.Enum_Gift_Red.AskGift)
end
function MailRedPointData.GetGiftDataByType(subTabType)
  MailRedPointData.InitData()
  local tabData = MailRedPointData.GetGiftCenterData()
  if tabData and tabData.SubTabs[subTabType] then
    return tabData.SubTabs[subTabType]
  end
  return nil
end
function MailRedPointData.GetSecurityDataByType(subTabType)
  MailRedPointData.InitData()
  local tabData = MailRedPointData.GetSecurityData()
  if tabData and tabData.SubTabs[subTabType] then
    return tabData.SubTabs[subTabType]
  end
  return nil
end
function MailRedPointData.OnLogin()
  MailRedPointData.InitData()
end
function MailRedPointData.OnLogout()
  redPoint = nil
  isInited = false
end
function MailRedPointData.Test()
  if redPoint then
    log_tree(bWriteLog and "[v_wllwu] MailRedPointData.Test = ", redPoint)
  end
end
return MailRedPointData