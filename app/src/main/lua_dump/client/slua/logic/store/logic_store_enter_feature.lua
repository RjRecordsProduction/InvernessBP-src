local logic_store_enter_feature = {}
local recommendForceFullScreenEnum = {
  none = 0,
  enterStore = 1,
  recommend = 2
}
local autoFeatureConfigByJK = {
  [ENUM_Feature_Desc_Type.ShockingAdmission] = 4,
  [ENUM_Feature_Desc_Type.ExclusiveExpression] = 3,
  [ENUM_Feature_Desc_Type.MallPerformance] = 2,
  [ENUM_Feature_Desc_Type.ExclusiveAdmission] = 1
}
local autoFeatureConfig = {
  [ENUM_Feature_Desc_Type.ShockingAdmission] = 4,
  [ENUM_Feature_Desc_Type.ExclusiveExpression] = 3,
  [ENUM_Feature_Desc_Type.MallPerformance] = 2
}
function logic_store_enter_feature:DefineAndResetData()
  self.saveSceneData = nil
  self.preItemType = nil
  self.preItemSubType = nil
  self.featuresTimers = nil
  self.recommendForceFullScreenMark = recommendForceFullScreenEnum.none
  self.recommendForceFullScreenAlreadyPlayed = {}
  self.curEnterExpressionID = nil
  self.GM_FullScreen = false
  self.cachedAsyncLoadingTimeLimit = nil
  self.isVideoEmoteFullScreen = false
  self.isCanPlayEmotion = true
end
function logic_store_enter_feature:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STORE, EVENTID_STORE_EMOTION_STOP, self.OnEmotionStop, self)
  self:AddCommonEvent(EVENTTYPE_VIDEO_PURE, EVENTID_VIDEO_PURE_CLOSE, self.OnVideoPureClose, self)
end
function logic_store_enter_feature:_SetAsyncLoadingTimeLimit(nNewValue)
  if not HDmpveRemote.HDmpveRemoteConfigGetBool("EnableStoreAsyncLoadingTimeLimit", true) then
    log(bWriteLog and "logic_store_enter_feature:_SetAsyncLoadingTimeLimit - Disabled by remote config")
    return
  end
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  if not gameInstance then
    log(bWriteLog and "logic_store_enter_feature:_SetAsyncLoadingTimeLimit - GameInstance is nil")
    return
  end
  if self.cachedAsyncLoadingTimeLimit == nil then
    self.cachedAsyncLoadingTimeLimit = gameInstance:GetAsyncLoadingTimeLimit()
  end
  gameInstance:SetAsyncLoadingTimeLimit(nNewValue)
  log(bWriteLog and string.format("logic_store_enter_feature:_SetAsyncLoadingTimeLimit - Set AsyncLoadingTimeLimit to %s, cached original: %s", tostring(nNewValue), tostring(self.cachedAsyncLoadingTimeLimit)))
end
function logic_store_enter_feature:RestoreAsyncLoadingTimeLimit()
  if self.cachedAsyncLoadingTimeLimit ~= nil then
    local STExtraGameInstance = import("STExtraGameInstance")
    local gameInstance = STExtraGameInstance.GetInstance()
    if gameInstance then
      gameInstance:SetAsyncLoadingTimeLimit(self.cachedAsyncLoadingTimeLimit)
      log(bWriteLog and string.format("logic_store_enter_feature:RestoreAsyncLoadingTimeLimit - Restored AsyncLoadingTimeLimit to %s", tostring(self.cachedAsyncLoadingTimeLimit)))
    end
    self.cachedAsyncLoadingTimeLimit = nil
  end
end
function logic_store_enter_feature:ClearPreItemType()
  self.preItemType = nil
  self.saveSceneData = nil
  self.preItemSubType = nil
  self.recommendForceFullScreenMark = recommendForceFullScreenEnum.none
  self.recommendForceFullScreenAlreadyPlayed = {}
  self.curEnterExpressionID = nil
  self.isVideoEmoteFullScreen = false
  self:RemoveAllFeatureTimer()
end
function logic_store_enter_feature:SetIsEnterExpressionForceFullScreen()
  self.recommendForceFullScreenMark = recommendForceFullScreenEnum.enterStore
