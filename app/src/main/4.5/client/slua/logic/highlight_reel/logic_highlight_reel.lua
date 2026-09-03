local hl_macro = require("client.slua.logic.highlight_reel.highlight_reel_macro")
local logic_highlight_reel = {}
function logic_highlight_reel:DefineAndResetData()
  self.generating = nil
  self.finished = nil
  self.has_cache = false
  self.is_requesting = false
end
function logic_highlight_reel:OnInitialize()
end
function logic_highlight_reel:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_HIGHLIGHTREEL, self.OnJumpHightlightReel, self)
end
function logic_highlight_reel:OnLogOut()
  self:DefineAndResetData()
end
function logic_highlight_reel:_send_get_list_req()
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  SmartAssistantHandler.send_get_highlight_reel_list_req()
end
function logic_highlight_reel:_send_clear_red_dot_req(battle_id)
  local SmartAssistantHandler = require("client.network.Protocol.SmartAssistantHandler")
  SmartAssistantHandler.send_clear_highlight_reel_red_dot_req(battle_id)
end
local _map_to_sorted_array = function(map)
  local arr = {}
  if map then
    for _, r in pairs(map) do
      arr[#arr + 1] = r
    end
  end
  table.sort(arr, function(a, b)
    return (a.create_ts or 0) > (b.create_ts or 0)
  end)
  return arr
end
function logic_highlight_reel:HasCache()
  return self.has_cache == true
end
function logic_highlight_reel:GetRecordList()
  return _map_to_sorted_array(self.finished)
end
function logic_highlight_reel:GetUnreadCount()
  local count = 0
  if self.finished then
    for _, r in pairs(self.finished) do
      if r.is_new == 1 then
        count = count + 1
      end
    end
  end
  return count
end
function logic_highlight_reel:GetRecordById(battle_id)
  if not battle_id then
    return nil
  end
  if self.finished and self.finished[battle_id] then
    return self.finished[battle_id]
  end
  if self.generating and self.generating[battle_id] then
    return self.generating[battle_id]
  end
  return nil
end
function logic_highlight_reel:SplitByState()
  return _map_to_sorted_array(self.generating), _map_to_sorted_array(self.finished)
end
function logic_highlight_reel:IsClickable(record)
  if not record then
    return false
  end
  return record.video_url ~= nil and record.video_url ~= ""
end
function logic_highlight_reel:RequestList()
  if self.is_requesting then
    return
  end
  self.is_requesting = true
  self:_send_get_list_req()
end
function logic_highlight_reel:ClearRedDot(battle_id)
  if not battle_id then
    return
  end
  self:_send_clear_red_dot_req(battle_id)
end
function logic_highlight_reel:IsFeatureEnabled()
  local PublishRegionMacros = require("client.slua.config.ClientMacros.PublishRegionMacros")
  if PublishRegionMacros.IsBLUEHOLE() then
    return false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SWITCH_HIGHLIGHTREEL) then
    log(bWriteLog and "logic_highlight_reel:IsFeatureEnabled switch close")
    return false
  end
  return true
end
function logic_highlight_reel:_OnGetListRsp(err_code, generating, finished)
  self.is_requesting = false
  if err_code == 0 then
    self.generating = generating or {}
    self.finished = finished or {}
    self.has_cache = true
  else
    log(bWriteLog and string.format("[logic_highlight_reel] _OnGetListRsp err: %s", tostring(err_code)))
  end
  EventSystem:postEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_HIGHLIGHT_REEL_REFRESH)
end
function logic_highlight_reel:_OnClearRedDotRsp(err_code, battle_id)
  if err_code == 0 then
    local rec = self.finished and self.finished[battle_id]
    if rec then
      rec.is_new = 0
    end
  elseif err_code == hl_macro.ERR_HL_REEL_RECORD_NOT_FOUND and self.finished then
    self.finished[battle_id] = nil
  end
  EventSystem:postEvent(EVENTTYPE_SMARTASSISTANT, EVENTID_HIGHLIGHT_REEL_REFRESH)
end
function logic_highlight_reel:OnJumpHightlightReel()
  log(bWriteLog and "logic_highlight_reel:OnJumpHightlightReel")
  if self:IsFeatureEnabled() then
    UIManager.ShowUI(UIManager.UI_Config.SmartAssistantV2_Popup_Medium_HaveTab_UIBP)
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
return class(CModuleBase, nil, logic_highlight_reel)