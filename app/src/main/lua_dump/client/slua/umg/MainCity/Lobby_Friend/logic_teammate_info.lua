local logic_teammate_info = {}
local C_CropsPositionLocalize = {
  [1] = 410005,
  [2] = 410006,
  [3] = 410007,
  [4] = 410008
}
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
function logic_teammate_info.CheckAndGetCertification(memberInfo)
  if not memberInfo then
    return false
  end
  if not memberInfo then
    log(bWriteLog and "logic_teammate_info.CheckCertification \228\184\141\230\152\175\233\152\159\229\143\139")
    return false
  end
  if not memberInfo.auth_type or not memberInfo.auth_end_time then
    log(bWriteLog and "logic_teammate_info.CheckCertification \229\184\144\229\143\183\230\156\170\233\133\141\231\189\174\232\174\164\232\175\129")
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if curTime > memberInfo.auth_end_time then
    log(bWriteLog and "logic_teammate_info.CheckCertification \232\174\164\232\175\129\232\191\135\230\156\159")
    return false
  end
  local authCfg = CDataTable.GetTableData("AuthTitleTable", memberInfo.auth_type)
  if not authCfg then
    log(bWriteLog and "logic_teammate_info.CheckCertification \233\133\141\231\189\174\232\174\164\232\175\129ID\233\148\153\232\175\175")
    return false
  end
  log(bWriteLog and "logic_teammate_info.CheckCertification true")
  return true, authCfg.AuthTypeText
end
function logic_teammate_info.CheckAuthInfoOpen(authType, authEndTime)
  if not authType or not authEndTime then
    log(bWriteLog and "Common_Certification_UIBP:SetAuthInfo invalid params")
    return false
  else
    local TimeUtil = require("client.common.time_util")
    local curTime = TimeUtil.GetServerTimeInSec()
    if authEndTime < curTime then
      log(bWriteLog and "Common_Certification_UIBP:SetAuthInfo curTime > authEndTime")
      return false
    end
  end
  local authCfg = CDataTable.GetTableData("AuthTitleTable", authType)
  if not authCfg then
    log(bWriteLog and "Common_Certification_UIBP:SetAuthInfo not authCfg")
    return false
  end
  return true
end
function logic_teammate_info.SetAlias(bIsSelf, memberInfo, Title_UIBP)
  if not Title_UIBP then
    return false
  end
  local aliasInfo = bIsSelf and DataMgr.roleData.alias or {}
  local id = aliasInfo.id or memberInfo.aliasid
  log(bWriteLog and "logic_teammate_info.CheckAlias id:" .. tostring(id))
  if id == nil or id == 0 then
    return false
  else
    local title = aliasInfo.title or memberInfo.aliastitle
    local nation = aliasInfo.nation or memberInfo.aliasnation
    local rank_id = aliasInfo.rank_id or memberInfo.aliasRankId
    if Title_UIBP.SetAliasInfo then
      Title_UIBP:SetAliasInfo(id or 0, title or "", nation or "", 0, rank_id or 0)
      return true
    else
      log_error(bWriteLog and "logic_teammate_info.CheckAlias Title_UIBP.SetAliasInfo is not exist")
      return false
    end
  end
end
function logic_teammate_info.UpdateCrops(memberInfo)
  if not memberInfo then
    return false
  end
  local corps_name = memberInfo.corps_name
  local corps_iconID = memberInfo.corps_icon
  local corps_icon = ""
  local config = CDataTable.GetTableData("CorpsBadge", tonumber(corps_iconID))
  if config then
    corps_icon = config.IconPath
  end
  log(bWriteLog and "logic_teammate_info.UpdateCrops corps_icon:" .. tostring(corps_icon))
  local corps_title = ""
  if corps_name and corps_name ~= "" then
    local cropAliasID = memberInfo.cur_corps_alias_id or 0
    log(bWriteLog and "logic_teammate_info.UpdateCrops cropAliasID:" .. tostring(cropAliasID))
    local cropAliasInfo = CDataTable.GetTableData("corps_alias_table", cropAliasID)
    if cropAliasInfo and cropAliasInfo.default == 1 then
      local positionLocalizeID = C_CropsPositionLocalize[memberInfo.corps_position]
      local positionStr = LocUtil.GetLocalizeResStr(positionLocalizeID or 410008)
      corps_title = positionStr
    end
    return true, corps_name, corps_title, corps_icon
  else
    return false
  end
