local logic_roleInfo_background = {}
function logic_roleInfo_background:DefineAndResetData()
  self.defaultRoleInfoBGID = nil
  self.curPreviewPlayerID = nil
  self.curPreviewBGID = nil
  self.curLoadLevelName = nil
  self.curWaitToPreviewBGID = nil
  self.sequencePlayer = nil
  self.sequenceActor = nil
  self.bPlaying = nil
  self.downloadPollTimer = nil
  self.downloadPollingBGID = nil
  self.downloadPollList = {}
end
function logic_roleInfo_background:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_ADD_PERSONAL_ITEM, self.OnAddRoleInfoBG, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_HALL_DEPOT_DELETE_PERSONAL_ITEM, self.OnDeleteRoleInfoBG, self)
end
function logic_roleInfo_background:OnAddRoleInfoBG()
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_BACKGROUND_REDDOT)
end
function logic_roleInfo_background:OnDeleteRoleInfoBG(_, _, deleteList)
  log_tree(bWriteLog and "logic_roleInfo_background:OnDeleteRoleInfoBG:", deleteList)
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local savedData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBackGroundRedPoint) or {}
  local update = false
  for _, id in ipairs(deleteList) do
    if savedData[id] then
      savedData[id] = nil
      update = true
    end
  end
  if update then
    PlayerPrefsSystem.SaveTableToFile_N(savedData, PlayerPrefsSystem.ePlayerPrefsType.eBackGroundRedPoint)
  end
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_BACKGROUND_REDDOT)
end
function logic_roleInfo_background:UpdateProfileData(roleInfoBGID)
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if not profile then
    return
  end
  profile.social_card = profile.social_card or {}
  if not profile.social_card.social_info_bg then
    profile.social_card.social_info_bg = {
      [ENUM_ITEM_SUBTYPE.RoleInfoBG] = roleInfoBGID
    }
  else
    profile.social_card.social_info_bg[ENUM_ITEM_SUBTYPE.RoleInfoBG] = roleInfoBGID
  end
end
function logic_roleInfo_background:GetDefaultRoleInfoBGID()
  if not self.defaultRoleInfoBGID then
    local defaultCfg = CDataTable.GetTableData("RoleInfoDefaultSkinCfg", ENUM_ITEM_SUBTYPE.RoleInfoBG)
    self.defaultRoleInfoBGID = defaultCfg.DefaultID
  end
  return self.defaultRoleInfoBGID
end
function logic_roleInfo_background:SetCurrentRoleInfoBGID(roleInfoBGID)
  DataMgr.roleData.social_card = DataMgr.roleData.social_card or {}
  if not DataMgr.roleData.social_card.social_info_bg then
    DataMgr.roleData.social_card.social_info_bg = {
      [ENUM_ITEM_SUBTYPE.RoleInfoBG] = roleInfoBGID
    }
  else
    DataMgr.roleData.social_card.social_info_bg[ENUM_ITEM_SUBTYPE.RoleInfoBG] = roleInfoBGID
  end
  self:UpdateProfileData(roleInfoBGID)
end
function logic_roleInfo_background:GetSelfRoleInfoBGID()
  if not LobbySystem.CheckOpen(BP_ENUM_ROLEINFO_BACKGROUND_SWITCH) then
    return self:GetDefaultRoleInfoBGID()
  end
  DataMgr.roleData.social_card = DataMgr.roleData.social_card or {}
  if DataMgr.roleData.social_card.social_info_bg and DataMgr.roleData.social_card.social_info_bg[ENUM_ITEM_SUBTYPE.RoleInfoBG] then
    return DataMgr.roleData.social_card.social_info_bg[ENUM_ITEM_SUBTYPE.RoleInfoBG]
  else
    return self:GetDefaultRoleInfoBGID()
  end
end
function logic_roleInfo_background:GetPlayerRoleInfoBGID(uid)
  if not LobbySystem.CheckOpen(BP_ENUM_ROLEINFO_BACKGROUND_SWITCH) then
    return self:GetDefaultRoleInfoBGID()
  end
  if tostring(uid) == tostring(DataMgr.roleData.uid) then
    return self:GetSelfRoleInfoBGID()
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local profile = logic_profile:GetLocalProfile(uid)
    if profile and profile.social_card and profile.social_card.social_info_bg and profile.social_card.social_info_bg[ENUM_ITEM_SUBTYPE.RoleInfoBG] then
      return profile.social_card.social_info_bg[ENUM_ITEM_SUBTYPE.RoleInfoBG]
    else
      return self:GetDefaultRoleInfoBGID()
    end
  end
