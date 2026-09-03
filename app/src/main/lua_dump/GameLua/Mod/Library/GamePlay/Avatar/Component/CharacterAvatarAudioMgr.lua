local CharacterAvatarAudioMgr = {}
local Enum_AudioTriggerCondition = {
  ON_PLAY_EMOTE = 1,
  ON_KILL = 2,
  ON_PARACHUTE_JUMP = 3,
  ON_AVATAR_RORATE = 4,
  ON_DIE = 5,
  ON_SHOT = 6,
  ON_HEAL = 7,
  RANDOM_PLAY = 999
}
function CharacterAvatarAudioMgr:ctor(_, AvatarComp)
  self.Owner  self.CurrentCfg = {}
  self.CurretnAllCfg = {}
  self.CurrentItemID = nil
  self.PlayAudioDelegates = {}
  self.StopAudioTimer = nil
  self.TriggerCD = nil
  self.LoadedBnks = {}
end
function CharacterAvatarAudioMgr:_IsInFight()
  if not self.OwnerAvatarComp or not slua.isValid(self.OwnerAvatarComp) then
    log(bWriteLog and "CharacterAvatarAudioMgr:_IsInFight OwnerAvatarComp is not valid")
    return false
  end
  local OwnerCharacter = self.OwnerAvatarComp:GetOwner()
  if not slua.isValid(OwnerCharacter) then
    log(bWriteLog and "CharacterAvatarAudioMgr:_IsInFight Failed to get OwnerCharacter")
    return false
  end
  local PlayerCls = import("/Script/ShadowTrackerExtra.STExtraBaseCharacter")
  return Game:IsClassOf(OwnerCharacter, PlayerCls)
end
function CharacterAvatarAudioMgr:Init()
  if not self.OwnerAvatarComp or not slua.isValid(self.OwnerAvatarComp) then
    log(bWriteLog and "CharacterAvatarAudioMgr:Init OwnerAvatarComp is not valid")
    return
  end
  local OwnerCharacter = self.OwnerAvatarComp:GetOwner()
  if not slua.isValid(OwnerCharacter) then
    log(bWriteLog and "CharacterAvatarAudioMgr:Init Failed to get OwnerCharacter")
    return
  end
  local bIsInFight = self:_IsInFight()
  if bIsInFight then
    log(bWriteLog and "CharacterAvatarAudioMgr:Init In fight")
    local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
    if not slua.isValid(uPlayerController) then
      log(bWriteLog and "CharacterAvatarAudioMgr:Init Failed to get uPlayerController")
      return
    end
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    if not SettingConfig.LocalGamePerformanceVoice then
      log(bWriteLog and "CharacterAvatarAudioMgr:Init Game performance voice is closed value: " .. tostring(SettingConfig.LocalGamePerformanceVoice))
      return
    end
    if self.OwnerAvatarComp:IsSelf() then
      self:AddControlEvent(uPlayerController, "OnPlayerKilledOthersPlayer", self.OnPlayerKillOther, self)
      self:AddControlEvent(uPlayerController, "OnPlayerControllerStateChangedDelegate", self.OnStateChanged, self)
      self:AddControlEvent(OwnerCharacter, "OnDeathDelegate", self.OnDie, self)
      self:AddCommonEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_PLAY_AUDIO, self.PlayAudioByEvent, self)
      self:AddCommonEvent(EVENTTYPE_CHARACTER_EFFECT, EVENTID_CHARACTER_EFFECT_STOP_AUDIO, self.StopAudioByEvent, self)
    end
  else
    log(bWriteLog and "CharacterAvatarAudioMgr:Init In lobby")
    self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ACTION_PLAY_START, self.OnPlayEmote, self)
    self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_PLAY_RANDOM_VOICE_FEATURE, self.RandomPlayAudio, self)
    self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_STOP_RANDOM_VOICE_FEATURE, self.StopAudio, self)
    self:AddCommonEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_PLAY_RANDOM_VOICE, self.RandomPlayAudio, self)
    self:AddCommonEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_STOP_RANDOM_VOICE, self.StopAudio, self)
    if slua.isValid(OwnerCharacter.CapsuleComponent) then
      self:AddControlEvent(OwnerCharacter.CapsuleComponent, "OnInputTouchBegin", self.OnAvatarClicked, self)
    end
  end
