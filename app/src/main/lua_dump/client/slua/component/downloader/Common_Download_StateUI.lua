local Common_Download_StateUI = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function Common_Download_StateUI:OnInitialize()
end
function Common_Download_StateUI:RegistEvents()
end
function Common_Download_StateUI:OnClose()
  self:ResetData()
end
function Common_Download_StateUI:ResetData()
  self.state = nil
  self.isShowAni = nil
end
function Common_Download_StateUI:SetIconColor(color)
  if not color then
    return
  end
  self.Border_0:SetContentColorAndOpacity(color)
end
function Common_Download_StateUI:SetPercent(percent)
  if self.Image_Progress then
    percent = percent or 0
    local dynamicMaterial = self.Image_Progress:GetDynamicMaterial()
    if dynamicMaterial then
      dynamicMaterial:SetScalarParameterValue("Mask_Percent", percent)
    end
  end
end
local E_DownloadState = PufferConst.ENUM_DownloadState
local iconStyleCfgs = {
  [PufferConst.Enum_StateIcon.Ani] = {
    [E_DownloadState.Not] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png",
    [E_DownloadState.Download] = "/Game/UMG/Texture_200/Lobby_NoAtlas/Download/Download_Icon_Cloud.Download_Icon_Cloud",
    [E_DownloadState.Pause] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png",
    [E_DownloadState.Done] = "",
    [E_DownloadState.Error] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Download_png.Common_Icon_Download_png",
    [E_DownloadState.Wait] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Wait_png.Common_Icon_Wait_png",
    [E_DownloadState.Update] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reflash_png.Common_Icon_Reflash_png"
  },
  [PufferConst.Enum_StateIcon.RoundIcon] = {
    [E_DownloadState.Not] = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_xiazai_01_png.Setting_icon_xiazai_01_png",
    [E_DownloadState.Download] = "/Game/UMG/Texture_200/Lobby_NoAtlas/Download/Download_Icon_Cloud.Download_Icon_Cloud",
    [E_DownloadState.Pause] = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_xiazai_01_png.Setting_icon_xiazai_01_png",
    [E_DownloadState.Done] = "",
    [E_DownloadState.Error] = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_xiazai_01_png.Setting_icon_xiazai_01_png",
    [E_DownloadState.Wait] = "/Game/UMG/Texture/Atlas/Common_Atlas/Frames/Setting_icon_dengdai_png.Setting_icon_dengdai_png",
    [E_DownloadState.Update] = "/Game/UMG/Texture_200/Atlas/Common_New_Atlas/Frames/Common_Icon_Reflash_png.Common_Icon_Reflash_png"
  }
}
local ColorNormal = FLinearColor(1, 1, 1, 1)
local ColorPause = FLinearColor(0.5, 0.5, 0.5, 1)
function Common_Download_StateUI:UpdateStateUI(state, params)
  local util = require("client.slua_ui_framework.util")
  local path = ""
  if state == E_DownloadState.Wait and (not params or not params.showWaitState) then
    state = E_DownloadState.Download
  end
  local Enum_StateIcon = PufferConst.Enum_StateIcon
  local iconStyleValue = params and params.enumIconState or Enum_StateIcon.Ani
  local iconStyleCfg = iconStyleCfgs[iconStyleValue]
  path = iconStyleCfg and iconStyleCfg[state] or iconStyleCfgs[Enum_StateIcon.Ani][E_DownloadState.Not]
  local UIUtil = require("client.common.ui_util")
  local roundBgShow = iconStyleValue == Enum_StateIcon.Ani
  if params and params.hideRoundBg then
    roundBgShow = false
  end
  UIUtil.SetWidgetVisible(self.Image_State_Bg, roundBgShow)
  UIUtil.SetWidgetVisible(self.Image_Loop, roundBgShow)
  UIUtil.SetWidgetVisible(self.Image_Progress, roundBgShow and state ~= E_DownloadState.Done and state ~= E_DownloadState.Error)
  if state ~= E_DownloadState.Pause then
    self.Image_Progress:SetColorAndOpacity(ColorNormal)
  else
    self.Image_Progress:SetColorAndOpacity(ColorPause)
  end
  util.SetTexture(self.Image_State, path, {sync = false})
  local showAni = state == PufferConst.ENUM_DownloadState.Download
  if self.isShowAni ~= showAni then
    if showAni then
      self:PlayUserWidgetAnimation(self.Anim_Loop01, 0, 0, 0, 1)
    else
      self:StopAnimation(self.Anim_Loop01)
    end
  end
  self.isShowAni = showAni
  UIUtil.SetWidgetVisible(self.CanvasPanel_Arrow, showAni)
  local color = ColorNormal
  if params and params.iconColor then
    color = params.iconColor
  end
  self:SetIconColor(color)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.OverrideUIBase")
local CCommon_Download_StateUI = class(ui_base, nil, Common_Download_StateUI)
return CCommon_Download_StateUI