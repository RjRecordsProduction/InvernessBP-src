local mail_notify_popup = {}
local Enum_Mail_Type = {
  System = 1,
  Friend = 2,
  MsgCenter = 3,
  GiftCenter = 4,
  Security = 5
}
mail_notify_popup.
function mail_notify_popup:CheckOutLinePoppupNotify()
  log(bWriteLog and "mail_notify_popup.CheckOutLinePoppupNotify")
  if self.IsShow then
    return
  end
  self.IsShow = true
  local time_ticker = require("common.time_ticker")
  self.timer = time_ticker.AddTimerOnce(5, function()
    self:ShowOutLinePoppupNotify()
    if self.timer then
      time_ticker.RemoveTimer(self.timer)
      self.timer = nil
    end
  end)
end
function mail_notify_popup:CheckPoppupNotify(mailInfo)
  if not mailInfo or not next(mailInfo) then
    log(bWriteLog and "mail_notify_popup.CheckPoppupNotify mailInfo is nil")
    return
  end
  log(bWriteLog and "mail_notify_popup.CheckPoppupNotify")
  local mailcfg = self:CheckIsINMailNotifyPopupCfg(mailInfo.opt.cfg_id)
  if mailcfg then
    self:ShowTipsWindow(mailcfg)
    self:SaveMailPoppupNotifyData(mailInfo.opt.cfg_id, mailInfo.my_id)
  end
end
function mail_notify_popup:ReportCommercialClick(params)
  local source = params.source or 0
  local requestId = params.requestId or 0
  local str = string.format("source=%d&requestId=%d", source, requestId)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.Safe_Mail_Click_Notify_Popup, 0, str)
end
function mail_notify_popup:ShowOutLinePoppupNotify()
  local logic_ugc_mail = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_mail)
  local mailList = logic_ugc_mail:GetUGCMessageMailInfoList() or {}
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMailRightCornerNotfiyPopupData) or {}
  local showList = {}
  for k, v in pairs(mailList) do
    if not v.Mail.read then
      local mailcfg = self:CheckIsINMailNotifyPopupCfg(v.Mail.opt.cfg_id)
      if mailcfg then
        if not LoadTable[v.Mail.opt.cfg_id] then
          LoadTable[v.Mail.opt.cfg_id] = {}
        end
        if not LoadTable[v.Mail.opt.cfg_id][v.Mail.my_id] then
          if not showList[v.Mail.opt.cfg_id] then
            showList[v.Mail.opt.cfg_id] = {}
          end
          if not showList[v.Mail.opt.cfg_id].cfgData then
            showList[v.Mail.opt.cfg_id].cfgData = mailcfg
          end
          if not showList[v.Mail.opt.cfg_id].allID then
            showList[v.Mail.opt.cfg_id].allID = {}
          end
          table.insert(showList[v.Mail.opt.cfg_id].allID, v.Mail.my_id)
        end
      end
    end
  end
  if next(showList) then
    for k1, v1 in pairs(showList) do
      self:ShowTipsWindow(v1.cfgData)
      for k2, v2 in pairs(v1.allID) do
        self:SaveMailPoppupNotifyData(k1, v2)
      end
    end
  end
end
function mail_notify_popup:ShowTipsWindow(mailcfg)
  if not mailcfg then
    log(bWriteLog and "mail_notify_popup:ShowTipsWindow(mailcfg) nil return")
    return
  end
  local _tCallbackHandle = {}
  function _tCallbackHandle.callback()
    log(bWriteLog and "mail_notify_popup.CheckPoppupNotify Open Panel >>>>>>>")
    local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
    self:ReportCommercialClick({
      source = UGCMacros.ENUM_Mail_Report.Click
    })
    if mailcfg.PopStyle then
      local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
      ActivityNewSystem.JumpUrl(mailcfg.PopStyle)
    end
  end
  local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
  local sTitle = LocUtil.GetLocalizeResStr(mailcfg.Title)
  local sContent = LocUtil.GetLocalizeResStr(mailcfg.Text)
  local path = mailcfg.PicPath
  local ui_show_queue_config = require("client.common.uibase.ui_show_queue_config")
  local ConfigTab = ui_show_queue_config.GetParamTable()
  RightPopSystem.CommonPopup(ConfigTab, sTitle, sContent, path, _tCallbackHandle, 5)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  self:ReportCommercialClick({
    source = UGCMacros.ENUM_Mail_Report.Show
  })
end
function mail_notify_popup:CheckIsINMailNotifyPopupCfg(cfgID)
  local ItemCfgData = CDataTable.GetTable("UgcMailNotifyPopupCfg")
  for k, v in pairs(ItemCfgData) do
    if v.MailID == cfgID then
      return v
    end
  end
  return nil
end
function mail_notify_popup:SaveMailPoppupNotifyData(cfgID, mailmyID)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LoadTable = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMailRightCornerNotfiyPopupData) or {}
  if cfgID then
    if not LoadTable[cfgID] then
      LoadTable[cfgID] = {}
    end
    LoadTable[cfgID][mailmyID] = true
  end
  PlayerPrefsSystem.SaveTableToFile_N(LoadTable, PlayerPrefsSystem.ePlayerPrefsType.eMailRightCornerNotfiyPopupData)
end
function mail_notify_popup:ClearMailPoppupNotifyData()
end
function mail_notify_popup:OnLogOut()
  log(bWriteLog and "mail_notify_popupOnLogOut")
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Cmail_notify_popup = class(CModuleBase, nil, mail_notify_popup)
return Cmail_notify_popup