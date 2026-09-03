local FeatureRedEmotion = {}
local Trait = require("common.trait")
local TFeatureRedEmotion = Trait(Trait.TraitPrototype, nil, FeatureRedEmotion)
function FeatureRedEmotion:PlayFeatureEmotion(emoteCfg, widget)
  local PufferConst = require("client.slua.logic.download.puffer_const")
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local state = PufferManager.GetState(PufferConst.ENUM_DownloadType.ODPAK, {
    self.curFeaturesItemID
  })
  if state ~= PufferConst.ENUM_DownloadState.Done then
    log(bWriteLog and string.format("FeatureRedEmotion:PlayFeatureEmotion self.curFeaturesItemID = %s, Not downloaded.", self.curFeaturesItemID))
    return
  end
  log(bWriteLog and "[edward][store_feature_component] PlayFeatureEmotion")
  self:NotifyOtherFeatureStop(emoteCfg)
  local logic_store_enter_feature = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_store_enter_feature)
  if widget then
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    local ShowingAvatar = ModelDisplayer.GetShowingAvatar()
    local cfg = emoteCfg.config
    local dependence = cfg.itemId
    if dependence ~= 0 and dependence ~= cfg.ExpressionID and ShowingAvatar and not ShowingAvatar:HasEquiped(dependence) then
      local DetailComponentMain = self:GetParentUI()
      DetailComponentMain:ShowAvatarDisplay(dependence, {withOutAction = 1})
      local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
      if ModelDisplayTypeHelper.IsWeaponById(self.curFeaturesItemID) then
        DetailComponentMain:ShowAvatarDisplay(self.curFeaturesItemID, {withOutAction = 1})
      end
    end
    log(bWriteLog and "  FeatureRedEmotion:PlayFeatureEmotion. self.nCurShowModelId: " .. tostring(self.nCurShowModelId))
    log(bWriteLog and "  FeatureRedEmotion:PlayFeatureEmotion. self.curFeaturesItemID: " .. tostring(self.curFeaturesItemID))
    local emoteID = logic_store_enter_feature:PlayOnceNormalEmotion(emoteCfg, self.curFeaturesItemID, self.nCurShowModelId)
    if emoteID <= 0 then
      local golden_suit_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.golden_suit_module)
      local itemId = golden_suit_module:GetAnotherItemId(self.curFeaturesItemID)
      if 0 < itemId then
        emoteID = logic_store_enter_feature:PlayOnceNormalEmotion(emoteCfg, itemId, self.nCurShowModelId)
      end
    end
    if 0 < emoteID and CDataTable.GetTableData("ItemUpgradeCollectEmote", emoteID) then
      EventSystem:postEvent(EVENTTYPE_DETAIL_COMPONENT, EVENTID_DETAIL_ON_WEAPON_SHOW_EMOTE_PLAY)
    end
  end
end
return TFeatureRedEmotion