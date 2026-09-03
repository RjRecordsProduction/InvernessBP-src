local Lobby_Main_Control = {}
local ANI_CONFIGS = {
  [1] = {
    offsetAni = {
      name = "Anim_Offset_UI_SocialToLobby",
      forward = true
    },
    blurAni = {
      name = "Anim_Offset_Blur_SocialToLobby",
      forward = true
    }
  },
  [2] = {
    offsetAni = {
      name = "Anim_Offset_UI_LobbyToMode",
      forward = true
    },
    blurAni = {
      name = "Anim_Offset_Blur_LobbyToMode",
      forward = true
    }
  },
  [10] = {
    offsetAni = {
      name = "Anim_Offset_UI_LobbyToSocial",
      forward = true
    },
    blurAni = {
      name = "Anim_Offset_Blur_SocialToLobby",
      forward = false
    }
  },
  [12] = {
    offsetAni = {
      name = "Anim_Offset_UI_LobbyToMode",
      forward = true
    },
    blurAni = {
      name = "Anim_Offset_Blur_LobbyToMode",
      forward = true
    }
  },
  [20] = {
    offsetAni = {
      name = "Anim_Offset_UI_ModeToSocial",
      forward = true
    },
    blurAni = {
      name = "Anim_Offset_Blur_LobbyToMode",
      forward = false
    }
  },
  [21] = {
    offsetAni = {
      name = "Anim_Offset_UI_ModeToLobby",
      forward = true
    },
    blurAni = {
      name = "Anim_Offset_Blur_LobbyToMode",
      forward = false
    }
  }
}
local ALL_ANI_NAMES = {}
for _, v in pairs(ANI_CONFIGS) do
  local offsetAniName = v.offsetAni.name
  local blurAniName = v.blurAni.name
  ALL_ANI_NAMES[offsetAniName] = true
  ALL_ANI_NAMES[blurAniName] = true
end
function Lobby_Main_Control.Init()
  log(bWriteLog and "Lobby_Main_Control.Init")
  Lobby_Main_Control.bAni = false
  Lobby_Main_Control.lockPageTime = 5
  Lobby_Main_Control.curPage = ENUM_LobbyPageType.Mid
  log(bWriteLog and "Lobby_Main_Control.Init. curPage = " .. tostring(Lobby_Main_Control.curPage))
  Lobby_Main_Control.fromPage = 1
  Lobby_Main_Control.toPage = 1
  Lobby_Main_Control.nextPage = nil
  Lobby_Main_Control.bFirstAni = true
  Lobby_Main_Control.ReturnFromTLobbyToPage = nil
  Lobby_Main_Control.ignoreAniCallback = false
  Lobby_Main_Control.ComputeCameraInfo_Once()
  local logic_lobby_main_gyroscope = require("client.slua.logic.lobby.Main.logic_lobby_main_gyroscope")
  logic_lobby_main_gyroscope.Init()
end
function Lobby_Main_Control.Destroy()
  log(bWriteLog and "Lobby_Main_Control.Destroy")
  local logic_lobby_main_gyroscope = require("client.slua.logic.lobby.Main.logic_lobby_main_gyroscope")
  logic_lobby_main_gyroscope.Destroy()
end
function Lobby_Main_Control.GetBAniData()
  return Lobby_Main_Control.bAni
end
function Lobby_Main_Control.GetCurPage()
  return Lobby_Main_Control.curPage
end
function Lobby_Main_Control.ComputeCameraInfo_Once()
  log(bWriteLog and "Lobby_Main_Control.ComputeCameraInfo_Once")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_Main_Control.cameraIdList = {
    10151,
    10152,
    10153,
    10001,
    10002,
    10154
  }
  Lobby_Main_Control.cameraPosList = {}
  for i = 1, #Lobby_Main_Control.cameraIdList do
    local cfg = Lobby_camera_manager_module:GetLobbyCameraLocationByCameraID(Lobby_Main_Control.cameraIdList[i])
    if cfg and next(cfg) then
      Lobby_Main_Control.cameraPosList[i] = cfg
    end
  end
  Lobby_Main_Control.ComputePosList()
  Lobby_Main_Control.ComputeVelocityList()
