local Setting_Mirror_Main_UIBP = {}
local SGunSightPaths = {
  default = {
    [1] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_1_png.Setting_icon_zhunxing_1_png",
    [2] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_2_png.Setting_icon_zhunxing_2_png",
    [3] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_3_png.Setting_icon_zhunxing_3_png",
    [4] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_4_png.Setting_icon_zhunxing_4_png"
  },
  CrossHairType = {
    [1] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_4_png.Setting_icon_zhunxing_4_png",
    [2] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_3_png.Setting_icon_zhunxing_3_png",
    [3] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_7_png.Setting_icon_zhunxing_7_png",
    [4] = "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_1_png.Setting_icon_zhunxing_1_png"
  }
}
function Setting_Mirror_Main_UIBP:ctor()
  self.nTitleIndex = 1
  self.colorKeys = {
    "CrossHairColor",
    "RedDotCHColor",
    "HolographicCHColor",
    "SideMirrorColor",
    "Sinper2xCHColor",
    "Sniper3xCHColor"
  }
  self.shapeKeys = {
    "CrossHairType",
    "RedDotCHType",
    nil,
    "SideMirrorType"
  }
  local   self.CHColors = {
    [1] = FLinearColor(0.95, 0.95, 0.95, 1),
    [2] = FLinearColor(0.93, 0.058, 0.058, 1),
    [3] = FLinearColor(0.8, 0.67, 0.03, 1),
    [4] = FLinearColor(0, 0.98, 0.08, 1),
    [5] = FLinearColor(0.01, 0.74, 0.84, 1),
    [6] = FLinearColor(0.03, 0.25, 0.41, 1),
    [7] = FLinearColor(0.61, 0.13, 0.61, 1),
    [8] = FLinearColor(0.99, 0.38, 0.54, 1),
    [9] = FLinearColor(0, 0, 0, 1)
  }
  self.itemColors = {
    [1] = FLinearColor(0.95, 0.95, 0.95, 1),
    [2] = FLinearColor(0.72, 0.01, 0.01, 1),
    [3] = FLinearColor(0.62, 0.56, 0.02, 1),
    [4] = FLinearColor(0, 0.42, 0.01, 1),
    [5] = FLinearColor(0.01, 0.52, 0.68, 1),
    [6] = FLinearColor(0.01, 0.26, 0.75, 1),
    [7] = FLinearColor(0.71, 0.02, 0.69, 1),
    [8] = FLinearColor(0.98, 0.12, 0.25, 1),
    [9] = FLinearColor(0, 0, 0, 1)
  }
  self.MirrorPaths = {
    nil,
    nil,
    "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_5_png.Setting_icon_zhunxing_5_png",
    nil,
    "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_6_png.Setting_icon_zhunxing_6_png",
    "/Game/UMG/Texture/Atlas/SettingUI/Frames/Setting_icon_zhunxing_3beijing_png.Setting_icon_zhunxing_3beijing_png"
  }
  self.ImageNames = {
    "Image_NotopenMirror",
    "Image_RedDotPreview",
    "HolographicSight_Preview",
    "Image_SideSightPreView",
    "Double_Preview",
    "Sniper3xPreview"
  }
end
function Setting_Mirror_Main_UIBP:OnInitialize()
  self.LoopScrollGrid_Shape = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Shape, "client.slua.umg.Setting.SettingMirror.Item.Setting_MirrorShapeItem")
  self.LoopScrollGrid_Color = self:InitChildClassScrollBox(self.UIRoot.LoopScrollGrid_Color, "client.slua.umg.Setting.SettingMirror.Item.Setting_MirrorColorItem")
  self.Common_Tab_Horizontal_LevelThree = self:InitHorizontalLevelThreeTextTab(self.UIRoot.Common_Tab_Horizontal_LevelThree_Text_UIBP, {bDarkMode = true})
end
function Setting_Mirror_Main_UIBP:RegistEvents()
end
function Setting_Mirror_Main_UIBP:OnPostInitialize()
  self:UpdateUI()
end
function Setting_Mirror_Main_UIBP:OnClose()
  slua_GameFrontendHUD:FinishModifyUserSettings()
