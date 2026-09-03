local logic_home_joint = {}
local home_joint_consts = require("client.slua.logic.home.Joint.config.home_joint_consts")
function logic_home_joint:DefineAndResetData()
  log(bWriteLog and "logic_home_joint:DefineAndResetData")
  self.res_joint_info = nil
  self.terminate_info_cache = nil
end
function logic_home_joint:proc_manor_joint_info_rsp(joint_info)
  log(bWriteLog and "logic_home_joint:proc_manor_joint_info_rsp")
  if IsWoWEditor then
    return
  end
  self.res_  local jointUid = self:GetMyJointMate()
  if jointUid ~= nil and self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL then
    self:TerminateInfoCache()
    local key = self.res_joint_info.state_expire_time or 1
    if self.terminate_info_cache.applyPopup ~= key and GameStatus.IsInLobbyOrMainCity() then
      UIManager.ShowUI(UIManager.UI_Config.Home_Popup_Cohabit_Invite_UIBP, jointUid)
      self:TerminateInfoCache({applyPopup = key})
    end
  end
  EventSystem:postEvent(EVENTTYPE_PLANPH_LOBBY, EVETNID_PLANPH_JOINT_INFO_UPDATE, joint_info)
end
function logic_home_joint:proc_manor_joint_invite_rsp(invitee)
  log(bWriteLog and "logic_home_joint:proc_manor_joint_invite_rsp")
  local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
  logic_chat_channel_friend.SendHomeJointInviteMsg(invitee)
  UIManager.CloseUI(UIManager.UI_Config.Home_DoubleOccupancy_Book_Popups_Small_UIBP)
  UIManager.CloseUI(UIManager.UI_Config.Home_DoubleOccupancy_Popups_UIBP)
  ShowNotice(655757)
end
function logic_home_joint:proc_manor_joint_invite_notify(inviter, master_uid)
  log(bWriteLog and "[DeanJYT] logic_home_joint:proc_manor_joint_invite_notify inviter = " .. tostring(inviter) .. ", master_uid = " .. tostring(master_uid))
  if GameStatus.IsInLobbyOrMainCity() then
    if IsWoWEditor then
      return
    end
    UIManager.ShowUI(UIManager.UI_Config.Home_Popup_Cohabit_Invite_UIBP, inviter, master_uid)
  end
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
end
function logic_home_joint:proc_manor_joint_reply_rsp(inviter, master_uid, do_joint_time)
  log(bWriteLog and "[DeanJYT] logic_home_joint:proc_manor_joint_reply_rsp inviter = " .. tostring(inviter) .. ", master_uid = " .. tostring(master_uid))
  local Home_DoubleOccupancy_Book_Popups_Small_UIBP = UIManager.GetUI(UIManager.UI_Config.Home_DoubleOccupancy_Book_Popups_Small_UIBP)
  if Home_DoubleOccupancy_Book_Popups_Small_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.Home_DoubleOccupancy_Book_Popups_Small_UIBP)
  end
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
  local Home_DoubleOccupancy_Popups_UIBP = UIManager.GetUI(UIManager.UI_Config.Home_DoubleOccupancy_Popups_UIBP)
  if not master_uid then
    if Home_DoubleOccupancy_Popups_UIBP then
      UIManager.CloseUI(UIManager.UI_Config.Home_DoubleOccupancy_Popups_UIBP)
    end
    ShowNotice(655846)
    return
  end
  ShowNotice(655901)
  if not Home_DoubleOccupancy_Popups_UIBP then
    Home_DoubleOccupancy_Popups_UIBP = UIManager.ShowUI(UIManager.UI_Config.Home_DoubleOccupancy_Popups_UIBP, inviter, tonumber(DataMgr.roleData.uid), master_uid)
    Home_DoubleOccupancy_Popups_UIBP:ShowJointSucceed(do_joint_time)
  else
    Home_DoubleOccupancy_Popups_UIBP:ShowJointSucceed(do_joint_time)
  end
  self:TerminateInfoCache({})