end
function Lobby_Main_Control.ComputePosList()
  log(bWriteLog and "Lobby_Main_Control.ComputePosList")
  local logic_team_up = require("client.slua.logic.teamup.logic_team_up")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not ui then
    log(bWriteLog and "Lobby_Main_Control.ComputePosList no ui")
    return
  end
  local bHasTeam = logic_team_up.IsInTeam()
  local posList = ui.UIRoot.Lobby20_Control_Comp.PosList
  posList:Clear()
  posList:Add(FVector(Lobby_Main_Control.cameraPosList[1][1], Lobby_Main_Control.cameraPosList[1][2], Lobby_Main_Control.cameraPosList[1][3]))
  posList:Add(FVector(Lobby_Main_Control.cameraPosList[2][1], Lobby_Main_Control.cameraPosList[2][2], Lobby_Main_Control.cameraPosList[2][3]))
  posList:Add(FVector(Lobby_Main_Control.cameraPosList[3][1], Lobby_Main_Control.cameraPosList[3][2], Lobby_Main_Control.cameraPosList[3][3]))
  if not bHasTeam then
    log(bWriteLog and "Lobby_Main_Control.ComputePosList not has team")
    posList:Add(FVector(Lobby_Main_Control.cameraPosList[4][1], Lobby_Main_Control.cameraPosList[4][2], Lobby_Main_Control.cameraPosList[4][3]))
    ui.UIRoot.Lobby20_Control_Comp.bHasTeam = false
  else
    log(bWriteLog and "Lobby_Main_Control.ComputePosList has team")
    posList:Add(FVector(Lobby_Main_Control.cameraPosList[5][1], Lobby_Main_Control.cameraPosList[5][2], Lobby_Main_Control.cameraPosList[5][3]))
    ui.UIRoot.Lobby20_Control_Comp.bHasTeam = true
  end
  posList:Add(FVector(Lobby_Main_Control.cameraPosList[6][1], Lobby_Main_Control.cameraPosList[6][2], Lobby_Main_Control.cameraPosList[6][3]))
end
function Lobby_Main_Control.ComputeVelocityList()
  log(bWriteLog and "Lobby_Main_Control.ComputeVelocityList")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not ui then
    log(bWriteLog and "Lobby_Main_Control.ComputeVelocityList no ui")
    return
  end
  local xSpeedList = {
    200,
    750,
    -650,
    -530,
    200,
    -200
  }
  local posList = ui.UIRoot.Lobby20_Control_Comp.PosList
  local sides = {
    posList:Get(0),
    posList:Get(1),
    posList:Get(2),
    posList:Get(3),
    posList:Get(4)
  }
  Lobby_Main_Control.moveTime = {
    (sides[2].X - sides[1].X) / xSpeedList[1],
    (sides[4].X - sides[3].X) / xSpeedList[2],
    (sides[3].X - sides[4].X) / xSpeedList[3],
    (sides[1].X - sides[2].X) / xSpeedList[4],
    (sides[5].X - sides[4].X) / xSpeedList[5],
    (sides[4].X - sides[5].X) / xSpeedList[6]
  }
  local KismetMathLibrary = import("KismetMathLibrary")
  local veloList = ui.UIRoot.Lobby20_Control_Comp.VelocityList
  veloList:Clear()
  veloList:Add(KismetMathLibrary.Divide_VectorFloat(KismetMathLibrary.Subtract_VectorVector(sides[2], sides[1]), Lobby_Main_Control.moveTime[1]))
  veloList:Add(KismetMathLibrary.Divide_VectorFloat(KismetMathLibrary.Subtract_VectorVector(sides[4], sides[3]), Lobby_Main_Control.moveTime[2]))
  veloList:Add(KismetMathLibrary.Divide_VectorFloat(KismetMathLibrary.Subtract_VectorVector(sides[3], sides[4]), Lobby_Main_Control.moveTime[3]))
  veloList:Add(KismetMathLibrary.Divide_VectorFloat(KismetMathLibrary.Subtract_VectorVector(sides[1], sides[2]), Lobby_Main_Control.moveTime[4]))
  veloList:Add(KismetMathLibrary.Divide_VectorFloat(KismetMathLibrary.Subtract_VectorVector(sides[5], sides[4]), Lobby_Main_Control.moveTime[5]))
  veloList:Add(KismetMathLibrary.Divide_VectorFloat(KismetMathLibrary.Subtract_VectorVector(sides[4], sides[5]), Lobby_Main_Control.moveTime[6]))