end
function CharacterAvatarAudioMgr:UpdateAudioCfg(ItemID)
  if not Client then
    return
  end
  if self:_IsInFight() and not self.OwnerAvatarComp:IsSelf() then
    return
  end
  if not ItemID then
    local SlotID = 5
    local Desc = self.OwnerAvatarComp.ViewSlotDesc:Get(SlotID)
    if Desc then
      ItemID = Desc.RealShowItemDefineID.TypeSpecificID
    end
  end
  log(bWriteLog and "CharacterAvatarAudioMgr:Init ItemID: " .. tostring(ItemID))
  if not ItemID or self.CurrentItemID == ItemID then
    return
  end
  self.Current  self.CurrentCfg = {}
  self.CurrentAllCfg = {}
  self:StopAudio()
  local VoiceCfg = CDataTable.GetTableByFilter("SuitVoiceCfg", "MasterSuitID", ItemID)
  if VoiceCfg then
    local string_util = require("common.string_util")
    for _, cfg in pairs(VoiceCfg) do
      local TriggerTypes = string_util.Split(cfg.TriggerType, "|")
      local tmp = {
        VoiceID = cfg.VoiceID,
        PlayEvent = cfg.PlayEvent,
        MasterSuitID = cfg.MasterSuitID,
        Duration = cfg.Duration,
        AudioFile = cfg.AudioFile,
        Gender = cfg.Gender,
        EmoteID = cfg.EmoteID
      }
      for _, sTriggerType in pairs(TriggerTypes) do
        local Type = tonumber(sTriggerType)
        if Type then
          if not self.CurrentCfg[Type] then
            self.CurrentCfg[Type] = {}
          end
          table.insert(self.CurrentCfg[Type], tmp)
        end
      end
      table.insert(self.CurrentAllCfg, tmp)
    end
  end
end
function CharacterAvatarAudioMgr:PlayAudio(EventPath, Duration)
  local UAkGameplayStatics = import("AkGameplayStatics")
  local UIUtil = require("client.common.ui_util")
  local worldContextObject = UIUtil.GetGameInstance()
  if not slua.isValid(self.OwnerAvatarComp) or not slua.isValid(self.OwnerAvatarComp:GetOwner()) then
    return
  end
  local CharacterLocation = self.OwnerAvatarComp:GetOwner():GetTransform():GetLocation()
  local time_ticker = require("common.time_ticker")
  local util = require("client.slua_ui_framework.util")
  if self.StopAudioTimer then
    log(bWriteLog and "CharacterAvatarAudioMgr:PlayAudio Playing, ignore next event")
    return
  end
  self.PlayingAkID = UAkGameplayStatics.PostEventAtLocation(nil, CharacterLocation, FRotator.ZeroRotator, EventPath, worldContextObject)
  log(bWriteLog and "CharacterAvatarAudioMgr:PlayAudio PlayingAkID " .. tostring(self.PlayingAkID))
  self.StopAudioTimer = time_ticker.AddTimerOnce(Duration, function()
    self.StopAudioTimer = nil
    self:StopAudio()
  end)
end
function CharacterAvatarAudioMgr:StopAudio()
  local UAkGameplayStatics = import("AkGameplayStatics")
  local time_ticker = require("common.time_ticker")
  if self.PlayingAkID then
    UAkGameplayStatics.StopPlayingID(self.PlayingAkID)
    self.PlayingAkID = nil
  end
  if self.StopAudioTimer then
    time_ticker.RemoveTimer(self.StopAudioTimer)
    self.StopAudioTimer = nil
  end
end
function CharacterAvatarAudioMgr:PlayAudioByEvent(_, _, Param)
  log(bWriteLog and "CharacterAvatarAudioMgr:PlayAudioByEvent " .. tostring(Param))
  local triggerType = tonumber(Param)
  if triggerType then
    self:PlayRandomAudioByTriggerType(triggerType)
  end
end
function CharacterAvatarAudioMgr:StopAudioByEvent(_, _)
  log(bWriteLog and "CharacterAvatarAudioMgr:StopAudioByEvent ")
  self:StopAudio()
end
function CharacterAvatarAudioMgr:Clear()
  self:Dispose()
end
function CharacterAvatarAudioMgr:Destroy()
  log(bWriteLog and "CharacterAvatarAudioMgr:Destroy")
  self:StopAudio()
  for Bnk, _ in pairs(self.LoadedBnks) do
    local UAkGameplayStatics = import("AkGameplayStatics")
    UAkGameplayStatics.UnloadBankByName(Bnk)
  end
  self:Clear()
