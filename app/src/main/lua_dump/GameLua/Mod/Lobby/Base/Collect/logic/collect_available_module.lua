local GetAvailableRewardsFunction = {
  {
    module = "collect_career_module",
    func = "GetListOfAvailableRewards",
    jumpURL = "game://?module=1002300&index=16&subTab=1"
  },
  {
    module = "collect_season_module",
    func = "GetListOfAvailableRewards",
    jumpURL = "game://?module=1002300&index=16&subTab=2"
  },
  {
    module = "collect_clothe_module",
    func = "GetListOfAvailableRewards",
    jumpURL = "game://?module=1002300&index=18&subTab=Clothe"
  },
  {
    module = "collect_gun_module",
    func = "GetListOfAvailableRewards",
    jumpURL = "game://?module=1002300&index=18&subTab=Gun"
  },
  {
    module = "collect_vehicle_module",
    func = "GetListOfAvailableRewards",
    jumpURL = "game://?module=1002300&index=18&subTab=Vehicle"
  },
  {
    module = "collect_pet_module",
    func = "GetListOfAvailableRewards",
    jumpURL = "game://?module=1002300&index=18&subTab=Pet"
  }
}
local collect_available_module = {}
function collect_available_module:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_COLLECT_AVAILABLE_REWARD_POPUP, self.CheckPopup, self)
end
function collect_available_module:CheckPopup()
  local growthprojectMgrB = require("client.slua.logic.growth_project.logic_growth_project_b")
  if not growthprojectMgrB.IsFinishAllNewGuide() then
    log(bWriteLog and string.format("collect_available_module:CheckPopup current is new guide."))
    return
  end
  local level = DataMgr.roleData.level
  if level <= 6 then
    log(bWriteLog and "collect_available_module:PopupTips level is less than 6")
    return
  end
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local data = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectRoom_AvailableReward)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  if data and data.time and TimeUtil.IsSameDay(curTime, data.time) then
    log(bWriteLog and "collect_available_module:CheckPopup is same day")
    return
  end
  local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
  local collectData = collect_module:GetCollectData()
  if not collectData then
    log(bWriteLog and "collect_available_module:CheckPopup not collectData")
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_get_collect_sys_main_data_req()
    return
  end
  self:PopupTips()
end
function collect_available_module:PopupTips()
  local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
  local list, url = self:GetRewardsAvailable()
  if #list <= 0 then
    log(bWriteLog and "collect_available_module:PopupTips list is empty")
    return
  end
  UIManager.ShowUI(UIManager.UI_Config.Collect_Available_Rewards, list, url)
  local TimeUtil = require("client.common.time_util")
  local curTime = TimeUtil.GetServerTimeInSec()
  PlayerPrefsSystem.SaveTableToFile_N({time = curTime}, PlayerPrefsSystem.ePlayerPrefsType.eCollectRoom_AvailableReward)
end
function collect_available_module:GetRewardsAvailable()
  local result = {}
  local sJumpUrl
  local getRewards = function(list)
    for i, v in ipairs(list) do
      result[#result + 1] = v
      if 7 <= #result then
        return false
      end
    end
    return true
  end
  for i, v in ipairs(GetAvailableRewardsFunction) do
    local module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig[v.module])
    local careerList, seriesID = module[v.func](module)
    if 0 < #careerList and not sJumpUrl then
      sJumpUrl = v.jumpURL
      if seriesID then
        sJumpUrl = string.format("%s&extraTab=%s", sJumpUrl, seriesID)
      end
    end
    if not getRewards(careerList) then
      return result, sJumpUrl
    end
  end
  return result, sJumpUrl
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, collect_available_module)
return CModuleTemplate