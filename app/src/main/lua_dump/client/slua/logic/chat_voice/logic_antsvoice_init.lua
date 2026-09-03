local logic_antsvoice_init = {}
function logic_antsvoice_init:OnInitialize()
  log(bWriteLog and "logic_antsvoice_init:OnInitialize")
end
function logic_antsvoice_init:RegistEvents()
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local interface = logic_antsvoice_interface:GetGVoiceInterface()
  self:AddControlEvent(interface, "SetAppInfoSuccess", self.OnSetAppInfoSuccess, self)
  self:AddControlEvent(interface, "SetAppInfoFail", self.OnSetAppInfoFail, self)
  self:AddControlEvent(interface, "GetReconnectInfo", self.OnGetReconnectInfo, self)
  if not self.bIsAntsVoiceInit then
    self:InitAntsVoiceInterface()
  end
end
function logic_antsvoice_init:InitAntsVoiceInterface(bReLogin)
  log(bWriteLog and string.format("[muidarzhang] logic_antsvoice_init:InitAntsVoiceInterface, bReLogin:%s", bReLogin))
  assert(DataMgr.roleData.uid ~= 0, "logic_antsvoice_init:InitAntsVoiceInterface, uid ~= 0.")
  local logic_antsvoice_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_antsvoice_interface)
  local StringUtil = require("common.string_util")
  local curRole = StringUtil.StrTrim(DataMgr.roleData.uid)
  if curRole ~= "" then
    logic_antsvoice_interface:InitVoiceSDKComponent(curRole)
  end
  logic_antsvoice_interface:InitMicAndSpeakerVolum()
  self.bIsAntsVoiceInit = true
end
function logic_antsvoice_init:OnSetAppInfoSuccess(_, openID, antsVoiceGameId)
  log(bWriteLog and string.format("[muidarzhang] logic_antsvoice_init:OnSetAppInfoSuccess, openID, antsVoiceGameId:%s, %s", openID, antsVoiceGameId))
end
function logic_antsvoice_init:OnSetAppInfoFail(error)
  local BusinessHelper = import("BusinessHelper")
  local userOpenID = BusinessHelper.GetOpenId()
  log(bWriteLog and string.format("[muidarzhang] ERROR: logic_antsvoice_init:OnSetAppInfoFail, error, userOpenID:%s, %s", error, userOpenID))
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local Enum_OperationErrorCode = logic_chat_voice_const.Enum_OperationErrorCode
  if error == Enum_OperationErrorCode.AntsVoiceServiceError then
    ShowNotice(106049)
  else
    ShowNotice(LocUtil.GetLocalizeResStr(106050) .. tostring(error))
  end
end
function logic_antsvoice_init:OnGetReconnectInfo()
  log(bWriteLog and "[muidarzhang] logic_antsvoice_init:OnGetReconnectInfo")
  local logic_chat_voice_const = require("client.slua.logic.chat_voice.logic_chat_voice_const")
  local ReenterDuration = logic_chat_voice_const.ReenterDuration
  local ReenterRoomMaxCount = logic_chat_voice_const.ReenterRoomMaxCount
  local data = {
    VoiceSdkReEnterRoomMaxCount = tostring(ReenterRoomMaxCount),
    VoiceSdkReEnterDuration = tostring(ReenterDuration)
  }
  Client.GetVoiceSdkReconnectInfo(GameFrontendHUD, data)
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
return class(CDelegateContainer, nil, logic_antsvoice_init)