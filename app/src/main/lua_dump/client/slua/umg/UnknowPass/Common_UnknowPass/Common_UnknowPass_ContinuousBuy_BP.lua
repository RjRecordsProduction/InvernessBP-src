local Enum_UIRPType = {
  Trunk = 1,
  Branch = 2,
  History = 3
}
local Common_UnknowPass_ContinuousBuy_BP = {}
function Common_UnknowPass_ContinuousBuy_BP:OnClose()
  self.subItemUI = nil
  self.currentConfig = nil
  Common_UnknowPass_ContinuousBuy_BP.__super.OnClose(self)
  log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP close")
end
function Common_UnknowPass_ContinuousBuy_BP:SetTypeData(nSeasonId, nkeepBuyCount, bIsBuyElite, nShowEffect, nValue, nPassType)
  self:SetUnknowPassHistory(nSeasonId, nkeepBuyCount, bIsBuyElite, nShowEffect, nValue, nPassType)
end
function Common_UnknowPass_ContinuousBuy_BP:SetUnknowPass(nPassType, nShowEffect)
  log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP SetUnknowPass nSeasonId" .. tostring(nSeasonId) .. "nkeepBuyCount" .. tostring(nkeepBuyCount) .. "bIsBuyElite" .. tostring(bIsBuyElite) .. "nShowEffect" .. tostring(nShowEffect) .. "nValue" .. tostring(nValue) .. "nPassType" .. tostring(nPassType))
  local param_data = {
    nRPType = Enum_UIRPType.Trunk,
    nPassType = nPassType or 0,
    nShowEffect = nShowEffect or 1
  }
  self:_InitView(param_data)
end
function Common_UnknowPass_ContinuousBuy_BP:SetUnknowPassBranch()
  log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP SetBranchUnknowPass")
  local param_data = {
    nRPType = Enum_UIRPType.Branch
  }
  self:_InitView(param_data)
end
function Common_UnknowPass_ContinuousBuy_BP:SetUnknowPassHistory(nSeasonId, nkeepBuyCount, bIsBuyElite, nShowEffect, nValue, nPassType)
  log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP SetBranchUnknowPassHistory nSeasonId" .. tostring(nSeasonId) .. "nkeepBuyCount" .. tostring(nkeepBuyCount) .. "bIsBuyElite" .. tostring(bIsBuyElite) .. "nShowEffect" .. tostring(nShowEffect) .. "nValue" .. tostring(nValue) .. "nPassType" .. tostring(nPassType))
  if nSeasonId == 0 then
    nSeasonId = UnknowPassSystem.GetSeasonId()
  end
  if UnknowPassSystem.IsBeyondASeries(nSeasonId) then
    if not bIsBuyElite then
      nPassType = 0
    end
    self:SetUnknowPass(nPassType, nShowEffect)
    return
  end
  local param_data = {
    nRPType = Enum_UIRPType.History,
    nSeasonId = nSeasonId,
    nkeepBuyCount = nkeepBuyCount or 0,
    bIsBuyElite = bIsBuyElite,
    nShowEffect = nShowEffect or 0,
    nValue = nValue or 0,
    nPassType = nPassType or 0
  }
  self:_InitView(param_data)
end
function Common_UnknowPass_ContinuousBuy_BP:SetClickItemCallback(fCallback, ...)
  if not self.subItemUI then
    return
  end
  self.subItemUI:SetClickItemCallback(fCallback, ...)
end
function Common_UnknowPass_ContinuousBuy_BP:_CreateSubItem(param_data)
  local ui_config
  if param_data.nRPType == Enum_UIRPType.Trunk then
    ui_config = UIManager.UI_Config.UnknowPass_ContinuousBuy_UIBP
  elseif param_data.nRPType == Enum_UIRPType.Branch then
    ui_config = UIManager.UI_Config.UnknowPass_ContinuousBuy_BranchRP_UIBP
  elseif param_data.nRPType == Enum_UIRPType.History then
    ui_config = UIManager.UI_Config.UnknowPass_ContinuousBuy_History_UIBP
  end
  if not ui_config then
    log_error("Common_UnknowPass_ContinuousBuy_BP:_CreateSubItem rptype is not exist, type=" .. tostring(param_data.nRPType))
    return
  end
  if self.currentConfig and self.currentConfig ~= ui_config then
    if self.subItemUI then
      self.subItemUI:Close()
      self.subItemUI = nil
    end
    log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP change")
  end
  if self.subItemUI then
    log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP:_CreateSubItem self.subItemUI is exist")
    return
  end
  self:SetWidgetVisible(self.Image_Default, false)
  self.subItemUI = self:CreateChildWindow(self.Root, ui_config)
  self.subItemUI:SetAutoSize(true)
  self.currentConfig = ui_config
  log(bWriteLog and "Common_UnknowPass_ContinuousBuy_BP create")
end
function Common_UnknowPass_ContinuousBuy_BP:_InitView(param_data)
  self:_CreateSubItem(param_data)
  if not self.subItemUI then
    return
  end
  self.subItemUI:InitView(param_data)
end
local class = require("class")
local OverrideUIBase = require("client.slua_ui_framework.OverrideUIBase")
return class(OverrideUIBase, nil, Common_UnknowPass_ContinuousBuy_BP)