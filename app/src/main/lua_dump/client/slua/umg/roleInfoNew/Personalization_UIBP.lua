local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
local ENUM_Type = PersonalizationConst.ENUM_Type
local TabCfg = {
  [ENUM_Type.Alias] = {
    config = UIManager.UI_Config.Personalization_Title_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Title_Select_png.Personalization_Icon_Title_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Title_png.Personalization_Icon_Title_png",
    bMatchSize = true,
    reddotKey = "aliasRed"
  },
  [ENUM_Type.CountryPage] = {
    config = UIManager.UI_Config.Personalization_Flag_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Flag_Select_png.Personalization_Icon_Flag_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Flag_png.Personalization_Icon_Flag_png",
    bMatchSize = true,
    reddotKey = "",
    checkShowFun = function()
      local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
      local logic_multiple_area = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_multiple_area)
      return not PublishRegionMacros.IsBLUEHOLE() and not logic_multiple_area:IsConnectToRussiaArea()
    end
  },
  [ENUM_Type.Avatar] = {
    config = UIManager.UI_Config.Personalization_Avatar_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Avatar_Select_png.Personalization_Icon_Avatar_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Avatar_png.Personalization_Icon_Avatar_png",
    bMatchSize = true,
    reddotKey = "avatarRed"
  },
  [ENUM_Type.AvatarFrame] = {
    config = UIManager.UI_Config.Personalization_AvatarFrame_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_AvatarFrame_Select_png.Personalization_Icon_AvatarFrame_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_AvatarFrame_png.Personalization_Icon_AvatarFrame_png",
    bMatchSize = true,
    reddotKey = "avatarFrameRed"
  },
  [ENUM_Type.NameFrame] = {
    config = UIManager.UI_Config.Personalization_Teambrand_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_NameplateFrame_Select_png.Personalization_Icon_NameplateFrame_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_NameplateFrame_png.Personalization_Icon_NameplateFrame_png",
    bMatchSize = true,
    reddotKey = "nameFrameRed"
  },
  [ENUM_Type.TeamUpFrame] = {
    config = UIManager.UI_Config.Personalization_InvitationPopup_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_InvitationPopup_Select_png.Personalization_Icon_InvitationPopup_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_InvitationPopup_png.Personalization_Icon_InvitationPopup_png",
    bMatchSize = true,
    reddotKey = "teamupFrameRed"
  },
  [ENUM_Type.CarteFrame] = {
    config = UIManager.UI_Config.Personalization_InformationCard_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_InformationCard_Select_png.Personalization_Icon_InformationCard_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_InformationCard_png.Personalization_Icon_InformationCard_png",
    bMatchSize = true,
    reddotKey = "carteFrameRed"
  },
  [ENUM_Type.SocialCardBGFrame] = {
    config = UIManager.UI_Config.Personalization_SocialCard_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Social_Select_png.Personalization_Icon_Social_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Social_png.Personalization_Icon_Social_png",
    bMatchSize = true,
    reddotKey = "soicalcardRed"
  },
  [ENUM_Type.NicknameFrame] = {
    config = UIManager.UI_Config.Personalization_Nickname_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_NickName_Select_png.Personalization_Icon_NickName_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_NickName_png.Personalization_Icon_NickName_png",
    bMatchSize = true,
    reddotKey = "nicknameFrameRed"
  },
  [ENUM_Type.NicknameColor] = {
    config = UIManager.UI_Config.Personalization_TeamShow_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_ID_Select_png.Personalization_Icon_ID_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_ID_png.Personalization_Icon_ID_png",
    bMatchSize = true,
    reddotKey = "nicknameColorRed"
  },
  [ENUM_Type.ChatFrame] = {
    config = UIManager.UI_Config.Personalization_ChatBubble_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_ChatBubble_Select_png.Personalization_Icon_ChatBubble_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_ChatBubble_png.Personalization_Icon_ChatBubble_png",
    bMatchSize = true,
    reddotKey = "chatFrameRed"
  },
  [ENUM_Type.EntryAction] = {
    config = UIManager.UI_Config.Personalization_EntryAction_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_EntryAction_Select_png.Personalization_Icon_EntryAction_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_EntryAction_png.Personalization_Icon_EntryAction_png",
    bMatchSize = true
  },
  [ENUM_Type.LightBoard] = {
    config = UIManager.UI_Config.LightBoard_Manage_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_LightBoard_Select_png.Personalization_Icon_LightBoard_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_LightBoard_png.Personalization_Icon_LightBoard_png",
    bMatchSize = true,
    reddotKey = "lightBoardRed",
    checkShowFun = function()
      local logic_light_board = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_light_board)
      local lightBoardCount = logic_light_board:GetLightBoardCount()
      local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
      return RoleInfoSystem.IsSelf() and 0 < lightBoardCount
    end
  },
  [ENUM_Type.RoleInfoBG] = {
    config = UIManager.UI_Config.Personalization_RoleInfoBG_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Background_Select_png.Personalization_Icon_Background_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Background_png.Personalization_Icon_Background_png",
    bMatchSize = true,
    reddotKey = "backgroundRed",
    checkShowFun = function()
      return LobbySystem.CheckOpen(BP_ENUM_ROLEINFO_BACKGROUND_SWITCH)
    end
  },
  [ENUM_Type.Opening] = {
    config = UIManager.UI_Config.Personalization_Opening_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Animation_Select_png.Personalization_Icon_Animation_Select_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Personalization_Icon_Animation_png.Personalization_Icon_Animation_png",
    bMatchSize = true,
    reddotKey = "openingRed"
  },
  [ENUM_Type.HomeDoorPlate] = {
    config = UIManager.UI_Config.Personalization_HomeDoorPlate_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Common_Tab_Doorplate_xuangzhong_png.Common_Tab_Doorplate_xuangzhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyPlayerInfoUI/Frames/Common_Tab_Doorplate_png.Common_Tab_Doorplate_png",
    bMatchSize = true,
    reddotKey = "homeDoorPlateRed",
    checkShowFun = function()
      local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
      return logic_home_switch:CheckHomeSwitchOpen(false)
    end
  },
  [ENUM_Type.ChatRoomBG] = {
    config = UIManager.UI_Config.ChatRoom_BG_UIBP,
    activePath = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Room_Xuanzhong_png.Common_Tab_Room_Xuanzhong_png",
    inactivePath = "/Game/UMG/Texture_200/Atlas/LobbyChatUI/Frames/Common_Tab_Room_png.Common_Tab_Room_png",
    bMatchSize = true,
    reddotKey = "chatRoomBGRed"
  }
}
local panelName = "CanvasPanel_Content"
local tlogReportMap = {
  [ENUM_Type.Alias] = TLogEventDefine.PersonSpaceCustomTitle,
  [ENUM_Type.CountryPage] = TLogEventDefine.PersonSpaceCustomBanner,
  [ENUM_Type.Avatar] = TLogEventDefine.PersonSpaceCustomAvatar,
  [ENUM_Type.AvatarFrame] = TLogEventDefine.PersonSpaceCustomAvatarFrame,
  [ENUM_Type.NicknameFrame] = TLogEventDefine.PersonSpaceCustomNickNameEffect,
  [ENUM_Type.NameFrame] = TLogEventDefine.PersonSpaceCustomNameTag,
  [ENUM_Type.CarteFrame] = TLogEventDefine.PersonSpaceCustomInfoCard,
  [ENUM_Type.SocialCardBGFrame] = TLogEventDefine.PersonSpaceCustomSocialCard,
  [ENUM_Type.RoleInfoBG] = TLogEventDefine.PersonSpaceCustomInfomationBG,
  [ENUM_Type.Opening] = TLogEventDefine.PersonSpaceCustomMatchStartAnimation,
  [ENUM_Type.TeamUpFrame] = TLogEventDefine.PersonSpaceCustomInviteWindowTheme,
  [ENUM_Type.ChatFrame] = TLogEventDefine.PersonSpaceCustomChatBubble,
  [ENUM_Type.HomeDoorPlate] = TLogEventDefine.PersonSpaceCustomShareHomeDoorplate,
  [ENUM_Type.NicknameColor] = TLogEventDefine.PersonSpaceCustomCollectionNickname,
  [ENUM_Type.ChatRoomBG] = TLogEventDefine.PersonSpaceCustomChatRoomBG,
  [ENUM_Type.LightBoard] = TLogEventDefine.PersonSpaceCustomLightBoard
}
local Personalization_UIBP = {}
local TabIndex2Type = {}
local ReddotData = {}
local clickInfo = {}
function Personalization_UIBP:ctor(_, extraData)
  local subTabType
  if extraData then
    if extraData.openTab then
      subTabType = tonumber(extraData.openTab)
    end
    self.itemID = tonumber(extraData.itemID)
  end
  self.type = subTabType
  self.childUI = nil
  self._titleTab = 0
  self.avatarFrameWidget = nil
  self._uObj_avatarAdaptWorldPos = nil
  self._uObj_avatarAdaptWorldDir = nil
  self.isShowAvatarScene = false
  self.lastSelectedTabIndex = 0
  self._tAvatarShowCfg = {
    UseCacheData = true,
    bCheckIsShow = true,
    bIsShowCar = true,
    nSourceType = Enum_AvatarShowSource.Personalization_UIBP
  }