end
function logic_store_enter_feature:SetEnterRecommendForceFullScreen(tabId, subTabId)
  if tabId == StoreConst.Page_New_ID_Recommend and subTabId == StoreConst.subtype_new_recommend_rec then
    if self.recommendForceFullScreenMark == recommendForceFullScreenEnum.enterStore then
      self.recommendForceFullScreenMark = recommendForceFullScreenEnum.recommend
    end
  elseif self.recommendForceFullScreenMark == recommendForceFullScreenEnum.recommend then
    self.recommendForceFullScreenMark = recommendForceFullScreenEnum.none
  end
end
function logic_store_enter_feature:CheckRecommendForceFullScreen(featureID)
  if not featureID then
    return false
  end
  if self.recommendForceFullScreenMark ~= recommendForceFullScreenEnum.recommend then
    return false
  end
  self.recommendForceFullScreenMark = recommendForceFullScreenEnum.none
  if self.recommendForceFullScreenAlreadyPlayed and self.recommendForceFullScreenAlreadyPlayed[featureID] then
    return false
  end
  self.recommendForceFullScreenAlreadyPlayed[featureID] = true
  return true
end
function logic_store_enter_feature:GetEmotionIdByGlobal(emoteCfg)
  local emotionId = emoteCfg.config.ExpressionID
  if emotionId <= 0 then
    emotionId = emoteCfg.config.FightExpressionID
  end
  return emotionId
end
function logic_store_enter_feature:GetEmotionIdByJK(emoteCfg)
  local emotionId = emoteCfg.config.FightExpressionID
  if emotionId <= 0 then
    emotionId = emoteCfg.config.ExpressionID
  end
  return emotionId
end
function logic_store_enter_feature:GetEmotionID(emoteCfg, curFeaturesItemID)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local emotionID = 0
  local bEquip
  if ModelDisplayer.GetShowingAvatar() then
    bEquip = ModelDisplayer.GetShowingAvatar():HasEquiped(curFeaturesItemID)
  end
  if not bEquip then
    return emotionID
  end
  if GlobalData.IsJapanOrKorea() then
    emotionID = self:GetEmotionIdByJK(emoteCfg)
  else
    emotionID = self:GetEmotionIdByGlobal(emoteCfg)
  end
  return emotionID
end
local MultiActionTb = {
  [12220586] = 12220579,
  [12220579] = 12220586,
  [12220580] = 12220587,
  [12220587] = 12220580
}
local actionNeedPutOnTb = {
  [12220580] = 1410923,
  [12220587] = 1410923
}
function logic_store_enter_feature:PlayOnceNormalEmotion(emoteCfg, curFeaturesItemID, nCurShowModelId)
  self:CheckRemoveTimer("loopEmotionTimer")
  local emotionID = self:GetEmotionID(emoteCfg, curFeaturesItemID)
  if emotionID == 0 then
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local otherId = multi_state_manager:GetOtherStateClothID(curFeaturesItemID)
    if otherId then
      emotionID = self:GetEmotionID(emoteCfg, otherId)
    end
  end
  if 0 < emotionID then
    if nCurShowModelId and nCurShowModelId ~= curFeaturesItemID then
      log(bWriteLog and "  logic_store_enter_feature:PlayOnceNormalEmotion.  is multi golden")
      if MultiActionTb[emotionID] then
        emotionID = MultiActionTb[emotionID]
      end
    end
    local needPutOn = actionNeedPutOnTb[emotionID]
    if needPutOn then
      local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
      ModelDisplayer.PutOnOrPutoff(needPutOn, true)
    end
    local isFullScreen = self.GM_FullScreen
    if isFullScreen then
      EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, false)
    end
    self:PlayEmotion(emotionID, emoteCfg, isFullScreen)
  end
  return emotionID
end
function logic_store_enter_feature:LoopNormalEmotion(emoteCfg, curFeaturesItemID)
  if emoteCfg == nil then
    return
  end
  local emotionID = self:GetEmotionID(emoteCfg, curFeaturesItemID)
  if 0 < emotionID then
    if emoteCfg.itemType == ENUM_ITEM_TYPE.Extra and emoteCfg.itemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 then
    else
      self:StopEmotion()
    end
    log(bWriteLog and string.format("logic_store_enter_feature:LoopEmotion emotionID = %s, emoteCfg.expressionCD = %s", emotionID, emoteCfg.config.ExpressionCD))
    if emotionID == 12219067 then
      self:CheckRemoveTimer("loopEmotionTimer")
      self:AddFeatureTimer("SpookyDollTimer", 0.01, function()
        self:PlayEmotion(emotionID, emoteCfg, false)
      end)
    else
      self:PlayEmotion(emotionID, emoteCfg)
    end
    if not (0 < emoteCfg.config.ExpressionCD) then
      return
    end
    self:AddFeatureTimer("loopEmotionTimer", emoteCfg.config.ExpressionCD, function()
      self:LoopNormalEmotion(emoteCfg, curFeaturesItemID)
    end)
  end
