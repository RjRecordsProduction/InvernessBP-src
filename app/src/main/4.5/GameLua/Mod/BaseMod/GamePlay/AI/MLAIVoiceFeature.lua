local MLAIVoiceFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
local MLAIVoiceDebugCode = {
  DSStateChange = 1,
  ClientRefuse = 2,
  VoiceInterFaceError = 3,
  ASRStateChange = 4,
  ClientInitSuccess = 5
}
local RSTSSceneNameToID = {
  None = logic_chat_voice_const.Enum_ASRSceneID.None,
  TeammateTakeOver = logic_chat_voice_const.Enum_ASRSceneID.TeammateTakeOver,
  Penguin = logic_chat_voice_const.Enum_ASRSceneID.Penguin,
  Treant = logic_chat_voice_const.Enum_ASRSceneID.Treant,
  Centaur = logic_chat_voice_const.Enum_ASRSceneID.Centaur
}
local LangToLang = logic_chat_voice_const.LangToLangID
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MLAIProcessUtil = require("GameLua.ExtraModule.MLAI.DS.AI.MLAIProcessUtil")
local Enum_HDmpveVoiceEvent = logic_chat_voice_const.Enum_HDmpveVoiceEvent
local TableUtil = require("common.table_util")
local time_ticker = require("common.time_ticker")
MLAIVoiceFeature.ServerRPC.RPC_Server_SendRSTSSubtitleText = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Float,
    UEnums.EPropertyClass.Str
  }
}
MLAIVoiceFeature.ServerRPC.RPC_Server_SendAIVoiceTLog = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.UInt64,
    UEnums.EPropertyClass.Str,
    UEnums.EPropertyClass.Str
  }
}
function MLAIVoiceFeature:_PostConstruct()
end
function MLAIVoiceFeature:ctor()
  self.bOpenMLAIVoice = false
  self.nRSTSSceneID = 0
  self.VoiceFileDownloadRecord = {}
  self.ASRRecord = {}
  self.MemberVoiceRecod = {}
end
function MLAIVoiceFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bOpenMLAIVoice",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "nRSTSSceneID",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function MLAIVoiceFeature:ReceiveBeginPlay()
  MLAIVoiceFeature.__super.ReceiveBeginPlay(self)
end
function MLAIVoiceFeature:ReceiveEndPlay(EndPlayReason)
  if Client and self.AntsVoiceInterface then
    if self.AntsVoiceInterface:GetMicState() then
      self:SetRSTSSubtitleState(0, "EndPlay")
    end
    local ModuleManager = require("client.module_framework.ModuleManager")
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:TryStopPlayRecordVoice()
  end
  self:UnRegistEvent()
  MLAIVoiceFeature.__super.ReceiveEndPlay(self, EndPlayReason)
end
function MLAIVoiceFeature:OnInit()
  if Client and not self.bHasInit then
    self.bShowRSTSSubtitleText = false
    self.bSpeechToTextState = false
    self.bComplaint = false
    self.AntsVoiceInterface = slua_GameFrontendHUD:GetVoiceSDKInterface()
    if slua.isValid(self.AntsVoiceInterface) then
      local uPlayerController = GameplayData.GetPlayerController()
      if not slua.isValid(uPlayerController) then
        print(bWriteLog and "MLAIVoiceFeature:OnInit PlayerController is nil")
        return
      end
      local uChatComponent = uPlayerController:GetChatComponent()
      local FirstLang = "zh"
      if slua.isValid(uChatComponent) then
        FirstLang = uChatComponent:GetFirstLanguage().name
      else
        print(bWriteLog and "MLAIVoiceFeature:OnInit uChatComponent is nil")
      end
      self.LangID = LangToLang[FirstLang] or 0
      print(bWriteLog and string.format("MLAIVoiceFeature:OnInit LangID=%s, FirstLang=%s", tostring(self.LangID), tostring(FirstLang)))
      self.bHasInit = true
      self:InitSecurityBaseInfo(uPlayerController)
      self:AddCommonEvent(EVENTTYPE_COMPLAINT, EVENTID_SUBMIT_COMPLAINT, self.OnPlayerSubmitComplaint, self)
      self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.ClientInitSuccess, "Init")
    else
      self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.VoiceInterFaceError, "Init")
    end
  end
end
function MLAIVoiceFeature:ChangeMLAIVoiceState(bOpen)
  print(bWriteLog and string.format("MLAIVoiceFeature:ChangeMLAIVoiceState, bOpen=%s", tostring(bOpen)))
  self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.DSStateChange, tostring(bOpen))
  self.bOpenMLAIVoice = bOpen
  return
