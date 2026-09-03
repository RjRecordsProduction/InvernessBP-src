local LogicUGCCRUD = {}
local C_UGC_EditModMetaModify = {}
local PufferConst = require("client.slua.logic.download.puffer_const")
function LogicUGCCRUD:DefineAndResetData()
  self.modList = {}
  self.bToEditMod = false
  self.bIsShowUGCCenterMainUI = false
  self.bLastStartIsNewbie = false
  self.EnterGameTimeoutCheckTimer = nil
  self.TeamEditDownloadState = {}
  self.TeamEditWaitTimer = nil
  self.TeamEditWaitAnswer = false
  self.TeamEditSyncTimer = nil
  self.TeamEditDownloadTimer = nil
  self.TeamEditSlot = nil
  self.CDRemain = nil
end
function LogicUGCCRUD:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_BE_KICKED_OUT, self.OnQuitTeam, self)
  self:AddCommonEvent(EVENTTYPE_TEAMUP, EVENTID_TEAMUP_CHANGE_LEADER_NOTIFY, self.OnTeamChangeLeader, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CHANGE_MOD_NOTIFY, self.OnChangeMod, self)
  self:AddCommonEvent(EVENTTYPE_NEXTDAY, EVENTID_NEXTDAY_ZERO, self.OnNextDayZeroCome, self)
end
function LogicUGCCRUD:OnLogOut()
  if self.PubCDRemainTimer then
    self:RemoveTimer(self.PubCDRemainTimer)
    self.PubCDRemainTimer = nil
  end
end
function LogicUGCCRUD:GetModeList()
  return self.modList
end
function LogicUGCCRUD:GetModeBySlot(slot)
  if not slot then
    return nil
  end
  return self.modList[slot]
end
function LogicUGCCRUD:NewModifyMeta()
  local TableUtil = require("common.table_util")
  return TableUtil.CopyTable(C_UGC_EditModMetaModify)
end
function LogicUGCCRUD:GetIsEditMod()
  return self.bToEditMod or false
end
function LogicUGCCRUD:SetIsEditMod(bToEditMod)
  self.end
function LogicUGCCRUD:GetShowUGCCenterMainUI()
  return self.bIsShowUGCCenterMainUI or false
end
function LogicUGCCRUD:SetShowUGCCenterMainUI(bIsShowUGCCenterMainUI)
  self.  log(bWriteLog and "[v_chenxxue]LogicUGCCRUD:SetShowUGCCenterMainUI bIsShowUGCCenterMainUI is " .. tostring(self.bIsShowUGCCenterMainUI))
end
function LogicUGCCRUD:OnGetModListRsp(list, DraftBox_Limit)
  self.modList = list or {}
  self.DraftBox_Limit = DraftBox_Limit or 0
  log_tree(bWriteLog and "Logic_UGC:OnGetModListRsp, ", self.modList)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_MOD_LIST)
end
function LogicUGCCRUD:ReqModifyModMeta(slot, metaData)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if LogicUGCAuthor:IsBanned(true) then
    log(bWriteLog and "LogicUGCCRUD:ReqModifyModMeta LogicUGCAuthor:IsBanned")
    return
  end
  if not slot or not metaData then
    log(bWriteLog and "LogicUGCCRUD:ReqModifyModMeta slot or metaData is nil")
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_modify_mod_meta_req(slot, metaData)
end
function LogicUGCCRUD:OnModifyModRsp(slot, edit_mod_meta)
  log_tree(bWriteLog and "Logic_UGC:OnModifyModRsp, ", edit_mod_meta)
  self.modList[slot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MODIFY_MOD, slot)