end
function logic_store_enter_feature:ExecuteAutoEmotion(emoteCfg, curFeaturesItemID, isOnClick, hasVideo, skipFullScreen)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {curFeaturesItemID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and string.format("logic_store_enter_feature:ExecuteAutoEmotion curFeaturesItemID = %s, The current item has not been downloaded yet.", curFeaturesItemID))
    return
  end
  self:_SetAsyncLoadingTimeLimit(100)
  local emotionId = 0
  if GlobalData.IsJapanOrKorea() then
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local originID = multi_state_manager:GetOriginClothIDAndState(curFeaturesItemID)
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if emoteCfg.enableCameraAnim ~= false and LogicXSuit.IsXSuit(curFeaturesItemID) or originID and LogicXSuit.IsXSuit(originID) then
      emotionId = emoteCfg.config.EnterExpressionID or 0
      if 0 < emotionId then
        self:PlayEnterEmotionFeature(emoteCfg, curFeaturesItemID, isOnClick, hasVideo, skipFullScreen)
        return
      end
    end
    emotionId = self:GetEmotionIdByJK(emoteCfg)
    if 0 < emotionId then
      self:LoopNormalEmotion(emoteCfg, curFeaturesItemID)
      return
    end
  else
    local emotionId = emoteCfg.config.EnterExpressionID or 0
    if emoteCfg.enableCameraAnim ~= false and 0 < emotionId then
      self:PlayEnterEmotionFeature(emoteCfg, curFeaturesItemID, isOnClick, hasVideo, skipFullScreen)
      return
    end
    emotionId = self:GetEmotionIdByGlobal(emoteCfg)
    if 0 < emotionId then
      self:LoopNormalEmotion(emoteCfg, curFeaturesItemID)
      return
    end
  end
end
function logic_store_enter_feature:PlayEnterEmotionFeature(emoteCfg, curFeaturesItemID, isOnClick, hasVideo, skipFullScreen)
  log(bWriteLog and "logic_store_enter_feature:PlayEnterEmotionFeature")
  if not emoteCfg then
    log(bWriteLog and "WARNING: logic_store_enter_feature:PlayEnterEmotionFeature, not emoteCfg. ")
    return
  end
  local enterExpressionID = emoteCfg.config.EnterExpressionID
  local isFullScreen = self:GetIsFeatureFullScreen(emoteCfg, hasVideo, isOnClick, skipFullScreen)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if limitScene and limitScene.sceneName and limitScene.scenePath then
    local sceneName = limitScene.sceneName
    local scenePath = limitScene.scenePath
    local PufferConst = require("client.slua.logic.download.puffer_const")
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {scenePath})
    if state == PufferConst.ENUM_DownloadState.Done then
      self:SwitchActionScene(sceneName)
      enterExpressionID = limitScene.newAction
    end
  end
  if self.curEnterExpressionID == enterExpressionID and not isOnClick then
    log(bWriteLog and "[tinghaohu]StoreDetail:PlayEnterEmotionFeature. is already playing same enter expression, id = " .. tostring(self.curEnterExpressionID))
    return
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {curFeaturesItemID, enterExpressionID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    return
  end
  self:StopEmotion()
  local view_component_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.view_component_manager)
  if view_component_manager:GetCurIsEnlarge() then
    view_component_manager:TryDirectForceUnEnlarge()
    self:AddFeatureTimer("PlayEmotionAni", 0, function()
      self:PlayEnterEmotionAndLoop(enterExpressionID, emoteCfg, curFeaturesItemID, isFullScreen)
    end)
  else
    self:PlayEnterEmotionAndLoop(enterExpressionID, emoteCfg, curFeaturesItemID, isFullScreen)
  end
  local full_preview_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.full_preview_module)
  full_preview_module:OnPlayEmote()
