local UILayoutConfig = {}
local LayoutNameConfig = {}
local Config = {}
LayoutNameConfig.UGCLayout = "UGCLayout"
LayoutNameConfig.SwimLayout = "SwimLayout"
LayoutNameConfig.HighLightLayout = "HighLightLayout"
LayoutNameConfig.PhotographerLayout = "PhotographerLayout"
LayoutNameConfig.VehicleDriverLayout = "VehicleDriverLayout"
LayoutNameConfig.UGCFreeCameraLayout = "UGCFreeCameraLayout"
LayoutNameConfig.VehiclePassengerLayout = "VehiclePassengerLayout"
LayoutNameConfig.UGCRestrictedOperationLayout = "UGCRestrictedOperationLayout"
LayoutNameConfig.UGCEditModeLayout = "UGCEditModeLayout"
LayoutNameConfig.VehicleDriverLayoutWithWeaponSlot = "VehicleDriverLayoutWithWeaponSlot"
Config[LayoutNameConfig.UGCLayout] = {
  MainControlBaseUI = FVector2D(2000, 0),
  ["MainControlBaseUI.BasicSkillsMenu_BP"] = FVector2D(-2000, 0)
}
Config[LayoutNameConfig.PhotographerLayout] = {
  MainControlBaseUI = FVector2D(2000, 0),
  ["MainControlBaseUI.BasicSkillsMenu_BP.LoopScrollBox_Interact"] = FVector2D(-2000, 0),
  ["MainControlBaseUI.BasicSkillsMenu_BP.CustomizeCanvasPanel_DriveAndGetIn"] = FVector2D(-2000, 0)
}
Config[LayoutNameConfig.UGCRestrictedOperationLayout] = {
  CanvasPanel_IPX = FVector2D(2000, 0),
  ["MainControlBaseUI.CanvasPanel_FreeCamera"] = FVector2D(-2000, 0)
}
Config[LayoutNameConfig.UGCFreeCameraLayout] = {
  CanvasPanel_IPX = FVector2D(2000, 0)
}
Config[LayoutNameConfig.UGCEditModeLayout] = {
  CanvasPanel_0 = FVector2D(5000, 0),
  ["ShootingUIPanel.AutoSprintPanelRoot"] = FVector2D(-5000, 0)
}
Config[LayoutNameConfig.SwimLayout] = {
  ["ShootingUIPanel.InvalidationBox_2"] = FVector2D(2000, 0),
  ["ShootingUIPanel.CanvasPanel_BuffList"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.ShootingUI_AutoSprint"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.MultiLayer_PMode"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.InvalidationBox_WeaponSlot"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.PistolBtnPanel"] = FVector2D(-2000, 0)
}
Config[LayoutNameConfig.VehicleDriverLayout] = {
  ["ShootingUIPanel.InvalidationBox_2"] = FVector2D(2000, 0),
  ["ShootingUIPanel.MultiLayer_PMode"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.ConsumeListPanel"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.CanvasPanel_BuffList"] = FVector2D(-2000, 0)
}
Config[LayoutNameConfig.VehicleDriverLayoutWithWeaponSlot] = {
  ["ShootingUIPanel.InvalidationBox_2"] = FVector2D(2000, 0),
  ["ShootingUIPanel.MultiLayer_PMode"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.ConsumeListPanel"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.PistolBtnPanel"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.CanvasPanel_BuffList"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.MultiLayer_GrenadeCanvas"] = FVector2D(-2000, 0),
  ["ShootingUIPanel.InvalidationBox_WeaponSlot"] = FVector2D(-2000, 0)
}
Config[LayoutNameConfig.VehiclePassengerLayout] = {
  ["ShootingUIPanel.LeanBtnPanel"] = FVector2D(2000, 0),
  ["ShootingUIPanel.Prone"] = FVector2D(2000, 0),
  ["ShootingUIPanel.Crouch"] = FVector2D(2000, 0),
  ["ShootingUIPanel.ShootingUI_AutoSprint"] = FVector2D(2000, 0),
  ["ShootingUIPanel.JumpVaultPanel"] = FVector2D(2000, 0),
  ["ShootingUIPanel.CanvasPanel_AICommand"] = FVector2D(2000, 0)
}
Config[LayoutNameConfig.HighLightLayout] = {
  CanvasPanel_IPX = FVector2D(2000, 0)
}
UILayoutConfig.UILayoutConfig.return UILayoutConfig