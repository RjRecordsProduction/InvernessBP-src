local logic_google_play_achievement = {}
local ACHIEVEMENT_INCREMENTAL_THRESHOLD = 50
local FLUSH_DEBOUNCE_SECONDS = 10
function logic_google_play_achievement:DefineAndResetData()
  self.curProgress = nil
  self.achieveCfg = nil
  self.syncedSnapshot = nil
  self.IsTryed = false
  self.pendingDirty = false
  self.pendingFlushTimer = nil
end
function logic_google_play_achievement:_loadSyncedSnapshot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGooglePlayAchievementData) or {}
  return saveData.syncedSnapshot or {}
end
function logic_google_play_achievement:_saveSyncedSnapshot()
  if not self.syncedSnapshot then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eGooglePlayAchievementData) or {}
  saveData.syncedSnapshot = self.syncedSnapshot
  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eGooglePlayAchievementData)
end
function logic_google_play_achievement:_unlockAchievement(achievementId)
  log_format("logic_google_play_achievement:_unlockAchievement. achievementId:%s", tostring(achievementId))
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  logic_store_game_interface:UnlockGPAchievement(achievementId)
end
function logic_google_play_achievement:_increaseAchievement(achievementId, step)
  step = math.floor(tonumber(step) or 0)
  log_format("logic_google_play_achievement:_increaseAchievement. achievementId:%s, step:%s", tostring(achievementId), tostring(step))
  if step <= 0 then
    log_format("[WARN] logic_google_play_achievement:_increaseAchievement. skip non-positive step, achievementId:%s", tostring(achievementId))
    return
  end
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  logic_store_game_interface:IncreaseGPAchievement(achievementId, step)
end
function logic_google_play_achievement:_calcPercent(progress, maxProgress)
  if not maxProgress or maxProgress <= 0 then
    return 0
  end
  return math.min(100, math.floor(progress / maxProgress * 100))
end
function logic_google_play_achievement:CheckAchieveDataSync(curProgress, bFullSync)
  if not curProgress or not self.achieveCfg then
    log(bWriteLog and "logic_google_play_achievement:CheckAchieveDataSync. invalid parameters")
    return
  end
  if bFullSync or not self.syncedSnapshot then
    log(bWriteLog and "logic_google_play_achievement:CheckAchieveDataSync. load synced snapshot from PlayerPrefs")
    self.syncedSnapshot = self:_loadSyncedSnapshot()
  end
  log(bWriteLog and "logic_google_play_achievement:CheckAchieveDataSync. checking achievements for sync")
  local snapshotDirty = false
  for i, achievementCfg in ipairs(self.achieveCfg) do
    if achievementCfg.event_id and achievementCfg.sub_id and achievementCfg.max_progress and achievementCfg.max_progress > 0 then
      local curEventData = curProgress[achievementCfg.event_id]
      local currentProgress = curEventData and curEventData[achievementCfg.sub_id] or 0
      local achievementId = achievementCfg.google_achv_id
      local maxProgress = achievementCfg.max_progress
      if maxProgress >= ACHIEVEMENT_INCREMENTAL_THRESHOLD then
        local lastProgress = self.syncedSnapshot[achievementId] or 0
        if type(lastProgress) ~= "number" then
          lastProgress = 0
        end
        local clampedProgress = math.floor(math.min(currentProgress, maxProgress))
        lastProgress = math.floor(lastProgress)
        if clampedProgress > lastProgress then
          local step = clampedProgress - lastProgress
          log_format("logic_google_play_achievement:CheckAchieveDataSync. increase achievement index:%s event_id:%s sub_id:%s progress:%s->%s step:%s achievementId:%s", i, achievementCfg.event_id, achievementCfg.sub_id, lastProgress, clampedProgress, step, tostring(achievementId))
          self:_increaseAchievement(achievementId, step)
          self.syncedSnapshot[achievementId] = clampedProgress
          snapshotDirty = true
        end
      elseif currentProgress >= maxProgress and self.syncedSnapshot[achievementId] ~= true then
        log_format("logic_google_play_achievement:CheckAchieveDataSync. unlocking achievement index:%s event_id:%s sub_id:%s progress:%s/%s achievementId:%s", i, achievementCfg.event_id, achievementCfg.sub_id, currentProgress, maxProgress, tostring(achievementId))
        self:_unlockAchievement(achievementId)
        self.syncedSnapshot[achievementId] = true
        snapshotDirty = true
      end
    else
      log_format("[WARN] logic_google_play_achievement:CheckAchieveDataSync. invalid config at index:%s event_id:%s sub_id:%s max_progress:%s", i, tostring(achievementCfg.event_id), tostring(achievementCfg.sub_id), tostring(achievementCfg.max_progress))
    end
  end
  if snapshotDirty then
    self:_saveSyncedSnapshot()
    log(bWriteLog and "logic_google_play_achievement:CheckAchieveDataSync. snapshot persisted")
  else
    log(bWriteLog and "logic_google_play_achievement:CheckAchieveDataSync. no new achievements to sync")
  end
  log(bWriteLog and "logic_google_play_achievement:CheckAchieveDataSync. achievement check completed")
