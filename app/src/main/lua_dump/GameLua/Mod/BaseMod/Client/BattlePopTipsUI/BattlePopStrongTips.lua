local BattlePopStrongTips = {}
local STExtraMapFunctionLibrary = import("STExtraMapFunctionLibrary")
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
function BattlePopStrongTips:ctor()
  printf("BattlePopStrongTips:ctor")
  self.DefaultBgImagePath = "/Game/Arts/UI/Atlas/BattleUI/General_Ver1/Frames/ZD_image_blue_effects_png_png.ZD_image_blue_effects_png_png"
  self.DefaultIconImagePath = "/Game/Arts/UI/Atlas/BattleUI/General_RGBA/Frames/ZD_icon_blue_fushe_png.ZD_icon_blue_fushe_png"
  self.DefaultBgImagePadding = {
    -50,
    0,
    -100.0,
    0
  }
end
function BattlePopStrongTips:OnInitialize()
  printf("BattlePopStrongTips:OnInitialize")
  BattlePopStrongTips.__super.OnInitialize(self)
  self:AttachToParent()
end
function BattlePopStrongTips:AttachToParent()
  local BattlePopTips = UIManager.GetUI(UIManager.UI_Config_InGame.BattlePopTips)
  if BattlePopTips then
    BattlePopTips:AttachChildWindow("CanvaPanelRoot", self)
    self:SetAnchors(0, 0, 1, 1)
    self:SetOffsets(0, 0, 0, 0)
  end
end
function BattlePopStrongTips:PreparePopTips(TipsType, TipsValue)
  BattlePopStrongTips.__super.PreparePopTips(self, TipsType, TipsValue)
  if not slua.isValid(self.UIRoot) then
    return
  end
  local bgItem = {
    TexturePath = TipsValue.BgImagePath == "" and self.DefaultBgImagePath or TipsValue.BgImagePath,
    Padding = TipsValue.BgImagePadding,
    ImageSize = TipsValue.BgImageSize,
    bImageOriginalSize = true,
    bKeepSize = true
  }
  if bgItem.Padding == nil or bgItem.Padding == "" then
    bgItem.Padding = self.DefaultBgImagePadding
  end
  self:SetControlTextureAsync(self.UIRoot.Image_BG, bgItem)
  local iconItem = {
    TexturePath = TipsValue.IconPath == "" and self.DefaultIconImagePath or TipsValue.IconPath,
    bImageOriginalSize = true
  }
  if TipsValue.IconSize ~= nil and TipsValue.IconSize ~= "" then
    local SizeStrFunction = "return " .. TipsValue.IconSize
    iconItem.ImageSize = load(SizeStrFunction)()
  end
  self:SetControlTextureAsync(self.UIRoot.Image_Icon, iconItem)
end
function BattlePopStrongTips:SetContentText(Content)
  if Content ~= nil then
    self.UIRoot.TipsContent:SetText(Content)
  end
end
function BattlePopStrongTips:SetTipsOffset(OffsetX, OffsetY)
end
local class = require("class")
local BattlePopTipsBase = require("GameLua.Mod.BaseMod.Client.BattlePopTipsUI.BattlePopTipsBase")
local CBattlePopStrongTips = class(BattlePopTipsBase, nil, BattlePopStrongTips)
return CBattlePopStrongTips