end
function MLAIVoiceFeature:RegistEvent()
  if Client and not self.bHasRegistEvent then
    print(bWriteLog and "MLAIVoiceFeature:RegistEvent")
    if self.AntsVoiceInterface then
      self:AddControlEvent(self.AntsVoiceInterface, "BeforeOperation", self.OnBeforeOperation, self)
      self:AddControlEvent(self.AntsVoiceInterface, "OnVoiceSDKEvent", self.OnAntsVoiceEvent, self)
      self:AddControlEvent(self.AntsVoiceInterface, "OnRSTSSubtitleCallback", self.OnRSTSSubtitleCallback, self)
      self:AddControlEvent(self.AntsVoiceInterface, "OnDeliverDataCallback", self.OnDeliverDataCallback, self)
      self:AddControlEvent(self.AntsVoiceInterface, "OnRSTSSubtitleASRStartCallback", self.OnRSTSSubtitleASRStartCallback, self)
      self:AddControlEvent(self.AntsVoiceInterface, "OnSessionForAIInfoCallback", self.OnSessionForAIInfoCallback, self)
      self:AddCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CHANGE_STT_STATE, self.OnSTTStateChange, self)
      self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE, self.OnMemberVoice, self)
      self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_START_PLAY_RECORD_FILE, self.StartPlayVoiceFile, self)
      self:AddCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_STOP_PLAY_RECORD_FILE, self.StopPlayVoiceFile, self)
      self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_END, self.OnDownloadFileEnd, self)
      self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_START, self.OnDownloadFileStart, self)
      self:AddCommonEvent(EVENTTYPE_COMPLAINT, EVENTID_SUBMIT_COMPLAINT, self.OnPlayerSubmitComplaint, self)
      local uPlayerController = self.Owner.Object
      if not slua.isValid(uPlayerController) then
        return
      end
      if self.CanOpenMLAIVoice() and slua.isValid(uPlayerController:GetChatComponent()) then
        self:BindLuaObjEvent(uPlayerController:GetChatComponent(), "OnSendMessage", self.HandleOnPlayerSendMsg, self)
      end
      print(bWriteLog and "MLAIVoiceFeature:RegistEvent, Success")
      self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.ClientInitSuccess, "RegistEvent")
    else
      self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.VoiceInterFaceError, "RegistEvent")
    end
    self.bHasRegistEvent = true
  end
end
function MLAIVoiceFeature:UnRegistEvent()
  if Client and self.bHasRegistEvent then
    print(bWriteLog and "MLAIVoiceFeature:UnRegistEvent")
    if self.AntsVoiceInterface then
      self:RemoveControlEvent(self.AntsVoiceInterface, "BeforeOperation")
      self:RemoveControlEvent(self.AntsVoiceInterface, "OnVoiceSDKEvent")
      self:RemoveControlEvent(self.AntsVoiceInterface, "OnRSTSSubtitleCallback")
      self:RemoveControlEvent(self.AntsVoiceInterface, "OnDeliverDataCallback")
      self:RemoveControlEvent(self.AntsVoiceInterface, "OnRSTSSubtitleASRStartCallback")
      self:RemoveControlEvent(self.AntsVoiceInterface, "OnSessionForAIInfoCallback")
      self:RemoveCommonEvent(EVENTTYPE_INGAME, EVENTID_INGAME_CHANGE_STT_STATE)
      self:RemoveCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_MEMBER_VOICE)
      self:RemoveCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_START_PLAY_RECORD_FILE)
      self:RemoveCommonEvent(EVENTTYPE_CHAT, EVENTID_CHAT_STOP_PLAY_RECORD_FILE)
      self:RemoveCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_END)
      self:RemoveCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_ON_DOWNLOAD_FILEID_START)
      self:RemoveCommonEvent(EVENTTYPE_COMPLAINT, EVENTID_SUBMIT_COMPLAINT)
      local uPlayerController = self.Owner.Object
      if not slua.isValid(uPlayerController) then
        return
      end
    end
    self.bHasRegistEvent = nil
  end
end
function MLAIVoiceFeature:OnRep_bOpenMLAIVoice(OldValue)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnRep_bOpenMLAIVoice, OldValue:%s, NewValue:%s", tostring(OldValue), tostring(self.bOpenMLAIVoice)))
  self:OnInit()
  if not self:CanOpenMLAIVoice() then
    if not OldValue and self.bOpenMLAIVoice then
      EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_CANNOT_OPEN)
    end
    print(bWriteLog and "MLAIVoiceFeature:OnRep_bOpenMLAIVoice, CanOpenMLAIVoice is false")
    self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.ClientRefuse, "Nonage")
    return
  end
  if self.bOpenMLAIVoice then
    self:RegistEvent()
  else
    self:UnRegistEvent()
  end
