local logic_suit_multi_shape = {
  CONST_EMPTY_MATCH_ID_LIST = {},
  UNLOCK_COST = 50,
  EXCLUDE_SUIT_ITEM_FOR_POOL = {
    [1407668] = true
  }
}
function logic_suit_multi_shape:DefineAndResetData()
  self._AllShapeData = nil
  self._bGetSelfBindClothInfo = false
  self.bHasUnlockJP = true
  self.SuitID2JumpUrl = nil
  self.bIgnoreDateChecking = false
  log(bWriteLog and "[jump][data] logic_suit_multi_shape:DefineAndResetData. ")
  self:ReqSuitID2JumpUrl()
  self:_InitSuitBelongings()
end
function logic_suit_multi_shape:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_PLAYER_PROFILE, EVENTID_GOT_PROFILE_AVATAR_DATA, self.OnGotAvatarShowDataEvent, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function logic_suit_multi_shape:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("[jump][data] logic_suit_multi_shape:OnPostSwitchGameStatus. pre=%s, nextState=%s", tostring(preState), tostring(nextState)))
  if nextState == GameStatus.Lobby then
    self:ReqSuitID2JumpUrl()
  end
end
function logic_suit_multi_shape:on_get_gold_cloth_bind_info_rsp(bind_info_table, unlock_state)
  log(bWriteLog and string.format("logic_suit_multi_shape:on_get_gold_cloth_bind_info_rsp. bind_info_table=%s, unlock_state=%s", tostring(bind_info_table), tostring(unlock_state)))
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  self._bGetSelfBindClothInfo = true
  local UID = DataMgr.roleData.uid
  if bind_info_table then
    self:SetPlayerBindClothInfo(UID, bind_info_table, true)
  end
  self:SetUnlockState(unlock_state)
end
function logic_suit_multi_shape:on_put_on_gold_dress_bind_rsp(inst_id, head_inst_id, res_id)
  log(bWriteLog and string.format("logic_suit_multi_shape:on_put_on_gold_dress_bind_rsp. inst_id=%s, head_inst_id=%s", tostring(inst_id), tostring(head_inst_id)))
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not inst_id then
    return
  end
  local ResId = self:_GetResIDFromInstID(inst_id) or res_id
  if not ResId then
    return
  end
  local MatchResId = self:_GetResIDFromInstID(head_inst_id)
  self:SetSuitShapeInfo(DataMgr.roleData.uid, ResId, 1, MatchResId)
  EventSystem:postEvent(EVENTTYPE_CHANGE_HEAD, EVENTID_CHANGE_HEAD_STATUS_RSP, ResId, MatchResId)
end
function logic_suit_multi_shape:on_put_off_gold_dress_bind_rsp(inst_id)
  log(bWriteLog and string.format("logic_suit_multi_shape:on_put_off_gold_dress_bind_rsp. inst_id=%s", tostring(inst_id)))
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not inst_id then
    return
  end
  local ResId = self:_GetResIDFromInstID(inst_id)
  if not ResId then
    return
  end
  self:SetSuitShapeInfo(DataMgr.roleData.uid, ResId, nil, nil)
  EventSystem:postEvent(EVENTTYPE_CHANGE_HEAD, EVENTID_CHANGE_HEAD_STATUS_RSP, ResId, nil)
end
function logic_suit_multi_shape:SetPlayerBindClothInfo(UID, bind_info_table, bKeyIsInstID)
  log(bWriteLog and "logic_suit_multi_shape:SetPlayerBindClothInfo. ")
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not UID then
    log(bWriteLog and "logic_suit_multi_shape:SetPlayerBindClothInfo, UID is invalid.")
    return
  end
  if not bind_info_table then
    log(bWriteLog and "logic_suit_multi_shape:SetPlayerBindClothInfo, bind_info_table")
    return
  end
  UID = tostring(UID)
  if not self._AllShapeData then
    self._AllShapeData = {}
  end
  if not self._AllShapeData[UID] then
    self._AllShapeData[UID] = {}
  end
  local bConvertInstID2ResID = bKeyIsInstID and UID == DataMgr.roleData.uid
  local EAvatarShapeType = import("ECharacterAvatarShapeType")
  for k, v in pairs(bind_info_table) do
    local ResID, MappedSuitResID = k, v
    if bConvertInstID2ResID then
      ResID = self:_GetResIDFromInstID(k)
      MappedSuitResID = self:_GetResIDFromInstID(v)
    end
    if ResID then
      self:SetSuitShapeInfo(UID, ResID, EAvatarShapeType.ECharacterAvatarShapeType_SuitChangeHead, MappedSuitResID)
    end
  end