end
function logic_roleInfo_background:GetRoleInfoBGList()
  local roleinfoBGList = {}
  local RoleInfoBackgroundCfg = CDataTable.GetTable("RoleInfoBackgroundCfg")
  for _, v in pairs(RoleInfoBackgroundCfg) do
    local TimeUtil = require("client.common.time_util")
    if (v.IsShow == true or self:IsHaveRoleInfoBG(v.ID)) and TimeUtil.CheckAfterTimeStr(v.ObtainStartDisplayTime) then
      local haveRed = self:HasRedDotByID(v.ID)
      if not haveRed and v.SubList then
        for _, item in ipairs(v.SubList) do
          if self:HasRedDotByID(item.ID) then
            haveRed = true
            break
          end
        end
      end
      local info = {
        ID = v.ID,
        RoleInfoBGName = v.RoleInfoBGName,
        DispalySortInfo = v.DispalySortInfo,
        Type = v.Type,
        Level = v.Level,
        LevelName = v.LevelName,
        ImagePath = v.ImagePath,
        ObtainDescID = v.ObtainDescID,
        ObtainJumpLink = v.ObtainJumpLink,
        bRed = haveRed
      }
      table.insert(roleinfoBGList, info)
    end
  end
  local CurSelectID = self:GetSelfRoleInfoBGID()
  table.sort(roleinfoBGList, function(a, b)
    if a.ID == CurSelectID then
      return true
    elseif b.ID == CurSelectID then
      return false
    else
      local isHaveA = self:IsHaveRoleInfoBG(a.ID)
      local isHaveB = self:IsHaveRoleInfoBG(b.ID)
      if a.ID == self:GetDefaultRoleInfoBGID() then
        isHaveA = true
      end
      if b.ID == self:GetDefaultRoleInfoBGID() then
        isHaveB = true
      end
      if isHaveA == isHaveB then
        if a.bRed ~= b.bRed then
          return a.bRed
        end
        return tonumber(a.DispalySortInfo) < tonumber(b.DispalySortInfo)
      else
        return isHaveA
      end
    end
  end)
  return roleinfoBGList
end
function logic_roleInfo_background:IsCurrentRoleInfoBG(roleInfoBGID)
  if self:GetSelfRoleInfoBGID() == roleInfoBGID then
    return true
  end
  return false
end
function logic_roleInfo_background:IsDefaultRoleInfoBG(roleInfoBGID)
  if self:GetDefaultRoleInfoBGID() == roleInfoBGID then
    return true
  end
  return false
end
function logic_roleInfo_background:GetRoleInfoBGLevelName(roleInfoBGID)
  local roleInfoBGCfg = CDataTable.GetTableData("RoleInfoBackgroundCfg", roleInfoBGID)
  if roleInfoBGCfg then
    return roleInfoBGCfg.LevelName
  else
    return ""
  end
end
function logic_roleInfo_background:IsHaveRoleInfoBG(roleInfoBGID)
  if self:IsDefaultRoleInfoBG(roleInfoBGID) then
    return true
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if WardrobeData:GetHallDepotItemDataByResID(roleInfoBGID) then
    return true
  else
    return false
  end
end
function logic_roleInfo_background:GetRoleInfoBGTime(roleInfoBGID)
  if not roleInfoBGID then
    return nil
  end
  local WardrobeData = require("client.slua.logic.wardrobe.wardrobe_data")
  if WardrobeData:HasItem(roleInfoBGID, true) then
    return nil
  end
  local info = WardrobeData:GetHallDepotItemDataByResIDAndTimeliness(roleInfoBGID, true)
  if info then
    return info.expireTS
  else
    return nil
  end
end
function logic_roleInfo_background:GetRoleInfoBGLevelName(roleInfoBGID)
  local cfg = CDataTable.GetTableData("RoleInfoBackgroundCfg", roleInfoBGID)
  if cfg then
    return cfg.LevelName
  end
  return nil
end
function logic_roleInfo_background:UpdatePlayerEquipBGLevel(uid, loadedCallback)
  self.curPreviewPlayerID = uid
  local curEquipID = self:GetPlayerRoleInfoBGID(uid)
  self:UpdateRoleInfoBGByBGID(curEquipID, loadedCallback, loadedCallback)
