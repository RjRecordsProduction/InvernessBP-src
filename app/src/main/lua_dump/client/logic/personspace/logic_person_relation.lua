local logic_person_relation = {}
local IntimacyConst = require("client.slua.logic.friend.Intimacy.IntimacyConst")
function logic_person_relation:OnInitialize()
  self.res_rela_frd_list = nil
  self.rela_frd_list = {}
  self.relation_crystal_info = {}
  self.partner_srystal_info = {}
  self.MaxChange = 10
  self.MaxPosChange = 5
  self.NowPosChange = 0
  self.SetUIBP_partner_crystal_info = {}
  self.FirCrystalList = {}
  self.Set_rela_frd_list = {}
  self.Set_empty_rela_frd_list = {
    0,
    0,
    0,
    0,
    0,
    0
  }
  self.DefaultPosID = 2207001
  self.limitTime = 2.5
  self.lastTime = 0
  self.sceneObjects = {sceneObjectActor1 = nil, sceneObjectActor2 = nil}
  self.bIsCreateObjects = false
  self.CurPoseID = 2207001
  self.bJumpOut = false
  self.CurLevelName = nil
  self.GM_openAllSeasonCryStal = false
end
function logic_person_relation:RegistEvents()
end
function logic_person_relation:LoadScene(poseID)
  local logic_person_relation_tool = require("client.logic.personspace.logic_person_relation_tool")
  self.CurPoseID = poseID
  self:DestroyScene()
  local CameraID = logic_person_relation_tool.GetCameraIDbyPoseId(poseID)
  local LevelName = logic_person_relation_tool.GetSceneBackGroundLevelName(poseID)
  self.Cur  local callback = function()
    EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_SCENE_LOADED)
  end
  LobbySceneManager.LoadStreamLevel(true, LevelName, CameraID, nil, {Callback = callback})
end
function logic_person_relation:LoadPlayerAvatarAvatar(friendList, PossID, bisEditActor)
  local MultiplayerAvatar = require("client.logic.avatar.MultiplayerAvatar")
  local tAvatarShowCfg = {}
  tAvatarShowCfg.UseCacheData = true
  tAvatarShowCfg.nSourceType = Enum_AvatarShowSource.Partner_Preview_UIBP
  tAvatarShowCfg.PoseItemID = PossID
  tAvatarShowCfg.bIsMultiplayerAvatar = true
  tAvatarShowCfg.  tAvatarShowCfg.SceneType = "LobbyCP01"
  local avatarInfos = {}
  if not friendList or not next(friendList) then
    return
  end
  for k, v in pairs(friendList) do
    local avatarInfo = {}
    if k == 1 or v.TexturePath == "" then
      avatarInfo.interactionValue = nil
      avatarInfo.interactionImage = nil
    else
      avatarInfo.interactionValue = v.interactInfo
      avatarInfo.interactionImage = v.TexturePath
    end
    avatarInfo.uid = v.uid
    avatarInfo.index = k
    avatarInfo.trustValue = v.friendIntimacy
    avatarInfo.relationImage = v.relationImage
    avatarInfo.relationText = v.relationText
    table.insert(avatarInfos, avatarInfo)
  end
  MultiplayerAvatar:CreateOrUpdateAvatar(avatarInfos, tAvatarShowCfg)
  if self.bIsCreateObjects and self.sceneObjects then
    if self.sceneObjects.sceneObjectActor1 then
      self.sceneObjects.sceneObjectActor1:ConditionalBeginDestroy()
      self.sceneObjects.sceneObjectActor1 = nil
    end
    if self.sceneObjects.sceneObjectActor2 then
      self.sceneObjects.sceneObjectActor2:ConditionalBeginDestroy()
      self.sceneObjects.sceneObjectActor2 = nil
    end
    self.bIsCreateObjects = false
  end
  local person_relation_sceneobjects_tool = require("client.logic.personspace.person_relation_sceneobjects_tool")
  local bCanGetData, meshPath1, pos1, rotate1, scale1, meshPath2, pos2, rotate2, scale2 = person_relation_sceneobjects_tool.CanGetSceneObjectsData(PossID)
  if not self.bIsCreateObjects and bCanGetData then
    self.sceneObjects.sceneObjectActor1 = person_relation_sceneobjects_tool.CreateScenesObject(meshPath1, pos1, rotate1, scale1)
    self.sceneObjects.sceneObjectActor2 = person_relation_sceneobjects_tool.CreateScenesObject(meshPath2, pos2, rotate2, scale2)
    self.bIsCreateObjects = true
  end
  return avatarInfos, tAvatarShowCfg