end
function logic_home_joint:send_manor_joint_terminate_apply_req(bForce)
  log(bWriteLog and "logic_home_joint:send_manor_joint_terminate_apply_req force = " .. tostring(bForce))
  if not bForce and self.bTerminateForce then
    log(bWriteLog and "logic_home_joint:send_manor_joint_terminate_apply_req already send force req ")
  end
  self.bTerminateForce = bForce or false
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_terminate_apply_req(bForce)
end
function logic_home_joint:proc_manor_joint_terminate_apply_rsp()
  log(bWriteLog and "logic_home_joint:proc_manor_joint_terminate_apply_rsp force = " .. tostring(self.bTerminateForce))
  if self.bTerminateForce then
    local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
    PHomeJointHandler.send_manor_joint_info_req()
    self.ShowTerminateSuccessUI()
    self:TerminateInfoCache({})
    self:IntermediateTimer()
  else
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    self:TerminateInfoCache({time = curTime})
    log(bWriteLog and "logic_home_joint:proc_manor_joint_terminate_apply_rsp cache last terminate time:" .. tostring(curTime))
    self.res_joint_info.state = self.res_joint_info.state or {}
    self.res_joint_info.state = home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPLY
    self.res_joint_info.state_expire_time = curTime + home_joint_consts.Terminate_Force_Apply_Time
    local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
    PHomeJointHandler.send_manor_joint_info_req()
    ShowNotice(655818)
    local logic_chat_channel_friend = require("client.slua.logic.lobby_chat.logic_chat_channel_friend")
    local jointUid = self:GetMyJointMate()
    local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
    if LogicFriend.IsMyFriend(jointUid) then
      logic_chat_channel_friend.SendHomeJointTerminateMsg(jointUid)
    end
  end
  if UIManager.UI_Config.Home_DoubleOccupancy_Book_Popups_Small_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.Home_DoubleOccupancy_Book_Popups_Small_UIBP)
  end
  if UIManager.UI_Config.PlanPH_Lobby_Cohabit_Main_UIBP then
    UIManager.CloseUI(UIManager.UI_Config.PlanPH_Lobby_Cohabit_Main_UIBP)
  end
end
function logic_home_joint:proc_manor_joint_terminate_apply_notify()
  log(bWriteLog and "[Dongkaizha] logic_home_joint:proc_manor_joint_terminate_apply_notify")
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  self.res_joint_info = self.res_joint_info or {}
  self.res_joint_info.state = home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL
  self.res_joint_info.state_expire_time = curTime + home_joint_consts.Terminate_Force_Apply_Time
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
  local jointUid = self:GetMyJointMate()
  if jointUid ~= nil then
    EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
  else
    log(bWriteLog and "logic_home_joint:proc_manor_joint_terminate_apply_notify failed to find the joint uid")
  end
end
function logic_home_joint:send_manor_joint_terminate_reply_req(bAgree)
  log(bWriteLog and "logic_home_joint:send_manor_joint_terminate_reply_req agree = " .. tostring(bAgree))
  if bAgree == nil then
    log(bWriteLog and "logic_home_joint:send_manor_joint_terminate_reply_req failed due to agree is nil")
    return
  end
  self.bTerminateReply = bAgree
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_terminate_reply_req(bAgree)
end
function logic_home_joint:proc_manor_joint_terminate_reply_rsp()
  log(bWriteLog and "[Dongkaizha] logic_home_joint:proc_manor_joint_terminate_reply_rsp")
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
  local noticeText = self.bTerminateReply and LocUtil.GetLocalizeResStr(655832) or LocUtil.GetLocalizeResStr(655833)
  ShowNotice(noticeText)
  if self.bTerminateReply == true then
    self.ShowTerminateSuccessUI()
    self:IntermediateTimer()
    self.res_joint_info.state = home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_DONE
  else
    self.res_joint_info.state = home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_DONE
  end
  EventSystem:postEvent(EVENTTYPE_FRIEND, EVENTID_FRIEND_APPLYLIST_CHANGE)
end
function logic_home_joint:proc_manor_joint_terminate_reply_notify(agree)
  log(bWriteLog and "[Dongkaizha] logic_home_joint:proc_manor_joint_terminate_reply_notify agree:" .. tostring(agree))
  local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
  PHomeJointHandler.send_manor_joint_info_req()
  if not self.res_joint_info then
    self.res_joint_info = {}
  end
  if agree then
    self.res_joint_info.state = home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_DONE
    self:TerminateInfoCache({})
    local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
    if PlanPH_GamePlay_Tools.IsPHomeMode() and PlanPH_GamePlay_Tools.IsManorOwner() then
      self.ShowTerminateSuccessUI()
    end
    self:IntermediateTimer()
  else
    self.res_joint_info.state = home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_REJECT
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    self.res_joint_info.state_expire_time = curTime + 99999999
  end