end
function MLAIVoiceFeature:OnRep_nRSTSSceneID(OldValue)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnRep_nRSTSSceneID, OldValue:%s, NewValue:%s", tostring(OldValue), tostring(self.nRSTSSceneID)))
  if not self:CanOpenMLAIVoice() then
    return
  end
  self:ChangeClientVoiceState(self.nRSTSSceneID)
end
function MLAIVoiceFeature:ChangeClientVoiceState(nSceneID)
  if Client then
    print(bWriteLog and string.format("MLAIVoiceFeature:ChangeClientState, bState=%s", tostring(bState)))
    if nSceneID and 0 < nSceneID and self:CanOpenMLAIVoice() then
      if self.AntsVoiceInterface then
        if self.AntsVoiceInterface:GetMicState() == 1 then
          self:SetRSTSSubtitleState(nSceneID, "Init OpenMic")
        end
      else
        print(bWriteLog and "MLAIVoiceFeature:ChangeClientState, AntsVoiceInterface is nil")
      end
    elseif self.AntsVoiceInterface and self.AntsVoiceInterface:GetMicState() == 1 then
      self:SetRSTSSubtitleState(0, "Init OpenMic")
    end
  end
end
function MLAIVoiceFeature:OnAntsVoiceEvent(Event)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnAntsVoiceEvent, code: %s", Event))
  if self.bSpeechToTextState == true then
    return
  end
  if Event == Enum_HDmpveVoiceEvent.GV_EVENT_MIC_STATE_OPEN_SUCC then
    self:SetRSTSSubtitleState(self.nRSTSSceneID, "OpenMic")
  end
end
function MLAIVoiceFeature:OnBeforeOperation(bOpen)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnBeforeOperation, state: %s", tostring(bOpen)))
  if self.bSpeechToTextState == true then
    return
  end
  if not bOpen then
    self:SetRSTSSubtitleState(0, "Close Mic")
  end
end
function MLAIVoiceFeature:RPC_Server_SendAIVoiceTLog(nUID, sProtolName, sTLogInfo)
  print(bWriteLog and string.format("MLAIVoiceFeature:RPC_Server_SendAIVoiceTLog, nUID:%s, sProtolName:%s, sTLogInfo:%s", tostring(nUID), tostring(sProtolName), tostring(sTLogInfo)))
  if not Client and NetUtil then
    NetUtil.SendPacket("report_common_info", sProtolName, nUID, sTLogInfo)
  end
end
function MLAIVoiceFeature:RPC_Server_SendRSTSSubtitleText(sInText, nRecordTime, nASRDelay, sSessionName)
  if not Client then
    MLAIProcessUtil:SendStringOnlyReplay(self.Owner.Object, sInText)
    local Info = string.format("%s|%s|%s|%s", sSessionName, string.format("%.0f", nRecordTime), string.format("%.0f", nASRDelay), sInText)
    print(bWriteLog and string.format("MLAIVoiceFeature:RPC_Server_SendRSTSSubtitleText, Info:%s", Info))
    NetUtil.SendPacket("report_common_info", "PlayerASRRecord", self.Owner.Object.UID, Info)
  end
end
function MLAIVoiceFeature:SetRSTSSubtitleSceneName(sRSTSSceneName, sExtraInfo)
  if sRSTSSceneName then
    self.nRSTSSceneID = RSTSSceneNameToID[sRSTSSceneName] or 0
    self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.ASRStateChange, tostring(self.nRSTSSceneID) .. "-" .. sExtraInfo)
  end
end
function MLAIVoiceFeature:SetRSTSSubtitleState(nRSTSSceneID, sExtraInfo)
  if Client then
    local bState = false
    if nRSTSSceneID ~= nil and 0 < nRSTSSceneID then
      bState = true
    end
    self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.ASRStateChange, tostring(nRSTSSceneID) .. "-" .. sExtraInfo)
    local tExtraInfo = {
      ASRSceneID = tostring(nRSTSSceneID)
    }
    local sExtraInfoStr = json.encode(tExtraInfo)
    local base64 = require("client.slua.logic.lobby_watermark.base64")
    local sEncodedExtraInfoStr = base64.encode(sExtraInfoStr)
    self.ErrorCode = self.AntsVoiceInterface and self.AntsVoiceInterface:EnableRSTSSubtitle(bState, self.LangID, sEncodedExtraInfoStr)
    print(bWriteLog and string.format("MLAIVoiceFeature:SetRSTSSubtitleState, ErrorCode:%s, ExtraInfo:%s", tostring(self.ErrorCode), sExtraInfoStr))
    self:SendMLAIVoiceDebugInfo(MLAIVoiceDebugCode.ASRStateChange, tostring(nRSTSSceneID) .. "-" .. sExtraInfo)
  end
