local UI_Team_Main = {}
local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
local C_MenuOffset = {
  {
    -20,
    0,
    -20
  },
  {
    -30,
    0,
    -20
  },
  {
    -30,
    0,
    20
  },
  {
    -30,
    0,
    20
  }
}
local C_MenuOffset_Long = {
  {
    -20,
    0,
    -20
  },
  {
    -20,
    0,
    -20
  },
  {
    -20,
    0,
    20
  },
  {
    -20,
    0,
    20
  }
}
local C_MenuOffset_Garage = {
  {
    5,
    0,
    -20
  },
  {
    0,
    0,
    -20
  },
  {
    0,
    0,
    35
  },
  {
    0,
    0,
    35
  }
}
local C_ChatHeightItemY = 300
local SyncMatchModeInfo = function()
  local teamInfo = TeamUpNewSystem.teamInfo
  if teamInfo then
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.nSelectMatchID = teamInfo.team_type
    MatchModeMgrSystem.bAutoMatch = teamInfo.fill == 1
  end
end
function UI_Team_Main:ctor()
  self.menuList = {}
  self.effectUI = {}
  self.fixMenuPositionTimer = nil
  self.nStartFixPositionTime = 0
  self.addMembers = {}
  self.bNewTeam = false
  self.bTeamUILoading = false
  self.curShowingDetailUid = 0
  self.lastIntimacyInfo = {}
  self.isShowing = false
  self.isShowingTimer = nil
end
function UI_Team_Main:RegistEvents()
  UI_Team_Main.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ADD_OTHER_PLAYER, self.OnJoin, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_JOIN_TEAM, self.OnJoin, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CREATE_TEAM, self.OnCreateTeam, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.OnQuit, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_EXIT_OTHER_PLAYER, self.OnExitMember, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMINFO_SYNC, self.OnTeamInfoSync, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOBBY_CAMERA_SHOWHIDE, self.OnShowHideLobbyCamera, self)
  self:AddOnClickedEventByControl(self.UIRoot.Teamcode.Button_TeamCode_X, self.OnClickCloseTeamCode, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_TEAMCODE_SYNC, self.OnUpdateTeamCode, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_INVITE_GAME, self.OnShowOneMoreGameInviteUI, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.FixMenuPosition, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_SHOW_ALL_AVATAR, self.OnShowAllMenu, self)
  self:AddCommonEvent(EVENTTYPE_OLD_WIDGET, EVENTID_ON_ALL_WIDGET_HIDE, self.FixMenuPositionNow, self)
  self:AddCommonEvent(EVENTTYPE_VIDEO, EVENTID_VIDEO_ENDS, self.OnShowAllMenu, self)
  self:AddCommonEvent(EVENTTYPE_SETTING, EVENTID_VIEWPORT_SIZE_CHANGED, self.OnScreenSizeChanged, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CLICK_MEMBER_DETAIL, self.OnShowHideMemberDetail, self)
  self:AddCommonEvent(EVENTTYPE_PERSON_SPACE, EVENTID_POPULARITY_SEND_GIFT_NOTIFY_RSP, self.OnSendGiftNotify, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_MEMBER_DETAIL_CLOSE_FROM_MENU, self.OnMemberDetailCloseFromMenu, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_AVATAR_CREATED, self.OnTeamAvatarCreated, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_MEMBER_RELATION_CHANGE, self.OnShowRelationAnim, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_AVATAR_POSITION_CHANGE, self.OnTeamPositionChange, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnShowRelationAnim, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_MICROPHONE, self.RefreshMicState, self)
  self:AddCommonEvent(EVENTTYPE_ANTSVOICE, EVENTID_ANTSVOICE_REFRESH_SPEAKER, self.RefreshSpeakerState, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_LOADING_BEGIN, self.ClearMenuChild, self)
end
function UI_Team_Main:OnPostInitialize()
  UI_Team_Main.__super.OnPostInitialize(self)
  local StatManager = import("StatManager")
  StatManager.GetInstance():ReportEventWithNoParam(3, true)
  SyncMatchModeInfo()
end
function UI_Team_Main:OnShow()
  UI_Team_Main.__super.OnShow(self)
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ON_SHOW_TEAMMAIN)
  log(bWriteLog and "UI_Team_Main:OnShow")
  self:UpdateMemberInfo(5)