end
function logic_store_enter_feature:PlayEnterEmotionAndLoop(enterExpressionID, emoteCfg, curFeaturesItemID, isFullScreen)
  if enterExpressionID == 0 then
    self.curEnterExpressionID = nil
    return
  end
  self:SetCurEnterExpressionID(enterExpressionID)
  self:PlayEmotion(enterExpressionID, emoteCfg, nil, isFullScreen)
  if not emoteCfg then
    log(bWriteLog and string.format("logic_store_enter_feature:StartPlayEmotion config is nil, enterExpressionID = %s", enterExpressionID))
    return
  end
  log(bWriteLog and string.format("logic_store_enter_feature:StartPlayEmotion enterExpressionID = %s emoteCfg.expressionCD = %s", enterExpressionID, emoteCfg.config.ExpressionCD))
  if 0 < emoteCfg.config.ExpressionCD then
    self:AddFeatureTimer("loopEmotionTimer", emoteCfg.config.ExpressionCD, function()
      self:LoopNormalEmotion(emoteCfg, curFeaturesItemID)
    end)
  end
end
function logic_store_enter_feature:PlayEmotion(emotionID, emoteCfg, removeTimer, isFullScreen)
  if removeTimer ~= false then
    self:CheckRemoveTimer("loopEmotionTimer")
  end
  if not self.isCanPlayEmotion then
    log(bWriteLog and "[SY]logic_store_enter_feature:PlayEmotion. CantPlay")
    return
  end
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  StoreUtils.PlayEmotion(emotionID, emoteCfg.config.FeatureType == ENUM_FeatureType.Glide, emoteCfg.enableCameraAnim, isFullScreen)
end
function logic_store_enter_feature:PauseEmotion()
  self.isCanPlayEmotion = false
end
function logic_store_enter_feature:ResumeEmotion()
  self.isCanPlayEmotion = true
end
function logic_store_enter_feature:HaveShowedStoreEmotion(itemId)
  local have = false
  local TimeUtil = require("client.common.time_util")
  local curT = TimeUtil.GetServerTimeInSec()
  local saveT = StoreConst.haveShowedStoreEmotion[itemId]
  if saveT and TimeUtil.IsSameDay(curT, saveT) then
    have = true
  end
  StoreConst.haveShowedStoreEmotion[itemId] = curT
  return have
end
function logic_store_enter_feature:StopEmotion()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if ModelDisplayer.GetShowingAvatar() then
    ModelDisplayer.GetShowingAvatar():StopAction(true)
  end
end
function logic_store_enter_feature:SwitchActionScene(sceneName)
  local preScene = LobbySceneManager.GetLastLevelName()
  log(bWriteLog and "[jonahwei]StoreDetail:StartPlayEmotion: ChangeScene!")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local preCameraID = Lobby_camera_manager_module.GetCurrentCameraID()
  LobbySceneManager.LoadStreamLevel(true, sceneName, 32117, nil, {UnloadLevelName = preScene})
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if ModelDisplayer.GetShowingAvatar() then
    local position = ModelDisplayer.GetShowingAvatar():GetPosition()
    local prePosition = {
      x = position.x,
      y = position.y,
      z = position.z
    }
    ModelDisplayer.GetShowingAvatar():SetShowPosition(0, 0, -29617.091797)
    self.saveSceneData = {
      preScene = preScene,
      sceneName = sceneName,
      preCameraID = preCameraID,
          }
  end
end
function logic_store_enter_feature:OnEmotionStop(_, __, stopEmoteID, enforce)
  log(bWriteLog and "[tinghaohu]StoreDetail:OnEmotionStop. id = " .. tostring(stopEmoteID))
  if enforce ~= true and self.curEnterExpressionID ~= stopEmoteID then
    return
  end
  self.curEnterExpressionID = nil
  if self.saveSceneData and next(self.saveSceneData) then
    log(bWriteLog and "[jonahwei]StartPlayEmotion: RecoverScene!")
    local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
    LobbySceneManager.LoadStreamLevel(true, self.saveSceneData.preScene, self.saveSceneData.preCameraID, nil, {
      UnloadLevelName = self.saveSceneData.sceneName
    })
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    if ModelDisplayer.GetShowingAvatar() then
      ModelDisplayer.GetShowingAvatar():SetShowPosition(self.saveSceneData.prePosition.x, self.saveSceneData.prePosition.y, self.saveSceneData.prePosition.z)
    end
    self.saveSceneData = nil
  end
