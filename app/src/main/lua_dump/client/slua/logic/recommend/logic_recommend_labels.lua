local logic_recommend_labels = {}
function logic_recommend_labels:OnInitialize()
  log(bWriteLog and "logic_recommend_labels:OnInitialize")
  self.LangLabelCfg = {}
  self.DevelopedLabelCfg = {}
  self.UserLabelList = {}
  self.UserZoneId = 0
  self.UserLanguage = Client.GetCurrentLanguage() or 0
  self.is_minor_lang = false
  self.lang_label_id = 0
  self:InitData()
end
function logic_recommend_labels:InitData()
  self:GetLanguageLabelData()
end
function logic_recommend_labels:GetLableConfigList(labelList)
  local labelConfigList = {}
  local cfg = CDataTable.GetTable("LableConfig")
  if cfg == nil then
    log(bWriteLog and "logic_recommend_labels:GetLableTextList")
    return labelConfigList
  end
  if labelList == nil then
    log(bWriteLog and "logic_recommend_labels:GetLableTextList labelList is nil")
    return labelConfigList
  end
  for _, value in pairs(labelList) do
    local labelConfig = cfg[value]
    if labelConfig and labelConfig.Priority and labelConfig.Priority ~= 0 then
      table.insert(labelConfigList, labelConfig)
    end
  end
  table.sort(labelConfigList, function(a, b)
    if a.Priority and b.Priority then
      return a.Priority < b.Priority
    else
      return false
    end
  end)
  return labelConfigList
end
function logic_recommend_labels:GetDefaultRecommededText()
  local cfg = CDataTable.GetTable("LableConfig")
  if cfg == nil then
    log(bWriteLog and "logic_recommend_labels:GetDefaultRecommededText cfg is nil")
    return
  end
  local defaultConfig = cfg[0]
  if defaultConfig == nil then
    log(bWriteLog and "logic_recommend_labels:GetDefaultRecommededText defaultConfig is nil")
    return
  end
  local defaultRecommendedText = defaultConfig.RecommendedText
  if defaultRecommendedText == nil then
    log(bWriteLog and "logic_recommend_labels:GetDefaultRecommededText defaultRecommendedText is nil")
    return
  end
  return defaultRecommendedText
end
function logic_recommend_labels:GetTegRecommendText(id)
  if not id then
    return nil
  end
  local cfg = CDataTable.GetTableData("RecommendedTegShowCfg", id)
  if not cfg then
    return nil
  end
  return LocUtil.GetLocalizeResStr(cfg.locID)
end
function logic_recommend_labels:GetLableConfigListAll(labelList, testCfg)
  log_tree(bWriteLog and "logic_recommend_labels:GetLableConfigListAll11", labelList)
  self:GetSelfLabelList()
  local labelConfigList = {}
  local LabelFromList = {}
  local LabelList = {}
  local cfg = CDataTable.GetTable("LableConfigAll")
  if cfg == nil then
    log(bWriteLog and "logic_recommend_labels:GetLableTextList")
    return labelConfigList, LabelFromList, LabelList
  end
  local testID = testCfg and testCfg.testID
  if labelList == nil then
    log(bWriteLog and "logic_recommend_labels:GetLableTextList labelList is nil")
    return labelConfigList, LabelFromList, LabelList
  end
  for _, value in pairs(labelList) do
    local labelConfig = cfg[value]
    if labelConfig and labelConfig.Priority and labelConfig.Priority ~= 0 and labelConfig.IsShow ~= 0 then
      if testID then
        if testID == labelConfig.TestID and self:CanShowLabel(value) then
          table.insert(LabelFromList, labelConfig.From)
          table.insert(labelConfigList, labelConfig)
          table.insert(LabelList, value)
        end
      elseif self:CanShowLabel(value) then
        table.insert(LabelFromList, labelConfig.From)
        table.insert(labelConfigList, labelConfig)
        table.insert(LabelList, value)
      end
    end
  end
  table.sort(labelConfigList, function(a, b)
    if a.Priority and b.Priority then
      return a.Priority < b.Priority
    else
      return false
    end
  end)
  return labelConfigList, LabelFromList, LabelList
