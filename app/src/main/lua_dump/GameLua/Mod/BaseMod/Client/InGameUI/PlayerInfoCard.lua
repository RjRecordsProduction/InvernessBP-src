local PlayerInfoCard = {}
local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
local C_ModeMap = {
  [1] = "solo",
  [2] = "duo",
  [3] = "squad",
  [4] = "fppsolo",
  [5] = "fppduo",
  [6] = "fppsquad"
}
function PlayerInfoCard:ctor(selfType, UID)
  self.uid = UID
  self._tCoupleAvatarCfg = {UseCacheData = true}
end
function PlayerInfoCard:OnPostInitialize()
  PlayerInfoCard.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function PlayerInfoCard:UpdateUI()
  if not self.UIRoot then
    return
  end
  self:SetWidgetVisible(self.UIRoot.Image_Nation, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_6, false)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_AddFavourite, false)
  self.UIRoot.Text_PlayerName:SetText("")
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  self.uid = IngameLikeClientSubSystem.playerCardId
  self:DisplayAvatarByUid(self.uid)
  print(bWriteLog and "PlayerInfoCard:OnPostInitialize" .. tostring(self.uid))
  local EWidgetVisible = import("EWidgetVisible")
  self.UIRoot:SetWidgetRender(EWidgetVisible.ForceVisible)
  if LobbySystem.roleData.all_gray_switch and not LobbySystem.roleData.all_gray_switch[1] then
    print(bWriteLog and "PlayerInfoCard:OnPostInitialize all_gray_switch return")
    self.UIRoot.WidgetSwitcher_DataPanel:SetActiveWidgetIndex(2)
    return
  end
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(self.uid)
  if profile and profile.rankdata then
    self:SetCombatTotalInfoByProfile(profile)
  else
    local logic_profile_get_wrap = require("client.slua.logic.user.profile.logic_profile_get_wrap")
    logic_profile_get_wrap.GetRankProfiles(Enum_PROFILE_REPORT_CFG.INGAME_SOCIAL, {
      self.uid
    }, function(list)
      if not self.UIRoot then
        print(bWriteLog and "PlayerInfoCard:Profile rsp no UIRoot")
        return
      end
      for j, currProfile in pairs(list) do
        if tonumber(self.uid) == tonumber(currProfile.uid) and currProfile.rankdata then
          self:SetCombatTotalInfoByProfile(currProfile)
          return
        end
      end
      print(bWriteLog and "PlayerInfoCard:Profile rsp no result")
      log_tree("PlayerInfoCard:Profile", list)
    end)
  end
end
function PlayerInfoCard:SetPlayerInfo(uid)
  self.  self:UpdateUI()
end
function PlayerInfoCard:RegistEvents()
  PlayerInfoCard.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_OBSERVING, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.CloseSelf, self)
end
function PlayerInfoCard:DisplayAvatar(bIsEnable, PlayerCharacter)
  if not slua.isValid(PlayerCharacter) then
    print(bWriteLog and "PlayerInfoCard:DisplayAvatar return invalid PlayerCharacter " .. tostring(PlayerCharacter))
    return
  end
  if bIsEnable then
    self:ShowSpectatePlayerInfo()
  else
    self:HideSpectatePlayerInfo()
  end
  local AvatarCaptureInfo = self:GetAvatarCaptureInfo()
  if not slua.isValid(AvatarCaptureInfo) then
    print(bWriteLog and "PlayerInfoCard:DisplayAvatar return invalid AvatarCaptureInfo")
    return
  end
  print(bWriteLog and "PlayerInfoCard:DisplayAvatar")
  AvatarCaptureInfo:DisplayAvatarWithComponent(bIsEnable, PlayerCharacter.CharacterAvatarComp2_BP, nil)
  if bIsEnable then
    self:RefreshAllItemsInfo()
    local GameInstance = slua_GameFrontendHUD:GetGameInstance()
    if slua.isValid(GameInstance) and GameInstance.IsOpenHDR then
      self:SwitchHDRInner(GameInstance:IsOpenHDR())
    end
  end
  self.UIRoot.CustomScrollBox_0:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
