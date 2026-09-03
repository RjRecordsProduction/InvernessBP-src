local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.OnClickPetAction(actionList)
  log(bWriteLog and "StoreOtherUtils.OnClickPetAction, actionList = " .. tostring(actionList))
  local StringUtil = require("common.string_util")
  local storeAction = StringUtil.Split(actionList, "|")
  log_tree("StoreOtherUtils.OnClickPetAction, storeAction = ", storeAction)
  if 0 < #storeAction then
    local key = math.random(#storeAction)
    local actionID = tonumber(storeAction[key])
    if not actionID then
      return
    end
    local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
    local showingAvatar = ModelDisplayer.GetShowingAvatar()
    if showingAvatar then
      showingAvatar:PlayPetAction(actionID)
    end
    ModelDisplayer.PlayPetAction(actionID)
  else
    log(bWriteLog and "StoreOtherUtils.OnClickPetAction, not action can show in store.")
  end
end
function StoreUtils.PlayPetFeature(bSkipSync)
  local ModelDisplayer = require("client.logic.avatar.ModelDisplayer")
  local showingAvatar = ModelDisplayer.GetShowingAvatar()
  if showingAvatar then
    showingAvatar:PlayPetFeature(bSkipSync)
  end
  ModelDisplayer.PlayPetFeature(bSkipSync)
end