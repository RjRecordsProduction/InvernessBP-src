local local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local logic_mail_frozen_tips = {
  hasShownDataKey = PlayerPrefsSystem.ePlayerPrefsType.eMailFrozenTips
}
function logic_mail_frozen_tips:ctor()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eMailFrozenTipsSkipCondition)
  self.SkipLobbyCheck = data and data.SkipLobbyCheck
  log(bWriteLog and "logic_mail_frozen_tips.ctor" .. tostring(self.SkipLobbyCheck))
end
function logic_mail_frozen_tips:DefineAndResetData()
  log(bWriteLog and "logic_mail_frozen_tips.DefineAndResetData")
end
function logic_mail_frozen_tips:_SaveData(mailTips)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if mailTips then
    PlayerPrefsSystem.SaveTableToFile_N(mailTips, self.hasShownDataKey)
  end
end
function logic_mail_frozen_tips:_LoadData()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tmp = PlayerPrefsSystem.LoadFileToTable_N(self.hasShownDataKey)
  if tmp ~= nil then
    log(bWriteLog and "logic_mail_frozen_tips._LoadData" .. tostring(tmp.mailCfgId) .. ":" .. tostring(tmp.mailCreatedTime) .. ":" .. tostring(tmp.nextDayZeroTime))
  end
  return tmp or {}
end
function logic_mail_frozen_tips:_SortFrozenItemTips(mailList)
  table.sort(mailList, function(mail1, mail2)
    local time1 = mail1.time or 0
    local time2 = mail2.time or 0
    if time1 == time2 then
      local cfg_id1 = mail1.opt and mail1.opt.cfg_id
      local cfg_id2 = mail2.opt and mail2.opt.cfg_id
      local order1 = cfg_id1 and CDataTable.GetTableData("DebtEmailConfiguration", cfg_id1).Order or 0
      order1 = order1 or 0
      local order2 = cfg_id2 and CDataTable.GetTableData("DebtEmailConfiguration", cfg_id2).Order or 0
      order2 = order2 or 0
      return order1 > order2
    end
    return time1 > time2
  end)
end
function logic_mail_frozen_tips:_SaveLocalMail(mailInfo)
  local mailTips = {
    mailCreatedTime = mailInfo.time,
    mailCfgId = mailInfo.opt.cfg_id
  }
  self:_SaveData(mailTips)
  log(bWriteLog and "logic_mail_frozen_tips._SaveLocalMail" .. tostring(mailInfo.my_id) .. ":" .. tostring(mailInfo and mailInfo.opt and mailInfo.opt.cfg_id or nil))
end
function logic_mail_frozen_tips:_SetFrozenMailHasShown(mailInfo)
  local TimeUtil = require("client.common.time_util")
  local mailTips = self:_LoadData()
  if not mailTips or not next(mailTips) then
    log(bWriteLog and "logic_mail_frozen_tips._SetFrozenMailHasShown mailTips is empty")
    return
  end
  mailTips.nextDayZeroTime = TimeUtil.GetNextDayZeroTime()
  self:_SaveData(mailTips)
  log(bWriteLog and "[step 3]logic_mail_frozen_tips._SetFrozenMailHasShown" .. tostring(mailInfo.my_id) .. tostring(mailInfo and mailInfo.opt and mailInfo.opt.cfg_id or nil) .. "nextday:" .. tostring(mailTips.nextDayZeroTime))
end
function logic_mail_frozen_tips:_IsFrozenItemRelatedMail(mailInfo)
  local cfg_id = mailInfo.opt and mailInfo.opt.cfg_id
  if cfg_id then
    local cfg = CDataTable.GetTableData("DebtEmailConfiguration", cfg_id)
    return cfg ~= nil
  end
end
function logic_mail_frozen_tips:_IsDailyPopupMail(mailInfo)
  local cfg_id = mailInfo.opt and mailInfo.opt.cfg_id
  if cfg_id then
    local cfg = CDataTable.GetTableData("DebtEmailConfiguration", cfg_id)
    log(bWriteLog and "logic_mail_frozen_tips:_IsDailyPopupMail DailyPopup" .. tostring(cfg ~= nil and cfg.DailyPopup == 1 or false))
    return cfg ~= nil and cfg.DailyPopup == 1
  end
