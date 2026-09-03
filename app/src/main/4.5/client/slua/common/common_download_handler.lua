local common_download_handler = {
  downloaderList = {},
  GC_CD = 5,
  GC_Time = 0,
  bIsCurrentSceneSkipDownload = false
}
common_download_handler.Enum_Align = {
  Left = 0,
  Mid = 1,
  Right = 2
}
local _DownloadUINodeName = "Common_Download_UI"
local PufferSwitch = require("client.slua.logic.download.puffer_switch")
local PufferConst = require("client.slua.logic.download.puffer_const")
local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
function common_download_handler.OnGameStateChange(eventType, eventID, vars)
  common_download_handler.UpdateCurrentSceneSkipDownload()
end
function common_download_handler.UpdateCurrentSceneSkipDownload()
  common_download_handler.bIsCurrentSceneSkipDownload = not GameStatus.InSupportDownloadState(true)
  log(bWriteLog and "common_download_handler.UpdateCurrentSceneSkipDownload. bIsCurrentSceneSkipDownload = " .. tostring(common_download_handler.bIsCurrentSceneSkipDownload))
end
function common_download_handler.CreateDownloadUI(downloadType, keyList, rootWidget, extraParams)
  log(bWriteLog and "common_download_handler.CreateDownloadUI downloadType = " .. tostring(downloadType))
  if common_download_handler.bIsCurrentSceneSkipDownload then
    return nil
  end
  if not rootWidget then
    return
  end
  if PufferSwitch.BanDownload then
    return
  end
  local downloader
  local state = PufferConst.ENUM_DownloadState.Done
  if downloadType == nil then
    if keyList and next(keyList) then
      local tmpList = {}
      for k, v in ipairs(keyList) do
        local type = PufferManager.GetDownloadType(v) or PufferConst.ENUM_DownloadType.ODPAK
        tmpList[1] = v
        if PufferManager.GetState(type, tmpList) ~= PufferConst.ENUM_DownloadState.Done then
          state = PufferConst.ENUM_DownloadState.Not
          break
        end
      end
    end
  else
    state = PufferManager.GetState(downloadType, keyList)
  end
  if state ~= PufferConst.ENUM_DownloadState.Done and keyList and next(keyList) then
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    downloader = common_download_handler.GetChild(rootWidget, _DownloadUINodeName)
    if not downloader then
      downloader = slua.loadUI("/Game/UMG/UI_BP/Common/Common_Download_UI.Common_Download_UI")
      rootWidget:AddChild(downloader)
    end
    if downloader then
      downloader:SetData(downloadType, keyList, extraParams)
    end
  else
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    local cache = common_download_handler.GetChild(rootWidget, _DownloadUINodeName)
    if cache and cache.RemoveRefreshTimer then
      cache:RemoveRefreshTimer()
    end
    if extraParams and extraParams.callback_no_need_down then
      extraParams.callback_no_need_down()
    end
  end
  return downloader
end
function common_download_handler.CreateDownloadUIReturnUIBase(downloadType, keyList, parentUIBase, parentPanel, extraParams)
  local firstItem = keyList and keyList[1]
  printf("common_download_handler.CreateDownloadUIReturnUIBase. downloadType=%s, firstItem=%s, parentUIBase=%s", tostring(downloadType), tostring(firstItem), tostring(parentUIBase))
  if common_download_handler.bIsCurrentSceneSkipDownload then
    return nil
  end
  if not parentPanel then
    return
  end
  if PufferSwitch.BanDownload then
    return nil
  end
  if not parentUIBase._childUI_Common_Download_UI_List then
    parentUIBase._childUI_Common_Download_UI_List = {}
  end
  local childUI_Common_Download_UI
  local state = PufferConst.ENUM_DownloadState.Done
  if downloadType == nil then
    if keyList and next(keyList) then
      local tmpList = {}
      for k, v in ipairs(keyList) do
        local type = PufferManager.GetDownloadType(v) or PufferConst.ENUM_DownloadType.ODPAK
        tmpList[1] = v
        if PufferManager.GetState(type, tmpList) ~= PufferConst.ENUM_DownloadState.Done then
          state = PufferConst.ENUM_DownloadState.Not
          break
        end
      end
    end
  else
    state = PufferManager.GetState(downloadType, keyList)
  end
  printf("common_download_handler.CreateDownloadUIReturnUIBase. state=%s", tostring(state))
  if state ~= PufferConst.ENUM_DownloadState.Done and keyList and next(keyList) then
    parentPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    childUI_Common_Download_UI = parentUIBase._childUI_Common_Download_UI_List[parentPanel]
    if not childUI_Common_Download_UI then
      childUI_Common_Download_UI = parentUIBase:CreateChildWindow(parentPanel, UIManager.UI_Config.Common_Download_UI)
      parentUIBase._childUI_Common_Download_UI_List[parentPanel] = childUI_Common_Download_UI
    end
    if childUI_Common_Download_UI then
      childUI_Common_Download_UI.UIRoot:SetData(downloadType, keyList, extraParams)
    end
  else
    parentPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    childUI_Common_Download_UI = parentUIBase._childUI_Common_Download_UI_List[parentPanel]
    if childUI_Common_Download_UI then
      childUI_Common_Download_UI:Close()
      parentUIBase._childUI_Common_Download_UI_List[parentPanel] = nil
    end
    if extraParams and extraParams.callback_no_need_down then
      extraParams.callback_no_need_down()
    end
    return nil
  end
  return childUI_Common_Download_UI