end
function LogicUGCCRUD:ReqDeleteMod(slot)
  if not slot then
    return
  end
  local PubMod = self.modList[slot]
  if PubMod then
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    LogicUGCResManager:PauseRes(LogicUGCResManager.DownloaderType.MyWork, PubMod)
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_delete_mod_req(slot)
end
function LogicUGCCRUD:OnDeleteModRsp(slot)
  log(bWriteLog and "Logic_UGC:OnDeleteModRsp, slot: " .. slot)
  self.modList[slot] = nil
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_MOD)
end
function LogicUGCCRUD:ReqPublishMod(slot, overwriteModID, is_wow_moment, ext_info, bPrivate)
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  if LogicUGCAuthor:IsBanned(true) then
    return
  end
  if not slot then
    return
  end
  local PubMod = self.modList[slot]
  if PubMod then
    if not overwriteModID then
      local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
      if LogicUGC:CheckModNameUsed(PubMod.setting.name, true) then
        ShowNotice(70059)
        return
      end
    end
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    LogicUGCResManager:PauseRes(LogicUGCResManager.DownloaderType.MyWork, PubMod)
  end
  local Logic_UGC_SeasonTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season_template)
  local activity_event_id = ext_info and ext_info.activity_event_id
  if activity_event_id and Logic_UGC_SeasonTemplate:CheckActivityEventIsEnd(activity_event_id) then
    log(bWriteLog and "LogicUGCCRUD:ReqPublishMod CheckActivityEventIsEnd CurSelectSeasonActID = " .. tostring(self.CurSelectSeasonActID))
    ext_info.activity_event_id = nil
  end
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  ext_info = ext_info or {}
  if bPrivate then
    ext_info.activity_event_id = nil
    ext_info.spec_theme_id = nil
    ext_info.publish_state = config_ugc.E_ModPubState.Private
  else
    ext_info.publish_state = config_ugc.E_ModPubState.Publish
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_publish_mod_req(slot, overwriteModID, nil, nil, nil, nil, is_wow_moment, ext_info)
end
function LogicUGCCRUD:ReqUpdateMod(slot, oldName, log_text, reset_leaderboard, reset_customvar, is_wow_moment, ext_info, bPrivate)
  if not slot then
    return
  end
  local mod = self.modList[slot]
  if not mod then
    return
  end
  local Logic_UGC_SeasonTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_ugc_season_template)
  local activity_event_id = ext_info and ext_info.activity_event_id
  if activity_event_id and Logic_UGC_SeasonTemplate:CheckActivityEventIsEnd(activity_event_id) then
    log(bWriteLog and "LogicUGCCRUD:ReqUpdateMod CheckActivityEventIsEnd CurSelectSeasonActID = " .. tostring(self.CurSelectSeasonActID))
    ext_info.activity_event_id = nil
  end
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  ext_info = ext_info or {}
  if bPrivate then
    ext_info.activity_event_id = nil
    ext_info.spec_theme_id = nil
    ext_info.publish_state = config_ugc.E_ModPubState.Private
  else
    ext_info.publish_state = config_ugc.E_ModPubState.Publish
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_publish_mod_req(slot, mod.base.mod_id_rela, oldName, log_text, reset_leaderboard, reset_customvar, is_wow_moment, ext_info)
end
function LogicUGCCRUD:OnPublishModRsp(slot, edit_mod_meta)
  log(bWriteLog and "[UGC] Logic_UGC:OnPublishModRsp, slot = " .. string.format("%s", slot))
  if edit_mod_meta.base.mod_id_rela then
    ShowNotice(1050300)
  else
    ShowNotice(70011)
  end
  self.modList[slot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PUBLISH_MOD)
end
function LogicUGCCRUD:ReqDeletePubMod(ModID, ModInfo)
  if not ModID then
    return
  end
  if ModInfo then
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    LogicUGCResManager:PauseRes(LogicUGCResManager.DownloaderType.ModCopy, ModInfo)
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_delete_pub_mod_req(ModID)
end
function LogicUGCCRUD:OnDeletePubModRsp(mod_id, newSlot, edit_mod_meta)
  if not mod_id or not newSlot then
    return
  end
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local list = LogicUGC:GetPubModList()
  if not list then
    return
  end
  list[mod_id] = nil
  log(bWriteLog and string.format("Logic_UGC:OnDeletePubModRsp, mod_id: %s, newSlot: %s", mod_id, newSlot))
  self.modList[newSlot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DELETE_MOD, true)
  if self.DeletingPropShopModID == mod_id then
    self.DeletingPropShopModID = nil
    ShowNotice(81750)
  end
  local LogicUGCSocial = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCSocial)
  LogicUGCSocial:RemoveCollection(mod_id)
end
function LogicUGCCRUD:ReqDuplicateMod(slot, name, type)
  if not slot then
    return
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if not Util_UGC.CheckNameValid(name) then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_duplicate_mod_req(slot, name, type)
end
function LogicUGCCRUD:OnDuplicateModRsp(oldSlot, newSlot, edit_mod_meta, mod_id_list, mod_id)
  local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  resManager:Send_update_client_mod_info_ByModInfo(edit_mod_meta)
  log(bWriteLog and "[UGC] Logic_UGC:OnDuplicateModRsp, oldSlot, newSlot = " .. string.format("%s, %s", oldSlot, newSlot))
  log(bWriteLog and "[UGC] Logic_UGC:OnDuplicateModRsp, edit_mod_meta.setting.has_played_completed = " .. tostring(edit_mod_meta.setting.has_played_completed))
  self.modList[newSlot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DUPLICATE_MOD, newSlot)
  if edit_mod_meta.base.mod_id_rela then
    ShowNotice(4302051)
  else
    ShowNotice(105001)
  end
  if self:OnDuplicateNotify(mod_id_list, mod_id) then
    log(bWriteLog and "[UGC] Logic_UGC:OnDuplicateModRsp Notify Return")
    return
  end
  if IsWoWEditor then
    return
  end
  if not UIManager.IsUIShow(UIManager.UI_Config.ugc_mine_main) then
    UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
  end
