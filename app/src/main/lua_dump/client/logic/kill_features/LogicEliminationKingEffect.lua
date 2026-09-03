local LogicEliminationKingEffect = {}
function LogicEliminationKingEffect:DefineAndResetData()
  self.elimi_king_data = nil
end
function LogicEliminationKingEffect:OnInitialize()
end
function LogicEliminationKingEffect:OnPreSwitchGameStatus(preState, nextState)
end
function LogicEliminationKingEffect:OnPostSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("LogicEliminationKingEffect:OnPostSwitchGameStatus nextState = %s", nextState))
  if nextState == GameStatus.Lobby then
    self:send_get_collect_award_privilege_req()
  end
end
function LogicEliminationKingEffect:ClearCacheData()
  self.elimi_king_data = nil
end
function LogicEliminationKingEffect:GetEffectItemCount(effectItemId)
  if not effectItemId then
    log(bWriteLog and "LogicEliminationKingEffect:GetEffectItemCount effectItemId is nil")
    return 0
  end
  if not self.elimi_king_data or not self.elimi_king_data.all_effect then
    log(bWriteLog and "LogicEliminationKingEffect:CheckHasEffect cur_own_list is nil")
    return 0
  end
  return self.elimi_king_data.all_effect[effectItemId] or 0
end
function LogicEliminationKingEffect:CheckHasEffect(effectItemId)
  local count = self:GetEffectItemCount(effectItemId)
  return 0 < count
end
function LogicEliminationKingEffect:GetCurEquipedEffectId()
  if not self.elimi_king_data or not self.elimi_king_data.equip_effect then
    log(bWriteLog and "LogicEliminationKingEffect:CheckHasEffect cur_own_list is nil")
    return nil
  end
  return self.elimi_king_data.equip_effect
end
function LogicEliminationKingEffect:GetPreviewVideoPath(effectItemId)
  local EliminationKingEffectCfg = CDataTable.GetTableData("EliminationKingEffectCfg", effectItemId)
  if not EliminationKingEffectCfg then
    return nil
  end
  return EliminationKingEffectCfg.PreviewVideoPath
end
function LogicEliminationKingEffect:PutOnEliminationKingEffects(effectId)
  if not effectId then
    log(bWriteLog and "LogicEliminationKingEffect:PutOnKillCounter params is nil")
    return
  end
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_set_elimination_king_effect_req(effectId)
end
function LogicEliminationKingEffect:PutOffEliminationKingEffects(effectId)
  log(bWriteLog and "LogicEliminationKingEffect:PutOffEliminationKingEffects effectId = %s" .. tostring(effectId))
  if effectId == self.elimi_king_data.equip_effect then
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_set_elimination_king_effect_req(nil)
  end
end
function LogicEliminationKingEffect:send_get_collect_award_privilege_req()
  if self.elimi_king_data and self.elimi_king_data.all_effect then
    EventSystem:postEvent(EVENTTYPE_ELIMINATION_KING_EFFECTS, EVENTID_ELIMINATION_KING_EFFECTS_INFO_RSP)
    return
  end
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_get_collect_award_privilege_req()
end
function LogicEliminationKingEffect:on_get_collect_award_privilege_rsp(data)
  if data and data.elimi_king then
    self.elimi_king_data = data.elimi_king
    local ResearchRedDot = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.ResearchRedDot)
    ResearchRedDot:SetKillEffectRedDot(self.elimi_king_data.all_effect)
  end
  EventSystem:postEvent(EVENTTYPE_ELIMINATION_KING_EFFECTS, EVENTID_ELIMINATION_KING_EFFECTS_INFO_RSP)
end
function LogicEliminationKingEffect:on_set_elimination_king_effect_rsp(resId)
  if self.elimi_king_data then
    self.elimi_king_data.equip_effect = resId
  end
  EventSystem:postEvent(EVENTTYPE_ELIMINATION_KING_EFFECTS, EVENTID_ELIMINATION_KING_EFFECTS_EQUIP_UPDATE)
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicEliminationKingEffect)
return CModuleTemplate