end
function UI_Team_Main:OnHide()
  EventSystem:postEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_ON_HIDE_TEAMMAIN)
  self:CloseTeamMemberDetail()
end
function UI_Team_Main:Close()
  for i, v in ipairs(self.menuList) do
    if v.Close then
      v:Close()
    end
  end
  self.menuList = {}
  self.effectUI = {}
  self.bTeamUILoading = false
  self:CloseTeamMemberDetail()
  UI_Team_Main.__super.Close(self)
end
function UI_Team_Main:FixMenuPositionNow()
  if UIManager.IsAndroidStackEmpty() then
    self:FixMenuPosition()
  end
end
function UI_Team_Main:AddEffectUI(uid, config, params)
  log(bWriteLog and string.format("UI_Team_Main:AddEffectUI. uid=%s, config=%s, params=%s", tostring(uid), tostring(config), tostring(params)))
  uid = tonumber(uid)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetAvatarByUid(uid)
  if not avatar then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenu not avatar")
    return
  end
  local ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Menus, config, avatar, params)
  ui:SetZOrder(1)
  self.effectUI[uid] = ui
end
function UI_Team_Main:RemoveEffectUI(ui)
  for k, v in pairs(self.effectUI) do
    if v == ui then
      self.effectUI[k] = nil
    end
  end
end
function UI_Team_Main:ClearMenuChild()
  self.menuList = {}
end
function UI_Team_Main:OnTeamAvatarCreated(_, _, uid)
  log(bWriteLog and "UI_Team_Main:OnTeamAvatarCreated uid == " .. tostring(uid))
  if not TeamUpNewSystem.teamInfo or not TeamUpNewSystem.teamInfo.members then
    return
  end
  local memberCount = 0
  for _ in pairs(TeamUpNewSystem.teamInfo.members) do
    memberCount = memberCount + 1
  end
  if memberCount <= 1 then
    log(bWriteLog and "UI_Team_Main:OnTeamAvatarCreated memberCount <= 1, skip")
    return
  end
  if TeamUpNewSystem.teamInfo.members[tonumber(uid)] then
    self:UpdateMenu(uid)
  end
end
function UI_Team_Main:UpdateMenu(uid)
  uid = tonumber(uid)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetAvatarByUid(uid)
  if not avatar then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenu not avatar")
    return
  end
  local uiEffect = self.effectUI[uid]
  if uiEffect then
    uiEffect:UpdatePos()
  end
  local index = avatar.positionIndex
  if not index or index == 0 then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenu not index or index == 0")
    return
  end
  if not TeamUpNewSystem.InShowGroup(index) then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenu not TeamUpNewSystem.InShowGroup(index)")
    return
  end
  local menuIndex = TeamUpNewSystem.GetShowTeamGroup() == 1 and index or index - TeamUpNewSystem.GetDefaultMaxTeamNum()
  local ui = self.menuList[menuIndex]
  local isNew = false
  if self.addMembers and self.addMembers[uid] then
    isNew = true
    self.addMembers[uid] = nil
  end
  if not ui or not slua.isValid(ui.UIRoot) then
    ui = self:CreateChildWindow(self.UIRoot.CanvasPanel_Menus, UIManager.UI_Config.TeamUp_Member_Menu_UIBP, uid, index)
    ui:SetAnchors(0, 0, 0, 0)
    ui:SetOffsets(0, 0, 100, 30)
    self.menuList[menuIndex] = ui
    return
  end
  ui:UpdateCanvasSlot2Postition(index)
  ui:UpdateChatPosition(uid)
  ui:SetUID(uid, isNew)
  ui:SelfHitTestInvisible()
end
function UI_Team_Main:ModifyChatHeight(height)
  C_ChatHeightItemY = height
  self:UpdateAllMenu()