end
function logic_person_relation:DestroyPlayerAvatar()
  local MultiplayerAvatar = require("client.logic.avatar.MultiplayerAvatar")
  MultiplayerAvatar:DestroyAvatar()
end
function logic_person_relation:DestroyScene()
  local logic_roleInfo_background = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_roleInfo_background)
  logic_roleInfo_background:UnloadCurrentRoleInfoBGLevel()
  LobbySceneManager.LoadStreamLevel(false, self.CurLevelName)
  self.CurLevelName = nil
  if self.sceneObjects then
    if self.sceneObjects.sceneObjectActor1 then
      self.sceneObjects.sceneObjectActor1:ConditionalBeginDestroy()
      self.sceneObjects.sceneObjectActor1 = nil
    end
    if self.sceneObjects.sceneObjectActor2 then
      self.sceneObjects.sceneObjectActor2:ConditionalBeginDestroy()
      self.sceneObjects.sceneObjectActor2 = nil
    end
    self.bIsCreateObjects = false
  end
end
function logic_person_relation:GetPartner_srystal_info()
  return self.partner_srystal_info
end
function logic_person_relation:GetRelation_crystal_info()
  return self.relation_crystal_info
end
function logic_person_relation:GetPartenerCrystal(index)
  if self.SetUIBP_partner_crystal_info and next(self.SetUIBP_partner_crystal_info) then
    return self.SetUIBP_partner_crystal_info[index]
  else
    return nil
  end
end
function logic_person_relation:GetPartnerShowCrystalData(changeCrystal, partnerUid, personSpaceUid)
  local bIsMySelf = tonumber(personSpaceUid) == tonumber(DataMgr.roleData.uid)
  local configs = CDataTable.GetTable("InteractiveCrystal")
  local showCrystalList = {}
  if changeCrystal then
    for k, v in pairs(changeCrystal) do
      local data
      for configsk, configsData in pairs(configs) do
        if configsData.MaxLevel <= v.score_lv and v.season_id == configsData.Season and configsData.CrystalName ~= "" then
          data = configsData
        end
      end
      if data then
        local CrystalData = {
          cfg = data,
          frd_uid = partnerUid,
          crystalType = 1
        }
        table.insert(showCrystalList, CrystalData)
      end
    end
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  if bIsMySelf then
    local bShouldShow, selectedSwitchs = IntimacyUtils.ShouldShowMyBondingCrystal(partnerUid, true)
    if selectedSwitchs then
      for id, value in pairs(selectedSwitchs) do
        if value then
          local data = {
            cfg = CDataTable.GetTableData("WeddingCrystalCfg", id),
            frd_uid = partnerUid,
            ownerUid = personSpaceUid,
            crystalType = 2
          }
          table.insert(showCrystalList, data)
        end
      end
    end
  else
    local bShouldShow, selectedSwitchs = IntimacyUtils.ShouldShowOtherBondingCrystal(personSpaceUid, true)
    if selectedSwitchs then
      for id, value in pairs(selectedSwitchs) do
        if value then
          local data = {
            cfg = CDataTable.GetTableData("WeddingCrystalCfg", id),
            frd_uid = partnerUid,
            ownerUid = personSpaceUid,
            crystalType = 2
          }
          table.insert(showCrystalList, data)
        end
      end
    end
  end
  return showCrystalList
end
function logic_person_relation:GetFriShowCrystal(changeCrystal, profile)
  local showCrystalList = {}
  if changeCrystal and next(changeCrystal) then
    local configs = CDataTable.GetTable("InteractiveCrystal")
    for k, v in pairs(changeCrystal) do
      local data = {}
      for configsk, configsData in pairs(configs) do
        if v.score_lv >= configsData.MaxLevel and v.season_id == configsData.Season and configsData.CrystalName ~= "" then
          data.cfg = configsData
          data.crystalType = 1
          data.frd_uid = v.frd_uid
        end
      end
      if data.cfg then
        table.insert(showCrystalList, data)
      end
    end
  end
  if profile and profile.soulmate_summary and profile.soulmate_summary.relation_keepsake_show_switchs then
    for id, value in pairs(profile.soulmate_summary.relation_keepsake_show_switchs) do
      if value then
        local data = {
          frd_uid = profile.soulmate_summary.mate_uid,
          cfg = CDataTable.GetTableData("WeddingCrystalCfg", id),
          ownerUid = profile.uid,
          crystalType = 2
        }
        table.insert(showCrystalList, data)
      end
    end
  end
  return showCrystalList