end
function Personalization_UIBP:OnInitialize()
  Personalization_UIBP.__super.OnInitialize(self)
  self.verticalIconTab = self:InitVerticalIconTab(self.UIRoot.Common_Tab_Vertical_LevelTwo_Icon_UIBP, true, true)
end
function Personalization_UIBP:RegistEvents()
  Personalization_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_COUPLE_AVATAR, EVENTID_LOBBY_SOCIAL_UPDATE_AVATAR, self.AdaptAvatar, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_CLOSE_ALL, self.CloseUI, self)
  self.verticalIconTab:AddOnTabSelectedCallback(self.TabItemClicked, self)
  self.verticalIconTab:AddOnTabRefreshCallback(self.TabItemRefresh, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_ALIAS_ENTER_BROADCAST, self.ShowAliasEnterBroadcast, self)
  self:AddCommonEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_ALIAS_CLEAR_ENTER_BROADCAST, self.OnRoleInfoAliasClearBroadCastEvent, self)
end
function Personalization_UIBP:OnPostInitialize()
  Personalization_UIBP.__super.OnPostInitialize(self)
  if DataMgr.roleData.total_devote == 0 then
    local RoleInfoPopularitySystem = require("client.slua.logic.person_space.logic_roleinfo_popularity")
    RoleInfoPopularitySystem.get_popularity_req(DataMgr.roleData.uid, RoleInfoPopularitySystem.EPopularityScene.Personize)
  end
