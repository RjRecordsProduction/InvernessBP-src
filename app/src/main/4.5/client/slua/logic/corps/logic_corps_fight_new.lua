local logic_corps_fight_new = {}
local corps_class = {
  leader = 1,
  deputy = 2,
  elite = 3,
  member = 11
}
function logic_corps_fight_new:DefineAndResetData()
  self.corps_data = nil
  self.tipsShow = false
  self.isSignPk = false
end
function logic_corps_fight_new:OnPreSwitchGameStatus(preState, nextState)
end
function logic_corps_fight_new:OnPostSwitchGameStatus(preState, nextState)
end
function logic_corps_fight_new:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_CORPS, EVENTID_CORPS_FIGHT_REFRESH_LOBBYTIPS, self.RegistrationSuccessful, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_CORPS_FIGHT_POPUP, self.TryShowPopupTip, self)
end
function logic_corps_fight_new:SetCropsId(corps_data)
  self.end
function logic_corps_fight_new:SetSignPk(isSignPk)
  self.end
function logic_corps_fight_new:TryShowPopupTip()
  log(bWriteLog and "logic_corps_fight_new:TryShowPopupTip")
  if not self.corps_data then
    log_warning(bWriteLog and "logic_corps_fight_new:TryShowPopupTip not corps_data")
    return
  end
  self:ShowPopupTip(self.corps_data)
end
function logic_corps_fight_new:ShowPopupTip(JobTitle)
  log(bWriteLog and "logic_corps_fight_new:ShowPopupTip")
  if JobTitle ~= corps_class.leader and JobTitle ~= corps_class.deputy then
    log_warning(bWriteLog and "logic_corps_fight_new:ShowPopupTip not leader or deputy")
    return
  end
  local TimeTicker = require("common.time_ticker")
  local TimeUtil = require("client.common.time_util")
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local tLocalCache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.CorpsShowPopupTip) or {}
  local nLastPlayTime = tLocalCache.nLastPlayTime or 0
  local bSameDay = TimeUtil.IsSameDay(nLastPlayTime, TimeUtil.GetServerTimeInSec())
  log(bWriteLog and "logic_corps_fight_new:ShowPopupTip bSameDay = " .. tostring(bSameDay))
  if bSameDay then
    return
  end
  local logic_corps_fight = require("client.slua.logic.corps.logic_corps_fight")
  if not logic_corps_fight.GetSubscribeState() then
    tLocalCache.nLastPlayTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "logic_corps_fight_new:ShowPopupTip not Subscribe tLocalCache.nLastPlayTime = " .. tostring(tLocalCache.nLastPlayTime))
    PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.CorpsShowPopupTip)
    return
  end
  if not logic_corps_fight.CheckFightInRegister() then
    log(bWriteLog and "logic_corps_fight_new:ShowPopupTip not in register")
    return
  end
  log(bWriteLog and "logic_corps_fight_new:ShowPopupTip self.isSignPk: " .. tostring(self.isSignPk))
  if self.isSignPk then
    log(bWriteLog and "logic_corps_fight_new:ShowPopupTip already sign pk")
    return
  end
  local MatchSystem = require("client.slua.logic.match.logic_match")
  if MatchSystem.nMatchStatus == ENUM_MatchStatus.Matching then
    log(bWriteLog and "logic_corps_fight_new:ShowPopupTip Matching")
    return
  end
  local corpsMemberList = DataMgr.corpsInfo.corpsMemberList
  if not corpsMemberList or not next(corpsMemberList) then
    log(bWriteLog and "logic_corps_fight_new:ShowPopupTip send_corps_members_req")
    local CorpsHandler = require("client.network.Protocol.CorpsHandler")
    CorpsHandler.send_corps_members_req()
  end
  local callback = function()
    local confirmFunc = function()
      log(bWriteLog and "logic_corps_fight_new:ShowPopupTip Confirm")
      self.tipsShow = true
      logic_corps_fight.JoinConfrontation()
    end
    local cancelFunc = function()
      log(bWriteLog and "logic_corps_fight_new:ShowPopupTip Cancel")
    end
    local jumpInfo = {}
    jumpInfo.callback = confirmFunc
    jumpInfo.cancelCallback = cancelFunc
    local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
    local content = LocUtil.LocalizeResFormat(82230)
    RightPopSystem.ShowPopupTip(content, true, false, jumpInfo, 10)
    tLocalCache.nLastPlayTime = TimeUtil.GetServerTimeInSec()
    log(bWriteLog and "logic_corps_fight_new:ShowPopupTip tLocalCache.nLastPlayTime = " .. tostring(tLocalCache.nLastPlayTime))
    PlayerPrefsSystem.SaveTableToFile_N(tLocalCache, PlayerPrefsSystem.ePlayerPrefsType.CorpsShowPopupTip)
  end
  TimeTicker.AddTimer(1, callback)
end
function logic_corps_fight_new:RegistrationSuccessful()
  if self.tipsShow == true then
    local corp_fight = require("client.slua.logic.corps.logic_corps_fight")
    local time = LocUtil.LocalizeResFormat(23735, corp_fight.GetBeginFightRestTime())
    ShowNotice(time)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_corps_fight_new)
return CModuleTemplate