end
function UI_Team_Main:GetWidgetTargetPosition(index)
  if _G.IsEditor then
    return self:GetWidgetTargetPosition380(index)
  end
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatarPos = TeamAvatarManager.GetAvatarPosition(index)
  log_tree("[DeanJYT] UI_Team_Main:GetWidgetTargetPosition avatarPos of index" .. tostring(index) .. ":", avatarPos)
  local offsetCfg = C_MenuOffset
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  local adapt = Lobby_camera_manager_module:GetCurrentCameraRatio()
  if adapt == Lobby_camera_manager_module.Enum_CameraRatio.LongScreen then
    offsetCfg = C_MenuOffset_Long
  end
  local GarageThemeSystem = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.GarageThemeSystem)
  if GarageThemeSystem:IsInGarageTheme() then
    offsetCfg = C_MenuOffset_Garage
  end
  local defaultMaxTeamNum = TeamUpNewSystem.GetDefaultMaxTeamNum()
  local menuIndex = index <= defaultMaxTeamNum and index or index - defaultMaxTeamNum
  local offset = offsetCfg[menuIndex]
  local UIUtil = require("client.common.ui_util")
  if not avatarPos then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:GetWidgetTargetPosition avatarPos missing")
    return
  end
  local menuPos = UIUtil.ProjectWorldPosToScreenPos(avatarPos[1] + offset[1], avatarPos[2] + offset[2], avatarPos[3] + offset[3])
  return menuPos
end
function UI_Team_Main:GetWidgetTargetPosition380(index)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatarPos = TeamAvatarManager.GetAvatarPosition(index)
  log(bWriteLog and string.format("UI_Team_Main:GetWidgetTargetPosition for index %s: %s %s %s", index, avatarPos[1], avatarPos[2], avatarPos[3]))
  if not avatarPos then
    return nil
  end
  local ui_util = require("client.common.ui_util")
  local WorldContextObject = ui_util.GetGameInstance()
  local UGameplayStatics = import("GameplayStatics")
  local PlayerController = UGameplayStatics.GetPlayerController(WorldContextObject, 0)
  if PlayerController == nil then
    log_error("PlayerController is nil")
    return nil
  end
  local viewportSize = ui_util.GetViewportSize()
  local screenPos = FVector2D(0, 0)
  local Pos = FVector(avatarPos[1], avatarPos[2], avatarPos[3])
  PlayerController:ProjectWorldLocationToScreen(Pos, screenPos, true)
  local SlateBlueprintLibrary = import("SlateBlueprintLibrary")
  local Geometry = self.UIRoot:GetCachedGeometry()
  local LocalSize = SlateBlueprintLibrary.GetLocalSize(Geometry)
  local localPos = FVector2D(0, 0)
  localPos.X = screenPos.X / viewportSize.X * LocalSize.X
  localPos.Y = screenPos.Y / viewportSize.Y * LocalSize.Y
  return localPos
end
local OnTeamMemberMenuLoaded = function()
  log(bWriteLog and "UI_Team_Main OnTeamMemberMenuLoaded")
  local ui = UIManager.GetUI(UIManager.UI_Config.team_main)
  if not ui then
    log(bWriteLog and "UI_Team_Main OnTeamMemberMenuLoaded not ui")
    return
  end
  ui.bTeamUILoading = false
  for i, v in ipairs(ui.menuList) do
    v:CloseGoldSpinWing()
    v:Hide()
  end
  for i, v in ipairs(ui.menuList) do
    if v.nUID and TeamUpNewSystem.GetMemberInfo(v.nUID) then
      log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateAllMenu v.nUID = " .. tostring(v.nUID))
    elseif v.Reset then
      v:Reset()
    end
  end
  if TeamUpNewSystem.GetTeamNum() == 1 then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateAllMenu TeamUpNewSystem.GetTeamNum() == 1")
    return
  end
  for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
    ui:UpdateMenu(k)
  end
end
function UI_Team_Main:UpdateAllMenu()
  log(bWriteLog and "UI_Team_Main:UpdateAllMenu.")
  if not self.bTeamUILoading then
    self.bTeamUILoading = true
    self:GetAssetAsync(UIManager.UI_Config.TeamUp_Member_Menu_UIBP.path .. "_C", OnTeamMemberMenuLoaded)
  end
