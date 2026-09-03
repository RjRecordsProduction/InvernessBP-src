local VoiceTransformSubsystem = {}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local table_util = require("common.table_util")
function VoiceTransformSubsystem:ctor()
  self.TransformCache = {}
  self.BankCache = {}
  self.ActorTableCache = {}
end
function VoiceTransformSubsystem:OnInit()
  print(bWriteLog and "VoiceTransformSubsystem:OnInit")
end
function VoiceTransformSubsystem:OnRelease()
  print(bWriteLog and "VoiceTransformSubsystem:OnRelease")
  self.TransformCache = {}
  self.BankCache = {}
  self.ActorTableCache = {}
  VoiceTransformSubsystem.__super.OnRelease(self)
end
function VoiceTransformSubsystem:TransformMsgID(OriMsgID)
  if not LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) and self.TransformCache[OriMsgID] then
    return self.TransformCache[OriMsgID]
  end
  local TransformedID = OriMsgID
  local ActorVoiceID = self:CheckActorVoice(OriMsgID)
  if ActorVoiceID and ActorVoiceID ~= 0 then
    TransformedID = ActorVoiceID
  end
  local DefaultMsgID = self:CheckDefaultMsgID(TransformedID)
  if DefaultMsgID and DefaultMsgID ~= 0 then
    TransformedID = DefaultMsgID
  end
  if not LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) then
    self.TransformCache[OriMsgID] = TransformedID
  end
  return TransformedID