end
function LogicUGCCRUD:OnDuplicateNotify(mod_id_list, mod_id)
  local UGCMacros = require("client.slua.logic.ugc.ugc_macros")
  local LogicUGC = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGC)
  local ShowPublishWorksList = LogicUGC:GetCacheByType(UGCMacros.ENUM_MODE_TYPE.Pub) or {}
  if mod_id_list ~= nil then
    local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
    local title = LocUtil.LocalizeResFormat(5077)
    local desc = ""
    local HaveCount = mod_id_list.have_count
    local CopyLimitCount = mod_id_list.copy_limit_count
    local ModIdList = mod_id_list.mod_id_list
    for _, mod_id in ipairs(ModIdList) do
      desc = desc .. " " .. tostring(mod_id)
    end
    if self:IsMineOrOthers(mod_id, ShowPublishWorksList) then
      desc = LocUtil.LocalizeResFormat(80057, HaveCount, CopyLimitCount, desc)
    else
      desc = LocUtil.LocalizeResFormat(80056, HaveCount, CopyLimitCount, desc)
    end
    CommonMsgBoxMgr.Show(2, title, desc, function()
      print(bWriteLog and "[UGC] Logic_UGC:OnDuplicateModRsp \231\159\165\233\129\147\228\186\134")
    end, function()
      print(bWriteLog and "[UGC] Logic_UGC:OnDuplicateModRsp \231\174\161\231\144\134\228\189\156\229\147\129")
      if IsWoWEditor then
        return
      end
      if not UIManager.IsUIShow(UIManager.UI_Config.ugc_mine_main) then
        UIManager.ShowUI(UIManager.UI_Config.ugc_mine_main)
      end
    end, LocUtil.GetLocalizeResStr(80054), LocUtil.GetLocalizeResStr(80055))
    return true
  end
  return false
end
function LogicUGCCRUD:IsMineOrOthers(mod_id, ShowPublishWorksList)
  if mod_id and ShowPublishWorksList then
    for key, _ in pairs(ShowPublishWorksList) do
      if mod_id == key then
        return true
      end
    end
  end
  return false
end
function LogicUGCCRUD:ReqDuplicatePubMod(modID, name, type)
  if not modID then
    return
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if not Util_UGC.CheckNameValid(name) then
    return
  end
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_duplicate_pub_mod_req(modID, name, type)
end
function LogicUGCCRUD:ReqStartEditGame(slot, bSingleEdit, isTrailPlay, novice_level_id, bUpdate)
  if not slot then
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsTeamLeader() == false then
    ShowNotice(64241)
    return
  end
  if LobbySystem.isInMatch then
    ShowNotice(6244)
    return
  end
  if IsWoWEditor and not IsEditor and (not PufferDownloader.InitSuccess or not PufferDownloader.PufferJsonDownloadReturn) then
    log(bWriteLog and "LogicUGCCRUD:ReqStartEditGame PufferJsonDownloadReturn false")
    PufferDownloader.ShowPufferInitProgressNotice()
    return
  end
  local modInfo = self.modList[slot]
  local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  if bSingleEdit and modInfo then
    resManager:Send_update_client_mod_info_ByModInfo(modInfo)
  end
  log(bWriteLog and "[UGC] Logic_UGC:ReqStartEditGame bUpdate = " .. tostring(bUpdate))
  if modInfo then
    local state = resManager:GetResState(resManager.DownloaderType.MyWork, modInfo)
    if state ~= PufferConst.ENUM_DownloadState.Done then
      if not bUpdate then
        ShowNotice(81432)
      end
      return
    end
  end
  self.bToEditMod = true
  log(bWriteLog and "[v_chenxxue]LogicUGCCRUD:ReqStartEditGame novice_level_id is " .. tostring(novice_level_id))
  if novice_level_id ~= nil then
    self:SetShowUGCCenterMainUI(true)
    self:SetLastStartNewbie(true)
  end
  local tryPlayFlag = isTrailPlay and 1 or 0
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_start_ugc_edit_game_req(slot, tryPlayFlag, novice_level_id)
  local logic_ugc_mine = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_UGC_Mine)
  logic_ugc_mine:AddEditCnt()
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  if LogicUGCMatch.bUseDirectEdit then
    print(bWriteLog and "LogicUGCCRUD:ReqStartEditGame AddTimeoutTimer")
    self.EnterGameTimeoutCheckTimer = self:AddTimerOnce(60, function()
      print(bWriteLog and "LogicUGCCRUD:ReqStartEditGame TimerOut")
      self.EnterGameTimeoutCheckTimer = nil
      local LoadingSystem = require("client.slua.logic.loading.logic_loading")
      LoadingSystem.RefreshLoadPercent(1)
      local _LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
      _LogicUGCMatch:SetUGCWaitingEnterGame(false)
      local MatchSystem = require("client.slua.logic.match.logic_match")
      MatchSystem.QueryPlayerState()
    end)
    LogicUGCMatch:SetUGCWaitingEnterGame(true)
    local ToMapID = 0
    if modInfo then
      local Config_UGC = require("client.slua.logic.ugc.config_ugc")
      ToMapID = Config_UGC.GetMapIDByTemplateID(modInfo.base.template_id)
    end
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.ShowLoading(nil, ToMapID)
  end
