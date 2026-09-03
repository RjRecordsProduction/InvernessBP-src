local logic_tarotcard_exchange_sendgift = {rightTipData = nil}
function logic_tarotcard_exchange_sendgift:DefineAndResetData()
  self.rawItemInfo = {}
end
function logic_tarotcard_exchange_sendgift:RegistEvents()
  self:AddCommonEvent(EVENTTYPE_STORE_DATA, EVENTID_STORE_DATA, self.RefreshStoreInfo, self)
end
function logic_tarotcard_exchange_sendgift:OnLogOut()
  self:DefineAndResetData()
end
function logic_tarotcard_exchange_sendgift:RefreshStoreInfo(_, _, tData)
  if tData.tab_id ~= 55 then
    return
  end
  log(bWriteLog and "[SY]logic_tarotcard_exchange_sendgift:RefreshStoreInfo.")
  local key = StoreConst.label_market_index_market_list
  local dataMap = tData and tData.data and tData.data[key] or {}
  self.rawItemInfo = {}
  for i, v in pairs(dataMap) do
    local itemId = v and v[StoreConst.label_item_index_id] or 0
    self.rawItemInfo[itemId] = v
  end
  EventSystem:postEvent(EVENTTYPE_ACTIVITY_TAROTCARD, EVENTID_ACTIVITY_SENDGIFT_REFRESH)
end
function logic_tarotcard_exchange_sendgift:GetSendGiftData()
  return self.rawItemInfo
end
function logic_tarotcard_exchange_sendgift:CanPop(itemId)
  self:_TryInitPathData()
  itemId = itemId or 0
  local needPop = false
  if logic_tarotcard_exchange_sendgift.rightTipData and logic_tarotcard_exchange_sendgift.rightTipData[itemId] then
    needPop = true
  end
  return needPop
end
function logic_tarotcard_exchange_sendgift:GetRightTipsIconData(itemId)
  self:_TryInitPathData()
  return logic_tarotcard_exchange_sendgift.rightTipData[itemId]
end
function logic_tarotcard_exchange_sendgift:_TryInitPathData()
  if logic_tarotcard_exchange_sendgift.rightTipData then
    return
  end
  logic_tarotcard_exchange_sendgift.rightTipData = {}
  local string_util = require("common.string_util")
  local AllCfg = CDataTable.GetTable("TarotGiftRightTipCfg")
  for i, cfg in pairs(AllCfg) do
    local itemList = string_util.Split(cfg.ItemString, ";")
    local data = {
      ImagePath = cfg.ImagePath,
      BgPath = cfg.BgPath,
      tipsID = cfg.tipsID ~= 0 and cfg.tipsID or 9976
    }
    for _, itemId in pairs(itemList) do
      logic_tarotcard_exchange_sendgift.rightTipData[tonumber(itemId)] = data
    end
  end
end
local class = require("class")
local CModuleBase = require("client.module_framework.ModuleBase")
local CTemplate = class(CModuleBase, nil, logic_tarotcard_exchange_sendgift)
return CTemplate