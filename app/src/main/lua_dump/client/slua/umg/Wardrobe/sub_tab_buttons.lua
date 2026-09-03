local SubTabButtons = {}
function SubTabButtons:ctor()
end
function SubTabButtons:OnInitialize()
  SubTabButtons.__super.OnInitialize(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_NormalView, self.OnNormalViewClicked, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_TopView, self.OnTopViewClicked, self)
  self:AddCommonEvent(EVENTTYPE_CAMERA, EVENTID_REAL_CAMERA_SWITCHED, self.OnCameraSwitch, self)
end
function SubTabButtons:OnShow()
  self:RefreshButton()
end
function SubTabButtons:RefreshButton()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if Lobby_camera_manager_module:GetCurrentCameraID() == Lobby_camera_manager_module:GetStoreVehicleTopViewCameraId() then
    self.UIRoot.WidgetSwitcher_CarView:SetActiveWidgetIndex(0)
  else
    self.UIRoot.WidgetSwitcher_CarView:SetActiveWidgetIndex(1)
  end
end
function SubTabButtons:OnNormalViewClicked()
  self:PlayAudio(sound_config.click_v1)
  self:SelectNormalView()
end
function SubTabButtons:SelectNormalView()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera_Only(Lobby_camera_manager_module:GetStoreVehicleCameraId())
end
function SubTabButtons:OnTopViewClicked()
  self:PlayAudio(sound_config.click_v1)
  self:SelectTopView()
end
function SubTabButtons:SelectTopView()
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera_Only(Lobby_camera_manager_module:GetStoreVehicleTopViewCameraId())
end
function SubTabButtons:OnCameraSwitch()
  log(bWriteLog and "SubTabButtons:OnCameraSwitch ")
  self:RefreshButton()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSubTabButtons = class(ui_base, nil, SubTabButtons)
return CSubTabButtons