end
function common_download_handler:CloseDownloadUI(parentUIBase, parentPanel)
  printf("common_download_handler:CloseDownloadUI.")
  if not parentUIBase or not parentPanel then
    return
  end
  if not parentUIBase._childUI_Common_Download_UI_List then
    return
  end
  local childUI_Common_Download_UI = parentUIBase._childUI_Common_Download_UI_List[parentPanel]
  if not childUI_Common_Download_UI then
    return
  end
  childUI_Common_Download_UI:Close()
  parentUIBase._childUI_Common_Download_UI_List[parentPanel] = nil
end
function common_download_handler.CreateMapDownloader(style, mapKey, parentUIBase, parentPanel, doneCallback, clickCallback, notDownloadCallback, from)
  log(bWriteLog and "common_download_handler.CreateMapDownloader style = " .. tostring(style))
  if common_download_handler.bIsCurrentSceneSkipDownload then
    return nil
  end
  if not parentPanel then
    return nil
  end
  if PufferSwitch.BanDownload then
    return
  end
  local childUI_MapDownloader_UI
  local cacheKey = "childUI_MapDownloader_UI" .. tostring(style)
  childUI_MapDownloader_UI = parentUIBase[cacheKey]
  if style == 1 then
    if not childUI_MapDownloader_UI then
      childUI_MapDownloader_UI = parentUIBase:CreateChildWindow(parentPanel, UIManager.UI_Config.Common_Download_Map_Style_One)
      parentUIBase[cacheKey] = childUI_MapDownloader_UI
    end
    childUI_MapDownloader_UI.UIRoot:SetData(mapKey, doneCallback, clickCallback, from)
  elseif style == 2 then
    if not childUI_MapDownloader_UI then
      childUI_MapDownloader_UI = parentUIBase:CreateChildWindow(parentPanel, UIManager.UI_Config.Common_Download_Map_Style_Two)
      parentUIBase[cacheKey] = childUI_MapDownloader_UI
    end
    childUI_MapDownloader_UI.UIRoot:SetData(mapKey, doneCallback, notDownloadCallback, from)
  end
  return childUI_MapDownloader_UI