end
function logic_google_play_achievement:_cancelPendingFlush()
  if self.pendingFlushTimer then
    self:RemoveTimer(self.pendingFlushTimer)
    self.pendingFlushTimer = nil
    log(bWriteLog and "logic_google_play_achievement:_cancelPendingFlush. debounce timer cancelled")
  end
end
function logic_google_play_achievement:_scheduleFlush()
  if self.pendingFlushTimer then
    log(bWriteLog and "logic_google_play_achievement:_scheduleFlush. merged into existing debounce window")
    return
  end
  log_format("logic_google_play_achievement:_scheduleFlush. schedule flush after %s sec", tostring(FLUSH_DEBOUNCE_SECONDS))
  self.pendingFlushTimer = self:AddTimerOnce(FLUSH_DEBOUNCE_SECONDS, function()
    self.pendingFlushTimer = nil
    self:_flushAchievementSync()
  end)
end
function logic_google_play_achievement:_flushAchievementSync()
  if not self.pendingDirty then
    log(bWriteLog and "logic_google_play_achievement:_flushAchievementSync. no pending change, skip")
    return
  end
  self.pendingDirty = false
  if not self.curProgress or not self.achieveCfg then
    log(bWriteLog and "logic_google_play_achievement:_flushAchievementSync. curProgress or achieveCfg is nil, skip")
    return
  end
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  if not logic_store_game_interface:IsGCAuthenticate() then
    log(bWriteLog and "logic_google_play_achievement:_flushAchievementSync. not authenticated, skip")
    return
  end
  log(bWriteLog and "logic_google_play_achievement:_flushAchievementSync. flush merged achievement sync")
  self:CheckAchieveDataSync(self.curProgress, false)
end
function logic_google_play_achievement:JumpToGooglePlayActivity()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local title = LocUtil.GetLocalizeResStr(75510)
  local content = LocUtil.GetLocalizeResStr(75511)
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, title, content, function()
    Client.LaunchUrl(FuncUtil.GetDomainByID(3366248))
  end, nil, LocUtil.GetLocalizeResStr(5078))
end
function logic_google_play_achievement:OnInitialize()
end
function logic_google_play_achievement:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_GOOGLE_ACTIVITY_JUMP, self.JumpToGooglePlayActivity, self)
end
function logic_google_play_achievement:OnLogin(bReLogin)
end
function logic_google_play_achievement:OnLogOut()
  self:_cancelPendingFlush()
  self.pendingDirty = false
end
function logic_google_play_achievement:OnPreSwitchGameStatus(preState, nextState)
  self:_cancelPendingFlush()
end
function logic_google_play_achievement:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Login then
    self:GPLogin()
  end
end
function logic_google_play_achievement:GPLogin()
  if self.IsTryed then
    log(bWriteLog and "logic_google_play_achievement:GPLogin return of IsTryed")
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_GOOGLE_PLAY_ACHIEVEMENT_SYNC_SWITCH_ID) then
    log(bWriteLog and "logic_google_play_achievement:GPLogin return of switch not open")
    return
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "logic_google_play_achievement:GPLogin return of not android")
    return
  end
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  if not logic_store_game_interface:IsStoreGameSupported() then
    log(bWriteLog and "logic_google_play_achievement:GPLogin return of store game not supported")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsGlobalVersion() then
    log(bWriteLog and "logic_google_play_achievement:GPLogin return of not global version")
    return
  end
  self.IsTryed = true
  logic_store_game_interface:Init()
end
function logic_google_play_achievement:on_googleplay_achiev_notify(event_id, sub_id, achieve_data, googleplay_achievement_cfg)
  if not LobbySystem.CheckOpen(BP_ENUM_GOOGLE_PLAY_ACHIEVEMENT_SYNC_SWITCH_ID) then
    log(bWriteLog and "logic_google_play_achievement:on_googleplay_achiev_notify return of switch not open")
    return
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.Android then
    log(bWriteLog and "logic_google_play_achievement:on_googleplay_achiev_notify return of not android")
    return
  end
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  if not logic_store_game_interface:IsStoreGameSupported() then
    log(bWriteLog and "logic_google_play_achievement:on_googleplay_achiev_notify return of store game not supported")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if not PublishRegionMacros.IsGlobalVersion() then
    log(bWriteLog and "logic_google_play_achievement:on_googleplay_achiev_notify return of not global version")
    return
  end
  log(bWriteLog and "logic_google_play_achievement:on_googleplay_achiev_notify. start processing achievement notification")
  local bFullSync = event_id == 0 and sub_id == 0
  log_format("logic_google_play_achievement:on_googleplay_achiev_notify. event_id:%s, sub_id:%s, bFullSync:%s", tostring(event_id), tostring(sub_id), tostring(bFullSync))
  self.curProgress = achieve_data
  if googleplay_achievement_cfg then
    self.achieveCfg = googleplay_achievement_cfg
  end
  if logic_store_game_interface:IsGCAuthenticate() then
    if bFullSync then
      self:_cancelPendingFlush()
      self.pendingDirty = false
      self:CheckAchieveDataSync(achieve_data, true)
    else
      self.pendingDirty = true
      self:_scheduleFlush()
    end
  else
    log(bWriteLog and "logic_google_play_achievement:on_googleplay_achiev_notify. not authenticated, skip sync")
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_google_play_achievement = class(CModuleBase, nil, logic_google_play_achievement)
return Clogic_google_play_achievement