end
function logic_person_relation:GetPartnerInteractiveCrystal(allSeasonData, changeCrystal, partnerUid)
  local configs = CDataTable.GetTable("InteractiveCrystal")
  local CrystalList = {}
  local showCrystal = changeCrystal or {}
  if allSeasonData then
    for k, v in pairs(allSeasonData) do
      if not v or not next(v) then
      else
        local data = {}
        for configsk, configsData in pairs(configs) do
          if configsData and configsData.Season and k == configsData.Season and v.season_interact_score_lv and v.season_interact_score_lv >= configsData.MaxLevel and configsData.CrystalName ~= "" then
            data.cfg = configsData
            data.change = false
            data.crystalType = 1
          end
        end
        if data.cfg then
          table.insert(CrystalList, data)
        end
      end
    end
  end
  local ListNum = 0
  if showCrystal ~= nil then
    for showCrystalk, showCrystalv in pairs(showCrystal) do
      for CrystalListk, CrystalListv in pairs(CrystalList) do
        if showCrystalv.season_id == CrystalListv.cfg.Season and showCrystalv.score_lv >= CrystalListv.cfg.MaxLevel then
          CrystalList[CrystalListk].change = true
          ListNum = ListNum + 1
        end
      end
    end
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bShouldShow, selectedSwitchs = IntimacyUtils.ShouldShowMyBondingCrystal(partnerUid, true)
  if selectedSwitchs then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
    for id, value in pairs(selectedSwitchs) do
      local data = {
        cfg = CDataTable.GetTableData("WeddingCrystalCfg", id),
        frd_uid = partnerUid,
        ownerUid = myProfile.uid,
        crystalType = 2,
        change = value
      }
      table.insert(CrystalList, data)
      if value then
        ListNum = ListNum + 1
      end
    end
  end
  self.SetUIBP_partner_crystal_info = CrystalList
  return CrystalList, ListNum
end
function logic_person_relation:GetAllInteractiveCrystal(allSeasonData)
  local configs = CDataTable.GetTable("InteractiveCrystal")
  local CrystalList = {}
  for k, v in pairs(allSeasonData) do
    if not v or not next(v) then
    else
      local data = {}
      for configsk, configsData in pairs(configs) do
        if v.season_interact_score_lv and v.season_interact_score_lv >= configsData.MaxLevel and k == configsData.Season and configsData.CrystalName ~= "" then
          data.cfg = configsData
          data.crystalType = 1
        end
      end
      if data.cfg then
        table.insert(CrystalList, data)
      end
    end
  end
  if self.GM_openAllSeasonCryStal then
    CrystalList = {}
    for configsk, configsData in pairs(configs) do
      local data = {cfg = configsData, crystalType = 1}
      if data.cfg.CrystalPath ~= "" then
        table.insert(CrystalList, data)
      end
    end
  end
  return CrystalList
end
function logic_person_relation:GetPartnerDisplayCrystalList(allSeasonData, partnerUid)
  local CrystalList = self:GetAllInteractiveCrystal(allSeasonData)
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bShouldShow, selectedSwitchs = IntimacyUtils.ShouldShowMyBondingCrystal(partnerUid, true)
  if selectedSwitchs then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
    for id, value in pairs(selectedSwitchs) do
      local data = {
        cfg = CDataTable.GetTableData("WeddingCrystalCfg", id),
        frd_uid = partnerUid,
        ownerUid = myProfile.uid,
        crystalType = 2,
        change = value
      }
      table.insert(CrystalList, data)
    end
  end
  return CrystalList