end
function common_download_handler.CreateUGCAssetIDDownloader(AllAssetID, rootWidget, extraParams, baseUI)
  if not rootWidget then
    return
  end
  if PufferSwitch.BanDownload then
    return
  end
  if not PufferDownloader.BattleDownloadSwitch then
    log(bWriteLog and "[edward] common_download_handler.CreateUGCDownloadUI, PufferDownloader.BattleDownloadSwitch is closed")
    return
  end
  local downloader
  local PufferUGCPakManager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.puffer_ugcpak_manager)
  local state = PufferUGCPakManager:GetStateByKeyList(PufferConst.ENUM_DownloadType.UGCPAK, AllAssetID)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Button_UIBP)
    downloader.UIRoot:SetUGCAssetID(AllAssetID, extraParams)
  else
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  return downloader
end
function common_download_handler.CreateUGCDownloader(uiType, loaderType, loaderInfo, rootWidget, switcher, baseUI, extendedParams)
  log(bWriteLog and "common_download_handler.CreateUGCDownloader uiType = " .. tostring(uiType) .. " loaderType = " .. tostring(loaderType))
  log_tree(bWriteLog and "common_download_handler.CreateUGCDownloader loaderInfo", loaderInfo)
  log_tree(bWriteLog and "common_download_handler.CreateUGCDownloader extendedParams", extendedParams)
  if not rootWidget then
    log(bWriteLog and "common_download_handler.CreateUGCDownloader --- not rootWidget")
    return
  end
  if PufferSwitch.BanDownload then
    log(bWriteLog and "common_download_handler.CreateUGCDownloader --- PufferSwitch.BanDownload")
    return
  end
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local state
  if loaderType == LogicUGCResManager.DownloaderType.ModList or loaderType == LogicUGCResManager.DownloaderType.TemplateList then
    state = LogicUGCResManager:BatchGetResState(loaderType, loaderInfo)
  else
    state = LogicUGCResManager:GetResState(loaderType, loaderInfo)
  end
  log(bWriteLog and "common_download_handler.CreateUGCDownloader state = " .. tostring(state))
  local downloader
  local FinishSwitcherIndex = extendedParams and extendedParams.FinishSwitcherIndex or 0
  local OtherSwitcherIndex = FinishSwitcherIndex == 0 and 1 or 0
  if state ~= PufferConst.ENUM_DownloadState.Done then
    if switcher == nil then
      rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    else
      log(bWriteLog and "common_download_handler.CreateUGCDownloader switcher:SetActiveWidgetIndex(1)")
      switcher:SetActiveWidgetIndex(OtherSwitcherIndex)
    end
    downloader = common_download_handler.InitUGCDownloader(uiType, rootWidget, baseUI)
    local callbackFunc = common_download_handler.InitUGCDownloadCallback(rootWidget, switcher, extendedParams)
    if loaderType == LogicUGCResManager.DownloaderType.ModList or loaderType == LogicUGCResManager.DownloaderType.TemplateList then
      downloader.UIRoot:SetUGCModListData(loaderType, loaderInfo, callbackFunc, extendedParams, uiType)
    else
      downloader.UIRoot:SetUGCData(loaderType, loaderInfo, callbackFunc, extendedParams, uiType)
    end
  elseif switcher == nil then
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    switcher:SetActiveWidgetIndex(FinishSwitcherIndex)
  end
  return downloader
end
function common_download_handler.CreateStoreDownloadUIReturnUIBase(downloadType, keyList, parentUIBase, parentPanel, extraParams)
  if common_download_handler.bIsCurrentSceneSkipDownload then
    return nil
  end
  if not parentPanel then
    return nil
  end
  if PufferSwitch.BanDownload then
    return nil
  end
  local childUI_Common_Download_UI
  local state = PufferManager.GetState(downloadType, keyList)
  if state ~= PufferConst.ENUM_DownloadState.Done and next(keyList) then
    parentPanel:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    childUI_Common_Download_UI = parentUIBase._childUI_Common_Download_UI
    if not childUI_Common_Download_UI then
      childUI_Common_Download_UI = parentUIBase:CreateChildWindow(parentPanel, UIManager.UI_Config.Common_Download_Store_Style)
      parentUIBase._    end
    if childUI_Common_Download_UI then
      childUI_Common_Download_UI.UIRoot:SetData(downloadType, keyList, extraParams)
    end
  else
    parentPanel:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    childUI_Common_Download_UI = parentUIBase._childUI_Common_Download_UI
    if childUI_Common_Download_UI then
      childUI_Common_Download_UI:Close()
      parentUIBase._childUI_Common_Download_UI = nil
    end
    return nil
  end
  return childUI_Common_Download_UI
end
function common_download_handler.CreateStoreDownloadUIFromPool(downloadType, keyList, parentOverrideUIBase, parentWidget, extraParams)
  if common_download_handler.bIsCurrentSceneSkipDownload then
    return nil
  end
  if not parentWidget then
    return nil
  end
  if PufferSwitch.BanDownload then
    return nil
  end
  local childUI_Common_Download_Widget
  local state = PufferManager.GetState(downloadType, keyList)
  if state ~= PufferConst.ENUM_DownloadState.Done and next(keyList) then
    parentWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    childUI_Common_Download_Widget = parentOverrideUIBase._childUI_Common_Download_Widget
    if not childUI_Common_Download_Widget then
      local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.downloadui_pool)
      childUI_Common_Download_Widget = pool:Get("/Game/UMG/UI_BP/Common/Common_Download_Store_Style.Common_Download_Store_Style")
      parentWidget:AddChild(childUI_Common_Download_Widget)
      parentOverrideUIBase._    end
    childUI_Common_Download_Widget:SetData(downloadType, keyList, extraParams)
  else
    parentWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    childUI_Common_Download_Widget = parentOverrideUIBase._childUI_Common_Download_Widget
    if childUI_Common_Download_Widget then
      common_download_handler.ReleaseStoreDownloadUIFromPool(parentOverrideUIBase)
    end
    return nil
  end
  return childUI_Common_Download_Widget