end
function LogicUGCCRUD:OnEnterGame()
  print(bWriteLog and "LogicUGCCRUD:OnEnterGame")
  if self.EnterGameTimeoutCheckTimer ~= nil then
    self:RemoveTimer(self.EnterGameTimeoutCheckTimer)
    self.EnterGameTimeoutCheckTimer = nil
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:SetUGCWaitingEnterGame(false)
end
function LogicUGCCRUD:OnStartEditGameErrorRsp(err)
  if err == 0 then
    if self.bToEditMod then
      LobbySystem.SetWaitingBattleFlag(true)
      if NetUtil then
        NetUtil.StartCheckEnterBattle(0)
      end
    end
    return
  end
  self:StopToEditMod()
end
function LogicUGCCRUD:ReqCreateMod(templateID, metaData, novice_level_id)
  if not templateID then
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.GetTemplateConfigByID(templateID) then
    ShowNotice(511011)
    return
  end
  local Util_UGC = require("client.slua.logic.ugc.util_ugc")
  if not Util_UGC.CheckNameValid(metaData.name) then
    return
  end
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  LogicUGCTemplate:SetCreateTemplateID(templateID)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_create_mod_req(templateID, metaData, novice_level_id)
end
function LogicUGCCRUD:OnCreateModRsp(slot, edit_mod_meta, novice_level_id)
  if not slot then
    log(bWriteLog and "Logic_UGC:OnCreateModRsp, slot: nil")
    return
  end
  log(bWriteLog and "Logic_UGC:OnCreateModRsp, slot: " .. slot)
  log_tree(bWriteLog and "Logic_UGC:OnCreateModRsp, ", edit_mod_meta)
  self.modList[slot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_CREATE_MOD, slot)
  if self.CreateNewbieLevelId then
    self.NewBieModSlot = slot
    EventSystem:postEvent(EVENTTYPE_NEWBIE_GUIDE, EVENTID_NEWBIE_CONTINUE_GUIDE, self.CreateNewbieLevelId)
    self.CreateNewbieLevelId = nil
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if TeamUpNewSystem.IsInTeam() then
    self:EnterTeamCreate(slot, edit_mod_meta.base.template_id)
  else
    local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    if LogicUGCMatch.bUseDirectEdit then
      self:ReqStartEditGame(slot, true, true, novice_level_id)
    else
      UIManager.CloseUI(UIManager.UI_Config.mode_selection_main)
      LogicUGCMatch:ReqEditModMatch(slot)
    end
  end
end
function LogicUGCCRUD:EnterTeamCreate(Slot, TemplateID)
  if not LobbySystem.CheckLobbyMenuOpen(BP_ENUM_UGC_TEAM_EDIT, false) then
    ShowNotice(48383)
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsTeamLeader() then
    ShowNotice(10120062)
    return
  end
  if TeamUpNewSystem.IsEverybodyReady() == false then
    ShowNotice(111013)
    return
  end
  local PriorLoadMgr = require("client.slua.logic.ugc.PrefabMall.LogicUGCPrefabMallPriorLoadMgr")
  local LeaderCustomAssetList = PriorLoadMgr:GetPriorLoadAssetKeyList()
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_ugc_nofity_custom_asset_info_req(Slot, LeaderCustomAssetList, TemplateID)
  self.TeamEdit  self.TeamEditWaitAnswer = true
  ShowNotice(10120060)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_TeamEdit_Launch)
end
function LogicUGCCRUD:HideTeamEditWaitUI()
  self.TeamEditWaitAnswer = false
  logic_connection_waiting:Hide(1)
  if self.TeamEditSyncTimer then
    self:RemoveTimer(self.TeamEditSyncTimer)
    self.TeamEditSyncTimer = nil
  end
  if self.TeamEditWaitTimer then
    self:RemoveTimer(self.TeamEditWaitTimer)
    self.TeamEditWaitTimer = nil
  end
end
function LogicUGCCRUD:GetTeamEditDownloadInfo(TeamLeaderUid)
  return self.TeamEditDownloadState[TeamLeaderUid]
end
function LogicUGCCRUD:_CheckTeamEditDownloading(TeamLeaderUid)
  local TeamEditDownloadInfo = self:GetTeamEditDownloadInfo(TeamLeaderUid)
  if TeamEditDownloadInfo and TeamEditDownloadInfo.State == PufferConst.ENUM_DownloadState.Download then
    return true, TeamEditDownloadInfo
  end
  return false