end
function Lobby_Main_Control.ChangeToLeftCamera()
  log(bWriteLog and "Lobby_Main_Control.ChangeToLeftCamera")
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(10151)
end
function Lobby_Main_Control.PlayUIAnim(curPage, toPage)
  log_format("Lobby_Main_Control.PlayUIAnim curPage:%s, toPage:%s", curPage, toPage)
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not ui then
    return
  end
  Lobby_Main_Control.bFirstAni = false
  Lobby_Main_Control.ignoreAniCallback = true
  for animName, _ in pairs(ALL_ANI_NAMES) do
    ui:StopAnimation(animName)
  end
  Lobby_Main_Control.ignoreAniCallback = false
  Lobby_Main_Control.  local isJumpPage = false
  if math.abs(curPage - toPage) ~= 1 then
    isJumpPage = true
  end
  local aniFromPage = curPage
  local aniToPage = toPage
  if isJumpPage then
    if curPage == ENUM_LobbyPageType.Left then
      aniToPage = ENUM_LobbyPageType.Mid
    else
      aniFromPage = ENUM_LobbyPageType.Mid
    end
  end
  log_format("Lobby_Main_Control.PlayUIAnim. isJumpPage = %s, aniFromPage = %s, aniToPage = %s", isJumpPage, aniFromPage, aniToPage)
  ui.Lobby20_Control_Comp:AniCamera(aniFromPage, aniToPage, false)
  local key = curPage * 10 + toPage
  local config = ANI_CONFIGS[key]
  if config then
    log_format("Lobby_Main_Control.PlayUIAnim. key = %s", key)
    ui:PlayAnimationSimple(config.offsetAni.name, config.offsetAni.forward)
    ui:PlayAnimationSimple(config.blurAni.name, config.blurAni.forward)
  end
  if toPage == ENUM_LobbyPageType.Right then
    local convience_mode_settings = DataMgr.roleData and DataMgr.roleData.convience_mode_settings
    if convience_mode_settings and convience_mode_settings.rightMode and convience_mode_settings.rightModeShowedRed == nil then
      convience_mode_settings.rightModeShowedRed = 1
      local DataMgrHandler = require("client.network.Protocol.DataMgrHandler")
      DataMgrHandler.send_save_convenient_mode_req(convience_mode_settings)
    end
    local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    local rightMode = logic_home_switch.lobbyRightMode
    log_format("Lobby_Main_Control.PlayUIAnim. rightMode = %s", rightMode)
    if rightMode == ENUM_LobbyRightMode.CustomMode then
      UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Custom_UIBP, false)
    elseif rightMode == ENUM_LobbyRightMode.XMission then
      UIManager.ShowUI(UIManager.UI_Config.ModeSelection_XMission_UIBP)
    elseif rightMode == ENUM_LobbyRightMode.WowMode then
      Lobby_Main_Control.curPage = ENUM_LobbyPageType.Right
      UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Wow_UIBP)
      ClientSendTLogReport(TLogEventDefine.RightScreenEnterWow, 0)
    elseif rightMode == ENUM_LobbyRightMode.None then
      UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Select_UIBP)
    elseif rightMode == ENUM_LobbyRightMode.UGCHall and logic_ugc_hall:CheckIsOpen() then
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      if not Config_UGC.IsUGCUnlock() then
        local ugcEntry = Config_UGC.GetEntryData()
        ShowNotice(LocUtil.LocalizeResFormat(31028, ugcEntry.level_limit))
        return
      end
      UIManager.ShowUI(UIManager.UI_Config.UGC_Hall_UIBP)
    end
  end