end
function common_download_handler.ReleaseStoreDownloadUIFromPool(parentOverrideUIBase)
  local childUI_Common_Download_Widget = parentOverrideUIBase._childUI_Common_Download_Widget
  if not childUI_Common_Download_Widget then
    return
  end
  if not slua.isValid(childUI_Common_Download_Widget) then
    return
  end
  local pool = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.downloadui_pool)
  pool:Release(childUI_Common_Download_Widget)
  parentOverrideUIBase._childUI_Common_Download_Widget = nil
end
function common_download_handler.RemoveChild(widget, childName)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local cnt = widget:GetChildrenCount()
  for index = cnt, 1, -1 do
    local childWidget = widget:GetChildAt(index - 1)
    local name = UKismetSystemLibrary.GetObjectName(childWidget)
    if string.find(name, childName) then
      widget:RemoveChildAt(index - 1)
      return true
    end
  end
  return false
end
function common_download_handler.GetDownloadUINodeByParentNode(uWidget)
  if not uWidget or not slua.isValid(uWidget) then
    return nil
  end
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local cnt = uWidget:GetChildrenCount()
  for index = cnt, 1, -1 do
    local childWidget = uWidget:GetChildAt(index - 1)
    local name = UKismetSystemLibrary.GetObjectName(childWidget)
    if string.match(name, _DownloadUINodeName) then
      return childWidget
    end
  end
end
function common_download_handler.GetChild(widget, childName)
  local UKismetSystemLibrary = import("KismetSystemLibrary")
  local cnt = widget:GetChildrenCount()
  local result
  for index = cnt, 1, -1 do
    local childWidget = widget:GetChildAt(index - 1)
    local name = UKismetSystemLibrary.GetObjectName(childWidget)
    if string.find(name, childName) then
      result = childWidget
    else
      widget:RemoveChildAt(index - 1)
    end
  end
  return result
end
function common_download_handler.InitUGCDownloader(uiType, rootWidget, baseUI)
  local downloader
  local ResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  if uiType == ResManager.DownloadUIType.RBottom then
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Corner_UIBP)
  elseif uiType == ResManager.DownloadUIType.DetailLoadBtn then
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Details_UIBP)
  elseif uiType == ResManager.DownloadUIType.TeamLoadBtn then
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_TeamButton_UIBP)
  elseif uiType == ResManager.DownloadUIType.LoadMapUI then
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_LoadMapUI_UIBP)
  elseif uiType == ResManager.DownloadUIType.UGCLoadMapUI then
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_LoadMapUI_UIBP2)
  elseif uiType == ResManager.DownloadUIType.UpdateMod or uiType == ResManager.DownloadUIType.EditPubMod then
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Button_UIBP_New)
  else
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Button_UIBP)
  end
  if uiType == ResManager.DownloadUIType.RBottom then
    downloader:SetAnchors(1, 1, 0, 0)
    downloader:SetOffsets(-36, -36, 0, 0)
  elseif uiType == ResManager.DownloadUIType.DetailLoadBtn then
    downloader:SetAutoSize(true)
    downloader:SetAnchors(0, 0, 1, 1)
    downloader:SetAlignment(1, 1)
    downloader:SetPosition(0, 0)
  elseif uiType == ResManager.DownloadUIType.LoadMapUI then
    downloader:SetAnchors(0, 0, 1, 1)
    downloader:SetOffsets(0, 0, 0, 0)
  else
    downloader:SetAutoSize(true)
  end
  return downloader
end
function common_download_handler.InitUGCDownloadCallback(rootWidget, switcher, extendedParams)
  local callbackFunc
  if switcher then
    function callbackFunc()
      if switcher then
        local labelClass = import("WidgetSwitcher")
        if Game:IsClassOf(switcher, labelClass) then
          local FinishSwitcherIndex = extendedParams and extendedParams.FinishSwitcherIndex or 0
          switcher:SetActiveWidgetIndex(FinishSwitcherIndex)
          EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_DOWNLOAD_RES_COMPLETE)
        end
        if extendedParams and extendedParams.EndDownloadCallback then
          extendedParams.EndDownloadCallback()
        end
      end
    end
  else
    function callbackFunc()
      if rootWidget then
        local labelClass = import("CanvasPanel")
        if Game:IsClassOf(rootWidget, labelClass) then
          rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
        if extendedParams and extendedParams.EndDownloadCallback then
          extendedParams.EndDownloadCallback()
        end
      end
    end
  end
  return callbackFunc
