local logic_apple_gamecenter_achievement = {}
function logic_apple_gamecenter_achievement:DefineAndResetData()
  self.startProgress = nil
  self.curProgress = nil
  self.achieveCfg = nil
end
function logic_apple_gamecenter_achievement:_syncToGameCenterSDK(cfg, curProgress)
  log(bWriteLog and "logic_apple_gamecenter_achievement:_syncToGameCenterSDK. syncing all achievements to SDK")
  if not cfg or not curProgress then
    log(bWriteLog and "logic_apple_gamecenter_achievement:_syncToGameCenterSDK. invalid parameters")
    return
  end
  for i, achievementCfg in ipairs(cfg) do
    if achievementCfg.event_id and achievementCfg.sub_id and achievementCfg.max_progress and achievementCfg.max_progress > 0 then
      local eventData = curProgress[achievementCfg.event_id]
      if eventData then
        local currentProgress = eventData[achievementCfg.sub_id] or 0
        local percent = math.min(100, math.floor(currentProgress / achievementCfg.max_progress * 100))
        log_format("logic_apple_gamecenter_achievement:_syncToGameCenterSDK. sync achievement event_id:%s sub_id:%s progress:%s max:%s percent:%s", achievementCfg.event_id, achievementCfg.sub_id, currentProgress, achievementCfg.max_progress, percent)
        local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
        if percent ~= 0 then
          logic_store_game_interface:ReportAchievement(i + 1000, percent)
        end
      end
    end
  end
  log(bWriteLog and "logic_apple_gamecenter_achievement:_syncToGameCenterSDK. sync completed")
end
function logic_apple_gamecenter_achievement:_syncChangesToGameCenterSDK(changeMap)
  log(bWriteLog and "logic_apple_gamecenter_achievement:_syncChangesToGameCenterSDK. syncing changed achievements to SDK")
  if not changeMap or not next(changeMap) then
    log(bWriteLog and "logic_apple_gamecenter_achievement:_syncChangesToGameCenterSDK. no changes to sync")
    return
  end
  for index, changeData in pairs(changeMap) do
    if changeData and changeData.eventId and changeData.subId and changeData.newPercent then
      log_format("logic_apple_gamecenter_achievement:_syncChangesToGameCenterSDK. sync changed achievement index:%s event_id:%s sub_id:%s old_percent:%s new_percent:%s", index, changeData.eventId, changeData.subId, changeData.oldPercent or 0, changeData.newPercent)
      local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
      logic_store_game_interface:ReportAchievement(changeData.gamecenterID, changeData.newPercent)
    end
  end
  log(bWriteLog and "logic_apple_gamecenter_achievement:_syncChangesToGameCenterSDK. sync completed")
end
function logic_apple_gamecenter_achievement:CheckAchieveDataSync(curProgress)
  if not curProgress or not self.achieveCfg then
    log(bWriteLog and "logic_apple_gamecenter_achievement:CheckAchieveDataSync. invalid parameters")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eAppleAchievementData) or {}
  if not next(saveData) then
    log(bWriteLog and "logic_apple_gamecenter_achievement:CheckAchieveDataSync. no cache data found, creating new cache")
    saveData.    PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAppleAchievementData)
    self:_syncToGameCenterSDK(self.achieveCfg, curProgress)
    return
  end
  log(bWriteLog and "logic_apple_gamecenter_achievement:CheckAchieveDataSync. comparing cache data with current data")
  local changeMap = {}
  local hasChanges = false
  for i, achievementCfg in ipairs(self.achieveCfg) do
    if achievementCfg.event_id and achievementCfg.sub_id and achievementCfg.max_progress and achievementCfg.max_progress > 0 then
      local cacheEventData = saveData.curProgress and saveData.curProgress[achievementCfg.event_id]
      local curEventData = curProgress and curProgress[achievementCfg.event_id]
      local cacheProgress = cacheEventData and cacheEventData[achievementCfg.sub_id] or 0
      local currentProgress = curEventData and curEventData[achievementCfg.sub_id] or 0
      local cachePercent = math.min(100, math.floor(cacheProgress / achievementCfg.max_progress * 100))
      local curPercent = math.min(100, math.floor(currentProgress / achievementCfg.max_progress * 100))
      if cachePercent < curPercent then
        changeMap[i] = {
          eventId = achievementCfg.event_id,
          subId = achievementCfg.sub_id,
          oldPercent = cachePercent,
          newPercent = curPercent,
          gamecenterID = i + 1000
        }
        hasChanges = true
      end
    else
      log_format("logic_apple_gamecenter_achievement:CheckAchieveDataSync. invalid config at index:%s event_id:%s sub_id:%s max_progress:%s", i, tostring(achievementCfg.event_id), tostring(achievementCfg.sub_id), tostring(achievementCfg.max_progress))
    end
  end
  if hasChanges then
    local changeCount = 0
    for _ in pairs(changeMap) do
      changeCount = changeCount + 1
    end
    log_format("logic_apple_gamecenter_achievement:CheckAchieveDataSync. found changes, syncing to SDK. change count:%s", changeCount)
    self:_syncChangesToGameCenterSDK(changeMap)
  else
    log(bWriteLog and "logic_apple_gamecenter_achievement:CheckAchieveDataSync. no changes detected")
  end
  saveData.  PlayerPrefsSystem.SaveTableToFile_N(saveData, PlayerPrefsSystem.ePlayerPrefsType.eAppleAchievementData)
  log(bWriteLog and "logic_apple_gamecenter_achievement:CheckAchieveDataSync. achievement data sync completed")
