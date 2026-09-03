local audio_util = {}
local zeroLocation = FVector(0)
local zeroRotator = FRotator(0)
local GMDebug = false
local _GMShowNotice = false
local local local local local local local string_format = string.format
local TimeUtil = require("client.common.time_util")
local asset_util = require("common.asset_util")
local USTExtraBlueprintFunctionLibrary = import("STExtraBlueprintFunctionLibrary")
local IsDevelopment = import("STExtraBlueprintFunctionLibrary").IsDevelopment()
local _PostEventAtLocation = function(akEvent, location, rotator, eventName, worldContextObject)
  local AkGameplayStatics = import("AkGameplayStatics")
  eventName = eventName or ""
  if not worldContextObject then
    local UIUtil = require("client.common.ui_util")
    worldContextObject = UIUtil.GetGameInstance()
  end
  if slua.isValid(worldContextObject) then
    return AkGameplayStatics.PostEventAtLocation(akEvent, location, rotator, eventName, worldContextObject)
  end
end
function audio_util.PlayAudio(audioPath, worldContextObject, eventName)
  if not assert(audioPath, "audio_util.PlayAudio audioPath should not be nil") then
    return
  end
  if not assert(audioPath ~= "", "audio_util.PlayAudio audioPath should not be empty") then
    return
  end
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  local akEvent = asset_util.GetAssetSync(audioPath)
  if GMDebug then
    local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
    log(bWriteLog and string_format("audio_util.PlayAudio:%s time:%fms", audioPath, timeSpan))
  else
    log(bWriteLog and "audio_util.PlayAudio" .. tostring(audioPath))
  end
  local AudioID
  if akEvent ~= nil then
    AudioID = _PostEventAtLocation(akEvent, zeroLocation, zeroRotator, eventName, worldContextObject)
  else
    log_error(bWriteLog and string_format("Can't load audio from path[%s]", audioPath))
  end
  return AudioID
end
function audio_util.PlayAudioAsync(audioPath, worldContextObject, eventName, LoadBackPostEventCallback)
  if not assert(audioPath, "audio_util.PlayAudioAsync audioPath should not be nil") then
    return
  end
  if not assert(audioPath ~= "", "audio_util.PlayAudioAsync audioPath should not be empty") then
    return
  end
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  local HandleID = asset_util.GetAssetAsync(audioPath, function(akEvent)
    local AudioID
    if slua.isValid(akEvent) then
      if GMDebug then
        local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
        log(bWriteLog and string_format("audio_util.PlayAudioAsync:%s time:%fms", audioPath, timeSpan))
      end
      AudioID = _PostEventAtLocation(akEvent, zeroLocation, zeroRotator, eventName, worldContextObject)
    else
      log_error("audio_util.PlayAudioAsync Failed to load the sound asset")
    end
    if LoadBackPostEventCallback then
      LoadBackPostEventCallback(AudioID, audioPath)
    end
  end)
  return HandleID
end
function audio_util.PlayAudioAsyncAtLocation(audioPath, inLocation, inRotation, worldContextObject, eventName, callback)
  if not assert(audioPath, "audio_util.PlayAudioAsyncAtLocation audioPath should not be nil") then
    return
  end
  if not assert(audioPath ~= "", "audio_util.PlayAudioAsyncAtLocation audioPath should not be empty") then
    return
  end
  inLocation = inLocation or zeroLocation
  inRotation = inRotation or zeroRotator
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  asset_util.GetAssetAsync(audioPath, function(akEvent)
    if slua.isValid(akEvent) then
      if GMDebug then
        local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
        log(bWriteLog and string_format("audio_util.PlayAudioAsyncAtLocation:%s time:%fms", audioPath, timeSpan))
      end
      local playingID = _PostEventAtLocation(akEvent, inLocation, inRotation, eventName, worldContextObject)
      if callback then
        callback(playingID)
      end
    else
      log_error("audio_util.PlayAudioAsync Failed to load the sound asset")
    end
  end)
