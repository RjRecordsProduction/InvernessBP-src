local Logic_SC_DownloadTools = {}
local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
local Logic_SocialLobbyConst = require("client.slua.logic.lobby.Left.SocialHallConst.Logic_SocialLobbyConst")
function Logic_SC_DownloadTools.GetSocialLobbyDownloadResList(nUId)
  nUId = nUId or tonumber(DataMgr.roleData.uid)
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local sLevelName = Logic_SocialLobbyModule:GetSocialLobbyShowSceneName(nUId)
  if not sLevelName then
    return {}
  end
  local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  local sLevelResPath = lobby_scene_module:GetStreamLevelFullPathByName(sLevelName)
  return {sLevelResPath}
end
function Logic_SC_DownloadTools.GetSocialLobbyResIsDownloaded(nUId)
  nUId = nUId or tonumber(DataMgr.roleData.uid)
  local Logic_SocialLobbyModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_SocialLobbyModule)
  local sLevelName = Logic_SocialLobbyModule:GetSocialLobbyShowSceneName(nUId)
  if not sLevelName then
    return false
  end
  local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
  local bIsDownloaded = lobby_scene_module:IsLevelDownloaded(sLevelName)
  return bIsDownloaded
end
function Logic_SC_DownloadTools.ShowSocialLobbyDownloadPopup(nUId, fDownloadFinishCallback)
  local tDownloadResList = Logic_SC_DownloadTools.GetSocialLobbyDownloadResList(nUId)
  local sResSize = PufferManager.GetSize2MBStr(PufferConst.ENUM_DownloadType.ODPAK, tDownloadResList)
  local sDownloadTip = LocUtil.LocalizeResFormat(7921, sResSize)
  fDownloadFinishCallback = fDownloadFinishCallback or function()
    local logic_lobby_main_page_jump = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_lobby_main_page_jump)
    logic_lobby_main_page_jump:JumpToPage(ENUM_LobbyPageType.Left)
  end
  local tShowData = {
    tDownloadResList = tDownloadResList,
    sDownloadTip = sDownloadTip,
    nDownloadType = PufferConst.ENUM_DownloadType.ODPAK,
    fOkCallback = fDownloadFinishCallback,
    sDownloadFinishTip = LocUtil.GetLocalizeResStr(880060013),
    nPufferTLog = PufferTlog.Enum_TLog_From.SocialLobby
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_DownloadPopup_UIBP, tShowData)
end
function Logic_SC_DownloadTools.GetPlanCHIsOpen()
  local tCollectHallData = DataMgr.GetCollectHallData()
  if not tCollectHallData or tCollectHallData.is_func_open == nil then
    return false
  end
  log(bWriteLog and "Logic_SC_DownloadTools.GetPlanCHIsOpen >>> tCollectHallData.is_func_open = " .. tostring(tCollectHallData.is_func_open))
  return tCollectHallData.is_func_open
end
function Logic_SC_DownloadTools.GetMapDownloadData()
  return {
    Logic_SocialLobbyConst.COLLECTION_MOD_PAK_NAME
  }
end
function Logic_SC_DownloadTools.GetNeedDownloadBroadcastId(nUId)
  local nBroadcastId
  if tostring(nUId) == tostring(DataMgr.roleData.uid) then
    local tCollectData = DataMgr.GetCollectHallData()
    nBroadcastId = tCollectData.broadcast_id
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local tProfile = logic_profile:GetLocalProfile(nUId)
    if not tProfile then
      log(bWriteLog and "Logic_SC_DownloadTools.GetNeedDownloadBroadcastId - tProfile is nil, nUId: " .. tostring(nUId))
      return nil
    elseif not tProfile.collect_hall_data then
      log(bWriteLog and "Logic_SC_DownloadTools.GetNeedDownloadBroadcastId - tProfile.collect_hall_data is nil, nUId: " .. tostring(nUId))
      return nil
    end
    nBroadcastId = tProfile.collect_hall_data.broadcast_id
  end
  return nBroadcastId
end
function Logic_SC_DownloadTools.GetNeedDownloadSkin(nUId)
  local nSkinItemId
  if tostring(nUId) == tostring(DataMgr.roleData.uid) then
    local tCollectData = DataMgr.GetCollectHallData()
    nSkinItemId = tCollectData.skin_id
  else
    local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
    local tProfile = logic_profile:GetLocalProfile(nUId)
    if not tProfile then
      log(bWriteLog and "Logic_SC_DownloadTools.GetNeedDownloadSkin - tProfile is nil, nUId: " .. tostring(nUId))
      return nil
    elseif not tProfile.collect_hall_data then
      log(bWriteLog and "Logic_SC_DownloadTools.GetNeedDownloadSkin - tProfile.collect_hall_data is nil, nUId: " .. tostring(nUId))
      return nil
    end
    nSkinItemId = tProfile.collect_hall_data.skin_id
  end
  return nSkinItemId
