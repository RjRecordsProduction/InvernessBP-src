local Logic_UGC_Mail = {MailList = nil}
local logic_mail = require("client.slua.logic.mail.logic_mail")
local UGCMailInfoList = {}
function Logic_UGC_Mail:OnInitialize()
end
function Logic_UGC_Mail:OnLogOut()
  self.MailList = nil
  UGCMailInfoList = nil
end
function Logic_UGC_Mail:GetUGCMessageMailCount()
  if not self.MailList or not next(self.MailList) then
    return 0
  end
  return #self.MailList
end
function Logic_UGC_Mail:GetUGCMessageMailInfoList()
  local mailInfoList = logic_mail.GetMailInfoList()
  if not mailInfoList or not next(mailInfoList) then
    log(bWriteLog and "[v_yibxu] Logic_UGC_Mail:GetUGCMessageMailInfoList  logic_mail.GetMailInfoList() = nil")
    return nil
  end
  UGCMailInfoList = {}
  local UGCMessageMailData
  for k, v in pairs(mailInfoList) do
    UGCMessageMailData = CDataTable.GetTableData("UGCMessageMailData", v.opt.cfg_id)
    if UGCMessageMailData then
      table.insert(UGCMailInfoList, {UGCMail = UGCMessageMailData, Mail = v})
    end
  end
  return UGCMailInfoList
end
function Logic_UGC_Mail:GetUGCMailListBySelectTab(selectedTab)
  local CurMailList = {}
  if not self.MailList or not next(self.MailList) then
    return nil
  end
  for k, v in pairs(self.MailList) do
    if v.UGCMail.SubTab == selectedTab then
      v.Mail.IsDefaultSelect = false
      v.UGCType = selectedTab
      table.insert(CurMailList, v.Mail)
    end
  end
  if CurMailList and 1 < #CurMailList then
    table.sort(CurMailList, function(a1, a2)
      return a1.sortIndex > a2.sortIndex
    end)
  end
  return Logic_UGC_Mail:GetMailWithDefaultSelect(CurMailList)
end
function Logic_UGC_Mail:GetMailWithDefaultSelect(mailList)
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local withAttach = {}
  local haveRead = {}
  for _, mailInfo in pairs(mailList) do
    if logic_mail_utils.hasUnRecvAttach(mailInfo) then
      table.insert(withAttach, mailInfo)
    end
    if logic_mail_utils.IsHaveRead(mailInfo) then
      table.insert(haveRead, mailInfo)
    end
  end
  if next(withAttach) then
    table.sort(withAttach, function(t1, t2)
      if t1 and t2 and t1.time and t2.time then
        return t1.time > t2.time
      end
      return false
    end)
    for _, mailInfo in pairs(mailList) do
      if withAttach[1] and mailInfo.my_id == withAttach[1].my_id then
        mailInfo.IsDefaultSelect = true
        break
      end
    end
    return mailList
  end
  if next(haveRead) then
    table.sort(haveRead, function(t1, t2)
      if t1 and t2 and t1.time and t2.time then
        return t1.time > t2.time
      end
      return false
    end)
    for _, mailInfo in pairs(mailList) do
      if haveRead[1] and mailInfo.my_id == haveRead[1].my_id then
        mailInfo.IsDefaultSelect = true
        break
      end
    end
    return mailList
  end
  log_tree(bWriteLog and "[v_yibxu] Logic_UGC_Mail:GetMailWithDefaultSelect mailList =  ", mailList)
  return mailList
end
function Logic_UGC_Mail:UGCOpenMailDetailUI(mailInfo)
  local MailItemDetail = UIManager.GetUI(UIManager.UI_Config.mail_item_detail)
  if not MailItemDetail then
    local UGC_Mine_MainPanel = UIManager.GetUI(UIManager.UI_Config.ugc_mine_main)
    if UGC_Mine_MainPanel then
      UGC_Mine_MainPanel:ShowLeftDetailUI(UIManager.UI_Config.mail_item_detail, mailInfo)
    end
  else
    EventSystem:postEvent(EVENTTYPE_MAIL, EVENTID_MAIL_REFRESH_MAIL_DETAIL, mailInfo)
  end
end
function Logic_UGC_Mail:UpdateUGCMailList()
  self.MailList = self:GetUGCMessageMailInfoList()
  local ugc_mail_reddot_data = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  ugc_mail_reddot_data.UpdateMailRedDot(self.MailList)
end
function Logic_UGC_Mail:ClearCacheData()
  UGCMailInfoList = nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogic_UGC_Mail = class(CModuleBase, nil, Logic_UGC_Mail)
return CLogic_UGC_Mail