end
function VoiceTransformSubsystem:CheckActorVoice(OriMsgID)
  if LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH_V2) then
    local SettingConfig = slua_GameFrontendHUD:GetUserSettings()
    local PlayerFeatureVoiceCfg = SettingConfig.PlayerFeatureVoiceCfg
    if not PlayerFeatureVoiceCfg then
      print(bWriteLog and "[Voice] No PlayerFeatureVoiceCfg field in SettingConfig")
      return nil
    end
    local SettingValue = PlayerFeatureVoiceCfg:Get(tostring(OriMsgID))
    if not SettingValue then
      print(bWriteLog and "[Voice] No setting value for OriMsgID:", OriMsgID)
      return nil
    end
    local StringUtil = require("common.string_util")
    local VoiceKeyList = StringUtil.Split(SettingValue, "|")
    if not VoiceKeyList or not next(VoiceKeyList) then
      print(bWriteLog and "[Voice] Responding setting value is not a list")
      return nil
    end
    local VoiceKey = tonumber(VoiceKeyList[math.random(#VoiceKeyList)])
    return VoiceKey
  end
  if LobbySystem.CheckOpen(BP_EUNM_NEW_ACTOR_VOICE_FEATURES_SWITCH) then
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if not SettingSubsystem then
      return nil
    end
    local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
    local SettingValue = SettingSubsystem:GetUserSettings_Int("PlayerChatActorID")
    if not SettingValue or not ActorVoiceSystem.CheckIsActorValid(SettingValue) then
      return nil
    end
    local ActorFeatureData = CDataTable.GetTableData("ActorVoiceFeatures", SettingValue)
    if not ActorFeatureData then
      return nil
    end
    local StringUtil = require("common.string_util")
    for Key, Value in pairs(ActorFeatureData) do
      if Key ~= "ActorID" then
        if type(Value) == "number" and Value % 100000 == OriMsgID then
          return Value
        elseif type(Value) == "string" then
          local MsgIDs = StringUtil.Split(Value, "|")
          for _, IDStr in ipairs(MsgIDs) do
            local IDNum = tonumber(IDStr)
            if IDNum and IDNum % 100000 == OriMsgID then
              return IDNum
            end
          end
        end
      end
    end
    return nil
  end
  local SoundMsgID = math.floor(OriMsgID % 100000)
  local SoundActorID = math.floor(OriMsgID / 100000)
  if SoundActorID == 0 then
    return nil
  end
  local ActorTableData = self:GetActorTableData(SoundActorID)
  if not ActorTableData then
    return nil
  end
  if ActorTableData.VoiceTypeV2 and ActorTableData.VoiceTypeV2 ~= 0 then
    return ActorTableData.VoiceTypeV2 * 100000 + SoundMsgID
  end
  if ActorTableData.VoiceType and ActorTableData.VoiceType ~= 0 then
    return ActorTableData.VoiceType * 100000 + SoundMsgID
  end
  return nil
end
function VoiceTransformSubsystem:CheckDefaultMsgID(OriMsgID)
  local Region = Client and Client.GetPublishRegion() or PublishRegionMacros.GLOBAL
  local SoundConfig = GamePlayTools.GetCurrentConfig("SoundConfig")
  if not SoundConfig or not SoundConfig.RegionDefaultVoice then
    return nil
  end
  local RegionVoiceConfig = SoundConfig.RegionDefaultVoice[OriMsgID]
  if not RegionVoiceConfig then
    return nil
  end
  print(bWriteLog and "VoiceTransformSubsystem:CheckDefaultMsgID RegionID:" .. tostring(Region))
  if Region == PublishRegionMacros.JAPAN and RegionVoiceConfig.JAPAN then
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) then
      local Gender = uPlayerState.Gender
      if Gender and RegionVoiceConfig.JAPAN[Gender] then
        return RegionVoiceConfig.JAPAN[Gender]
      end
    end
  end
  if Region == PublishRegionMacros.KOREA and RegionVoiceConfig.KOREA then
    local uPlayerState = GameplayData.GetPlayerState()
    if slua.isValid(uPlayerState) then
      local Gender = uPlayerState.Gender
      if Gender and RegionVoiceConfig.KOREA[Gender] then
        return RegionVoiceConfig.KOREA[Gender]
      end
    end
  end
  return nil
end
function VoiceTransformSubsystem:GetAutoLanguageMsg(ActorID, MsgID)
  print(bWriteLog and string.format("VoiceTransformSubsystem:GetAutoLanguageMsg ActorID: %d, MsgID: %d", ActorID, MsgID))
  local DefaultBankName = self:GetActorBankByID(ActorID)
  local DefaultEventName = "play_chat_" .. tostring(ActorID) .. "_" .. tostring(MsgID)
  if not LobbySystem.CheckOpen(BP_ENUM_MULTI_LANGUAGE_SOUND_SWITCH) then
    print(bWriteLog and "VoiceTransformSubsystem:GetAutoLanguageMsg [1] Multi-language switch closed")
    return DefaultBankName, DefaultEventName
  end
  local VoiceActorData = self:GetActorTableData(ActorID)
  if not VoiceActorData then
    print(bWriteLog and "VoiceTransformSubsystem:GetAutoLanguageMsg [2] No voiceActorData")
    return DefaultBankName, DefaultEventName
  end
  if VoiceActorData.IsMultiLanguage ~= 1 then
    print(bWriteLog and "VoiceTransformSubsystem:GetAutoLanguageMsg [3] IsMultiLanguage false")
    return DefaultBankName, DefaultEventName
  end
  local ActorVoiceSystem = require("client.slua.logic.actor_voice.logic_actor_voice")
  local bIsLoopPlay, nMapActorId, nLoopPlayIndex = ActorVoiceSystem.GetIsMultiLanguageLoopPlay(ActorID, MsgID)
  if not bIsLoopPlay then
    local Language = Client.GetCurrentLanguage()
    local ActorKey = tostring(ActorID) .. "_" .. Language
    local MultiLanguageActorCfg = CDataTable.GetTableData("MultiLanguageActor", ActorKey)
    if not MultiLanguageActorCfg or not MultiLanguageActorCfg.ActorID then
      print(bWriteLog and "VoiceTransformSubsystem:GetAutoLanguageMsg [4] No multiLanguageActorCfg: " .. ActorKey)
      return DefaultBankName, DefaultEventName
    end
    nMapActorId = MultiLanguageActorCfg.ActorID
  end
  local VoiceActorDataForMultiLanguage = CDataTable.GetTableData("VoiceActorCfg", nMapActorId)
  if not VoiceActorDataForMultiLanguage then
    print(bWriteLog and "VoiceTransformSubsystem:GetAutoLanguageMsg [5] No voiceActorDataForMultiLanguage")
    return DefaultBankName, DefaultEventName
  end
  local MultiLanguageBankName = VoiceActorDataForMultiLanguage.BankName
  if not self:CheckVoiceBankExists(nMapActorId * 100000) then
    print(bWriteLog and "VoiceTransformSubsystem:GetAutoLanguageMsg [6] Bank not exist: " .. MultiLanguageBankName)
    return DefaultBankName, DefaultEventName
  end
  if bIsLoopPlay then
    ActorVoiceSystem.SaveMultiLugShowIndex(ActorID, MsgID, nLoopPlayIndex)
  end
  local NewEventName = "play_chat_" .. tostring(nMapActorId) .. "_" .. tostring(MsgID)
  print(bWriteLog and string.format("VoiceTransformSubsystem:GetAutoLanguageMsg [7] Success: %s, %s", MultiLanguageBankName, NewEventName))
  return MultiLanguageBankName, NewEventName
end
function VoiceTransformSubsystem:GetActorBankByID(ActorID)
  if self.BankCache[ActorID] then
    return self.BankCache[ActorID]
  end
  local BankName = ""
  local ActorTableData = self:GetActorTableData(ActorID)
  if ActorTableData and ActorTableData.BankName and ActorTableData.BankName ~= "" then
    BankName = ActorTableData.BankName
  end
  self.BankCache[ActorID] = BankName
  return BankName
end
function VoiceTransformSubsystem:GetActorTableData(ActorID)
  if self.ActorTableCache[ActorID] ~= nil then
    return self.ActorTableCache[ActorID]
  end
  local ActorTableData = CDataTable.GetTableData("VoiceActorCfg", ActorID)
  self.ActorTableCache[ActorID] = ActorTableData or false
  return ActorTableData
end
function VoiceTransformSubsystem:CheckVoiceBankExists(VoiceID)
  local ActorID = math.floor(VoiceID / 100000)
  local BankName = self:GetActorBankByID(ActorID)
  if Client then
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    if PufferManager and PufferManager.IsBankExist then
      local Exists = PufferManager.IsBankExist(BankName)
      print(bWriteLog and string.format("VoiceTransformSubsystem:CheckVoiceBankExists Bank: %s, Exists: %s", BankName, tostring(Exists)))
      return Exists
    end
  end
  return true
end
local class = require("class")
local SubsystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubsystemBase, nil, VoiceTransformSubsystem)