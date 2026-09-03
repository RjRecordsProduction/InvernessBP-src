local logic_team_platform_data = {}
local isDataInited, filterLanguageIdList, isSwitchOpen, selfZonePingValue
local _InitSelectLanguageData = function()
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  if logic_team_platform_utils.IsCanFilterLanguage() then
    local TeamPlatform_Macro = require("client.slua.logic.teamup.teamplatform_macro")
    local saveData = logic_team_platform_utils.GetSaveFilterLanguageData(TeamPlatform_Macro.Enum_FilterLanguage_Scene.TeamPlatForm)
    if saveData and 0 < #saveData then
      log_tree(bWriteLog and "[v_wllwu] logic_team_platform_data:_InitSelectLanguageData, saveData: ", saveData)
      filterLanguageIdList = logic_team_platform_utils.FilterInvalidData(saveData)
      log_tree(bWriteLog and "[v_wllwu] logic_team_platform_data:_InitSelectLanguageData, selectLanguageList: ", filterLanguageIdList)
    end
  end
  if not filterLanguageIdList or #filterLanguageIdList <= 0 then
    filterLanguageIdList = logic_team_platform_utils.GetDefaultSelectData()
    log_tree(bWriteLog and "[v_wllwu] logic_team_platform_data:_InitSelectLanguageData, GetDefaultSelectData >>> ", filterLanguageIdList)
  end
  isSwitchOpen = logic_team_platform_utils.GetSaveFilterLangSwitch()
  log(bWriteLog and "[v_wllwu] logic_team_platform_data:_InitSelectLanguageData, isSwitchOpen is:" .. tostring(isSwitchOpen))
end
local _InitCfgData = function()
  local cfg = CDataTable.GetTableData("TeamPlatformParamConfig", "SelfZonePingLimit")
  if cfg then
    selfZonePingValue = cfg.ParamValue
  end
end
local _InitData = function()
  if isDataInited then
    return
  end
  _InitCfgData()
  _InitSelectLanguageData()
  isDataInited = true
end
function logic_team_platform_data:OnInitialize()
  logic_team_platform_data.__super.OnInitialize(self)
end
function logic_team_platform_data:OnLogin(bReLogin)
end
function logic_team_platform_data:OnLogOut()
  isDataInited = nil
  filterLanguageIdList = nil
end
function logic_team_platform_data:OnPostSwitchGameStatus(preState, nextState)
end
function logic_team_platform_data:GetSelectFilterLanguage()
  _InitData()
  return filterLanguageIdList
end
function logic_team_platform_data:UpdateSelectFilterLanguage(languageList)
  filterLanguageIdList = languageList
end
function logic_team_platform_data:IsFilterSwitchOpen()
  _InitData()
  return isSwitchOpen
end
function logic_team_platform_data:UpdateFilterLanguageSwitch(isOpen)
  log(bWriteLog and "[v_wllwu] logic_team_platform_data:UpdateFilterLanguageSwitch, isOpen is:" .. tostring(isOpen))
  isSwitchOpen = isOpen
end
function logic_team_platform_data:GetProtoLangData()
  if not self:IsFilterSwitchOpen() then
    return
  end
  return self:GetSelectFilterLanguage()
end
function logic_team_platform_data:GetSelfZonePingCfgValue()
  _InitData()
  return selfZonePingValue or 0
end
function logic_team_platform_data:RefreshCurSelectFilterLanguage()
  if not isDataInited then
    return
  end
  log(bWriteLog and "[v_wllwu] logic_team_platform_data:RefreshCurSelectFilterLanguage before, filterLanguageIdList is:", filterLanguageIdList)
  local logic_team_platform_utils = require("client.slua.logic.teamup.logic_team_platform_utils")
  filterLanguageIdList = logic_team_platform_utils.FilterInvalidData(filterLanguageIdList)
  log(bWriteLog and "[v_wllwu] logic_team_platform_data:RefreshCurSelectFilterLanguage after, filterLanguageIdList is:", filterLanguageIdList)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local Clogic_team_platform_data = class(CModuleBase, nil, logic_team_platform_data)
return Clogic_team_platform_data