end
function logic_store_enter_feature:CheckStopActionByFeatures(itemID, itemType, itemSubType)
  local dontStopAction = false
  if self.preItemType == ENUM_ITEM_TYPE.Extra and self.preItemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 and itemType == ENUM_ITEM_TYPE.Extra and itemSubType == ENUM_ITEM_SUBTYPE.Glider_Slot_415 then
    dontStopAction = true
  end
  self.preItemType = itemType
  self.preItemSubType = itemSubType
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsEmotion(itemType) then
    dontStopAction = true
  end
  local paintCfg = CDataTable.GetTableData("DecalBPTable", itemID)
  if paintCfg and paintCfg.soundID and paintCfg.soundID ~= 0 and paintCfg.soundPath and paintCfg.soundPath ~= "" then
    dontStopAction = true
  end
  return dontStopAction
end
function logic_store_enter_feature:SetCurEnterExpressionID(expressionID)
  self.curEnterExpressionID = expressionID
end
function logic_store_enter_feature:GetCurEnterExpressionID()
  return self.curEnterExpressionID
end
function logic_store_enter_feature:PlayFeatureVideo(videoCfg, isOnClick, closeDirectly, bRestoreMusic)
  local gem_report_utils = require("client.logic.store.gem_report_utils")
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  ActorVoiceSystem.StopSound()
  local result = false
  local videoPath = videoCfg.config.Video
  if videoPath ~= "" then
    local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
    log(bWriteLog and string.format("logic_store_enter_feature:PlayFeatureVideo videoCfg.video = %s closeDirectly = %s", videoPath, closeDirectly))
    result = VideoLibrary.PlayVideo(videoPath, {
      bDoNotChangeCameraSetting = true,
      bCloseDirectly = closeDirectly,
      bRestoreLobbyMusic = bRestoreMusic
    })
  end
  if not isOnClick then
    gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_StoreVideoPlayTimes, 0)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogReasonStr = json.encode({
      event_name = gem_report_utils.SubEventName_StoreVideoPlayTimes,
      play_type = "Auto"
    })
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StoreVideoPlayTimes, 0, TLogReasonStr)
    log(bWriteLog and "TLog new format, logic_store_enter_feature:PlayVideoPure auto, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
  else
    gem_report_utils.ReportLobbyClickEvent(gem_report_utils.SubEventName_StoreVideoPlayTimes, 1)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    local TLogReasonStr = json.encode({
      event_name = gem_report_utils.SubEventName_StoreVideoPlayTimes,
      play_type = "Click"
    })
    tlog_report_utils.ReportTLogEvent(TLogEventDefine.StoreVideoPlayTimes, 0, TLogReasonStr)
    log(bWriteLog and "TLog new format, logic_store_enter_feature:PlayVideoPure auto, reason : " .. tostring(0) .. " reasonStr : " .. tostring(TLogReasonStr))
  end
  return result
end
function logic_store_enter_feature:PlayFeatureVideoEmote(videoCfg, skipFullScreen, isOnClick)
  local videoPath = videoCfg.config.Video
  if videoPath == "" then
    return false
  end
  local isFullScreen = false
  if not skipFullScreen then
    if isOnClick then
      isFullScreen = true
    else
      isFullScreen = self:FeatureAutoplayHasBeenTriggeredToday(videoCfg.config.ID, true)
    end
  end
  self.isVideoEmoteFullScreen = isFullScreen
  if isFullScreen then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, false)
  end
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  VideoLibrary.StopVideoPure()
  local result = VideoLibrary.PlayVideoPure(videoPath)
  if not result and isFullScreen then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, true)
    self.isVideoEmoteFullScreen = false
  end
  return result
end
function logic_store_enter_feature:OnVideoPureClose()
  if self.isVideoEmoteFullScreen then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, true)
    self.isVideoEmoteFullScreen = false
  end
end
function logic_store_enter_feature:JudgeVideoAutoPlay(videoCfg)
  local VideoLibrary = require("client.slua.logic.video.lobby_video_function_library")
  if videoCfg and VideoLibrary.IsCanVideoFileAndReady(videoCfg.config.Video) and self:FeatureAutoplayHasBeenTriggeredToday(videoCfg.config.ID) then
    return true
  end
  return false
