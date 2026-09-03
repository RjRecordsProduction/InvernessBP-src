local TipsManager = {}
local TipsList = {}
local CacheTipsPriorityConfig = {}
local showingTipId = -1
local SaveTipsList = function()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.LobbyTipsList
  if next(TipsList) then
    PlayerPrefsSystem.SaveTableToFile_N(TipsList, fileType)
  end
end
local RestoreTipsList = function()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local fileType = PlayerPrefsSystem.ePlayerPrefsType.LobbyTipsList
  local saveData = PlayerPrefsSystem.LoadFileToTable_N(fileType)
  if saveData then
    TipsList = saveData
    log_tree(bWriteLog and "TipsManager RestoreTipsList TipsList:", TipsList)
  end
end
local CleanData = function()
  TipsList = {}
  CacheTipsPriorityConfig = {}
  showingTipId = -1
end
local GetTipPriority = function(tipId)
  if CacheTipsPriorityConfig[tipId] then
    return CacheTipsPriorityConfig[tipId].priority
  else
    local cfg = CDataTable.GetTableData("LobbyTipsPriorityConfig", tipId)
    if cfg then
      CacheTipsPriorityConfig[tipId] = cfg
      return cfg.priority
    else
      return 0
    end
  end
end
local PopTip = function()
  if showingTipId ~= -1 then
    log(bWriteLog and "TipsManager PopTip isShowing:" .. tostring(showingTipId))
    return
  end
  if next(TipsList) then
    log(bWriteLog and "TipsManager PopTip pop:" .. tostring(TipsList[1].tipId))
    EventSystem:postEvent(EVENTTYPE_TIPS_MANAGER, EVENTID_TOP_TIP, TipsList[1])
  else
    log(bWriteLog and "TipsManager PopTip no tip")
  end
end
function TipsManager:OnInitialize()
  TipsManager.__super.OnInitialize(self)
  CleanData()
end
function TipsManager:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_ON_FACESLAP_END, self.OnFaceSlapEnd, self)
end
function TipsManager:OnLogOut()
  log(bWriteLog and "TipsManager:OnLogOut")
  SaveTipsList()
  CleanData()
end
function TipsManager:PushTip(tipParam)
  log(bWriteLog and "TipsManager:PushTip tipId:" .. tostring(tipParam.tipId))
  if tipParam.tipId == showingTipId then
    log(bWriteLog and "TipsManager:PushTip Same to showingTipId:" .. tostring(showingTipId))
    EventSystem:postEvent(EVENTTYPE_TIPS_MANAGER, EVENTID_TOP_TIP, tipParam)
    return
  end
  tipParam.priority = GetTipPriority(tipParam.tipId)
  local find = false
  for index, value in ipairs(TipsList) do
    if value.tipId == tipParam.tipId then
      TipsList[index] = tipParam
      find = true
      log(bWriteLog and "TipsManager:PushTip find")
      break
    end
  end
  if not find then
    table.insert(TipsList, tipParam)
    table.sort(TipsList, function(a, b)
      return a.priority > b.priority
    end)
  end
  PopTip()
end
function TipsManager:CloseTip(tipId)
  if tipId ~= showingTipId then
    log(bWriteLog and "TipsManager:CloseTip wrong tipId:" .. tostring(tipId))
    return
  end
  log(bWriteLog and "TipsManager:CloseTip tipId:" .. tostring(tipId))
  for index, value in ipairs(TipsList) do
    if value.tipId == tipId then
      table.remove(TipsList, index)
      break
    end
  end
  showingTipId = -1
  PopTip()
end
function TipsManager:OnFaceSlapEnd()
  log(bWriteLog and "TipsManager:OnFaceSlapEnd")
  PopTip()
end
function TipsManager:SetTipsShowing(tipId)
  log(bWriteLog and "TipsManager:SetTipsShowing tipId:" .. tostring(tipId))
  showingTipId = tipId
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTipsManager = class(CModuleBase, nil, TipsManager)
return CTipsManager