end
function logic_roleInfo_background:GetPreviewPlayerID()
  return self.curPreviewPlayerID
end
function logic_roleInfo_background:GetPreviewBGID()
  return self.curPreviewBGID
end
function logic_roleInfo_background:UpdateRoleInfoBGByBGID(bgID, loadedCallback, loadedDefaultCallback)
  log(bWriteLog and "[ax] logic_roleInfo_background:UpdateRoleInfoBGByBGID BGID=" .. tostring(bgID))
  if bgID == self.curPreviewBGID then
    log(bWriteLog and "[ax] logic_roleInfo_background:UpdateRoleInfoBGByItemID same itemID:" .. tostring(bgID))
    if loadedCallback and type(loadedCallback) == "function" then
      loadedCallback(bgID)
    end
    return
  end
  local common_config = require("client.slua.common.common_config")
  if not common_config:IsShowAvatarInRank() then
    log(bWriteLog and "logic_roleInfo_background:UpdateRoleInfoBGByBGID UI responsiveness testing")
    return
  end
  self:UnloadCurrentRoleInfoBGLevel()
  local LevelName = self:GetRoleInfoBGLevelName(bgID)
  self.curLoad  self.curPreviewBGID = bgID
  self.downloadPollList = {}
  local roleInfoBGCfg = CDataTable.GetTableDataByFilter("RoleInfoBackgroundCfg", "ID", self.curPreviewBGID)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if roleInfoBGCfg.HighSequencePath and roleInfoBGCfg.HighSequencePath ~= "" then
    local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
      roleInfoBGCfg.HighSequencePath
    })
    log_format(bWriteLog and "logic_roleInfo_background:UpdateRoleInfoBGByBGID HighSequencePath=%s, state=%s", roleInfoBGCfg.HighSequencePath, state)
    if state ~= ENUM_DownloadState.Done then
      table.insert(self.downloadPollList, roleInfoBGCfg.HighSequencePath)
    end
  end
  if LevelName and LevelName ~= "" then
    local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
    local levelFullPath = lobby_scene_module:GetStreamLevelFullPathByName(LevelName)
    if levelFullPath then
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {levelFullPath})
      log_format(bWriteLog and "logic_roleInfo_background:UpdateRoleInfoBGByBGID LevelName=%s, fullPath=%s, state=%s", LevelName, levelFullPath, state)
      if state ~= ENUM_DownloadState.Done then
        table.insert(self.downloadPollList, levelFullPath)
      end
    end
  end
  if #self.downloadPollList > 0 then
    self:WaitDownloadThenUpdateBG(bgID, loadedCallback, loadedDefaultCallback)
    return
  end
  local Extra = {
    bAsync = LobbySceneManager.ENUM_ASYNC.ROLE_INFO,
    DefaultScene = LobbySceneManager.LEVEL_NAME.ROLE_INFO,
    DefaultCameraID = 40035,
    Callback = function()
      if self.curPreviewBGID ~= bgID then
        return
      end
      self:PlayLevelSequence()
      if loadedCallback and type(loadedCallback) == "function" then
        loadedCallback(bgID)
      end
    end
  }
  LobbySceneManager.LoadStreamLevel(true, LevelName, nil, nil, Extra)
end
function logic_roleInfo_background:_StopDownloadPollTimer()
  if self.downloadPollTimer then
    self:RemoveTimer(self.downloadPollTimer)
    self.downloadPollTimer = nil
  end
  self.downloadPollingBGID = nil
