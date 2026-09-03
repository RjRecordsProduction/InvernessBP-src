local SurviveInfoPanel = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function SurviveInfoPanel:RefreshKillNum()
  SurviveInfoPanel.__super.RefreshKillNum(self)
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) or PlayerController.GetCurPlayerState == nil then
    print(bWriteLog and "[GodTrial]SurviveInfoPanel:RefreshKillNum invalid PlayerController")
    return
  end
  local CurrentPlayerState = PlayerController:GetCurPlayerState()
  if not slua.isValid(CurrentPlayerState) then
    print(bWriteLog and "[GodTrial]SurviveInfoPanel:RefreshKillNum invalid CurrentPlayerState")
    return
  end
  local nMercenaryKillNum = CurrentPlayerState.MercenaryFeature and CurrentPlayerState.MercenaryFeature.nMercenaryKillNum or 0
  print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:RefreshKillNum:PlayerKey=%s, Kills=%s, nMercenaryKillNum=%s", tostring(CurrentPlayerState.PlayerKey), tostring(CurrentPlayerState.Kills), tostring(nMercenaryKillNum)))
  if 0 < nMercenaryKillNum and self.UIRoot.HorizontalBox_3 and self.UIRoot.TextBlock_1 then
    self.UIRoot.HorizontalBox_3:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_1:SetText(tostring(nMercenaryKillNum))
  elseif self.UIRoot.HorizontalBox_3 then
    self.UIRoot.HorizontalBox_3:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:ResetRegistEvents(CurrentPlayerState)
end
function SurviveInfoPanel:PlayerKillsChange()
  SurviveInfoPanel.__super.PlayerKillsChange(self)
  local PlayerState = GameplayData.GetPlayerState()
  if not slua.isValid(PlayerState) then
    return
  end
  local nMercenaryKillNum = PlayerState.MercenaryFeature and PlayerState.MercenaryFeature.nMercenaryKillNum or 0
  print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:PlayerKillsChange PlayerKey=%s, nMercenaryKillNum=%s", tostring(PlayerState.PlayerKey), tostring(nMercenaryKillNum)))
  if 0 < nMercenaryKillNum and self.UIRoot.HorizontalBox_3 and self.UIRoot.TextBlock_1 then
    self.UIRoot.HorizontalBox_3:SetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.TextBlock_1:SetText(tostring(nMercenaryKillNum))
  elseif self.UIRoot.HorizontalBox_3 then
    self.UIRoot.HorizontalBox_3:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  self:ResetRegistEvents(PlayerState)
end
function SurviveInfoPanel:ResetRegistEvents(PlayerState)
  if not slua.isValid(PlayerState) or not PlayerState.MercenaryFeature then
    print(bWriteLog and "[GodTrial]SurviveInfoPanel:ResetRegistEvents return")
    return
  end
  if slua.isValid(self.uCacheMercenaryPlayerState) and self.uCacheMercenaryPlayerState == PlayerState then
    return
  end
  if slua.isValid(self.uCacheMercenaryPlayerState) and self.uCacheMercenaryPlayerState.MercenaryFeature then
    local MercenaryFeatureSuperData = self.uCacheMercenaryPlayerState.MercenaryFeature:GetSuperData()
    if MercenaryFeatureSuperData then
      self:RemoveDataListener(MercenaryFeatureSuperData, "nMercenaryKillNum")
    end
  end
  local MercenaryFeatureSuperData = PlayerState.MercenaryFeature:GetSuperData()
  if MercenaryFeatureSuperData then
    self:AddDataListener(MercenaryFeatureSuperData, "nMercenaryKillNum", self.OnMercenaryKillNumChanged, self)
  end
  if CGameState and CGameState.PlayerNumPerTeam and CGameState.PlayerNumPerTeam <= 1 then
    local uPlayerController = GameplayData.GetPlayerController()
    if not slua.isValid(uPlayerController) then
      print(bWriteLog and "[GodTrial]SurviveInfoPanel:ResetRegistEvents not slua.isValid(uPlayerController)")
      return
    end
    if uPlayerController:IsObserver() then
      self:RemoveCacheDataListener()
      UIManager.HideUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI)
      return
    end
    self:RemoveCacheDataListener()
    self.uCacheMercenary    local MercenaryFeatureSuperData = PlayerState.MercenaryFeature:GetSuperData()
    if MercenaryFeatureSuperData then
      self:AddDataListener(MercenaryFeatureSuperData, "bShowMercenaryUI", self.OnShowMercenaryUIChanged, self)
    end
  end
  self.uCacheMercenary  print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:ResetRegistEvents Set uCacheMercenaryPlayerState, PlayerState.PlayerKey=%s", tostring(PlayerState.PlayerKey)))