end
function logic_suit_multi_shape:on_unlock_gold_dress_bind_rsp()
  ShowNotice(7165)
  self:SetUnlockState(true)
end
function logic_suit_multi_shape:on_get_item_jump_info_by_itemlist_rsp(ret_tbl)
  if not ret_tbl then
    return
  end
  self:AppendSuitJumpUrlCfg(ret_tbl)
end
function logic_suit_multi_shape:SetSuitShapeInfo(UID, SuitItemID, ShapeType, ShapeID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not UID then
    log(bWriteLog and "logic_suit_multi_shape:SetSuitShapeInfo, UID is nil")
    return
  end
  if not SuitItemID then
    log(bWriteLog and "logic_suit_multi_shape:SetSuitShapeInfo, SuitItemID is invalid.")
    return
  end
  UID = tostring(UID)
  if not self._AllShapeData then
    self._AllShapeData = {}
  end
  if not self._AllShapeData[UID] then
    self._AllShapeData[UID] = {}
  end
  if not ShapeType or not ShapeID then
    self._AllShapeData[UID][SuitItemID] = nil
  else
    self._AllShapeData[UID][SuitItemID] = {ShapeType = ShapeType, ShapeID = ShapeID}
  end
  self:_UpdateTeamAvatarShapeInfo(UID)
end
function logic_suit_multi_shape:ClearSuitShapeInfo(UID, SuitItemID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not UID then
    log(bWriteLog and "logic_suit_multi_shape:ClearSuitShapeInfo, UID is nil")
    return
  end
  if not SuitItemID then
    log(bWriteLog and "logic_suit_multi_shape:ClearSuitShapeInfo, SuitItemID is invalid.")
    return
  end
  UID = tostring(UID)
  if not self._AllShapeData then
    self._AllShapeData = {}
  end
  if not self._AllShapeData[UID] then
    self._AllShapeData[UID] = {}
  end
  self._AllShapeData[UID][SuitItemID] = nil
  self:_UpdateTeamAvatarShapeInfo(UID)
end
function logic_suit_multi_shape:GetSuitShapeID(UID, SuitItemID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not UID then
    log(bWriteLog and "logic_suit_multi_shape:GetSuitShapeID, UID is invalid.")
    return nil
  end
  if not SuitItemID then
    log(bWriteLog and "logic_suit_multi_shape:GetSuitShapeID, SuitItemID is invalid.")
    return nil
  end
  local UID = tostring(UID)
  if UID == DataMgr.roleData.uid then
    local RoleWear = AvatarData.GetRoleWear()
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    if RoleWear then
      for _, InsID in pairs(RoleWear) do
        local ResID = wardrobe_data:GetItemIDByInsID(InsID)
        local DataSource = wardrobe_data:GetItemSource(InsID)
        if ResID == SuitItemID and DataSource == EWardrobeDataSource.InheritWardrobe then
          return nil
        end
      end
    end
  end
  local ShapeInfo = self._AllShapeData and self._AllShapeData[UID] and self._AllShapeData[UID][SuitItemID]
  if ShapeInfo and not self:CheckSuitHeadGenderValidByUID(UID, SuitItemID, ShapeInfo.ShapeID) then
    return nil
  end
  return ShapeInfo and ShapeInfo.ShapeID
end
function logic_suit_multi_shape:SetSelfSuitShapeInfo(SuitItemID, ShapeType, ShapeID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not SuitItemID then
    log(bWriteLog and "logic_suit_multi_shape:SetSuitShapeInfo, SuitItemID is invalid.")
    return
  end
  local UID = DataMgr.roleData.uid
  self:SetSuitShapeInfo(UID, SuitItemID, ShapeType, ShapeID)
end
function logic_suit_multi_shape:GetSelfSuitShapeID(SuitItemID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return nil
  end
  if not SuitItemID then
    return nil
  end
  local UID = DataMgr.roleData.uid
  return self:GetSuitShapeID(UID, SuitItemID)
end
function logic_suit_multi_shape:CanCurrentSuitChangeHead(SuitItemID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return false
  end
  if not SuitItemID or SuitItemID == 0 then
    return false
  end
  local MatchHeadInfoList = self:GetMatchHeadInfoBySuitID(SuitItemID, false)
  return MatchHeadInfoList and next(MatchHeadInfoList) ~= nil
end
function logic_suit_multi_shape:GetResponseHatItemID(SuitItemID)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return nil
  end
  if not SuitItemID then
    return nil
  end
  local ChangeHeadCfg = CDataTable.GetTableData("GoldenSuitChangeHeadCfg", SuitItemID)
  return ChangeHeadCfg and ChangeHeadCfg.DependencyItemID
end
function logic_suit_multi_shape:IsShowChangeHeadNewGuide(SuitItemID)
  if not self:CanCurrentSuitChangeHead(SuitItemID) then
    log(bWriteLog and string.format("xcc logic_suit_multi_shape:IsShowChangeHeadNewGuide itemId %s isn't changeheadgoldsuit", SuitItemID))
    return
  end
  log(bWriteLog and "[YY]IsShowChangeHeadNewGuide===\229\143\175\230\141\162\229\164\180==" .. tostring(SuitItemID))
  local playerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local cfg = playerPrefsSystem.LoadFileToTable_N(playerPrefsSystem.ePlayerPrefsType.eGoldenSuitWardrobeChangeHeadGuide) or {}
  if cfg and cfg.hasShow then
    log(bWriteLog and string.format("xcc logic_suit_multi_shape:IsShowChangeHeadNewGuide itemId %s triggered changeheadgoldsuit new guide", SuitItemID))
    return
  end
  local PlayAnimationFeatureInGameGuide = require("client.slua.umg.newbie_guide.PlayAnimationFeatureInGameGuide")
  if PlayAnimationFeatureInGameGuide.CanShowGuide(SuitItemID) then
    PlayAnimationFeatureInGameGuide.ShowAndSaveGuide()
    return
  end
  cfg = {hasShow = true}
  playerPrefsSystem.SaveTableToFile_N(cfg, playerPrefsSystem.ePlayerPrefsType.eGoldenSuitWardrobeChangeHeadGuide)
  local Config = require("client.slua.umg.Wardrobe.guide.goldsuit_changehead_guide_config")
  UIManager.ShowUI(UIManager.UI_Config.Common_Popup_Reward_Base, nil, Config)
  log(bWriteLog and string.format("xcc logic_suit_multi_shape:IsShowChangeHeadNewGuide itemId %s trigger changeheadgoldsuit new guide", SuitItemID))
end
function logic_suit_multi_shape:GetMatchHeadInfoBySuitID(SuitItemID, bIncludeLocked)
  local Result = self:GetMatchHeadInfoBySuitIDWithoutSelf(SuitItemID, bIncludeLocked)
  if not Result then
    return nil
  end
  if next(Result) then
    table.insert(Result, 1, {OriginSuitID = SuitItemID, MatchItemID = 0})
  end
  return Result
end
function logic_suit_multi_shape:GetMatchHeadInfoBySuitIDWithoutSelf(SuitItemID, bIncludeLocked)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return nil
  end
  if not SuitItemID or SuitItemID == 0 then
    return nil
  end
  if not bIncludeLocked and not self:IsSuitChangeHeadOpened(SuitItemID, true) then
    return nil
  end
  local ChangeHeadCfg = CDataTable.GetTableData("GoldenSuitChangeHeadCfg", SuitItemID)
  if not ChangeHeadCfg or ChangeHeadCfg.CanUseHeadGoldenID == "" then
    return logic_suit_multi_shape.CONST_EMPTY_MATCH_ID_LIST
  end
  local Result = {}
  local StringUtil = require("common.string_util")
  local CanUseHeadGoldenIDList = StringUtil.Split(ChangeHeadCfg.CanUseHeadGoldenID, "|")
  for _, v in pairs(CanUseHeadGoldenIDList) do
    local MatchItemID = tonumber(v)
    if MatchItemID then
      local bHeadUnlocked = self:IsSuitChangeHeadOpened(MatchItemID, false)
      if bIncludeLocked or bHeadUnlocked then
        Result[#Result + 1] = {
          OriginSuitID = SuitItemID,
          MatchItemID = MatchItemID,
          bUnlocked = bHeadUnlocked
        }
      end
    end
  end
  return Result
end
function logic_suit_multi_shape:GetGroupedHeadInfoBySuitID(SuitItemID, bIncludeLocked)
  local Result = self:GetGroupedHeadInfoBySuitIDWithoutSelf(SuitItemID, bIncludeLocked)
  if not Result then
    return nil
  end
  if next(Result) then
    table.insert(Result, 1, {
      OriginSuitID = SuitItemID,
      MasterID = SuitItemID,
      MatchItemIDList = {0}
    })
  end
  return Result
end
function logic_suit_multi_shape:GetGroupedHeadInfoBySuitIDWithoutSelf(SuitItemID, bIncludeLocked)
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return nil
  end
  if not SuitItemID or SuitItemID == 0 then
    return nil
  end
  if not bIncludeLocked and not self:IsSuitChangeHeadOpened(SuitItemID, true) then
    return nil
  end
  local ChangeHeadCfg = CDataTable.GetTableData("GoldenSuitChangeHeadCfg", SuitItemID)
  if not ChangeHeadCfg or ChangeHeadCfg.CanUseHeadGoldenID == "" then
    return logic_suit_multi_shape.CONST_EMPTY_MATCH_ID_LIST
  end
  if not self._BelongMap then
    self:_InitSuitBelongings()
  end
  local GroupMap = {}
  local StringUtil = require("common.string_util")
  local CanUseHeadGoldenIDList = StringUtil.Split(ChangeHeadCfg.CanUseHeadGoldenID, "|")
  local GroupCount = 0
  for _, v in pairs(CanUseHeadGoldenIDList) do
    local MatchItemID = tonumber(v)
    if MatchItemID then
      local bHeadUnlocked = self:IsSuitChangeHeadOpened(MatchItemID, false)
      if bIncludeLocked or bHeadUnlocked then
        local GroupID = MatchItemID
        local MasterSuitID = self._BelongMap[MatchItemID]
        if MasterSuitID and SuitItemID ~= MasterSuitID then
          GroupID = MasterSuitID
        end
        if not GroupMap[GroupID] then
          GroupCount = GroupCount + 1
          GroupMap[GroupID] = {
            OriginSuitID = SuitItemID,
            MasterID = GroupID,
            MatchItemIDList = {MatchItemID},
            bUnlocked = bHeadUnlocked,
            GroupIndex = GroupCount
          }
        else
          table.insert(GroupMap[GroupID].MatchItemIDList, MatchItemID)
        end
      end
    end
  end
  local GroupList = {}
  for k, v in pairs(GroupMap) do
    GroupList[#GroupList + 1] = v
  end
  table.sort(GroupList, function(a, b)
    return a.GroupIndex < b.GroupIndex
  end)
  return GroupList
end
function logic_suit_multi_shape:GetBindClothInfoIfNeed()
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if self._bGetSelfBindClothInfo then
    return
  end
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_get_gold_cloth_bind_info_req()
end
function logic_suit_multi_shape:GetAllSuitsCanChangeHead(bIncludeLocked, bForPool)
  local ChangeHeadTable = CDataTable.GetTable("GoldenSuitChangeHeadCfg")
  local SuitInfoList = {}
  for SuitID, Cfg in pairs(ChangeHeadTable) do
    if Cfg and Cfg.CanUseHeadGoldenID ~= "" then
      local bSuitUnlocked = self:IsSuitChangeHeadOpened(SuitID, true)
      if bIncludeLocked or bSuitUnlocked then
        if not bForPool or not logic_suit_multi_shape.EXCLUDE_SUIT_ITEM_FOR_POOL[SuitID] then
          SuitInfoList[#SuitInfoList + 1] = {SuitID = SuitID, bUnlocked = bSuitUnlocked}
        else
          log(bWriteLog and "logic_suit_multi_shape:GetAllSuitsCanChangeHead get list for pool, exclude SuitID: " .. tostring(SuitID))
        end
      end
    end
  end
  return SuitInfoList
end
function logic_suit_multi_shape:_GetResIDFromInstID(InstID)
  if not InstID then
    return nil
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(InstID)
  return ItemData and ItemData.resID
end
function logic_suit_multi_shape:_GetClothesResIDByUID(UID)
  if not UID then
    return nil
  end
  UID = tostring(UID)
  if UID == DataMgr.roleData.uid then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    local tRoleData = AvatarData.GetRoleWear()
    for _, v in pairs(tRoleData) do
      local ItemData = wardrobe_data:GetHallDepotItemDataByInsID(v)
      if ItemData and ItemData.resID then
        local ItemCfg = CDataTable.GetTableData("Item", ItemData.resID)
        if ItemCfg and ItemCfg.ItemSubType == ENUM_ITEM_SUBTYPE.Package_Slot then
          return ItemData.resID
        end
      end
    end
    return nil
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local memberInfo = TeamUpNewSystem.GetMemberInfo(UID)
  return memberInfo and memberInfo.wear_ext and memberInfo.wear_ext[3] and memberInfo.wear_ext[3][1]
end
function logic_suit_multi_shape:_UpdateTeamAvatarShapeInfo(UID)
  log(bWriteLog and string.format("logic_suit_multi_shape:_UpdateTeamAvatarShapeInfo. UID=%s", tostring(UID)))
  if not LobbySystem.CheckOpen(BP_ENUM_GOLDEN_CHANGE_HEAD_SWITCH) then
    return
  end
  if not UID then
    return
  end
  local ClothID = self:_GetClothesResIDByUID(UID)
  local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
  local Avatar = TeamAvatarManager.GetAvatarByUid(UID)
  if not Avatar then
    return
  end
  local ShapeID = ClothID and self:GetSuitShapeID(UID, ClothID)
  if ShapeID then
    Avatar:HandleShapeInfo(ClothID, ShapeID)
  else
    Avatar:HandleShapeInfo(ClothID, 0)
  end
end
function logic_suit_multi_shape:CheckSuitHeadGenderValid(Gender, SuitItemID, HeadItemID)
  if not SuitItemID or not HeadItemID then
    log(bWriteLog and "logic_suit_multi_shape:CheckSuitHeadGenderValid SuitItemID or HeadItemID is nil.")
    return false
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  Gender = Gender or LobbyAvatarManager.Enum_Sex.Male
  local HeadGenderCfg = CDataTable.GetTableData("FixGenderAvatarTable", HeadItemID)
  local HeadLimitGender = HeadGenderCfg and HeadGenderCfg.Gender
  if HeadLimitGender == nil then
    return true
  end
  local SuitGenderCfg = CDataTable.GetTableData("FixGenderAvatarTable", SuitItemID)
  local SuitLimitGender = SuitGenderCfg and SuitGenderCfg.Gender
  local bHeadMale = HeadLimitGender == LobbyAvatarManager.Enum_Sex_Cpp.Male
  local bBodyMale = Gender == LobbyAvatarManager.Enum_Sex.Male
  if SuitLimitGender then
    bBodyMale = SuitLimitGender == LobbyAvatarManager.Enum_Sex_Cpp
  end
  if bHeadMale ~= bBodyMale then
    log(bWriteLog and string.format("logic_suit_multi_shape:CheckSuitHeadGenderValid bHeadMale=%s, bBodyMale=%s Gender=%s, SuitItemID=%s, HeadItemID=%s", tostring(bHeadMale), tostring(bBodyMale), tostring(Gender), tostring(SuitItemID), tostring(HeadItemID)))
    return false
  end
  return true
end
function logic_suit_multi_shape:CheckSuitHeadGenderValidByUID(UID, SuitItemID, HeadItemID)
  if not UID then
    log(bWriteLog and "logic_suit_multi_shape:CheckSuitHeadGenderValidByUID UID is nil ")
    return false
  end
  if not SuitItemID or not HeadItemID then
    log(bWriteLog and "logic_suit_multi_shape:CheckSuitHeadGenderValidByUID SuitItemID or HeadItemID is nil.")
    return false
  end
  local RoleGender
  if UID == DataMgr.roleData.uid then
    RoleGender = AvatarData.GetGameGender()
  else
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
    RoleGender = BasicDataAvatarWearInfo:GetGender(UID) or LobbyAvatarManager.Enum_Sex.Male
  end
  return self:CheckSuitHeadGenderValid(RoleGender, SuitItemID, HeadItemID)
end
function logic_suit_multi_shape:OnGotAvatarShowDataEvent(_, _, nUId)
  if tonumber(nUId) ~= tonumber(DataMgr.roleData.uid) then
    return
  end
  self:_UpdateTeamAvatarShapeInfo(DataMgr.roleData.uid)
end
function logic_suit_multi_shape:NeedShowUnlockPrompt()
  local AccountRegionForBPMacros = require("client.slua.config.ClientMacros.AccountRegionForBPMacros")
  if not GlobalData.IsJapanOrKorea() or FuncUtil.GetAccountRegionForBP() ~= AccountRegionForBPMacros.JP then
    log(bWriteLog and string.format("logic_suit_multi_shape:NeedShowUnlockPrompt. NOT Japan return false "))
    return false
  end
  log(bWriteLog and string.format("logic_suit_multi_shape:NeedShowUnlockPrompt. Japan return %s", tostring(self.bHasUnlockJP)))
  return not self.bHasUnlockJP
end
function logic_suit_multi_shape:OpenUnlockConfirmPanel()
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local Title = LocUtil.GetLocalizeResStr(101001)
  local bMoneyEnough = DataMgr.IsMoneyEnough(StoreConst.label_price_type_chip, logic_suit_multi_shape.UNLOCK_COST)
  local ContentLocID = bMoneyEnough and 82155 or 82154
  local Content = LocUtil.LocalizeResFormat(ContentLocID, logic_suit_multi_shape.UNLOCK_COST)
  CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, Title, Content, function()
    if bMoneyEnough then
      self:ReqUnlockGoldenDressBind()
    else
      ShowNotice(4457)
    end
  end)
end
function logic_suit_multi_shape:ReqUnlockGoldenDressBind()
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_unlock_gold_dress_bind_req()
end
function logic_suit_multi_shape:SetUnlockState(bUnlock)
  self.bHasUnlockJP = bUnlock
  local LobbyIdleUnlock = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyIdleUnlock)
  EventSystem:postEvent(EVENTTYPE_WARDROBE, EVENTID_WARDROBE_COLLECT_UNLOCK_STATE_REFRESH, LobbyIdleUnlock.E_CollectType.E_Type_ChangeHead)
end
function logic_suit_multi_shape:IsSuitChangeHeadOpened(SuitItemID, bAsBody)
  if not SuitItemID then
    return false
  end
  local ChangeHeadCfg = CDataTable.GetTableData("GoldenSuitChangeHeadCfg", SuitItemID)
  if not ChangeHeadCfg then
    return false
  end
  if self.bIgnoreDateChecking then
    return true
  end
  local UnlockTimeStr
  if bAsBody then
    UnlockTimeStr = ChangeHeadCfg.BodyUnlockTime
  else
    UnlockTimeStr = ChangeHeadCfg.HeadUnlockTime
  end
  if not UnlockTimeStr or UnlockTimeStr == "" then
    return true
  end
  local TimeUtil = require("client.common.time_util")
  local UnlockTimeStamp = TimeUtil.TimeStringToUnixstamp(UnlockTimeStr, false)
  if not UnlockTimeStamp then
    return true
  end
  local Now = TimeUtil.GetServerTimeInSec()
  return UnlockTimeStamp <= Now
end
function logic_suit_multi_shape:SetIgnoreDataCheckIgnore(bIgnoreDateChecking)
  self.end
function logic_suit_multi_shape:GetChangeHeadDescText(ItemID)
  if not ItemID or ItemID <= 0 then
    return ""
  end
  local MatchHeadInfo = self:GetMatchHeadInfoBySuitID(ItemID, false) or {}
  local HeadNameList = ""
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  local bWithSeparator = false
  for k, v in pairs(MatchHeadInfo) do
    if v.MatchItemID ~= 0 then
      local ItemCfg = CDataTable.GetTableData("Item", v.MatchItemID)
      if ItemCfg then
        if bWithSeparator then
          HeadNameList = string.format("%s | %s", HeadNameList, ItemCfg.ItemName)
        else
          HeadNameList = string.format("%s%s", HeadNameList, ItemCfg.ItemName)
          bWithSeparator = true
        end
      end
    end
  end
  local SuitItemName = ""
  local ItemCfg = CDataTable.GetTableData("Item", ItemID)
  SuitItemName = ItemCfg and ItemCfg.ItemName
  return LocUtil.LocalizeResFormat(82106, SuitItemName, HeadNameList)
end
function logic_suit_multi_shape:GetGoldChangeHeadIcon(MatchItemID, OriginSuitID, PreviewGender)
  if not MatchItemID then
    return nil
  end
  local ChangeHeadCfg = CDataTable.GetTableData("GoldenSuitChangeHeadCfg", MatchItemID)
  if not ChangeHeadCfg then
    return nil
  end
  local LobbyAvatarManager = require("client.logic.avatar.LobbyAvatarManager")
  local Gender, HeadLimitGender
  if OriginSuitID then
    local HeadGenderCfg = CDataTable.GetTableData("FixGenderAvatarTable", OriginSuitID)
    local HeadLimitGenderCPP = HeadGenderCfg and HeadGenderCfg.Gender
    if HeadLimitGenderCPP then
      HeadLimitGender = HeadLimitGenderCPP == LobbyAvatarManager.Enum_Sex_Cpp.Male and LobbyAvatarManager.Enum_Sex.Male or LobbyAvatarManager.Enum_Sex.Female
    end
  end
  Gender = HeadLimitGender or PreviewGender
  if not Gender then
    local BasicDataAvatarWearInfo = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataAvatarWearInfo)
    Gender = BasicDataAvatarWearInfo:GetGender(DataMgr.roleData.uid) or AvatarData.GetGameGender()
  end
  if Gender == LobbyAvatarManager.Enum_Sex.Male and ChangeHeadCfg.DisplayIconPathMale ~= "" then
    return ChangeHeadCfg.DisplayIconPathMale
  end
  return ChangeHeadCfg.DisplayIconPathCommon
end
function logic_suit_multi_shape:IsGoldHeadChangeUnlocked(MatchItemID)
  if not MatchItemID then
    return false
  end
  if MatchItemID == 0 then
    return true
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  if not wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(MatchItemID) then
    return false
  end
  local logic_suit_multi_shape = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_suit_multi_shape)
  local MatchHatItemID = logic_suit_multi_shape:GetResponseHatItemID(MatchItemID)
  if MatchHatItemID and MatchHatItemID ~= 0 then
    return wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(MatchHatItemID)
  end
  return true
end
function logic_suit_multi_shape:GetJumpUrlBySuitID(SuitID)
  local JumpCfg = SuitID and self.SuitID2JumpUrl and self.SuitID2JumpUrl[SuitID]
  if not JumpCfg then
    return nil
  end
  local TimeUtil = require("client.common.time_util")
  local Now = TimeUtil.GetServerTimeInSec()
  for k, v in pairs(JumpCfg) do
    if v.begin_time and Now >= v.begin_time and v.end_time and Now < v.end_time then
      return v.jump_url
    end
  end
  return nil
end
function logic_suit_multi_shape:AppendSuitJumpUrlCfg(CfgTable)
  if not CfgTable then
    return
  end
  if not self.SuitID2JumpUrl then
    self.SuitID2JumpUrl = {}
  end
  for k, v in pairs(CfgTable) do
    self.SuitID2JumpUrl[k] = v
  end
end
function logic_suit_multi_shape:OnNextDayZeroCome()
  self:ReqSuitID2JumpUrl()
end
local QUERY_COUNT_PER_REQUEST = 50
function logic_suit_multi_shape:ReqSuitID2JumpUrl()
  log(bWriteLog and "logic_suit_multi_shape:ReqSuitID2JumpUrl. ")
  local AllChangeHeadSuitList = self:GetAllSuitsCanChangeHead(true)
  local ListLength = #AllChangeHeadSuitList
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  local BatchIndex = 0
  self:AddTimer(0, function()
    while QUERY_COUNT_PER_REQUEST * BatchIndex < ListLength do
      local SingleReqList = {}
      for i = 1, 50 do
        local CurrentIndexInAll = QUERY_COUNT_PER_REQUEST * BatchIndex + i
        if CurrentIndexInAll > ListLength then
          break
        end
        SingleReqList[#SingleReqList + 1] = AllChangeHeadSuitList[CurrentIndexInAll].SuitID
      end
      WardRobeHandler.send_get_item_jump_info_by_itemlist_req(SingleReqList)
      BatchIndex = BatchIndex + 1
      coroutine.yield(0)
    end
  end)
end
function logic_suit_multi_shape:_InitSuitBelongings()
  self._BelongMap = {}
  local BelongTable = CDataTable.GetTable("ChangeHeadBelongingCfg")
  for k, v in pairs(BelongTable) do
    self._BelongMap[k] = v.MasterSuitID
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_suit_multi_shape = class(CModuleBase, nil, logic_suit_multi_shape)
return Clogic_suit_multi_shape