end
function MLAIVoiceFeature:OnRSTSSubtitleASRStartCallback(sASRSessionName)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnRSTSSubtitleASRStartCallback, sASRSessionName:%s", sASRSessionName))
  self.ASRRecord[sASRSessionName] = slua.getMiliseconds()
end
function MLAIVoiceFeature:OnSessionForAIInfoCallback(_, sSessionName)
  self.CacheSessionName = sSessionName
  if self.CacheSessionNameClearTimer ~= nil then
    Game:ClearTimer(self.CacheSessionNameClearTimer)
  end
  self.CacheSessionNameClearTimer = self:AddGameTimer(0.5, false, function()
    self.CacheSessionName = nil
    self.CacheSessionNameClearTimer = nil
  end)
end
function MLAIVoiceFeature:OnRSTSSubtitleCallback(InCode, InSrcLang, InTargetLang, InSrcText, InTargetText, InSessionName)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnRSTSSubtitleCallback, InCode, InSrcLang, InTargetLang, InSrcText, InTargetText, InRecordFile:%s, %s, %s, %s", InCode, InSrcLang, InTargetLang, InSrcText, InSessionName))
  local CurrentFrame = time_ticker.GFrameCount or 0
  if self.LastMsgFrame and CurrentFrame == self.LastMsgFrame then
    print(bWriteLog and "MLAIVoiceFeature:OnRSTSSubtitleCallback, CurrentFrame == LastMsgFrame CurrentFrame:%s", tostring(CurrentFrame))
    return
  end
  self.LastMsgFrame = CurrentFrame
  if InTargetText ~= "" and self.bSpeechToTextState == false then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      if self.bShowRSTSSubtitleText then
        uPlayerController:SendStringMsg(InTargetText, -1, 0, "0", 0, 0, false)
      end
      self:SendDeliveryDataByVoice(InTargetText, 1, InSrcLang, InSessionName, self.bComplaint)
      local nASRDelay = 0
      if self.ASRRecord[InSessionName] then
        nASRDelay = slua.getMiliseconds() - self.ASRRecord[InSessionName]
      end
      self:RPC_Server_SendRSTSSubtitleText(InTargetText, self:GetCurrentServerTimeSec(), nASRDelay, InSessionName or "none")
    end
  else
    print(bWriteLog and "MLAIVoiceFeature:OnRSTSSubtitleCallback, InTargetText is empty")
  end
end
function MLAIVoiceFeature:HandleOnPlayerSendMsg(sMessage)
  print(bWriteLog and string.format("MLAIVoiceFeature:HandleOnPlayerSendSTTMsgDelegate, sMessage%s", sMessage))
  self:SendDeliveryDataByVoice(sMessage, 2, self.LangID, nil, self.bComplaint)
