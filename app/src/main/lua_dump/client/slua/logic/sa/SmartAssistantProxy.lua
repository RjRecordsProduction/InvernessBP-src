local SmartAssistantProxy = {}
local SAUtils = require("client.slua.logic.sa.SAUtils")
function SmartAssistantProxy.TryShowSmartAssistant()
  local tvStatus = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MINI_TV)
  if not tvStatus then
    log(bWriteLog and "mini_logic: tvStatus" .. tostring(tvStatus))
    return
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and "mini_logic: is in xmission")
    return
  end
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if lobbyMainLogic.curPage == ENUM_LobbyPageType.Mid then
    SmartAssistantProxy.ShowSmartAssistant()
  end
end
function SmartAssistantProxy.ShowSmartAssistant(explicitShowType)
  local MiniTVActor = SmartAssistantProxy._Get_MiniTVActor()
  local EntranceUI = SmartAssistantProxy._Get_EntranceUI()
  local showType = explicitShowType or SAUtils.GetAssistantType()
  if not MiniTVActor or not slua.isValid(MiniTVActor) then
    MiniTVActor = SmartAssistantProxy._CreateMiniTVActor()
    SmartAssistantProxy._Set_MiniTVActor(MiniTVActor)
  end
  if showType == 3 then
    SmartAssistantProxy.UpdateMiniTvVisible()
  else
    if MiniTVActor and slua.isValid(MiniTVActor) then
      MiniTVActor:LogicHide()
    end
    EntranceUI = EntranceUI or SmartAssistantProxy._CreateEntranceUI()
    if EntranceUI then
      EntranceUI:SelfHitTestInvisible()
    else
      printf("SmartAssistantProxy.ShowSmartAssistant entranceUI is nil")
    end
  end
end
function SmartAssistantProxy._CreateMiniTVActor()
  local logic_mini_tv = require("client.slua.logic.mini_tv.logic_mini_tv")
  return logic_mini_tv.Create()
end
function SmartAssistantProxy._CreateEntranceUI()
  local uiConfig = UIManager.UI_Config.SmartAssistant_RobotTips_UIBP
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, true, "Border_SmartAssistant", uiConfig)
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local SmartAssistant_RobotTips_UIBP = lobbyMain:GetChildUI(uiConfig)
    return SmartAssistant_RobotTips_UIBP
  end
end
function SmartAssistantProxy._Get_MiniTVActor()
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  return LogicSmartAssistant.MiniTVActor
end
function SmartAssistantProxy._Set_MiniTVActor(obj)
  local LogicSmartAssistant = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.LogicSmartAssistant)
  LogicSmartAssistant.MiniTVActor = obj
end
function SmartAssistantProxy._Get_EntranceUI()
  local lobbyMain = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMain then
    local uiConfig = UIManager.UI_Config.SmartAssistant_RobotTips_UIBP
    return lobbyMain:GetChildUI(uiConfig)
  end
  return nil
end
function SmartAssistantProxy._Set_EntranceUI(obj)
end
function SmartAssistantProxy.HideSmartAssistant()
  local MiniTVActor = SmartAssistantProxy._Get_MiniTVActor()
  local EntranceUI = SmartAssistantProxy._Get_EntranceUI()
  if MiniTVActor and slua.isValid(MiniTVActor) then
    MiniTVActor:LogicHide()
    local logic_mini_tv = require("client.slua.logic.mini_tv.logic_mini_tv")
    logic_mini_tv.SaveActorData()
    SAUtils.CloseMiniTVBubbleUI()
  end
  if EntranceUI then
    EntranceUI:Hide()
  end
end
function SmartAssistantProxy.DestroySmartAssistant()
  SmartAssistantProxy._DestroyMiniTVActor()
  SmartAssistantProxy._DestroyEntranceUI()
end
function SmartAssistantProxy._DestroyMiniTVActor()
  local MiniTVActor = SmartAssistantProxy._Get_MiniTVActor()
  if MiniTVActor and slua.isValid(MiniTVActor) then
    MiniTVActor:K2_DestroyActor()
  end
  SmartAssistantProxy._Set_MiniTVActor(nil)
end
function SmartAssistantProxy._DestroyEntranceUI()
  local EntranceUI = SmartAssistantProxy._Get_EntranceUI()
  if EntranceUI then
    local uiConfig = UIManager.UI_Config.SmartAssistant_RobotTips_UIBP
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_SHOW_OR_HIDE_PANEL, false, "Border_SmartAssistant", uiConfig)
  end
end
function SmartAssistantProxy.UpdateMiniTvVisible()
  local MiniTVActor = SmartAssistantProxy._Get_MiniTVActor()
  if MiniTVActor and slua.isValid(MiniTVActor) then
    local showType = SAUtils.GetAssistantType()
    if showType == 2 then
      MiniTVActor:LogicHide()
      return
    end
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    local hideReason_teamNum = TeamUpNewSystem.GetTeamNum() > 1
    local logic_lobby = require("client.slua.logic.lobby.logic_lobby_main")
    local hideReason_lobby = logic_lobby.isCurrentShow == false
    local hideReason_xmission = require("client.slua.logic.TxMission.logic_xmission_main").IsInXMission()
    printf("SmartAssistantProxy.UpdateMiniTvVisible hideReason_teamNum: %s, hideReason_lobby: %s, hideReason_xmission: %s", hideReason_teamNum, hideReason_lobby, hideReason_xmission)
    if hideReason_teamNum or hideReason_lobby or hideReason_xmission then
      MiniTVActor:LogicHide()
    else
      MiniTVActor:LogicShow()
    end
  end
end
function SmartAssistantProxy.OnNoticeLevelChanged(level, msg)
  log(bWriteLog and "SmartAssistantProxy.OnNoticeLevelChanged level:" .. tostring(level) .. " msg:" .. tostring(msg))
  local MiniTVActor = SmartAssistantProxy._Get_MiniTVActor()
  if MiniTVActor and slua.isValid(MiniTVActor) then
    MiniTVActor:OnNoticeLevelChanged(level, msg)
  end
  local EntranceUI = SmartAssistantProxy._Get_EntranceUI()
  if EntranceUI and not EntranceUI:IsAsyncLoading() and EntranceUI:GetVisibility() ~= UEnums.ESlateVisibility.Collapsed then
    EntranceUI:OnNoticeLevelChanged(level, msg)
  end
  local lobbyMainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if lobbyMainUI then
    local ui = lobbyMainUI:GetChildUI(UIManager.UI_Config.Lobby_Mid_Match_Center_Entry_UIBP)
    if ui then
      ui:AdjustTVPosBySmartAssistant()
      return
    end
  end
end
function SmartAssistantProxy.OnSettingSwitchTypeChanged(nowType)
  if nowType == 2 then
    local MiniTVActor = SmartAssistantProxy._Get_MiniTVActor()
    if MiniTVActor and slua.isValid(MiniTVActor) then
      MiniTVActor:LogicHide()
    end
  elseif nowType == 3 then
    SmartAssistantProxy._DestroyEntranceUI()
  end
  SmartAssistantProxy.ShowSmartAssistant(nowType)
end
return SmartAssistantProxy