end
function logic_home_joint:proc_on_last_joint_manor_to_model_rsp(slot_id, expect_level)
  log(bWriteLog and "[Dongkaizha] logic_home_joint:proc_on_last_joint_manor_to_model_rsp slot_id:" .. tostring(slot_id) .. " expect_lv " .. tostring(expect_level))
  ShowNotice(66337)
  local PlanPH_Drawing_Logic = require("GameLua.Mod.PlanPH.Client.Logic.PlanPH_Drawing_Logic")
  PlanPH_Drawing_Logic.HandleEnterEditPlanMode(slot_id)
  local config = UIManager.UI_Config_InGame.PlanPH_Single_Popup_UIBP
  if config then
    UIManager.CloseUI(config)
  end
end
function logic_home_joint:GetHomeJointInfo()
  return self.res_joint_info
end
function logic_home_joint:GetMemberList()
  log(bWriteLog and "logic_home_joint:GetMemberList.")
  local manor_owner_id
  if not manor_owner_id then
    local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
    manor_owner_id = logic_home_entry.manor_owner_id
  end
  local myUid = tonumber(DataMgr.roleData.uid)
  manor_owner_id = manor_owner_id or myUid
  local manor_id = manor_owner_id
  local list = {manor_owner_id}
  local joint_uid
  if manor_owner_id == myUid then
    if self:HasJointHome() then
      if self.res_joint_info.mate_uid then
        joint_uid = self:GetMyJointMate()
      end
      if self.res_joint_info.joint_id then
        manor_id = self.res_joint_info.joint_id
      end
    end
  elseif self.res_joint_info and self.res_joint_info.mate_uid == manor_owner_id then
    joint_uid = myUid
    if self.res_joint_info.joint_id then
      manor_id = self.res_joint_info.joint_id
    end
  else
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local memberList = logic_home_profile:GetHomeJointMemberList(manor_owner_id) or {manor_owner_id}
    local profile = logic_home_profile:GetHomeProfileByUid(manor_owner_id)
    if profile and profile.joint_id then
      manor_id = profile.joint_id
    end
    return memberList, manor_id
  end
  log(bWriteLog and "logic_home_joint:GetMemberList. joint_uid = " .. tostring(joint_uid) .. ", manor_id = " .. tostring(manor_id))
  if joint_uid then
    table.insert(list, joint_uid)
  end
  return list, manor_id
end
function logic_home_joint:GetMemberListByUid(manor_owner_id, callback)
  log(bWriteLog and string.format("logic_home_joint:GetMemberListByUid. manor_owner_id=%s, callback=%s", tostring(manor_owner_id), tostring(callback)))
  if not manor_owner_id or not callback then
    log(bWriteLog and "logic_home_joint:GetMemberListByUid. manor_owner_id is nil or callback is nil")
    return
  end
  local myUid = tonumber(DataMgr.roleData.uid)
  local manor_id = manor_owner_id
  local list = {manor_owner_id}
  local joint_uid
  if manor_owner_id == myUid then
    if self:HasJointHome() then
      if self.res_joint_info.mate_uid then
        joint_uid = self:GetMyJointMate()
      end
      if self.res_joint_info.joint_id then
        manor_id = self.res_joint_info.joint_id
      end
    end
  elseif self.res_joint_info and self.res_joint_info.mate_uid == manor_owner_id then
    joint_uid = myUid
    if self.res_joint_info.joint_id then
      manor_id = self.res_joint_info.joint_id
    end
  else
    local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
    local handleFunc = function()
      local profile = logic_home_profile:GetHomeProfileByUid(manor_owner_id)
      log_tree("logic_home_joint:GetMemberListByUid. profile = ", profile)
      local memberList = logic_home_profile:GetHomeJointMemberList(manor_owner_id) or {manor_owner_id}
      if profile.joint_id then
        manor_id = profile.joint_id
      end
      log(bWriteLog and "logic_home_joint:GetMemberListByUid. manor_id = " .. tostring(manor_id))
      log_tree("logic_home_joint:GetMemberListByUid. memberList = ", memberList)
      callback(manor_id, memberList)
    end
    logic_home_profile:GetOrReqHomeProfile({manor_owner_id}, handleFunc, true)
    return
  end
  log(bWriteLog and "logic_home_joint:GetMemberListByUid. joint_uid = " .. tostring(joint_uid) .. ", manor_id = " .. tostring(manor_id))
  if joint_uid then
    table.insert(list, joint_uid)
  end
  callback(manor_id, list)