end
function Lobby_Main_Control.MoveToPage(toPage)
  log_format("Lobby_Main_Control.MoveToPage toPage = %s", toPage)
  if Lobby_Main_Control.curPage == toPage then
    return false
  end
  local Lobby_Main_City_Enter = require("client.slua.logic.lobby.MainCity.Lobby_Main_City_Enter")
  if Lobby_Main_City_Enter.bEnterMainCityLoading then
    log(bWriteLog and "Lobby_Main_Control.MoveToPage bEnterMainCityLoading")
    return false
  end
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXmission = LogicTxMissionMain.IsInXMission()
  if toPage == ENUM_LobbyPageType.Right then
    if not Lobby_Main_Control.HandleToRightScreenLogic() then
      return false
    end
  else
    local ModeSelection_Custom_UIBP = UIManager.GetUI(UIManager.UI_Config.ModeSelection_Custom_UIBP)
    if ModeSelection_Custom_UIBP and ModeSelection_Custom_UIBP:IsChangeSetting() then
      ModeSelection_Custom_UIBP:ShowMsgSaveMapMode(toPage)
      return false
    end
    UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Select_UIBP)
    local ModeSelection_Wow_UIBP = UIManager.GetUI(UIManager.UI_Config.ModeSelection_Wow_UIBP)
    if ModeSelection_Wow_UIBP then
      ModeSelection_Wow_UIBP:SetRealToPage(toPage)
    end
    local UGC_Hall_UIBP = UIManager.GetUI(UIManager.UI_Config.UGC_Hall_UIBP)
    if UGC_Hall_UIBP then
      UGC_Hall_UIBP:SetRealToPage(toPage)
    end
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimerOnce(0.3, function()
      UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Custom_UIBP)
      UIManager.CloseUI(UIManager.UI_Config.ModeSelection_XMission_UIBP)
      UIManager.CloseUI(UIManager.UI_Config.xmission_download)
      UIManager.CloseUI(UIManager.UI_Config.ModeSelection_Wow_UIBP)
      UIManager.CloseUI(UIManager.UI_Config.UGC_Hall_UIBP)
    end)
  end
  if toPage ~= ENUM_LobbyPageType.Right and isInXmission then
    Lobby_Main_Control.ReturnFromTLobbyToPage = toPage
    LogicTxMissionMain.QuitXMission(true, nil, true)
    local xmission_main = UIManager.GetUI(UIManager.UI_Config.xmission_main)
    log_format("Lobby_Main_Control.MoveToPage xmission_main = %s", xmission_main == nil)
    return xmission_main == nil
  end
  Lobby_Main_Control.fromPage = Lobby_Main_Control.curPage
  Lobby_Main_Control.  Lobby_Main_Control.PlayUIAnim(Lobby_Main_Control.curPage, toPage)
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, toPage)
  if UIManager.IsUIShow(UIManager.UI_Config.Lab_Main_Newbie_Slide_UIBP) and toPage ~= ENUM_LobbyPageType.Mid then
    local LogicNewbie = require("client.logic.newbie.logic_newbie")
    if not DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, 20007) then
      DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, 20007)
    end
    UIManager.CloseUI(UIManager.UI_Config.Lab_Main_Newbie_Slide_UIBP)
  end
  return true
end
function Lobby_Main_Control.HandleToRightScreenLogic()
  log(bWriteLog and "Lobby_Main_Control.HandleToRightScreenLogic. ")
  local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
  local rightMode = logic_home_switch.lobbyRightMode
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  local isInXmission = LogicTxMissionMain.IsInXMission()
  if not logic_home_switch.isShowLobbyRightMode then
    log(bWriteLog and "Lobby_Main_Control.HandleToRightScreenLogic is not  show lobby right")
    return false
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local teamID = TeamUpNewSystem.GetTeamID() or 0
  local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
  log(bWriteLog and "Lobby_Main_Control.HandleToRightScreenLogic rightMode = " .. tostring(rightMode))
  local isUGCOpen = true
  if rightMode == ENUM_LobbyRightMode.UGCHall then
    isUGCOpen = logic_ugc_hall:CheckIsOpen()
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    if not Config_UGC.IsUGCUnlock() then
      local ugcEntry = Config_UGC.GetEntryData()
      ShowNotice(LocUtil.LocalizeResFormat(31028, ugcEntry.level_limit))
      return
    end
  end
  if 0 < teamID and not TeamUpNewSystem.IsTeamLeader() and not isUGCOpen then
    log(bWriteLog and "Lobby_Main_Control.HandleToRightScreenLogic is not team leader")
    ShowNotice(33241)
    return false
  end
  if LobbySystem.isInMatch and not isUGCOpen then
    ShowNotice(110014)
    return false
  end
  local QRcodeRestrictManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.QRcodeRestrictManager)
  if QRcodeRestrictManager:IsRestrictBatlleRank() then
    QRcodeRestrictManager:ShowRestrictTips()
    return false
  end
  if rightMode == ENUM_LobbyRightMode.None then
  elseif rightMode == ENUM_LobbyRightMode.XMission and not isInXmission then
    if not Lobby_Main_Control.EnterXmission(ENUM_XMISSION_FROM.Scroll) then
      return false
    end
    local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
    if not logic_xmission_entrance:IsTxMissionOpen() then
      return true
    end
  end
  return true