end
function logic_person_relation:GetFriInteractiveCrystal(allSeasonData, uid)
  local configs = CDataTable.GetTable("InteractiveCrystal")
  local FirCrystalList = {}
  FirCrystalList[uid] = {}
  if allSeasonData then
    for k, v in pairs(allSeasonData) do
      if not v or not next(v) then
      else
        local data = {}
        for configsk, configsData in pairs(configs) do
          if v and v.season_interact_score_lv and configsData.MaxLevel <= v.season_interact_score_lv and k == configsData.Season and configsData.CrystalName ~= "" then
            data.cfg = configsData
            data.change = false
            data.frd_            data.crystalType = 1
          end
        end
        if data.cfg then
          table.insert(FirCrystalList[uid], data)
        end
      end
    end
  end
  local changeCrystal = self:GetRelation_crystal_info()
  if changeCrystal and next(changeCrystal) then
    for changeCrystalk, changeCrystalv in pairs(changeCrystal) do
      for k, v in pairs(FirCrystalList[uid]) do
        local cfg = v.cfg
        if changeCrystalv.season_id == cfg.Season and changeCrystalv.score_lv >= cfg.MaxLevel and uid == changeCrystalv.frd_uid then
          FirCrystalList[uid][k].change = true
        end
      end
    end
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bShouldShow, selectedSwitchs = IntimacyUtils.ShouldShowMyBondingCrystal(uid, false)
  if selectedSwitchs then
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local myProfile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
    for id, value in pairs(selectedSwitchs) do
      local data = {
        cfg = CDataTable.GetTableData("WeddingCrystalCfg", id),
        frd_uid = uid,
        ownerUid = myProfile.uid,
        crystalType = 2,
        change = value
      }
      table.insert(FirCrystalList[uid], data)
    end
  end
  self.FirCrystalList[uid] = FirCrystalList[uid]
  return self.FirCrystalList
end
function logic_person_relation:GetFirCrystalList(uid)
  if self.FirCrystalList and next(self.FirCrystalList) then
    return self.FirCrystalList[uid]
  end
end
function logic_person_relation:GetFirCrystalListNum()
  if not self.FirCrystalList or not next(self.FirCrystalList) then
    return 0
  end
  local ListConst = 0
  for uid, dataList in pairs(self.FirCrystalList) do
    if dataList and next(dataList) then
      for k, v in pairs(dataList) do
        if v.change == true then
          ListConst = ListConst + 1
        end
      end
    end
  end
  return ListConst
end
function logic_person_relation:SetCrystalItemSend(is_partner, partnerUid)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  local bSelected1, bSelected2 = false, false
  if is_partner then
    local PartnerList = {}
    local dataList = {}
    for k, v in pairs(self.SetUIBP_partner_crystal_info) do
      if v.change then
        if v.crystalType == 1 then
          dataList[v.cfg.Season] = v.cfg.MaxLevel
        elseif v.crystalType == 2 then
          if v.cfg.ID == 1 then
            bSelected1 = true
          elseif v.cfg.ID == 2 then
            bSelected2 = true
          end
        end
      end
    end
    if dataList ~= nil and next(dataList) then
      PartnerList[partnerUid] = dataList
    else
      PartnerList[partnerUid] = {}
    end
    self:send_set_interact_crystal_req(PartnerList, is_partner, bSelected1, bSelected2)
  else
    local SendCrystalList = {}
    local bSelected1, bSelected2 = false, false
    for uid, CrystalList in pairs(self.FirCrystalList) do
      local dataList = {}
      for k, v in pairs(CrystalList) do
        if v.change then
          if v.crystalType == 1 then
            dataList[v.cfg.Season] = v.cfg.MaxLevel
          elseif v.crystalType == 2 then
            if v.cfg.ID == 1 then
              bSelected1 = true
            elseif v.cfg.ID == 2 then
              bSelected2 = true
            end
          end
        end
      end
      SendCrystalList[uid] = dataList
    end
    self:send_set_interact_crystal_req(SendCrystalList, is_partner, bSelected1, bSelected2)
  end
end
function logic_person_relation:GetRela_frd_list()
  if not self.rela_frd_list or not next(self.rela_frd_list) then
    self.rela_frd_list = {}
  end
  for i = 1, 6 do
    if not self.rela_frd_list[i] then
      self.rela_frd_list[i] = 0
    else
    end
    self.Set_rela_frd_list[i] = self.rela_frd_list[i]
  end
  return self.rela_frd_list
end
function logic_person_relation:GetNowPosChange()
  self.NowPosChange = 0
  for k, v in pairs(self.Set_rela_frd_list) do
    if v ~= 0 and tonumber(v) ~= tonumber(DataMgr.roleData.uid) then
      self.NowPosChange = self.NowPosChange + 1
    end
  end
  return self.NowPosChange