end
function audio_util.PlayAudioByActor(audioPath, actor)
  if not assert(audioPath, "audio_util.PlayAudioByActor audioPath should not be nil") then
    return
  end
  if not assert(audioPath ~= "", "audio_util.PlayAudioByActor audioPath should not be empty") then
    return
  end
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  local akEvent = asset_util.GetAssetSync(audioPath)
  if GMDebug then
    local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
    log(bWriteLog and string_format("audio_util.PlayAudioByActor:%s time:%fms", audioPath, timeSpan))
  else
    log(bWriteLog and "audio_util.PlayAudioByActor, audioPath = " .. audioPath)
  end
  if akEvent ~= nil then
    local AkGameplayStatics = import("AkGameplayStatics")
    if not actor then
      local GameplayStatics = import("GameplayStatics")
      local world = slua_GameFrontendHUD:GetWorld()
      local playerCameraManager = GameplayStatics.GetPlayerCameraManager(world, 0)
      if playerCameraManager == nil then
        log(bWriteLog and "[tinghaohu][util] PlayAudioByActor playerCameraManager is nil")
        return
      end
      actor = playerCameraManager
    end
    local playingID = AkGameplayStatics.PostEvent(akEvent, actor, false, "")
    return akEvent, playingID
  else
    log_error(string_format("Can't load audio from path[%s]", audioPath))
    return nil, nil
  end
end
function audio_util.PlayAudioByActorAsync(audioPath, actor, callback, bStopWhenActorDestroy)
  if not assert(audioPath, "audio_util.PlayAudioByActorAsync audioPath should not be nil") then
    return
  end
  if not assert(audioPath ~= "", "audio_util.PlayAudioByActorAsync audioPath should not be empty") then
    return
  end
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  local HandleID = asset_util.GetAssetAsync(audioPath, function(akEvent)
    local PlayingID = -1
    if akEvent then
      if GMDebug then
        local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
        log(bWriteLog and string_format("audio_util.PlayAudioByActorAsync:%s time:%fms", audioPath, timeSpan))
      end
      local AkGameplayStatics = import("AkGameplayStatics")
      local bStopWhenAttachedToDestroyed = bStopWhenActorDestroy or false
      if not slua.isValid(actor) then
        if bStopWhenAttachedToDestroyed then
          log_error("audio_util.PlayAudioByActorAsync actor has been destroyed")
          return
        end
        local GameplayData = require("GameLua.GameCore.Data.GameplayData")
        actor = GameplayData.GetPlayerController()
      end
      if slua.isValid(actor) then
        PlayingID = AkGameplayStatics.PostEvent(akEvent, actor, bStopWhenAttachedToDestroyed, "")
      end
    else
      log_error("audio_util.PlayAudioByActorAsync Failed to load the sound asset")
    end
    if callback then
      callback(PlayingID)
    end
  end)
  return HandleID