end
function Personalization_UIBP:OnShow()
  Personalization_UIBP.__super.OnShow(self)
  ReddotData = {}
  TabIndex2Type = {}
  local allTabs = {
    ENUM_Type.Alias,
    ENUM_Type.CountryPage,
    ENUM_Type.Avatar,
    ENUM_Type.AvatarFrame,
    ENUM_Type.LightBoard,
    ENUM_Type.NicknameFrame,
    ENUM_Type.NameFrame,
    ENUM_Type.CarteFrame,
    ENUM_Type.SocialCardBGFrame,
    ENUM_Type.RoleInfoBG,
    ENUM_Type.Opening,
    ENUM_Type.TeamUpFrame,
    ENUM_Type.ChatFrame,
    ENUM_Type.HomeDoorPlate,
    ENUM_Type.NicknameColor,
    ENUM_Type.ChatRoomBG
  }
  for k, v in ipairs(allTabs) do
    if TabCfg[v].checkShowFun then
      if TabCfg[v].checkShowFun() then
        table.insert(TabIndex2Type, v)
      end
    else
      table.insert(TabIndex2Type, v)
    end
  end
  if not self.type then
    self.type = TabIndex2Type[1]
  end
  self:UpdateTabData()
  self:OnCheckChange(true, self.type)