end
function logic_person_relation:GetSet_rela_frd_list(bisEmpty)
  if bisEmpty then
    return self.Set_empty_rela_frd_list
  end
  log(bWriteLog and "logic_person_relation:GetSet_rela_frd_list")
  log_tree("logic_person_relation:GetSet_rela_frd_list", self.Set_rela_frd_list)
  return self.Set_rela_frd_list
end
function logic_person_relation:GetInteractionWithSet_rela_frd_list(frd_list, isMySelf)
  log(bWriteLog and "logic_person_relation:GetInteractionWithSet_rela_frd_list" .. tostring(frd_list) .. " isMySelf" .. tostring(isMySelf))
  if frd_list == nil or not next(frd_list) then
    return nil
  end
  local dataList = {}
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  local logic_interaction = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_interaction)
  for k, v in pairs(frd_list) do
    local relationImage, relationText, friendIntimacy, intimacyData
    if k ~= 1 and v ~= 0 then
      local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
      local TableUtil = require("common.table_util")
      local HasBuildList = TableUtil.DeepCloneTable(PersonSpaceSystem.FriendDetailsDatas)
      for HasBuildListk, HasBuildListv in pairs(HasBuildList) do
        if HasBuildListv.gid == tostring(v) then
          intimacyData = HasBuildListv
        end
      end
      local IntimacyAwardSystem = require("client.slua.logic.person_space.logic_intimacy_award")
      if intimacyData and intimacyData.relation then
        relationImage = IntimacyAwardSystem.GetInitimacyIcon_RelationshipDisplay(intimacyData.relation)
        local UIUtil = require("client.common.ui_util")
        local logic_person_space_relationship = require("client.logic.personspace.logic_person_space_relationship")
        relationText = UIUtil.GetIntimacyRelationName(intimacyData.relation)
        friendIntimacy = intimacyData.intimacy
      end
    end
    local interactInfo, TexturePath
    if isMySelf then
      interactInfo, TexturePath = logic_interaction:GetInteractiveScoreandTexture(v)
    elseif self.TargetInteractionList and next(self.TargetInteractionList) and self.TargetInteractionList[v] then
      local data = logic_interaction:GetInteractionIconConfigs(self.TargetInteractionList[v].score)
      if intimacyData then
        local relationKey
        if not intimacyData.relation or intimacyData.relation == 0 then
          relationKey = "Ordinary"
        elseif intimacyData.relation == IntimacyConst.EIntimacyType.Lover then
          relationKey = "Lovers"
        else
          relationKey = "NotLovers"
        end
        local name = relationKey .. "Name"
        interactInfo = self.TargetInteractionList[v].score
        local textturePath = relationKey .. "Bright"
        TexturePath = data[textturePath]
      end
    end
    local data = {}
    data.uid = v
    data.interactInfo = interactInfo or 0
    data.friendIntimacy = friendIntimacy or 0
    data.TexturePath = TexturePath or ""
    data.    data.    table.insert(dataList, data)
  end
  return dataList
end
function logic_person_relation:RemoveRelaIndex(posIndex, frd_uid)
  if frd_uid == self.Set_rela_frd_list[posIndex] then
    self.Set_rela_frd_list[posIndex] = 0
  end
end
function logic_person_relation:RemoveRelaIndexOfID(frd_uid)
  for k, v in pairs(self.Set_rela_frd_list) do
    if v == frd_uid then
      self.Set_rela_frd_list[k] = 0
    end
  end
end
function logic_person_relation:AddRelaIndex(posIndex, frd_uid)
  if self:GetNowPosChange() >= self.MaxPosChange then
    return false
  else
    self.Set_rela_frd_list[posIndex] = frd_uid
  end
end
function logic_person_relation:AddRela(frd_uid)
  if self:GetNowPosChange() >= self.MaxPosChange then
    return false
  else
    for k, v in pairs(self.Set_rela_frd_list) do
      if v == 0 and 1 < k then
        self.Set_rela_frd_list[k] = frd_uid
        return
      end
    end
  end
end
function logic_person_relation:FindRelaIndex(frd_uid)
  for k, v in pairs(self.Set_rela_frd_list) do
    if k ~= 1 and v == frd_uid then
      return k
    end
  end
  return false
end
function logic_person_relation:Setsetpos_mod_id(pos_mod_id)
  if self.Setpos_mod_id ~= pos_mod_id then
    self.Set  end
end
function logic_person_relation:Getetpos_mod_id()
  return self.Setpos_mod_id
