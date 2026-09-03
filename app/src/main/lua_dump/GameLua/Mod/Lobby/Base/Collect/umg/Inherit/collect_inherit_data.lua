local collect_inherit_data = {}
local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
local CollectHandler = require("client.network.Protocol.CollectHandler")
local TimeUtil = require("client.common.time_util")
local super_data = require("common.super_data")
local UIUtil = require("client.common.ui_util")
local Logic_ItemGiveAndAskUtils = require("client.slua.logic.ItemGiveAndAsk.Logic_ItemGiveAndAskUtils")
local inheritState = {
  not_owned = -1,
  not_used = 0,
  wait_used = 1,
  using = 2,
  denied = 3,
  lifted = 4,
  out_used = 5
}
function collect_inherit_data:GetStates()
  return inheritState
end
function collect_inherit_data:ctor()
  self.inherit_datas = nil
  self.bOperationTip = true
  self.mail_list = nil
  self.inheritOwnerTimer = nil
  self.inherit_priv = 0
  self.mailType = 0
  self.bShowPopup = false
  self.vaildTime = 0
  self.mailDays = 0
  self.mailTime = 0
  self.curMail = nil
  self.bPopupJump = nil
  self.lastMailTime = nil
  self.lastMailTimer = nil
  self.limitSeasonScore = nil
  self.invite_player_collect_data = nil
end
function collect_inherit_data:DefineAndResetData()
  local self_uid = DataMgr.roleData.uid
  self.inherit_datas = super_data.CreateSuperData({
    inherit_owner = {
      owner = self_uid,
      other = "",
      state = inheritState.not_owned,
      time = nil,
      end_time = nil,
      last_build_time = nil
    },
    inherit_other = {
      owner = "",
      other = self_uid,
      state = inheritState.not_used,
      time = nil,
      end_time = nil,
      invite_list = {}
    }
  })
  local cacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectInherit) or {}
  if cacheData.bOperationTip ~= nil then
    self.bOperationTip = cacheData.bOperationTip
  end
  self.mail_list = {}
  CollectHandler.send_get_inherit_relation_req()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local info = collect_module:GetSplitTableData("CollectArgsConfig", collect_module.E_ColCfgMode.Def, "InheritInviteMailID")
  self.mailType = tonumber(info.valueCfg)
  info = collect_module:GetSplitTableData("CollectArgsConfig", collect_module.E_ColCfgMode.Def, "InheritValidDays")
  local validDays = tonumber(info.valueCfg) or 0
  self.vaildTime = validDays * 24 * 60 * 60
  info = collect_module:GetSplitTableData("CollectArgsConfig", collect_module.E_ColCfgMode.Def, "InheritInviteValidDays")
  self.mailDays = tonumber(info.valueCfg) or 0
  self.mailTime = self.mailDays * 24 * 60 * 60
  self:GetProFlieWithNotDatas()
  info = collect_module:GetSplitTableData("CollectArgsConfig", collect_module.E_ColCfgMode.Def, "InheritSeasonScoreMin")
  self.limitSeasonScore = tonumber(info.valueCfg) or 0
  log(bWriteLog and "xcc collect_inherit_data:DefineAndResetData CollectArgsConfig InheritInviteMailID " .. tostring(self.mailType))
  log(bWriteLog and "xcc collect_inherit_data:DefineAndResetData CollectArgsConfig InheritValidDays " .. tostring(self.vaildTime))
  log(bWriteLog and "xcc collect_inherit_data:DefineAndResetData CollectArgsConfig InheritInviteValidDays " .. tostring(self.mailDays))
  log(bWriteLog and "xcc collect_inherit_data:DefineAndResetData CollectArgsConfig InheritSeasonScoreMin " .. tostring(self.limitSeasonScore))
end
function collect_inherit_data:OnLogOut()
  self:RemoveInheritOwnerTimer()
  self:RemoveMailTimer()
end
function collect_inherit_data:OnDestroy()
  self:RemoveInheritOwnerTimer()
  self:RemoveMailTimer()
