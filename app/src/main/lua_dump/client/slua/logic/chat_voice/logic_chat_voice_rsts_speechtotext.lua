local logic_chat_voice_rsts_speechtotext = {}
function logic_chat_voice_rsts_speechtotext:OnInitialize()
  log(bWriteLog and "logic_chat_voice_rsts_speechtotext:OnInitialize")
end
function logic_chat_voice_rsts_speechtotext:RegistEvents()
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = logic_antsvoice_interface:GetGVoiceInterface()
  self:AddControlEvent(interface, "OnRSTSSpeechToTextCallback", self.OnRSTSSpeechToTextCallback, self)
end
function logic_chat_voice_rsts_speechtotext:OnRSTSSpeechToTextCallback(InCode, InSrcLang, InTargetLang, InSrcText, InTargetText, InSrcFileDuration, InRecordFile)
  local result = {
    InCode = InCode,
    InSrcLang = InSrcLang,
    InTargetLang = InTargetLang,
    InSrcText = InSrcText,
    InTargetText = InTargetText,
    InSrcFileDuration = InSrcFileDuration,
      }
  log_tree(bWriteLog and "logic_chat_voice_rsts_speechtotext:OnRSTSSpeechToTextCallback result:", result)
  self:TrySendToCommunity(InCode, InTargetText, InSrcFileDuration)
  EventSystem:postEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_SPEECH_TO_TEXT_RESULT, result)
end
function logic_chat_voice_rsts_speechtotext:RSTSSpeechToText(LangID, SceneID)
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  if not logic_antsvoice_interface then
    log_error("logic_chat_voice_rsts_speechtotext:RSTSSpeechToText - logic_antsvoice_interface not found")
    return
  end
  logic_antsvoice_interface:RSTSSpeechToText(LangID, SceneID)
end
function logic_chat_voice_rsts_speechtotext:RSTSStopRecording()
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  logic_antsvoice_interface:RSTSStopRecording()
end
function logic_chat_voice_rsts_speechtotext:TrySendToCommunity(InCode, InTargetText, InSrcFileDuration)
  if not GameStatus.IsInLobbyOrMainCity() then
    log(bWriteLog and "logic_chat_voice_rsts_speechtotext:TrySendToCommunity not InLobby")
    return
  end
  local bp_pluginBPLibrary = import("bp_pluginBPLibrary")
  local IsInForeground = bp_pluginBPLibrary.bp_pluginIsInForeground()
  if not IsInForeground then
    log(bWriteLog and "logic_chat_voice_rsts_speechtotext:TrySendToCommunity not InForeground")
    return
  end
  local tb = {
    action = "receive_stt_result",
    targetText = InTargetText,
    code = InCode,
    duration = InSrcFileDuration
  }
  local jsonStr = json.encode(tb)
  if bp_pluginBPLibrary.bp_pluginSendEvent then
    log(bWriteLog and "logic_chat_voice_rsts_speechtotext:TrySendToCommunity jsonStr:" .. jsonStr)
    bp_pluginBPLibrary.bp_pluginSendEvent(jsonStr)
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, logic_chat_voice_rsts_speechtotext)