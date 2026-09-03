local setting_refresh_RelationShowOrder = {
  showIndexToSaveIndexMap = {
    [1] = 2,
    [2] = 1,
    [3] = 3,
    [4] = 4,
    [5] = 5
  },
  saveIndexToShowIndexMap = {
    [1] = 2,
    [2] = 1,
    [3] = 3,
    [4] = 4,
    [5] = 5
  }
}
function setting_refresh_RelationShowOrder.OnClickItem(key, index)
  log(bWriteLog and "setting_refresh_RelationShowOrder.OnClickItem key = " .. key .. ", index = " .. index)
  local logic_person_space = require("client.logic.personspace.logic_person_space")
  local curSelect = setting_refresh_RelationShowOrder.saveIndexToShowIndexMap[logic_person_space.relationPrior.prior_type]
  if curSelect == index then
    log(bWriteLog and "setting_refresh_RelationShowOrder.OnClickItem curSelect == index")
    return
  end
  setting_refresh_RelationShowOrder.curSelect = index
  local audio_util = require("client.common.audio_util")
  audio_util.PlayAudio(sound_config.click_v1)
  local saveIndex = setting_refresh_RelationShowOrder.showIndexToSaveIndexMap[index]
  local PersonSpaceHandler = require("client.network.Protocol.PersonSpaceHandler")
  PersonSpaceHandler.send_set_intimacy_relation_prior_show(saveIndex)
end
function setting_refresh_RelationShowOrder.BShowRelationShowOrder()
  if IsWoWEditor then
    return false
  end
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  if PersonSpaceSystem.relationPrior == nil then
    return false
  end
  return PersonSpaceSystem.relationPrior.unlock_intimacy
end
return setting_refresh_RelationShowOrder