end
function logic_roleInfo_background:WaitDownloadThenUpdateBG(bgID, loadedCallback, loadedDefaultCallback)
  log(bWriteLog and string.format("logic_roleInfo_background:WaitDownloadThenUpdateBG bgID=%s, pollCount=%d", tostring(bgID), #self.downloadPollList))
  self:_StopDownloadPollTimer()
  self.curWaitToPreviewBGID = bgID
  self:UnloadCurrentRoleInfoBGLevel()
  local DefaultLevelName = self:GetRoleInfoBGLevelName(self.defaultRoleInfoBGID)
  self.curPreviewBGID = self.defaultRoleInfoBGID
  self.curLoadLevelName = DefaultLevelName
  local DefaultExtra = {
    bAsync = LobbySceneManager.ENUM_ASYNC.ROLE_INFO,
    DefaultScene = LobbySceneManager.LEVEL_NAME.ROLE_INFO,
    DefaultCameraID = 40035,
    bExclusive = true,
    Callback = function()
      self:PlayLevelSequence()
      if self.curPreviewBGID ~= self.defaultRoleInfoBGID then
        return
      end
      if loadedDefaultCallback and type(loadedDefaultCallback) == "function" then
        loadedDefaultCallback(self.defaultRoleInfoBGID)
      end
    end
  }
  LobbySceneManager.LoadStreamLevel(true, DefaultLevelName, nil, nil, DefaultExtra)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local extraData = {bFirst = true, bSkipPopUp = true}
  PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, self.downloadPollList, nil, nil, extraData)
  self.downloadPollingBGID = bgID
  self.downloadPollTimer = self:AddTimerLoop(1, function()
    local allDone = true
    local hasError = false
    for _, path in ipairs(self.downloadPollList) do
      local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {path})
      log_format(bWriteLog and "logic_roleInfo_background:WaitDownloadThenUpdateBG poll bgID=%s, path=%s, state=%s", bgID, path, state)
      if state == PufferConst.ENUM_DownloadState.Error then
        hasError = true
        break
      end
      if state ~= PufferConst.ENUM_DownloadState.Done then
        allDone = false
      end
    end
    if hasError then
      log(bWriteLog and string.format("logic_roleInfo_background:WaitDownloadThenUpdateBG download error bgID=%s", bgID))
      self:_StopDownloadPollTimer()
      return
    end
    if allDone then
      self:_StopDownloadPollTimer()
      if self.curWaitToPreviewBGID ~= bgID then
        log(bWriteLog and "logic_roleInfo_background:WaitDownloadThenUpdateBG bgID changed, skip")
        return
      end
      self.downloadPollList = {}
      self:UnloadCurrentRoleInfoBGLevel()
      local LevelName = self:GetRoleInfoBGLevelName(self.curWaitToPreviewBGID)
      self.curPreviewBGID = self.curWaitToPreviewBGID
      self.curLoad      local Extra = {
        bAsync = LobbySceneManager.ENUM_ASYNC.ROLE_INFO,
        DefaultScene = LobbySceneManager.LEVEL_NAME.ROLE_INFO,
        DefaultCameraID = 40035,
        bExclusive = true,
        Callback = function()
          log(bWriteLog and string.format("logic_roleInfo_background:WaitDownloadThenUpdateBG LoadStreamLevel callback self.curPreviewBGID=%s, bgID=%s", tostring(self.curPreviewBGID), tostring(bgID)))
          if self.curPreviewBGID ~= self.curWaitToPreviewBGID then
            return
          end
          if loadedCallback and type(loadedCallback) == "function" then
            loadedCallback(bgID)
          end
        end
      }
      LobbySceneManager.LoadStreamLevel(true, LevelName, nil, nil, Extra)
    end
  end, TIMER_INFINITE, 1)
end
function logic_roleInfo_background:UpdateRoleInfoBGByLevelName(levelName)
  log(bWriteLog and "[ax] logic_roleInfo_background:UpdateRoleInfoBGByLevelName levelName = " .. tostring(levelName))
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_PREVIEW_UPDATE)
  if levelName == self.curLoadLevelName then
    log(bWriteLog and "logic_roleInfo_background:UpdateRoleInfoBGByLevelName same level")
    return
  end
  self:UnloadCurrentRoleInfoBGLevel()
  self.curLoadLevelName = levelName
  local Extra = {
    bAsync = LobbySceneManager.ENUM_ASYNC.ROLE_INFO,
    DefaultScene = LobbySceneManager.LEVEL_NAME.ROLE_INFO,
    DefaultCameraID = 40035,
    bExclusive = true,
    Callback = function()
      self:PlayLevelSequence()
    end
  }
  LobbySceneManager.LoadStreamLevel(true, levelName, nil, nil, Extra)
end
function logic_roleInfo_background:UnloadCurrentRoleInfoBGLevel(bForceUnload)
  self:_StopDownloadPollTimer()
  if self.curLoadLevelName then
    log(bWriteLog and "[ax] logic_roleInfo_background:UnloadCurrentRoleInfoBGLevel levelName=" .. tostring(self.curLoadLevelName) .. " curPreviewBGID=" .. tostring(self.curPreviewBGID))
    LobbySceneManager.LoadStreamLevel(false, self.curLoadLevelName, nil, nil, {bForceUnload = bForceUnload})
    self.curLoadLevelName = nil
    self.curPreviewBGID = nil
  end
  self:DestroySequencePlayer()
