local BattlePopWeakTips = {}
local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BattlePopWeakTips:ctor()
  printf("BattlePopWeakTips:ctor")
  self.DefaultBgImagePath = "/Game/Arts/UI/NoAtlas/Guide/T_image_tips_bg.T_image_tips_bg"
  self.DefaultBgImageSize = {256.0, 64.0}
  self.DefaultBgImagePadding = {
    -50.0,
    -20.0,
    -50.0,
    -22.0
  }
  self.AllShowUIWidget = {
    "ImageBorder"
  }
  self.AllHideUIWidget = {
    "Border_GameGuide"
  }
end
function BattlePopWeakTips:OnInitialize()
  printf("BattlePopWeakTips:OnInitialize")
  BattlePopWeakTips.__super.OnInitialize(self)
  self:AttachToParent()
end
function BattlePopWeakTips:AttachToParent()
  if UIManager.UI_Config_InGame.BattlePopTips then
    local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
    if BattlePopTips then
      BattlePopTips:AttachChildWindow("CanvaPanelRoot", self)
      self:SetAnchors(0, 0, 1, 1)
      self:SetOffsets(0, 0, 0, 0)
    end
  end
end
function BattlePopWeakTips:PreparePopTips(TipsType, TipsValue)
  BattlePopWeakTips.__super.PreparePopTips(self, TipsType, TipsValue)
  if not slua.isValid(self.UIRoot) then
    return
  end
  local bgItem = {
    TexturePath = TipsValue.BgImagePath,
    Padding = TipsValue.BgImagePadding,
    ImageSize = TipsValue.BgImageSize,
    bImageOriginalSize = true,
    bKeepSize = true
  }
  if bgItem.TexturePath == nil or bgItem.TexturePath == "" then
    bgItem.TexturePath = self.DefaultBgImagePath
  end
  if bgItem.Padding == nil or bgItem.Padding == "" then
    bgItem.Padding = self.DefaultBgImagePadding
  end
  self:SetControlTextureAsync(self.UIRoot.Image_BG, bgItem)
  local iconItem = {
    TexturePath = TipsValue.IconPath,
    bImageOriginalSize = true
  }
  if TipsValue.IconSize ~= nil and TipsValue.IconSize ~= "" then
    local SizeStrFunction = "return " .. TipsValue.IconSize
    iconItem.ImageSize = load(SizeStrFunction)()
  end
  self:SetControlTextureAsync(self.UIRoot.Image_Icon, iconItem)
end
function BattlePopWeakTips:SetContentText(Content)
  local TextBlock = self.UIRoot.TipsContent
  if self.TipsValue and self.TipsValue.TipsTextBlockStr then
    TextBlock = self.UIRoot[self.TipsValue.TipsTextBlockStr]
  end
  if TextBlock and slua.isValid(TextBlock) then
    TextBlock:SetText(Content)
  end
  self.UIRoot:ForceLayoutPrepass()
end
function BattlePopWeakTips:SetTipsOffset(OffsetX, OffsetY)
  if OffsetX and OffsetY then
    self.UIRoot:SetRenderTranslation(FVector2D(OffsetX, OffsetY))
  else
    self.UIRoot:SetRenderTranslation(FVector2D(0, 0))
  end
end
local class = require("class")
local BattlePopTipsBase = require("GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopTipsBase")
local CBattlePopWeakTips = class(BattlePopTipsBase, nil, BattlePopWeakTips)
return CBattlePopWeakTips