local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.CanSendGift()
  local logic_give_item = require("client.slua.logic.give_item.logic_give_item")
  return logic_give_item.IsCanShowEntrance(logic_give_item.EnumGiveType.shop)
end