end
function logic_roleInfo_background:on_notify_social_info_bg(roleInfoBGID)
  self:SetCurrentRoleInfoBGID(roleInfoBGID)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_BACKGROUND_REDDOT)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_BACKGROUND_UPDATE)
end
function logic_roleInfo_background:send_set_social_info_bg_req(roleInfoBGID)
  if self:GetSelfRoleInfoBGID() == roleInfoBGID then
    log(bWriteLog and "logic_roleInfo_background:send_set_social_info_bg_req equipped")
    return
  end
  if not self:IsHaveRoleInfoBG(roleInfoBGID) then
    log(bWriteLog and "logic_roleInfo_background:send_set_social_info_bg_req not have")
  end
  local RoleInfoBGHandler = require("client.network.Protocol.RoleInfoBGHandler")
  RoleInfoBGHandler.send_set_social_info_bg_req(ENUM_ITEM_SUBTYPE.RoleInfoBG, roleInfoBGID)
end
function logic_roleInfo_background:on_set_social_info_bg_rsp(res, bg_id)
  if res ~= 0 then
    ShowNotice(9910101)
    return
  end
  self:SetCurrentRoleInfoBGID(bg_id)
  ShowNotice(27736)
end
function logic_roleInfo_background:HaveRedDot()
  if not LobbySystem.CheckOpen(BP_ENUM_ROLEINFO_BACKGROUND_SWITCH) then
    return false
  end
  local RoleInfoBackgroundCfg = CDataTable.GetTable("RoleInfoBackgroundCfg")
  if not RoleInfoBackgroundCfg then
    return false
  end
  for id, _ in pairs(RoleInfoBackgroundCfg) do
    if self:HasRedDotByID(tonumber(id)) then
      return true
    end
  end
  return false
end
function logic_roleInfo_background:ReadRedDot(roleInfoBGID)
  if not roleInfoBGID then
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBackGroundRedPoint) or {}
  save_data[roleInfoBGID] = true
  PlayerPrefsSystem.SaveTableToFile_N(save_data, PlayerPrefsSystem.ePlayerPrefsType.eBackGroundRedPoint)
  EventSystem:postEvent(EVENTTYPE_ROLEINFO, EVENTID_ROLEINFO_UPDATE_BACKGROUND_REDDOT)
end
function logic_roleInfo_background:HasRedDotByID(roleInfoBGID)
  if not roleInfoBGID then
    return false
  end
  if self:IsDefaultRoleInfoBG(roleInfoBGID) then
    return false
  end
  if not self:IsHaveRoleInfoBG(roleInfoBGID) then
    return false
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local save_data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eBackGroundRedPoint)
  if not save_data or not save_data[roleInfoBGID] then
    return true
  end
  return false
end
function logic_roleInfo_background:PlayLevelSequence()
  log(bWriteLog and "logic_roleInfo_background:PlayLevelSequence levelName=" .. tostring(self.curLoadLevelName))
  local roleInfoBGCfg = CDataTable.GetTableDataByFilter("RoleInfoBackgroundCfg", "LevelName", self.curLoadLevelName)
  if not (roleInfoBGCfg and roleInfoBGCfg.SequencePath) or roleInfoBGCfg.SequencePath == "" then
    log(bWriteLog and string.format("logic_roleInfo_background:PlayLevelSequence return roleInfoBGCfg or SequencePath is nil, self.curLoadLevelName=%s", self.curLoadLevelName))
    return
  end
  local loopTime = roleInfoBGCfg.PlayTime - 1
  local bFreezeEndFrame = roleInfoBGCfg.FreezeEndFrame == 1
  self:AsyncLoadAsset(roleInfoBGCfg.SequencePath, function(sequence)
    log(bWriteLog and string.format("logic_roleInfo_background:PlayLevelSequence curLoadLevelName=%s, loopTime=%d, bFreezeEndFrame=%d", self.curLoadLevelName, loopTime, roleInfoBGCfg.FreezeEndFrame))
    local LobbyCameraFunctionLibrary = import("/Game/UMG/UI_Utility/LobbyCameraFunctionLibrary.LobbyCameraFunctionLibrary_C")
    local UIUtil = require("client.common.ui_util")
    self.sequencePlayer, self.sequenceActor = LobbyCameraFunctionLibrary.CreateLevelSequencePlayerAndActor(sequence, UIUtil.GetGameInstance())
    if self.sequencePlayer then
      self.sequencePlayer.FreezeEndFrame = bFreezeEndFrame
      self.sequencePlayer:PlayLooping(loopTime)
    end
  end)
