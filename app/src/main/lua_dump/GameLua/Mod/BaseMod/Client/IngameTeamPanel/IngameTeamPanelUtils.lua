local IngameTeamPanel = require("GameLua.Mod.BaseMod.Client.IngameTeamPanel.IngameTeamPanelConfig")
local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local uEGameModeType = import("EGameModeType")
function IngameTeamPanel:GetUIRoot()
  return self.UIRoot
end
function IngameTeamPanel:GetTeamItemList()
  return self.TeamItemList
end
function IngameTeamPanel:GetPositionItemList()
  return self.TeammatePosItemList
end
function IngameTeamPanel:CheckNeedCreateItems()
  local bNeedCreateItem = true
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) and uGameState.GameModeType == uEGameModeType.EWarGameMode then
    self.UIRoot.FollowBtn_WarControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    self.UIRoot.FollowPanel_WarControl:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    if uGameState.PlayerNumPerTeam <= 1 then
      bNeedCreateItem = false
    end
  end
  return bNeedCreateItem
end
function IngameTeamPanel:GetValidTeammateStateNum()
  local nCount = 0
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) and slua.isValid(uPlayerController.PlayerState) then
    local uPlayerState = uPlayerController.PlayerState
    if not uPlayerState.GetTeamMatePlayerStateList then
      return 0
    end
    local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false) or {}
    for _, TeammatePlayerState in pairs(TeammatePlayerStateList) do
      if slua.isValid(TeammatePlayerState) then
        nCount = nCount + 1
      end
    end
  end
  print(bWriteLog and "TeamPanel_Debug_Msg: GetValidTeammateStateNum = " .. nCount)
  return nCount
end
function IngameTeamPanel:GetSelfUID()
  return DataMgr and DataMgr.roleData and tonumber(DataMgr.roleData.uid) or nil
end
function IngameTeamPanel:IsSelfInTeamMateList()
  local SelfUID = self:GetSelfUID()
  if not SelfUID then
    return false
  end
  local uPlayerState = self.uLocalOwnerPlayerstate
  if not slua.isValid(uPlayerState) then
    local uPlayerController = GameplayData.GetPlayerController()
    if slua.isValid(uPlayerController) then
      uPlayerState = uPlayerController.GetCurPlayerState and uPlayerController:GetCurPlayerState() or uPlayerController.PlayerState
    end
  end
  if not slua.isValid(uPlayerState) then
    return false
  end
  if not uPlayerState.GetTeamMatePlayerStateList then
    return false
  end
  local TeammatePlayerStateList = uPlayerState:GetTeamMatePlayerStateList({}, false) or {}
  for _, ps in pairs(TeammatePlayerStateList) do
    if slua.isValid(ps) and tonumber(ps.UID) == SelfUID then
      return true
    end
  end
  return false
end
function IngameTeamPanel:IsInfectMode()
  if self.bCalledInfectMode then
    return self.bInfectMode
  else
    local uGameState = GameplayData.GetGameState()
    if slua.isValid(uGameState) then
      local bIsInfectGameMode = uGameState.GameModeType == uEGameModeType.EPVEInfectionGameMode
      self.bInfectMode = bIsInfectGameMode
      self.bCalledInfectMode = true
      if bIsInfectGameMode then
        return true
      end
    end
  end
  return false
end
function IngameTeamPanel:GetMaxAliasInfoNum()
  local uPlayerController = GameplayData.GetPlayerController()
  if slua.isValid(uPlayerController) then
    return uPlayerController.iPlayerAliasInfoCount
  else
    return 10
  end
end
function IngameTeamPanel:GetTableLength(table)
  if not table then
    return
  end
  local nLen = 0
  for _, Item in pairs(table) do
    if Item then
      nLen = nLen + 1
    end
  end
  return nLen
end
function IngameTeamPanel:IsNeedUpdatePFList()
  local uGameState = GameplayData.GetGameState()
  if slua.isValid(uGameState) then
    local eGameModeType = uGameState.GameModeType
    if eGameModeType == uEGameModeType.EWarGameMode then
      return false
    end
  end
  return true
end
function IngameTeamPanel:CheckTeamPanelDisplay()
  if Client.IsEditor() then
    self:ShowTeamInfo(true)
    return false
  else
    local uGameState = GameplayData.GetGameState()
    local bPassCheck
    if slua.isValid(uGameState) then
      local BTModeType = CDataTable.GetTableData("BTMode", uGameState.GameModeID)
      if BTModeType then
        bPassCheck = BTModeType.MaxTeamMember > 1
      end
    else
      bPassCheck = false
    end
    self:ShowTeamInfo(bPassCheck)
    return bPassCheck
  end
end
function IngameTeamPanel:CheckIsInBattleResult()
  local bInBattleResult = false
  local BattleResultSubSystem = SubsystemMgr:Get("BattleResultSubSystem")
  if BattleResultSubSystem then
    bInBattleResult = BattleResultSubSystem:InResultProcess() and not BattleResultSubSystem.ResultProcessSuspended
  end
  print(bWriteLog and "IngameTeamPanel:CheckIsInBattleResult", bInBattleResult)
  return bInBattleResult
end
function IngameTeamPanel:__AddStateIconByUIPath(sUIPath, sTag, sPosition)
  print(bWriteLog and "TeamPanel_Debug_Msg: AttachIconsOnTeamItems On " .. sPosition .. " Tag = " .. sTag)
  local TeamItemList = self.TeamItemList or {}
  if sPosition == "Left" then
    self.CustomStatusMapLeft[#self.CustomStatusMapLeft + 1] = {UIPath = sUIPath, Tag = sTag}
    for _, TeamItem in pairs(TeamItemList) do
      if TeamItem then
        TeamItem:AddPreCustomStatusMarkByUIPath(sUIPath, sTag)
      end
    end
  elseif sPosition == "Right" then
    self.CustomStatusMapRight[#self.CustomStatusMapRight + 1] = {UIPath = sUIPath, Tag = sTag}
    for _, TeamItem in pairs(TeamItemList) do
      if TeamItem then
        TeamItem:AddCustomStatusMarkByUIPath(sUIPath, sTag)
      end
    end
  end
end
function IngameTeamPanel:_ReCreateDynamicStateIcons()
  print(bWriteLog and "TeamPanel_Debug_Msg: _ReCreateDynamicStateIcons()")
  local CustomStatusMapRight = self.CustomStatusMapRight or {}
  local CustomStatusMapLeft = self.CustomStatusMapLeft or {}
  local TeamItemList = self.TeamItemList or {}
  for _, Value in pairs(CustomStatusMapRight) do
    for _, Item in pairs(TeamItemList) do
      if Item then
        Item:AddCustomStatusMarkByUIPath(Value.UIPath, Value.Tag)
        Item:InitAllDynamicStatusItem()
      end
    end
  end
  for _, Value in pairs(CustomStatusMapLeft) do
    for _, Item in pairs(TeamItemList) do
      if Item then
        Item:AddPreCustomStatusMarkByUIPath(Value.UIPath, Value.Tag)
        Item:InitAllDynamicStatusItem()
      end
    end
  end
end
function IngameTeamPanel:GetInTeamIndex(TeammatePlayerState)
  local uPlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(uPlayerController) then
    return 0
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) or not uPlayerState.GetPlayerInTeamIndexByPlayerState then
    return 0
  end
  return uPlayerState:GetPlayerInTeamIndexByPlayerState(TeammatePlayerState)
end