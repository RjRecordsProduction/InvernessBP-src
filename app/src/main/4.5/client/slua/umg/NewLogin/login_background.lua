local LoginBackground = {
  ENUM_BG_TYPE = {BP = 2, IMAGE = 3}
}
local DEFAULT_BLUEHOLE_BG = "/Game/Mod/Lobby/Base/Login/Texture/NoAtlas/LOGIN_image_bg_1_kr_jp_.LOGIN_image_bg_1_kr_jp_"
function LoginBackground:ctor(_, type, ResPath, BGMPath, TexPath)
  self.  self.  self.  self.end
function LoginBackground:OnConstruct(type, ResPath, BGMPath, TexPath)
  self.  self.  self.  self.  self:OnShow()
end
function LoginBackground:OnInitialize()
  self.UIRoot.Image_LoginBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function LoginBackground:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOGIN, EVENTID_UPDATE_BACKGROUND_IMAGE, self.UpdateImage, self)
end
function LoginBackground:OnShow()
  if self.type == LoginBackground.ENUM_BG_TYPE.BP then
    self:ShowBP()
  elseif self.type == LoginBackground.ENUM_BG_TYPE.IMAGE then
    self:ShowImage()
  end
end
function LoginBackground:ShowBP()
  self.UIRoot.Switcher:SetActiveWidgetIndex(1)
  if self.bgPanel then
    self.bgPanel:Close()
    self.bgPanel = nil
  end
  local region = Client.GetPublishRegion()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  log_warning(bWriteLog and "  LoginBackground:ShowBP. self.ResPath " .. tostring(self.ResPath))
  if self.ResPath and self.ResPath ~= "" then
    self.bgPanel = self:CreateChildWindowWithBpPath("BGRoot", nil, self.ResPath)
  end
  if not self.bgPanel or not self.bgPanel.UIRoot then
    log(bWriteLog and "LoginBackground:ShowBP false path = " .. tostring(self.ResPath))
    self:ShowImage()
    return
  end
  self:AddTimerOnce(0, function()
    GlobalData.StopLobbyBGM()
    self:PlayAudio(self.BGMPath)
  end)
  if region == PublishRegionMacros.BLUEHOLE then
    if self.bgPanel.UIRoot.ScaleBox_AllFx then
      self:SetWidgetVisible(self.bgPanel.UIRoot.ScaleBox_AllFx, false)
    end
    local asset_util = require("common.asset_util")
    local texture = asset_util.GetAssetSync(DEFAULT_BLUEHOLE_BG)
    if self.bgPanel.UIRoot.Image_LoginBg then
      self.bgPanel.UIRoot.Image_LoginBg:SetBrushFromTexture(texture, false)
    end
  end
  local anim = self.bgPanel.UIRoot.NewAnimation_bird
  if anim then
    log(bWriteLog and "[ : it has Anim")
    self.bgPanel:PlayUserWidgetAnimation(anim, 0, 0, 0, 1)
  end
end
function LoginBackground:ShowImage()
  self.UIRoot.Switcher:SetActiveWidgetIndex(0)
  local asset_util = require("common.asset_util")
  local texture = asset_util.GetAssetSync(self.TexPath)
  self.UIRoot.Image_LoginBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Image_LoginBG:SetBrushFromTexture(texture, false)
end
function LoginBackground:UpdateImage(_, _, isShow, texture)
  if self.type ~= LoginBackground.ENUM_BG_TYPE.IMAGE then
    return
  end
  if isShow ~= nil then
    if isShow then
      self.UIRoot.Image_LoginBG:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      self.UIRoot.Image_LoginBG:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
  end
  if texture then
    self.UIRoot.Image_LoginBG:SetBrushFromTexture(texture, false)
  end
end
function LoginBackground:OnClose()
  if self.bgPanel then
    self.bgPanel:Close()
    self.bgPanel = nil
  end
  GlobalData.StopLobbyBGM()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLoginBackground = class(ui_base, nil, LoginBackground)
return CLoginBackground