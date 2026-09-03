local LobbyChat_InformationCustomProfile_UIBP = {}
function LobbyChat_InformationCustomProfile_UIBP:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_0, self.OnClickButtonSelect, self)
end
function LobbyChat_InformationCustomProfile_UIBP:OnInitialize()
  local UIComponentModule = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.UIComponentModule)
  self.LobbyChat_InformationCustomDetail_UIBP = UIComponentModule:InitWithParentComponent(self, UIComponentModule.Config.LobbyChat_InformationCustomDetail_UIBP, self.UIRoot.LobbyChat_InformationCustomDetail_UIBP)
  self.needDownloadPakNames = {}
end
function LobbyChat_InformationCustomProfile_UIBP:OnPostInitialize()
  self:UpdateUI()
  self:UpdateCardSkin()
end
function LobbyChat_InformationCustomProfile_UIBP:OnShow()
  if self.LobbyChat_InformationCustomDetail_UIBP then
    self.LobbyChat_InformationCustomDetail_UIBP:SetEdit(true)
  end
end
function LobbyChat_InformationCustomProfile_UIBP:OnHide()
end
function LobbyChat_InformationCustomProfile_UIBP:OnClose()
  if self.LobbyChat_InformationCustomDetail_UIBP then
    self.LobbyChat_InformationCustomDetail_UIBP:OnClose()
  end
end
function LobbyChat_InformationCustomProfile_UIBP:UpdateUI()
  self:UpdateBasicInfo()
end
function LobbyChat_InformationCustomProfile_UIBP:InitList()
end
function LobbyChat_InformationCustomProfile_UIBP:UpdateBasicInfo()
  local LobbySocialSystem = require("client.slua.logic.lobby.Left.logic_lobby_social")
  local profile = LobbySocialSystem.GetProfileByUID(tonumber(DataMgr.roleData.uid))
  if not profile then
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:UpdateBasicInfo profile info is invalid with uid " .. tostring(self.uid))
    return
  end
  self.UIRoot.Common_Avatar_BP:InitView(1, uid, profile.picUrl, profile.sex, profile.cur_avatar_box_id, profile.level, false, "")
  self.UIRoot.Common_Avatar_BP:SetWidgetVisibility(UEnums.ESlateVisibility.HitTestInvisible)
  local maxRank = FuncUtil.GetCurMaxSegementLevel(profile.segment_info)
  local color = FSlateColor(FLinearColor(0, 0, 0, 1))
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor(color)
  self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:SetRankInteral(maxRank, nil)
  local UIUtil = require("client.common.ui_util")
  UIUtil.UpdateNationImage(self.UIRoot.Image_Flag, profile.nation)
  if profile.social_card and type(profile.social_card) == "table" and self.UIRoot.Common_Gender_UIBP then
    self.UIRoot.Common_Gender_UIBP:LoadIcon(self.uid)
  else
    log(bWriteLog and "Lobby_RoleInfo_Card_UIBP:UpdateBasicInfo profile.social_card is invalid")
  end
  self.UIRoot.Text_Name:SetText(profile.nickName or "")
  self.UIRoot.Common_LightBoard_UIBP:ShowLightBoard(DataMgr.roleData.uid)
  self.UIRoot.Common_Certification_UIBP:SetAuthInfo(profile.auth_type, profile.auth_end_time)
  self.UIRoot.Platform:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local platformIcon = UIUtil.GetPlatformlIcon(uid)
  if platformIcon then
    self:SetTexture(self.UIRoot.Image_Platform, platformIcon)
    self.UIRoot.Platform:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  if profile.corps_id == 0 or profile.corps_id == nil then
    self:SetWidgetVisible(self.UIRoot.Image_icon_juntuan, false)
    self:SetWidgetVisible(self.UIRoot.txt_juntuan, false)
    self.UIRoot.WidgetSwitcher_Corps:SetActiveWidgetIndex(1)
  else
    self.UIRoot.WidgetSwitcher_Corps:SetActiveWidgetIndex(0)
    local corps_summary = LobbySocialSystem.CacheCorpsSummary[profile.corps_id] or {}
    self:SetWidgetVisible(self.UIRoot.Image_icon_juntuan, true)
    self:SetWidgetVisible(self.UIRoot.txt_juntuan, true)
    self.UIRoot.txt_juntuan:SetText(LocUtil.LocalizeResFormat(5085))
    self.UIRoot.txt_juntuan:SetText(corps_summary.name or "")
    local cfg = CDataTable.GetTableData("corps_alias_table", profile.corp_alias_id)
    if cfg then
      if cfg.Default == 1 then
        self.UIRoot.WidgetSwitcher_5:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        local pos = corps_summary.position or 0
        if pos == 0 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(3)
        elseif pos == 1 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(0)
        elseif pos == 2 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(1)
        elseif pos == 3 then
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(2)
        else
          self.UIRoot.WidgetSwitcher_5:SetActiveWidgetIndex(3)
        end
      else
        self.UIRoot.WidgetSwitcher_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
        self.UIRoot["aliasName" .. cfg.background]:SetText(cfg.CorpAliasName)
        self.UIRoot.WidgetSwitcher_21:SetActiveWidgetIndex(cfg.background - 1)
      end
    else
      self.UIRoot.WidgetSwitcher_5:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.UIRoot.WidgetSwitcher_21:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    end
    local icon_path = "/Game/UMG/Texture/Atlas/LobbyPlayerInfoUI/Frames/Players_icon_xiangqing_png"
    if corps_summary.icon ~= nil and 0 < corps_summary.icon then
      local corpIDConf = CDataTable.GetTableData("CorpsBadge", tonumber(corps_summary.icon))
      if corpIDConf ~= nil then
        icon_path = corpIDConf.IconPath
      end
    end
    self:SetTexture(self.UIRoot.Image_icon_juntuan, icon_path)
  end
  local logic_friend_list = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.logic_friend_list)
  local intimacy = logic_friend_list:GetIntimacy(tonumber(DataMgr.roleData.uid)) or 0
  self.UIRoot.Text_Intimacy:SetText(tostring(intimacy))
  self:SetWidgetVisible(self.UIRoot.Button_Fire, true, false)
  local frd_uid = tonumber(DataMgr.roleData.uid)
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  local texturePath, _, interactionScore = logic_interaction:GetIconInfoByID(frd_uid)
  if texturePath and interactionScore and 0 < interactionScore then
    self:SetWidgetVisible(self.UIRoot.Button_Fire, true, false)
    self:SetTexture(self.UIRoot.Image_Scintilla, texturePath)
    self.UIRoot.TextBlock_2:SetText(interactionScore)
  else
    self:SetWidgetVisible(self.UIRoot.Button_Fire, false, false)
  end