end
function logic_store_enter_feature:GetIsFeatureFullScreen(emoteCfg, hasVideo, isOnClick, skipFullScreen)
  local result = false
  if skipFullScreen then
    return false
  end
  if isOnClick then
    return true
  end
  result = self:FeatureAutoplayHasBeenTriggeredToday(emoteCfg.config.ID, true)
  if hasVideo and self:CheckRecommendForceFullScreen(emoteCfg.config.ID) then
    result = true
  end
  return result
end
function logic_store_enter_feature:FeatureAutoplayHasBeenTriggeredToday(featureID, isUpdateRecord)
  local haveSeen = false
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local featureViewRecordTime = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eStoreItemFeatureViewRecordToday)
  if featureViewRecordTime == nil then
    featureViewRecordTime = {}
  end
  if featureViewRecordTime[featureID] ~= nil and TimeUtil.IsSameDay(featureViewRecordTime[featureID], currentTime) then
    haveSeen = false
  else
    if isUpdateRecord then
      featureViewRecordTime[featureID] = currentTime
    end
    haveSeen = true
  end
  if isUpdateRecord and haveSeen then
    playerPrefsSystem.SaveTableToFile_N(featureViewRecordTime, playerPrefsSystem.ePlayerPrefsType.eStoreItemFeatureViewRecordToday)
  end
  log(bWriteLog and string.format("logic_store_enter_feature:HaveViewStoreItemFeatureFullScreenToday isFeatureNeedFullScreenView = %s", haveSeen))
  return haveSeen
end
function logic_store_enter_feature:MarkAutoplayHasBeenTriggered(featureID)
  local TimeUtil = require("client.common.time_util")
  local currentTime = TimeUtil.GetServerTimeInSec()
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local featureViewRecordTime = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eStoreItemFeatureViewRecordToday)
  if featureViewRecordTime == nil then
    featureViewRecordTime = {}
  end
  featureViewRecordTime[featureID] = currentTime
  playerPrefsSystem.SaveTableToFile_N(featureViewRecordTime, playerPrefsSystem.ePlayerPrefsType.eStoreItemFeatureViewRecordToday)
end
function logic_store_enter_feature:AddFeatureTimer(timerName, delay, timerHandle)
  local time_ticker = require("common.time_ticker")
  if not self.featuresTimers then
    self.featuresTimers = {}
  end
  if self.featuresTimers[timerName] then
    time_ticker.RemoveTimer(self.featuresTimers[timerName])
  end
  self.featuresTimers[timerName] = time_ticker.AddTimerOnce(delay, function(...)
    if self.featuresTimers then
      timerHandle(...)
    end
  end)
end
function logic_store_enter_feature:ClearLoopTimer()
  self:CheckRemoveTimer("loopEmotionTimer")
end
function logic_store_enter_feature:CheckRemoveTimer(timerName)
  if not self.featuresTimers then
    return
  end
  if self.featuresTimers[timerName] then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.featuresTimers[timerName])
    self.featuresTimers[timerName] = nil
  end
end
function logic_store_enter_feature:RemoveAllFeatureTimer()
  if self.featuresTimers then
    for timer, handle in pairs(self.featuresTimers) do
      local time_ticker = require("common.time_ticker")
      time_ticker.RemoveTimer(handle)
      handle = nil
    end
    self.featuresTimers = nil
  end
end
function logic_store_enter_feature:GetAutoEmotionWeightConfig(sacredSuitAutoEnterEmotion)
  local autoConfig
  if GlobalData.IsJapanOrKorea() then
    autoConfig = DeepCopy(autoFeatureConfigByJK)
  else
    autoConfig = DeepCopy(autoFeatureConfig)
  end
  if sacredSuitAutoEnterEmotion == false then
    autoConfig[ENUM_Feature_Desc_Type.ShockingAdmission] = nil
  end
  return autoConfig
end
function logic_store_enter_feature:CheckEmotionAutoPlay(newDescID, oldDescID, autoConfig)
  if newDescID == 0 and oldDescID == 0 then
    return true
  end
  local nWeight = autoConfig[newDescID] or 0
  local oWeight = autoConfig[oldDescID] or 0
  if nWeight > oWeight then
    return true
  end
  return false
