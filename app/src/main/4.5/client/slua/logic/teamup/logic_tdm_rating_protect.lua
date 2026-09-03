local logic_tdm_rating_protect = {}
function logic_tdm_rating_protect:OnInitialize()
  logic_tdm_rating_protect.__super.OnInitialize(self)
  self.protect_info = nil
  self.has_get_tdm_rank_protect_info_req = false
end
function logic_tdm_rating_protect:send_get_tdm_rank_protect_info_req()
  local DoubleCardHandler = require("client.network.Protocol.DoubleCardHandler")
  DoubleCardHandler.send_get_tdm_rank_protect_info_req(tonumber(DataMgr.roleData.uid))
end
function logic_tdm_rating_protect:proc_get_tdm_rank_protect_info_rsp(error_code, protect_info)
  self.has_get_tdm_rank_protect_info_req = true
  if error_code ~= 0 then
    return
  end
  self.  EventSystem:postEvent(EVENTTYPE_DOUBLECARD, EVENTID_TDM_PROTECT_INFO_RSP, protect_info)
end
function logic_tdm_rating_protect:SetResultType(battle_result)
  if not battle_result or not battle_result.left_protect_times then
    return
  end
  if not self.protect_info then
    self:send_get_tdm_rank_protect_info_req()
    return
  end
  self.protect_info.left_protect_times = battle_result.left_protect_times
  EventSystem:postEvent(EVENTTYPE_DOUBLECARD, EVENTID_TDM_PROTECT_INFO_RSP, protect_info)
end
function logic_tdm_rating_protect:GetProtectInfo()
  log("logic_tdm_rating_protect:GetProtectInfo")
  if not self.has_get_tdm_rank_protect_info_req then
    self:send_get_tdm_rank_protect_info_req()
    return nil
  end
  return self.protect_info
end
function logic_tdm_rating_protect:GetIsProtect(onlyCheckData)
  if not onlyCheckData then
    local logic_mode_selection = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_mode_selection)
    local matchMode, viewID, viewIDs = logic_mode_selection:GetCurSelectInfo()
    local viewInfo = logic_mode_selection:GetSubviewInfoBySubviewID(viewID)
    local config_arena = require("client.slua.logic.arena.config_arena")
    if not viewInfo or viewInfo.menu_id ~= config_arena.ModeMenuId then
      return false
    end
  end
  local protect_info = self:GetProtectInfo()
  if not protect_info then
    return false
  end
  return protect_info.left_protect_times and protect_info.left_protect_times > 0
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_tdm_rating_protect)