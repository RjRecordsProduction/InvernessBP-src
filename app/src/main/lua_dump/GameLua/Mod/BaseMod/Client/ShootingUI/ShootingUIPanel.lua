local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local GameMainConfig = require("GameLua.GameCore.Main.GameMainConfig")
local ShootingUIPanel = {}
function ShootingUIPanel:ctor()
  self.bNeedDelayRegistEvents = true
  self.uWeaponManager = nil
  self.TotalReloadTime = 1.0
  self.ShootingUIPanelMain = nil
end
function ShootingUIPanel:Construct()
  self.ShootingUIPanelMain = {}
  local ModType = GameMainConfig.GetModType()
  local ModPath = string.format("GameLua.Mod.%s.Client.ShootingUI.ShootingUIPanelMain", ModType)
  local DefaultPath = "GameLua.Mod.BaseMod.Client.ShootingUI.ShootingUIPanelMain"
  local FinalPath = GamePlayTools.LuaFileExits(ModPath) and ModPath or DefaultPath
  self.ShootingUIPanelMain.Super = self:AddChildWidget(self.Object, FinalPath)
end
function ShootingUIPanel:ReceivedInitWidget()
  if self.ShootingUIPanelMain and self.ShootingUIPanelMain.Super then
    self.ShootingUIPanelMain.Super:OnInitializeDelay()
    self.ShootingUIPanelMain.Super:RegistEventsDelay()
  end
end
function ShootingUIPanel:RegistEvents()
end
function ShootingUIPanel:Destruct()
  if self.ShootingUIPanelMain then
    self.ShootingUIPanelMain.Super:OnDestruct()
  end
  ShootingUIPanel.__super.Destruct(self)
end
function ShootingUIPanel:OnDestroy()
  self.ShootingUIPanelMain = nil
  ShootingUIPanel.__super.OnDestroy(self)
end
local class = require("class")
local CDelegateContainer = require("GameLua.Mod.BaseMod.Common.UI.UILuaUserWidget")
local CShootingUIPanel = class(CDelegateContainer, nil, ShootingUIPanel)
return CShootingUIPanel