end
function Logic_SC_DownloadTools.GetPlanCHDownloadResMap(nUId, nSkinItemId)
  local tDownloadResMap = {
    [PufferConst.ENUM_DownloadType.MAP] = Logic_SC_DownloadTools.GetMapDownloadData(),
    [PufferConst.ENUM_DownloadType.ODPAK] = {
      "/Game/UMG/UI_BP/Lobby/SocialLobby/StaticMesh/BP/PlanCH_CrystalStatue.PlanCH_CrystalStatue"
    }
  }
  local nBroadcastId = Logic_SC_DownloadTools.GetNeedDownloadBroadcastId(nUId)
  if nBroadcastId then
    table.insert(tDownloadResMap[PufferConst.ENUM_DownloadType.ODPAK], nBroadcastId)
  end
  nSkinItemId = nSkinItemId or Logic_SC_DownloadTools.GetNeedDownloadSkin(nUId)
  if nSkinItemId then
    local sSkinResPath = Logic_SC_DownloadTools.GetSkinResPath(nSkinItemId)
    if sSkinResPath then
      table.insert(tDownloadResMap[PufferConst.ENUM_DownloadType.ODPAK], sSkinResPath)
    end
    local uSkinSceneCfg = CDataTable.GetTableData("SocialLobby_SkinScene", nSkinItemId)
    if uSkinSceneCfg then
      local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
      local sLevelResPath = lobby_scene_module:GetStreamLevelFullPathByName(uSkinSceneCfg.scene_name)
      table.insert(tDownloadResMap[PufferConst.ENUM_DownloadType.ODPAK], sLevelResPath)
    end
  end
  return tDownloadResMap
end
function Logic_SC_DownloadTools.GetPlanCHDownloadTypeAndResList(nUId, nSkinItemId)
  local tDownloadResMap = Logic_SC_DownloadTools.GetPlanCHDownloadResMap(nUId, nSkinItemId)
  local nDownloadResType = PufferConst.ENUM_DownloadType.Map
  local tDownloadResList = {}
  local nTypeCount = 0
  for nDownloadType, tResList in pairs(tDownloadResMap) do
    if next(tResList) then
      nTypeCount = nTypeCount + 1
    end
    if nTypeCount == 1 then
      nDownloadResType = nDownloadType
    else
      nDownloadResType = nil
    end
    for _, v in pairs(tResList) do
      table.insert(tDownloadResList, v)
    end
  end
  return nDownloadResType, tDownloadResList
end
function Logic_SC_DownloadTools.CheckPlanCHIsDownloaded(nUId, nSkinItemId)
  local nDoneDownloadState = PufferConst.ENUM_DownloadState.Done
  local tDownloadResMap = Logic_SC_DownloadTools.GetPlanCHDownloadResMap(nUId, nSkinItemId)
  for k, v in pairs(tDownloadResMap) do
    if PufferManager.GetState(k, v) ~= nDoneDownloadState then
      return false
    end
  end
  return true
end
function Logic_SC_DownloadTools.ShowPlanCHDownloadPopup(nUId, fDownloadFinishCallback, nSkinItemId)
  local tDownloadResMap = Logic_SC_DownloadTools.GetPlanCHDownloadResMap(nUId, nSkinItemId)
  local nDownloadDoneState = PufferConst.ENUM_DownloadState.Done
  local nCurSize = 0
  local nTotalSize = 0
  for nDownloadType, tResList in pairs(tDownloadResMap) do
    if PufferManager.GetState(nDownloadType, tResList) ~= nDownloadDoneState then
      local nTempCurSize, nTempTotalSize = PufferManager.GetSize(nDownloadType, tResList)
      nCurSize = nCurSize + nTempCurSize
      nTotalSize = nTotalSize + nTempTotalSize
    end
  end
  local nNeedDownloadSize = nTotalSize - nCurSize
  local sResSize = PufferManager.ResSizeToMBStr(nNeedDownloadSize)
  local sDownloadTip = LocUtil.LocalizeResFormat(7921, sResSize)
  local nDownloadType, tDownloadResList = Logic_SC_DownloadTools.GetPlanCHDownloadTypeAndResList(nUId, nSkinItemId)
  local tShowData = {
    tDownloadResList = tDownloadResList,
    sDownloadTip = sDownloadTip,
    nDownloadType = nDownloadType,
    fOkCallback = fDownloadFinishCallback,
    fCheckDownloadFinish = function()
      return Logic_SC_DownloadTools.CheckPlanCHIsDownloaded(nUId, nSkinItemId)
    end,
    sDownloadFinishTip = LocUtil.GetLocalizeResStr(880060013),
    nPufferTLog = PufferTlog.Enum_TLog_From.CollectionHall
  }
  UIManager.ShowUI(UIManager.UI_Config.Common_DownloadPopup_UIBP, tShowData)
end
function Logic_SC_DownloadTools.GetSkinResPath(nSkinItemId)
  local uSkinResCfg = CDataTable.GetTableData("PlanCH_SkinResCfg", nSkinItemId)
  return uSkinResCfg and uSkinResCfg.SkinResPath
end
function Logic_SC_DownloadTools.GetSkinDownloadResList(nSkinItemId)
  local tDownloadResList = {}
  local sSkinResPath = Logic_SC_DownloadTools.GetSkinResPath(nSkinItemId)
  if sSkinResPath then
    table.insert(tDownloadResList, sSkinResPath)
  end
  local uSkinSceneCfg = CDataTable.GetTableData("SocialLobby_SkinScene", nSkinItemId)
  if uSkinSceneCfg then
    local lobby_scene_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.lobby_scene_module)
    local sLevelResPath = lobby_scene_module:GetStreamLevelFullPathByName(uSkinSceneCfg.scene_name)
    table.insert(tDownloadResList, sLevelResPath)
  end
  return tDownloadResList
end
function Logic_SC_DownloadTools.GetIsDownloadedHallSkinRes(nSkinItemId)
  if IsEditor then
    local PlanCH_GamePlay_Tools = require("GameLua.Mod.PlanCH.Tools.PlanCH_GamePlay_Tools")
    if PlanCH_GamePlay_Tools.IsLocalBoot() then
      return true
    end
  end
  local tDownloadResList = Logic_SC_DownloadTools.GetSkinDownloadResList(nSkinItemId)
  return PufferManager.GetListIsDownloaded(PufferConst.ENUM_DownloadType.ODPAK, tDownloadResList)
end
return Logic_SC_DownloadTools