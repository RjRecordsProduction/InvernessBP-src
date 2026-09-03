local LogicUGCTemplate = {}
local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
local IfLoginReqTemplate = false
local IfBanServerReqTemplate = true
function LogicUGCTemplate:DefineAndResetData()
  self.templates = nil
  self.HasReqTemplateData = false
  self:LoadTemplateDataFromConfig()
  self.LastCreateTemplateID = nil
  self.CreateModCD = 8
  self.LastCreateModTimestamp = 0
  self.download_slot = {}
  self.popup_template_id = nil
  self.good_mods_map = nil
end
function LogicUGCTemplate:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_CREATE_MOD, self.OnAddDownloadSlot, self)
  self:AddCommonEvent(EVENTTYPE_UGC, EVENTID_UGC_DUPLICATE_MOD, self.OnAddDownloadSlot, self)
end
function LogicUGCTemplate:OnLogOut()
  self.download_slot = nil
  self.good_mods_map = nil
end
function LogicUGCTemplate:OnPreSwitchGameStatus(preState, nextState)
end
function LogicUGCTemplate:LoadTemplateDataFromConfig()
  local CfgTemplates = {}
  local TemplateConfigs = CDataTable.GetTable("UGCTemplateConfig") or {}
  for id, data in pairs(TemplateConfigs) do
    if not CfgTemplates[id] then
      CfgTemplates[id] = {}
    end
    CfgTemplates[id].ID = id
    CfgTemplates[id].MapID = data.MapID
    if data.ShowParams_a then
      CfgTemplates[id].ShowParams_a = {}
      for k_, v in pairs(data.ShowParams_a) do
        table.insert(CfgTemplates[id].ShowParams_a, v)
      end
    end
    if data.DefaultShortcutBarData_a then
      CfgTemplates[id].DefaultShortcutBarData_a = {}
      for k, v in pairs(data.DefaultShortcutBarData_a) do
        table.insert(CfgTemplates[id].DefaultShortcutBarData_a, v)
      end
    end
    CfgTemplates[id].MinPlayerNum = data.MinPlayerNum
    CfgTemplates[id].CreateUID = 0
    CfgTemplates[id].ModIDCreativeFrom = 0
    local Meta = self:ReadLocalMeta(id)
    if Meta then
      CfgTemplates[id].ResList = Meta.setting.res_list
      CfgTemplates[id].CustomAssetList = Meta.setting.custom_asset_key_list
      CfgTemplates[id].tag_v2 = Meta.setting.tag_v2 or {}
      CfgTemplates[id].subfeature_tag = Meta.setting.subfeature_tag or {}
    end
  end
  local TemlateShowConfig = CDataTable.GetTable("UGCTemplateShowConfig") or {}
  for id, data in pairs(TemlateShowConfig) do
    local cfg = CfgTemplates[data.TemplateID]
    if cfg then
      cfg.BgImage = data.BgImage
      cfg.Name = data.Name
      cfg.Desc = data.Desc
      cfg.Type = data.Type
      cfg.Sort = data.Sort
      cfg.Version = data.Version
      cfg.DefaultCreateName = data.DefaultCreateName
      cfg.TagID = data.TagID
      cfg.SceneType = data.SceneType
      cfg.IsBanShow = false
      if data.AllBan == 1 then
        cfg.IsBanShow = true
      end
      if PublishRegionMacros.IsBLUEHOLE() and data.BlueHoleBan == 1 then
        cfg.IsBanShow = true
      end
      local templateType = CDataTable.GetTableData("UGCTemplateTypeConfig", cfg.Type)
      if templateType then
        cfg.Tab = templateType.Type
      end
      if data.IntroductoryDiagram_as then
        cfg.IntroductoryDiagram_as = {}
        for k, v in pairs(data.IntroductoryDiagram_as) do
          table.insert(cfg.IntroductoryDiagram_as, v)
        end
      end
      cfg.OriginalAuthorUID = data.OriginalAuthorUID
      cfg.TemplateTag = data.TemplateTag
      cfg.BlockyLua = data.BlockyLua
      cfg.MapSize = data.MapSize
      cfg.PlayTime = data.PlayTime
      if data.TemplateMods_a then
        cfg.TemplateMods_a = {}
        for k, v in pairs(data.TemplateMods_a) do
          table.insert(cfg.TemplateMods_a, v)
        end
      end
      if data.LaunchTime and data.LaunchTime ~= "" then
        cfg.LaunchTime = data.LaunchTime
      end
      if data.DownlineTime and data.DownlineTime ~= "" then
        cfg.DownlineTime = data.DownlineTime
      end
    end
  end
  log_tree("LogicUGCTemplate:LoadTemplateDataFromConfig CfgTemplates = ", CfgTemplates)
  self:SetTemplate(CfgTemplates, true)
