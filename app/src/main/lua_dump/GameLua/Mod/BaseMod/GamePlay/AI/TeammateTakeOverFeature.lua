local TeammateTakeOverFeature = {
  ServerRPC = {},
  ClientRPC = {}
}
local TeammateTakeOverConfig = require("GameLua.Mod.BaseMod.GamePlay.AI.TeammateTakeOverConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
TeammateTakeOverFeature.ClientRPC.RPC_Client_RequestTeammateTakeOver = {
  Reliable = true,
  Params = {}
}
TeammateTakeOverFeature.ServerRPC.RPC_Server_ResponseTeammateTakeOver = {
  Reliable = true,
  Params = {
    UEnums.EPropertyClass.Bool,
    UEnums.EPropertyClass.Bool
  }
}
function TeammateTakeOverFeature:_PostConstruct()
  local uSTExtraDelegateMgr = import("STExtraDelegateMgr")
  self:AddCommonEvent(EVENTTYPE_INGAME_TEAMMATE_PANEL, EVENTID_TEAMMATE_ON_TEAMMATE_ITEM_INIT, self.OnTeammateItemInit, self)
end
function TeammateTakeOverFeature:ctor()
  self.bAITakeOver = false
  self.bOpenTeammateTakeOver = false
  self.nMasterIndex = -1
end
function TeammateTakeOverFeature:ReceiveBeginPlay()
  if slua.isValid(self.Owner.Object) then
    self.Owner.Object.nMasterIndex = self.nMasterIndex
  end
  print(bWriteLog and "TeammateTakeOverFeature:ReceiveBeginPlay")
end
function TeammateTakeOverFeature:ReceiveEndPlay()
  if self.GuideTimer then
    Game:ClearTimer(self.GuideTimer)
    self.GuideTimer = nil
  end
end
function TeammateTakeOverFeature:GetLifetimeReplicatedProps()
  local ELifetimeCondition = import("ELifetimeCondition")
  return {
    {
      "bAITakeOver",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Bool
    },
    {
      "bOpenTeammateTakeOver",
      ELifetimeCondition.COND_OwnerOnly,
      UEnums.EPropertyClass.Bool
    },
    {
      "nMasterIndex",
      ELifetimeCondition.COND_None,
      UEnums.EPropertyClass.Int
    }
  }
end
function TeammateTakeOverFeature:RPC_Client_RequestTeammateTakeOver()
  if Client then
    if Client.IsEditor() then
      self:RPC_Server_ResponseTeammateTakeOver(true, true)
      return
    end
    local SettingSubsystem = SubsystemMgr:Get("SettingSubsystem")
    if SettingSubsystem then
      local bTeammateTakeOverSetting = SettingSubsystem:GetUserSettings_Bool("TeammateTakeOver")
      if bTeammateTakeOverSetting == true then
        if UIManager.UI_Config_InGame.AITakeOverConfirmUI then
          UIManager.ShowUI(UIManager.UI_Config_InGame.AITakeOverConfirmUI)
        end
      else
        self:RPC_Server_ResponseTeammateTakeOver(false, false)
      end
    end
  end
end
function TeammateTakeOverFeature:RPC_Server_ResponseTeammateTakeOver(bEnable, bOpenSwitch)
  if Client then
    return
  end
  if self.bHasResponse == nil or self.bHasResponse == true then
    return
  end
  self.bHasResponse = true
  local uPlayerState = self.Owner.Object
  if slua.isValid(uPlayerState) then
    local TeammateTakeOverSubsystem = SubsystemMgr:Get("TeammateTakeOverSubsystem")
    if TeammateTakeOverSubsystem then
      TeammateTakeOverSubsystem:ResponseTeammateTakeOver(uPlayerState.PlayerKey, uPlayerState.TeamID, bEnable, bOpenSwitch)
    end
  else
    print(bWriteLog and "TeammateTakeOverFeature:RPC_Server_ResponseTeammateTakeOver uPlayerState is invalid")
  end
end
function TeammateTakeOverFeature:OnRep_bAITakeOver(OldValue)
  if self.Owner:HasAuthority() then
    return
  end
  print(bWriteLog and string.format("TeammateTakeOverFeature:OnRep_bAITakeOver %s %s", tostring(OldValue), tostring(self.bAITakeOver)))
  if UIManager.UI_Config_InGame.TeamPanel then
    local TeamPanel = UIManager.GetUI(UIManager.UI_Config_InGame.TeamPanel)
    if TeamPanel then
      print(bWriteLog and "TeammateTakeOverFeature:OnRep_bAITakeOver TeamPanel")
      if TeamPanel.OnAITakeOverStateChange and self.bAITakeOver == true then
        TeamPanel:OnAITakeOverStateChange(self.Owner.Object, true, self.nMasterIndex)
        IngameTipsTools.BattleNormalTipsByTextID(TeammateTakeOverConfig.TeammateAllocatedTips)
        if UIManager.UI_Config_InGame.AITakeOverConfirmUI then
          UIManager.CloseUI(UIManager.UI_Config_InGame.AITakeOverConfirmUI)
        end
      elseif TeamPanel.OnAITakeOverStateChange and self.bAITakeOver == false and OldValue == true then
        TeamPanel:OnAITakeOverStateChange(self.Owner.Object, false, self.nMasterIndex)
      end
    end
  end
end
function TeammateTakeOverFeature:OnRep_nMasterIndex(OldValue)
  if self.Owner:HasAuthority() then
    return
  end
  if not Client then
    return
  end
  print(bWriteLog and string.format("TeammateTakeOverFeature:OnRep_nMasterIndex %s %s", tostring(OldValue), tostring(self.nMasterIndex)))
  local ui_manager = require("client.slua_ui_framework.manager")
  if ui_manager.UI_Config_InGame.TeamPanel then
    local TeamPanel = ui_manager.GetUI(ui_manager.UI_Config_InGame.TeamPanel)
    if TeamPanel then
      print(bWriteLog and "TeammateTakeOverFeature:OnRep_nMasterIndex TeamPanel")
      if TeamPanel.OnAITakeOverStateChange and self.bAITakeOver == true then
        TeamPanel:OnAITakeOverStateChange(self.Owner.Object, true, self.nMasterIndex)
        self.Owner.Object.nMasterIndex = self.nMasterIndex
      end
    end
  end
end
function TeammateTakeOverFeature:OnRep_bOpenTeammateTakeOver(OldValue)
  if self.Owner:HasAuthority() then
    return
  end
  print(bWriteLog and string.format("TeammateTakeOverFeature:OnRep_bOpenTeammateTakeOver %s %s", tostring(OldValue), tostring(self.bOpenTeammateTakeOver)))
  if self.bOpenTeammateTakeOver == true and self.GuideTimer == nil then
    self.GuideTimer = self:AddGameTimer(1, true, function()
      if slua.isValid(CGameState) and CGameState.GetGameModeState then
        local GameModeState = CGameState:GetGameModeState()
        if GameModeState == "ReadyState" or GameModeState == "ActiveState" then
          EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_GUIDE_TAKEOVER_TEAMMATE)
          return
        end
        Game:ClearTimer(self.GuideTimer)
        self.GuideTimer = nil
      end
    end)
    self:AddCommonEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_SHOW_TAKEOVER_TEAMMATE_UI, self.ShowGuideUI, self)
    print(bWriteLog and "TeammateTakeOverFeature:OnRep_bOpenTeammateTakeOver")
  end