end
function LogicUGCCRUD:OnUgcNotifyCustomAssetInfoRsp(ErrCode, TeamLeaderUid, Slot, ModCustomAssetInfo, LeaderCustomAssetList, TemplateID)
  if ErrCode ~= 0 then
    self:HideTeamEditWaitUI()
    return
  end
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  if not TeamUpNewSystem.IsInTeam() then
    print(bWriteLog and "LogicUGCCRUD:OnUgcNotifyCustomAssetInfoRsp not in team")
    return
  end
  local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
  local bChangeSlot = false
  local bDownloading, DownloadInfo = self:_CheckTeamEditDownloading(TeamLeaderUid)
  if bDownloading and DownloadInfo.Slot ~= Slot then
    bChangeSlot = true
    ShowNotice(99009896)
    LogicUGCAssetHub:PauseList(DownloadInfo.DownloadSeq)
    self.TeamEditDownloadState[TeamLeaderUid] = nil
  end
  if not self.TeamEditDownloadState[TeamLeaderUid] then
    local TableUtil = require("common.table_util")
    local CustomAssetList = TableUtil.TableConcat(ModCustomAssetInfo or {}, LeaderCustomAssetList or {})
    CustomAssetList = TableUtil.ArrayUnique(CustomAssetList)
    local DownloadSeq = LogicUGCAssetHub:GetModSeqKeyByTeam(TeamLeaderUid)
    self.TeamEditDownloadState[TeamLeaderUid] = {
      Slot = Slot,
      TemplateID = TemplateID,
      CustomAssetList = CustomAssetList,
      DownloadSeq = DownloadSeq,
      State = PufferConst.ENUM_DownloadState.Not
    }
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    if LogicUGCResManager:IsCompleteUGCTemplateResByTeam(TemplateID, nil, CustomAssetList) then
      self:UpdateTeamEditDownloadState(TeamLeaderUid, PufferConst.ENUM_DownloadState.Done)
      print(bWriteLog and "LogicUGCCRUD:OnUgcNotifyCustomAssetInfoRsp check download done")
    end
  elseif self.TeamEditDownloadState[TeamLeaderUid].State == PufferConst.ENUM_DownloadState.Download then
    local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    if LogicUGCResManager:IsCompleteUGCTemplateResByTeam(TemplateID, nil, self.TeamEditDownloadState[TeamLeaderUid].CustomAssetList) then
      self:UpdateTeamEditDownloadState(TeamLeaderUid, PufferConst.ENUM_DownloadState.Done)
      ShowNotice(99009893)
      print(bWriteLog and "LogicUGCCRUD:OnUgcNotifyCustomAssetInfoRsp check download done")
    else
      local SelfUID = TeamUpNewSystem.GetSelfUID()
      if SelfUID == TeamLeaderUid then
        ShowNotice(99009891)
      else
        ShowNotice(99009892)
      end
    end
  end
  local TeamEditDownloadInfo = self:GetTeamEditDownloadInfo(TeamLeaderUid)
  local SelfUID = TeamUpNewSystem.GetSelfUID()
  if SelfUID == TeamLeaderUid then
    if TeamEditDownloadInfo.State == PufferConst.ENUM_DownloadState.Done then
      self:AddTimerOnce(1, function()
        local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
        UGCMatchHandler.send_ugc_team_download_captain_slot_req(false, TemplateID)
      end)
      self.TeamEditSyncTimer = self:AddTimerOnce(4, function()
        if self.TeamEditWaitAnswer then
          local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
          UGCMatchHandler.send_ugc_team_download_captain_slot_req(true, TemplateID)
        end
      end)
      logic_connection_waiting:Show(1)
      self.TeamEditWaitTimer = self:AddTimerOnce(10, function()
        self:HideTeamEditWaitUI()
      end)
    end
  elseif TeamEditDownloadInfo.State == PufferConst.ENUM_DownloadState.Done then
    print(bWriteLog and "LogicUGCCRUD:OnUgcNotifyCustomAssetInfoRsp ready download done")
  elseif UIManager.IsUIShow(UIManager.UI_Config.UGC_TeamDownload_Popup_UIBP) then
    if bChangeSlot then
      local Popup = UIManager.GetUI(UIManager.UI_Config.UGC_TeamDownload_Popup_UIBP)
      Popup:UpdateData(TeamLeaderUid)
    end
  else
    UIManager.ShowUI(UIManager.UI_Config.UGC_TeamDownload_Popup_UIBP, TeamLeaderUid)
  end
end
function LogicUGCCRUD:UpdateTeamEditDownloadState(TeamLeaderUid, State)
  local TeamEditDownloadInfo = self:GetTeamEditDownloadInfo(TeamLeaderUid)
  if not TeamEditDownloadInfo then
    return
  end
  TeamEditDownloadInfo.  if State == PufferConst.ENUM_DownloadState.Done then
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_TeamEdit_Download_Done)
  end
end
function LogicUGCCRUD:_CancelTeamEditDownload(TeamLeaderUid)
  local TeamEditDownloadInfo = self:GetTeamEditDownloadInfo(TeamLeaderUid)
  if not TeamEditDownloadInfo then
    return
  end
  local LogicUGCAssetHub = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAssetHub)
  LogicUGCAssetHub:PauseList(TeamEditDownloadInfo.DownloadSeq)
  self.TeamEditDownloadState[TeamLeaderUid] = nil