end
function collect_inherit_data:InitInheritOwnerTimer()
  local owner = self.inherit_datas.inherit_owner
  if owner.end_time and not self.inheritOwnerTimer and self:IsNeedTimer(owner.state) then
    local curTime = TimeUtil.GetServerTimeInSec()
    local data = TimeUtil.GetDateByUnixTime(curTime, true)
    log(bWriteLog and "xcc collect_inherit_data:InitInheritOwnerTimer state" .. tostring(owner.state))
    if owner.state ~= inheritState.wait_used then
      if owner.last_build_time then
        local preData = TimeUtil.GetDateByUnixTime(owner.last_build_time, true)
        if preData.year == data.year and preData.month == data.month then
        else
          owner.state = inheritState.not_used
          owner.other = owner.state == inheritState.out_used and owner.other or ""
          return
        end
      else
        owner.state = inheritState.not_used
        return
      end
      local days = TimeUtil.GetMonthMaxDay(data.year, data.month)
      local endTime = curTime + (days - data.day or 1) * 24 * 60 * 60 - data.hour * 60 * 60 - data.min * 60 - data.sec
      owner.end_time = endTime
    end
    log(bWriteLog and "xcc collect_inherit_data:InitInheritOwnerTimer end_time " .. tostring(TimeUtil.FormatTime_YMDHMS(owner.end_time, true)))
    local delay = owner.end_time - TimeUtil.GetServerTimeInSec() or 0
    self.inheritOwnerTimer = self:AddTimerOnce(0 <= delay and delay or 0, function()
      log(bWriteLog and "xcc collect_inherit_data:InitInheritOwnerTimer inheritOwnerTimer state" .. tostring(owner.state))
      owner.other = owner.state == inheritState.lifted and "" or owner.other
      owner.state = inheritState.not_used
    end)
  end
end
function collect_inherit_data:RemoveInheritOwnerTimer()
  if self.inheritOwnerTimer then
    self:RemoveTimer(self.inheritOwnerTimer)
    self.inheritOwnerTimer = nil
  end
end
function collect_inherit_data:RemoveMailTimer()
  if self.lastMailTimer then
    self:RemoveTimer(self.lastMailTimer)
    self.lastMailTimer = nil
  end
end
function collect_inherit_data:ReSetTimer()
  self:RemoveInheritOwnerTimer()
  self:InitInheritOwnerTimer()
end
function collect_inherit_data:InitMailTimer()
  self:RemoveMailTimer()
  local lastTime = self.lastMailTime - TimeUtil.GetServerTimeInSec()
  self.lastMailTimer = self:AddTimerOnce(0 < lastTime and lastTime or 0, function()
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_INHERIT_BUTTON_REFRESH)
  end)
end
function collect_inherit_data:SetMailTimer(uid, mailInfo)
  if self.inherit_datas.inherit_other.invite_list[tonumber(uid)] then
    if not self.lastMailTime then
      self.lastMailTime = mailInfo.time + self.mailTime
      self:InitMailTimer()
    elseif self.lastMailTime < mailInfo.time + self.mailTime then
      self.lastMailTime = mailInfo.time + self.mailTime
      self:InitMailTimer()
    end
  end
end
function collect_inherit_data:UpdateInheritDatas(bOwner, newData, bInit)
  log(bWriteLog and "xcc collect_inherit_data:UpdateInheritDatas bOwner" .. tostring(bOwner))
  log(bWriteLog and "xcc collect_inherit_data:UpdateInheritDatas bInit" .. tostring(bInit))
  log_tree("xcc collect_inherit_data:UpdateInheritDatas newData", newData)
  local inherit_data = bOwner and self.inherit_datas.inherit_owner or self.inherit_datas.inherit_other
  inherit_data.owner = (not newData.owner or newData.owner == 0) and inherit_data.owner or tostring(newData.owner)
  inherit_data.other = (not newData.other or newData.other == 0) and inherit_data.other or tostring(newData.other)
  inherit_data.time = newData.time == nil and inherit_data.time or newData.time
  inherit_data.end_time = newData.end_time == nil and inherit_data.end_time or newData.end_time
  inherit_data.invite_list = newData.invite_list == nil and inherit_data.invite_list or newData.invite_list
  if bInit then
    if bOwner and (not newData.state or newData.state < inheritState.wait_used) then
      self:UpdateByPrivilegeEndTime()
    else
      inherit_data.state = newData.state or inheritState.not_owned
    end
    if not bOwner then
      inherit_data.state = newData.state == inheritState.using and inheritState.using or inheritState.not_used
    end
    inherit_data.last_build_time = newData.last_build_time
  elseif newData.state then
    inherit_data.state = newData.state
  end
