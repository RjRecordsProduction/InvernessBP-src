local Logic_ColorShapeUtils = {_nLastTriggerUnlockItemId = nil}
local _nColorShapeUnlockItemId = 1627001
function Logic_ColorShapeUtils.GetColorShapeUnlockItemId()
  return _nColorShapeUnlockItemId
end
function Logic_ColorShapeUtils.GetLastTriggerUnlockItemId()
  return Logic_ColorShapeUtils._nLastTriggerUnlockItemId
end
function Logic_ColorShapeUtils.GetColorShapeItemShowIcon(nItemID)
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local nShowItemId = LogicMultiItemModule:GetMultiItemGroupCurSelectItemId(nItemID)
  return Logic_ColorShapeUtils.GetColorShapeItemShowIconByItemId(nShowItemId)
end
function Logic_ColorShapeUtils.GetColorShapeItemShowIconByItemId(nItemId)
  local uObj_multiItemCfg = CDataTable.GetTableData("MultiLevelItemShowIcon", nItemId)
  if not uObj_multiItemCfg then
    return
  end
  return uObj_multiItemCfg.ShowIconPath
end
function Logic_ColorShapeUtils.ShowColorShapeUnlockTip(nItemId)
  local Logic_BaseComponent_BtnUtils = require("client.logic.BaseComponent.Logic_BaseComponent_BtnUtils")
  local tConfirmBtnCfg = Logic_BaseComponent_BtnUtils.GetTextButtonShowCfg(LocUtil.GetLocalizeResStr(6752), true, true)
  local tAllBtnCfg = {tConfirmBtnCfg}
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local bIsHideGoBtn = LogicMultiItemModule:GetIsWardrobeMultiShapeTabUnlock()
  if not bIsHideGoBtn then
    local tGoBtnCfg = Logic_BaseComponent_BtnUtils.GetTextButtonShowCfg(LocUtil.GetLocalizeResStr(12232), true, true)
    local tUIShowParams = tGoBtnCfg.tUIShowParams
    tUIShowParams.sBtnBgPath = Logic_BaseComponent_BtnUtils.Enum_BtnBg.Blue
    function tUIShowParams.fClickCallback()
      GlobalData.JumpUrl(string.format("game://?module=%s&itemId=%s", BP_ENUM_MODULE_WARDROBE, nItemId))
    end
    table.insert(tAllBtnCfg, 1, tGoBtnCfg)
  end
  local UI_Config = UIManager.UI_Config
  local sTitle = LocUtil.GetLocalizeResStr(876171)
  local tExtraData = {
    tContentUI = {
      tUIConfig = UI_Config.Common_Popup_Theme_Explain_Picture09_Item_UIBP,
      tUIShowParams = {nItemId}
    },
    tAllBtnUI = tAllBtnCfg,
    bMaskBtnCloseUI = true
  }
  UIManager.ShowUI(UI_Config.CommonPopup_RewardTipParent_UIBP, sTitle, tExtraData)
end
function Logic_ColorShapeUtils.CheckIsColorShapeItemId(nItemId)
  if not nItemId or nItemId == 0 then
    return false
  end
  local Logic_MultiShapeConst = require("client.slua.logic.wardrobe.Logic_MultiShapeConst")
  local Enum_MultiShapeModuleID = Logic_MultiShapeConst.Enum_MultiShapeModuleID
  local uObj_multiCfg = CDataTable.GetTableData("MultiLevelItem", nItemId)
  if uObj_multiCfg and uObj_multiCfg.ModuleID == Enum_MultiShapeModuleID.ColorShape then
    return true
  end
  return false
end
function Logic_ColorShapeUtils.CheckMultiColorShapeOwnedStatus(nItemId)
  if not Logic_ColorShapeUtils.CheckIsColorShapeItemId(nItemId) then
    return false
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local tMultiList = LogicMultiItemModule:GetMultiListByItemID(nItemId)
  if not tMultiList then
    return false
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(tMultiList) do
    local bIsOwned = wardrobe_data:CheckHavePermanentItemForCollect(v.ItemID)
    if bIsOwned then
      return true
    end
  end
  return false
end
function Logic_ColorShapeUtils.CheckIsUnlockedAllColorShape(nItemId)
  if not Logic_ColorShapeUtils.CheckIsColorShapeItemId(nItemId) then
    return true
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local tMultiList = LogicMultiItemModule:GetMultiListByItemID(nItemId)
  if not tMultiList then
    return true
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(tMultiList) do
    local bIsOwned = wardrobe_data:CheckHavePermanentItemForCollect(v.ItemID)
    if not bIsOwned then
      return false
    end
  end
  return true
