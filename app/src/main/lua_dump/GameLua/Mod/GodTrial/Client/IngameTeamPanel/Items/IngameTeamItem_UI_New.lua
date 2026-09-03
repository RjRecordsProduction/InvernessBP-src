local IngameTeamItemUI = {}
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
function IngameTeamItemUI:OnShow()
  IngameTeamItemUI.__super.OnShow(self)
  if UIManager.UI_Config_InGame.BattleFlagTeamArmorUI then
    print(bWriteLog and "[GodTrial]IngameTeamItemUI:OnShow", self.UIRoot.GridPanel_2)
    self.BattleFlagTeamArmorUI = self:CreateChildWindow(self.UIRoot.GridPanel_2, UIManager.UI_Config_InGame.BattleFlagTeamArmorUI)
    if not self.BattleFlagTeamArmorUI then
      print(bWriteLog and "[GodTrial]IngameTeamItemUI:OnShow BattleFlagTeamArmorUI is nil")
    end
  end
end
function IngameTeamItemUI:OnHide()
  if self.BattleFlagTeamArmorUI then
    self.BattleFlagTeamArmorUI:Close()
    self.BattleFlagTeamArmorUI = nil
  end
  IngameTeamItemUI.__super.OnHide(self)
end
function IngameTeamItemUI:InitTeamItem()
  IngameTeamItemUI.__super.InitTeamItem(self)
  local IsSingleMode = CGameState and CGameState.PlayerNumPerTeam and CGameState.PlayerNumPerTeam <= 1
  if IsSingleMode then
    print(bWriteLog and "[GodTrial]IngameTeamItemUI:InitTeamItem Single mode")
    return
  end
  self:ResetRegistEvents()
  print(bWriteLog and "[GodTrial]IngameTeamItemUI:InitTeamItem" .. tostring(self.uPlayerState.PlayerKey))
end
function IngameTeamItemUI:ResetRegistEvents()
  if not slua.isValid(self.uPlayerState) or not self.uPlayerState.MercenaryFeature then
    print(bWriteLog and "[GodTrial]IngameTeamItemUI:ResetRegistEvents return")
    return
  end
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    print(bWriteLog and "[GodTrial]IngameTeamItemUI:ResetRegistEvents not slua.isValid(uPlayerController)")
    return
  end
  self:RemoveCacheDataListener()
  if uPlayerController:IsObserver() then
    print(bWriteLog and "[GodTrial]IngameTeamItemUI:ResetRegistEvents IsObserver, uPlayerController.PlayerKey=" .. tostring(uPlayerController.PlayerKey))
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI)
    return
  end
  local MercenaryFeatureSuperData = self.uPlayerState.MercenaryFeature:GetSuperData()
  if MercenaryFeatureSuperData then
    self:AddDataListener(MercenaryFeatureSuperData, "bShowMercenaryUI", self.OnShowMercenaryUIChanged, self)
    self.uCache  end
  print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:ResetRegistEvents self.uPlayerState.PlayerKey=%s, uPlayerController.PlayerKey=%s", tostring(self.uPlayerState.PlayerKey), tostring(uPlayerController.PlayerKey)))
end
function IngameTeamItemUI:RemoveCacheDataListener()
  if self.uCacheMercenaryFeatureSuperData then
    self:RemoveDataListener(self.uCacheMercenaryFeatureSuperData, "bShowMercenaryUI")
    self.uCacheMercenaryFeatureSuperData = nil
  end
end
function IngameTeamItemUI:OnShowMercenaryUIChanged(_, bShowMercenaryUI)
  if not slua.isValid(self.uPlayerState) or not self.uPlayerState.MercenaryFeature then
    return
  end
  print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged,bShowMercenaryUI=%s, PlayerKey=%s", tostring(bShowMercenaryUI), tostring(self.uPlayerState.PlayerKey)))
  if not UIManager.UI_Config_InGame.IngameMercenaryItemUI then
    return
  end
  if bShowMercenaryUI then
    local MercenaryFeatureSuperData = self.uPlayerState.MercenaryFeature:GetSuperData()
    if not MercenaryFeatureSuperData or not MercenaryFeatureSuperData.MercenaryPSData then
      print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged, not MercenaryFeatureSuperData  or not MercenaryFeatureSuperData.MercenaryPSData"))
      return
    end
    local uMercenaryPlayerState = MercenaryFeatureSuperData.MercenaryPSData
    if not slua.isValid(uMercenaryPlayerState) then
      print(bWriteLog and "[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged not uMercenaryPlayerState", uMercenaryPlayerState)
      return
    end
    local MercenaryItemUI = UIManager.GetUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI)
    if MercenaryItemUI then
      print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged, UpdateMercenaryAndMaster, PlayerKey=%s", tostring(self.uPlayerState.PlayerKey)))
      MercenaryItemUI:UpdateMercenaryAndMaster(self.uPlayerState.Object, uMercenaryPlayerState)
    end
    print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged, Show UI, PlayerKey=%s", tostring(self.uPlayerState.PlayerKey)))
    UIManager.ShowUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI, self.uPlayerState, uMercenaryPlayerState)
  elseif not self:CheckTeamMercenaryPlayerStateShow() then
    print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged, Hide UI, PlayerKey=%s", tostring(self.uPlayerState.PlayerKey)))
    UIManager.HideUI(UIManager.UI_Config_InGame.IngameMercenaryItemUI)
  else
    print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:OnShowMercenaryUIChanged, CheckTeamMercenaryPlayerStateShow=true, return, PlayerKey=%s", tostring(self.uPlayerState.PlayerKey)))
  end
end
function IngameTeamItemUI:CheckTeamMercenaryPlayerStateShow()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    local uPlayerState = uPlayerController.PlayerState
    if slua.isValid(uPlayerState) and uPlayerState.GetTeamMatePlayerStateList then
      local TeamMatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false)
      if TeamMatePlayerStateList and TeamMatePlayerStateList:Num() > 0 then
        for nIndex, uTeammatePlayerState in pairs(TeamMatePlayerStateList) do
          if slua.isValid(uTeammatePlayerState) and uTeammatePlayerState.MercenaryFeature and uTeammatePlayerState.MercenaryFeature:IsValidMercenaryPS() then
            print(bWriteLog and string.format("[GodTrial]IngameTeamItemUI:CheckTeamMercenaryPlayerStateShow,IsValidMercenaryPS, uTeammatePlayerState.PlayerKey=%s, uPlayerController.PlayerKey=%s", tostring(uTeammatePlayerState.PlayerKey), tostring(uPlayerController.PlayerKey)))
            return true
          end
        end
      end
    end
  end
  return false
end
local class = require("class")
local ui_base = require("GameLua.Mod.BRMod.Client.IngameTeamPanel.IngameTeamItem_UI_New")
return class(ui_base, nil, IngameTeamItemUI)