end
function collect_inherit_data:GetProFlieWithNotDatas()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local FriendIds = LogicFriend.GetFriendList(true)
  if self.inherit_datas.inherit_owner.other ~= "" then
    table.insert(FriendIds, {
      uid = tonumber(self.inherit_datas.inherit_owner.other)
    })
  end
  if self.inherit_datas.inherit_other.owner ~= "" then
    table.insert(FriendIds, {
      uid = tonumber(self.inherit_datas.inherit_other.owner)
    })
  end
  local ReqFriendIds = {}
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  for _, data in pairs(FriendIds) do
    local uid = data.uid
    local profile = logic_profile:GetLocalProfile(uid)
    if not profile or not profile.isInit then
      table.insert(ReqFriendIds, uid)
    end
  end
  log_tree("xcc collect_inherit_data:GetProFlieWithNotDatas ReqFriendIds", ReqFriendIds)
  if next(ReqFriendIds) then
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles(ReqFriendIds, function(list)
      if list and next(list) then
        log_tree("xcc collect_inherit_data:GetProFlieWithNotDatas list", list)
        EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_INHERIT_AVATAR_REFRESH)
      end
    end, Enum_PROFILE_REPORT_CFG.ROLE_INFO)
  end
end
function collect_inherit_data:SetExpireTime(inherit_priv)
  log(bWriteLog and "xcc collect_inherit_data:SetExpireTime inherit_priv" .. tostring(inherit_priv))
  self.  log(bWriteLog and "xcc collect_inherit_data:SetExpireTime self.inherit_priv" .. tostring(self.inherit_priv))
  if not self.inherit_datas.inherit_owner.state or self.inherit_datas.inherit_owner.state < inheritState.wait_used then
    self:UpdateByPrivilegeEndTime()
  end
end
function collect_inherit_data:UpdateByPrivilegeEndTime()
  log(bWriteLog and "xcc collect_inherit_data:UpdateByPrivilegeEndTime self.inherit_priv" .. tostring(self.inherit_priv))
  if self.inherit_priv and self.inherit_priv == 1 then
    self.inherit_datas.inherit_owner.state = inheritState.not_used
  else
    self.inherit_datas.inherit_owner.state = inheritState.not_owned
  end
end
function collect_inherit_data:RefreshLocalCacheData()
  local cacheData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectInherit) or {}
  cacheData.bOperationTip = self.bOperationTip
  PlayerPrefsSystem.SaveTableToFile_N(cacheData, PlayerPrefsSystem.ePlayerPrefsType.eCollectInherit)
end
function collect_inherit_data:AddInheritInvited(uid, mailInfo)
  if not uid then
    return
  end
  local mail = self.mail_list[uid]
  if mail then
    if mail.time < mailInfo.time then
      self.mail_list[uid] = mailInfo
      self:SetMailTimer(uid, mailInfo)
    end
  else
    self.mail_list[uid] = mailInfo
    self:SetMailTimer(uid, mailInfo)
  end
  if not self.bShowPopup then
    self:ShowFirstMailPopup()
  end
end
function collect_inherit_data:AddInvitedOnLine(uid, time)
  self.inherit_datas.inherit_other.invite_list[tonumber(uid)] = {begin_time = time}
end
function collect_inherit_data:RemoveInvitedOnLine(uid)
  local data = self.inherit_datas.inherit_other.invite_list[tonumber(uid)]
  if data then
    data.begin_time = false
  end
end
function collect_inherit_data:PopupJumpOut()
  self.bPopupJump = true
end
function collect_inherit_data:GetInheritInvitedCount()
  local count = 0
  for uid, info in pairs(self.inherit_datas.inherit_other.invite_list) do
    if info.begin_time then
      count = count + 1
    end
  end
  return count
end
function collect_inherit_data:CheckCanShowInheritEntrance(bGetInherit)
  if bGetInherit then
    self.inherit_datas.inherit_owner.state = inheritState.not_used
    return true
  end
  if self.inherit_datas.inherit_owner.state ~= inheritState.not_owned then
    return true
  end
  local inherit_other = self.inherit_datas.inherit_other
  if inherit_other.state == inheritState.using then
    return true
  end
  return self:GetShowFeiendMail()
end
function collect_inherit_data:CheckCanUseResourceShar()
  if UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.StoreTab) == false then
    return false
  end
  if self.inherit_datas.inherit_owner.state ~= inheritState.not_owned and self:CheckCurCollectLevel() then
    return true
  end
  local inherit_other = self.inherit_datas.inherit_other
  if inherit_other.state == inheritState.using then
    return true
  end
  return self:GetShowFeiendMail()