end
function UI_Team_Main:UpdateMenuPos(uid)
  uid = tonumber(uid)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetAvatarByUid(uid)
  if not avatar then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenuPos not avatar")
    return
  end
  local index = avatar.positionIndex
  if not index or index == 0 then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenu not index or index == 0")
    return
  end
  if not TeamUpNewSystem.InShowGroup(index) then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenu not TeamUpNewSystem.InShowGroup(index)")
    return
  end
  local menuIndex = TeamUpNewSystem.GetShowTeamGroup() == 1 and index or index - TeamUpNewSystem.GetDefaultMaxTeamNum()
  local ui = self.menuList[menuIndex]
  if not ui then
    return
  end
  if not slua.isValid(ui.UIRoot) then
    printf("UI_Team_Main:UpdateMenuPos not slua.isValid(ui.UIRoot)")
    return
  end
  local menuPos = self:GetWidgetTargetPosition(index)
  if nil == menuPos then
    log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenuPos nil == menuPos")
    return
  end
  local canvasSlot = ui.UIRoot.CanvasPanel_1.Slot
  canvasSlot:SetPosition(FVector2D(menuPos.X, menuPos.Y))
  log(bWriteLog and "[DeanJYT] UI_Team_Main:UpdateMenuPos uid == " .. tostring(uid) .. ", pos.X = " .. tostring(menuPos.X) .. ", pos.Y = " .. tostring(menuPos.Y))
  local uiEffect = self.effectUI[uid]
  if uiEffect then
    uiEffect:UpdatePos(menuPos.X + 30)
  end
  local mouthWorldPos = avatar:GetMouthWorldPosition()
  local UIUtil = require("client.common.ui_util")
  local screen = UIUtil.ProjectWorldToScreen(mouthWorldPos)
  local scale = UIUtil.GetViewportScale()
  local layoutPos = screen / scale
  print(bWriteLog and string.format(" UI_Team_Main:UpdateMenuPos index:%s,mouthWorldPos:%s,screen:%s,layoutPos:%s", index, mouthWorldPos, screen, layoutPos))
  local Slot = ui.UIRoot.CanvasPanel_QuickMsg.Slot
  Slot:SetPosition(layoutPos)
end
function UI_Team_Main:UpdateMemberInfo(fixPositionDt)
  log(bWriteLog and "[cw][team] UpdateMemberInfo(" .. tostring(fixPositionDt) .. ") ")
  local Lobby_Main_Control = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  Lobby_Main_Control.ComputeCameraInfo_Once()
  local newbieGuideManager = require("client.logic.newbie_manager.newbie_guide_manager")
  local needUpdateRole = newbieGuideManager.NeedUpdateRole()
  if not needUpdateRole then
    log(bWriteLog and "[cw][team] not needUpdateRole")
    LobbySceneManager.SwitchMainOrTeamCamera()
  else
    log(bWriteLog and "switch camera is not allowed when update role")
  end
  self:RemoveAllTimer()
  self:UpdateAllMenu()
  self:OnUpdateTeamCode()
  self:FixMenuPosition(fixPositionDt)
  self:RefreshTeamMemberDetail(self.curShowingDetailUid)
end
function UI_Team_Main:FixMenuPosition(fixPositionDt)
  if self.fixMenuPositionTimer then
    self:RemoveTimer(self.fixMenuPositionTimer)
    self.fixMenuPositionTimer = nil
  end
  self.nStartFixPositionTime = 0
  fixPositionDt = fixPositionDt or 10
  self.fixMenuPositionTimer = self:AddTimerLoop(0, function()
    self.nStartFixPositionTime = self.nStartFixPositionTime + 0.2
    if self.nStartFixPositionTime > fixPositionDt then
      self:RemoveTimer(self.fixMenuPositionTimer)
    else
      for k, v in pairs(TeamUpNewSystem.teamInfo.members) do
        self:UpdateMenuPos(k)
      end
    end
  end, TIMER_INFINITE, 0.5)
end
function UI_Team_Main:OnJoin(_, _, teamid, memberInfo)
  log(bWriteLog and "[edward][team_main] UI_Team_Main:OnJoin")
  if not self.addMembers then
    self.addMembers = {}
  end
  if memberInfo then
    self.addMembers[tonumber(memberInfo.uid)] = 1
  elseif self.bNewTeam then
    local teamInfo = TeamUpNewSystem.teamInfo
    if teamInfo then
      for uid, v in pairs(teamInfo.members) do
        self.addMembers[tonumber(uid)] = 1
      end
    end
    self.bNewTeam = false
  end
  self:UpdateMemberInfo()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowExtraTeamUI()
end
function UI_Team_Main:OnCreateTeam()
  self.bNewTeam = true
end
function UI_Team_Main:OnQuit()
  log(bWriteLog and "[edward][team_main] UI_Team_Main:OnQuit")
  self.addMembers = nil
  self:UpdateMemberInfo()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowExtraTeamUI()