end
function logic_mail_frozen_tips:_IsShowLobbyMainUI()
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  return lobbyMainUI and lobbyMainUI:IsShow()
end
function logic_mail_frozen_tips:_CheckAndClose()
  if self.SkipLobbyCheck then
    return true
  end
  if GameStatus.IsInFightingNotMainCity() then
    log(bWriteLog and "logic_mail_frozen_tips lobby check is in battle")
    return false
  end
  if GameStatus.IsInMainCity() then
    log(bWriteLog and "logic_mail_frozen_tips main city check is not main city")
    return false
  end
  return true
end
function logic_mail_frozen_tips:_CheckLobbyStatus()
  if self.SkipLobbyCheck then
    return true
  end
  if not self:_IsShowLobbyMainUI() then
    log(bWriteLog and "logic_mail_frozen_tips.CanShowFace.IsShowLobbyMainUI()")
    return false
  end
  if not UIManager.IsAndroidStackEmpty() then
    log(bWriteLog and "logic_mail_frozen_tips.CanShowFace.IsLobbyEmpty() not empty")
    return false
  end
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  local toPage = Lobby_Main_Control.toPage
  local curPage = Lobby_Main_Control.curPage
  if toPage ~= ENUM_LobbyPageType.Mid or curPage ~= ENUM_LobbyPageType.Mid then
    log(bWriteLog and "logic_mail_frozen_tips lobby curPage is not middle")
    return false
  end
  log(bWriteLog and "logic_mail_frozen_tips lobby check curPage is " .. tostring(curPage))
  local NewFaceSlapSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NewFaceSlapSystem)
  if not NewFaceSlapSystem:IsSlapEnd() then
    log(bWriteLog and "logic_mail_frozen_tips.CanShowFace.IsSlapEnd() not slap end")
    if NewFaceSlapSystem:IsSlapStart() and not NewFaceSlapSystem:IsCanShow() then
      log(bWriteLog and "logic_mail_frozen_tips.CanShowFace.IsCanShow() true")
      return true
    end
    return false
  end
  return true
end
function logic_mail_frozen_tips:_CompareOrderWithLocalSaveMail(mailInfo, mailTips)
  local time1 = mailInfo.time
  if not time1 then
    log_error("logic_mail_frozen_tips:_CompareTimeWithLocalSaveMail \233\130\174\228\187\182\229\136\155\229\187\186\230\151\182\233\151\180 is nil")
    return true
  end
  local time2 = mailTips.mailCreatedTime
  if not time2 then
    log_error("logic_mail_frozen_tips:_CompareTimeWithLocalSaveMail \230\156\172\229\156\176\228\191\157\229\173\152\231\154\132\233\130\174\228\187\182\231\154\132\229\136\155\229\187\186\230\151\182\233\151\180 is nil")
    return false
  end
  log(bWriteLog and "logic_mail_frozen_tips:_CompareTimeWithLocalSaveMail time1" .. tostring(time1) .. ",time2" .. tostring(time2))
  if time1 == time2 then
    local cfg_id1 = mailInfo.opt and mailInfo.opt.cfg_id
    local cfg_id2 = mailTips.mailCfgId
    local order1 = cfg_id1 and CDataTable.GetTableData("DebtEmailConfiguration", cfg_id1).Order or 0
    order1 = order1 or 0
    local order2 = cfg_id2 and CDataTable.GetTableData("DebtEmailConfiguration", cfg_id2).Order or 0
    order2 = order2 or 0
    return order1 > order2
  end
  return time1 > time2
end
function logic_mail_frozen_tips:_HasExpired(mailInfo)
  local cfg_id = mailInfo.opt and mailInfo.opt.cfg_id
  if not cfg_id then
    log_error("logic_mail_frozen_tips:_HasExpired cfg_id is nil")
    return true
  end
  local time1 = mailInfo.time
  if not time1 then
    log_error("logic_mail_frozen_tips:_HasExpired mailInfo is nil")
    return true
  end
  local cfg = CDataTable.GetTableData("DebtEmailConfiguration", cfg_id)
  if not cfg then
    log_error("logic_mail_frozen_tips:_HasExpired cfg is nil" .. tostring(cfg_id))
    return true
  end
  if not cfg.ExpireTime then
    log_error("logic_mail_frozen_tips:_HasExpired cfg.ExpireTime is nil")
    return true
  end
  local expireTime = cfg.ExpireTime * 24 * 60 * 60
  time1 = time1 + expireTime
  local TimeUtil = require("client.common.time_util")
  local time2 = TimeUtil.GetServerTimeInSec()
  if not time2 then
    log_error("logic_mail_frozen_tips:_HasExpired serverTime time is nil")
    return true
  end
  return time1 <= time2