end
function Personalization_UIBP:CloseUI()
  self:CloseAll()
  UIManager.CloseUI(UIManager.UI_Config.roleinfo_main)
end
function Personalization_UIBP:ReqAvatarShowInfo(uObj_widget)
  local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
  local curRoleId = RoleInfoSystem.CurShowPlayerInfoUid
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(CoupleAvatarSystem.ESceneType.RoleInfo)
  self:AddTimerOnce(0, function()
    self:SetAvatarAdaptWidget(uObj_widget)
    CoupleAvatar:UpdateAvatar(curRoleId, self._tAvatarShowCfg)
  end)
end
function Personalization_UIBP:LoadAvatarScene()
  self.isShowAvatarScene = true
  self:SetPanelBgVisible(false)
  local Lobby_camera_manager_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Lobby_camera_manager_module)
  Lobby_camera_manager_module:SwitchCamera(40035)
  local callback = function()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_SCENE_LOADED)
  end
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UpdatePlayerEquipBGLevel(DataMgr.roleData.uid, callback)
end
function Personalization_UIBP:UnloadAvatarScene()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UnloadCurrentRoleInfoBGLevel(true)
  self.isShowAvatarScene = false
end
function Personalization_UIBP:DestroyPlayerAvatar()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.RoleInfo)
end
function Personalization_UIBP:SetAvatarAdaptWidget(uObj_widget)
  self.avatarFrameWidget = uObj_widget
  if not uObj_widget then
    self._uObj_avatarAdaptWorldPos = nil
    self._uObj_avatarAdaptWorldDir = nil
    return
  end
  local UIUtil = require("client.common.ui_util")
  local ViewportPos = UIUtil.GetWidgetViewportPosInNormalized(uObj_widget, 0.5, 0.5)
  local uObj_worldPos, uObj_worldDir = UIUtil.DeprojectScreenToWorld(ViewportPos)
  self._uObj_avatarAdaptWorldPos = uObj_worldPos
  self._uObj_avatarAdaptWorldDir = uObj_worldDir
end
function Personalization_UIBP:GetAvatarCenterX(pawn)
  if not (pawn and self.avatarFrameWidget) or not slua.isValid(self.avatarFrameWidget) then
    return
  end
  if not self._uObj_avatarAdaptWorldDir or not self._uObj_avatarAdaptWorldDir then
    return
  end
  local UIUtil = require("client.common.ui_util")
  local bIsSuc, intersection = UIUtil.RayIntersectPlane(self._uObj_avatarAdaptWorldPos, self._uObj_avatarAdaptWorldDir, pawn:K2_GetActorLocation(), FVector(0, 1, 0))
  if not bIsSuc then
    return
  end
  return intersection and intersection.X
end
function Personalization_UIBP:AdaptAvatar()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(CoupleAvatarSystem.ESceneType.RoleInfo)
  local CoupleAvatarConfig = require("client.slua.logic.lobby.Left.CoupleAvatarConfig")
  local uObj_avatar = CoupleAvatar:GetModel(CoupleAvatarConfig.AvatarType.Self)
  if not uObj_avatar then
    return
  end
  local x = self:GetAvatarCenterX(uObj_avatar)
  if x then
    local Old = uObj_avatar:K2_GetActorLocation()
    Old.X = x
    uObj_avatar:K2_SetActorLocation(Old, false, nil, false)
  end