end
function audio_util.PlaySound(eventName, switchState, worldContextObject, downloadIfNotExist)
  local AkGameplayStatics = import("AkGameplayStatics")
  if switchState ~= nil and switchState ~= "" then
    log(bWriteLog and string_format("audio_util.PlaySound, switchState:%s", switchState))
    local exist = true
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    exist = PufferManager.IsBankExist(switchState, downloadIfNotExist)
    if not exist then
      log(bWriteLog and "audio_util.PlaySound, not exist. ")
      local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
      local actorID = ActorVoiceSystem.GetDefaultActorID()
      switchState = CDataTable.GetTableData("VoiceActorCfg", actorID).BankName
      local StringUtil = require("common.string_util")
      local result = StringUtil.Split(eventName, "_")
      local msgID = result[#result]
      eventName = "play_chat_" .. tostring(actorID) .. "_" .. tostring(msgID)
    end
    log(bWriteLog and string_format("audio_util.PlaySound, switchState:%s", switchState))
    AkGameplayStatics.LoadBank(nil, switchState)
  end
  if _GMShowNotice and IsDevelopment then
    ShowNotice("PlaySound >>> " .. eventName)
  end
  return AkGameplayStatics.PostEventAtLocation(nil, zeroLocation, zeroRotator, eventName or "", worldContextObject)
end
function audio_util.TryPlayBankAudio(eventName, bankName, worldContextObject, downloadIfNotExist, Location, Rotation)
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local exist = PufferManager.IsBankExist(bankName, downloadIfNotExist)
  if not exist then
    return nil
  end
  Location = Location or zeroLocation
  Rotation = Rotation or zeroRotator
  local AkGameplayStatics = import("AkGameplayStatics")
  AkGameplayStatics.LoadBank(nil, bankName)
  return _PostEventAtLocation(nil, Location, Rotation, eventName or "", worldContextObject)
end
function audio_util.SetRTPCValue(RTPC, Value, InterpolationTimeMs)
  local AkGameplayStatics = import("AkGameplayStatics")
  log(bWriteLog and "audio_util.SetRTPCValue RTPC:" .. RTPC .. " Value:" .. Value .. " InterpolationTimeMs:" .. InterpolationTimeMs)
  AkGameplayStatics.SetRTPCValue(RTPC, Value, InterpolationTimeMs, nil)
end
function audio_util.AKSetRTPCValue(RTPC, Value, in_bBypassInternalValueInterpolation)
  local AkGameplayStatics = import("AkGameplayStatics")
  log(bWriteLog and "audio_util.AKSetRTPCValue RTPC:" .. RTPC .. " Value:" .. Value .. " in_bBypassInternalValueInterpolation:" .. tostring(in_bBypassInternalValueInterpolation))
  AkGameplayStatics.AKSetRTPCValue(RTPC, Value, in_bBypassInternalValueInterpolation)
end
function audio_util.StopSound(playingID)
  local AkGameplayStatics = import("AkGameplayStatics")
  AkGameplayStatics.StopPlayingID(playingID)
end
function audio_util.PlayAudioByActorInRangeAsync(audioPath, actor, rangeSquare, callback)
  if rangeSquare <= 0 then
    log(bWriteLog and string_format("audio_util.PlayAudioByActorInRangeAsync:%s rangeSquare <=0", audioPath))
    return
  end
  if not assert(audioPath, "audio_util.PlayAudioByActorInRangeAsync audioPath should not be nil") then
    return
  end
  if not assert(audioPath ~= "", "audio_util.PlayAudioByActorInRangeAsync audioPath should not be empty") then
    return
  end
  local startTime
  if GMDebug then
    startTime = TimeUtil.GetMicroseconds()
  end
  asset_util.GetAssetAsync(audioPath, function(akEvent)
    local uAkComponent
    if akEvent and slua.isValid(actor) then
      if GMDebug then
        local timeSpan = (TimeUtil.GetMicroseconds() - startTime) / 1000
        log(bWriteLog and string_format("audio_util.PlayAudioByActorInRangeAsync:%s time:%fms", audioPath, timeSpan))
      end
      local AkGameplayStatics = import("AkGameplayStatics")
      uAkComponent = AkGameplayStatics.PostEventInRange(akEvent, actor, rangeSquare)
    else
      log(bWriteLog and string_format("audio_util.PlayAudioByActorInRangeAsync Can't load audio from path[%s] or actor is not valid", audioPath))
    end
    if callback then
      callback(uAkComponent)
    end
  end)
end
function audio_util.StopSoundInRange(uAkComponent)
  if slua.isValid(uAkComponent) then
    uAkComponent:StopEventInRange()
  end
end
function audio_util.SetGMShowNotice(bIsShowNotice)
  _GMShowNotice = bIsShowNotice
end
return audio_util