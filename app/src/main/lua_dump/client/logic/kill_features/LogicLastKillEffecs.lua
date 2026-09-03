local LogicLastKillEffecs = {}
local EnumOperateType = {PotOn = 0, PotOff = 1}
function LogicLastKillEffecs:DefineAndResetData()
  self.last_kill_effects_data = nil
end
function LogicLastKillEffecs:OnInitialize()
end
function LogicLastKillEffecs:OnPreSwitchGameStatus(preState, nextState)
end
function LogicLastKillEffecs:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("LogicLastKillEffecs:OnPostSwitchGameStatus nextState = %s", nextState))
  if nextState == GameStatus.Lobby then
    self:send_get_last_kill_special_effects_req()
  end
end
function LogicLastKillEffecs:ClearCacheData()
  self.last_kill_effects_data = nil
end
function LogicLastKillEffecs:GetEffectItemCount(effectItemId)
  if not effectItemId then
    log(bWriteLog and "LogicLastKillEffecs:GetEffectItemCount effectItemId is nil")
    return 0
  end
  if not self.last_kill_effects_data or not self.last_kill_effects_data.cur_own_list then
    log(bWriteLog and "LogicLastKillEffecs:CheckHasEffect cur_own_list is nil")
    return 0
  end
  return self.last_kill_effects_data.cur_own_list[effectItemId] or 0
end
function LogicLastKillEffecs:CheckHasEffect(effectItemId)
  local count = self:GetEffectItemCount(effectItemId)
  return 0 < count
end
function LogicLastKillEffecs:GetCurEquipedEffectId()
  if not self.last_kill_effects_data or not self.last_kill_effects_data.cur_arm_list then
    log(bWriteLog and "LogicLastKillEffecs:CheckHasEffect cur_own_list is nil")
    return nil
  end
  local equipedId = next(self.last_kill_effects_data.cur_arm_list)
  return equipedId
end
function LogicLastKillEffecs:GetPreviewVideoPath(effectItemId)
  local LastKillEffectShowCfg = CDataTable.GetTableData("LastKillEffectShowCfg", effectItemId)
  if not LastKillEffectShowCfg then
    return nil
  end
  return LastKillEffectShowCfg.PreviewVideoPath
end
function LogicLastKillEffecs:PutOnLastKillEffects(effectId)
  if not effectId then
    log(bWriteLog and "LogicLastKillEffecs:PutOnKillCounter params is nil")
    return
  end
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_last_kill_special_effects_oper_req(EnumOperateType.PotOn, effectId)
end
function LogicLastKillEffecs:PutOffLastKillEffects(effectId)
  if not effectId then
    log(bWriteLog and "LogicLastKillEffecs:PutOnKillCounter params is nil")
    return
  end
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_last_kill_special_effects_oper_req(EnumOperateType.PotOff, effectId)
end
function LogicLastKillEffecs:send_get_last_kill_special_effects_req(enforce)
  if not enforce and self.last_kill_effects_data and self.last_kill_effects_data.cur_own_list then
    EventSystem:postEvent(EVENTTYPE_LAST_KILL_EFFECTS, EVENTID_LAST_KILL_EFFECTS_INFO_RSP)
    return
  end
  local KillFeatureHandler = require("client.network.Protocol.KillFeatureHandler")
  KillFeatureHandler.send_get_last_kill_special_effects_req()
end
function LogicLastKillEffecs:on_get_last_kill_special_effects_rsp(last_kill_effects_data)
  if not last_kill_effects_data then
    log(bWriteLog and "LogicLastKillEffecs:on_get_last_kill_special_effects_rsp last_kill_effects_data is nil")
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_LAST_KILL_EFFECTS, EVENTID_LAST_KILL_EFFECTS_INFO_RSP)
  local ResearchRedDot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ResearchRedDot)
  ResearchRedDot:SetKillEffectRedDot(last_kill_effects_data.cur_own_list)
end
function LogicLastKillEffecs:on_last_kill_special_effects_oper_rsp(cur_effect_list)
  if not cur_effect_list then
    log(bWriteLog and "LogicLastKillEffecs:on_last_kill_special_effects_oper_rsp cur_effect_list is nil")
    return
  end
  self.last_kill_effects_data = self.last_kill_effects_data or {}
  self.last_kill_effects_data.cur_arm_list = cur_effect_list
  EventSystem:postEvent(EVENTTYPE_LAST_KILL_EFFECTS, EVENTID_LAST_KILL_EFFECTS_EQUIP_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicLastKillEffecs)
return CModuleTemplate