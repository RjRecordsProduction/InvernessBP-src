local UnknowPass_Medal_Item_UIBP = {}
function UnknowPass_Medal_Item_UIBP:SetData(seasonId, isBuyElite, passLevel)
  local util = require("client.slua_ui_framework.util")
  local versionStr = "2_6_0"
  local seasonCfg = CDataTable.GetTableData("UnknowPassSeasonTimeCfg", seasonId)
  if seasonCfg then
    versionStr = seasonCfg.ResourseVerion
  end
  local MedalBgPath = string.format("%s%s%s", "/Game/Arts_UI/UnknowPass/Common/", versionStr, "/Atlas/Frames/Battlepass_di_png.Battlepass_di_png")
  local BougntNumPath = string.format("%s%s%s", "/Game/Arts_UI/UnknowPass/Common/", versionStr, "/Atlas/Frames/RP_%d_png.RP_%d_png")
  local NotBuyNumPath = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RPA_%d_normal_png.RPA_%d_normal_png"
  local seriesNum = UnknowPassSystem.GetSeriesBySeason(seasonId)
  local param = {sync = true}
  if seriesNum == UnknowPassSystem.ESeries.S then
    NotBuyNumPath = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RP_%d_normal_png.RP_%d_normal_png"
    if not isBuyElite then
      self.WidgetSwitcher_Medal:SetActiveWidgetIndex(0)
      self:ShowLevelForThreeImage(self.Medal_Normal_S_100, self.Medal_Normal_S_10, self.Medal_Normal_S_1, passLevel, NotBuyNumPath)
    else
      self.WidgetSwitcher_Medal:SetActiveWidgetIndex(1)
      self:ShowLevelForThreeImage(self.Medal_Plus_S_100, self.Medal_Plus_S_10, self.Medal_Plus_S_1, passLevel, BougntNumPath)
      util.SetTexture(self.Medal_Plus_S, MedalBgPath, param)
    end
  elseif seriesNum == UnknowPassSystem.ESeries.M then
    NotBuyNumPath = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RP_%d_png.RP_%d_png"
    if not isBuyElite then
      self.WidgetSwitcher_Medal:SetActiveWidgetIndex(2)
      self:ShowLevelForThreeImage(self.Medal_Normal_M_100, self.Medal_Normal_M_10, self.Medal_Normal_M_1, passLevel, NotBuyNumPath)
    else
      self.WidgetSwitcher_Medal:SetActiveWidgetIndex(3)
      self:ShowLevelForThreeImage(self.Medal_Plus_M_100, self.Medal_Plus_M_10, self.Medal_Plus_M_1, passLevel, BougntNumPath)
      util.SetTexture(self.Medal_Plus_M, MedalBgPath, param)
    end
  elseif seriesNum == UnknowPassSystem.ESeries.A then
    NotBuyNumPath = "/Game/UMG/Texture/Atlas/UnknowntrialUI/Frames/RPA_%d_normal_png.RPA_%d_normal_png"
    if not isBuyElite then
      self.WidgetSwitcher_Medal:SetActiveWidgetIndex(4)
      self:ShowLevelForThreeImage(self.Medal_Normal_A_100, self.Medal_Normal_A_10, self.Medal_Normal_A_1, passLevel, NotBuyNumPath)
    else
      self.WidgetSwitcher_Medal:SetActiveWidgetIndex(5)
      self:ShowLevelForThreeImage(self.Medal_Plus_A_100, self.Medal_Plus_A_10, self.Medal_Plus_A_1, passLevel, BougntNumPath)
      util.SetTexture(self.Medal_Plus_A, MedalBgPath, param)
    end
  end
end
function UnknowPass_Medal_Item_UIBP:ShowLevelForThreeImage(widget1, widget2, widget3, passLevel, numPath)
  if not (widget1 and widget2) or not widget3 then
    return
  end
  local UIUtil = require("client.common.ui_util")
  widget2:SetWidgetVisibility(UIUtil.BoolToVisible(10 <= passLevel))
  widget1:SetWidgetVisibility(UIUtil.BoolToVisible(100 <= passLevel))
  local util = require("client.slua_ui_framework.util")
  local param = {sync = true}
  if passLevel < 10 then
    util.SetTexture(widget3, string.format(numPath, passLevel, passLevel), param)
    widget3:SetRenderScale(FVector2D(1.2, 1.2))
  elseif passLevel < 100 then
    local ten = math.floor(passLevel / 10)
    local sNumber = passLevel % 10
    util.SetTexture(widget2, string.format(numPath, ten, ten), param)
    util.SetTexture(widget3, string.format(numPath, sNumber, sNumber), param)
    widget2:SetRenderScale(FVector2D(1.2, 1.2))
    widget3:SetRenderScale(FVector2D(1.2, 1.2))
  else
    util.SetTexture(widget1, string.format(numPath, 1, 1), param)
    util.SetTexture(widget2, string.format(numPath, 0, 0), param)
    util.SetTexture(widget3, string.format(numPath, 0, 0), param)
    widget1:SetRenderScale(FVector2D(1, 1))
    widget2:SetRenderScale(FVector2D(1, 1))
    widget3:SetRenderScale(FVector2D(1, 1))
  end
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, UnknowPass_Medal_Item_UIBP)