end
function logic_teammate_info.UpdateReady(uid, memberInfo)
  if not uid or not memberInfo then
    return
  end
  local isLeader = TeamUpNewSystem.IsTeamLeader(uid)
  local isOffline = not memberInfo.svr or memberInfo.svr == 0
  local isReady = memberInfo.status == ENUM_MatchStatus.Ready
  local isInGame = memberInfo.game_start and 0 < memberInfo.game_start
  return isLeader, isOffline, isReady, isInGame
end
function logic_teammate_info.LeaveTeam()
  if LobbySystem.isInMatch then
    ShowNotice(110017)
    return
  end
  local UIUtil = require("client.common.ui_util")
  if not UIUtil.CanClickNow(UIUtil.ClickFrequencyLimit.Wardrobe) then
    return
  end
  if not Client.IsShipping() then
    local logic_team_up_test = require("client.slua.logic.teamup.logic_team_up_test")
    if logic_team_up_test.HasTeamBot() then
      logic_team_up_test.ClearBots()
      return
    end
  end
  TeamUpNewSystem.team_quit_request(TeamUpNewSystem.teamInfo.id)
end
function logic_teammate_info.UpdateRank(memberInfo, PeakGameUI, CommonRankUI)
  if not (memberInfo and PeakGameUI) or not CommonRankUI then
    return
  end
  local team_type = TeamUpNewSystem.GetTeamType()
  local LogicPeakGameUtil = require("client.logic.PeakGame.LogicPeakGameUtil")
  if LogicPeakGameUtil.IsPeakGameBattleType(team_type) then
    logic_teammate_info.RefreshPeakGameSegment(memberInfo, PeakGameUI)
    return true
  end
  local rankColor = FSlateColor(FLinearColor(0, 0, 0, 0.7))
  local id = logic_teammate_info.GetCurModeSegment(memberInfo.segment_info, memberInfo)
  CommonRankUI:SetRankCustomColor(id or 101, nil, rankColor)
end
function logic_teammate_info.GetCurModeSegment(allSegmentInfo, memberInfo)
  if not allSegmentInfo then
    log_warning(bWriteLog and " logic_teammate_info.GetCurModeSegment allSegmentInfo is nil")
    return 0
  end
  local zoneid
  if memberInfo and memberInfo.self_zone_id then
    zoneid = memberInfo.self_zone_id
  else
    zoneid = TeamUpNewSystem.teamInfo.zone_id
  end
  if not zoneid or zoneid == 0 then
    log_warning(bWriteLog and " logic_teammate_info.GetCurModeSegment zoneid is invalid,use self zone")
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    zoneid = ZoneSystem.GetChooseZone() or 0
  end
  log(bWriteLog and " logic_teammate_info.GetCurModeSegment zoneid is " .. tostring(zoneid))
  if not allSegmentInfo[zoneid] then
    log_warning(bWriteLog and " logic_teammate_info.GetCurModeSegment segment is nil")
    return FuncUtil.GetCurMaxSegementLevel(allSegmentInfo)
  end
  log_tree(bWriteLog and " logic_teammate_info.GetCurModeSegment TeamMember Segment:", allSegmentInfo[zoneid])
  local segment_info = allSegmentInfo[zoneid]
  local team_type = TeamUpNewSystem.GetTeamType()
  if team_type == 101 then
    return segment_info[enum_SegmentType.solo]
  elseif team_type == 102 then
    return segment_info[enum_SegmentType.double]
  elseif team_type == 103 then
    return segment_info[enum_SegmentType.team]
  elseif team_type == 401 then
    return segment_info[enum_SegmentType.fpp_solo]
  elseif team_type == 402 then
    return segment_info[enum_SegmentType.fpp_double]
  elseif team_type == 403 then
    return segment_info[enum_SegmentType.fpp_team]
  else
    return FuncUtil.GetCurMaxSegementLevel(allSegmentInfo)
  end