end
function logic_person_relation:SendPos()
  local sendData = {}
  for k, v in pairs(self.Set_rela_frd_list) do
    if 1 < k and 0 < v then
      sendData[k] = v
    end
  end
  self:send_set_interact_avatar_req(sendData, self.Setpos_mod_id)
end
function logic_person_relation:send_set_interact_avatar_req(frd_list, pos_mod_id)
  log_tree(bWriteLog and "logic_person_relation:send_set_interact_avatar_req", frd_list)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_set_interact_avatar_req(frd_list, pos_mod_id)
end
function logic_person_relation:on_set_interact_avatar_rsp(err_list, uid_list, pos_mod_id)
  log(bWriteLog and "logic_person_relation:on_set_interact_avatar_rsp pod_mod_id = " .. tostring(pos_mod_id))
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_get_interact_avatar_req()
end
function logic_person_relation:send_set_interact_crystal_req(crystal_list, is_partner, bSelected1, bSelected2)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_set_interact_crystal_req(crystal_list, is_partner)
  local logic_wedding = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_wedding)
  if logic_wedding:GetSoulmateInfo() ~= nil then
    PersonSpaceHandler.send_soulmate_keepsake_show_switch_set_req({bSelected1, bSelected2}, is_partner)
  end
end
function logic_person_relation:on_set_interact_crystal_rsp(crystal_list, is_partner, relation_crystal_info)
  if is_partner then
    self.partner_srystal_info = relation_crystal_info or {}
  else
    self.relation_crystal_info = relation_crystal_info or {}
  end
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_AVATAR_RSP)
end
function logic_person_relation:send_get_interact_avatar_req()
  log(bWriteLog and "logic_person_relation.send_get_interact_avatar_req")
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_get_interact_avatar_req()
end
function logic_person_relation:proc_get_interact_avatar_rsp(rela_frd_list, relation_crystal_info, partner_srystal_info, cur_interact_avatar_posture)
  if rela_frd_list then
    log(bWriteLog and "logic_person_relation:proc_get_interact_avatar_rsp rela_frd_list.pos_mod_id = " .. tostring(rela_frd_list.pos_mod_id))
  else
    log(bWriteLog and "logic_person_relation:proc_get_interact_avatar_rsp")
  end
  self.res_  self.  self.FirCrystalList = {}
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  self.partner_srystal_info = {}
  if partner_srystal_info and next(partner_srystal_info) then
    for k, v in pairs(partner_srystal_info) do
      if v.frd_uid == PersonSpaceSystem.IntimacyPartnerData.partner_uid then
        table.insert(self.partner_srystal_info, v)
      end
    end
  end
  if rela_frd_list and rela_frd_list.pos_mod_id then
    self.pos_mod_id = rela_frd_list.pos_mod_id
  elseif cur_interact_avatar_posture then
    self.pos_mod_id = cur_interact_avatar_posture
  else
    self.pos_mod_id = nil
  end
  if rela_frd_list ~= nil and next(rela_frd_list) then
    self.rela_frd_list = {}
    for k, v in pairs(rela_frd_list) do
      if type(k) == "number" then
        self.rela_frd_list[k] = rela_frd_list[k] or 0
      end
    end
  else
    self.rela_frd_list = nil
  end
  local table_util = require("common.table_util")
  if table_util.CountTable(self.rela_frd_list) < 2 then
    self.rela_frd_list = nil
  end
  self.Setpos_mod_id = self.pos_mod_id or self.DefaultPosID
  self:GetRela_frd_list()
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_INTIMACY_AVATAR_RSP)
end
function logic_person_relation:LimitTiming()
  local TimeUtil = require("client.common.time_util")
  local nowTime = TimeUtil.GetServerTimeInSec()
  if nowTime - self.lastTime > self.limitTime then
    self.lastTime = nowTime
    log(bWriteLog and "logic_person_relation:LimitTiming true:")
    return true
  else
    log(bWriteLog and "logic_person_relation:LimitTiming false:")
    return false
  end
end
function logic_person_relation:send_get_frd_interact_info_req(frd_uid, target_uid)
  log(bWriteLog and "logic_person_relation:send_get_frd_interact_info_req frd_uid:" .. tostring(frd_uid) .. " target_uid:" .. tostring(target_uid))
  local ChatHandler = require("client.network.Protocol.ChatHandler")
  if self:LimitTiming() then
    ChatHandler.send_get_frd_interact_info_req(frd_uid, target_uid)
  else
    ShowNotice(34735)
  end