end
function CharacterAvatarAudioMgr:PlayRandomAudioByTriggerType(TriggerType, Param)
  if not self.CurrentCfg[TriggerType] and TriggerType ~= Enum_AudioTriggerCondition.RANDOM_PLAY then
    log(bWriteLog and "CharacterAvatarAudioMgr:PlayRandomAudioByTriggerType not valid")
    return
  end
  local checker = function(VoiceCfg, TriggerType, Param)
    if not Game:IsValid(VoiceCfg) or not slua.isValid(self.OwnerAvatarComp) then
      return false
    end
    if VoiceCfg.Gender ~= 0 and self.OwnerAvatarComp.gender + 1 ~= VoiceCfg.Gender then
      return false
    end
    if TriggerType == Enum_AudioTriggerCondition.RANDOM_PLAY then
      return true
    end
    if TriggerType == Enum_AudioTriggerCondition.ON_PLAY_EMOTE and VoiceCfg.EmoteID ~= Param then
      return false
    end
    return true
  end
  local TempArray = {}
  local SrcVoiceList
  if TriggerType == Enum_AudioTriggerCondition.RANDOM_PLAY then
    SrcVoiceList = self.CurrentAllCfg
  else
    SrcVoiceList = self.CurrentCfg[TriggerType]
  end
  for index, cfg in pairs(SrcVoiceList) do
    if checker(cfg, TriggerType, Param) then
      table.insert(TempArray, cfg)
    end
  end
  if 0 < #TempArray then
    local cfg = TempArray[math.random(1, #TempArray)]
    local UAkGameplayStatics = import("AkGameplayStatics")
    UAkGameplayStatics.LoadBankByName(cfg.AudioFile)
    self.LoadedBnks[cfg.AudioFile] = true
    log(bWriteLog and string.format("CharacterAvatarAudioMgr:PlayRandomAudioByTriggerType Bnk: %s, Event: %s", cfg.AudioFile, cfg.PlayEvent))
    self:PlayAudio(cfg.PlayEvent, cfg.Duration)
  else
    log(bWriteLog and "CharacterAvatarAudioMgr:PlayRandomAudioByTriggerType No suitable cfg")
  end
end
function CharacterAvatarAudioMgr:OnPlayEmote(_, _, AvatarComp, EmoteID)
  log(bWriteLog and "CharacterAvatarAudioMgr:OnPlayEmote EmoteID = " .. tostring(EmoteID))
  if not slua.isValid(self.OwnerAvatarComp) then
    return
  end
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  if not logic_display_setting.LobbyPerformanceVoice() then
    return
  end
  local OwnerPawn = self.OwnerAvatarComp:GetOwner()
  if not self.OwnerAvatarComp:IsLobbyActor() or self.OwnerAvatarComp ~= AvatarComp then
    log(bWriteLog and "CharacterAvatarAudioMgr:OnPlayEmote Not current pawn")
    return
  end
  self:PlayRandomAudioByTriggerType(Enum_AudioTriggerCondition.ON_PLAY_EMOTE, EmoteID)
end
function CharacterAvatarAudioMgr:OnPlayerKillOther(FatalDamageParameter)
  log(bWriteLog and "CharacterAvatarAudioMgr:OnPlayerKillOther")
  local MyPlayKey = slua.isValid(self.OwnerAvatarComp) and self.OwnerAvatarComp:GetOwner().PlayerKey
  local DamageCauserKey = FatalDamageParameter and FatalDamageParameter.causerKey
  if not MyPlayKey or MyPlayKey ~= DamageCauserKey then
    print(bWriteLog and string.format("CharacterAvatarAudioMgr:OnPlayerKillOther Self is not killer %s %s", tostring(MyPlayKey), tostring(DamageCauserKey)))
    return
  end
  self:PlayRandomAudioByTriggerType(Enum_AudioTriggerCondition.ON_KILL)
end
function CharacterAvatarAudioMgr:OnStateChanged(StateType)
  log(bWriteLog and "CharacterAvatarAudioMgr:OnStateChanged StateType: " .. tostring(StateType))
  local EStateType = import("EStateType")
  if StateType == EStateType.State_ParachuteJump then
    self:PlayRandomAudioByTriggerType(Enum_AudioTriggerCondition.ON_PARACHUTE_JUMP)
  end
end
function CharacterAvatarAudioMgr:OnAvatarClicked()
  local logic_display_setting = require("client.slua.logic.wardrobe.logic_display_setting")
  if not logic_display_setting.LobbyPerformanceVoice() then
    return
  end
  local OwnerPawn = self.OwnerAvatarComp:GetOwner()
  if not self.OwnerAvatarComp:IsLobbyActor() then
    return
  end
  if self.TriggerCD then
    return
  end
  log(bWriteLog and "CharacterAvatarAudioMgr:OnAvatarClicked")
  self:PlayRandomAudioByTriggerType(Enum_AudioTriggerCondition.ON_AVATAR_RORATE)
  local time_ticker = require("common.time_ticker")
  self.TriggerCD = true
  time_ticker.AddTimerOnce(10, function()
    self.TriggerCD = nil
  end)
end
function CharacterAvatarAudioMgr:OnDie(Character)
  log(bWriteLog and "CharacterAvatarAudioMgr:OnDie")
  local time_ticker = require("common.time_ticker")
  self:PlayRandomAudioByTriggerType(Enum_AudioTriggerCondition.ON_DIE)
end
function CharacterAvatarAudioMgr:RandomPlayAudio()
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local TargetAvatar = ModelDisplayer.GetShowingAvatar() or TeamAvatarManager:GetMainAvatar()
  if not TargetAvatar or TargetAvatar:GetModelAvatarComp() ~= self.OwnerAvatarComp then
    return
  end
  log(bWriteLog and "CharacterAvatarAudioMgr:RandomPlayAudio")
  self:PlayRandomAudioByTriggerType(Enum_AudioTriggerCondition.RANDOM_PLAY)
end
local class = require("class")
local object = require("common.delegate_container")
local CCharacterAvatarAudioMgr = class(object, nil, CharacterAvatarAudioMgr)
return CCharacterAvatarAudioMgr