end
function UI_Team_Main:OnExitMember(_, _, uid)
  log(bWriteLog and "[cw][team][edward][team_main] UI_Team_Main:OnExitMember")
  if uid then
    log(bWriteLog and "[cw][team] param")
    local uidNum = tonumber(uid)
    if self.addMembers and self.addMembers[uidNum] then
      self.addMembers[uidNum] = nil
    end
    for i, v in ipairs(self.menuList) do
      if v and v.nUID and tonumber(v.nUID) == uidNum then
        v:Hide()
        v:Reset()
        break
      end
    end
    if TeamUpNewSystem.GetMemberInfo(uidNum) then
      self:UpdateMenu(uidNum)
      return
    end
    return
  end
  self:UpdateMemberInfo()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  TeamUpNewSystem.ShowExtraTeamUI()
end
function UI_Team_Main:OnTeamPositionChange()
  log(bWriteLog and "UI_Team_Main:OnTeamPositionChange")
  self:UpdateMemberInfo()
end
function UI_Team_Main:OnShowHideLobbyCamera(_, _, bShow)
  if not bShow then
    return
  end
  log(bWriteLog and "UI_Team_Main:OnShowHideLobbyCamera" .. tostring(bShow))
  self:UpdateMemberInfo()
end
function UI_Team_Main:OnTeamInfoSync(_, _, type)
  if not type or type == ENUM_TeamInfoSyncType.All then
    log(bWriteLog and "UI_Team_Main:OnTeamInfoSync")
    self:UpdateMemberInfo()
    SyncMatchModeInfo()
    EventSystem:postEvent(EVENTTYPE_MATCH, EVENTID_MATCH_UPDATE_PLAYERNUM, TeamUpNewSystem.GetTeamNum())
  elseif type == ENUM_TeamInfoSyncType.MatchMode then
    SyncMatchModeInfo()
    local MatchModeMgrSystem = require("client.slua.logic.match.logic_mode_mgr")
    MatchModeMgrSystem.SyncMatchModeEntry()
  end
end
function UI_Team_Main:OnShowAllMenu()
  log(bWriteLog and "[edward] UI_Team_Main:OnShowAllMenu")
  self:UpdateMemberInfo()
end
function UI_Team_Main:OnScreenSizeChanged()
  log(bWriteLog and "UI_Team_Main:OnScreenSizeChanged")
  self:UpdateMemberInfo()
end
function UI_Team_Main:RefreshTeamMemberDetail(uid)
  local LogicTxMissionMain = require("client.slua.logic.TxMission.logic_xmission_main")
  if LogicTxMissionMain.IsInXMission() then
    log(bWriteLog and string.format("[kkjhuang] RefreshTeamMemberDetail, strCode:%s", "IsInXMission"))
    return
  end
  if uid == 0 then
    return
  end
  self.curShowingDetailUid = uid
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local avatar = TeamAvatarManager.GetAvatarByUid(uid)
  if not avatar then
    self:CloseTeamMemberDetail()
    return
  end
  local index = avatar.positionIndex
  if not index or index == 0 then
    self:CloseTeamMemberDetail()
    return
  end
  local team_member_detail = UIManager.GetUI(UIManager.UI_Config.team_member_detail)
  if team_member_detail then
    team_member_detail:SelfHitTestInvisible()
  else
    team_member_detail = UIManager.ShowUI(UIManager.UI_Config.team_member_detail, uid)
  end
  team_member_detail:SetUID(uid)
  local menuIndex = TeamUpNewSystem.GetShowTeamGroup() == 1 and index or index - TeamUpNewSystem.GetDefaultMaxTeamNum()
  local ui = self.menuList[menuIndex]
  if not ui or not ui.UIRoot then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local Pos = UIUtil.LocalToContainerBoundingBox(ui.UIRoot.Overlay_InfoMenu)
  local uiFirst = self.menuList[1] and self.menuList[1].UIRoot and self.menuList[1].UIRoot.Overlay_InfoMenu
  if uiFirst then
    local PosFirst = UIUtil.LocalToContainerBoundingBox(uiFirst)
    Pos.Y = PosFirst.Y
  end
  team_member_detail:SetTipsWithPos(Pos)