end
function Lobby_Main_Control.EnterXmission(from)
  local LogicTxMissionDownload = require("client.slua.logic.TxMission.logic_xmission_download")
  if from == ENUM_XMISSION_FROM.Scroll then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    logic_home_switch:UpdateRightModeNewbie(logic_home_switch.Enum_RightModeNewbieGuideKey.FirstSetXmission)
  end
  local canEnter = LogicTxMissionDownload.CheckResHasDownloaded()
  local PufferMapManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_map_manager)
  if not PufferMapManager.bHaveInitMapPaks then
    canEnter = false
  end
  if canEnter then
    local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
    if not logic_xmission_entrance:CheckPlayerLevelEnough() then
      log_warning(bWriteLog and "Lobby_Main_Control.EnterXmission. not enough level")
      ClientSendTLogReport(TLogEventDefine.TPlan_Enter_Block, 2, tostring(DataMgr.roleData.level))
      return false, false
    end
    if not logic_xmission_entrance:CheckCanEnterTxMission(true, true) then
      log_warning(bWriteLog and "Lobby_Main_Control.EnterXmission. can not enter xmission")
      return true, false
    end
    if not logic_xmission_entrance:IsTxMissionOpen() then
      log(bWriteLog and "Lobby_Main_Control.EnterXmission. XMission is not open")
      return true, false
    end
    logic_connection_waiting:Show(0, false)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(1, function()
      logic_connection_waiting:Hide(0)
    end)
    local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
    LogicTxMissionMain.SendEnterXMissionReq(from)
    return false, true
  else
    local logic_xmission_entrance = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_xmission_entrance)
    local ActivityInfo = logic_xmission_entrance:GetTxMissionActivityInfo()
    if ActivityInfo == nil then
      return true, false
    end
    logic_connection_waiting:Show(0, false)
    local time_ticker = require("common.time_ticker")
    time_ticker.AddTimer(1.2, function()
      log(bWriteLog and "Lobby_Main_Control.EnterXmission. hide loading")
      logic_connection_waiting:Hide(0)
    end)
    LogicTxMissionDownload.OpenDownload(from)
    return true, false
  end
end
function Lobby_Main_Control.OnEnterXmission()
  log(bWriteLog and "Lobby_Main_Control.OnEnterXmission")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not ui or ui.UIRoot then
  end
end
function Lobby_Main_Control.OnEnterXmissionEnd()
  log_shipping_client("Lobby_Main_Control.OnEnterXmissionEnd")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not ui or ui.UIRoot then
  end
end
function Lobby_Main_Control.OnSwitchToPageEnd(fromPage, toPage)
  log(bWriteLog and "Lobby_Main_Control.OnSwitchToPageEnd fromPage = " .. fromPage .. ", toPage = " .. toPage)
  if toPage == ENUM_LobbyPageType.Mid then
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.ShowTeamUI()
  else
    local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
    TeamUpNewSystem.HideTeamUI()
  end
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, fromPage, toPage)
end
function Lobby_Main_Control.OnLobbyEndedDispatcher(X, Y)
  Lobby_Main_Control.Display3D_TouchEndEvent()
end
function Lobby_Main_Control.Display3D_TouchEndEvent()
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_3D_TOUCH_END)
end
function Lobby_Main_Control.OnTouchStartedEvent()
  log(bWriteLog and "Lobby_Main_Control.OnTouchStartedEvent")
  if UIManager.GetUI(UIManager.UI_Config.match_tips_guide) then
    UIManager.CloseUI(UIManager.UI_Config.match_tips_guide)
  end
