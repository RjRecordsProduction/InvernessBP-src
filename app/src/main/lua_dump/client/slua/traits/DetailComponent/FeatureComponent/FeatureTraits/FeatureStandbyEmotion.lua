local FeatureStandbyEmotion = {}
local Trait = require("common.trait")
local TFeatureStandbyEmotion = Trait(Trait.TraitPrototype, nil, FeatureStandbyEmotion)
local EmotionBegin = function()
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, false, true)
end
local EmotionEnd = function(id)
  local isShowVideo = UIManager.IsUIShow(UIManager.UI_Config.video_player_system_pure)
  if not isShowVideo then
    EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_CRATE_HIDEUI, true, id)
  end
  EventSystem:postEvent(EVENTTYPE_STORE, EVENTID_STORE_EMOTION_STOP, id)
end
function FeatureStandbyEmotion:PlayAvatarStandbyEmotion(data)
  self:NotifyOtherFeatureStop(data)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    self.curFeaturesItemID
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    if state == PufferConst.ENUM_DownloadState.Not then
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {
        self.curFeaturesItemID
      })
    end
    ShowNotice(511044)
    return
  end
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  logic_store_enter_feature:SetCurEnterExpressionID(nil)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local showingAvatar = ModelDisplayer.GetShowingAvatar()
  if showingAvatar then
    showingAvatar:StopAction()
  end
  ModelDisplayer.Display(self.curFeaturesItemID, true, {
    bIsAsync = false,
    emotionStartCallback = EmotionBegin,
    emotionEndCallback = EmotionEnd,
    bPlayingWeapon = true,
    enableCameraAnim = true,
    bForceCharacter = true
  })
  local standbyActionID = 12219414
  if showingAvatar then
    showingAvatar:PlayAction(standbyActionID)
  end
  self.bIsPlayingAvatarStandbyEmotion = true
end
function FeatureStandbyEmotion:StopAvatarStandbyEmotion()
  if self.bIsPlayingAvatarStandbyEmotion then
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    if ModelDisplayer.GetShowingAvatar() then
      ModelDisplayer.GetShowingAvatar():StopAction()
    end
    self.bIsPlayingAvatarStandbyEmotion = false
  end
end
return TFeatureStandbyEmotion