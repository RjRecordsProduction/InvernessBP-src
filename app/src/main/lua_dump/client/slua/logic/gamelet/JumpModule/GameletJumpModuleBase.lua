local GameletJumpModuleBase = {}
function GameletJumpModuleBase:SendCmd(msg, appId)
  appId = appId or self:GetAppId()
  local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  return gamelet_interface:SendMessageToApp(appId, msg)
end
function GameletJumpModuleBase:DefineAndResetData()
  self.ctorData = nil
end
function GameletJumpModuleBase:JumpCheck(ctorData)
  local ready = self:IsAppReady()
  if not ready then
    self:JumpButNotReady(ctorData)
  end
  log(bWriteLog and "GameletJumpModuleBase:JumpCheck. IsReady: " .. tostring(ready))
  return ready == true
end
function GameletJumpModuleBase:JumpButNotReady(ctorData)
end
function GameletJumpModuleBase:ToShow(ctorData)
end
function GameletJumpModuleBase:ShowModule(ctorData)
  self.  local appPage = "index"
  if self.ctorData and type(self.ctorData) == "table" and self.ctorData.appPage then
    appPage = self.ctorData.appPage
  end
  local ModuleId = self:GetModuleID()
  local appType = self:GetAppType()
  local appId = self:GetAppId()
  local layerNode = {
    moduleId = ModuleId,
    appType = appType,
    appId = appId,
      }
  local LogicGameletLayer = require("client.slua.logic.gamelet.LogicGameletLayer")
  LogicGameletLayer:Push(layerNode)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera_Only(Lobby_camera_manager_module.Enum_CameraID.XsuitPreview, 0)
  local HostedProtoBridge = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.HostedProtoBridge)
  HostedProtoBridge:SetOpenFlag(appType, appId)
  log(bWriteLog and "GameletJumpModuleBase:ShowModule. ToShow ModuleID:" .. ModuleId)
  self:ToShow(ctorData)
end
function GameletJumpModuleBase:CloseModule()
  local LogicGameletLayer = require("client.slua.logic.gamelet.LogicGameletLayer")
  LogicGameletLayer:Clear()
  local logic_gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  logic_gamelet_interface:CloseApp()
  UIManager.CloseUI(UIManager.UI_Config.GameletSDK_UIBP)
  self:ToClose()
end
function GameletJumpModuleBase:ToClose()
end
function GameletJumpModuleBase:GetModuleID()
  return 0
end
function GameletJumpModuleBase:GetAppType()
  return ""
end
function GameletJumpModuleBase:GetDataForJumpBack()
  return {
    uiData = {},
    ctorData = self.ctorData or {}
  }
end
function GameletJumpModuleBase:IsAppReady()
  local appId = self:GetAppId()
  local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  return gamelet_interface:IsInterfaceReady(appId)
end
function GameletJumpModuleBase:GetAppId()
  local appType = self:GetAppType()
  local gamelet_interface = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_gamelet_interface)
  return gamelet_interface:get_app_id(appType)
end
function GameletJumpModuleBase:GenerateArgs(ctorData)
  if not ctorData then
    return {}
  end
  local result = {}
  for key, value in pairs(ctorData) do
    if key == "appPage" then
      result[key] = value
    else
      if not result.jumpParams then
        result.jumpParams = {}
      end
      result.jumpParams[key] = value
    end
  end
  return result
end
local class = require("class")
local CJumpModuleBase = require("client.module_framework.JumpModuleBase")
local CGameletJumpModuleBase = class(CJumpModuleBase, nil, GameletJumpModuleBase)
return CGameletJumpModuleBase