end
function logic_home_joint:GetMyJointMate()
  local myUid = tonumber(DataMgr.roleData.uid)
  if myUid and self.res_joint_info then
    if myUid ~= tonumber(self.res_joint_info.master_uid) then
      return tonumber(self.res_joint_info.master_uid)
    end
    if myUid ~= tonumber(self.res_joint_info.mate_uid) then
      return tonumber(self.res_joint_info.mate_uid)
    end
  end
  return nil
end
function logic_home_joint:IsJointHomeTerminating()
  local state = self.res_joint_info.state
  if state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPLY then
  elseif state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL then
  elseif state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_REJECT then
  else
    return false
  end
  return true
end
function logic_home_joint:HasJointHomeTerminated()
  if not self.res_joint_info then
    return nil
  end
  local bUsedToJoint = self.res_joint_info and self.res_joint_info.last_joint_time
  local bHasTerminated = self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_OTHER_TERMINATE
  bHasTerminated = bHasTerminated or self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_DONE
  bHasTerminated = bHasTerminated or self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_WAIT
  bHasTerminated = bHasTerminated or self.res_joint_info.state == 0
  bHasTerminated = bHasTerminated or self.res_joint_info.state == nil
  return bUsedToJoint and bHasTerminated
end
function logic_home_joint:IsJointHomeForceTerminating()
  local state = self.res_joint_info.state
  if not state then
    log(bWriteLog and "logic_home_joint:IsJointHomeForceTerminating failed due to nil state")
    return false
  end
  local bState = state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_REJECT
  local bTime = true
  if self.res_joint_info.state_expire_time then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    bTime = curTime <= self.res_joint_info.state_expire_time
  end
  return bState and bTime
end
function logic_home_joint:GetForceTerminateTime(bFormat)
  if not self:IsJointHomeForceTerminating() then
    return nil
  else
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local diff = self.res_joint_info.state_expire_time - curTime
    if bFormat then
      return TimeUtil.FormatCountDownTime_DH_or_HMS(diff, true)
    end
    return bFormat
  end
end
function logic_home_joint:HasJointHome()
  if not self.res_joint_info then
    return false
  end
  local state = self.res_joint_info.state
  if state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_DONE then
    return true
  end
  if self:IsJointHomeTerminating() then
    return true
  end
  return false
end
function logic_home_joint:IsJointMateEditing()
  local PlanPH_ManorData_Client = SubsystemMgr:Get("PlanPH_ManorData_Client")
  local list = PlanPH_ManorData_Client:GetAllEditHomePlayerList()
  for _, uid in pairs(list) do
    if uid == self.res_joint_info.mate_uid then
      return true
    end
  end
  return false
end
function logic_home_joint:IsIntermediateState(bApply, bTerminate)
  if not self.res_joint_info or not self.res_joint_info.state then
    log(bWriteLog and "logic_home_joint:IsIntermediateState failed due to nil joint state info")
    return false
  end
  log(bWriteLog and "logic_home_joint:IsIntermediateState state" .. tostring(state))
  bApply = bApply or true
  bTerminate = bTerminate or true
  local state = self.res_joint_info.state
  local bA = bApply and state >= home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_WAIT and state < home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_DONE
  local bT = bTerminate and state >= home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_CONSULT and state < home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_DONE
  return bA or bT
end
function logic_home_joint:IntermediateTimer(bRemove)
  log(bWriteLog and "logic_home_joint:IntermediateTimer")
  local timer_ticker = require("common.time_ticker")
  if self.interTimer then
    timer_ticker.RemoveTimer(self.interTimer)
    self.interTimer = nil
  end
  if not bRemove then
    self.interTimer = timer_ticker.AddTimerOnce(75, function()
      log(bWriteLog and "logic_home_joint:IntermediateTimer: send joint info req")
      local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
      PHomeJointHandler.send_manor_joint_info_req()
      local logic_home_profile = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_profile)
      logic_home_profile:GetOrReqHomeProfile({
        DataMgr.roleData.uid
      }, nil, true)
    end)
  end
