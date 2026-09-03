local logic_airdrop_collection = {}
function logic_airdrop_collection:OnInitialize()
  self.CollectionPageInfo = nil
  self.isPlayingMusic = nil
end
function logic_airdrop_collection:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.OnWidgetHide, self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_WORLDCUP_MISSION, self.OnJumpAirdropCollection, self)
end
function logic_airdrop_collection:OnWidgetHide()
  if not self.isPlayingMusic then
    return
  end
  if self.isHandlingWidgetHide then
    log(bWriteLog and "logic_airdrop_collection:OnWidgetHide return of isHandlingWidgetHide")
    return
  end
  self.isHandlingWidgetHide = true
  if not self.restoreMusicTimer then
    self.restoreMusicTimer = self:AddTimerOnce(0.1, function()
      self:CheckRestoreLobbyMusic()
      self.isHandlingWidgetHide = false
      self:RemoveTimer(self.restoreMusicTimer)
      self.restoreMusicTimer = nil
    end)
  end
end
function logic_airdrop_collection:GetCollectionPageInfo()
  return self.CollectionPageInfo
end
function logic_airdrop_collection:GetActInfo(actID)
  if not self.CollectionPageInfo then
    return nil
  end
  return self.CollectionPageInfo[actID]
end
function logic_airdrop_collection:SetCollectionPageInfo(collectionPageInfo, airdrop_progress_info)
  self.CollectionPageInfo = collectionPageInfo
  local logic_super_airdrop = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_super_airdrop)
  logic_super_airdrop:SetAirdropProgressInfo(airdrop_progress_info)
  EventSystem:postEvent(EVENTTYPE_SUPERAIRDROP, EVENTID_SUPERAIRDROP_GET_COLLECTION_INFO)
end
function logic_airdrop_collection:CheckInActTime(actid)
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  if actid == airdrop_macro.ActId.ActId2 then
    local logic_best_partner = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_best_partner)
    if not logic_best_partner:CheckInActivityTime() then
      log(bWriteLog and "logic_airdrop_collection:CheckInActTime not CheckInActivityTime")
      return false
    end
  end
  if not self.CollectionPageInfo or not self.CollectionPageInfo[actid] then
    log(bWriteLog and "logic_airdrop_collection:CheckInActTime not CollectionPageInfo")
    return false
  end
  local tNow = FuncUtil.GetServerTimeInSec()
  return tNow > self.CollectionPageInfo[actid].act_start_time and tNow < self.CollectionPageInfo[actid].act_end_time
end
function logic_airdrop_collection:GetActState(act_id)
  if not act_id then
    log(bWriteLog and "[v_wllwu] logic_airdrop_collection:GetActState, not act_id")
    return
  end
  local actConfig = self:GetActInfo(act_id)
  if not actConfig then
    log(bWriteLog and "[v_wllwu] logic_airdrop_entry:GetActState, no actConfig and act_id is:" .. tostring(act_id))
    return
  end
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  local actStartTime = actConfig.act_start_time or 0
  local actEndTime = actConfig.act_end_time or 0
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  if nowTime < actStartTime or nowTime >= actEndTime then
    return airdrop_macro.Enum_ActState.NotOpen
  end
  local actSwitchTime = actConfig.act_switch_time or 0
  if nowTime < actSwitchTime then
    return airdrop_macro.Enum_ActState.NotDrawn
  end
  return airdrop_macro.Enum_ActState.HasDrawn
end
function logic_airdrop_collection:send_get_make_festival_activity_list_req()
  local SuperAirdropHandler = require("client.network.Protocol.SuperAirdropHandler")
  SuperAirdropHandler.send_get_make_festival_activity_list_req()
end
function logic_airdrop_collection:ForceResetBackgroundMusic()
  GlobalData.StopLobbyBGM()
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(airdrop_macro.playBGM)
end
function logic_airdrop_collection:PlayBackgroundMusic()
  if self.isPlayingMusic then
    return
  end
  self.isPlayingMusic = true
  GlobalData.StopLobbyBGM()
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(airdrop_macro.playBGM)
end
function logic_airdrop_collection:CheckRestoreLobbyMusic()
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  for _, uiName in ipairs(airdrop_macro.ActUIKeyNameConfig) do
    if UIManager.IsUIShow(UIManager.UI_Config[uiName]) then
      log(bWriteLog and "[v_wllwu] logic_airdrop_collection:CheckRestoreLobbyMusic return when subActUI is showing, uiName is:" .. tostring(uiName))
      return
    end
  end
  self:StopBackgroundMusic()
  GlobalData.RestoreLobbyBGM()
end
function logic_airdrop_collection:StopBackgroundMusic()
  if not self.isPlayingMusic then
    return
  end
  self.isPlayingMusic = false
  local audio_util = require("client.common.audio_util")
  local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
  audio_util.PlayAudio(airdrop_macro.stopBGM)
end
function logic_airdrop_collection:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("[logic_airdrop_collection] OnPreSwitchGameStatus preState[%s] nextState[%s]", preState, nextState))
  if nextState == GameStatus.Fighting and not GameStatus.IsInMainCity() then
    local airdrop_macro = require("client.slua.logic.lobby_activity.super_airdrop.airdrop_macro")
    local audio_util = require("client.common.audio_util")
    audio_util.PlayAudio(airdrop_macro.stopBGM)
    self.isPlayingMusic = false
  end
end
function logic_airdrop_collection:OnJumpAirdropCollection()
  if not (DataMgr and DataMgr.roleData) or not DataMgr.roleData.level then
    return
  end
  if DataMgr.roleData.level < 8 then
    log(bWriteLog and "logic_airdrop_collection:OnJumpAirdropCollection jump airdrop collection failed, role's level is " .. tostring(DataMgr.roleData.level))
    ShowNotice(LocUtil.LocalizeResFormat(6543, 8))
    return
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_airdrop_collection = class(CModuleBase, nil, logic_airdrop_collection)
return Clogic_airdrop_collection