end
function Lobby_Main_Control.OnScrollEnd(offsetX, offsetY, Geometry, touchStartPos)
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  local Logic_SocialLobbyEditMgrModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyEditMgrModule)
  if Logic_SocialLobbyEditMgrModule:GetIsEditing() then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd IsEditing")
    return
  end
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local lastSwitchCameraTime = Lobby_camera_manager_module.lastSwitchCameraTime or 0
  local time_util = require("client.common.time_util")
  local curTime = time_util.GetMiliseconds()
  if curTime - lastSwitchCameraTime < 1200 then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd cannot switch camera fast")
    return
  end
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_RESET_3D_BUTTON_STATUS)
  end)
  local Lobby_Main_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not Lobby_Main_UIBP then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd no ui")
    return
  end
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.CanSwitchUI() then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd can not switch")
    return
  end
  if touchStartPos then
    local UIUtil = require("client.common.ui_util")
    local DPI = UIUtil.GetViewportScale()
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd DPI = " .. tostring(DPI))
    local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
    local LocalCoord = SlateBlueprintLibrary.AbsoluteToLocal(Geometry, touchStartPos)
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd LocalCoord = " .. LocalCoord:ToString())
    local touchStartY = LocalCoord.Y
    local new_offsetY = offsetY / DPI
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd touchStartY = " .. tostring(touchStartY) .. " new_offsetY = " .. tostring(new_offsetY))
    if 77 <= touchStartY then
      local coe = math.abs(offsetX) / math.abs(offsetY)
      if coe < 1 and 135 <= new_offsetY and not UIManager.IsUIShow(UIManager.UI_Config.xmission_download) and Lobby_Main_Control.curPage == ENUM_LobbyPageType.Mid then
        log(bWriteLog and "Lobby_Main_Control.OnScrollEnd move up")
        local logic_main_city_privacy = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_main_city_privacy)
        local switch = logic_main_city_privacy:GetUserSwitch(4)
        if not switch then
          log(bWriteLog and "Lobby_Main_Control.OnScrollEnd check quick enter hub switch is " .. tostring(switch))
          return
        end
        local main_city_process_util = require("GameLua.Mod.MainCity.Client.logic.Process.main_city_process_util")
        if not main_city_process_util.IsMainCityEntryOpen(true) then
          return
        end
        UIManager.CloseUI(UIManager.UI_Config.MainCity_Newbie_Slide_UIBP)
        local Main_City_Download_Tool = require("client.slua.logic.lobby.MainCity.Main_City_Download_Tool")
        if not Main_City_Download_Tool.IsMainCityMapDownloaded(true) then
          return
        end
        UIManager.ShowUI(UIManager.UI_Config.ModeSelection_Opening_MainCity)
        local logic_main_city_enter_report = require("GameLua.Mod.MainCity.Client.logic.logic_main_city_enter_report")
        logic_main_city_enter_report.SetReportData("NewEnterMainCity", "EnterMCFromLobby", "DropDownIntoMC")
        return
      end
    end
  end
  if UIManager.GetUI(UIManager.UI_Config.ModeSelection_Opening_MainCity) then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd ModeSelection_Opening_MainCity")
    return
  end
  local curPage = Lobby_Main_Control.curPage
  local toPage = curPage
  if math.abs(offsetX) > math.abs(offsetY) and math.abs(offsetX) > 50 then
    if 0 < offsetX then
      if 0 < curPage then
        toPage = curPage - 1
      end
    elseif curPage < 2 then
      toPage = curPage + 1
    end
  else
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd offset not enough")
    return
  end
  if curPage == toPage then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd same page")
    return
  end
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if toPage == ENUM_LobbyPageType.Left then
    local Logic_SC_DownloadTools = require("client.slua.logic.lobby.Left.SocialLobby.Logic_SC_DownloadTools")
    local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
    local PufferConst = require("client.slua.logic.download.puffer_const")
    if PublishRegionMacros.IsFITVersion() then
      local tDownloadResList = Logic_SC_DownloadTools.GetSocialLobbyDownloadResList()
      table.insert(tDownloadResList, PufferConst.EODPackID.SocialLobby)
      if PufferManager.ShowDownloadTips(PufferConst.ENUM_DownloadType.ODPACK, tDownloadResList) then
        log(bWriteLog and "Lobby_Main_Control.OnScrollEnd no SocialLobby")
        return
      end
    else
      local bIsDownload = Logic_SC_DownloadTools.GetSocialLobbyResIsDownloaded()
      if not bIsDownload then
        Logic_SC_DownloadTools.ShowSocialLobbyDownloadPopup(DataMgr.roleData.uid)
        return
      end
    end
  end
  Lobby_Main_Control.lockPageTime = 5
  if toPage == ENUM_LobbyPageType.Right then
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if logic_home_switch.lobbyRightMode == ENUM_LobbyRightMode.WowMode then
      Lobby_Main_Control.lockPageTime = 0
    end
  end
  if Lobby_Main_Control.LockPage() == false then
    log(bWriteLog and "Lobby_Main_Control.OnScrollEnd lock page")
    return
  end
  if Lobby_Main_Control.MoveToPage(toPage) then
    local switchUI = Lobby_Main_UIBP:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
    if switchUI then
      switchUI:PlaySwitchPageButtonAnimation(curPage, toPage)
    end
  end
  if not DataMgr.GetNewbieGuideValue(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, 20007) then
    DataMgr.SetNewbieGuide(LogicNewbie.NEWBIE_GUIDE_MODULE_ID_NewNewbie, 20007)
  end
  UIManager.CloseUI(UIManager.UI_Config.Lab_Main_Newbie_Slide_UIBP)
  local eventId
  if curPage == 1 and toPage == 0 then
    eventId = TLogEventDefine.LobbyMainScrollToSocialPage
  elseif curPage == 1 and toPage == 2 then
    eventId = TLogEventDefine.LobbyMainScrollToCommercialPage
    local logic_ugc_hall = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_hall)
    local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
    if logic_home_switch.lobbyRightMode == ENUM_LobbyRightMode.UGCHall and logic_ugc_hall:CheckIsOpen() then
      eventId = TLogEventDefine.LobbyMain_Scroll_To_UGC_Hall
    end
  elseif curPage == 0 and toPage == 1 then
    eventId = TLogEventDefine.LobbyMainSocialScrollToMainPage
  elseif curPage == 2 and toPage == 1 then
    eventId = TLogEventDefine.LobbyMainCommercialScrollToMainPage
  end
  ClientSendBAReport(eventId, 0)
