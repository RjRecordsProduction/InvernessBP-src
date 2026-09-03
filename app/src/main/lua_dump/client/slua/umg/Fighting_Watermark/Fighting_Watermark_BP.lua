local Fighting_Watermark_BP = {}
function Fighting_Watermark_BP:ctor()
  self.TextBlock = {}
end
function Fighting_Watermark_BP:OnInitialize()
  Fighting_Watermark_BP.__super.OnInitialize(self)
  for i = 1, 7 do
    table.insert(self.TextBlock, self.UIRoot["TextBlock" .. tostring(i)])
  end
  self:UpdateUI()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsCEVersion() then
    self.UIRoot.WidgetSwitcherBetaOrNot:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcherBetaOrNot:SetActiveWidgetIndex(0)
  end
end
function Fighting_Watermark_BP:RegistEvents()
  Fighting_Watermark_BP.__super.RegistEvents(self)
end
function Fighting_Watermark_BP:OnPostInitialize()
  Fighting_Watermark_BP.__super.OnPostInitialize(self)
end
function Fighting_Watermark_BP:UpdateUI()
  local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
  local strOutput = LobbyWaterMarkSystem.GetFightingWatermarkString()
  for k, v in pairs(self.TextBlock) do
    v:SetText(strOutput)
  end
end
function Fighting_Watermark_BP.RefreshWatermarkByGMSwitch()
  local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
  local isShow = LobbyWaterMarkSystem.CheckReleaseVersionWatermark()
  if isShow then
    UIManager.ShowUI(UIManager.UI_Config.Lobby_Watermark_BP)
  else
    UIManager.CloseUI(UIManager.UI_Config.Lobby_Watermark_BP)
  end
end
function Fighting_Watermark_BP.CreateWatermark()
  local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
  if not LobbyWaterMarkSystem.CheckReleaseVersionWatermark() then
    log(bWriteLog and string.format("Battle watermark opening conditions are not met."))
    return
  end
  if CGameState and slua.isValid(CGameState) and CGameState.IsCreativeMode and CGameState:IsCreativeMode() then
    local ECreativeModeGameType = import("ECreativeModeGameType")
    if CGameState:GetInitializeGameType() == ECreativeModeGameType.CreativeModeGameType_Editor then
      log(bWriteLog and string.format("Battle watermark close at UGC Editor."))
      return
    end
  end
  if not GameStatus.IsInFightingNotMainCity() then
    return
  end
  log(bWriteLog and "Fighting_Watermark_BP.CreateWatermark show ui")
  UIManager.ShowUI(UIManager.UI_Config.Fighting_Watermark_BP)
end
function Fighting_Watermark_BP.HideWatermark()
  local LobbyWaterMarkSystem = require("client.slua.logic.lobby_watermark.logic_lobby_watermark")
  if not LobbyWaterMarkSystem.CheckReleaseVersionWatermark() then
    log(bWriteLog and string.format("Battle watermark opening conditions are not met."))
    return
  end
  UIManager.CloseUI(UIManager.UI_Config.Fighting_Watermark_BP)
end
function Fighting_Watermark_BP:Close()
  self.TextBlock = {}
  Fighting_Watermark_BP.__super.Close(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CFighting_Watermark_BP = class(ui_base, nil, Fighting_Watermark_BP)
return CFighting_Watermark_BP