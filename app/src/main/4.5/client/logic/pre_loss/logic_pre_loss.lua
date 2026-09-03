local logic_pre_loss = {}
local preLossDataTab
local isFightingToLobby = false
function logic_pre_loss:OnInitialize()
  logic_pre_loss.__super.OnInitialize(self)
  preLossDataTab = {}
end
function logic_pre_loss:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_URL, BP_ENUM_MODULE_PRESS_LOSS, self.OnPressLoss, self)
end
function logic_pre_loss:OnLogin(bReLogin)
end
function logic_pre_loss:OnLogOut()
end
function logic_pre_loss:OnPreSwitchGameStatus(preState, nextState)
  log(bWriteLog and string.format("[logic_pre_loss] OnPreSwitchGameStatus preState[%s] nextState[%s]", preState, nextState))
  if preState == GameStatus.Fighting and nextState == GameStatus.Lobby then
    isFightingToLobby = true
  elseif not GameStatus.IsInMainCity() then
    isFightingToLobby = false
  end
end
function logic_pre_loss:GetTitleAndContentId(display_type)
  log(bWriteLog and "logic_pre_loss:GetTitleAndContentId display_type = " .. tostring(display_type))
  if display_type == nil or type(display_type) ~= "number" then
    return nil, nil
  end
  local PreLossTextConfig = CDataTable.GetTableData("PreLossTextConfig", display_type)
  if not PreLossTextConfig then
    log(bWriteLog and "logic_pre_loss GetTitleAndContentId config is nil")
    return nil, nil
  end
  log(bWriteLog and "logic_pre_loss GetTitleAndContentId titleId = " .. tostring(PreLossTextConfig.TitleId) .. " and contentId = " .. tostring(PreLossTextConfig.ContentId))
  return PreLossTextConfig.TitleId, PreLossTextConfig.ContentId
end
function logic_pre_loss:GetRewardData(display_type)
  log(bWriteLog and "logic_pre_loss:GetRewardData display_type = " .. tostring(display_type))
  if display_type == nil or type(display_type) ~= "number" then
    return nil
  end
  if preLossDataTab == nil or not next(preLossDataTab) then
    log(bWriteLog and "logic_pre_loss:GetRewardData preLossDataTab is nil")
    return nil
  end
  local preLossData = preLossDataTab[display_type]
  if preLossData == nil or not next(preLossData) then
    log(bWriteLog and "logic_pre_loss:GetRewardData preLossData is nil")
    return nil
  end
  return preLossData.items
end
function logic_pre_loss:ClearPreLossData(display_type)
  log(bWriteLog and "logic_pre_loss:ClearData display_type = " .. tostring(display_type))
  if display_type == nil or type(display_type) ~= "number" then
    return
  end
  preLossDataTab[display_type] = nil
end
function logic_pre_loss:GetItemName(itemId)
  log(bWriteLog and "logic_pre_loss:GetItemNam")
  if itemId == nil then
    log(bWriteLog and "logic_pre_loss:GetItemNam itemId is invalid")
    return nil
  end
  itemId = tonumber(itemId)
  local UIUtil = require("client.common.ui_util")
  local itemCfg = UIUtil.GetItemCfg(itemId)
  return itemCfg.ItemName
end
function logic_pre_loss:OnPressLoss()
  log(bWriteLog and "logic_pre_loss:OnPressLoss")
  local LogicSettingGraphics = require("client.slua.logic.setting.logic_setting_graphics")
  LogicSettingGraphics.PopNegativePlayGuide()
  if not self:ShouldSlapPreLossPopup() then
    log(bWriteLog and "logic_pre_loss OnPressLoss ShouldSlapPreLossPopup return false")
    return
  end
  isFightingToLobby = false
  local time_ticker = require("common.time_ticker")
  time_ticker.AddTimerOnce(0.1, function()
    local preLossMacros = require("client.logic.pre_loss.pre_loss_macros")
    UIManager.ShowUI(UIManager.UI_Config.PreChurn_Popup_UIBP, preLossMacros.Display_Type.SegmentCare)
  end)
end
function logic_pre_loss:ShouldSlapPreLossPopup()
  log(bWriteLog and "logic_pre_loss ShouldSlapPreLossPopup isFightingToLobby " .. tostring(isFightingToLobby))
  local preLossMacros = require("client.logic.pre_loss.pre_loss_macros")
  return self:CanShowDisPlayTypeUI(preLossMacros.Display_Type.SegmentCare)
end
function logic_pre_loss:CanShowDisPlayTypeUI(displayType)
  if isFightingToLobby ~= true then
    return false
  end
  return self:IsPreLossDisPlayTypeExist(displayType)
end
function logic_pre_loss:IsPreLossDisPlayTypeExist(displayType)
  log_tree(bWriteLog and "[v_wllwu] logic_pre_loss:IsPreLossDisPlayTypeExist, preLossDataTab is  ", preLossDataTab)
  if not preLossDataTab or not preLossDataTab[displayType] then
    return false
  end
  return true
end
function logic_pre_loss:GetRemainHour(itemId)
  log(bWriteLog and "logic_pre_loss:GetRemainHour itemId = " .. tostring(itemId))
  if itemId == nil then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local itemData = wardrobe_data:GetHallDepotItemDataByResIDAndValidExpireTime(tonumber(itemId))
  local validTime = 0
  if itemData and itemData.expireTS then
    log(bWriteLog and "logic_pre_loss:GetRemainHour itemData.expireTS = " .. tostring(itemData.expireTS))
    validTime = itemData.expireTS
  end
  local TimeUtil = require("client.common.time_util")
  local remainTime = validTime - TimeUtil.GetServerTimeInSec()
  local SecToHour = 2.777777777777778E-4
  local hour = math.ceil(remainTime * SecToHour)
  log(bWriteLog and "logic_pre_loss:GetRemainHour hour = " .. tostring(hour))
  if hour < 0 then
    hour = 0
  end
  return hour
end
function logic_pre_loss:notify_pre_loss_trigger(rule_id, display_type, items)
  if rule_id == nil or type(rule_id) ~= "number" then
    log(bWriteLog and "logic_pre_loss:notify_pre_loss_trigger rule_id is invalid")
    return
  end
  if display_type == nil or type(display_type) ~= "number" then
    log(bWriteLog and "logic_pre_loss:notify_pre_loss_trigger display_type is invalid")
    return
  end
  preLossDataTab[display_type] = {rule_id = rule_id, items = items}
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CModuleTemplate = class(CModuleBase, nil, logic_pre_loss)
return CModuleTemplate