end
function Setting_Mirror_Main_UIBP:UpdateUI()
  log(bWriteLog and "Setting_Mirror_Main_UIBP:UpdateUI")
  local common_tab_data = {
    LocUtil.GetLocalizeResStr(370094),
    LocUtil.GetLocalizeResStr(370095),
    LocUtil.GetLocalizeResStr(370096),
    LocUtil.GetLocalizeResStr(370097),
    LocUtil.GetLocalizeResStr(370098),
    LocUtil.GetLocalizeResStr(370099)
  }
  self.Common_Tab_Horizontal_LevelThree:SetTabs(common_tab_data)
  self.Common_Tab_Horizontal_LevelThree:AddOnClickedCallback(self.OnLevelTwoTabClicked, self)
  self.UIRoot.CanvasPanel_4:SetVisibility(UEnums.ESlateVisibility.Visible)
  self.Common_Tab_Horizontal_LevelThree:Show()
  self.Common_Tab_Horizontal_LevelThree:Select(1)
  self.nTitleIndex = 1
  self:UpdateGun()
end
function Setting_Mirror_Main_UIBP:OnLevelTwoTabClicked(_, index)
  self:PlayAudio(sound_config.click)
  self.nTitleIndex = index
  self:UpdateGun()
end
function Setting_Mirror_Main_UIBP:UpdateGun()
  local Root = self.UIRoot
  self.LoopScrollGrid_Color:SetData(self.CHColors)
  local colorKey = self:GetColorKey()
  self.UIRoot.WidgetSwitcher_frontSight:SetActiveWidgetIndex(self.nTitleIndex - 1)
  self.UIRoot.WidgetSwitcher_CanvasPanelRoot:SetActiveWidgetIndex(0)
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  local colorValue = SettingModule:GetOptionValue(colorKey)
  self:SelectOneColor(colorValue)
  local shapeKey = self:GetShapeKey()
  if shapeKey then
    local shapeData = self:GetShapeData(shapeKey)
    self.LoopScrollGrid_Shape:SetData(shapeData)
    local shapeValue = SettingModule:GetOptionValue(shapeKey)
    self:SelectOneShape(shapeValue)
  else
    self:SelectOneShape()
  end
  self:SetWidgetVisible(Root.TextBlock_Mirror, shapeKey)
  self:SetWidgetVisible(Root.LoopScrollGrid_Shape, shapeKey, true)
end
function Setting_Mirror_Main_UIBP:SelectOneColor(index)
  self.LoopScrollGrid_Color:Select(index)
  local colorKey = self:GetColorKey()
  local imageName = self.ImageNames[self.nTitleIndex]
  self.UIRoot[imageName]:SetColorAndOpacity(self.CHColors[index])
  local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
  SettingModule:SetOptionValue(colorKey, index)
end
function Setting_Mirror_Main_UIBP:SelectOneShape(index)
  local imageName = self.ImageNames[self.nTitleIndex]
  local image = self.UIRoot[imageName]
  if index then
    self.LoopScrollGrid_Shape:Select(index)
    local shapeKey = self:GetShapeKey()
    local SettingModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.SettingModule)
    SettingModule:SetOptionValue(shapeKey, index)
    self:SetTexture(image, self:GetShapePath(index))
    EventSystem:postEvent(EVENTTYPE_SETTING, EVENTID_SETTING_REFRESH_CROSSHAIR)
  else
    local path = self.MirrorPaths[self.nTitleIndex]
    if path then
      self:SetTexture(image, path)
    end
  end
end
function Setting_Mirror_Main_UIBP:GetColorKey()
  return self.colorKeys[self.nTitleIndex]
end
function Setting_Mirror_Main_UIBP:GetShapeKey()
  return self.shapeKeys[self.nTitleIndex]
end
function Setting_Mirror_Main_UIBP:GetShapePath(index)
  local shapeKey = self:GetShapeKey()
  local paths = SGunSightPaths[shapeKey] or SGunSightPaths.default
  return paths and paths[index]
end
function Setting_Mirror_Main_UIBP:GetShapeData(shapeKey)
  local paths = SGunSightPaths[shapeKey] or SGunSightPaths.default
  if not paths then
    log_warning_format("Setting_Mirror_Main_UIBP:GetShapeData. No shape config found for key: %s", shapeKey)
    return {}
  end
  local shapeData = {}
  for i = 1, #paths do
    shapeData[i] = i
  end
  log_format("Setting_Mirror_Main_UIBP:GetShapeData. shapeKey: %s, count: %s", shapeKey, #shapeData)
  return shapeData
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Setting_Mirror_Main_UIBP)