end
function Lobby_Main_Control.LockPage()
  log(bWriteLog and "Lobby_Main_Control.LockPage. ani = " .. tostring(Lobby_Main_Control.bAni))
  if Lobby_Main_Control.bAni then
    return false
  end
  Lobby_Main_Control.bAni = true
  logic_connection_waiting:Show(0, false)
  local time_ticker = require("common.time_ticker")
  if Lobby_Main_Control.unlockTimer ~= nil then
    time_ticker.RemoveTimer(Lobby_Main_Control.unlockTimer)
    Lobby_Main_Control.unlockTimer = nil
  end
  Lobby_Main_Control.unlockTimer = time_ticker.AddTimerOnce(Lobby_Main_Control.lockPageTime, function()
    Lobby_Main_Control.unlockTimer = nil
    logic_connection_waiting:Hide(0)
    Lobby_Main_Control.bAni = false
    log(bWriteLog and "Lobby_Main_Control.LockPage. unlock")
  end)
  return true
end
function Lobby_Main_Control.OnAniLeftMidEnd()
  log(bWriteLog and "Lobby_Main_Control.OnAniLeftMidEnd")
  if Lobby_Main_Control.ignoreAniCallback then
    log_format("Lobby_Main_Control.OnAniLeftMidEnd. ignore")
    return
  end
  Lobby_Main_Control.HandleOnAniEnd()
end
function Lobby_Main_Control.OnAniMidRightEnd()
  log(bWriteLog and "Lobby_Main_Control.OnAniMidRightEnd")
  if Lobby_Main_Control.ignoreAniCallback then
    log_format("Lobby_Main_Control.OnAniMidRightEnd. ignore")
    return
  end
  Lobby_Main_Control.HandleOnAniEnd()
end
function Lobby_Main_Control.HandleOnAniEnd()
  log(bWriteLog and "Lobby_Main_Control.HandleOnAniEnd")
  Lobby_Main_Control.OnAniEnd()
end
function Lobby_Main_Control.OnAniEnd()
  log(bWriteLog and "Lobby_Main_Control.OnAniEnd")
  if Lobby_Main_Control.bFirstAni == true then
    Lobby_Main_Control.bFirstAni = false
    return
  end
  logic_connection_waiting:Hide(0)
  Lobby_Main_Control.bAni = false
  Lobby_Main_Control.curPage = Lobby_Main_Control.toPage
  log(bWriteLog and "Lobby_Main_Control.OnAniEnd curPage = " .. Lobby_Main_Control.curPage)
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if ui then
    log(bWriteLog and "Lobby_Main_Control.OnAniEnd AniCameraEnd bAnimation = " .. tostring(ui.Lobby20_Control_Comp.bAnimation))
    ui.Lobby20_Control_Comp:AniCameraEnd()
    local uibp = ui:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
    if uibp then
      uibp:CheckShowRightScreenNewbie()
    end
  end
  Lobby_Main_Control.OnSwitchToPageEnd(Lobby_Main_Control.fromPage, Lobby_Main_Control.toPage)
  Lobby_Main_Control.ShowPage(Lobby_Main_Control.curPage, true)
  if Lobby_Main_Control.curPage == ENUM_LobbyPageType.Left then
    EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_ANIM_MID_TO_LEFT_END)
  end
