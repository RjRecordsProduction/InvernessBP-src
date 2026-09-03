local PlaneShowAliasEnterBroadcastUI = {}
function PlaneShowAliasEnterBroadcastUI:RegistEvents()
  log(bWriteLog and "PlaneShowAliasEnterBroadcastUI:RegistEvents")
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_PLAYER_ALIAS_BROADCAST_RSP, self.OnAliasBroadcastRsp, self)
end
function PlaneShowAliasEnterBroadcastUI:OnShow()
  log(bWriteLog and "PlaneShowAliasEnterBroadcastUI:OnShow")
  self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local UGameplayStatics = import("GameplayStatics")
  local PC = UGameplayStatics.GetPlayerController(CGameState, 0)
  if Game:IsValid(PC) and PC.CommerFeature then
    PC.CommerFeature:RPCServer_AliasEnterBroadcastReq()
  end
  if not self.CloseUITimer then
    self.CloseUITimer = self:AddGameTimer(4, false, function()
      self:CloseSelfUI()
    end)
  end
end
function PlaneShowAliasEnterBroadcastUI:_SetAliasEnterBroadcast(AliasID, XSuitIconID, PlayerName, CollectScore)
  log(bWriteLog and "PlaneShowAliasEnterBroadcastUI:_SetAliasEnterBroadcast")
  local Msg = FuncUtil.GenEnterBroadcastMsg(AliasID, PlayerName, CollectScore)
  if not self.EnterBroadcastUI then
    self.EnterBroadcastUI = self:CreateChildWindow("CanvasPanel_1", UIManager.UI_Config.EnterBroadcastItem)
  end
  self.EnterBroadcastUI:SetAnchors(0.5, 0.5, 0.5, 0.5)
  self.EnterBroadcastUI:UpdateUI({
    AliasID = AliasID,
    XSuitIconID = XSuitIconID,
      })
end
function PlaneShowAliasEnterBroadcastUI:OnAliasBroadcastRsp(_, _, AliasID, XSuitIconID, PlayerName, CollectScore)
  log(bWriteLog and string.format("PlaneShowAliasEnterBroadcastUI:OnAliasBroadcastRsp AliasID: %s, XSuitIconID: %s", tonumber(AliasID), tonumber(XSuitIconID)))
  if AliasID == 0 then
    return
  end
  self:_SetAliasEnterBroadcast(AliasID, XSuitIconID, PlayerName, CollectScore)
  self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
end
function PlaneShowAliasEnterBroadcastUI:CloseSelfUI()
  if self.CloseUITimer then
    Game:ClearTimer(self.CloseUITimer)
    self.CloseUITimer = nil
  end
  self:CloseSelf()
end
function PlaneShowAliasEnterBroadcastUI:ReceivePlaneShowEnd()
  self:CloseSelfUI()
end
local class = require("class")
local UIBase = require("client.slua_ui_framework.base")
return class(UIBase, nil, PlaneShowAliasEnterBroadcastUI)