end
function LogicUGCCRUD:CheckCancelTeamEditDownloading(TeamLeaderUid, NoticeID)
  local TeamEditDownloadInfo = self:GetTeamEditDownloadInfo(TeamLeaderUid)
  if TeamEditDownloadInfo and TeamEditDownloadInfo.State == PufferConst.ENUM_DownloadState.Download then
    self:_CancelTeamEditDownload(TeamLeaderUid)
    ShowNotice(NoticeID)
    local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
    UGCTLogReport:ReportDelay(TLogEventDefine.UGC_TeamEdit_Break)
    return true
  end
  return false
end
function LogicUGCCRUD:RejectTeamEditDownload(LeadUID, MemberUID, asset_type)
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  local SelfUID = TeamUpNewSystem.GetSelfUID()
  if SelfUID ~= LeadUID then
    return
  end
  self:HideTeamEditWaitUI()
  local MemberName = TeamUpNewSystem.GetMemberName(MemberUID)
  if MemberName then
    local Tip = LocUtil.LocalizeResFormat(99009902, MemberName)
    ShowNotice(Tip)
  else
    ShowNotice(512031)
  end
end
function LogicUGCCRUD:AnswerTeamEditDownloadFinish(ModKey, State)
  local StrSplit = StringUtil.Split(ModKey, "_")
  local TeamLeaderUid = tonumber(StrSplit[1])
  if not TeamLeaderUid then
    return
  end
  self:UpdateTeamEditDownloadState(TeamLeaderUid, State)
end
function LogicUGCCRUD:OnUgcTeamDownloadCaptainSlotRsp(err_code, team_leader_uid, no_mod_uids, template_id)
  if err_code == 511044 then
    local State = PufferConst.ENUM_DownloadState.Not
    local TeamEditDownloadInfo = self.TeamEditDownloadState[team_leader_uid]
    if TeamEditDownloadInfo then
      State = TeamEditDownloadInfo.State
    else
      print(bWriteLog and "LogicUGCCRUD:OnUgcNotifyCustomAssetInfoRsp not trigger OnUgcNotifyCustomAssetInfoRsp")
    end
    local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
    resManager:Send_update_client_mod_info_ByTeamRes(team_leader_uid, State)
    log(bWriteLog and "LogicUGCCRUD:OnUgcTeamDownloadCaptainSlotRsp err_code == 511044 leaderUid:" .. tostring(team_leader_uid))
  elseif err_code == 511045 then
    self:HideTeamEditWaitUI()
    if no_mod_uids then
      local names = ""
      local teamSystem = require("client.slua.logic.teamup.logic_team_up")
      for _, uid in pairs(no_mod_uids) do
        local memName = teamSystem.GetMemberName(uid)
        if memName then
          if 0 < #names then
            names = names .. "\239\188\140" .. memName
          else
            names = memName
          end
        end
      end
      if 0 < #names then
        local tipContent = LocUtil.LocalizeResFormat(48452, names)
        ShowNotice(tipContent)
      else
        local tipContent = LocUtil.GetLocalizeResStr(512031)
        ShowNotice(tipContent)
      end
      log(bWriteLog and "LogicUGCCRUD:OnUgcTeamDownloadCaptainSlotRsp err_code == 511045 names:" .. names)
    end
  elseif err_code == 0 then
    ShowNotice(99009894)
    self:HideTeamEditWaitUI()
    log(bWriteLog and "LogicUGCCRUD:OnUgcTeamDownloadCaptainSlotRsp err_code == 0 ")
    if self.TeamEditSlot and 0 < self.TeamEditSlot then
      self:ReqStartEditGame(self.TeamEditSlot, false)
    end
  elseif err_code == 64240 then
    log_tree("LogicUGCCRUD:OnUgcTeamDownloadCaptainSlotRsp err_code == 64240 no_mod_uids = ", no_mod_uids)
    if no_mod_uids then
      local maxCount = 3
      local names = ""
      local nameCount = 0
      local hasMore = false
      local teamSystem = require("client.slua.logic.teamup.logic_team_up")
      for _, uid in pairs(no_mod_uids) do
        local memName = teamSystem.GetMemberName(uid)
        if memName then
          if maxCount > nameCount then
            if 0 < #names then
              names = names .. "\239\188\140" .. memName
            else
              names = memName
            end
            nameCount = nameCount + 1
          else
            hasMore = true
            break
          end
        end
      end
      if hasMore then
        names = names .. "..."
      end
      if 0 < #names then
        local tipContent = LocUtil.LocalizeResFormat(10120061, names)
        ShowNotice(tipContent)
      else
        local tipContent = LocUtil.GetLocalizeResStr(512031)
        ShowNotice(tipContent)
      end
    end
  else
    self:HideTeamEditWaitUI()
    log(bWriteLog and "LogicUGCCRUD:OnUgcTeamDownloadCaptainSlotRsp other err_code")
    ShowNotice(err_code)
  end
