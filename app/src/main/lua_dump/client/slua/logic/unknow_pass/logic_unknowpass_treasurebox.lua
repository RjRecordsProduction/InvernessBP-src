local UnknowPassTreasureBoxSystem = {CostItemFromExchange = 0}
function UnknowPassTreasureBoxSystem.CloseTreasureBoxUI()
  UnknowPassTreasureBoxSystem.CostItemFromExchange = 0
  local UnknowPassTunnelSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknowpass_tunnel")
  if UnknowPassTunnelSystem.isShowRP then
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_TAB)
  end
  log(bWriteLog and "UnknowPassTreasureBoxSystem.CloseTreasureBoxUI" .. tostring(UIManager.GetUI(UIManager.UI_Config.unknowpass_award_buyscore)))
  local awardBuyScoreUI = UIManager.GetUI(UIManager.UI_Config.unknowpass_award_buyscore)
  if nil ~= awardBuyScoreUI then
    awardBuyScoreUI:SelfHitTestInvisible()
  elseif UIManager.GetUI(UIManager.UI_Config.unknowpass_award) then
    local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
    local panelType = PassDataSystem.GetPanelType()
    local curType = PassDataSystem.GetCurRpPanelType()
    if curType ~= panelType.BranchRp then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_AWARDUI, true)
    end
  elseif UIManager.GetUI(UIManager.UI_Config.unknowpass_exchange) then
    log(bWriteLog and "exchangeSyetem.SetExchangeOpenOrClose(true)")
    local exchangeSyetem = require("client.slua.logic.unknow_pass.logic_unknowpass_exchange")
    exchangeSyetem.SetExchangeOpenOrClose(true)
    EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_CLOSE_TREASUREBOX)
  end
  UnknowPassTreasureBoxSystem.TreasureBoxUIShowing = false
end
function UnknowPassTreasureBoxSystem.SetTreasureBoxUIVisible(value)
  if value then
    local awardBuyScoreUI = UIManager.GetUI(UIManager.UI_Config.unknowpass_award_buyscore)
    if nil ~= awardBuyScoreUI then
      awardBuyScoreUI:SelfHitTestInvisible()
    elseif UIManager.GetUI(UIManager.UI_Config.unknowpass_award) then
      local PassDataSystem = require("client.slua.logic.unknow_pass.NewRPPreview.logic_unknownpass_data")
      local panelType = PassDataSystem.GetPanelType()
      local curType = PassDataSystem.GetCurRpPanelType()
      if curType ~= panelType.BranchRp then
        EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_AWARDUI, true)
      end
    end
  else
    local awardBuyScoreUI = UIManager.GetUI(UIManager.UI_Config.unknowpass_award_buyscore)
    if nil ~= awardBuyScoreUI then
      awardBuyScoreUI:Collapsed(false)
    elseif UIManager.GetUI(UIManager.UI_Config.unknowpass_award) then
      EventSystem:postEvent(EVENTTYPE_UNKNOW_PASS, EVENTID_UNKNOW_PASS_SHOW_AWARDUI, false)
    end
  end
end
function UnknowPassTreasureBoxSystem.StrSplit(str, reps)
  local resultStrList = {}
  string.gsub(str, "[^" .. reps .. "]+", function(w)
    table.insert(resultStrList, w)
  end)
  return resultStrList
end
function UnknowPassTreasureBoxSystem.GetItemCount(itemId)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local arrayHallDepotItemInfo = wardrobe_data:GetArrayHallDepotItemInfo()
  if arrayHallDepotItemInfo == nil then
    return 0
  end
  local count = 0
  for _, v in pairs(arrayHallDepotItemInfo) do
    if v.resID == itemId then
      count = count + v.count
    end
  end
  return count
end
return UnknowPassTreasureBoxSystem