end
function logic_recommend_labels:CanShowLabel(labelID)
  local labelIDStr = tostring(labelID)
  labelIDStr = string.sub(labelIDStr, 1, 4)
  local info = CDataTable.GetTableData("BasicFeatureLabelConfig", labelIDStr)
  if info and info.LabelSearchType == 1 then
    log(bWriteLog and "logic_recommend_labels:CanShowLabel check label", labelID)
    local userLabel = self.UserLabelList
    if labelIDStr == "7009" then
      if self.is_minor_lang and self.lang_label_id == labelID then
        return true
      else
        return false
      end
    elseif userLabel and next(userLabel) and userLabel[labelID] then
      return true
    else
      return false
    end
  else
    log(bWriteLog and "logic_recommend_labels:CanShowLabel no need check label", labelID)
    return true
  end
end
function logic_recommend_labels:GetLanguageLabelData()
  if self.LanguageLabelData and next(self.LanguageLabelData) then
    log(bWriteLog and "logic_recommend_labels:GetLanguageLabelData 1")
    return
  end
  self.LanguageLabelData = {}
  local cfg = CDataTable.GetTable("LanguageLabelConfig")
  if cfg == nil then
    log(bWriteLog and "logic_recommend_labels:GetLanguageLabelData cfg is nil")
    return
  end
  local zoneCfg = {}
  for _, value in ipairs(cfg) do
    local Zone = value.Zone
    local LanguageStr = value.Language
    if Zone and LanguageStr then
      if zoneCfg[Zone] == nil then
        zoneCfg[Zone] = {}
      end
      zoneCfg[Zone][LanguageStr] = value
    end
  end
  log(bWriteLog and "logic_recommend_labels:GetLanguageLabelData 2")
  self.LanguageLabelData = zoneCfg
end
function logic_recommend_labels:GetLabelFeature(id)
  local cfg = CDataTable.GetTableData("BasicFeatureLabelConfig", id)
  if cfg == nil then
    log(bWriteLog and "logic_recommend_labels:GetLabelFeature cfg is nil")
    return
  end
  local searchType = cfg.LabelSearchType
  log(bWriteLog and "logic_recommend_labels:GetLabelFeature", id, searchType)
  return searchType
end
function logic_recommend_labels:GetLangLabelCfg()
  if self.LangLabelCfg and next(self.LangLabelCfg) then
    return self.LangLabelCfg
  else
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    BasicDataServerTable:GetOrReqData(data_config_marco.lang_label_config, function(tableName, data)
      self.LangLabelCfg = data
    end)
  end
end
function logic_recommend_labels:GetDevelopedLabelCfg()
  log(bWriteLog and "logic_recommend_labels:GetDevelopedLabelCfg")
  if self.DevelopedLabelCfg and next(self.DevelopedLabelCfg) then
    log(bWriteLog and "logic_recommend_labels:GetDevelopedLabelCfg1")
    return self.DevelopedLabelCfg
  else
    local BasicDataServerTable = ModuleManager.GetModule(ModuleManager.DataModuleConfig.BasicDataServerTable)
    local data_config_marco = require("client.logic.data.data_config_marco")
    BasicDataServerTable:GetOrReqData(data_config_marco.self_developed_label_cfg, function(tableName, data)
      log(bWriteLog and "logic_recommend_labels:GetDevelopedLabelCfg2")
      self.DevelopedLabelCfg = data
    end)
  end
end
function logic_recommend_labels:GetSelfLabelList()
  local logic_profile = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_profile)
  local profile = logic_profile:GetLocalProfile(DataMgr.roleData.uid)
  if profile then
    self.UserLabelList = profile.integration_labels
    self.UserLanguage = profile.language
  end
  local ZoneSystem = require("client.slua.logic.teamup.logic_zone")
  self.UserZoneId = ZoneSystem.GetChooseZone()
  local language_cfg = self.LanguageLabelData
  if language_cfg and language_cfg[self.UserZoneId] and language_cfg[self.UserZoneId][self.UserLanguage] then
    self.is_minor_lang = language_cfg[self.UserZoneId][self.UserLanguage].isMinorLang == 1
    self.lang_label_id = language_cfg[self.UserZoneId][self.UserLanguage].LanguageLabel
  end
  log_tree(bWriteLog and "logic_recommend_labels:GetSelfLabelList1", self.UserLabelList)
  log(bWriteLog and string.format("logic_recommend_labels:GetSelfLabelList2 UserLanguage: %s, UserZoneId: %s, is_minor_lang: %s, lang_label_id: %s", tostring(self.UserLanguage), tostring(self.UserZoneId), tostring(self.is_minor_lang), tostring(self.lang_label_id)))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_recommend_labels)