end
function logic_mail_frozen_tips:_HasShownMailTips(mailTips)
  local time1 = mailTips.nextDayZeroTime
  return time1 ~= nil
end
function logic_mail_frozen_tips:_HasShownMailTipsToday(mailInfo, mailTips)
  local time1 = mailTips.nextDayZeroTime
  if not time1 then
    log_error("logic_mail_frozen_tips:_HasShownMailTipsToday nextDayZeroTime is nil")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local time2 = TimeUtil.GetServerTimeInSec()
  if not time2 then
    log_error("logic_mail_frozen_tips:_HasShownMailTipsToday serverTime time is nil")
    return true
  end
  log(bWriteLog and "logic_mail_frozen_tips:_HasShownMailTipsToday isSame" .. tostring(time1 > time2))
  return time1 > time2
end
function logic_mail_frozen_tips:_IsLocalMail(mailInfo, mailTips)
  local currentMailCfgId = mailInfo.opt and mailInfo.opt.cfg_id
  if not currentMailCfgId then
    log_error("logic_mail_frozen_tips:_HasShownMailTipsToday currentMailCfgId is nil")
    return true
  end
  local localMailCfgId = mailTips.mailCfgId
  if not localMailCfgId then
    log_error("logic_mail_frozen_tips:_HasShownMailTipsToday localMailCfgId is nil")
    return false
  end
  if currentMailCfgId ~= localMailCfgId then
    return false
  end
  local time1 = mailInfo.time
  if not time1 then
    log_error("logic_mail_frozen_tips:_HasShownMailTips \233\130\174\228\187\182\229\136\155\229\187\186\230\151\182\233\151\180 is nil")
    return false
  end
  local time2 = mailTips.mailCreatedTime
  if not time2 then
    log_error("logic_mail_frozen_tips:_HasShownMailTips \230\156\172\229\156\176\228\191\157\229\173\152\231\154\132\233\130\174\228\187\182\231\154\132\229\136\155\229\187\186\230\151\182\233\151\180 is nil")
    return false
  end
  if time1 ~= time2 then
    return false
  end
  log(bWriteLog and "logic_mail_frozen_tips:_HasShownMailTips currentMailCfgId" .. tostring(currentMailCfgId) .. ",localMailCfgId" .. tostring(localMailCfgId) .. "time" .. tostring(time1))
  return true
end
function logic_mail_frozen_tips:_TryAddTipsTimer()
  local mailInfo = self:_GetMailInfoForTips()
  if mailInfo and mailInfo.my_id then
    self:_SaveLocalMail(mailInfo)
    self:_AddTipsTimer(mailInfo.my_id)
  end
end
function logic_mail_frozen_tips:_GetMailInfoForTips()
  local mailList = {}
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local mailInfoList = logic_mail.GetMailInfoList()
  if mailInfoList then
    for _, mailInfo in pairs(mailInfoList) do
      if self:_IsFrozenItemRelatedMail(mailInfo) then
        table.insert(mailList, mailInfo)
      end
    end
  end
  if #mailList <= 0 then
    return
  end
  self:_SortFrozenItemTips(mailList)
  local newestMailInfo = mailList[1]
  if not newestMailInfo then
    return
  end
  log(bWriteLog and "logic_mail_frozen_tips:newestMailInfo my_id =" .. tostring(newestMailInfo.my_id) .. ",currentMailCfgId =" .. tostring(newestMailInfo.opt and newestMailInfo.opt.cfg_id) .. "time=" .. tostring(newestMailInfo.time))
  if not self:_CanShowMailTips(newestMailInfo) then
    return
  end
  return newestMailInfo
