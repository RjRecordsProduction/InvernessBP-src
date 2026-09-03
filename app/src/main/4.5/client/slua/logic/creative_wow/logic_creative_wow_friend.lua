local logic_creative_wow_friend = {}
logic_creative_wow_friend.ENUM_CWOW_STATUS = {
  NONE_ON_CWOW = 1,
  ME_ON_CWOW = 2,
  TARGET_ON_CWOW = 4,
  ON_DIFFERENT_CWOW = 5,
  ON_SAME_CWOW = 6,
  NA = 7
}
local ignoreMaxTime = 300
function logic_creative_wow_friend:_InitData()
  self.cwow_type = nil
  self.cwow_ds_partition_id = nil
  self.ignoreInviteMap = {}
end
function logic_creative_wow_friend:_OnInviteNotify(_, _, InviterUid)
  log(bWriteLog and "logic_creative_wow_friend._OnInviteNotify")
  self.  self.  local ignoreTime = self.ignoreInviteMap[InviterUid]
  if ignoreTime then
    local TimeUtil = require("client.common.time_util")
    local tNow = TimeUtil.GetServerTimeInSec()
    if tNow - ignoreTime <= ignoreMaxTime then
      log(bWriteLog and "SocialIslandHandler ignore invite " .. tostring(InviterUid))
      return
    end
  end
  UIManager.ShowUI(UIManager.UI_Config.UGC_CWOW_Invite_Notify_UIBP, InviterUid)
end
function logic_creative_wow_friend:OnInitialize()
  logic_creative_wow_friend.__super.OnInitialize(self)
  self:_InitData()
end
function logic_creative_wow_friend:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CWOW_INVITE_NOTIFY, self._OnInviteNotify, self)
end
function logic_creative_wow_friend:OnLogin(bReLogin)
end
function logic_creative_wow_friend:OnLogOut()
  self:_InitData()
end
function logic_creative_wow_friend:OnPreSwitchGameStatus(preState, nextState)
  self:_InitData()
end
function logic_creative_wow_friend:IsIn()
  if slua.isValid(CGameState) and CGameState.bIsCreativeWoW then
    return true
  end
  return self.cwow_type and self.cwow_type ~= 0
end
function logic_creative_wow_friend:GetDSPartitionID()
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local uPlayerCtrl = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerCtrl) and uPlayerCtrl.PlayerStartID then
    return uPlayerCtrl.PlayerStartID
  end
  return self.cwow_ds_partition_id
end
function logic_creative_wow_friend:GetStatus(cwow_type, GameId, cwow_ds_partition_id)
  if self:IsIn() then
    if cwow_type == 1 then
      if g_game_id == GameId and self:GetDSPartitionID() == cwow_ds_partition_id then
        return logic_creative_wow_friend.ENUM_CWOW_STATUS.ON_SAME_CWOW
      else
        return logic_creative_wow_friend.ENUM_CWOW_STATUS.ON_DIFFERENT_CWOW
      end
    elseif cwow_type == 2 then
      return logic_creative_wow_friend.ENUM_CWOW_STATUS.NA
    else
      return logic_creative_wow_friend.ENUM_CWOW_STATUS.ME_ON_CWOW
    end
  end
  if cwow_type and 0 < cwow_type then
    return logic_creative_wow_friend.ENUM_CWOW_STATUS.TARGET_ON_CWOW
  else
    return logic_creative_wow_friend.ENUM_CWOW_STATUS.NONE_ON_CWOW
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_creative_wow_friend)
return CModuleTemplate