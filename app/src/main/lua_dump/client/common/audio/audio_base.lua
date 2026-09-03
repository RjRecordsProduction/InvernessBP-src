local audio_base = {}
local AkGameplayStatics = import("AkGameplayStatics")
local GameplayStatics = import("GameplayStatics")
local local local local TimeUtil = require("client.common.time_util")
local string_format = string.format
local local slua_isValid = slua.isValid
local slua_addRef = slua.addRef
local slua_removeRef = slua.removeRef
local C_DefalutPosition = -1
local GMDebug = false
function audio_base:ctor()
  self._sound_id = nil
  self._path = nil
  self._type = nil
  self._AkEvent = nil
  self._position = nil
  self._AkPlayingID = nil
  self._actor = nil
end
function audio_base:InitBySoundConfig(config)
  if not config then
    log_error("audio_base:InitBySoundConfig, config == nil. ")
    return
  end
  self._sound_id = config.ID
  self._path = config.Path
  self._type = config.Type
  if not assert_format(self._path ~= "", "audio_base:self._path invalid, _sound_id:%s", self._sound_id) then
    return
  end
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  local asset_util = require("common.asset_util")
  self._AkEvent = asset_util.GetAssetSync(self._path)
  if self._AkEvent == nil then
    log_error("audio_base:InitBySoundConfig, _AkEvent == nil.  _path:" .. self._path)
    return
  end
  slua_addRef(self._AkEvent)
  self._position = C_DefalutPosition
  if GMDebug then
    local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
    log(bWriteLog and string_format("audio_base:InitBySoundConfig,_sound_id:%s _path:%s time:%fms", self._sound_id, self._path, timeSpan))
  else
    log(bWriteLog and string_format("audio_base:InitBySoundConfig,_sound_id:%s _path:%s", self._sound_id, self._path))
  end
end
function audio_base:Start()
  if not self:_PlayAndCheckStop() then
    return
  end
  if GMDebug then
    log(bWriteLog and string_format("audio_base:Start, _sound_id:%s _path:%s", self._sound_id, self._path))
  end
end
function audio_base:Pause()
  if not self._AkPlayingID then
    log_error("audio_base:Pause, _AkPlayingID == nil _sound_id:" .. self._sound_id)
    return
  end
  self._position = self:GetSourcePlayPosition()
  if GMDebug then
    log(bWriteLog and string_format("audio_base:Pause, _sound_id:%s\239\188\140 _AkPlayingID:%s, _path:%s\239\188\140_position:%d", self._sound_id, self._AkPlayingID, self._path, self._position))
  end
  AkGameplayStatics.StopPlayingID(self._AkPlayingID)
  self._AkPlayingID = nil
end
function audio_base:Resume()
  if not self:_PlayAndCheckStop() then
    return
  end
  if self._position == C_DefalutPosition then
    log_error("audio_base:Resume, _position == C_DefalutPosition. ")
  end
  if GMDebug then
    log(bWriteLog and string_format("audio_base:Resume, _sound_id:%s, _path:%s _position:%d", self._sound_id, self._path, self._position))
  end
  AkGameplayStatics.SeekOnEvent(self._AkEvent, self._actor, self._position, "", false)
end
function audio_base:Stop()
  if not self._AkPlayingID then
    log_error("audio_base:Stop, _AkPlayingID == nil _sound_id:" .. self._sound_id)
    return
  end
  if GMDebug then
    log(bWriteLog and string_format("audio_base:Stop, _sound_id:%s, _path:%s\239\188\140_position:%d", self._sound_id, self._path, self._position))
  end
  AkGameplayStatics.StopPlayingID(self._AkPlayingID)
  self._AkPlayingID = nil
  return self._type
end
function audio_base:ResumeAtTime(time)
  if not self:_PlayAndCheckStop() then
    return
  end
  self._position = time
  if GMDebug then
    log(bWriteLog and string_format("audio_base:ResumeAtTime, _sound_id:%s\239\188\140_path:%s _position:%d", self._sound_id, self._path, self._position))
  end
  AkGameplayStatics.SeekOnEvent(self._AkEvent, self._actor, self._position, "", false)
end
function audio_base:GetSourcePlayPosition()
  if not self._AkPlayingID then
    log_error("audio_base:GetSourcePlayPosition, _AkPlayingID == nil _sound_id:" .. self._sound_id)
    return C_DefalutPosition
  end
  self._position = AkGameplayStatics.GetSourcePlayPosition(self._AkPlayingID)
  if GMDebug then
    log(bWriteLog and string_format("audio_base:GetSourcePlayPosition, _sound_id:%s, _path:%s _position:%d", self._sound_id, self._path, self._position))
  end
  return self._position
end
function audio_base:GetSourcePausePosition()
  if GMDebug then
    log(bWriteLog and string_format("audio_base:GetSourcePausePosition, _sound_id:%s, _path:%s _position:%d", self._sound_id, self._path, self._position))
  end
  return self._position
end
function audio_base:Release()
  local audio_manager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.audio_manager)
  audio_manager:Release(self._sound_id)
end
function audio_base:OnRelease()
  if GMDebug then
    log(bWriteLog and "audio_base:Release _sound_id:" .. self._sound_id)
  end
  if self:GetSourcePlayPosition() ~= C_DefalutPosition then
    self:Stop()
  end
  if self._AkEvent ~= nil then
    slua_removeRef(self._AkEvent)
    self._AkEvent = nil
  end
  self._actor = nil
end
function audio_base:GetAudioType()
  return self._type
end
function audio_base:GetAudioID()
  return self._sound_id
end
function audio_base:GetAudioName()
  return self._path
end
function audio_base:_PlayAndCheckStop()
  if not slua_isValid(self._AkEvent) then
    log_error("audio_base:_PlayAndCheckStop, _AkEvent is nil")
    return false
  end
  if not self:_GetOrCreateActor() then
    log_error("audio_base:_PlayAndCheckStop, _actor is nil")
    return false
  end
  if self._AkPlayingID and self._type ~= UEnums.LobbyAudioType.UI then
    AkGameplayStatics.StopPlayingID(self._AkPlayingID)
  end
  self._AkPlayingID = AkGameplayStatics.PostEvent(self._AkEvent, self._actor, false, "")
  return true
end
function audio_base:_GetOrCreateActor()
  if slua_isValid(self._actor) then
    return self._actor
  end
  local world = slua_GameFrontendHUD:GetWorld()
  if not slua_isValid(world) then
    return nil
  end
  self._actor = GameplayStatics.GetPlayerCameraManager(world, 0)
  return self._actor
end
local class = require("class")
local object = require("object")
local CAudioBase = class(object, nil, audio_base)
return CAudioBase