end
function Personalization_UIBP:SetPanelBgVisible(visible)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Bg, visible, false)
end
function Personalization_UIBP:ShowAliasEnterBroadcast(_, _, AliasID)
  self:ClearAliasEnterBroadcast()
  if not self.EnterBroadcastUI then
    self.EnterBroadcastUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_Center, UIManager.UI_Config.EnterBroadcastItem)
  end
  self.EnterBroadcastUI:SetAnchors(0.5, 0.5, 0.5, 0.5)
  local Msg = FuncUtil.GenEnterBroadcastMsg(AliasID)
  self.EnterBroadcastUI:UpdateUI({AliasID = AliasID, Msg = Msg})
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.RoleInfo)
  if CoupleAvatar then
    CoupleAvatar:HideAvatars()
  end
end
function Personalization_UIBP:ClearAliasEnterBroadcast()
  if self.EnterBroadcastUI then
    self.EnterBroadcastUI:Close()
    self.EnterBroadcastUI = nil
  end
end
function Personalization_UIBP:OnRoleInfoAliasClearBroadCastEvent(_, _)
  self:ClearAliasEnterBroadcast()
  local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
  local CoupleAvatar = CoupleAvatarSystem:GetCoupleAvatar(CoupleAvatarSystem.ESceneType.RoleInfo)
  if CoupleAvatar then
    local RoleInfoSystem = require("client.logic.roleinfo.logic_roleinfo")
    local nCurRoleId = RoleInfoSystem.CurShowPlayerInfoUid
    CoupleAvatar:UpdateAvatar(nCurRoleId, self._tAvatarShowCfg)
  end
end
function Personalization_UIBP:UpdateTabData()
  if self.verticalIconTab == nil then
    return
  end
  local initTabIdx = 1
  local tabIcons = {}
  local roleinfo_red_data = require("client.logic.roleinfo.roleinfo_red_data")
  roleinfo_red_data.RefreshAll()
  for k, v in pairs(TabIndex2Type) do
    if v == self.type then
      initTabIdx = k
    end
    if TabCfg[v] then
      local cfg = TabCfg[v]
      table.insert(tabIcons, cfg)
      local reddotData = roleinfo_red_data.GetSuperData()
      if cfg and cfg.reddotKey and reddotData[cfg.reddotKey] ~= nil then
        log(bWriteLog and string.format("Personalization_UIBP:UpdateRedPoint AddDataListener, key [%s] ", v))
        self:UpdateReddotByEnumType(v, reddotData[cfg.reddotKey])
        self:AddDataListener(reddotData, cfg.reddotKey, function()
          local value = reddotData[cfg.reddotKey]
          log(bWriteLog and string.format("Personalization_UIBP:UpdateRedPoint ReddotChange, key [%s], value = %s ", v, tostring(value)))
          self:UpdateReddotByEnumType(v, value)
          self.verticalIconTab.LoopScrollBox_Tab:RefreshItem(k)
        end)
      end
    end
  end
  self.verticalIconTab:SetTabs(tabIcons, initTabIdx)
  self.verticalIconTab.LoopScrollBox_Tab:ScrollToItem(initTabIdx)
end
function Personalization_UIBP:Close()
  local CountryAreaSystem = require("client.slua.logic.country_area.logic_country_area")
  CountryAreaSystem.IsUseFlag = false
  CountryAreaSystem.IsFlagJump = false
  Personalization_UIBP.__super.Close(self)
end
function Personalization_UIBP:TabItemRefresh(widget, index)
  log(bWriteLog and "RoleInfo_Main:TabItemRefresh, index = " .. tostring(index))
  local data = self.verticalIconTab:GetTabData(index)
  if not data then
    return
  end
  local curType = TabIndex2Type[index]
  self:SetWidgetVisible(widget.Image_Reddot_01, ReddotData[curType] == true)