end
function collect_inherit_data:GetShowFeiendMail()
  local all_friend_list = Logic_ItemGiveAndAskUtils.GetAllFriendData()
  local invite_list = self.inherit_datas.inherit_other.invite_list or {}
  for key, friend in pairs(all_friend_list) do
    local uid = friend.uid
    if invite_list[uid] and invite_list[uid].begin_time and invite_list[uid].begin_time + self.mailTime > TimeUtil.GetServerTimeInSec() then
      return true, uid, self.mail_list[uid]
    end
  end
  return false
end
function collect_inherit_data:CheckCurCollectLevel()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local season = collect_module:GetSeasonId()
  local TableUtil = require("common.table_util")
  local score = TableUtil.GetTableValue(collect_module.collect_data.season_score, season) or 0
  log(bWriteLog and "xcc collect_inherit_data:CheckCurCollectLevel season" .. tostring(season))
  log(bWriteLog and "xcc collect_inherit_data:CheckCurCollectLevel score" .. tostring(score))
  return score >= self.limitSeasonScore
end
function collect_inherit_data:GetInheritData(bOwner)
  return bOwner and self.inherit_datas.inherit_owner or self.inherit_datas.inherit_other
end
function collect_inherit_data:IsNeedTimer(state)
  return state == inheritState.out_used or state == inheritState.lifted or state == inheritState.wait_used
end
function collect_inherit_data:GetInheritEndTime(bOwner)
  if bOwner then
    local state = self.inherit_datas.inherit_owner.state
    if state == inheritState.wait_used or state == inheritState.not_used then
      local curTime = TimeUtil.GetServerTimeInSec()
      return TimeUtil.FormatTime_YMD(curTime + self.vaildTime)
    else
      return TimeUtil.FormatTime_YMD(self.inherit_datas.inherit_owner.last_build_time + self.vaildTime)
    end
  else
    local state = self.inherit_datas.inherit_other.state
    if state == inheritState.wait_used then
      local time = TimeUtil.GetServerTimeInSec()
      return TimeUtil.FormatTime_YMD(time + self.vaildTime)
    else
      return TimeUtil.FormatTime_YMD(self.inherit_datas.inherit_owner.end_time)
    end
  end
end
function collect_inherit_data:GetMailOutTime()
  local curTime = TimeUtil.GetServerTimeInSec()
  local data = TimeUtil.GetDateByUnixTime(curTime, true)
  local days = TimeUtil.GetMonthMaxDay(data.year, data.month)
  local endTime = curTime + (days - data.day or 1) * 24 * 60 * 60 - data.hour * 60 * 60 - data.min * 60 - data.sec
  if endTime < curTime + self.mailTime then
    return endTime
  end
  return curTime + self.mailTime
end
function collect_inherit_data:TryGetInviteCollectData(uid)
  uid = tonumber(uid)
  if not self.invite_player_collect_data then
    self.invite_player_collect_data = {}
  end
  if not self.invite_player_collect_data[uid] then
    CollectHandler.send_get_collect_detail_req(uid, 1)
  else
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    collect_module:OnGetItemData(uid, self.invite_player_collect_data[uid])
  end
  return self.invite_player_collect_data[uid]
end
function collect_inherit_data:SetInviteCollectData(uid, data)
  if not self.invite_player_collect_data then
    self.invite_player_collect_data = {}
  end
  if self.inherit_datas.inherit_other.invite_list[uid] or tostring(uid) == self.inherit_datas.inherit_owner.owner then
    self.invite_player_collect_data[uid] = data
  end
end
function collect_inherit_data:ClearInviteCollectData()
  self.invite_player_collect_data = {}
end
function collect_inherit_data:ShowOperationTip()
  if self.bOperationTip then
    self.bOperationTip = false
    self:RefreshLocalCacheData()
    return true
  end
  return false
end
function collect_inherit_data:ShowExplainTip(widget)
  local tipsUI = UIManager.ShowUI(UIManager.UI_Config.common_float_tips)
  local TipsParam = {
    offsetX = 20,
    offsetY = 100,
    wrapWidthType = 2
  }
  local tips = LocUtil.GetLocalizeResStr(77688)
  tipsUI:SetTips(widget, tips, TipsParam, true)