end
function SurviveInfoPanel:OnMercenaryKillNumChanged(nOldMercenaryKills, nMercenaryKillNum)
  print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:OnMercenaryKillNumChanged,Old=%s, nMercenaryKillNum=%s", tostring(nOldMercenaryKills), tostring(nMercenaryKillNum)))
  if self.UIRoot.Animation_Number then
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Number, 0, 1, 0, 1)
  end
end
function SurviveInfoPanel:RemoveCacheDataListener()
  if slua.isValid(self.uCacheMercenaryPlayerState) and self.uCacheMercenaryPlayerState.MercenaryFeature then
    print(bWriteLog and "[GodTrial]SurviveInfoPanel:ResetRegistEvents RemoveDataListener self.uCacheMercenaryPlayerState.PlayerKey=" .. tostring(self.uCacheMercenaryPlayerState.PlayerKey))
    self:RemoveDataListener(self.uCacheMercenaryPlayerState.MercenaryFeature:GetSuperData(), "bShowMercenaryUI")
    self.uCacheMercenaryPlayerState = nil
  end
end
function SurviveInfoPanel:OnShowMercenaryUIChanged(_, bShowMercenaryUI)
  local PlayerState = self.uCacheMercenaryPlayerState
  if not slua.isValid(PlayerState) or not PlayerState.MercenaryFeature then
    return
  end
  print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:OnShowMercenaryUIChanged,bShowMercenaryUI=%s, PlayerKey=%s", tostring(bShowMercenaryUI), tostring(PlayerState.PlayerKey)))
  if not UIManager.UI_Config_InGame.IngameMercenaryItemUI then
    return
  end
  if bShowMercenaryUI then
    local MercenaryFeatureSuperData = PlayerState.MercenaryFeature:GetSuperData()
    if not MercenaryFeatureSuperData or not MercenaryFeatureSuperData.MercenaryPSData then
      print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:OnShowMercenaryUIChanged,not MercenaryFeatureSuperData or not MercenaryFeatureSuperData.MercenaryPSData"))
      return
    end
    local uMercenaryPlayerState = MercenaryFeatureSuperData.MercenaryPSData
    if not slua.isValid(uMercenaryPlayerState) then
      print(bWriteLog and "[GodTrial]SurviveInfoPanel:OnShowMercenaryUIChanged not uMercenaryPlayerState", uMercenaryPlayerState)
      return
    end
    local MercenaryItemUI = UIManager.GetUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI)
    if MercenaryItemUI then
      print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:OnShowMercenaryUIChanged, UpdateMercenaryAndMaster, PlayerKey=%s", tostring(PlayerState.PlayerKey)))
      MercenaryItemUI:UpdateMercenaryAndMaster(PlayerState, uMercenaryPlayerState)
    end
    print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:OnShowMercenaryUIChanged, Show UI, PlayerKey=%s", tostring(PlayerState.PlayerKey)))
    UIManager.ShowUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI, PlayerState, uMercenaryPlayerState)
  else
    print(bWriteLog and string.format("[GodTrial]SurviveInfoPanel:OnShowMercenaryUIChanged, Hide UI, PlayerKey=%s", tostring(PlayerState.PlayerKey)))
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI)
  end
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.InGameUI.SurviveInfoPanel")
return class(UIBase, nil, SurviveInfoPanel)