end
function LogicUGCCRUD:OnQuitTeam()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  self:CheckCancelTeamEditDownloading(TeamUpNewSystem.GetTeamLeader() or 0, 99009897)
end
function LogicUGCCRUD:OnTeamChangeLeader()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  self:CheckCancelTeamEditDownloading(TeamUpNewSystem.GetTeamLeader() or 0, 99009897)
end
function LogicUGCCRUD:OnChangeMod()
  local TeamUpNewSystem = require("client.slua.logic.teamup.logic_team_up")
  self:CheckCancelTeamEditDownloading(TeamUpNewSystem.GetTeamLeader() or 0, 99009895)
end
function LogicUGCCRUD:OnCancelPubModRsp(slot)
  local modInfo = self.modList[slot]
  if modInfo then
    local Config_UGC = require("client.slua.logic.ugc.config_ugc")
    modInfo.base.state_release = Config_UGC.E_PublishState.Not
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MODIFY_MOD, slot)
end
function LogicUGCCRUD:ReqDeleteModAlbum(slot, index)
  if not slot then
    return
  end
  if not index then
    return
  end
  local UGCPublishHandler = require("client.network.Protocol.UGCPublishHandler")
  UGCPublishHandler.send_ugc_delete_mod_album_req(slot, index)
end
function LogicUGCCRUD:OnDeleteModAlbumRsp(slot, edit_mod_meta)
  self.modList[slot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_MODIFY_MOD, slot)
end
function LogicUGCCRUD:ReqStartNewbieGuideTemplate(templateId, beginnerlevelId)
  log(bWriteLog and "LogicUGCCRUD:ReqStartNewbieGuideTemplate")
  if not templateId then
    log(bWriteLog and "LogicUGCCRUD:ReqStartNewbieGuideTemplate no templateId")
    return
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  if not Config_UGC.GetTemplateConfigByID(templateId) then
    ShowNotice(511011)
    return
  end
  if LobbySystem.isInMatch then
    ShowNotice(6244)
    return
  end
  local resManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  resManager:Send_update_client_mod_info_NewbieGuideTemplate(templateId)
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:SetUGCWaitingEnterGame(true)
  print(bWriteLog and "LogicUGCCRUD:ReqStartNewbieGuideTemplate AddTimeoutTimer")
  self.EnterGameTimeoutCheckTimer = self:AddTimerOnce(60, function()
    print(bWriteLog and "LogicUGCCRUD:ReqStartNewbieGuideTemplate TimerOut")
    self.EnterGameTimeoutCheckTimer = nil
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.RefreshLoadPercent(1)
    local _LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
    _LogicUGCMatch:SetUGCWaitingEnterGame(false)
  end)
  self.bToEditMod = true
  local UGCMatchHandler = require("client.network.Protocol.UGCMatchHandler")
  UGCMatchHandler.send_start_ugc_novice_game_req(templateId, beginnerlevelId)
  log(bWriteLog and "[v_chenxxue]LogicUGCCRUD:ReqStartNewbieGuideTemplat beginnerlevelId " .. tostring(beginnerlevelId))
  if beginnerlevelId ~= nil then
    self:SetShowUGCCenterMainUI(true)
    self:SetLastStartNewbie(true)
  end
  if LogicUGCMatch.bUseDirectEdit then
    local LoadingSystem = require("client.slua.logic.loading.logic_loading")
    LoadingSystem.ShowLoading()
  end
end
function LogicUGCCRUD:OnStartUGCNoviceGameRsp(err_code)
  log(bWriteLog and "LogicUGCCRUD:OnStartUGCNoviceGameRsp")
  if err_code == 0 then
    if self.bToEditMod then
      LobbySystem.SetWaitingBattleFlag(true)
      if NetUtil then
        NetUtil.StartCheckEnterBattle(0)
      end
    end
    return
  end
  self:StopToEditMod()
end
function LogicUGCCRUD:SetLastStartNewbie(bFlag)
  print(bWriteLog and "LogicUGCCRUD:SetLastStartNewbie " .. tostring(bFlag))
  self.bLastStartIsNewbie = bFlag
end
function LogicUGCCRUD:IsLastStartNewbie()
  print(bWriteLog and "LogicUGCCRUD:bLastStartIsNewbie " .. tostring(self.bLastStartIsNewbie))
  return self.bLastStartIsNewbie
end
function LogicUGCCRUD:StopToEditMod()
  self.bToEditMod = false
  local LoadingSystem = require("client.slua.logic.loading.logic_loading")
  if LoadingSystem.IsShowing() then
    LoadingSystem.RefreshLoadPercent(1)
  end
  local LogicUGCMatch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCMatch)
  LogicUGCMatch:SetUGCWaitingEnterGame(false)