end
function logic_apple_gamecenter_achievement:OnInitialize()
end
function logic_apple_gamecenter_achievement:RegistEvents()
end
function logic_apple_gamecenter_achievement:OnLogin(bReLogin)
end
function logic_apple_gamecenter_achievement:OnLogOut()
end
function logic_apple_gamecenter_achievement:OnPreSwitchGameStatus(preState, nextState)
end
function logic_apple_gamecenter_achievement:OnPostSwitchGameStatus(preState, nextState)
  if nextState == GameStatus.Login then
    self:GCLogin()
  end
end
function logic_apple_gamecenter_achievement:GCLogin()
  if self.IsTryed then
    log(bWriteLog and "logic_apple_gamecenter_achievement:GCLogin return of IsTryed")
    return
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "logic_apple_gamecenter_achievement:GCLogin return of not ios device")
    return
  end
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  logic_store_game_interface:Init()
  self.loginTimer = self:AddTimerLoop(0, function()
    if logic_store_game_interface.Inited then
      if logic_store_game_interface:IsGCAuthenticate() then
        log(bWriteLog and "logic_apple_gamecenter_achievement:GCLogin return of IsGCAuthenticate")
        return
      end
      if Client.IsDevelopment() then
        ShowNotice("###[\228\187\133Dev]\229\135\134\229\164\135\230\139\137\232\181\183GameCenter\231\153\187\229\189\149")
      end
      self:AddTimerOnce(1, function()
        logic_store_game_interface:AuthenticateLocalPlayer()
      end)
      self:RemoveTimer(self.loginTimer)
      self.loginTimer = nil
      self.IsTryed = true
    end
  end, 10, 1)
end
function logic_apple_gamecenter_achievement:on_gamecenter_achiev_notify(event_id, sub_id, achieve_data, gamecenter_achievement_cfg)
  if not LobbySystem.CheckOpen(BP_ENUM_APPLE_GAMECENTER_ACHIEVEMENT_SWITCH_ID) then
    log(bWriteLog and "logic_apple_gamecenter_achievement:on_gamecenter_achiev_notify return of switch not open")
    return
  end
  local DevicePlatformNameMacros = require("client.slua.config.ClientMacros.DevicePlatformNameMacros")
  if Client.GetDevicePlatformName() ~= DevicePlatformNameMacros.IOS then
    log(bWriteLog and "logic_apple_gamecenter_achievement:on_gamecenter_achiev_notify return of not ios device")
    return
  end
  log(bWriteLog and "logic_apple_gamecenter_achievement:on_gamecenter_achiev_notify. start processing achievement notification")
  self.curProgress = achieve_data
  if gamecenter_achievement_cfg then
    self.achieveCfg = gamecenter_achievement_cfg
  end
  local logic_store_game_interface = require("client.slua.logic.app_store.logic_store_game_interface")
  if logic_store_game_interface:IsGCAuthenticate() then
    self:CheckAchieveDataSync(achieve_data)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_apple_gamecenter_achievement = class(CModuleBase, nil, logic_apple_gamecenter_achievement)
return Clogic_apple_gamecenter_achievement