end
function LogicUGCTemplate:ReadLocalMeta(TemplateID)
  local TemplateDataConfig = CDataTable.GetTableData("UGCTemplateDataConfig", TemplateID)
  if not TemplateDataConfig then
    return
  end
  local CreativeModeBlueprintLibrary = import("CreativeModeBlueprintLibrary")
  local MetaDataPath = CreativeModeBlueprintLibrary.ProjectContentDir() .. "Templates/UGC/TemplateData/Meta/" .. TemplateDataConfig.InitialMeta
  local MetaDataBuffer = CreativeModeBlueprintLibrary.LoadFileToArrayByFullPath(MetaDataPath)
  local MetaData
  local InitialMetaTable = slua.LuaArchiverDecode(LuaStateWrapper, MetaDataBuffer)
  if InitialMetaTable then
    MetaData = {
      base = {}
    }
    MetaData.base.version = InitialMetaTable.version_temp
    MetaData.base.template_id = TemplateID
    MetaData.setting = InitialMetaTable
  end
  return MetaData
end
function LogicUGCTemplate:ReqTemplates()
  if self.HasReqTemplateData then
    return
  end
  if not IfBanServerReqTemplate then
    local UGCHandler = require("client.network.Protocol.UGCHandler")
    UGCHandler.send_ugc_get_template_list_req()
  end
  self.HasReqTemplateData = true
end
function LogicUGCTemplate:GetTemplate()
  if self.templates then
    return self.templates
  end
  if IfLoginReqTemplate then
    self:ReqTemplates()
  end
end
function LogicUGCTemplate:SetTemplate(templates, DataFromClient)
  if not templates or type(templates) ~= "table" then
    log_error("LogicUGCTemplate:SetTemplate invalid templates")
    return
  end
  if not DataFromClient then
    for templateId, templateInfo in pairs(templates) do
      local clientData = self.templates[templateId]
      if clientData and clientData.Desc then
        templateInfo.Desc = clientData.Desc
      end
      if clientData and clientData.Name then
        templateInfo.Name = clientData.Name
      end
    end
  end
  self.  if DataFromClient then
    print(bWriteLog and "LogicUGCTemplate:SetTemplate from client")
  else
    print(bWriteLog and "LogicUGCTemplate:SetTemplate from server")
    EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_NOTIFY_TEMPLATE, self.templates)
  end
end
function LogicUGCTemplate:GetTemplatesByType(tType)
  local templates = {}
  if not tType then
    log_error("LogicUGCTemplate:SetTemplate invalid tType")
    return templates
  end
  if not self.templates then
    return templates
  end
  for k, v in pairs(self.templates) do
    if v.Type == tType then
      table.insert(templates, v)
    end
  end
  local template_list = self:FilterTemplate(templates)
  table.sort(template_list, function(a, b)
    if not a.Sort or not b.Sort then
      return true
    end
    return a.Sort < b.Sort
  end)
  return template_list
end
function LogicUGCTemplate:GetTemplatesByTypeAndScene(tType, sceneType)
  local templates = {}
  if not tType or not sceneType then
    log_error("LogicUGCTemplate:GetTemplatesByTypeAndScene invalid tType or sceneType")
    return templates
  end
  log(bWriteLog and "LogicUGCTemplate:GetTemplatesByTypeAndScene tType:" .. tostring(tType) .. " sceneType:" .. tostring(sceneType))
  if not self.templates then
    return templates
  end
  for _, v in pairs(self.templates) do
    if v.Type == tType and v.SceneType == sceneType then
      table.insert(templates, v)
    end
  end
  local template_list = self:FilterTemplate(templates)
  table.sort(template_list, function(a, b)
    if not a.Sort or not b.Sort then
      return true
    end
    return a.Sort < b.Sort
  end)
  return template_list
end
function LogicUGCTemplate:FilterTemplate(templates)
  local TableUtil = require("common.table_util")
  local template_list = TableUtil.CopyTable(templates)
  for i = #template_list, 1, -1 do
    if template_list[i].IsBanShow then
      table.remove(template_list, i)
    end
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  for i = #template_list, 1, -1 do
    local template = template_list[i]
    if template.LaunchTime then
      local launchTime = TimeUtil.TimeStringToUnixstamp(template.LaunchTime)
      local downlineTime = template.DownlineTime and TimeUtil.TimeStringToUnixstamp(template.DownlineTime)
      local shouldRemove = false
      if curTime < launchTime then
        shouldRemove = true
      elseif downlineTime and curTime > downlineTime then
        shouldRemove = true
      end
      if shouldRemove then
        table.remove(template_list, i)
      end
    end
  end
  return template_list
