local NicknameColorManager = {}
local macro = require("client.slua.logic.lobby_chat.chat_macro")
local defaultColorConfig = {
  [ENUM_NAME_COLOR_UI_TYPE.ChatChannel] = FSlateColor(FLinearColor(1, 1, 1, 0.7)),
  [ENUM_NAME_COLOR_UI_TYPE.Rank] = FSlateColor(FLinearColor(0, 0, 0, 1)),
  [ENUM_NAME_COLOR_UI_TYPE.ChatRoom] = FSlateColor(FLinearColor(1, 1, 1, 0.7)),
  [ENUM_NAME_COLOR_UI_TYPE.MomentComment] = FSlateColor(FLinearColor(0.693872, 0.14996, 0, 1)),
  [ENUM_NAME_COLOR_UI_TYPE.TeamChannel] = FSlateColor(FLinearColor(0, 0, 0, 0.7)),
  [ENUM_NAME_COLOR_UI_TYPE.RightPopup] = FSlateColor(FLinearColor(0, 0, 0, 1)),
  [ENUM_NAME_COLOR_UI_TYPE.RoleInfo] = FSlateColor(FLinearColor(0, 0, 0, 1)),
  [ENUM_NAME_COLOR_UI_TYPE.FriendApply] = FSlateColor(FLinearColor(0, 0, 0, 1))
}
function NicknameColorManager:DefineAndResetData()
  self.msg_recolor = {}
  self.bGetSelfData = false
  self.msg_recolor_change_time = 0
  self.UserData = {}
  self.DEFAULT_PLAN_ID = 61910002
  self.OPTYPE = {PUT_ON = 1, PUT_OFF = 2}
end
function NicknameColorManager:OnInitialize()
  if not self.bGetSelfData then
    self:send_get_collect_award_privilege_req()
  end
end
function NicknameColorManager:OnLogin(bReLogin)
  if not self.bGetSelfData then
    self:send_get_collect_award_privilege_req()
  end
end
function NicknameColorManager:OnLogOut()
  self.msg_recolor = {}
  self.bGetSelfData = false
  self.UserData = {}
end
function NicknameColorManager:SetUserData(UID, planID)
  log(bWriteLog and string.format("NicknameColorManager:SetUserData UID = %s, planID = %s", tostring(UID), tostring(planID)))
  if not UID then
    return
  end
  planID = planID or self.DEFAULT_PLAN_ID
  UID = tostring(UID)
  self.UserData[UID] = planID
  EventSystem:postEvent(EVENTTYPE_COLLECT, EVENTID_COLLECT_NICKNAME_COLOR_CHANGE, UID)
end
function NicknameColorManager:GetUserData(UID)
  UID = tostring(UID)
  if not Client.IsShipping() then
    log(bWriteLog and "NicknameColorManager:GetUserData" .. UID)
  end
  if self.UserData[UID] then
    return self.UserData[UID]
  end
  return self.DEFAULT_PLAN_ID
end
function NicknameColorManager:GetColorByUID(UID, uiType)
  return self:GetColorByPlanID(self:GetUserData(UID), uiType)
end
function NicknameColorManager:GetColorByPlanID(planID, uiType)
  log(bWriteLog and string.format("NicknameColorManager:GetColorByPlanID planID:%s, Channel:%s", tostring(planID), tostring(uiType)))
  if not planID then
    return self:GetDefaultColorByType(uiType)
  end
  local NickNameColorCfg = CDataTable.GetTableData("NicknameColorCfg", planID)
  if NickNameColorCfg and NickNameColorCfg.ColorName and NickNameColorCfg.ColorName ~= "" then
    local colorCfg = CDataTable.GetTableData("FontColorPreset", NickNameColorCfg.ColorName)
    if colorCfg then
      local StringUtil = require("common.string_util")
      local colorStrList = StringUtil.Split(colorCfg.FontColor, ";")
      local R = colorStrList[1] and tonumber(colorStrList[1]) / 255.0 or 0
      local G = colorStrList[2] and tonumber(colorStrList[2]) / 255.0 or 0
      local B = colorStrList[3] and tonumber(colorStrList[3]) / 255.0 or 0
      local A = colorStrList[4] and tonumber(colorStrList[4]) / 255.0 or 0
      return FSlateColor(FLinearColor(R, G, B, A))
    end
  end
  return self:GetDefaultColorByType(uiType)
end
function NicknameColorManager:GetDefaultColorByType(uiType)
  if not uiType then
    return FSlateColor(FLinearColor(1, 1, 1, 1))
  end
  local color = defaultColorConfig[uiType]
  if color then
    return color
  else
    return FSlateColor(FLinearColor(1, 1, 1, 1))
  end
end
function NicknameColorManager:GetDarkColorByUID(UID)
  return self:GetDarkColorByPlanID(self:GetUserData(UID))
