local StoreUtils = require("client.slua.logic.store.utils.store_utils_config")
function StoreUtils.GetExchangeMoneyInfo(data)
  if data == nil then
    return nil
  end
  local silver = StoreConst.label_price_type_chip
  for k, v in pairs(data) do
    if v[6] == silver then
      return {
        type = v[6],
        num = v[1],
        discount = v[2] or 0
      }
    end
  end
  for k, v in pairs(data) do
    if v[6] ~= silver then
      return {
        type = v[6],
        num = v[1],
        discount = v[2] or 0
      }
    end
  end
  return nil
end
function StoreUtils.ShowCrateCreditExchangeUI()
  log(bWriteLog and "StoreExchangeUtils.ShowCrateCreditExchangeUI")
  UIManager.ShowUI(UIManager.UI_Config.crate_credit_ui)
end