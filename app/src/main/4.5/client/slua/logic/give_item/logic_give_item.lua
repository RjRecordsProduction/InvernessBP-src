local logic_give_item = {
  EnumGiveType = {
    shop = 1,
    rpCard = 2,
    goldSuit = 3,
    petCard = 4,
    vehicle = 5,
    tarotCard = 6
  },
  switchMapInfo = nil,
  giveCondition = nil
}
local MenuOpenId = {
  [logic_give_item.EnumGiveType.shop] = BP_ENUM_LOBBY_MENU_SEND_GIFT,
  [logic_give_item.EnumGiveType.rpCard] = BP_ENUM_MENU_UNKNOW_PASS_GIFT,
  [logic_give_item.EnumGiveType.goldSuit] = BP_ENUM_GOLDEN_SUIT_GIFT_ID
}
function logic_give_item.IsCanShowEntrance(giveType)
  local menuId = MenuOpenId[giveType]
  if menuId ~= nil and not LobbySystem.CheckOpen(menuId) then
    return false
  end
  local switchInfo = logic_give_item.switchMapInfo or {}
  if switchInfo[giveType] ~= nil and not switchInfo[giveType].if_open then
    return false
  end
  return true
end
function logic_give_item.CheckGiftSwitch(giveType)
  local switchInfo = logic_give_item.switchMapInfo or {}
  if switchInfo[giveType] ~= nil and not switchInfo[giveType].if_open then
    return false
  end
  return true
end
function logic_give_item.SetGiveSwitchInfo(info)
  logic_give_item.switchMapInfo = info
end
function logic_give_item.GetGiveCondition()
  if not logic_give_item.giveCondition then
    logic_give_item.giveCondition = {}
    local configs = CDataTable.GetTable("SendGiftCondition")
    for _, v in pairs(configs) do
      local condition = {}
      condition.sendMinSeconds = v.SendMinSeconds
      condition.sendMinIntimacy = v.sendMinIntimacy
      condition.sendMinLevel = v.sendMinLevel
      condition.sendNumLimit = v.sendNumLimit
      logic_give_item.giveCondition[v.ItemType] = condition
    end
  end
  return logic_give_item.giveCondition
end
function logic_give_item.GetGiveConditionByType(giveType)
  local conditionMap = logic_give_item.GetGiveCondition()
  if conditionMap and conditionMap[giveType] then
    return conditionMap[giveType]
  end
  return conditionMap[logic_give_item.EnumGiveType.shop]
end
function logic_give_item.ResetData()
  logic_give_item.giveCondition = nil
end
return logic_give_item