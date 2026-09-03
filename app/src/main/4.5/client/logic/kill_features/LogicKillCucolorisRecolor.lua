local LogicKillCucolorisRecolor = {}
local EnumOperateType = {PotOn = 1, PotOff = 2}
function LogicKillCucolorisRecolor:DefineAndResetData()
  self.kill_cucoloris_recolor = nil
end
function LogicKillCucolorisRecolor:OnInitialize()
end
function LogicKillCucolorisRecolor:ClearCacheData()
  self.kill_cucoloris_recolor = nil
end
function LogicKillCucolorisRecolor:CheckHasEffect(itemId)
  if not itemId then
    return false
  end
  if not self.kill_cucoloris_recolor or not self.kill_cucoloris_recolor.all_colors then
    return false
  end
  if self.kill_cucoloris_recolor.all_colors[itemId] then
    return true
  end
  return false
end
function LogicKillCucolorisRecolor:GetCurEquipedItemId()
  if self.kill_cucoloris_recolor and self.kill_cucoloris_recolor.use_color then
    return self.kill_cucoloris_recolor.use_color
  end
  return nil
end
function LogicKillCucolorisRecolor:GetAllEffectItems()
  if self.kill_cucoloris_recolor and self.kill_cucoloris_recolor.all_colors then
    return self.kill_cucoloris_recolor.all_colors
  end
  return {}
end
function LogicKillCucolorisRecolor:PutOnKillRecolorItem(itemId)
  local curUseColor = self.kill_cucoloris_recolor and self.kill_cucoloris_recolor.use_color
  if not itemId or itemId == curUseColor then
    log(bWriteLog and "LogicKillCucolorisRecolor:PutOnKillRecolorItem not need")
    return
  end
  self:ChangeKillRecolorItem(itemId, EnumOperateType.PotOn)
end
function LogicKillCucolorisRecolor:PutOffKillRecolorItem(itemId)
  self:ChangeKillRecolorItem(itemId, EnumOperateType.PotOff)
end
function LogicKillCucolorisRecolor:ChangeKillRecolorItem(itemId, optype)
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_set_collect_privilege_req(itemId, optype):Then(function(_, _item_id, _optype)
    if self.kill_cucoloris_recolor then
      if _optype == EnumOperateType.PotOff then
        self.kill_cucoloris_recolor.use_color = nil
      else
        self.kill_cucoloris_recolor.use_color = _item_id
      end
    end
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_KILL_CUCOLORIS_RECOLOR_EQUIP_UPDATE)
  end)
end
function LogicKillCucolorisRecolor:CheckAndReqRecolorData()
  if self.kill_cucoloris_recolor then
    log(bWriteLog and "LogicKillCucolorisRecolor:CheckAndReqRecolorData not need")
    return
  end
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_get_collect_award_privilege_req()
end
function LogicKillCucolorisRecolor:on_get_collect_award_privilege_rsp(data)
  if not data then
    return
  end
  self:RefreshBadgeAllowLit(data)
  if data.kill_cucoloris_recolor then
    self.kill_cucoloris_recolor = data.kill_cucoloris_recolor
    log_tree("LogicKillCucolorisRecolor:on_get_collect_award_privilege_rsp", self.kill_cucoloris_recolor)
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_KILL_CUCOLORIS_RECOLOR_EQUIP_UPDATE)
  end
end
function LogicKillCucolorisRecolor:on_notify_collect_privilege_data(data)
  if not data then
    return
  end
  self:RefreshBadgeAllowLit(data)
  if data.kill_cucoloris_recolor then
    self.kill_cucoloris_recolor = data.kill_cucoloris_recolor
    log_tree("LogicKillCucolorisRecolor:on_get_collect_award_privilege_rsp", self.kill_cucoloris_recolor)
    EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_KILL_CUCOLORIS_RECOLOR_EQUIP_UPDATE)
  end
end
function LogicKillCucolorisRecolor:RefreshBadgeAllowLit(data)
  log(bWriteLog and string.format("LogicKillCucolorisRecolor:RefreshBadgeAllowLit data.collect_frame_priv = %s", data.collect_frame_priv))
  if data.collect_frame_priv then
    local collect_badge_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_badge_module)
    collect_badge_module:SetBadgeAllowLit(data.collect_frame_priv)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, LogicKillCucolorisRecolor)
return CModuleTemplate