end
function logic_person_relation:on_get_frd_interact_info_rsp(res, target_uid, frd_interact_info, user_data, interact_reward_limit_data, cfg_limit, frd_uid)
  log(bWriteLog and "logic_person_relation:on_get_frd_interact_info_rsp res:" .. tostring(res) .. " target_uid:" .. tostring(target_uid) .. " frd_uid" .. tostring(frd_uid))
  log_tree(bWriteLog and "logic_person_relation:on_get_frd_interact_info_rsp frd_interact_info:", frd_interact_info)
  log_tree(bWriteLog and "logic_person_relation:on_get_frd_interact_info_rsp user_data:", user_data)
  log_tree(bWriteLog and "logic_person_relation:on_get_frd_interact_info_rsp interact_reward_limit_data:", interact_reward_limit_data)
  log_tree(bWriteLog and "logic_person_relation:on_get_frd_interact_info_rsp cfg_limit:", cfg_limit)
  if res == 0 then
    self.FriInteractInfo = frd_interact_info
    EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_FRD_INTIMACY)
  else
    ShowNotice(34735)
  end
end
function logic_person_relation:send_batch_get_frd_interact_info_req(frd_uid, target_uid_list)
  log(bWriteLog and "logic_person_relation:send_batch_get_frd_interact_info_req" .. tostring(frd_uid))
  log_tree(bWriteLog and "logic_person_relation:send_batch_get_frd_interact_info_req target_uid_list:", target_uid_list)
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_batch_get_frd_interact_info_req(frd_uid, target_uid_list)
end
function logic_person_relation:on_batch_get_frd_interact_info_rsp(frd_uid, target_uid_list)
  log_tree(bWriteLog and "logic_person_relation:on_batch_get_frd_interact_info_rsp target_uid_list:", target_uid_list)
  self.TargetInteractionList = target_uid_list
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_PARTNER_ALLFRD_INTIMACY)
end
function logic_person_relation:SharePhoto(localsize)
  log(bWriteLog and "logic_person_relation : SharePhoto")
  EventSystem:postEvent(EVENTTYPE_LOBBY, EVENTID_CLICK_ANIMATION_HIDE)
  Client.DeleteDirectory(Client.ProjectSavedDir() .. "Screenshots/")
  local ScreenshotMaker = import("ScreenshotMaker")
  local sSharePath = ScreenshotMaker.MakePicture(true)
  EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_INTIMACY_PHOTO_SHARE, true)
  local timer_ticker = require("common.time_ticker")
  local timer
  timer = timer_ticker.AddTimerLoop(0, function()
    if ScreenshotMaker.HasCaptured(sSharePath) then
      EventSystem:postEvent(EVENTTYPE_PERSON_SPACE, EVENTID_INTIMACY_PHOTO_SHARE, false)
      local TimeUtil = require("client.common.time_util")
      local data = self:GetRelation_crystal_info()
      local PartnerData = self.GetFriShowCrystal(data)
      local checkargInfo = {
        {
          name = LocUtil.GetLocalizeResStr(84373),
          bopen = true
        },
        {
          name = LocUtil.GetLocalizeResStr(84374),
          bopen = true
        }
      }
      if type(data) == "table" and next(data) == nil and not PartnerData then
        checkargInfo = {
          {
            name = LocUtil.GetLocalizeResStr(84373),
            bopen = 2
          },
          {
            name = LocUtil.GetLocalizeResStr(84374),
            bopen = true
          }
        }
      end
      local cfg = {
        campaign = "relation_exhibition_share",
        capturePath = sSharePath,
        sceneType = ShareSceneType.RoleInfo_Intimacy_Relationship_Share,
        otherTLog = TLogEventDefine.Lobby_Intimacy_Click_Photo_Share,
        share_type = ShareBtnTLogShareTypeDefine.RoleInfo_Intimacy_Relationship_Share,
        checkargs = checkargInfo,
        isOld = true
      }
      local Util = require("client.slua_ui_framework.util")
      Util.ShowShare(cfg, UIManager.UI_Config.IntimateRelation_Exhibition_Share, localsize)
      timer_ticker.RemoveTimer(timer)
    else
      log(bWriteLog and "  : not yet")
    end
  end, TIMER_INFINITE, 0.1)
end
local class = require("class")
local ModuleBase = require("client.module_framework.ModuleBase")
local logic_person_relation = class(ModuleBase, nil, logic_person_relation)
return logic_person_relation