end
function LogicUGCTemplate:GetTemplateByID(id)
  if not self.templates then
    log_error("LogicUGCTemplate:GetTemplateByID invalid templates")
    if IfLoginReqTemplate then
      self:ReqTemplates()
    end
    return nil
  end
  if not self.templates[id] then
    log_error("LogicUGCTemplate:GetTemplateByID get nil by id =" .. tostring(id))
    return nil
  end
  return self.templates[id]
end
function LogicUGCTemplate:GetTemplateByIDLocally(id)
  return CDataTable.GetTableData("UGCTemplateConfig", id)
end
function LogicUGCTemplate:GetTemplates()
  return self.templates
end
function LogicUGCTemplate:GetTemplateSceneTypeConfig(templateTypeId)
  if not templateTypeId or not self.templates then
    log(bWriteLog and "LogicUGCTemplate:GetTemplateSceneTypeConfig no templateTypeId or no templates")
    return nil
  end
  local Config_UGC = require("client.slua.logic.ugc.config_ugc")
  local UGCTemplateTypeConfig = Config_UGC.GetTemplateTypeConfigByID(templateTypeId)
  if not (UGCTemplateTypeConfig and UGCTemplateTypeConfig.SceneTypeList_a) or UGCTemplateTypeConfig.SceneTypeList_a:Num() <= 0 then
    log(bWriteLog and "LogicUGCTemplate:GetTemplateSceneTypeConfig no SceneTypeList_a")
    return nil
  end
  local TemplateSceneTypeConfig = CDataTable.GetTable("UGCTemplateSceneTypeConfig")
  if not TemplateSceneTypeConfig then
    log(bWriteLog and "LogicUGCTemplate:GetTemplateSceneTypeConfig no config")
    return nil
  end
  local sortCfg = {}
  for _, sceneType in pairs(UGCTemplateTypeConfig.SceneTypeList_a) do
    if TemplateSceneTypeConfig[sceneType] and self:CheckHasSceneTypeTemplate(templateTypeId, sceneType) then
      table.insert(sortCfg, TemplateSceneTypeConfig[sceneType])
    end
  end
  table.sort(sortCfg, function(a, b)
    if not a.Sort or not b.Sort then
      return true
    end
    return a.Sort < b.Sort
  end)
  log_tree("LogicUGCTemplate:GetTemplateSceneTypeConfig sortCfg:", sortCfg)
  return sortCfg
end
function LogicUGCTemplate:CheckHasSceneTypeTemplate(tType, sceneType)
  if not tType or not sceneType then
    log(bWriteLog and "LogicUGCTemplate:CheckHasSceneTypeTemplate invalid tType or sceneType")
    return false
  end
  log(bWriteLog and "LogicUGCTemplate:CheckHasSceneTypeTemplate tType:" .. tostring(tType) .. " sceneType:" .. tostring(sceneType))
  if not self.templates then
    return false
  end
  for _, v in pairs(self.templates) do
    if v.Type == tType and v.SceneType == sceneType then
      log(bWriteLog and "LogicUGCTemplate:CheckHasSceneTypeTemplate true")
      return true
    end
  end
  return false
end
function LogicUGCTemplate:CheckIsNewbieGuideTemplate(templateID)
  local templateConfig = CDataTable.GetTableData("UGCTemplateConfig", templateID)
  if not templateConfig or not templateConfig.IsNewbieGuide then
    log(bWriteLog and "LogicUGCTemplate:CheckIsNewbieGuideTemplate no config")
    return false
  end
  return templateConfig.IsNewbieGuide == 1
end
function LogicUGCTemplate:GetTemplateTypeTabs()
  local tabs = {}
  local UGCTemplateTypeCfg_List = {}
  local UGCTemplateTypeConfigs = CDataTable.GetTable("UGCTemplateTypeConfig") or {}
  for _, config in pairs(UGCTemplateTypeConfigs) do
    table.insert(UGCTemplateTypeCfg_List, config)
  end
  table.sort(UGCTemplateTypeCfg_List, function(a, b)
    return a.Sort < b.Sort
  end)
  for _, config in ipairs(UGCTemplateTypeCfg_List) do
    if config.SceneTypeList_a and config.SceneTypeList_a:Num() >= 2 then
      local subTabs = {}
      local sceneTypeList = self:GetTemplateSceneTypeConfig(config.ID) or {}
      for i, v in ipairs(sceneTypeList) do
        local templates = self:GetTemplatesByTypeAndScene(config.ID, v.SceneTypeID)
        if 0 < #templates then
          table.insert(subTabs, {
            text = LocUtil.GetLocalizeResStr(v.SceneTypeName),
            SceneTypeID = v.SceneTypeID
          })
        end
      end
      if 0 < #subTabs then
        table.insert(tabs, {
          text = config.Name,
          subData = subTabs,
          ID = config.ID
        })
      end
    else
      local templates = self:GetTemplatesByType(config.ID)
      if 0 < #templates then
        table.insert(tabs, {
          text = config.Name,
          ID = config.ID
        })
      end
    end
  end
  return tabs