end
function logic_teammate_info.RefreshPeakGameSegment(memberInfo, PeakGameUI)
  if not (memberInfo and PeakGameUI) or not PeakGameUI.UIRoot then
    return
  end
  PeakGameUI.UIRoot:Setvisibility(UEnums.ESlateVisibility.Collapsed)
  local zoneid = memberInfo.self_zone_id or TeamUpNewSystem.teamInfo.zone_id
  if not zoneid or zoneid == 0 then
    log_warning(bWriteLog and "logic_teammate_info.RefreshPeakGameSegment zoneid is invalid, use self zone")
    local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
    zoneid = ZoneSystem.GetChooseZone() or 0
  end
  local teamType = TeamUpNewSystem.GetTeamType()
  local LogicPeakGameSegmentUtil = require("client.logic.PeakGame.LogicPeakGameSegmentUtil")
  local segId = LogicPeakGameSegmentUtil.GetPeakSegmentFromTeamMemberInfo(memberInfo, zoneid, teamType)
  if not segId then
    log(bWriteLog and "logic_teammate_info.RefreshPeakGameSegment no segId")
    return
  end
  log(bWriteLog and "logic_teammate_info.RefreshPeakGameSegment segId is " .. tostring(segId))
  PeakGameUI.UIRoot:Setvisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  PeakGameUI:SetPeakRankIntegral(segId)
end
function logic_teammate_info.UpdateGender(nUID, Gender_UIBP)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(nUID)
  if profile then
    Gender_UIBP:LoadIcon(nUID)
  else
    log(bWriteLog and "logic_teammate_info.UpdateGender no profile, uid:" .. tostring(nUID))
    Gender_UIBP:LoadIcon(0)
  end
end
function logic_teammate_info.UpdateBase(uid, memberInfo, PlayerNameUI, Button_Leave, Button_Info)
  if not (uid and memberInfo and PlayerNameUI and Button_Leave) or not Button_Info then
    return
  end
  local bIsSelf = uid == TeamUpNewSystem.GetSelfUID()
  PlayerNameUI:SetText(memberInfo.name)
  local NicknameColorManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.NicknameColorManager)
  PlayerNameUI:SetColorAndOpacity(NicknameColorManager:GetColorByUID(uid))
  Button_Leave:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  Button_Info:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if bIsSelf then
    Button_Leave:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  else
    Button_Info:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
  end
end
function logic_teammate_info.ShowButtonFriend(uid, Button_AddFriend)
  Button_AddFriend:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local isFriend = LogicFriend.IsMyFriend(uid)
  local UIUtil = require("client.common.ui_util")
  if isFriend then
    return
  end
  Button_AddFriend:SetWidgetVisibility(UIUtil.BoolToVisible(true, nil, true))
end
function logic_teammate_info.SendGift(uid)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() and PufferManager.ShowDownloadTips(PufferConst.ENUM_DownloadType.ODPACK, {
    PufferConst.EODPackID.SocialLobby
  }) then
    return
  end
  local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
  RoleInfoPopularitySystem.enter(tostring(uid))
  UIManager.ShowUI(UIManager.UI_Config.roleinfo_send_gift, RoleInfoPopularitySystem.GiftSourceType.TeamUp, nil, nil, uid)
end
function logic_teammate_info.CheckCanShowCollectLevel(uid)
  log(bWriteLog and string.format("logic_teammate_info.CheckCanShowCollectLevel uid = %s", uid))
  if not uid then
    log(bWriteLog and string.format("logic_teammate_info.CheckCanShowCollectLevel uid is nil"))
    return false
  end
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(uid)
  if not profile then
    log(bWriteLog and string.format("logic_teammate_info.CheckCanShowCollectLevel nil profile data. uid = %s", uid))
    return
  end
  if not profile.collect_data or not next(profile.collect_data) then
    log(bWriteLog and string.format("logic_teammate_info.CheckCanShowCollectLevel players are still in the old version. uid = %s", uid))
    return
  end
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  local privacy = profile.collect_data.privacy or {}
  if not collect_privacy_module:CanShowCollectLevel(privacy) then
    log(bWriteLog and string.format("logic_teammate_info.CheckCanShowCollectLevel privacy is not open"))
    return false
  end
  return true