end
function Personalization_UIBP:TabItemClicked(widget, index)
  self.playFadein = widget == 0
  local UIUtil = require("client.common.ui_util")
  local curType = TabIndex2Type[index]
  local info = clickInfo[curType]
  if info == nil then
    info = {1, 0}
    clickInfo[curType] = info
  end
  if UIUtil.CanClickNow(info) then
    self.lastSelectedTabIndex = index
    self:OnCheckChange(false, curType)
    local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
    tlog_report_utils.ReportTLogEvent(tlogReportMap[curType])
  else
    self.verticalIconTab.LoopScrollBox_Tab:Select(self.lastSelectedTabIndex)
  end
end
function Personalization_UIBP:GetTypeConfig()
  if not TabCfg[self.type] then
    log(bWriteLog and "PersonalizationMain:GetTypeConfig return nil. type == " .. self.type)
    return nil
  end
  return TabCfg[self.type].config
end
function Personalization_UIBP:ShowMainUI(jumpItemId)
  local RoleInfoAvatarFrameSystem = require("client.slua.logic.roleInfo.logic_RoleInfoAvatarFrame")
  local ui = self:CreateChildWindow(panelName, self:GetTypeConfig(), jumpItemId)
  RoleInfoAvatarFrameSystem.get_avatar_box_list()
  return ui
end
function Personalization_UIBP:GetDataForJumpBack()
  return {
    ctorData = {
      [1] = self.type
    }
  }
end
function Personalization_UIBP:OnCheckChange(isInit, type, isCheck)
  self:PlayAudio(sound_config.click)
  if self.type ~= type or isInit then
    log(bWriteLog and "RoleInfo_Main:OnCheckChange " .. type)
    if not self.UIRoot then
      return
    end
    if self.childUI then
      self.childUI:CloseSelf()
      self.childUI = nil
    end
    self.    local childUI
    if self.type == ENUM_Type.AvatarFrame then
      childUI = self:ShowMainUI(self.itemID)
    elseif self.type == ENUM_Type.CountryPage then
      childUI = self:CreateChildWindow(panelName, self:GetTypeConfig(), 1, DataMgr.roleData.nation)
    elseif self.type == ENUM_Type.Alias then
      childUI = self:CreateChildWindow(panelName, self:GetTypeConfig(), self.itemID, self.type)
    elseif self.type == ENUM_Type.TeamUpFrame then
      local tlog_report_utils = require("client.slua.config.tlog.tlog_report_utils")
      tlog_report_utils.ReportTLogEvent(TLogEventDefine.TeamInvite_Skin_UI_Click)
      childUI = self:CreateChildWindow(panelName, self:GetTypeConfig(), self.itemID)
    else
      local typeConfig = self:GetTypeConfig()
      if not typeConfig then
        log(bWriteLog and "Personalization_UIBP:OnCheckChange typeConfig is nil for type: " .. tostring(self.type))
        return
      end
      childUI = self:CreateChildWindow(panelName, typeConfig, self.itemID)
    end
    self.    self.itemID = nil
    if self.UIRoot.Image_0 then
      local bHideBg = self.type == ENUM_Type.Alias or self.type == ENUM_Type.RoleInfoBG
      self:SetWidgetVisible(self.UIRoot.Image_0, not bHideBg)
    end
  else
    log(bWriteLog and "RoleInfo_Main:OnCheckChange return " .. type)
    return
  end
end
function Personalization_UIBP:CloseAll()
  self:CloseSelf()
end
function Personalization_UIBP:OnClose()
  if self.isShowAvatarScene then
    self:UnloadAvatarScene()
  end
  self:DestroyPlayerAvatar()
  Personalization_UIBP.__super.OnClose(self)
end
function Personalization_UIBP:UpdateReddotByEnumType(type, bShouldShowReddot)
  ReddotData[type] = bShouldShowReddot
end
function Personalization_UIBP:GetDataForJumpBack()
  return {
    ctorData = {
      [1] = self.type
    }
  }
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CUITemplate = class(ui_base, nil, Personalization_UIBP)
return CUITemplate