end
function Lobby_Main_Control.ShowPage(page)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if not ui then
    return
  end
  local switchUI = ui:GetChildUI(UIManager.UI_Config.Lobby_Main_Switch_UIBP)
  if not switchUI then
    return
  end
  local uiRoot = ui.UIRoot
  local collapsedList = {
    uiRoot.Border_SocialHall,
    uiRoot.Border3,
    uiRoot.Border4,
    uiRoot.Border5
  }
  local Collapsed = UEnums.ESlateVisibility.Collapsed
  local SelfHitTestInvisible = UEnums.ESlateVisibility.SelfHitTestInvisible
  for k, v in pairs(collapsedList) do
    v:SetWidgetVisibility(Collapsed)
  end
  if page == ENUM_LobbyPageType.Left then
    if uiRoot.Border_SocialHall then
      uiRoot.Border_SocialHall:SetWidgetVisibility(SelfHitTestInvisible)
    end
    uiRoot.Border_TabRoot:SetWidgetVisibility(Collapsed)
    uiRoot.Border_money:SetWidgetVisibility(Collapsed)
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:HideAntsVoiceUI()
    local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
    if avatar then
      avatar:SetCanRotate(false)
    end
  elseif page == ENUM_LobbyPageType.Mid then
    local Lobby_Left_Message_UIBP = UIManager.GetUI(UIManager.UI_Config.Lobby_Left_Message_UIBP)
    if Lobby_Left_Message_UIBP then
      Lobby_Left_Message_UIBP:RemoveAllTimer()
    end
    uiRoot.Border3:SetWidgetVisibility(SelfHitTestInvisible)
    uiRoot.Border4:SetWidgetVisibility(SelfHitTestInvisible)
    uiRoot.Border_TabRoot:SetWidgetVisibility(SelfHitTestInvisible)
    uiRoot.Border_money:SetWidgetVisibility(SelfHitTestInvisible)
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:ShowAntsVoiceUI()
    local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
    if avatar then
      avatar:SetCanRotate(true)
    end
    local Lobby_Mid_Message_UIBP = ui:GetChildUI(UIManager.UI_Config.Lobby_Mid_Message_UIBP)
    if Lobby_Mid_Message_UIBP then
      Lobby_Mid_Message_UIBP:UpdatePlayerAvatar()
    end
  elseif page == ENUM_LobbyPageType.Right then
    uiRoot.Border5:SetWidgetVisibility(SelfHitTestInvisible)
    uiRoot.Border_TabRoot:SetWidgetVisibility(Collapsed)
    uiRoot.Border_money:SetWidgetVisibility(Collapsed)
    local logic_chat_voice = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_chat_voice)
    logic_chat_voice:HideAntsVoiceUI()
    local avatar = TeamAvatarManager.GetAvatarByUid(DataMgr.roleData.uid)
    if avatar then
      avatar:SetCanRotate(false)
    end
  end
  local isRightPage = page == ENUM_LobbyPageType.Right
  local visibility = isRightPage and Collapsed or SelfHitTestInvisible
  uiRoot.Border_Match_Entry:SetWidgetVisibility(visibility)
  uiRoot.Border_Downloader_Btn:SetWidgetVisibility(visibility)
end
function Lobby_Main_Control.RecoverCameraPos()
  log(bWriteLog and "Lobby_Main_Control.RecoverCameraPos")
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  if ui then
    local page = Lobby_Main_Control.curPage
    log(bWriteLog and "Lobby_Main_Control.RecoverCameraPos. page = " .. tostring(Lobby_Main_Control.curPage))
    local cameraIndex = 0
    if page == ENUM_LobbyPageType.Left then
      cameraIndex = 10151
    elseif page == ENUM_LobbyPageType.Mid then
      local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
      if TeamUpNewSystem.GetTeamNum() == 1 then
        cameraIndex = Lobby_camera_manager_module.Enum_CameraID.Lobby_Default
      else
        cameraIndex = Lobby_camera_manager_module.Enum_CameraID.Lobby_Team
      end
    elseif page == ENUM_LobbyPageType.Right then
      cameraIndex = 10153
    end
    local LobbyLightLogic = require("client.slua.logic.manager.LobbySceneSubLogic.LobbyLightLogic")
    local lightLevelName = Lobby_camera_manager_module:GetLightLevelNameByCameraID(cameraIndex)
    local bLightLevelLoaded = LobbyLightLogic.currentLight == lightLevelName and LobbyLightLogic.IsLightLevelLoaded(lightLevelName)
    log(bWriteLog and string.format("Lobby_Main_Control.RecoverCameraPos cameraIndex=%d, cameraLightLevel=%s, curLight=%s, lightLevelLoaded=%s", cameraIndex, tostring(lightLevelName), tostring(LobbyLightLogic.currentLight), tostring(bLightLevelLoaded)))
    Lobby_camera_manager_module:SwitchCamera(cameraIndex, 0, bLightLevelLoaded)
  end
end
function Lobby_Main_Control.OnPlayerRotate()
  Lobby_Main_Control.CancelScroll()
end
function Lobby_Main_Control.CancelScroll()
  local xmission_main = UIManager.GetUI(UIManager.UI_Config.xmission_main)
  if xmission_main and xmission_main:IsShow() and xmission_main.UIRoot and xmission_main.UIRoot.Lobby_Control_Comp then
    xmission_main.UIRoot.Lobby_Control_Comp:CancelScroll()
  end
  local ui = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
  if ui and (Lobby_Main_Control.curPage == 0 or Lobby_Main_Control.curPage == 1) then
    ui.Lobby20_Control_Comp:CancelScroll()
  end
end
return Lobby_Main_Control