end
function UI_Team_Main:CloseTeamMemberDetail()
  log(bWriteLog and "[DeanJYT] UI_Team_Main:CloseTeamMemberDetail")
  local team_member_detail = UIManager.GetUI(UIManager.UI_Config.team_member_detail)
  if team_member_detail then
    team_member_detail:CloseSelf()
  end
  self.curShowingDetailUid = 0
end
function UI_Team_Main:OnShowHideMemberDetail(_, _, uid)
  log(bWriteLog and "[DeanJYT] UI_Team_Main:OnShowHideMemberDetail uid = " .. tostring(uid))
  if self.curShowingDetailUid == uid then
    self:CloseTeamMemberDetail()
    return
  end
  self:RefreshTeamMemberDetail(uid)
end
function UI_Team_Main:OnSendGiftNotify()
  self:CloseTeamMemberDetail()
end
function UI_Team_Main:OnAvatarCreated(uid)
  log(bWriteLog and "UI_Team_Main:OnAvatarCreated")
  self:UpdateAllMenu()
end
function UI_Team_Main:OnMemberDetailCloseFromMenu()
  self.curShowingDetailUid = 0
end
function UI_Team_Main:StartShowingRelationAnim(delayTime)
  delayTime = delayTime or 1
  self.isShowing = true
  if self.isShowingTimer then
    self:RemoveTimer(self.isShowingTimer)
    self.isShowingTimer = nil
  end
  self.isShowingTimer = self:AddTimerOnce(delayTime, function()
    print(bWriteLog and "UI_Team_Main:StartShowingRelationAnim self.isShowing = false")
    self.isShowing = false
    self.isShowingTimer = nil
  end)