end
function logic_home_joint:TerminateInfoCache(terminate_info)
  log_tree("[dongkaizha]logic_home_joint:TerminateInfoCache", terminate_info)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if terminate_info == nil then
    if not self.terminate_info_cache then
      self.terminate_info_cache = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeJointTerminateInfo) or {}
    end
    return self.terminate_info_cache
  else
    if self.terminate_info_cache == terminate_info then
      return self.terminate_info_cache
    end
    self.terminate_info_cache = terminate_info
    PlayerPrefsSystem.SaveTableToFile_N(self.terminate_info_cache, PlayerPrefsSystem.ePlayerPrefsType.eHomeJointTerminateInfo)
  end
  return self.terminate_info_cache
end
function logic_home_joint:IsTerminateRejected()
  if not self.res_joint_info then
    log(bWriteLog and "logic_home_joint:IsTerminateRejected failed because joint info is nil")
    return false
  end
  if self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_REJECT then
    local lastApplyTime = self:TerminateInfoCache().time
    if lastApplyTime then
      local OutOfDateTime = lastApplyTime + home_joint_consts.Terminate_Reply_Limit_Time + home_joint_consts.Terminate_Force_Apply_Time
      return OutOfDateTime >= self.res_joint_info.state_expire_time
    end
  end
  return false
end
function logic_home_joint:GetJointOrTerminateApplications(bIncludeInValid)
  return self:HasJointHome() and self:GetTerminateApplications(bIncludeInValid) or self:GetJointApplications(bIncludeInValid)
end
function logic_home_joint:GetJointApplications(bIncludeInValid)
  if not LobbySystem.CheckOpen(BP_ENUM_MODULE_PLANPH_HOME_COHABIT) then
    log(bWriteLog and "[DeanJYT] logic_home_joint:GetJointApplications switch not open")
    return {}
  end
  if bIncludeInValid == nil then
    bIncludeInValid = false
  end
  if not self.res_joint_info or not self.res_joint_info.inviter_list then
    return {}
  end
  local result = {}
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  for k, v in pairs(self.res_joint_info.inviter_list) do
    local relation = LogicFriend.GetRelation(k)
    local intimacy = LogicFriend.GetInnerFriendIntimacy(tonumber(k))
    local minIntimacy = 0
    local cfg = CDataTable.GetTableData("JointParamCfg", "manor_joint_lower_intimacy")
    if cfg and cfg.Value then
      minIntimacy = tonumber(cfg.Value) or 0
    end
    if intimacy >= minIntimacy and relation and LogicFriend.IsMyFriend(k) and (bIncludeInValid or curTime <= v.expire_time) then
      result[#result + 1] = {
        fromId = k,
        masterUid = v.master_uid
      }
    end
  end
  return result
end
function logic_home_joint:GetTerminateApplications(bIncludeInValid)
  bIncludeInValid = bIncludeInValid or false
  if not self.res_joint_info then
    log_warning(bWriteLog and "logic_home_joint:GetTernimateApplications: return nil due to invalid joint info")
    return {}
  end
  local result = {}
  local state = self.res_joint_info.state
  if state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL then
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    local bValid = self.res_joint_info.state_expire_time and curTime <= self.res_joint_info.state_expire_time
    if bIncludeInValid or bValid then
      result[#result + 1] = {
        fromId = self:GetMyJointMate()
      }
    end
  else
    log(bWriteLog and "logic_home_joint:GetTernimateApplications return nil due to joint state not approval: " .. tostring(state))
    return {}
  end
  return result
end
function logic_home_joint:GetInviteInfoByInviterUid(uid)
  if not self.res_joint_info or not self.res_joint_info.inviter_list then
    return nil
  end
  local data = self.res_joint_info.inviter_list[uid]
  if not data then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime > data.expire_time then
    return nil
  end
  return {
    inviterUid = uid,
    masterUid = data.master_uid
  }