end
function collect_inherit_data:ShowInheritPupupOrInvitedPage(uid, mail)
  self:GetProFlieWithNotDatas()
  local owner = self.inherit_datas.inherit_owner
  local other = self.inherit_datas.inherit_other
  local bShowOwner = true
  local bShowPrivilege = true
  if uid and uid ~= "" and mail then
    log(bWriteLog and "xcc collect_inherit_data:ShowInheritPupupOrInvitedPage mail.time " .. tostring(TimeUtil.FormatTime_YMDHMS(mail.time, true)))
    local curTime = TimeUtil.GetServerTimeInSec()
    if curTime < mail.time or curTime > mail.time + self.mailTime then
      ShowNotice(9940026)
      return
    end
    if other.state == inheritState.using then
      if tonumber(other.owner) ~= uid then
        ShowNotice(77716)
      end
    else
      if uid then
        other.owner = uid
        other.state = inheritState.wait_used
      end
      local data = self.inherit_datas.inherit_other.invite_list[tonumber(other.owner)]
      if not (data and data.begin_time) or mail and not self:CheckIsSameInvite(data.begin_time, mail.time) then
        other.state = inheritState.denied
        ShowNotice(77716)
      else
        bShowPrivilege = false
        self.curMail = mail
      end
    end
    bShowOwner = false
  elseif owner.state == inheritState.using then
  elseif other.state == inheritState.using then
    bShowOwner = false
  elseif owner.other ~= "" then
  end
  local otherUid = self.inherit_datas.inherit_other.owner
  if otherUid and otherUid ~= "" then
    CollectHandler.send_get_collect_detail_req(tonumber(otherUid), 1)
  end
  UIManager.ShowUI(UIManager.UI_Config.collect_inherit_popup_page, bShowOwner, bShowPrivilege)
end
function collect_inherit_data:ShowFirstMailPopup()
  self.bShowPopup = false
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() then
    return
  end
  local time, mail
  for uid, info in pairs(self.inherit_datas.inherit_other.invite_list) do
    local mailCache = self.mail_list[uid]
    if mailCache and info.begin_time and mailCache and not mailCache.read and self:CheckIsSameInvite(info.begin_time, mailCache.time) then
      time = mailCache.time
      mail = mailCache
    end
  end
  if mail then
    self:ShowNextMailPopup(mail)
    mail.read = true
    self.bShowPopup = true
  end
end
function collect_inherit_data:CheckIsSameInvite(begin_time, mail_time)
  if begin_time - mail_time <= 3 then
    return true
  end
  if mail_time - begin_time <= 3 then
    return true
  end
  return false
end
function collect_inherit_data:ShowNextMailPopup(mailInfo)
  local jumpInfo = {
    cancelCallback = function()
      self.bShowPopup = false
      self:ShowFirstMailPopup()
    end,
    callback = function()
      local logic_mail_utils = require("client.slua.logic.mail.logic_mail_utils")
      logic_mail_utils.JumpByMailInfo(mailInfo)
      self.bShowPopup = false
    end
  }
  local ShowUI = function(profile)
    local RightPopSystem = require("client.slua.logic.lobby_popui.logic_right_popup")
    local title = LocUtil.GetLocalizeResStr(77680)
    local content = LocUtil.LocalizeResFormat(77726, profile.nickName or profile.remarks_name)
    local nItemId = 619140001
    local uObj_itemCfg = CDataTable.GetTableData("Item", nItemId)
    local CommonItem_Utils = require("client.slua.component.item.ItemUtils.CommonItem_Utils")
    local sIconPath = CommonItem_Utils.GetIconPath(nItemId, uObj_itemCfg, nil, false, false)
    RightPopSystem.CommonPopupServerSwitch(title, content, sIconPath, uObj_itemCfg.ItemQuality, jumpInfo, 10, true)
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(mailInfo.opt.uid)
  if profile and profile.isInit then
    ShowUI(profile)
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetNormalProfiles({
      mailInfo.opt.uid
    }, function(list)
      if list and next(list) then
        local profile = list[1]
        ShowUI(profile)
      end
    end, Enum_PROFILE_REPORT_CFG.ROLE_INFO)
  end
end
function collect_inherit_data:ReOpenPopupPage()
  if self.bPopupJump then
    if self.curMail and self.curMail.opt then
      local mail = self.curMail
      self.curMail = nil
      self:ShowInheritPupupOrInvitedPage(mail.opt.uid, mail)
    else
      self:ShowInheritPupupOrInvitedPage()
    end
  end
  self.bPopupJump = false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Ccollect_inherit_data = class(CModuleBase, nil, collect_inherit_data)
return Ccollect_inherit_data