end
function UI_Team_Main:OnShowRelationAnim(_, _, type)
  print(bWriteLog and "UI_Team_Main:OnShowRelationAnim type = " .. tostring(type))
  local showCount = 0
  for key, ui in pairs(self.menuList) do
    if ui:IsShow() then
      showCount = showCount + 1
    end
  end
  if showCount ~= TeamUpNewSystem.GetTeamNum() then
    return
  end
  if not TeamUpNewSystem.teamInfo.intimacy_info then
    print(bWriteLog and "UI_Team_Main:OnShowRelationAnim intimacy_info = nil return")
    return
  end
  self.lastIntimacyInfo = TeamUpNewSystem.teamInfo.intimacy_info
  if self.isShowing then
    print(bWriteLog and "UI_Team_Main:OnShowRelationAnim self.isShowing = true return")
    return
  end
  log_tree("[wzp] UI_Team_Main:OnShowRelationAnim TeamUpNewSystem.teamInfo.intimacy_info ", TeamUpNewSystem.teamInfo.intimacy_info)
  local canShowList = {}
  local canShowCount = 0
  for uid, value in pairs(TeamUpNewSystem.teamInfo.intimacy_info) do
    local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
    if IntimacyAwardSystem.CheckCanShowAnimation(value.intimacy) then
      canShowList[uid] = value
      canShowCount = canShowCount + 1
    end
  end
  if canShowCount < 2 then
    return
  end
  if canShowCount == 2 then
    for key, value in pairs(canShowList) do
      for _, ui in pairs(self.menuList) do
        if ui:GetUID() == key then
          if ui:ShowRelationAnim() then
            self:StartShowingRelationAnim()
          end
          break
        end
      end
    end
    return
  end
  if canShowCount == 3 then
    local oneUID, noShowUID, relation
    local sameCount = 0
    for uid, value in pairs(canShowList) do
      if not oneUID then
        oneUID = uid
        relation = value.relation
      end
      if uid ~= oneUID then
        if value.relation == relation then
          sameCount = sameCount + 1
        else
          noShowUID = uid
        end
      end
    end
    if sameCount == 0 then
      for key, value in pairs(canShowList) do
        for _, ui in pairs(self.menuList) do
          if ui:GetUID() == key and ui:GetUID() ~= oneUID then
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
            break
          end
        end
      end
      return
    end
    if sameCount == 1 then
      for key, value in pairs(canShowList) do
        for _, ui in pairs(self.menuList) do
          if ui:GetUID() == key and ui:GetUID() ~= noShowUID then
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
            break
          end
        end
      end
      return
    end
    if sameCount == 2 then
      local firstShowUID1, firstShowUID2, firstIntimacy, secondShowUID1, secondShowUID2, secondIntimacy
      for uid, value in pairs(canShowList) do
        if not firstShowUID1 then
          firstShowUID1 = uid
          firstShowUID2 = value.friend_uid
          firstIntimacy = value.intimacy
        end
        if uid == firstShowUID2 and value.friend_uid == firstShowUID1 then
        else
          secondShowUID1 = uid
          secondShowUID2 = value.friend_uid
          secondIntimacy = value.intimacy
        end
      end
      if firstIntimacy > secondIntimacy then
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() == firstShowUID1 or ui:GetUID() == firstShowUID2 then
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
            print(bWriteLog and "[wzp] playUID = " .. tostring(ui:GetUID()))
          end
        end
      else
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() == secondShowUID1 or ui:GetUID() == secondShowUID2 then
            print(bWriteLog and "[wzp] playUID = " .. tostring(ui:GetUID()))
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
          end
        end
      end
      return
    end
  end
  if canShowCount == 4 then
    local oneUID, relationUID, noShowUID, relation
    local sameCount = 0
    for uid, value in pairs(canShowList) do
      if not oneUID then
        oneUID = uid
        relation = value.relation
        relationUID = value.friend_uid
      end
      if uid ~= oneUID then
        if value.relation == relation then
          sameCount = sameCount + 1
        else
          noShowUID = uid
        end
      end
    end
    if sameCount == 0 then
      local twoUID, _noShowUID
      sameCount = 0
      for uid, value in pairs(canShowList) do
        if not twoUID then
          twoUID = uid
          relation = value.relation
        end
        if uid ~= twoUID then
          if value.relation == relation then
            sameCount = sameCount + 1
          else
            _noShowUID = uid
          end
        end
      end
      if sameCount == 0 then
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() ~= oneUID and ui:GetUID() ~= twoUID and ui:ShowRelationAnim() then
            self:StartShowingRelationAnim()
          end
        end
        return
      end
      if sameCount == 1 then
        for key, value in pairs(canShowList) do
          for _, ui in pairs(self.menuList) do
            if ui:GetUID() == key and ui:GetUID() ~= oneUID and ui:GetUID() ~= _noShowUID and ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
            break
          end
        end
        return
      end
      if sameCount == 2 then
        local firstShowUID1, firstShowUID2, firstIntimacy, secondShowUID1, secondShowUID2, secondIntimacy
        for uid, value in pairs(canShowList) do
          if uid ~= oneUID then
            if not firstShowUID1 then
              firstShowUID1 = uid
              firstShowUID2 = value.friend_uid
              firstIntimacy = value.intimacy
            end
            if uid == firstShowUID2 and value.friend_uid == firstShowUID1 then
            else
              secondShowUID1 = uid
              secondShowUID2 = value.friend_uid
              secondIntimacy = value.intimacy
            end
          end
        end
        if firstIntimacy > secondIntimacy then
          for key, ui in pairs(self.menuList) do
            if ui:GetUID() ~= oneUID and (ui:GetUID() == firstShowUID1 or ui:GetUID() == firstShowUID2) then
              if ui:ShowRelationAnim() then
                self:StartShowingRelationAnim()
              end
              print(bWriteLog and "[wzp] playUID = " .. tostring(ui:GetUID()))
            end
          end
        else
          for key, ui in pairs(self.menuList) do
            if ui:GetUID() ~= oneUID and (ui:GetUID() == secondShowUID1 or ui:GetUID() == secondShowUID2) then
              print(bWriteLog and "[wzp] playUID = " .. tostring(ui:GetUID()))
              if ui:ShowRelationAnim() then
                self:StartShowingRelationAnim()
              end
            end
          end
        end
        return
      end
    end
    if sameCount == 1 then
      for key, ui in pairs(self.menuList) do
        if ui:GetUID() == oneUID or ui:GetUID() == relationUID then
          print(bWriteLog and "[wzp] first playUID = " .. tostring(ui:GetUID()))
          if ui:ShowRelationAnim() then
            self:StartShowingRelationAnim()
          end
        end
      end
      self:AddTimerOnce(3, function()
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() ~= oneUID and ui:GetUID() ~= relationUID then
            print(bWriteLog and "[wzp] second playUID = " .. tostring(ui:GetUID()))
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
          end
        end
      end)
      return
    end
    if sameCount == 2 then
      local firstShowUID1, firstShowUID2, firstIntimacy, secondShowUID1, secondShowUID2, secondIntimacy
      for uid, value in pairs(canShowList) do
        if uid ~= noShowUID then
          if not firstShowUID1 then
            firstShowUID1 = uid
            firstShowUID2 = value.friend_uid
            firstIntimacy = value.intimacy
          end
          if uid == firstShowUID2 and value.friend_uid == firstShowUID1 then
          else
            secondShowUID1 = uid
            secondShowUID2 = value.friend_uid
            secondIntimacy = value.intimacy
          end
        end
      end
      if firstIntimacy > secondIntimacy then
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() ~= noShowUID and (ui:GetUID() == firstShowUID1 or ui:GetUID() == firstShowUID2) then
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
            print(bWriteLog and "[wzp] playUID = " .. tostring(ui:GetUID()))
          end
        end
      else
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() ~= noShowUID and (ui:GetUID() == secondShowUID1 or ui:GetUID() == secondShowUID2) then
            print(bWriteLog and "[wzp] playUID = " .. tostring(ui:GetUID()))
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
          end
        end
      end
      return
    end
    if sameCount == 3 then
      do
        local firstShowUID = 0
        local secondShowUID = 0
        local thirdShowUID = 0
        local sameAnimNoShowUID = 0
        for uid, value in pairs(canShowList) do
          if canShowList[value.friend_uid].friend_uid == uid then
            sameAnimNoShowUID = value.friend_uid
          end
        end
        for uid, value in pairs(canShowList) do
          if uid ~= sameAnimNoShowUID then
            if not firstShowUID then
              firstShowUID = uid
            elseif not secondShowUID then
              secondShowUID = uid
            else
              thirdShowUID = uid
            end
          end
        end
        local canShowUID = 0
        if canShowList[firstShowUID].intimacy > canShowList[secondShowUID].intimacy then
          if canShowList[firstShowUID].intimacy > canShowList[thirdShowUID].intimacy then
            canShowUID = firstShowUID
          else
            canShowUID = thirdShowUID
          end
        elseif canShowList[secondShowUID].intimacy > canShowList[thirdShowUID].intimacy then
          canShowUID = secondShowUID
        else
          canShowUID = thirdShowUID
        end
        for key, ui in pairs(self.menuList) do
          if ui:GetUID() == canShowUID or ui:GetUID() == canShowList[canShowUID].friend_uid then
            print(bWriteLog and "[wzp] first playUID = " .. tostring(ui:GetUID()))
            if ui:ShowRelationAnim() then
              self:StartShowingRelationAnim()
            end
          end
        end
      end
    end
  end
