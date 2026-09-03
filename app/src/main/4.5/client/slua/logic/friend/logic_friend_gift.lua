local logic_friend_gift = {}
function logic_friend_gift:DefineAndResetData()
  self.lastPresentTimes = {}
end
function logic_friend_gift:proc_present_friend_gold_rsp(res, friUid, msg)
  log(bWriteLog and "logic_friend_gift:proc_present_friend_gold_rsp res: " .. res)
  log_tree(bWriteLog and "logic_friend_gift:proc_present_friend_gold_rsp msg:", msg)
  friUid = tonumber(friUid)
  if res == NetErrorCode_NONE or res == "repeat" then
    local TimeUtil = require("client.common.time_util")
    self.lastPresentTimes[friUid] = TimeUtil.GetServerTimeInSec()
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  if type(msg) == "table" and msg.op == MailMacro.Enum_FriendPresentFromType.MiniTVOneClick then
    log(bWriteLog and "[v_wllwu] LogicFriend.on_present_friend_gold_rsp, no tips when MiniTVOneClick ")
    return
  end
  local HDmpveChannelID = Client.GetLoginChannel(NetInterface)
  local SettingAccount = require("client.logic.setting.logic_setting_account")
  local ChannelName = SettingAccount.GetNameByHDmpveChannel(HDmpveChannelID)
  if res == NetErrorCode_NONE then
    local tips = self:GetSendBPSuccessTips(friUid, msg) or LocUtil.GetLocalizeResStr(200018)
    ShowNotice(tips)
  elseif res == "limit" then
    ShowNotice(200019)
  elseif res == "in_blacklist" then
    ShowNotice(200023)
  elseif res == "repeat" then
    ShowNotice(200020)
  elseif res == "not_friend" then
    ShowNotice(18050003)
  elseif res == 100150011 or res == 100150012 then
    local NoticeMessage = LocUtil.LocalizeResFormat(14252, ChannelName)
    ShowNotice(NoticeMessage)
  elseif res == 100150013 then
    local NoticeMessage = LocUtil.LocalizeResFormat(14253, ChannelName, friUid)
    ShowNotice(NoticeMessage)
  else
    ShowNotice(420001)
  end
end
function logic_friend_gift:SetLastPresentTime(uid, timestamp)
  self.lastPresentTimes[uid] = timestamp
end
function logic_friend_gift:CanSendCoin(uid)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if not LogicFriend.IsMyFriend(uid) then
    return false
  end
  if not self.lastPresentTimes[uid] then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  if not TimeUtil.IsSameDay(TimeUtil.GetServerTimeInSec(), self.lastPresentTimes[uid]) then
    return true
  end
  return false
end
function logic_friend_gift:GetSendBPSuccessTips(friUid, msg)
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_FRIEND_PRESENT_CONTINUOUS) then
    log(bWriteLog and "[v_wllwu] LogicFriend.GetSendBPSuccessTips, switch not open")
    return
  end
  local MailMacro = require("client.slua.logic.mail.mail_macro")
  local fromType = msg and msg.op
  if fromType == MailMacro.Enum_FriendPresentFromType.MailBatchRebate or fromType == MailMacro.Enum_FriendPresentFromType.BackUser then
    return
  end
  local logic_mail = require("client.slua.logic.mail.logic_mail")
  local presentData = logic_mail.friendPresentTypeList and logic_mail.friendPresentTypeList[friUid]
  if not presentData or not presentData.present_type then
    return
  end
  local presentType = presentData.present_type
  local contDays = presentData.contDays or 0
  if contDays <= 0 then
    return
  end
  if presentType == MailMacro.Enum_FriendPresent_Type.Continuous then
    return LocUtil.LocalizeResFormat(48729, contDays)
  end
  return nil
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_friend_gift = class(CModuleBase, nil, logic_friend_gift)
return Clogic_friend_gift