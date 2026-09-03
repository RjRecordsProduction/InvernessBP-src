local FeatureShow3D = {}
local Trait = require("common.trait")
local TFeatureShow3D = Trait(Trait.TraitPrototype, nil, FeatureShow3D)
local lastFeaturesItemID
function FeatureShow3D:Show3D(data)
  local DetailComponentMain = self:GetParentUI()
  local expressionID = data.config.ExpressionID
  log_warning(bWriteLog and "  FeatureShow3D:Show3D. expressionID: " .. tostring(expressionID))
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  logic_store_enter_feature:ClearLoopTimer()
  DetailComponentMain:ShowAvatarDisplay(expressionID)
  DetailComponentMain:UpdateItemId(expressionID)
  DetailComponentMain:SetViewComponentData(expressionID)
  lastFeaturesItemID = self.curFeaturesItemID
end
function FeatureShow3D:Stop3D(close, dontStopAction)
  log_warning(bWriteLog and "  FeatureShow3D:Stop3D. close: " .. tostring(close))
  local DetailComponentMain = self:GetParentUI()
  local curFeaturesItemID = self.curFeaturesItemID
  if not curFeaturesItemID or curFeaturesItemID <= 0 then
    return
  end
  if close then
    return
  end
  DetailComponentMain:UpdateItemId(curFeaturesItemID)
  DetailComponentMain:SetViewComponentData(curFeaturesItemID)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  if not ModelDisplayer.IsShowModel() then
    log_warning(bWriteLog and "  FeatureShow3D:Stop3D.  ModelDisplayer.IsShowModel(")
    return
  end
  log_warning(bWriteLog and "  FeatureShow3D:Stop3D. lastFeaturesItemID: " .. tostring(lastFeaturesItemID))
  if lastFeaturesItemID == curFeaturesItemID then
    log_warning(bWriteLog and "  FeatureShow3D:Stop3D. self.curFeaturesItemID: " .. tostring(curFeaturesItemID))
    DetailComponentMain:ShowAvatarDisplay(curFeaturesItemID, {withOutAction = 1})
  end
end
return TFeatureShow3D