end
function Logic_ColorShapeUtils.GetNotHaveColorShapeItemId(nItemId)
  if not Logic_ColorShapeUtils.CheckIsColorShapeItemId(nItemId) then
    return
  end
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local tMultiList = LogicMultiItemModule:GetMultiListByItemID(nItemId)
  if not tMultiList then
    return
  end
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  for _, v in pairs(tMultiList) do
    local bIsOwned = wardrobe_data:CheckHavePermanentItemForCollect(v.ItemID)
    if not bIsOwned then
      return v.ItemID
    end
  end
  return nil
end
function Logic_ColorShapeUtils.TryUnlockColorShape(nItemId, bIsWardrobeShapeTabUnlock, nNeedCount)
  if Logic_ColorShapeUtils.CheckIsUnlockedAllColorShape(nItemId) then
    return
  end
  Logic_ColorShapeUtils._nLastTriggerUnlockItemId = nItemId
  nNeedCount = nNeedCount or 1
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  LogicMultiItemModule:SetIsWardrobeMultiShapeTabUnlock(bIsWardrobeShapeTabUnlock)
  local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
  local nOwnCount = wardrobe_data:GetHallDepotItemCountByResID(_nColorShapeUnlockItemId)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  local sTitle = LocUtil.GetLocalizeResStr(18130020)
  local tCommonMsgShowCfg = {
    showUIKey = "com_msg_small_box_slua",
    sBtnTopTip = LocUtil.LocalizeResFormat(18130023, nOwnCount)
  }
  if nNeedCount <= nOwnCount then
    local sContent = LocUtil.LocalizeResFormat(18130021, nNeedCount)
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sContent, function()
      Logic_ColorShapeUtils.SendUnlockColorShapeByItemId(nItemId)
    end, nil, nil, nil, tCommonMsgShowCfg)
  else
    local sContent = LocUtil.LocalizeResFormat(18130022, nNeedCount)
    local sGetBtnStr = LocUtil.GetLocalizeResStr(48324)
    CommonMsgBoxMgr.Show(CommonMsgBoxMgr.SHOW_TYPE_TWO, sTitle, sContent, function()
      local Logic_BonusPass = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.Logic_BonusPass)
      if Logic_BonusPass:IsInActivityTimes() then
        local bIsCanReceive = Logic_BonusPass:GetIsCanReceiveAwardByItemId(_nColorShapeUnlockItemId)
        if bIsCanReceive then
          local sJumpUrl = string.format("game://?module=1002502&Tab1=1&itemId=%s&panelType=2", _nColorShapeUnlockItemId)
          GlobalData.JumpUrl(sJumpUrl)
          return
        end
      end
      local sJumpUrl = string.format("game://?module=1002502&Tab1=2&itemId=%s", _nColorShapeUnlockItemId)
      GlobalData.JumpUrl(sJumpUrl)
    end, nil, sGetBtnStr, nil, tCommonMsgShowCfg)
  end
end
function Logic_ColorShapeUtils.TriggerUnlockOperating()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local tAllShapeData = LogicMultiItemModule:GetAllUnlockableData()
  if #tAllShapeData == 0 then
    return
  elseif #tAllShapeData == 1 then
    Logic_ColorShapeUtils.SendUnlockColorShapeByItemId(tAllShapeData[1])
  else
    UIManager.ShowUI(UIManager.UI_Config.UnknowPass_BP_ColorSuitUnlock_Popup_UIBP, tAllShapeData)
  end
end
function Logic_ColorShapeUtils.SendUnlockColorShapeByItemId(nItemId)
  local WardRobeHandler = require("client.network.Protocol.WardRobeHandler")
  WardRobeHandler.send_unlock_multi_color_req(nItemId, _nColorShapeUnlockItemId)
end
function Logic_ColorShapeUtils.CheckIsExistCanUnlockColorShape()
  local LogicMultiItemModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LogicMultiItemModule)
  local tAllUnlockableData = LogicMultiItemModule:GetAllUnlockableData()
  if not tAllUnlockableData or not next(tAllUnlockableData) then
    return false
  end
  return true
end
return Logic_ColorShapeUtils