local C_Check_Collect_Badge_Exists_Path = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Level_UIBP.Common_Collect_Level_UIBP"
local Common_Collect_Level_DynamicLoading_UIBP = {}
function Common_Collect_Level_DynamicLoading_UIBP:OnPostInitialize()
  self._bIsShow = true
end
function Common_Collect_Level_DynamicLoading_UIBP:OnClose()
  self._cObj_ui = nil
  self._uid = nil
  self._extraPara = nil
  self._bIsShow = false
end
function Common_Collect_Level_DynamicLoading_UIBP:InitCollectBadge(uid, collect_data, isShowTips, extendedParam)
  if not self:_CheckDataValid(uid, collect_data) then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  local extraPara = extendedParam or {}
  extraPara.collectData = collect_data
  extraPara.showCollectTips = isShowTips
  self._  self._  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not PufferManager.CheckDownloadEnvironment(C_Check_Collect_Badge_Exists_Path) then
    return
  end
  self:_CreateBadge(uid, extraPara)
end
function Common_Collect_Level_DynamicLoading_UIBP:_CreateBadge()
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  if collect_module.OPEN_COLLECT_DOWNLOAD_MARK and not self:_CheckAssetExists() then
    self:SetWidgetVisible(self.CanvasPanel_DownLoading, true)
    return
  end
  self:SetWidgetVisible(self.CanvasPanel_DownLoading, false)
  if self._cObj_ui then
    self._cObj_ui:Close()
    self._cObj_ui = nil
  end
  self._cObj_ui = self:CreateChildWindow(self.CanvasPanel_CollectLevelItem, UIManager.UI_Config.Common_Collect_Level_UIBP, self._uid, self._extraPara)
end
function Common_Collect_Level_DynamicLoading_UIBP:_CheckAssetExists()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {C_Check_Collect_Badge_Exists_Path})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {C_Check_Collect_Badge_Exists_Path}, PufferTlog.Enum_TLog_From.Click, function()
      if not self._bIsShow then
        return
      end
      if not self._cObj_ui then
        self:_CreateBadge()
      end
    end)
    return false
  end
  return true
end
function Common_Collect_Level_DynamicLoading_UIBP:_CheckDataValid(uid, collectData)
  if not uid then
    log(bWriteLog and string.format("Common_Collect_Level_DynamicLoading_UIBP:_CheckDataValid uid is nil"))
    return false
  end
  if not collectData or not next(collectData) then
    log(bWriteLog and string.format("Common_Collect_Level_DynamicLoading_UIBP:_CheckDataValid collectData is nil or empty"))
    return false
  end
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  local privacy = collectData.privacy or {}
  if not collect_privacy_module:CanShowCollectLevel(privacy) then
    log(bWriteLog and string.format("Common_Collect_Level_DynamicLoading_UIBP:_CheckDataValid privacy is not open"))
    return false
  end
  return true
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
local CVersionAlbum_Entrance_UIBP = class(OverrideUIBase, nil, Common_Collect_Level_DynamicLoading_UIBP)
return CVersionAlbum_Entrance_UIBP