end
function UI_Team_Main:OnUpdateTeamCode()
  local teamCode = TeamUpNewSystem.GetTeamCode()
  if not teamCode or teamCode == "" then
    self.UIRoot.Teamcode:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self.UIRoot.Teamcode:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self.UIRoot.Teamcode:SetData(teamCode, TeamUpNewSystem.IsTeamLeader())
end
function UI_Team_Main:OnClickCloseTeamCode()
  self:PlayAudio(sound_config.click)
  local FaceTeamSystem = require("client.slua.logic.faceteam.logic_faceteam")
  FaceTeamSystem.team_code_delete_req(TeamUpNewSystem.GetTeamCode())
end
function UI_Team_Main:OnShowOneMoreGameInviteUI()
  if GameStatus.IsInLobbyOrMainCity() then
    TeamUpNewSystem.ShowOneMoreGameInviteUI()
  end
end
function UI_Team_Main:OnSwitchToPageStart(_, _, toPage)
  if toPage == ENUM_LobbyPageType.Mid then
    self:OnShowRelationAnim()
    return
  end
  TeamUpNewSystem.HideTeamUI()
end
function UI_Team_Main:RefreshMicState()
  printf("UI_Team_Main:RefreshMicState")
  for key, ui in pairs(self.menuList) do
    if ui.bIsSelf then
      ui:RefreshMicState()
      break
    end
  end
end
function UI_Team_Main:RefreshSpeakerState()
  printf("UI_Team_Main:RefreshSpeakerState")
  for key, ui in pairs(self.menuList) do
    if ui.bIsSelf then
      ui:RefreshSpeakerState()
      break
    end
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUI_Team_Main = class(ui_base, nil, UI_Team_Main)
return CUI_Team_Main