end
function logic_home_joint:ShowJointMainUI()
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  if PlanPH_GamePlay_Tools.IsPHomeMode() then
    local PlanPH_Common_UI_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Common_UI_Tools")
    if PlanPH_Common_UI_Tools and PlanPH_Common_UI_Tools.IsConflictVisit() then
      log(bWriteLog and "PlanPH_Feature_Item_UIBP.OnClickFeatureButton() failed due to confict")
      return
    end
  end
  log(bWriteLog and "[dongkaizha] logic_home_joint:ShowJointMainUI")
  local LastTerminateInfo = self:TerminateInfoCache()
  if self:IsJointHomeForceTerminating() then
    if not LastTerminateInfo.force then
      self.ShowTerminateForceUI(true)
      LastTerminateInfo.force = true
      self:TerminateInfoCache(LastTerminateInfo)
    end
  elseif LastTerminateInfo and LastTerminateInfo.time and self.res_joint_info and self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_DONE then
    local bIsReject = self:IsTerminateRejected() or false
    self.ShowTerminateFailureUI(bIsReject)
    self:TerminateInfoCache({})
  end
  if IsEditor then
    local UIConfig = require("GameLua.Mod.PlanPH.Client.Config.UIConfig")
    if not UIManager.UI_Config_InGame or not next(UIManager.UI_Config_InGame) then
      UIManager.UI_Config_InGame = UIConfig.UIConfig
    end
  end
  if UIManager.UI_Config_InGame.PlanPH_Cohabit_Main_UIBP then
    UIManager.ShowUI(UIManager.UI_Config_InGame.PlanPH_Cohabit_Main_UIBP)
  end
end
function logic_home_joint:ShowTerminateInfo(bAllowApply, retry)
  if not self:GetHomeJointInfo() then
    log(bWriteLog and "logic_home_joint:ShowTerminateInfo res info is nil trying to req, retry: " .. tostring(retry))
    retry = retry or 3
    if retry and retry <= 0 then
      return
    end
    local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
    PHomeJointHandler.send_manor_joint_info_req()
    self.res_joint_info = {state = 0}
    local timer_ticker = require("common.time_ticker")
    timer_ticker.AddTimer(0.5, function()
      self:ShowTerminateInfo(bAllowApply, retry - 1)
    end)
    return
  end
  if self:IsJointHomeForceTerminating() then
    self.ShowTerminateForceUI(true)
    self:TerminateInfoCache(LastTerminateInfo)
    return
  end
  local LastTerminateInfo = self:TerminateInfoCache()
  if LastTerminateInfo and LastTerminateInfo.time and self.res_joint_info.state ~= home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPLY and self.res_joint_info.state ~= home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL then
    local bIsReject = self:IsTerminateRejected() or false
    self.ShowTerminateFailureUI(bIsReject)
    self:TerminateInfoCache({})
  end
  if self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPLY then
    ShowNotice(19810249)
  elseif self.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL then
    if bAllowApply then
      ShowNotice(19810249)
    else
      local PlanPH_Download_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Download_Tools")
      local bODPAKDownloaded = PlanPH_Download_Tools.CheckHomeODPAKDownloadReady()
      log(bWriteLog and string.format("logic_home_joint:ShowTerminateInfo APPROVAL ODPAK check, bODPAKDownloaded=%s", tostring(bODPAKDownloaded)))
      if not bODPAKDownloaded then
        ShowNotice(817403)
        return
      end
      self.ShowTerminateMainUI(false)
    end
  elseif bAllowApply then
    local PlanPH_Download_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_Download_Tools")
    local bODPAKDownloaded = PlanPH_Download_Tools.CheckHomeODPAKDownloadReady()
    log(bWriteLog and string.format("logic_home_joint:ShowTerminateInfo else ODPAK check, bODPAKDownloaded=%s", tostring(bODPAKDownloaded)))
    if not bODPAKDownloaded then
      ShowNotice(817403)
      return
    end
    self.ShowTerminateMainUI(true)
  else
    ShowNotice(15111)
  end
end
function logic_home_joint.ShowTerminateMainUI(bIsSender)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  if not logic_home_joint:GetHomeJointInfo() then
    local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
    PHomeJointHandler.send_manor_joint_info_req()
  end
  local childBuildData = {}
  childBuildData.callBackYes = logic_home_joint.ShowTerminateYesUI
  childBuildData.callBackNo = bIsSender and logic_home_joint.CloseTerminateMainUI or logic_home_joint.ShowTerminateNoUI
  childBuildData.Texts = {
    Yes = LocUtil.GetLocalizeResStr(655812),
    No = bIsSender and LocUtil.GetLocalizeResStr(7510) or LocUtil.GetLocalizeResStr(12718),
    Rule = LocUtil.GetLocalizeStrConcatenation(655808),
    CheckBox = LocUtil.GetLocalizeResStr(655811)
  }
  local tabList = {
    {
      tabName = 655809,
      index = 1,
      UIConfig = UIManager.UI_Config.PlanPH_Cohabit_ReleaseRule_UIBP,
      extraData = childBuildData
    }
  }
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  PufferMapManager:MountMapPak("map_planph_3")
  UIManager.ShowUI(UIManager.UI_Config.PlanPH_Lobby_Cohabit_Main_UIBP, tabList)