end
function logic_mail_frozen_tips:_CanShowMailTips(mailInfo)
  if not self:_IsFrozenItemRelatedMail(mailInfo) then
    return
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  if logic_mail_utils.IsHaveRead(mailInfo) then
    log(bWriteLog and "logic_mail_frozen_tips:_CanShowMailTips IsHaveRead() true")
    return
  end
  if self:_HasExpired(mailInfo) then
    return
  end
  local mailTips = self:_LoadData()
  if not mailTips or not next(mailTips) then
    return true
  end
  if self:_IsLocalMail(mailInfo, mailTips) then
    if not self:_IsDailyPopupMail(mailInfo) then
      if self:_HasShownMailTips(mailTips) then
        log(bWriteLog and "logic_mail_frozen_tips:_CanShowMailTips HasShownMailTips() true")
        return
      end
      return true
    end
    if self:_HasShownMailTipsToday(mailInfo, mailTips) then
      return
    end
  else
    local result = self:_CompareOrderWithLocalSaveMail(mailInfo, mailTips)
    if not result then
      return
    end
  end
  return true
end
function logic_mail_frozen_tips:_ReadIfNotJumpToMail(url)
  local StringUtil = require("common.string_util")
  local params = StringUtil.ParseURLParams(url)
  log_tree(bWriteLog and "GlobalData.JumpGameUrl params:", params)
  local moduleId
  if params.module and params.module ~= "" then
    moduleId = tonumber(params.module)
  end
  if moduleId and moduleId ~= BP_ENUM_MODULE_MAIL then
    local mailId = tonumber(params.mailId)
    if not mailId then
      log_error("logic_mail_frozen_tips:_IsNotJumpToMailList mailId is nil")
    end
    if mailId then
      local logic_mail = require("client.slua.logic.mail.logic_mail")
      local mailInfo = logic_mail.GetMailInfoById(mailId)
      if not mailInfo then
        log_error("logic_mail_frozen_tips:_IsNotJumpToMailList mailInfo is nil")
      end
      if mailInfo then
        logic_mail.ReadMailInfo(mailInfo)
      end
    end
  end
end
function logic_mail_frozen_tips:_ShowFrozenMailTips(mailInfo)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local cfg_id = mailInfo.opt and mailInfo.opt.cfg_id
  if not cfg_id then
    log_error("logic_mail_frozen_tips:_ShowFrozenMailTips cfg_id is nil")
    return
  end
  local cfg = CDataTable.GetTableData("DebtEmailConfiguration", cfg_id)
  if not cfg then
    log_error("logic_mail_frozen_tips:_ShowFrozenMailTips cfg is nil" .. tostring(cfg_id))
    return
  end
  local sMsg = LocUtil.GetLocalizeResStr(cfg.ContentID)
  local sTitle = LocUtil.GetLocalizeResStr(cfg.TittleID)
  local sBtnOK = LocUtil.GetLocalizeResStr(5078)
  local sBtnCancel = LocUtil.GetLocalizeResStr(7510)
  local fClickOkCallback = function()
    if mailInfo then
      local url = cfg.JumpURL
      if url then
        local mailId = mailInfo.my_id
        if mailId then
          url = url .. "&mailId=" .. mailId
        end
        self:_ReadIfNotJumpToMail(url)
        GlobalData.JumpUrl(url)
        log(bWriteLog and "logic_mail_frozen_tips.jump:" .. tostring(url))
      end
    end
  end
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sMsg, fClickOkCallback, nil, sBtnOK, sBtnCancel)
  log(bWriteLog and "[step 4]logic_mail_frozen_tips._ShowFrozenMailTips")
end
function logic_mail_frozen_tips:_CheckMailStatusValid(mailId)
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local mailInfo = logic_mail.GetMailInfoById(mailId)
  if not mailInfo then
    log(bWriteLog and "[step 2]logic_mail_frozen_tips._GetMailInfoForTips nil")
    return
  end
  local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
  if logic_mail_utils.IsHaveRead(mailInfo) then
    return
  end
  if self:_HasExpired(mailInfo) then
    return
  end
  return mailInfo
end
function logic_mail_frozen_tips:_AddTipsTimer(mailId)
  log(bWriteLog and "[step 0]logic_mail_frozen_tips._AddTipsTimer" .. tostring(mailId))
  self:RemoveAllTimer()
  local checkStatus = function()
    if not self:_CheckAndClose() then
      self:RemoveAllTimer()
      log(bWriteLog and "[step 1]logic_mail_frozen_tips._CheckMainCityStatus closecheck")
      return
    end
    if not self:_CheckLobbyStatus() then
      log(bWriteLog and "[step 1]logic_mail_frozen_tips._CheckLobbyStatus false")
      return
    end
    local mailInfo = self:_CheckMailStatusValid(mailId)
    if not mailInfo then
      self:RemoveAllTimer()
      log(bWriteLog and "[step 5]logic_mail_frozen_tips missing mail closecheck")
      return
    end
    self:_SetFrozenMailHasShown(mailInfo)
    self:_ShowFrozenMailTips(mailInfo)
    self:RemoveAllTimer()
    log(bWriteLog and "logic_mail_frozen_tips.hasShow closecheck")
  end
  self:AddTimerLoop(1, function()
    local utility = require("common.utility")
    local excuteResult = xpcall(checkStatus, utility.ErrorMessageHandler)
    if not excuteResult then
      self:RemoveAllTimer()
      log(bWriteLog and "logic_mail_frozen_tips.exception closecheck")
    end
  end, TIMER_INFINITE, 2)
