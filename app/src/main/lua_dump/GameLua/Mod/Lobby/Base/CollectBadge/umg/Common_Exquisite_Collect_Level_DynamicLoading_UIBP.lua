local Common_Exquisite_Collect_Level_DynamicLoading_UIBP = {}
local C_Check_Exquisite_Collect_Badge_Exists_Path = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_1_UIBP.Common_Collect_Achievement_Level_1_UIBP"
local Const_SubCollect_Level_Config = {
  [1] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_1_UIBP.Common_Collect_Achievement_Level_1_UIBP",
  [2] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_2_UIBP.Common_Collect_Achievement_Level_2_UIBP",
  [3] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_3_UIBP.Common_Collect_Achievement_Level_3_UIBP",
  [4] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_4_UIBP.Common_Collect_Achievement_Level_4_UIBP",
  [5] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_5_UIBP.Common_Collect_Achievement_Level_5_UIBP",
  [6] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_6_UIBP.Common_Collect_Achievement_Level_6_UIBP",
  [7] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_7_UIBP.Common_Collect_Achievement_Level_7_UIBP",
  [8] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_9_UIBP.Common_Collect_Achievement_Level_9_UIBP"
}
local Const_SubCollect_Level_Small_Config = {
  [1] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_1_UIBP.Common_Collect_Achievement_Level_Small_1_UIBP",
  [2] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_2_UIBP.Common_Collect_Achievement_Level_Small_2_UIBP",
  [3] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_3_UIBP.Common_Collect_Achievement_Level_Small_3_UIBP",
  [4] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_4_UIBP.Common_Collect_Achievement_Level_Small_4_UIBP",
  [5] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_5_UIBP.Common_Collect_Achievement_Level_Small_5_UIBP",
  [6] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_6_UIBP.Common_Collect_Achievement_Level_Small_6_UIBP",
  [7] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Level_Small_7_UIBP.Common_Collect_Achievement_Level_Small_7_UIBP",
  [8] = "/Game/Mod/Lobby/Split/CollectBadge/Common_Collect_Achievement_Small_Level_9_UIBP.Common_Collect_Achievement_Small_Level_9_UIBP"
}
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:InitExquisiteCollectBadge(uid, extendedParam)
  self._uid = uid or DataMgr.roleData.uid
  self._extendedParam = extendedParam or {}
  if self._extendedParam.checkPrivacyData and not self:_CheckDataValid(self._extendedParam.checkPrivacyData) then
    self:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  self:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  self:SetDefaultIconAlpha()
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  if not PufferManager.CheckDownloadEnvironment(C_Check_Exquisite_Collect_Badge_Exists_Path) then
    return
  end
  self:_CreateBadge()
end
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:OnPostInitialize()
  self._bIsShow = true
end
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:OnClose()
  if self._cObj_ui then
    self._cObj_ui:Close()
    self._cObj_ui = nil
  end
  if self._cObj_highLight_ui then
    self._cObj_highLight_ui:Close()
    self._cObj_highLight_ui = nil
  end
  self._uid = nil
  self._extendedParam = nil
  self._bIsShow = false
end
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:SetDefaultIconAlpha()
  local alpha = 0.3
  if self._extendedParam and self._extendedParam.defaultIconAlpha then
    alpha = self._extendedParam.defaultIconAlpha
  end
  self.Def_Icon:SetColorAndOpacity(FLinearColor(1, 1, 1, alpha))
end
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:_CreateBadge()
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
  if self._cObj_highLight_ui then
    self._cObj_highLight_ui:Close()
    self._cObj_highLight_ui = nil
  end
  self._extendedParam = self._extendedParam or {}
  local rank = self._extendedParam.rank or 0
  if rank <= 0 then
    return
  end
  local path = ""
  if self._extendedParam.bUseSmall then
    path = Const_SubCollect_Level_Small_Config[rank]
  else
    path = Const_SubCollect_Level_Config[rank]
  end
  if not path then
    log(bWriteLog and string.format("Collect_Level_Item_UIBP:CreateBadge rank %d not found blueprint path.", rank))
    return
  end
  self._cObj_ui = self:CreateChildWindowWithBpPath(self.CanvasPanel_CollectLevelItem, UIManager.UI_Config.Common_Exquisite_Collect_Level_UIBP, path, self._uid, self._extendedParam)
  if self._cObj_ui and self._cObj_ui.light and rank < 7 then
    local HighlightPanel = self.CanvasPanel_Glow
    self:SetWidgetVisible(HighlightPanel, self._cObj_ui.light, false)
    self._cObj_highLight_ui = self:CreateChildWindow(HighlightPanel, UIManager.UI_Config.Common_Exquisite_Collect_Level_Bright_UIBP, rank)
  end
end
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:_CheckAssetExists()
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {C_Check_Exquisite_Collect_Badge_Exists_Path})
  if state ~= PufferConst.ENUM_DownloadState.Done then
    local PufferTlog = require("client.slua.logic.download.report.puffer_tlog")
    PufferManager.Download(PufferConst.ENUM_DownloadType.ODPAK, {C_Check_Exquisite_Collect_Badge_Exists_Path}, PufferTlog.Enum_TLog_From.Click, function()
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
function Common_Exquisite_Collect_Level_DynamicLoading_UIBP:_CheckDataValid(collectData)
  if not collectData or not next(collectData) then
    log(bWriteLog and string.format("Common_Exquisite_Collect_Level_DynamicLoading_UIBP:_CheckDataValid collectData is nil or empty"))
    return false
  end
  local collect_privacy_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_privacy_module)
  local privacy = collectData.privacy or {}
  if not collect_privacy_module:CanShowCollectLevel(privacy) then
    log(bWriteLog and string.format("Common_Exquisite_Collect_Level_DynamicLoading_UIBP:_CheckDataValid privacy is not open"))
    return false
  end
  return true
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
local CVersionAlbum_Entrance_UIBP = class(OverrideUIBase, nil, Common_Exquisite_Collect_Level_DynamicLoading_UIBP)
return CVersionAlbum_Entrance_UIBP