end
function logic_home_joint.CloseTerminateMainUI()
  UIManager.CloseUI(UIManager.UI_Config.PlanPH_Lobby_Cohabit_Main_UIBP)
end
function logic_home_joint.ShowTerminateYesUI()
  log(bWriteLog and "[dongkaizha] logic_home_joint.ShowTerminateYesUI")
  UIManager.CloseUI(UIManager.UI_Config.PlanPH_Lobby_Cohabit_Main_UIBP)
  local logic_home_joint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local toId = logic_home_joint:GetMyJointMate()
  if not toId then
    if not logic_home_joint.res_joint_info then
      log(bWriteLog and "logic_home_joint.ShowTerminateYesUI: failed because of nil joint info")
      ShowNotice(49283)
      local PHomeJointHandler = require("client.network.Protocol.PHomeJointHandler")
      PHomeJointHandler.send_manor_joint_info_req()
    else
      log(bWriteLog and "logic_home_joint.ShowTerminateYesUI: failed because of nil joint id")
      ShowDevNotice("###\230\151\160\229\144\140\228\189\143\230\136\150\229\144\140\228\189\143\229\183\178\232\167\163\233\153\164")
    end
    return
  end
  local fromId = tonumber(DataMgr.roleData.uid)
  if logic_home_joint.res_joint_info.state == home_joint_consts.E_Manor_Joint_States.MANOR_JOINT_STATE_TERMINATE_APPROVAL then
    fromId, toId = toId, fromId
  end
  UIManager.ShowUI(UIManager.UI_Config.Home_DoubleOccupancy_Book_Popups_Small_UIBP, fromId, toId)
end
function logic_home_joint.ShowTerminateForceUI(bIsReject)
  log(bWriteLog and "[dongkaizha] logic_home_joint.ShowTerminateForceUI bIsReject:" .. tostring(bIsReject))
  if bIsReject == nil then
    bIsReject = false
  end
  local TimeUtil = require("client.common.time_util")
  local text = bIsReject and LocUtil.GetLocalizeResStr(655823) or LocUtil.LocalizeResFormat(655821, TimeUtil.FormatCountDownTime_HMS(home_joint_consts.Terminate_Reply_Limit_Time))
  local tmpConfig = {
    title = LocUtil.GetLocalizeResStr(655826),
    msg = text,
    dynamicNotice = function()
      local LogicHomeJoint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
      return LogicHomeJoint:GetForceTerminateTime(true) or ""
    end,
    clickOkCallback = function()
      local LogicHomeJoint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
      LogicHomeJoint:send_manor_joint_terminate_apply_req(true)
      LogicHomeJoint.CloseTerminateMainUI()
    end,
    clickCancelCallback = function()
    end,
    type = 2
  }
  local config = UIManager.UI_Config.PlanPH_Lobby_Common_Popups_Small_UIBP
  if config then
    UIManager.ShowUI(config, tmpConfig)
  else
    log(bWriteLog and "logic_home_joint.ShowTerminateForceUI failed to show due to nil config")
  end
end
function logic_home_joint.ShowTerminateFailureUI(bIsReject)
  log(bWriteLog and "[dongkaizha] logic_home_joint.ShowTerminateFailureUI bIsReject:" .. tostring(bIsReject))
  local TimeUtil = require("client.common.time_util")
  local LogicHomeJoint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
  local lastApplyTime = tonumber(LogicHomeJoint:TerminateInfoCache().time)
  local TerminateReactTime = lastApplyTime and TimeUtil.GetServerTimeInSec() - lastApplyTime or 0
  if TerminateReactTime <= 0 then
    log(bWriteLog and "logic_home_joint.ShowTerminateFailureUI invalid react time")
    TerminateReactTime = home_joint_consts.Terminate_Force_Apply_Time
  end
  local text = bIsReject and LocUtil.GetLocalizeResStr(655824) or LocUtil.LocalizeResFormat(655822, TimeUtil.FormatCountDownTime_HMS2(home_joint_consts.Terminate_Force_Apply_Time))
  local tmpConfig = {
    title = LocUtil.GetLocalizeResStr(655826),
    msg = text,
    type = 1
  }
  local config = UIManager.UI_Config.PlanPH_Lobby_Common_Popups_Small_UIBP
  if config then
    UIManager.ShowUI(config, tmpConfig)
  else
    log(bWriteLog and "logic_home_joint.ShowTerminateFailureUI failed to show due to nil config")
  end