end
function LobbyChat_InformationCustomProfile_UIBP:GetAllItemData()
  if self.LobbyChat_InformationCustomDetail_UIBP then
    return self.LobbyChat_InformationCustomDetail_UIBP:GetAllItemData()
  end
end
function LobbyChat_InformationCustomProfile_UIBP:OnClickButtonSelect()
  self:PlayAudio(sound_config.click_v1)
  UIManager.CloseUI(UIManager.UI_Config.Lobby_RoleInfo_CustomInformation_Popup_UIBP)
  local RoleInfoMainSystem = require("client.logic.roleinfo.logic_new_roleinfo")
  local PersonalizationConst = require("client.slua.umg.roleInfoNew.PersonalizationConst")
  RoleInfoMainSystem.Show(RoleInfoMainSystem.Personalize, RoleInfoMainSystem.RoleInfoOpenFromType.Null, DataMgr.roleData.uid, {
    personalInfo = {
      openTab = PersonalizationConst.ENUM_Type.CarteFrame
    }
  })
end
function LobbyChat_InformationCustomProfile_UIBP:UpdateCardSkin()
  self.isShowSkin = false
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile_info = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if not profile_info then
    return
  end
  local logic_social_card = require("client.slua.logic.lobby.Left.logic_social_card")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local carte_frame_equip_id = logic_social_card.GetCarteFrameEquipIdByProfile(profile_info)
  if carte_frame_equip_id then
    local downloadArr = {}
    local logic_roleinfo_carte_frame = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleinfo_carte_frame)
    local effect_bp_path, skin_path, _, bLoopAnim = logic_roleinfo_carte_frame:GetSkinPath(carte_frame_equip_id)
    local pak_util = require("client.common.pak_util")
    log_format(bWriteLog and "ChatMenu_BP:GetProfileRsp effect_bp_path=%s", effect_bp_path)
    if effect_bp_path and effect_bp_path ~= "" and pak_util.IsFileExist(effect_bp_path) then
      self:ClearCarteSkin()
      self.isShowSkin = true
      self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(1)
      local uiConfig = UIManager.UI_Config.Lobby_RoleInfo_EffectSkin_Item_UIBP
      local aniName
      if bLoopAnim then
        aniName = "Auto_Loop"
      end
      local extraData = {}
      local item_data = logic_roleinfo_carte_frame:GetCrateFrameBGCfg(carte_frame_equip_id)
      if item_data and item_data.Level == 3 then
        extraData.bEnableGyroscope = true
      end
      self.card_skin_bp = self:CreateChildWindowWithBpPath("CanvasPanel_Effect_002", uiConfig, effect_bp_path, aniName, extraData)
    else
      local bpPakName = PufferManager.GetPakName(effect_bp_path)
      log_format("ChatMenu_BP:GetProfileRsp. bpPakName=%s", bpPakName)
      if bpPakName ~= "" then
        self.needDownloadPakNames[bpPakName] = true
        table.insert(downloadArr, bpPakName)
      end
      log_format(bWriteLog and "ChatMenu_BP:GetProfileRsp effect_bp_path file not exist", effect_bp_path)
      self.UIRoot.WidgetSwitcher_Effect:SetActiveWidgetIndex(0)
    end
    log_format(bWriteLog and "ChatMenu_BP:GetProfileRsp skin_path=%s", skin_path)
    if skin_path and skin_path ~= "" then
      local skin_download_success = function(texture, path)
        if slua.isValid(self.UIRoot) then
          self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
          self:SetTexture(self.UIRoot.Image_bg_001, path)
        end
      end
      local ret = self:SetTexture(self.UIRoot.Image_bg_001, skin_path, {onDownloadSuccess = skin_download_success})
      local SetTextureConst = require("client.slua.logic.image_download.SetTextureConst")
      log_format(bWriteLog and "LobbyChat_InformationCustomProfile_UIBP:UpdateCardSkin SetTexture ret=%s", tostring(ret))
      if ret ~= SetTextureConst.Done then
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
        local pakName = PufferManager.GetPakName(skin_path)
        log_format("ChatMenu_BP:GetProfileRsp. pakName=%s", pakName)
        self.needDownloadPakNames[pakName] = true
      else
        self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(1)
      end
    else
      self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(0)
    end
    if next(downloadArr) then
      local PufferConst = require("client.slua.logic.download.puffer_const")
      PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, downloadArr)
    end
  end
  self:ChangeTextColorBySkin()