end
function MLAIVoiceFeature:SendDeliveryDataByVoice(sMessage, nType, nInSrcLang, InSessionName, bComplaint)
  print(bWriteLog and string.format("SendDeliveryDataByVoice sMessage = %s nType = %s", tostring(sMessage), tostring(nType)))
  if sMessage and sMessage ~= "" and nType then
    local uPlayerController = self.Owner.Object
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "MLAIVoiceFeature:SendDeliveryDataByVoice uPlayerController is nil")
      return
    end
    local uPlayerState = uPlayerController.PlayerState
    if slua.isValid(uPlayerState) then
      if uPlayerState.AIGCRequestID == nil then
        uPlayerState.AIGCRequestID = 1
      end
      if self.AreaID == nil then
        self:InitSecurityBaseInfo(uPlayerController)
      end
      local TimeUtil = require("client.common.time_util")
      local CurrentTime = TimeUtil.GetServerTimeInSec()
      local pb = require("pb")
      pb.option("enum_as_value")
      pb.loadfile("ds_client/aigc_smart_npc_client.pb")
      local nRequestID = CurrentTime * 10000 + uPlayerState.AIGCRequestID
      local AIGCRequest = {
        request_id = nRequestID,
        query = sMessage,
        version = "1",
        context = nil,
        uid = uPlayerState.UID,
        query_gen_type = nType,
        plat_id = self.PlatID or 0,
        area_id = self.AreaID or 0,
        region_id = self:GetRegionID(),
        lang_id = self.LangID or -1,
        session_name = InSessionName or tostring(nRequestID),
        is_complaint = bComplaint
      }
      uPlayerState.AIGCRequestID = uPlayerState.AIGCRequestID + 1
      uPlayerState.AIGCRequestID = uPlayerState.AIGCRequestID % 10000
      local EncodeAIGCRequest = pb.encode("smart_npc_client.AIGCRequest", AIGCRequest)
      if slua.isValid(self.AntsVoiceInterface) then
        self.AntsVoiceInterface:SetDeliverData(EncodeAIGCRequest, #EncodeAIGCRequest)
        log_tree("Send AIGCRequest", AIGCRequest)
      end
    end
  end
end
function MLAIVoiceFeature:InitSecurityBaseInfo(uPlayerController)
  local uPlayerCharacter = uPlayerController:GetPlayerCharacterSafety()
  if slua.isValid(uPlayerCharacter) then
    local uSecurityComp = uPlayerCharacter:GetSecuryComponent()
    if slua.isValid(uSecurityComp) then
      self.PlatID = uSecurityComp.GameBaseInfo.PlatID
      local IMSDKHelper = import("IMSDKHelper")
      if IMSDKHelper ~= nil then
        local SDKHelper = IMSDKHelper.GetInstance()
        if slua.isValid(SDKHelper) then
          self.AreaID = SDKHelper:ConvertTConndChannel2IMSDKChannel(uSecurityComp.GameBaseInfo.AreaID)
        end
      end
    end
  end
end
function MLAIVoiceFeature:OnSTTStateChange(_, __, bOpen)
  self.bSpeechToTextState = bOpen
  print(bWriteLog and string.format("MLAIVoiceFeature:OnSTTStateChange, bOpen:%s", tostring(bOpen)))
end
function MLAIVoiceFeature:OnDeliverDataCallback(uData, nLen, sOpenID)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnDeliverDataCallback, nLen:%s, sOpenID:%s", tostring(nLen), tostring(sOpenID)))
  local uTeammatePlayerState = self:GetTeammatePlayerStateByOpenID(sOpenID)
  if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.nMasterIndex and uTeammatePlayerState.nMasterIndex >= 0 then
    local pb = require("pb")
    pb.option("enum_as_value")
    pb.loadfile("ds_client/aigc_smart_npc_client.pb")
    local AIGCResponse = pb.decode("smart_npc_client.AIGCResponse", uData)
    if AIGCResponse then
      log_tree("MLAIVoiceFeature:OnDeliverDataCallback AIGCResponse", AIGCResponse)
      if AIGCResponse.audio_id and AIGCResponse.audio_duration then
        local ModuleManager = require("client.module_framework.ModuleManager")
        local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
        local tExtraData = {
          permanent = true,
          OpenID = sOpenID,
          FileID = AIGCResponse.audio_id,
          Duration = AIGCResponse.audio_duration,
          bSkipTips = true,
          bOnlyFightingState = true
        }
        if AIGCResponse.audio_id ~= nil and AIGCResponse.audio_id ~= "" then
          if self.VoiceFileDownloadRecord[AIGCResponse.audio_id] ~= nil then
            self:OnDownloadFileEnd(nil, nil, AIGCResponse.audio_id, false)
            Game:ClearTimer(self.VoiceFileDownloadRecord[AIGCResponse.audio_id].Timer)
          end
          local UID = 0
          if slua.isValid(self.Owner.Object) and slua.isValid(self.Owner.Object.PlayerState) then
            UID = self.Owner.Object.PlayerState.UID
          end
          self.VoiceFileDownloadRecord[AIGCResponse.audio_id] = {
            UID = UID,
            OpenID = sOpenID,
            DownloadState = 0,
            Duration = 0,
            PlayResult = 0,
            SessionName = AIGCResponse.session_name
          }
          self.VoiceFileDownloadRecord[AIGCResponse.audio_id].Timer = self:AddGameTimer(2, false, function()
            self:OnVoiceFileEndPlay(AIGCResponse.audio_id)
          end)
          logic_chat_voice:TryStopPlayRecordVoice()
          logic_chat_voice:PlayVoiceFile(AIGCResponse.audio_id, AIGCResponse.audio_duration, tExtraData)
        else
          print(bWriteLog and "MLAIVoiceFeature:OnDeliverDataCallback, AIGCResponse.audio_id is empty")
        end
      end
    else
      print(bWriteLog and "MLAIVoiceFeature:OnDeliverDataCallback, AIGCResponse is nil")
    end
  else
    print(bWriteLog and "MLAIVoiceFeature:OnDeliverDataCallback, uTeammatePlayerState is Not TeammateAI")
  end
end
function MLAIVoiceFeature:GetRegionID()
  local RegionID = 0
  local gdpr_user_type = 1
  if DataMgr.roleData.eugdpr then
    gdpr_user_type = DataMgr.roleData.eugdpr.user_type
  else
    print(bWriteLog and "MLAIVoiceFeature:GetRegionID eugdpr is nil")
  end
  local logic_gdpr = require("client.slua.logic.gdpr.logic_gdpr")
  if gdpr_user_type ~= 0 and logic_gdpr.IsEUGDPRUser(gdpr_user_type) then
    RegionID = 1
  end
  return RegionID
end
function MLAIVoiceFeature:CanOpenMLAIVoice()
  if self.bOpenMLAIVoice ~= true then
    return false
  end
  local bNeedCheck = false
  local sCheckRegion = "Unknown"
  if DataMgr.RegionData then
    local sRegion = DataMgr.RegionData.region
    print(bWriteLog and string.format("MLAIVoiceFeature:CanOpenMLAIVoice, sRegion:%s", tostring(sRegion)))
    if sRegion == "US" then
      bNeedCheck = true
      sCheckRegion = "US"
    end
  end
  if not bNeedCheck then
    local gdpr_user_type = 1
    if DataMgr.roleData.eugdpr then
      gdpr_user_type = DataMgr.roleData.eugdpr.user_type
    end
    local logic_gdpr = require("client.slua.logic.gdpr.logic_gdpr")
    if gdpr_user_type ~= 0 and logic_gdpr.IsEUGDPRUser(gdpr_user_type) then
      bNeedCheck = true
      sCheckRegion = "EU"
    end
  end
  if bNeedCheck then
    local AntiaddctionSystem = require("client.logic.antiaddction.logic_antiaddction")
    print(bWriteLog and string.format("MLAIVoiceFeature:CanOpenMLAIVoice, %s nonage:%s", sCheckRegion, tostring(AntiaddctionSystem.is_nonage)))
    if AntiaddctionSystem.is_nonage ~= nil and AntiaddctionSystem.is_nonage == 1 then
      print(bWriteLog and string.format("MLAIVoiceFeature:CanOpenMLAIVoice, %s Nonage Can't Open", sCheckRegion))
      return false
    end
  end
  return true
end
function MLAIVoiceFeature:OnMemberVoice(_, _, param)
  log_tree("MLAIVoiceFeature:OnMemberVoice", param)
  log_tree("MLAIVoiceFeature:OnMemberVoice MemberVoiceRecod", self.MemberVoiceRecod)
  local uTeammatePlayerState
  if param.uid and slua.isValid(CGameState) then
    uTeammatePlayerState = CGameState:GetPlayerStateByUID(param.uid or 0)
  elseif param.user_info then
    local parts = {}
    for part in param.user_info:gmatch("([^&]+)") do
      table.insert(parts, part)
    end
    local OpenID = parts[1] or ""
    uTeammatePlayerState = self:GetTeammatePlayerStateByOpenID(OpenID)
  end
  print(bWriteLog and string.format("MLAIVoiceFeature:OnMemberVoice, uTeammatePlayerState:%s", tostring(uTeammatePlayerState)))
  if slua.isValid(uTeammatePlayerState) and self:IsMasterOfTeammate(uTeammatePlayerState) then
    if self.MemberVoiceRecod[uTeammatePlayerState.UID] == nil and param.status == 1 or param.status == 2 then
      self.MemberVoiceRecod[uTeammatePlayerState.UID] = {
        StartTime = slua.getMiliseconds(),
        SessionName = self.CacheSessionName or tostring("none")
      }
      if self.CacheSessionNameClearTimer ~= nil then
        self.CacheSessionName = nil
        Game:ClearTimer(self.CacheSessionNameClearTimer)
        self.CacheSessionNameClearTimer = nil
      end
    elseif param.status == 0 and self.MemberVoiceRecod[uTeammatePlayerState.UID] then
      local nPlaybackDuration = slua.getMiliseconds() - self.MemberVoiceRecod[uTeammatePlayerState.UID].StartTime
      local Info = string.format("%s|%s|%s|%s", self.MemberVoiceRecod[uTeammatePlayerState.UID].SessionName, string.format("%.0f", self:GetCurrentServerTimeSec()), string.format("%.0f", nPlaybackDuration), tostring(uTeammatePlayerState.UID))
      print(bWriteLog and string.format("MLAIVoiceFeature:OnMemberVoice, Info:%s", tostring(Info)))
      self.MemberVoiceRecod[uTeammatePlayerState.UID] = nil
      self:RPC_Server_SendAIVoiceTLog(uTeammatePlayerState.UID, "AIVoiceRecord", Info)
    end
  else
    print(bWriteLog and string.format("MLAIVoiceFeature:OnMemberVoice, uTeammatePlayerState is not master"))
  end
end
function MLAIVoiceFeature:IsMasterOfTeammate(uTeammatePlayerState)
  local uPlayerController = self.Owner.Object
  if slua.isValid(uPlayerController) and slua.isValid(uTeammatePlayerState) and slua.isValid(uPlayerController.PlayerState) then
    print(bWriteLog and string.format("MLAIVoiceFeature:IsMasterOfTeammate, uPlayerController.PlayerState:GetPlayerTeamIndex:%s, uTeammatePlayerState.MasterIndex:%s", tostring(uPlayerController.PlayerState:GetPlayerTeamIndex()), tostring(uTeammatePlayerState.nMasterIndex)))
    if uPlayerController.PlayerState:GetPlayerTeamIndex() == uTeammatePlayerState.nMasterIndex then
      return true
    end
  end
  return false
end
function MLAIVoiceFeature:StartPlayVoiceFile(_, __, tExtraData)
  log_tree("MLAIVoiceFeature:StartPlayVoiceFile,", tExtraData)
  if tExtraData.OpenID then
    log_tree("MLAIVoiceFeature:StartPlayVoiceFile VoiceFileDownloadRecord", self.VoiceFileDownloadRecord)
    if self.VoiceFileDownloadRecord[tExtraData.FileID] ~= nil then
      local uPlayerController = self.Owner.Object
      if slua.isValid(uPlayerController) then
        local uTeammatePlayerState = self:GetTeammatePlayerStateByOpenID(tExtraData.OpenID)
        print(bWriteLog and string.format("MLAIVoiceFeature:OnPlayVoiceFile,uTeammatePlayerState:%s", tostring(uTeammatePlayerState)))
        if slua.isValid(uTeammatePlayerState) then
          print(bWriteLog and string.format("MLAIVoiceFeature:OnPlayVoiceFile, OpenID:%s, FileID:%s", tostring(tExtraData.OpenID), tostring(tExtraData.FileID)))
          self:OnSessionForAIInfoCallback(nil, self.VoiceFileDownloadRecord[tExtraData.FileID].SessionName)
          uPlayerController:OnMemberVoice(uTeammatePlayerState.GVMemberID, 1, tExtraData.OpenID)
          self.MemberVoiceGVMemberID = uTeammatePlayerState.GVMemberID
          self.VoiceFileDownloadRecord[tExtraData.FileID].PlayResult = 1
          self:OnVoiceFileEndPlay(tExtraData.FileID)
        end
      end
    end
  end
end
function MLAIVoiceFeature:StopPlayVoiceFile()
  print(bWriteLog and string.format("MLAIVoiceFeature:StopPlayVoiceFile MemberVoiceGVMemberID = %s", tostring(self.MemberVoiceGVMemberID)))
  if self.MemberVoiceGVMemberID and self.MemberVoiceGVMemberID ~= 0 then
    local uPlayerController = self.Owner.Object
    if slua.isValid(uPlayerController) then
      uPlayerController:OnMemberVoice(self.MemberVoiceGVMemberID, 0, "")
      self.MemberVoiceGVMemberID = 0
    end
  end
end
function MLAIVoiceFeature:OnDownloadFileEnd(_, __, nFileID, nResult)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnDownloadFileEnd, nFileID:%s, nResult:%s", tostring(nFileID), tostring(nResult)))
  if self.VoiceFileDownloadRecord[nFileID] and nResult == 2 and self.VoiceFileDownloadRecord[nFileID].StartTime then
    self.VoiceFileDownloadRecord[nFileID].DownloadState = 1
    self.VoiceFileDownloadRecord[nFileID].Duration = slua.getMiliseconds() - self.VoiceFileDownloadRecord[nFileID].StartTime
    self.VoiceFileDownloadRecord[nFileID].PlayResult = 0
  end
end
function MLAIVoiceFeature:OnDownloadFileStart(_, __, nFileID)
  print(bWriteLog and string.format("MLAIVoiceFeature:OnDownloadFileStart, nFileID:%s", tostring(nFileID)))
  if self.VoiceFileDownloadRecord[nFileID] then
    self.VoiceFileDownloadRecord[nFileID].StartTime = slua.getMiliseconds()
  end
end
function MLAIVoiceFeature:OnVoiceFileEndPlay(nFileID)
  log_tree("MLAIVoiceFeature:OnVoiceFileEndPlay", self.VoiceFileDownloadRecord)
  if self.VoiceFileDownloadRecord[nFileID] then
    Game:ClearTimer(self.VoiceFileDownloadRecord[nFileID].Timer)
    local uTeammatePlayerState = self:GetTeammatePlayerStateByOpenID(self.VoiceFileDownloadRecord[nFileID].OpenID)
    if slua.isValid(uTeammatePlayerState) then
      print(bWriteLog and string.format("MLAIVoiceFeature:OnVoiceFileEndPlay, self.Owner.Object.UID:%s", tostring(self.VoiceFileDownloadRecord[nFileID].UID)))
      local Info = string.format("%s|%s|%s|%s|%s|%s|%s", self.VoiceFileDownloadRecord[nFileID].SessionName or tostring("none"), tostring(nFileID), string.format("%.0f", self:GetCurrentServerTimeSec()), tostring(self.VoiceFileDownloadRecord[nFileID].UID or 0), tostring(self.VoiceFileDownloadRecord[nFileID].DownloadState), string.format("%.0f", self.VoiceFileDownloadRecord[nFileID].Duration), tostring(self.VoiceFileDownloadRecord[nFileID].PlayResult))
      print(bWriteLog and string.format("MLAIVoiceFeature:OnVoiceFileEndPlay, Info:%s", tostring(Info)))
      self:RPC_Server_SendAIVoiceTLog(uTeammatePlayerState.UID, "VoiceFileRecord", Info)
      self.VoiceFileDownloadRecord[nFileID] = nil
    end
  end
end
function MLAIVoiceFeature:OnPlayerSubmitComplaint(_, __, tReportTLog)
  log_tree("MLAIVoiceFeature:OnPlayerSubmitComplaint", tReportTLog)
  if tReportTLog and tReportTLog.UID and (tReportTLog.ComplaintType == 2 or tReportTLog.ComplaintType == 512) then
    local uPlayerState = self:GetTeammatePlayerStateByOpenID(tReportTLog.OpenID)
    if slua.isValid(uPlayerState) and uPlayerState.nMasterIndex and uPlayerState.nMasterIndex >= 0 then
      self.bComplaint = true
      self:SendDeliveryDataByVoice("PlayerComplaint", 2, self.LangID, nil, self.bComplaint)
    end
  end
end
function MLAIVoiceFeature:GetTeammatePlayerStateByOpenID(sOpenID)
  local uTeammatePlayerState = Game:GetTeammatePlayerStateByOpenID(sOpenID)
  if not slua.isValid(uTeammatePlayerState) and CGameState and CGameState.GetPlayerStateByOpenID then
    uTeammatePlayerState = CGameState:GetPlayerStateByOpenID(sOpenID)
  end
  return uTeammatePlayerState
end
function MLAIVoiceFeature:SendMLAIVoiceDebugInfo(nDebugCode, sExtraInfo)
  local sInfo = string.format("%s|%s|%s", tostring(nDebugCode), tostring(sExtraInfo), string.format("%.0f", self:GetCurrentServerTimeSec()))
  print(bWriteLog and string.format("MLAIVoiceFeature:SendMLAIVoiceDebugInfo, sInfo:%s", tostring(sInfo)))
  if slua.isValid(self.Owner.Object) then
    local nUID = self.Owner.Object.UID
    if nUID == 0 and slua.isValid(self.Owner.Object.PlayerState) then
      nUID = self.Owner.Object.PlayerState.UID
    end
    self:RPC_Server_SendAIVoiceTLog(nUID, "MLAIVoiceDebugInfo", sInfo)
  end
end
function MLAIVoiceFeature:GetCurrentServerTimeSec()
  local nCurrentTime = slua.getMiliseconds() / 1000
  if slua.isValid(CGameState) then
    nCurrentTime = CGameState:GetServerWorldTimeSeconds() or 999999
  end
  return nCurrentTime
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CMLAIVoiceFeature = class(CFeatureBase, nil, MLAIVoiceFeature)
return CMLAIVoiceFeature