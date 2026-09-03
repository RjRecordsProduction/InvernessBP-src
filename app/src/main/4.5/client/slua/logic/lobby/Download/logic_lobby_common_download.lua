local logic_lobby_common_download = {}
function logic_lobby_common_download:DefineAndResetData()
  log_format("logic_lobby_common_download:DefineAndResetData.")
end
function logic_lobby_common_download:RegistEvents()
  log_format("logic_lobby_common_download:RegistEvents.")
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_COMMON_DOWNLOAD_POPUP, self._OnUrlEvent, self)
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsFITVersion() and not LogicPufferBundle.bFitLobbyResExist then
    self:AddCommonEvent(EVENTTYPE_PUFFER, EVENTID_PUFFER_DOWNLOADFINISH, self._OnFitLobbyResCheck, self)
  end
end
function logic_lobby_common_download:ShowDownloadPopup(tShowData)
  if not self:CheckCanDownload(tShowData) then
    log_warning(bWriteLog and "logic_lobby_common_download:ShowDownloadPopup, CheckCanDownload return false")
    return
  end
  if not self:_CheckCanShow() then
    log_warning(bWriteLog and "logic_lobby_common_download:ShowDownloadPopup, _CheckCanShow return false")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Common_DownloadPopup_UIBP, tShowData)
end
function logic_lobby_common_download:_OnUrlEvent(_, _, params)
  log_tree("logic_lobby_common_download:_OnUrlEvent. params = ", params)
  local tShowData = {
    tDownloadResList = {
      params.key
    },
    nDownloadType = tonumber(params.type),
    sDownloadTip = LocUtil.GetLocalizeResStr(params.popupDownloadTipsId),
    sDownloadFinishTip = LocUtil.GetLocalizeResStr(params.popupFinishTipsId),
    finishTipsId = params.finishTipsId,
    bIsUGCMod = false
  }
  if params.key and params.key == "map_planbt" then
    local Logic_UGC_Template = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
    local ModInfo = Logic_UGC_Template:ReadLocalMeta(53)
    ModInfo.base.mod_id = params.key
    ModInfo.mod_id = params.key
    tShowData.tExtraData = {UGCModInfo = ModInfo}
    tShowData.bIsUGCMod = true
    function tShowData.fCheckDownloadFinish()
      local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
      return LogicUGCResManager:IsCompleteRes(LogicUGCResManager.DownloaderType.ModCopy, ModInfo)
    end
  end
  log_tree("logic_lobby_common_download:_OnUrlEvent. tShowData = ", tShowData)
  self:ShowDownloadPopup(tShowData)
end
function logic_lobby_common_download:CheckCanDownload(tShowData)
  if not (tShowData and tShowData.tDownloadResList) or not next(tShowData.tDownloadResList) then
    log_warning(bWriteLog and "logic_lobby_common_download:CheckCanDownload, tShowData is nil or tDownloadResList is nil")
    return false
  end
  if not tShowData.nDownloadType then
    log_warning(bWriteLog and "logic_lobby_common_download:CheckCanDownload, nDownloadType is nil")
    return false
  end
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local nDownloadState = PufferManager.GetState(tShowData.nDownloadType, tShowData.tDownloadResList)
  log_format("logic_lobby_common_download:CheckCanDownload, nDownloadState = %s", nDownloadState)
  if nDownloadState == PufferConst.ENUM_DownloadState.Done and tShowData.finishTipsId ~= nil then
    ShowNotice(tShowData.finishTipsId)
    return false
  end
  return true
end
function logic_lobby_common_download:_CheckCanShow()
  if not GameStatus.IsInLobbyOrMainCity() then
    log_warning(bWriteLog and "logic_lobby_common_download:_CheckCanShow not in lobby or main city")
    return false
  end
  return true
end
function logic_lobby_common_download:_OnFitLobbyResCheck()
  log_format("logic_lobby_common_download:_OnFitLobbyResCheck.")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if LogicPufferBundle.IsFitLobbyResDownloaded() then
    LogicPufferBundle.OnFitLobbyResDownloadFinish()
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_lobby_common_download = class(CModuleBase, nil, logic_lobby_common_download)
return Clogic_lobby_common_download