end
function LogicUGCTemplate:OnAddDownloadSlot(_, _, slot)
  log(bWriteLog and "LogicUGCTemplate:OnAddDownloadSlot slot = " .. slot)
  for k, v in pairs(self.download_slot) do
    if v == slot then
      return
    end
  end
  table.insert(self.download_slot, slot)
end
function LogicUGCTemplate:GetDownloadSlot()
  return self.download_slot
end
function LogicUGCTemplate:RemoveDownloadSlot(slot)
  local idx = 1
  for i, v in pairs(self.download_slot) do
    if v == slot then
      idx = i
      break
    end
  end
  table.remove(self.download_slot, idx)
  log(bWriteLog and "LogicUGCTemplate:RemoveDownloadSlot slot = " .. slot)
end
function LogicUGCTemplate:ClearDownloadSlot()
  log(bWriteLog and "LogicUGCTemplate:ClearDownloadSlot")
  self.download_slot = {}
end
function LogicUGCTemplate:GetLastCreateTemplateID()
  return self.LastCreateTemplateID
end
function LogicUGCTemplate:SetCreateTemplateID(id)
  self.LastCreateTemplateID = id
end
function LogicUGCTemplate:GetPopupTemplateID()
  return self.popup_template_id
end
function LogicUGCTemplate:SetPopupTemplateID(id)
  self.popup_template_end
function LogicUGCTemplate:CheckCanCreateMod()
  local TimeUtil = require("client.common.time_util")
  local cur_timestamp = TimeUtil.GetServerTimeInSec()
  if cur_timestamp - self.LastCreateModTimestamp < self.CreateModCD then
    ShowNotice(120164)
    return false
  end
  self.LastCreateModTimestamp = cur_timestamp
  return true
end
function LogicUGCTemplate:AddTemplateTabRedDot()
  local UGCTemplateTypeCfg_List = {}
  local UGCTemplateTypeConfigs = CDataTable.GetTable("UGCTemplateTypeConfig") or {}
  for _, config in pairs(UGCTemplateTypeConfigs) do
    table.insert(UGCTemplateTypeCfg_List, config)
  end
  if not UGCTemplateTypeCfg_List or #UGCTemplateTypeCfg_List == 0 then
    print(bWriteLog and "LogicUGCTemplate:AddTemplateTabRedDot - No UGCTemplateTypeCfg_List found")
    return
  end
  for tabIndex, tabData in ipairs(UGCTemplateTypeCfg_List) do
    self:ProcessTabRedDot(tabData)
  end
  local ugc_center_reddot_data = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  ugc_center_reddot_data.GetCreatTemplateRedDotData()
end
function LogicUGCTemplate:ProcessTabRedDot(tabData)
  if not tabData or not tabData.ID then
    return
  end
  if tabData.SceneTypeList_a and tabData.SceneTypeList_a:Num() > 0 then
    local sceneTypeList = self:GetTemplateSceneTypeConfig(tabData.ID) or {}
    for i, v in pairs(sceneTypeList) do
      self:ProcessSubTabRedDot(tabData.ID, v)
    end
  else
    self:ProcessSingleTabRedDot(tabData.ID)
  end
end
function LogicUGCTemplate:ProcessSubTabRedDot(tabTypeID, subTabData)
  if not subTabData or not subTabData.SceneTypeID then
    return
  end
  local templateList = self:GetTemplatesByTypeAndScene(tabTypeID, subTabData.SceneTypeID)
  if not templateList or #templateList == 0 then
    return
  end
  local ugc_center_reddot_data = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  for templateIndex, templateData in ipairs(templateList) do
    if templateData and templateData.ID then
      ugc_center_reddot_data.AddCreatTemplateTabRedDot(tabTypeID, subTabData.SceneTypeID, templateData.ID)
    end
  end
