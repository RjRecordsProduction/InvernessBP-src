local FeatureGoldenAction = {}
local Trait = require("common.trait")
local TFeatureGoldenAction = Trait(Trait.TraitPrototype, nil, FeatureGoldenAction)
function FeatureGoldenAction:GoldenAction(data)
  local DetailComponentMain = self:GetParentUI()
  local itemId = data.config.ExpressionID
  log(bWriteLog and "  FeatureGoldenAction:GoldenAction. itemId: " .. tostring(itemId))
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  logic_store_enter_feature:ClearLoopTimer()
  DetailComponentMain:StopAllFeature()
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  if LogicFusionModule:IsFusionTargetItem(itemId) then
    local config = LogicFusionModule:GetFusionConfig(itemId)
    local curItemID = self.curFeaturesItemID
    if config and curItemID and curItemID ~= itemId then
      local curConfig = LogicFusionModule:GetFusionConfig(curItemID)
      if curConfig and curConfig.period == config.period then
        LogicFusionModule:SetFusionPreviewPre(config.period, curItemID)
      end
    end
  end
  self.bGoldenActionTriggered = true
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Display(itemId, true)
end
function FeatureGoldenAction:StopGoldenAction(_, dontStopAction)
  if dontStopAction then
    return
  end
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local ShowingAvatar = ModelDisplayer.GetShowingAvatar()
  if ShowingAvatar then
    local TeamAvatarManager = require("client.logic.avatar.logic_team_avatar_manager")
    TeamAvatarManager.StopActionWhenChangeClothesWithAvatar(ShowingAvatar)
  end
end
function FeatureGoldenAction:UnSelect35()
  local curFeaturesItemID = self.curFeaturesItemID
  local multi_state_manager = ModuleManager.GetModule(ModuleManager.CommonModuleConfig.multi_state_manager)
  local OriginItemID, _ = multi_state_manager:GetOriginClothIDAndState(curFeaturesItemID)
  if OriginItemID then
    curFeaturesItemID = OriginItemID
  end
  local LogicFusionModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicFusionModule)
  if LogicFusionModule:IsFusionTargetItem(self.curFeaturesItemID) then
    local config = LogicFusionModule:GetFusionConfig(self.curFeaturesItemID)
    if config then
      LogicFusionModule:ClearFusionPreviewPre(config.period)
      local parentUI = self:GetParentUI()
      local curItem = parentUI and parentUI.curItemID or 0
      local originItem
      for _, v in ipairs(config.originItems) do
        if curItem == v then
          originItem = v
          break
        end
      end
      if not originItem and config.originItems[1] then
        originItem = config.originItems[1]
      end
      if originItem then
        curFeaturesItemID = originItem
      else
        log_error(bWriteLog and "FeatureGoldenAction:UnSelect35 Fusion originItem not found!")
      end
    end
  end
  log(bWriteLog and "FeatureGoldenAction:UnSelect35. curFeaturesItemID: " .. tostring(curFeaturesItemID))
  self.bGoldenActionTriggered = true
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  ModelDisplayer.Display(curFeaturesItemID, true)
end
return TFeatureGoldenAction