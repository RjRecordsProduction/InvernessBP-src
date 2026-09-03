local ModuleCoupon_GoldenSuit = {}
function ModuleCoupon_GoldenSuit:DefineAndResetData()
end
function ModuleCoupon_GoldenSuit:OnInitialize()
end
function ModuleCoupon_GoldenSuit:RegistEvents()
  ModuleCoupon_GoldenSuit.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_GOLDENSUIT_SERIES_NEWEST, self.JumpToNewestGoldenSuit, self)
end
function ModuleCoupon_GoldenSuit:OnLogin(bReLogin)
end
function ModuleCoupon_GoldenSuit:OnLogOut()
end
function ModuleCoupon_GoldenSuit:OnPreSwitchGameStatus(preState, nextState)
end
function ModuleCoupon_GoldenSuit:OnPostSwitchGameStatus(preState, nextState)
end
function ModuleCoupon_GoldenSuit:JumpToNewestGoldenSuit(_, _, var)
  log_tree("\229\153\187\233\128\137\230\156\128\230\150\176\231\154\132\230\180\187\229\138\168\230\149\176\230\141\174", var)
  ModuleCoupon_GoldenSuit:GetNewestGoldenSuitInfo()
end
function ModuleCoupon_GoldenSuit:GetNewestGoldenSuitInfo()
  local ActivityNewSystem = require("client.slua.logic.activity.logic_activity_mgr")
  local serverData = ActivityNewSystem.GetServerDataByType(ActivityType.LUCKYBACK)
  if not serverData or not next(serverData) then
    ShowNotice(7809)
    return
  end
  local activityId = 0
  local server_time = FuncUtil.GetServerTimeInSec()
  for i, data in pairs(serverData) do
    if data.cfg and data.cfg.start_time and data.cfg.end_time and data.cfg.back_up_two and server_time >= data.cfg.start_time and server_time < data.cfg.end_time and tonumber(data.cfg.back_up_two) == 1 then
      activityId = i
      break
    end
  end
  if activityId == 0 then
    ShowNotice(7809)
    return
  end
  local moduleId = BP_ENUM_MODULE_LUCKY_BACK
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local cfg = PufferManager.GetResourceCfgByModuleIDActivityID(nil, activityId)
  if cfg then
    moduleId = cfg.ModuleID
  end
  GlobalData.JumpUrl("game://?module=" .. tostring(moduleId) .. "&activityid=" .. tostring(activityId))
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleCoupon_GoldenSuit = class(CModuleBase, nil, ModuleCoupon_GoldenSuit)
return CModuleCoupon_GoldenSuit