end
function logic_home_joint.ShowTerminateSuccessUI()
  log(bWriteLog and "[dongkaizha] logic_home_joint.ShowTerminateSuccessUI")
  local showMsg = LocUtil.GetLocalizeResStr(655819)
  local PlanPH_GamePlay_Tools = require("GameLua.Mod.PlanPH.Tools.PlanPH_GamePlay_Tools")
  local bIsVisiter = PlanPH_GamePlay_Tools.IsPHomeMode() and not PlanPH_GamePlay_Tools.IsManorOwner()
  if bIsVisiter then
    showMsg = LocUtil.GetLocalizeResStr(655893)
  end
  local logic_home_entry = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_entry)
  local tmpConfig = {
    title = LocUtil.GetLocalizeResStr(655812),
    msg = showMsg,
    notice = LocUtil.GetLocalizeResStr(655820),
    type = 1,
    clickOkCallback = function(...)
      if logic_home_entry:IsPlanPHMode() then
        UnrealNet.RetrunToLobbyFromDisconnect(false)
      end
    end
  }
  local config = UIManager.UI_Config.PlanPH_Lobby_Common_Popups_Small_UIBP
  UIManager.ShowUI(config, tmpConfig)
end
function logic_home_joint.ShowTerminateNoUI()
  local TimeUtil = require("client.common.time_util")
  local tmpConfig = {
    title = LocUtil.GetLocalizeResStr(655826),
    msg = LocUtil.LocalizeResFormat(655830, TimeUtil.FormatCountDownTime_HMS2(home_joint_consts.Terminate_Force_Apply_Time)),
    btnOK = LocUtil.GetLocalizeResStr(655831),
    btnCancel = LocUtil.GetLocalizeResStr(110035),
    clickOkCallback = function()
      local LogicHomeJoint = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_home_joint)
      LogicHomeJoint:send_manor_joint_terminate_reply_req(false)
      LogicHomeJoint.CloseTerminateMainUI()
    end,
    clickCancelCallback = function()
    end,
    type = 2
  }
  local config = UIManager.UI_Config.PlanPH_Lobby_Common_Popups_Small_UIBP
  if config then
    UIManager.ShowUI(config, tmpConfig)
  else
    log(bWriteLog and "logic_home_joint.ShowTerminateNoUI failed to show due to nil config")
  end
end
function logic_home_joint:NeedSinglePopup()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local lastPop = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eHomeJointToSinglePopup) or {}
  local currentPop = self.res_joint_info and self.res_joint_info.last_joint_time or nil
  local bHasPoped = true
  local bHasTerminated = self:HasJointHomeTerminated()
  if currentPop then
    bHasPoped = lastPop == currentPop
  end
  log(bWriteLog and "logic_home_joint:NeedSinglePopup: hasPoped" .. tostring(bHasPoped) .. "hasTerminate" .. tostring(bHasTerminated))
  return not bHasPoped and bHasTerminated
end
function logic_home_joint:ShowHasSaveJoint()
  ShowNotice(62440)
  self:SetSinglePopup(true)
  local config = UIManager.UI_Config_InGame.PlanPH_Single_Popup_UIBP
  if config then
    UIManager.CloseUI(config)
  end
end
function logic_home_joint:SetSinglePopup(bHasPoped)
  log(bWriteLog and "logic_home_joint:SetSinglePopup HasPoped" .. tostring(bHasPoped))
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  if not self.res_joint_info then
    log(bWriteLog and "logic_home_joint:SetSinglePopup failed due to nil joint_info")
    return
  end
  if not self.res_joint_info.last_joint_time then
    log(bWriteLog and "logic_home_joint:SetSinglePopup failed due to nil joint_info.last_joint_time")
    return
  end
  local setValue = bHasPoped and self.res_joint_info.last_joint_time or 0
  PlayerPrefsSystem.SaveTableToFile_N(setValue, PlayerPrefsSystem.ePlayerPrefsType.eHomeJointToSinglePopup)
end
function logic_home_joint.IsManorJointUID(uid)
  return uid and tonumber(string.sub(uid, 2, 2)) == 0 or false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_home_joint)