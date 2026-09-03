local pandora_v2_adapter = {
  MountHandleMap = {}
}
local local PandoraV2Helper
function pandora_v2_adapter:RegistEvents()
  self:GetPandoraV2Interface().CallGameDelegate:Clear()
  self:GetPandoraV2Interface().CallGameDelegate:Add(function(cmdJson, cmdType)
    self:OnCallGame(cmdJson, cmdType)
  end)
  self:GetPandoraV2Interface().JumpDelegate:Clear()
  self:GetPandoraV2Interface().JumpDelegate:Add(function(jumpType, jumpContent)
    self:OnJump(jumpType, jumpContent)
  end)
  self:GetPandoraV2Interface().AddUserWidgetToGameDelegate:Clear()
  self:GetPandoraV2Interface().AddUserWidgetToGameDelegate:Add(function(widget, pannelName, anchorId, panelType)
    self:OnAddUserWidgetToGame(widget, pannelName, anchorId, panelType)
  end)
  self:GetPandoraV2Interface().RemoveUserWidgetFromGameDelegate:Clear()
  self:GetPandoraV2Interface().RemoveUserWidgetFromGameDelegate:Add(function(widget, pannelName, anchorId, panelType)
    self:OnRemoveUserWidgetFromGame(widget, pannelName, anchorId, panelType)
  end)
end
function pandora_v2_adapter:Init()
  local PandoraV2Define = require("client.slua.logic.Pandora.pandara_v2_define")
  local env = PandoraV2Define.ENV.PDR_Prod
  if Client.GetIMSDKEnv() == 0 then
    env = PandoraV2Define.ENV.PDR_Test
  end
  self:RegistEvents()
  self:GetPandoraV2Interface():Init(true, env, false)
end
function pandora_v2_adapter:PandoraInit(UserData)
  if not UserData or type(UserData) ~= "table" then
    return
  end
  UserData.sServiceType = "pubgmobile"
  local is5sDevices = Client.IsIPhoneFiveS(GameFrontendHUD)
  if is5sDevices then
    self:GetPandoraV2Interface():SetSDKVersion(50001)
  end
  local pandoraLuaCoreFilePath = string.format("%sTemplates/Data/Pandora/Content/luacore.bin", Client.ProjectContentDir())
  self:GetPandoraV2Interface():SetLuaCoreData(pandoraLuaCoreFilePath)
  self:GetPandoraV2Interface():SetUserData(UserData)
end
function pandora_v2_adapter:PandoraClose()
  self:GetPandoraV2Interface():Close()
end
function pandora_v2_adapter:SetDebugLog(enabled)
  log(bWriteLog and string.format("pandora_v2_adapter:SetDebugLog. enabled=%s", tostring(enabled)))
  self:GetPandoraV2Interface():SetLogEnable(enabled)
end
function pandora_v2_adapter:PauseLuaGC()
  log(bWriteLog and "pandora_v2_adapter:PauseLuaGC")
  self:GetPandoraV2Interface():PauseLuaGC()
end
function pandora_v2_adapter:ResumeLuaGC()
  log(bWriteLog and "pandora_v2_adapter:ResumeLuaGC")
  self:GetPandoraV2Interface():ResumeLuaGC()
end
function pandora_v2_adapter:PandoraSendCmd(cmdJson)
  local PandoraV2Define = require("client.slua.logic.Pandora.pandara_v2_define")
  self:GetPandoraV2Interface():Do(cmdJson, PandoraV2Define.CMDType.PDRCT_Pandora)
end
function pandora_v2_adapter:OnCallGame(cmdJson, cmdType)
  log(bWriteLog and string.format("pandora_v2_adapter:OnCallGame: %s", cmdJson))
  local PandoraProtocolLayer = require("client.slua.logic.Pandora.pandora_protocol_layer")
  PandoraProtocolLayer.OnPandoraCallback(cmdJson)
end
function pandora_v2_adapter:OnJump(jumpType, jumpContent)
  log(bWriteLog and string.format("[ERROR] Not implement pandora_v2_adapter:OnJump: %s %s", tostring(jumpType), jumpContent))
end
function pandora_v2_adapter:OnAddUserWidgetToGame(widget, pannelName, anchorId, panelType)
  log(bWriteLog and string.format("pandora_v2_adapter:OnAddUserWidgetToGame: %s %s, %s", tostring(pannelName), tostring(anchorId), tostring(panelType)))
  if not slua.isValid(widget) then
    return
  end
  if self:IsMountPandora(anchorId) then
    if self.MountHandleMap[anchorId] ~= nil then
      self.MountHandleMap[anchorId](widget, pannelName, anchorId, panelType)
    end
  else
    widget:AddToViewport(30003)
  end
end
function pandora_v2_adapter:OnRemoveUserWidgetFromGame(widget, pannelName, anchorId, panelType)
  log(bWriteLog and string.format("pandora_v2_adapter:OnRemoveUserWidgetFromGame: %s %s, %s", tostring(pannelName), tostring(anchorId), tostring(panelType)))
  if not slua.isValid(widget) then
    return
  end
  if not self:IsMountPandora(anchorId) then
    widget:RemoveFromViewport()
  else
    widget:RemoveFromParent()
  end
end
function pandora_v2_adapter:GetPandoraV2Interface()
  if not PandoraV2Helper then
    local PandoraV2 = import("PandoraV2Helper")
    PandoraV2Helper = PandoraV2.Get()
  end
  return PandoraV2Helper
end
function pandora_v2_adapter:IsMountPandora(anchorId)
  if not anchorId or type(anchorId) ~= "string" then
    return false
  end
  local StringUtil = require("common.string_util")
  return StringUtil.StrFind(anchorId, "MountPandora")
end
function pandora_v2_adapter:AddMountHandle(keyName, handleFunc, ...)
  if self.MountHandleMap[keyName] ~= nil then
    log(bWriteLog and string.format("pandora_v2_adapter:AddMountHandle. keyName=%s already exist", tostring(keyName)))
    return
  end
  local common = require("client.slua_ui_framework.common")
  local args = table.pack(...)
  local handle = function(...)
    return common.CallCombinationArgs(handleFunc, args, ...)
  end
  log(bWriteLog and string.format("pandora_v2_adapter:AddMountHandle. keyName=%s regist", tostring(keyName)))
  self.MountHandleMap[keyName] = handle
end
function pandora_v2_adapter:RemoveMountHandle(keyName)
  if self.MountHandleMap[keyName] ~= nil then
    log(bWriteLog and string.format("pandora_v2_adapter:RemoveMountHandle. keyName=%s unregist", tostring(keyName)))
    self.MountHandleMap[keyName] = nil
  end
end
return pandora_v2_adapter