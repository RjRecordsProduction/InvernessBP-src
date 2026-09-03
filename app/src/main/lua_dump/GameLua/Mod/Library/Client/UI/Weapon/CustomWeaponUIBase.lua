local CustomWeaponUIBase = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local InGameUITools = require("GameLua.Mod.BaseMod.Common.UI.InGameUITools")
function CustomWeaponUIBase:ctor()
  print(bWriteLog and "CustomWeaponUIBase:ctor")
end
function CustomWeaponUIBase:OnPostInitialize()
  print(bWriteLog and "CustomWeaponUIBase:OnPostInitialize")
  local bIsOB = false
  local PlayerController = GameplayData.GetPlayerController()
  if slua.isValid(PlayerController) then
    bIsOB = PlayerController:IsInSpectating()
  end
  if bIsOB then
    local PlayerInfoPanelMain = UIManager.GetUI(UIManager.UI_Config_InGame.WatchGamePlayerInfo)
    if PlayerInfoPanelMain then
      PlayerInfoPanelMain:AttachChildWindow("CanvasPanel_IPX", self)
    else
      print(bWriteLog and "CustomWeaponUIBase:OnPostInitialize - WatchGamePlayerInfo is nil")
      self:Collapsed()
    end
  else
    local ShootingUIPanel = InGameUITools.GetShootingUIPanelLuaClass()
    if not ShootingUIPanel then
      print(bWriteLog and "CustomWeaponUIBase:OnPostInitialize - ShootingUIPanel is nil")
      return
    end
    ShootingUIPanel:AttachChildWindow("CanvasPanel_CustomWeaponUI", self)
  end
  if self.UIRoot.Slot then
    self.UIRoot.Slot:SetAnchors(FAnchors(0, 0, 1, 1))
    self.UIRoot.Slot:SetOffsets(FMargin(0, 0, 0, 0))
  end
end
function CustomWeaponUIBase:UpdateCurrentWeapon(CurrentUsingWeapon)
  print(bWriteLog and "CustomWeaponUIBase:UpdateCurrentWeapon")
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, CustomWeaponUIBase)