end
function TeammateTakeOverFeature:ShowGuideUI(_, __)
  UIManager.ShowUI(UIManager.UI_Config.AITakeOverGuideUI)
  self:AddGameTimer(TeammateTakeOverConfig.GuideUIShowTime, false, function()
    UIManager.CloseUI(UIManager.UI_Config.AITakeOverGuideUI)
  end)
end
function TeammateTakeOverFeature:OnTeammateTakeOver(bTakeOver, bAbnormal, bHasSendBattleResult)
  if self.bAITakeOver == bTakeOver then
    return
  end
  self.bAITakeOver = bTakeOver
  local uPlayerState = self.Owner.Object
  if slua.isValid(uPlayerState) then
    if bTakeOver == false then
      if bHasSendBattleResult == false then
        local DestroyAllocatedTipsID = TeammateTakeOverConfig.TeammateDestroyAllocatedTips
        if bAbnormal then
          DestroyAllocatedTipsID = TeammateTakeOverConfig.TeammateExceptionTips
        end
        print(bWriteLog and string.format("TeammateTakeOverFeature:OnTeammateTakeOver %s %s %s", tostring(bTakeOver), tostring(bAbnormal), tostring(DestroyAllocatedTipsID)))
        local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, true)
        if TeammatePlayerStateList and DestroyAllocatedTipsID then
          for _, uTeammatePlayerState in pairs(TeammatePlayerStateList) do
            if slua.isValid(uTeammatePlayerState) then
              Game:UIShowTips(uTeammatePlayerState.PlayerKey, DestroyAllocatedTipsID)
            end
          end
        end
      end
      self:SetAllyMasterIndex(-1)
    elseif bTakeOver == true then
      local uPlayerController = uPlayerState:GetOwner()
      if slua.isValid(uPlayerController) then
        uPlayerController:SendStringMsg("", TeammateTakeOverConfig.GreetingTextID, 0, "0", 0, 0, true)
      end
    end
    uPlayerState.isLostConnection = not bTakeOver
  else
    print(bWriteLog and "TeammateTakeOverFeature:OnTeammateTakeOver uPlayerState is invalid")
  end
end
function TeammateTakeOverFeature:SetAllyMasterIndex(nMasterIndex)
  self.  print(bWriteLog and string.format("TeammateTakeOverFeature:SetAllyMasterIndex %s", tostring(nMasterIndex)))
end
function TeammateTakeOverFeature:OnTeammateItemInit(_, __, TeamItemUI, uPlayerState)
  if not slua.isValid(uPlayerState) then
    return
  end
  if uPlayerState == self.Owner.Object then
    local ui_manager = require("client.slua_ui_framework.manager")
    if ui_manager.UI_Config_InGame.TeamPanel then
      local TeamPanel = ui_manager.GetUI(ui_manager.UI_Config_InGame.TeamPanel)
      if TeamPanel then
        print(bWriteLog and "TeammateTakeOverFeature:OnTeammateItemInit TeamPanel")
        if TeamPanel.OnAITakeOverStateChange and self.bAITakeOver == true then
          TeamPanel:OnAITakeOverStateChange(self.Owner.Object, true, self.nMasterIndex)
        end
      end
    end
  end
end
local class = require("class")
local CFeatureBase = require("GameLua.Mod.BaseMod.GamePlay.Feature.Common.FeatureBase")
local CTeammateTakeOverFeature = class(CFeatureBase, nil, TeammateTakeOverFeature)
return CTeammateTakeOverFeature