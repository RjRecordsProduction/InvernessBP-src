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
function setting_refresh_RelationShowOrder._ShowItemOneChoose(curItem, key, ui)
  log(bWriteLog and "setting_refresh_RelationShowOrder._ShowItemOneChoose key = " .. key)
  setting_refresh_RelationShowOrder.UpdateItem(curItem)
  ui:AddControlEventByControl(curItem.Setting_Switch_Button_Item_1.Button_0, "OnClicked", setting_refresh_RelationShowOrder.OnClickItem, key, 1)
  ui:AddControlEventByControl(curItem.Setting_Switch_Button_Item_2.Button_0, "OnClicked", setting_refresh_RelationShowOrder.OnClickItem, key, 2)
  ui:AddControlEventByControl(curItem.Setting_Switch_Button_Item_3.Button_0, "OnClicked", setting_refresh_RelationShowOrder.OnClickItem, key, 3)
  ui:AddControlEventByControl(curItem.Setting_Switch_Button_Item_4.Button_0, "OnClicked", setting_refresh_RelationShowOrder.OnClickItem, key, 4)
  ui:AddControlEventByControl(curItem.Setting_Switch_Button_Item_5.Button_0, "OnClicked", setting_refresh_RelationShowOrder.OnClickItem, key, 5)
end
function setting_refresh_RelationShowOrder.RefreshRelationShowOrder(key)
  log(bWriteLog and "setting_refresh_RelationShowOrder.RefreshRelationShowOrder key = " .. key)
  local setting_config = require("client.logic.setting.setting_config")
  if setting_config[key] == nil then
    return
  end
  local widget = setting_config[key].widget
  if not slua.isValid(widget) then
    return
  end
  setting_refresh_RelationShowOrder.UpdateItem(widget)
end
function setting_refresh_RelationShowOrder.UpdateItem(curItem)
  log(bWriteLog and "setting_refresh_RelationShowOrder.UpdateItem")
  local i = 1
  local PersonSpaceSystem = require("client.logic.personspace.logic_person_space")
  local curSelect = 0
  if PersonSpaceSystem.relationPrior == nil then
    curSelect = 0
  else
    curSelect = setting_refresh_RelationShowOrder.saveIndexToShowIndexMap[PersonSpaceSystem.relationPrior.prior_type]
  end
  local IntimacyUtils = require("client.slua.logic.friend.Intimacy.IntimacyUtils")
  local bIsBondingSystem = IntimacyUtils.IsBondingSystemOpen()
  for i = 1, 5 do
    local item = curItem["Setting_Switch_Button_Item_" .. i]
    if i <= 4 then
      if i == 1 and bIsBondingSystem then
        item.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(8075914))
        item.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(8075914))
      else
        item.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(33144 + i))
        item.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(33144 + i))
      end
    elseif i == 5 then
      item.TextBlock_0:SetText(LocUtil.GetLocalizeResStr(73243))
      item.TextBlock_1:SetText(LocUtil.GetLocalizeResStr(73243))
    end
    if i == curSelect then
      item.WidgetSwitcher_0:SetActiveWidgetIndex(0)
    else
      item.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    end
  end
  setting_refresh_RelationShowOrder.end
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