end
function common_download_handler.CreateUGCPackDownloaderUI(packList, rootWidget, extraParams, baseUI)
  if not rootWidget then
    return
  end
  if PufferSwitch.BanDownload then
    return
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() and not PufferDownloader.BattleDownloadSwitch then
    log(bWriteLog and "common_download_handler.CreateUGCPackDownloaderUI, PufferDownloader.BattleDownloadSwitch is Open")
    return
  end
  local downloader
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local state = LogicUGCResManager:GetPackListState(packList, extraParams.bNeedEditorRes)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Button_UIBP)
    downloader:SetAutoSize(true)
    downloader.UIRoot:SetHallUGCPackListData(packList, extraParams, false)
  else
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  return downloader
end
function common_download_handler.CreateUGCTemplatePackDownloaderUI(TemplateList, rootWidget, extraParams, baseUI)
  if not rootWidget then
    return
  end
  if PufferSwitch.BanDownload then
    return
  end
  if GameStatus.IsInFightingNotSocialNotMainCityNotHome() and not PufferDownloader.BattleDownloadSwitch then
    log(bWriteLog and "common_download_handler.CreateUGCTemplatePackDownloaderUI, PufferDownloader.BattleDownloadSwitch is Open")
    return
  end
  local downloader
  local LogicUGCTemplate = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCTemplate)
  local TemplateInfoList = {}
  for _, TemplateID in ipairs(TemplateList) do
    local TemplateInfo = LogicUGCTemplate:GetTemplateByID(TemplateID)
    table.insert(TemplateInfoList, TemplateInfo)
  end
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local state = LogicUGCResManager:BatchGetResState(LogicUGCResManager.DownloaderType.TemplateList, TemplateInfoList)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Button_UIBP)
    downloader:SetAutoSize(true)
    downloader.UIRoot:SetUGCModListData(LogicUGCResManager.DownloaderType.TemplateList, TemplateInfoList, extraParams.callback, extraParams)
  else
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  return downloader
end
function common_download_handler.CreateUGCTeamEditDownloadUI(rootWidget, extraParams, baseUI)
  if not rootWidget then
    return
  end
  if PufferSwitch.BanDownload then
    return
  end
  local downloader
  local LogicUGCResManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicUGCResManager)
  local state = LogicUGCResManager:GetUGCTemplateResStateByTeam(extraParams.TemplateID, extraParams.CustomAssetList)
  if state ~= PufferConst.ENUM_DownloadState.Done then
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    downloader = common_download_handler.CreateOrGetPanelDownloadUI(rootWidget, baseUI, UIManager.UI_Config.UGC_Download_Button_UIBP)
    downloader.UIRoot:SetUGCTeamEditData(extraParams)
  else
    rootWidget:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
  return downloader
end
function common_download_handler.CreateOrGetPanelDownloadUI(parentPanel, parentUIBase, config)
  if not parentUIBase._childUI_Common_Download_UI_List then
    parentUIBase._childUI_Common_Download_UI_List = {}
  end
  local childUI_Common_Download_UI = parentUIBase._childUI_Common_Download_UI_List[parentPanel]
  if not childUI_Common_Download_UI then
    childUI_Common_Download_UI = parentUIBase:CreateChildWindow(parentPanel, config)
    parentUIBase._childUI_Common_Download_UI_List[parentPanel] = childUI_Common_Download_UI
  end
  return childUI_Common_Download_UI
end
function common_download_handler.UpdateCommonDownloadStateUI(Common_Download_StateUI, state, params)
  if not slua.isValid(Common_Download_StateUI) or not state then
    log(bWriteLog and "common_download_handler.UpdateCommonDownloadStateUI. invalid ui or state")
    return
  end
  Common_Download_StateUI:UpdateStateUI(state, params)
end
function common_download_handler.UpdateCommonDownloadStateUIPercent(Common_Download_StateUI, percent)
  if Common_Download_StateUI then
    Common_Download_StateUI:SetPercent(percent)
  end
end
function common_download_handler.UpdateCommonDownloadStateUIIconColor(Common_Download_StateUI, color)
  if Common_Download_StateUI then
    Common_Download_StateUI:SetIconColor(color)
  end
end
return common_download_handler