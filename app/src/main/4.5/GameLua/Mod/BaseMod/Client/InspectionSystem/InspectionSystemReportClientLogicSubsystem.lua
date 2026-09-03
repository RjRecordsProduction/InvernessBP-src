local InspectionSystemReportClientLogicSubsystem = {}
local ModeIDConfig = {
  "11003",
  "11006",
  "11066",
  "11069"
}
function InspectionSystemReportClientLogicSubsystem:OnInit()
  printf("InspectionSystemReportClientLogicSubsystem:OnInit")
  if not self.bHasRegist then
    self:AddCommonEvent(EVENTTYPE_INSPECTION, EVENTID_INSPECTION_ASKFORINSPECTOR, self.AskForInspector, self)
    self:AddCommonEvent(EVENTTYPE_INSPECTION, EVENTID_INSPECTION_REPORTENEMY, self.ReportEnemy, self)
    self:AddCommonEvent(EVENTTYPE_INSPECTION, EVENTID_INSPECTION_KICKOUTONETEAM, self.KickOutOneTeam, self)
    self.bHasRegist = true
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not Client then
    printf("InspectionSystemReportClientLogicSubsystem:OnInit uPlayerController or Client invalid")
    return
  end
  if uPlayerController:IsRoomMode() and not uPlayerController:IsObserver() then
    local CurGameModeID = Client.GetGameModeID(GameFrontendHUD)
    printf("InspectionSystemReportClientLogicSubsystem:OnInit CurGameModeID[%s]", CurGameModeID)
    if CurGameModeID then
      for k, v in pairs(ModeIDConfig) do
        if v == CurGameModeID then
          UIManager.ShowUI(UIManager.UI_Config_InGame.InspectionSystemReportButton)
          printf("InspectionSystemReportClientLogicSubsystem:OnInit show InspectionSystemReportButton")
          return
        end
      end
    end
  end
  printf("InspectionSystemReportClientLogicSubsystem:OnInit not desired gamemodeid")
end
function InspectionSystemReportClientLogicSubsystem:OnRelease()
  printf("InspectionSystemReportClientLogicSubsystem:OnRelease")
  self.bHasRegist = nil
  InspectionSystemReportClientLogicSubsystem.__super.OnRelease(self)
end
function InspectionSystemReportClientLogicSubsystem.RecvNotifyInspector(Message)
  printf("InspectionSystemReportClientLogicSubsystem:RecvNotifyInspector")
  local InspectionSystemReportClientLogicSubsystemInst = SubsystemMgr:Get("InspectionSystemReportClientLogicSubsystem")
  if InspectionSystemReportClientLogicSubsystemInst then
    InspectionSystemReportClientLogicSubsystemInst:ClientNotifyInspectorImplementation(Message.nPlayerKey, Message.nType, Message.nNum)
  end
end
function InspectionSystemReportClientLogicSubsystem:SendReportToInspector(InUID, InType)
  printf("InspectionSystemReportClientLogicSubsystem:SendReportToInspector uid[%d] type[%d]", InUID, InType)
  local Message = {nUID = InUID, nType = InType}
  local ds_net = require("ds_net")
  ds_net.SendMessage("inspection_system_report_to_inspector", Message)
end
function InspectionSystemReportClientLogicSubsystem:SendKickOutOneTeam(InPlayerKey)
  printf("InspectionSystemReportClientLogicSubsystem:SendKickOutOneTeam playerkey[%d]", InPlayerKey)
  local Message = {nPlayerKey = InPlayerKey}
  local ds_net = require("ds_net")
  ds_net.SendMessage("inspection_system_kick_out_one_team", Message)
end
function InspectionSystemReportClientLogicSubsystem:AskForInspector(_, __)
  printf("InspectionSystemReportClientLogicSubsystem:AskForInspector")
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) then
    printf("InspectionSystemReportClientLogicSubsystem:AskForInspector uPlayerController invalid")
    return
  end
  local uPlayerState = uPlayerController.PlayerState
  if not slua.isValid(uPlayerState) then
    printf("InspectionSystemReportClientLogicSubsystem:AskForInspector uPlayerState invalid")
  end
  self:SendReportToInspector(uPlayerState.UID, UEnums.EReportToInspectorType.AskForInspector)
end
function InspectionSystemReportClientLogicSubsystem:ReportEnemy(_, __, nEnemyUID)
  printf("InspectionSystemReportClientLogicSubsystem:ReportEnemy nEnemyUID[%d]", nEnemyUID)
  local nUID = tonumber(nEnemyUID)
  if nUID then
    self:SendReportToInspector(nUID, UEnums.EReportToInspectorType.ReportPlayer)
  end
end
function InspectionSystemReportClientLogicSubsystem:KickOutOneTeam(_, __, sInPlayerKey)
  printf("InspectionSystemReportClientLogicSubsystem:KickOutOneTeam sInPlayerKey[%s]", sInPlayerKey)
  local nPlayerKey = tonumber(sInPlayerKey)
  if nPlayerKey then
    self:SendKickOutOneTeam(nPlayerKey)
  end
end
function InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation(nTargetPlayerKey, nReportToInspectorType, nReportNum)
  printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation nTargetPlayerKey[%d] nReportToInspectorType[%d]", nTargetPlayerKey, nReportToInspectorType)
  if not Client then
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation not client")
    return
  end
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if not slua.isValid(uPlayerController) or not slua.isValid(uPlayerController.PlayerState) then
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation uPlayerController or player state invalid")
    return
  end
  if not uPlayerController:IsObserver() then
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation not observer")
    return
  end
  if not uPlayerController.PlayerState.GetPlayerStaticInfo then
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation no GetPlayerStaticInfo function")
    return
  end
  local PlayerStaticInfo = uPlayerController.PlayerState:GetPlayerStaticInfo(nTargetPlayerKey)
  if not slua.isValid(PlayerStaticInfo) then
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation PlayerStaticInfo invalid")
    return
  end
  if nReportToInspectorType == UEnums.EReportToInspectorType.ReportPlayer then
    local uAllStarReportInfo = uPlayerController:GetAllStarReportDataByOpenID(PlayerStaticInfo.PlayerOpenID)
    if uAllStarReportInfo then
      uAllStarReportInfo.BeReportedNum = nReportNum
      uPlayerController:SetAllStarReportDataByOpenID(PlayerStaticInfo.PlayerOpenID, uAllStarReportInfo)
    end
    EventSystem:postEvent(EVENTTYPE_INSPECTION, EVENTID_INSPECTION_REFRESHLIST)
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation postEvent EVENTID_INSPECTION_REFRESHLIST")
  elseif nReportToInspectorType == UEnums.EReportToInspectorType.AskForInspector then
    local uAllStarReportInfo = uPlayerController:GetAllStarReportDataByOpenID(PlayerStaticInfo.PlayerOpenID)
    if uAllStarReportInfo then
      uAllStarReportInfo.bShowReportFlag = true
      uPlayerController:SetAllStarReportDataByOpenID(PlayerStaticInfo.PlayerOpenID, uAllStarReportInfo)
    end
    EventSystem:postEvent(EVENTTYPE_INSPECTION, EVENTID_INSPECTION_REFRESHLIST)
    printf("InspectionSystemReportClientLogicSubsystem:ClientNotifyInspectorImplementation postEvent EVENTID_INSPECTION_REFRESHLIST")
  end
end
local class = require("class")
local SubSystemBase = require("GameLua.GameCore.Module.Subsystem.SubsystemBase")
return class(SubSystemBase, nil, InspectionSystemReportClientLogicSubsystem)