end
function logic_mail_frozen_tips:_OnNextDayZeroCome()
  log(bWriteLog and "logic_mail_frozen_tips:_OnNextDayZeroCome")
  local TimeUtil = require("client.common.time_util")
  local mailTips = self:_LoadData()
  if not mailTips or not next(mailTips) then
    return
  end
  local nextDayZeroTime = mailTips.nextDayZeroTime
  if not nextDayZeroTime then
    return
  end
  local curTime = TimeUtil.GetServerTimeInSec()
  if nextDayZeroTime < curTime then
    self:RemoveAllTimer()
    self:_TryAddTipsTimer()
  end
end
function logic_mail_frozen_tips:_OnEnterMainCity()
  if self.SkipLobbyCheck then
    return
  end
  self:RemoveAllTimer()
  log(bWriteLog and "logic_mail_frozen_tips.OnPostSwitchGameStatus:_OnEnterMainCity closecheck")
end
function logic_mail_frozen_tips:_OnLeaveMainCity()
  self:_TryAddTipsTimer()
  log(bWriteLog and "logic_mail_frozen_tips.OnPostSwitchGameStatus:_OnLeaveMainCity")
end
function logic_mail_frozen_tips:OnInitialize()
  log(bWriteLog and "logic_mail_frozen_tips.OnInitialize")
end
function logic_mail_frozen_tips:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self._OnNextDayZeroCome, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_ENTER, self._OnEnterMainCity, self)
  self:AddCommonEvent(EVENTTYPE_MAIN_CITY_LOBBY, EVENTID_MAIN_CITY_RETURN_TO_LOBBY, self._OnLeaveMainCity, self)
end
function logic_mail_frozen_tips:OnLogin(bReLogin)
  log(bWriteLog and "logic_mail_frozen_tips.OnLogin")
  self:RemoveAllTimer()
end
function logic_mail_frozen_tips:OnLogOut()
  log(bWriteLog and "logic_mail_frozen_tips.OnLogOut")
  self:RemoveAllTimer()
end
function logic_mail_frozen_tips:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_mail_frozen_tips.OnPreSwitchGameStatus")
end
function logic_mail_frozen_tips:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and "logic_mail_frozen_tips.OnPostSwitchGameStatus check status" .. tostring(preState) .. ":" .. tostring(nextState))
  if GameStatus.IsPostSwitchEnterLobbyOrMainCityFromFighting(preState, nextState) then
    log(bWriteLog and "logic_mail_frozen_tips.OnPostSwitchGameStatus IsInLobbyOrMainCity")
    self:_TryAddTipsTimer()
  elseif GameStatus.IsInFightingNotMainCity() then
    log(bWriteLog and "logic_mail_frozen_tips.OnPostSwitchGameStatus IsInFightingNotMainCity")
    self:RemoveAllTimer()
  end
end
function logic_mail_frozen_tips:OnGetMailList()
  log(bWriteLog and "logic_mail_frozen_tips.OnGetMailList")
  if not self:_CheckAndClose() then
    return
  end
  self:_TryAddTipsTimer()
end
function logic_mail_frozen_tips:OnAddNewMail(mailInfo)
  log(bWriteLog and "logic_mail_frozen_tips.OnAddNewMail")
  if not self:_CheckAndClose() then
    return
  end
  if self:_CanShowMailTips(mailInfo) then
    self:_SaveLocalMail(mailInfo)
    self:_AddTipsTimer(mailInfo.my_id)
    log(bWriteLog and "logic_mail_frozen_tips:OnAddNewMail opencheck")
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_mail_frozen_tips = class(CModuleBase, nil, logic_mail_frozen_tips)
return Clogic_mail_frozen_tips