end
function PlayerInfoCard:SetCombatTotalInfoByProfile(profile)
  PlayerInfoCard.__super.SetCombatTotalInfo(self)
  if not profile then
    print(bWriteLog and "PlayerInfoCard:SetCombatTotalInfoByProfile profile return")
    return
  end
  self.UIRoot.Text_PlayerName:SetText(profile.nickName)
  self:SetNation(profile.nation)
  if not profile.social_private_data or profile.social_private_data[3] == 0 or profile.social_private_data[2] == 0 then
    self.UIRoot.WidgetSwitcher_DataPanel:SetActiveWidgetIndex(2)
    print(bWriteLog and "PlayerInfoCard:SetCombatTotalInfoByProfile switch return")
    return
  end
  if GamePlayTools.IsBlueHoleVersion() then
    self:SetWidgetVisible(self.UIRoot.Image_Nation, false)
  else
    self:SetWidgetVisible(self.UIRoot.Image_Nation, true)
  end
  local ClientGameMain = require("GameLua.GameCore.Main.ClientGameMain")
  local bHideDeathPlaybackDetail = ClientGameMain.GetUIOtherSetting("bHideDeathPlaybackDetail")
  print(bWriteLog and "PlayerInfoCard:SetCombatTotalInfoByProfile bHideDeathPlaybackDetail", bHideDeathPlaybackDetail)
  if bHideDeathPlaybackDetail == true then
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_6, false)
  else
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_6, true)
  end
  print(bWriteLog and "PlayerInfoCard:SetCombatTotalInfoByProfile " .. tostring(profile.social_private_data[2]) .. "" .. tostring(profile.social_private_data[3]))
  if profile.upass_is_show == 1 then
    local upass = profile.upass
    self.UIRoot.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.UnknowPass_ContinuousBuy_BP:SetTypeData(0, profile.upass.keep_buy or 0, 0 < upass.is_buy, 0, upass.cur_value or 0, upass.pass_type or 0)
  else
    self.UIRoot.UnknowPass_ContinuousBuy_BP:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  if profile.social_private_data[2] == 1 then
    self.UIRoot.WidgetSwitcher_DataPanel:SetActiveWidgetIndex(0)
    local logic_segment_title = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_segment_title)
    local maxSegment, maxZoneId, maxModeId = logic_segment_title:GetMaxSegementLevelWithZoneAndModeId(profile.segment_info)
    local maxRankData = profile.rankdata[maxZoneId][C_ModeMap[maxModeId]]
    if not maxRankData then
      return
    end
    local KDNum = math.ceil(maxRankData.kd * 100) / 100
    self.UIRoot.TextBlock_KDNum:SetText(KDNum)
    self.UIRoot.TextBlock_KillNum:SetText(maxRankData.kill_num or 0)
    self.UIRoot.TextBlock_WinCount:SetText(maxRankData.win_num or 0)
    self.UIRoot.TextBlock_GameCount:SetText(maxRankData.game_num or 0)
    self.UIRoot.TextBlock_TopTenCount:SetText(maxRankData.top10_count or 0)
  else
    self.UIRoot.WidgetSwitcher_DataPanel:SetActiveWidgetIndex(1)
    local logic_recommend_labels = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_recommend_labels)
    local labels = logic_recommend_labels:GetLableConfigList(profile.all_show_labels)
    local labelText = ""
    if labels and next(labels) then
      for _, lableConfig in pairs(labels) do
        if labelText ~= "" then
          labelText = labelText .. "\227\128\129"
        end
        labelText = labelText .. lableConfig.LabelText
      end
    end
    self.UIRoot.TextBlock_38:SetText(labelText)
    if profile.evaluation.privacy ~= 2 or not profile.evaluation.score then
      self.UIRoot.TextBlock_26:SetText(LocUtil.GetLocalizeResStr(505021))
      self.UIRoot.TextBlock_35:SetText(LocUtil.GetLocalizeResStr(505021))
    else
      self.UIRoot.TextBlock_26:SetText(profile.evaluation.score)
      local logic_team_evaluation_view = require("client.slua.logic.team_evaluation.logic_team_evaluation_view")
      labelText = ""
      if profile.evaluation.labels and next(profile.evaluation.labels) then
        for k, v in pairs(profile.evaluation.labels) do
          local labelCfg = logic_team_evaluation_view.GetLabelByID(k)
          if labelCfg then
            if labelText ~= "" then
              labelText = labelText .. "\227\128\129"
            end
            labelText = labelText .. labelCfg.show_name
          end
        end
      end
      self.UIRoot.TextBlock_35:SetText(labelText)
    end
  end
end
function PlayerInfoCard:DisplayAvatarByUid(uid)
  self.avatarUid = uid
  local isFin = self:DisplayAvatarByRoleData(uid)
  if not isFin then
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    BasicDataAvatarWearInfo:GetOrReqData(uid, function(callUid, callInfo)
      self:DisplayAvatarByRoleData(callUid)
    end, nil, Enum_AvatarShowSource.PlayerInfoCard)
  end
end
function PlayerInfoCard:DisplayAvatarByRoleData(uid)
  local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
  local data = BasicDataAvatarWearInfo:GetCacheData(uid)
  if data then
    local CoupleAvatarSystem = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.CoupleAvatarSystem)
    CoupleAvatarSystem:DestoryCoupleAvatar(CoupleAvatarSystem.ESceneType.Upass)
    local CoupleAvatar = CoupleAvatarSystem:GetOrCreateCoupleAvatar(CoupleAvatarSystem.ESceneType.Upass)
    CoupleAvatar:UpdateAvatar(uid, self._tCoupleAvatarCfg)
    self:DisplayAvatar(true, CoupleAvatar:GetModel(1))
    self:RefreshCorder(data.wear)
    print(bWriteLog and "PlayerInfoCard:DisplayAvatarByRoleData true")
    return true
  else
    print(bWriteLog and "PlayerInfoCard:DisplayAvatarByRoleData false")
    return false
  end
end
function PlayerInfoCard:OnClose()
  self.UIRoot.WidgetSwitcher_DataPanel:SetActiveWidgetIndex(0)
  if slua.isValid(self.UIRoot) then
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_AddFavourite, true)
  PlayerInfoCard.__super.OnClose(self)
end
local class = require("class")
local UIBase = require("GameLua.Mod.BaseMod.Client.InGameUI.PlayerInfoCardBaseUI")
return class(UIBase, nil, PlayerInfoCard)