end
function LobbyChat_InformationCustomProfile_UIBP:ClearCarteSkin()
  if self.card_skin_bp then
    self.card_skin_bp:Close()
    self.card_skin_bp = nil
  end
end
function LobbyChat_InformationCustomProfile_UIBP:GetAllSpawnItem()
  if self.LobbyChat_InformationCustomDetail_UIBP then
    return self.LobbyChat_InformationCustomDetail_UIBP:GetAllSpawnItem()
  end
end
function LobbyChat_InformationCustomProfile_UIBP:ChangeTextColorBySkin()
  local color
  if self.isShowSkin then
    color = FSlateColor(FLinearColor(1, 1, 1, 1))
  else
    color = FSlateColor(FLinearColor(0, 0, 0, 1))
  end
  self.UIRoot.Text_Platform:SetColorAndOpacity(color)
  self.UIRoot.Text_Name:SetColorAndOpacity(color)
  self.UIRoot.txt_juntuan:SetColorAndOpacity(color)
  self.UIRoot.aliasName1:SetColorAndOpacity(color)
  self.UIRoot.aliasName2:SetColorAndOpacity(color)
  self.UIRoot.aliasName3:SetColorAndOpacity(color)
  self.UIRoot.Text_Commander:SetColorAndOpacity(color)
  self.UIRoot.Text_DeputyCommander:SetColorAndOpacity(color)
  self.UIRoot.Text_Elite:SetColorAndOpacity(color)
  self.UIRoot.Text_Member:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_5:SetColorAndOpacity(color)
  self.UIRoot.Text_Intimacy:SetColorAndOpacity(color)
  self.UIRoot.TextBlock_2:SetColorAndOpacity(color)
  if self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP then
    self.UIRoot.Common_RankIntegralLevel_Style_Small_UIBP:ChangeRankInteralColor(color)
  end
end
function LobbyChat_InformationCustomProfile_UIBP:OnClickOneKeyCreate(ret)
  if self.LobbyChat_InformationCustomDetail_UIBP then
    self.LobbyChat_InformationCustomDetail_UIBP:OnClickOneKeyCreate(ret)
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, LobbyChat_InformationCustomProfile_UIBP)