end
function logic_store_enter_feature:IsNeePlayEnterEmote(itemCfg, switchConfig)
  if not itemCfg or not itemCfg.ItemID then
    return
  end
  local ItemID = itemCfg.ItemID
  local featuresItem = CDataTable.GetTableData("FeaturesItems", ItemID)
  if not (featuresItem and featuresItem.Features) or featuresItem.Features == "" then
    log(bWriteLog and string.format("logic_store_enter_feature:IsNeePlayEnterEmote ItemID = %s return false of featuresItem is nil", tostring(ItemID)))
    return false
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {ItemID})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and string.format("logic_store_enter_feature:IsNeePlayEnterEmote ItemID = %s return false of state is %s", tostring(ItemID), tostring(state)))
    return false
  end
  local FeatureCfg
  switchConfig = switchConfig or {}
  local StringUtil = require("common.string_util")
  local features = StringUtil.Split(featuresItem.Features, ";")
  local StoreUtils = require("client.slua.logic.store.utils.store_utils")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  local shieldByIN = PublishRegionMacros.IsBLUEHOLE() and ModelDisplayTypeHelper.IsKillCounter(itemCfg.ItemSubType)
  local autoConfig = self:GetAutoEmotionWeightConfig(switchConfig.sacredSuitAutoEnterEmotion)
  local bNeedPlayVideo = false
  local oldDescID = 0
  for _, v in ipairs(features) do
    local cfg = CDataTable.GetTableData("FeaturesConfig", tonumber(v))
    if cfg and not (0 >= cfg.DescID) and not StoreUtils.CheckExcludeForCurRegion(cfg) then
      if cfg.FeatureType == ENUM_FeatureType.Video then
        if not (not shieldByIN and switchConfig.skipAutoPlayVideo) then
          goto lbl_182
        end
        bNeedPlayVideo = logic_store_enter_feature:JudgeVideoAutoPlay({config = cfg})
      end
      if cfg.FeatureType == ENUM_FeatureType.Emotion or cfg.FeatureType == ENUM_FeatureType.PetEmotion or cfg.FeatureType == ENUM_FeatureType.Glide then
        if cfg.FeatureType == ENUM_FeatureType.Emotion then
          if not logic_store_enter_feature:CheckEmotionAutoPlay(cfg.DescID, oldDescID, autoConfig) then
            goto lbl_182
          end
          oldDescID = cfg.DescID
        end
        local data = StoreUtils.GetFeatureData(cfg, itemCfg.ItemType, itemCfg.ItemSubType)
        if data and next(data) then
          FeatureCfg = cfg
          break
        end
      end
    end
    ::lbl_182::
  end
  if not FeatureCfg or bNeedPlayVideo then
    log(bWriteLog and string.format("logic_store_enter_feature:IsNeePlayEnterEmote ItemID = %s return false of FeatureCfg is %s, bNeedPlayVideo is %s", tostring(ItemID), tostring(FeatureCfg), tostring(bNeedPlayVideo)))
    return false
  end
  local emotionId = self:GetPlayEmoteID(ItemID, FeatureCfg)
  if not emotionId or emotionId <= 0 then
    log(bWriteLog and string.format("logic_store_enter_feature:IsNeePlayEnterEmote ItemID = %s return false of emotionId is %s", tostring(ItemID), tostring(emotionId)))
    return false
  end
  state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {emotionId})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and string.format("logic_store_enter_feature:IsNeePlayEnterEmote emotionId = %s return false of state is %s", tostring(emotionId), tostring(state)))
    return false
  end
  return true
end
function logic_store_enter_feature:GetPlayEmoteID(ItemID, FeatureCfg)
  local emotionId = 0
  if GlobalData.IsJapanOrKorea() then
    local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
    local originID = multi_state_manager:GetOriginClothIDAndState(ItemID)
    local LogicXSuit = require("client.slua.logic.XSuit.logic_xsuit")
    if LogicXSuit.IsXSuit(ItemID) or originID and LogicXSuit.IsXSuit(originID) then
      emotionId = FeatureCfg.EnterExpressionID or 0
      if 0 < emotionId then
        return emotionId
      end
    end
    emotionId = FeatureCfg.FightExpressionID
    if emotionId <= 0 then
      emotionId = FeatureCfg.ExpressionID
    end
    if 0 < emotionId then
      return emotionId
    end
  else
    emotionId = FeatureCfg.EnterExpressionID or 0
    if 0 < emotionId then
      return emotionId
    end
    emotionId = FeatureCfg.ExpressionID
    if emotionId <= 0 then
      emotionId = FeatureCfg.FightExpressionID
    end
    if 0 < emotionId then
      return emotionId
    end
  end
  return emotionId
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_store_enter_feature)
return CModuleTemplate