end
function NicknameColorManager:GetDarkColorByPlanID(planID)
  if not planID then
    return FSlateColor(FLinearColor(0, 0, 0, 0.7))
  end
  local NickNameColorCfg = CDataTable.GetTableData("NicknameColorCfg", planID)
  local colorCfg
  if NickNameColorCfg then
    if NickNameColorCfg.DarkColorName and NickNameColorCfg.DarkColorName ~= "" then
      colorCfg = CDataTable.GetTableData("FontColorPreset", NickNameColorCfg.DarkColorName)
    end
    if not colorCfg and NickNameColorCfg.ColorName and NickNameColorCfg.ColorName ~= "" then
      colorCfg = CDataTable.GetTableData("FontColorPreset", NickNameColorCfg.ColorName)
    end
  end
  if colorCfg then
    local StringUtil = require("common.string_util")
    local colorStrList = StringUtil.Split(colorCfg.FontColor, ";")
    local R = colorStrList[1] and tonumber(colorStrList[1]) / 255.0 or 0
    local G = colorStrList[2] and tonumber(colorStrList[2]) / 255.0 or 0
    local B = colorStrList[3] and tonumber(colorStrList[3]) / 255.0 or 0
    local A = colorStrList[4] and tonumber(colorStrList[4]) / 255.0 or 0
    return FSlateColor(FLinearColor(R, G, B, A))
  end
  return FSlateColor(FLinearColor(0, 0, 0, 0.7))
end
function NicknameColorManager:ChangeTextColorByUID(text, UID)
  local planID = self:GetUserData(UID)
  if planID ~= self.DEFAULT_PLAN_ID then
    local NickNameColorCfg = CDataTable.GetTableData("NicknameColorCfg", planID)
    if NickNameColorCfg and NickNameColorCfg.StyleName and NickNameColorCfg.StyleName ~= "" then
      return "<" .. NickNameColorCfg.StyleName .. ">" .. text .. "</>"
    end
  end
  return text
end
function NicknameColorManager:GetCurColor()
  if self.msg_recolor and self.msg_recolor.use_color then
    return self.msg_recolor.use_color
  end
  return self.DEFAULT_PLAN_ID
end
function NicknameColorManager:GetAllColors()
  if self.msg_recolor and self.msg_recolor.all_colors then
    return self.msg_recolor.all_colors
  end
  return {}
end
function NicknameColorManager:send_get_collect_award_privilege_req()
  local CollectHandler = require("client.network.Protocol.CollectHandler")
  CollectHandler.send_get_collect_award_privilege_req()
end
function NicknameColorManager:on_get_collect_award_privilege_rsp(data)
  self.msg_recolor = data.msg_recolor or {}
  log_tree("get_collect_award_privilege_rsp", self.msg_recolor)
  self:SetUserData(DataMgr.roleData.uid, self.msg_recolor.use_color or self.DEFAULT_PLAN_ID)
  self.bGetSelfData = true
end
function NicknameColorManager:send_set_collect_privilege_req(item_id, optype)
  log(bWriteLog and string.format("NicknameColorManager:send_set_collect_privilege_req %s  %s", tostring(item_id), tostring(optype)))
  local TimeUtil = require("client.common.time_util")
  if optype == self.OPTYPE.PUT_ON then
    if not item_id or item_id == self.msg_recolor.use_color then
      log(bWriteLog and "NicknameColorManager:send_set_collect_privilege_req not need")
      return
    end
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_set_collect_privilege_req(item_id, optype):Then(function(_, _item_id, _optype)
      self.msg_recolor.use_color = _item_id
      self.msg_recolor_change_time = TimeUtil.GetServerTimeInSec()
      self:SetUserData(DataMgr.roleData.uid, self.msg_recolor.use_color or self.DEFAULT_PLAN_ID)
    end)
  elseif optype == self.OPTYPE.PUT_OFF and self.msg_recolor.use_color then
    local CollectHandler = require("client.network.Protocol.CollectHandler")
    CollectHandler.send_set_collect_privilege_req(item_id, optype):Then(function(_, _item_id, _optype)
      if _optype == self.OPTYPE.PUT_ON then
        self.msg_recolor.use_color = _item_id
        self.msg_recolor_change_time = TimeUtil.GetServerTimeInSec()
        self:SetUserData(DataMgr.roleData.uid, _item_id)
      end
      if _optype == self.OPTYPE.PUT_OFF then
        self.msg_recolor.use_color = nil
        self.msg_recolor_change_time = TimeUtil.GetServerTimeInSec()
        self:SetUserData(DataMgr.roleData.uid, self.DEFAULT_PLAN_ID)
      end
    end)
  end
end
function NicknameColorManager:on_notify_collect_privilege_data(data)
  self.msg_recolor = data.msg_recolor or {}
  log_tree("on_notify_collect_privilege_data", self.msg_recolor)
  self:SetUserData(DataMgr.roleData.uid, self.msg_recolor.use_color or self.DEFAULT_PLAN_ID)
  self.bGetSelfData = true
end
function NicknameColorManager:CanTrustProfileColor()
  local TimeUtil = require("client.common.time_util")
  local canTrust = TimeUtil.GetServerTimeInSec() - self.msg_recolor_change_time > 3
  log(bWriteLog and "NicknameColorManager:CanTrustProfileColor. canTrust = " .. tostring(canTrust))
  return canTrust
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CNicknameColorManager = class(CModuleBase, nil, NicknameColorManager)
return CNicknameColorManager