end
function LogicUGCCRUD:ReqModVersionRollBack(mod_id, version_timestamp, replace_slot)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_mod_version_rollback_req(mod_id, version_timestamp, replace_slot)
end
function LogicUGCCRUD:RspModVersionRollBack(newSlot, edit_mod_meta, copy_limit, mod_id)
  self.modList[newSlot] = edit_mod_meta
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_ROLLBACK_MOD, newSlot)
  ShowNotice(105001)
  self:OnDuplicateNotify(copy_limit, mod_id)
  local UGCTLogReport = ModuleManager.GetModule(ModuleManager.DataModuleConfig.UGCTLogReport)
  UGCTLogReport:ReportDelay(TLogEventDefine.UGC_HistoryVersion_RollBack, DataMgr.roleData.uid, newSlot)
end
function LogicUGCCRUD:CheckVersionExpiration(data)
  local TimeUtil = require("client.common.time_util")
  local isWithInOneYear = TimeUtil.WithinInNDay(data.update_time, 360)
  if data.update_flag == 1 and not isWithInOneYear then
    return true
  else
    return false
  end
end
function LogicUGCCRUD:GetDraftBoxLimit()
  local min_cnt = 6
  if self.DraftBox_Limit then
    return self.DraftBox_Limit
  end
  local LogicUGCAuthor = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCAuthor)
  local AuthorInfo = LogicUGCAuthor:GetMineAuthorInfo()
  if not AuthorInfo then
    log(bWriteLog and "LogicUGCCRUD:GetDraftBoxLimit  AuthorInfo is nil")
    return min_cnt
  end
  local author_info = CDataTable.GetTableData("UGCAuthorLevelConfig", AuthorInfo.new_level or 0)
  if not author_info then
    log(bWriteLog and "LogicUGCCRUD:GetDraftBoxLimit  author_info is nil")
    return min_cnt
  end
  return author_info.EditModMaxNum or min_cnt
end
function LogicUGCCRUD:SetPubCDRemain(cd_remain)
  self.CDRemain = cd_remain
  log(bWriteLog and "LogicUGCCRUD:SetPubCDRemain = " .. tostring(cd_remain))
  local time_ticker = require("common.time_ticker")
  if self.PubCDRemainTimer == nil then
    self.PubCDRemainTimer = time_ticker.AddTimerLoop(0, function()
      if not self.CDRemain or self.CDRemain <= 0 then
        self:ClearCDRemain()
        return
      end
      self.CDRemain = self.CDRemain - 1
      if UIManager.IsUIShow(UIManager.UI_Config.ugc_mine_edit_noromal_work) then
        EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PUBCD_REMAIN_CHANGED, self.CDRemain)
      end
    end, TIMER_INFINITE, 1)
  end
end
function LogicUGCCRUD:ClearCDRemain()
  log(bWriteLog and "LogicUGCCRUD:ClearCDRemain")
  if self.PubCDRemainTimer then
    local time_ticker = require("common.time_ticker")
    time_ticker.RemoveTimer(self.PubCDRemainTimer)
    self.PubCDRemainTimer = nil
  end
  self.CDRemain = nil
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_PUBCD_REMAIN_CHANGED, -1)
end
function LogicUGCCRUD:OnNextDayZeroCome()
  log(bWriteLog and "LogicUGCCRUD:OnNextDayZeroCome")
  self:ClearCDRemain()
end
function LogicUGCCRUD:SwitchPrivateState(mod_id, private_state)
  local UGCModHandler = require("client.network.Protocol.UGCModHandler")
  UGCModHandler.send_ugc_toggle_publish_state_req(mod_id, private_state)
end
function LogicUGCCRUD:OnTogglePublishStateRsp(mod_id, new_state)
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_SWITCH_PRIVATE_STATE, mod_id, new_state)
end
function LogicUGCCRUD:CheckPubModIsPrivate(meta)
  local state_release = meta.base.state_release or -1
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  local BPrivate = state_release == config_ugc.E_PublishState.Private
  log(bWriteLog and "LogicUGCCRUD:CheckPubModIsPrivate: BPrivate = " .. tostring(BPrivate) .. " mod_id = " .. tostring(meta.mod_id))
  return BPrivate
end
function LogicUGCCRUD:CheckEditModIsPrivate(edit_meta)
  local publish_state = edit_meta.setting.publish_state or -1
  local config_ugc = require("client.slua.logic.ugc.config_ugc")
  local BPrivate = publish_state == config_ugc.E_ModPubState.Private
  log(bWriteLog and "LogicUGCCRUD:CheckEditModIsPrivate: BPrivate = " .. tostring(BPrivate) .. " mod_name = " .. tostring(edit_meta.setting.name))
  return BPrivate
end
function LogicUGCCRUD:CheckUGCDetailUINeedHide(meta)
  local BPrivate = self:CheckPubModIsPrivate(meta)
  if tonumber(meta.base.uid) ~= tonumber(DataMgr.roleData.uid) and BPrivate then
    return true
  end
  return false
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCCRUD = class(CModuleBase, nil, LogicUGCCRUD)
return CLogicUGCCRUD