end
function logic_roleInfo_background:DestroySequencePlayer()
  if not self.sequencePlayer or slua.isValid(self.sequencePlayer) then
  end
  self.sequencePlayer = nil
  if self.sequenceActor and slua.isValid(self.sequenceActor) then
    self.sequenceActor:K2_DestroyActor()
  end
  self.sequenceActor = nil
end
function logic_roleInfo_background:HasHighLevelEffect()
  local roleInfoBGCfg = CDataTable.GetTableDataByFilter("RoleInfoBackgroundCfg", "ID", self.curPreviewBGID)
  if not (roleInfoBGCfg and roleInfoBGCfg.Level ~= 1 and roleInfoBGCfg.HighSequencePath) or roleInfoBGCfg.HighSequencePath == "" then
    return false
  end
  local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  local bSceneDownloaded = lobby_scene_module:IsLevelDownloaded(self:GetRoleInfoBGLevelName(self.curPreviewBGID))
  if not bSceneDownloaded then
    log(bWriteLog and "logic_roleInfo_background:HasHighLevelEffect bSceneDownloaded == false")
    return false
  end
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local roleInfoBGCfg = CDataTable.GetTableDataByFilter("RoleInfoBackgroundCfg", "ID", self.curPreviewBGID)
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    roleInfoBGCfg.HighSequencePath
  })
  if state ~= ENUM_DownloadState.Done then
    log(bWriteLog and string.format("logic_roleInfo_background:HasHighLevelEffect return false, state=%s", tostring(state)))
    return false
  end
  return true
end
function logic_roleInfo_background:PlayHighLevelEffect(callback)
  log(bWriteLog and "logic_roleInfo_background:PlayHighLevelEffect self.curPreviewBGID = " .. tostring(self.curPreviewBGID))
  local roleInfoBGCfg = CDataTable.GetTableDataByFilter("RoleInfoBackgroundCfg", "ID", self.curPreviewBGID)
  if self:HasHighLevelEffect() == false then
    log(bWriteLog and "logic_roleInfo_background:PlayLevelSequence cannot find cfg")
    return
  end
  if self.bPlaying == true then
    log(bWriteLog and "logic_roleInfo_background:PlayHighLevelEffect clear last effect")
    self:ClearHighLevelEffect()
  end
  local sequencePath = roleInfoBGCfg.HighSequencePath
  self:AsyncLoadAsset(sequencePath, function(sequence)
    self.highEffectCallback = callback
    local UIUtil = require("client.common.ui_util")
    local SequenceTransform = FTransform()
    local squenceActorPath = "/Game/Arts_PlayerBluePrints/RoleInfo/BP_RoleInfoBGSeqActor.BP_RoleInfoBGSeqActor_C"
    self.highSequenceActor = Game:PlayLevelSequence(UIUtil.GetGameInstance(), sequencePath, SequenceTransform, squenceActorPath, false)
  end)
  self.bPlaying = true
end
function logic_roleInfo_background:ClearHighLevelEffect()
  log(bWriteLog and "logic_roleInfo_background:ClearHighLevelEffect")
  if slua.isValid(self.highSequenceActor) then
    self.highSequenceActor:Stop()
  else
    log_warning("logic_roleInfo_background:HighLevelCallback self.highSequenceActor is destroyed")
  end
end
function logic_roleInfo_background:HighLevelFinishedCallback()
  log(bWriteLog and "logic_roleInfo_background:HighLevelCallback")
  if self.highEffectCallback then
    self.highEffectCallback()
    if slua.isValid(self.highSequenceActor) then
      self.highSequenceActor:K2_DestroyActor()
    end
    self.highSequenceActor = nil
    self.highEffectCallback = nil
    self.bPlaying = false
  else
    log_warning("logic_roleInfo_background:HighLevelCallback self.highEffectCallback is nil")
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_roleInfo_background = class(CModuleBase, nil, logic_roleInfo_background)
return Clogic_roleInfo_background