end
function logic_teammate_info.ShowCollectData(uid)
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local score, seasonScore = 0, 0
  local TableUtil = require("common.table_util")
  local bIsSelf = uid == TeamUpNewSystem.GetSelfUID()
  local collect_data
  if bIsSelf then
    collect_data = collect_module.collect_data
    if not collect_data then
      if not UIManager.IsUIShow(UIManager.UI_Config.Collect_Guide_UIBP) then
        local CollectHandler = require("client.network.Protocol.CollectHandler")
        CollectHandler.send_get_collect_sys_main_data_req()
      end
      log(bWriteLog and "logic_teammate_info.ShowCollect collect_data is nil ")
      return false
    end
    score = collect_data.total_score
    local season = collect_module:GetSeasonId()
    seasonScore = TableUtil.GetTableValue(collect_module.collect_data.season_score, season) or 0
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if not profile then
      log(bWriteLog and "logic_teammate_info.ShowCollect profile is nil ")
      return false
    end
    collect_data = profile.collect_data
    score, seasonScore = collect_module:GetCollectScoreByCollectData(collect_data)
  end
  local collect_cfg = require("GameLua.Mod.Lobby.Base.Collect.logic.collect_cfg")
  local data = {
    collectData = {
      total_score = score,
      cur_season_collect_score = seasonScore,
      privacy = {
        [collect_cfg.privacy.DoubleShowCollectLevel] = collect_data.privacy
      }
    },
    showCollectTips = true
  }
  log_tree(bWriteLog and "logic_teammate_info.ShowCollect data:", data)
  return data
end
function logic_teammate_info.AdjustUIBySetPosition(alignWidget, adjustPanel, offsetX, offsetY)
  local slateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = alignWidget:GetCachedGeometry()
  local Size = slateBlueprintLibrary.GetLocalSize(Geometry)
  log(bWriteLog and "[zzw]logic_teammate_info.AdjustUIBySetPosition Size.x = " .. tostring(Size.X) .. "+ Y = " .. tostring(Size.Y))
  local util = require("client.slua_ui_framework.util")
  util.SetAnchors(adjustPanel, 0, 0, 0, 0)
  util.SetAlignment(adjustPanel, 0, 0)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  adjustPanel.Slot:SetPosition(FVector2D(Size.X + offsetX, offsetY))
end
function logic_teammate_info.AdjustUIBySetAnchorAndPosition(alignWidget, adjustPanel, offsetX, offsetY)
  if not alignWidget or not adjustPanel then
    return
  end
  logic_teammate_info._SetAnchor(alignWidget, adjustPanel)
  logic_teammate_info._SetPosition(alignWidget, adjustPanel, offsetX, offsetY)
end
function logic_teammate_info.CalculateWidgetActualSize(alignWidget)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local widgetGeo = alignWidget:GetCachedGeometry()
  local absSize = SlateBlueprintLibrary.GetAbsoluteSize(widgetGeo)
  local ui_util = require("client.common.ui_util")
  local viewPortScale = ui_util.GetViewportScale()
  absSize = absSize / viewPortScale
  local absSize2 = alignWidget:GetDesiredSize()
  log(bWriteLog and "[zzw]logic_teammate_info.CalculateWidgetActualSize asdasd absSize = " .. tostring(absSize.X) .. "+ absSize2 = " .. tostring(absSize2.X) .. " viewPortScale = " .. tostring(viewPortScale))
  return absSize
end
function logic_teammate_info._SetAnchor(alignWidget, adjustPanel)
  adjustPanel.Slot:SetPosition(FVector2D(0, 0))
  local ui_util = require("client.common.ui_util")
  local viewSize = ui_util.GetViewportSize()
  local util = require("client.slua_ui_framework.util")
  local slotPosition = ui_util.GetWidgetViewportPos(alignWidget) * ui_util.GetViewportScale()
  local MaxX = slotPosition.X / viewSize.X
  local MaxY = slotPosition.Y / viewSize.Y
  util.SetAnchors(adjustPanel, MaxX, MaxY, MaxX, MaxY)
  util.SetAlignment(adjustPanel, 0, 0)
end
function logic_teammate_info._SetPosition(alignWidget, adjustPanel, offsetX, offsetY)
  local absSize = logic_teammate_info.CalculateWidgetActualSize(alignWidget)
  offsetX = offsetX or 0
  offsetY = offsetY or 0
  offsetX = offsetX + absSize.X
  log(bWriteLog and "[zzw]logic_teammate_info._SetPosition asdasd absSize.x = " .. tostring(absSize.X) .. " offsetX = " .. tostring(offsetX))
  adjustPanel.Slot:SetPosition(FVector2D(offsetX, offsetY))
end
return logic_teammate_info