end
function LogicUGCTemplate:ProcessSingleTabRedDot(tabTypeID)
  local templateList = self:GetTemplatesByType(tabTypeID)
  if not templateList or #templateList == 0 then
    return
  end
  local ugc_center_reddot_data = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  for templateIndex, templateData in ipairs(templateList) do
    if templateData and templateData.ID then
      ugc_center_reddot_data.AddCreatTemplateTabRedDot(tabTypeID, nil, templateData.ID)
    end
  end
end
function LogicUGCTemplate:UpdateTemplateTabRedDot()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LocData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCTemplateNewRedDot) or {}
  local version_util = require("client.common.version_util")
  local cur_version = version_util.GetClientFormat(Client.GetAppVersion())
  if LocData.version and LocData.version ~= cur_version then
    LocData = {}
    PlayerPrefsSystem.SaveTableToFile_N(LocData, PlayerPrefsSystem.ePlayerPrefsType.eUGCTemplateNewRedDot)
  end
  local shown_templates = LocData.templates or {}
  local templates = self:GetTemplate() or {}
  if not templates or not next(templates) then
    log(bWriteLog and "LogicUGCTemplate:UpdateTemplateTabRedDot no template_list")
    return
  end
  local Shown = function(templateID)
    for k, v in pairs(shown_templates) do
      if v == templateID then
        return true
      end
    end
    return false
  end
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  local ugc_center_reddot_data = require("client.slua.logic.ugc.center.ugc_center_reddot_data")
  for k, v in pairs(templates) do
    if v.Type and not v.IsBanShow and v.LaunchTime then
      local launchTime = TimeUtil.TimeStringToUnixstamp(v.LaunchTime)
      local downlineTime = v.DownlineTime and TimeUtil.TimeStringToUnixstamp(v.DownlineTime)
      local shouldRemove = false
      if curTime < launchTime then
        shouldRemove = true
      elseif downlineTime and curTime > downlineTime then
        shouldRemove = true
      end
      if not shouldRemove then
        if version_util.CompareVersionStandard(cur_version, v.Version) == 0 and not Shown(v.ID) then
          ugc_center_reddot_data.UpdateCreatTemplateRedDotData(v.Type, v.SceneType, v.ID, true)
        else
          ugc_center_reddot_data.UpdateCreatTemplateRedDotData(v.Type, v.SceneType, v.ID)
        end
      end
    end
  end
end
function LogicUGCTemplate:ClearTemplateRedDot(template_id)
  local version_util = require("client.common.version_util")
  local cur_version = version_util.GetClientFormat(Client.GetAppVersion())
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local LocData = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eUGCTemplateNewRedDot) or {}
  if not LocData.version then
    LocData.version = cur_version
  end
  local shown_templates = LocData.templates or {}
  local has = false
  for k, v in pairs(shown_templates) do
    if v == template_id then
      has = true
      break
    end
  end
  if not has then
    log(bWriteLog and "LogicUGCTemplate:ClearTemplateRedDot template_id = " .. template_id)
    table.insert(shown_templates, template_id)
  end
  LocData.templates = shown_templates
  PlayerPrefsSystem.SaveTableToFile_N(LocData, PlayerPrefsSystem.ePlayerPrefsType.eUGCTemplateNewRedDot)
  self:UpdateTemplateTabRedDot()
end
function LogicUGCTemplate:ReqGetGoodModOfTemplate()
  if self.good_mods_map and next(self.good_mods_map) then
    log(bWriteLog and "LogicUGCTemplate:ReqGetGoodModOfTemplate already get good mods")
    return
  end
  local UGCHandler = require("client.network.Protocol.UGCHandler")
  UGCHandler.send_wow_good_mod_of_template_req()
end
function LogicUGCTemplate:RspGoodModOfTemplate(ret_list)
  local StringUtil = require("common.string_util")
  for k, v in pairs(ret_list or {}) do
    if not self.good_mods_map then
      self.good_mods_map = {}
    end
    local mod_list_s = StringUtil.Split(v.mod_list, "|")
    local mod_id_list = {}
    for i, j in pairs(mod_list_s) do
      table.insert(mod_id_list, tonumber(j))
    end
    self.good_mods_map[v.id] = mod_id_list
  end
  EventSystem:postEvent(EVENTTYPE_UGC, EVENTID_UGC_GET_GOOD_MOD_OF_TEMPLATE)
end
function LogicUGCTemplate:GetGoodModsByTempLate(template_id)
  if not self.good_mods_map then
    return nil
  end
  return self.good_mods_map[template_id]
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CLogicUGCTemplate = class(CModuleBase, nil, LogicUGCTemplate)
return CLogicUGCTemplate