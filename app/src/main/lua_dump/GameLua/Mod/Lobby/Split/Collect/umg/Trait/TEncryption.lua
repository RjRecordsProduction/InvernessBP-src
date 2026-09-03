local TEncryption = {}
local Trait = require("common.trait")
local TTEncryption = Trait(Trait.TraitPrototype, nil, TEncryption)
function TEncryption:ShowEncryptionTime(root, itemList)
  self:RemoveEncryptionTimer()
  if not slua.isValid(root) then
    return
  end
  itemList = itemList or {}
  local TimeUtil = require("client.common.time_util")
  local encryptionTime
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  for i, itemID in pairs(itemList) do
    local config = collect_encryption_module:GetEncryptionConfig(itemID)
    if config and config.ShowTime ~= "" then
      local show = TimeUtil.TimeStringToUnixstamp(config.ShowTime)
      local current = TimeUtil.GetServerTimeInSec()
      local timeLeft = show - current
      if 0 < timeLeft then
        encryptionTime = config.ShowTime
      end
    end
  end
  if encryptionTime and not self.encryptionTimer then
    self.encryptionTimer = self:AddTimerLoop(0, function()
      local current = TimeUtil.GetServerTimeInSec()
      local show = TimeUtil.TimeStringToUnixstamp(encryptionTime)
      local timeLeft = show - current
      root.TextBlock_TimeRemianing:SetText(TimeUtil.FormatCountDownTime_D_or_HM(timeLeft, 1))
      if timeLeft <= 0 then
        self:RemoveEncryptionTimer()
        if self.OnRefresh then
          self:OnRefresh()
        end
      end
    end, TIMER_INFINITE, 1)
  end
  self:SetWidgetVisible(root.CanvasPanel_TimeRemaining, encryptionTime)
end
function TEncryption:RemoveEncryptionTimer()
  if self.encryptionTimer then
    self:RemoveTimer(self.encryptionTimer)
  end
  self.encryptionTimer = nil
end
function TEncryption:GetIconForEncryptedItems(imagerWidget, itemID)
  if not imagerWidget then
    log(bWriteLog and string.format("collect_encryption_module:GetIconForEncryptedItems widget is nil."))
    return false
  end
  local encryption = false
  local UIUtil = require("client.common.ui_util")
  local iconPath, bHasAddKnownMissing
  local collect_encryption_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_encryption_module)
  if collect_encryption_module:IsEncryption(itemID) then
    log(bWriteLog and string.format("collect_encryption_module:GetIconForEncryptedItems this item is encryption. itemID = %s", itemID))
    iconPath, bHasAddKnownMissing = UIUtil.GetDefaultIcon(itemID)
    encryption = true
  else
    local itemData = CDataTable.GetTableData("Item", itemID)
    local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
    if itemData and ModelDisplayTypeHelper.IsMileStone(itemData.ItemSubType) then
      local LobbyEmoteManager = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.LobbyEmoteManager)
      local icon = LobbyEmoteManager:GetMilestoneUPIcon(itemID)
      if icon and icon ~= "" then
        iconPath = icon
      end
    end
    if not iconPath then
      iconPath, bHasAddKnownMissing = UIUtil.GetItemSmallIcon(itemID, imagerWidget)
    end
  end
  local params = {sync = true, bHasAddKnownMissing = bHasAddKnownMissing}
  self:SetTexture(imagerWidget, iconPath, params)
  return encryption
end
function TEncryption:ShowTipsOrEncryption(itemWidget, itemId)
  local isEncryption = self:GetIconForEncryptedItems(itemWidget.Image_Icon, itemId)
  itemWidget.CanvasPanel_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if not isEncryption then
    local PlayerPrefsSystem = require("client.logic.LogicPlayerPrefs.playerprefs")
    local tipsMark = PlayerPrefsSystem.LoadFileToTable_N(PlayerPrefsSystem.ePlayerPrefsType.eCollectNewItemTips) or {}
    if tipsMark[tonumber(itemId)] then
      return
    end
    local collect_module = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.collect_module)
    local config = collect_module:GetSplitTableData("CollectEncryptionConfig", collect_module.E_ColCfgMode.JK, itemId)
    if config and config.ShowTips == 1 then
      local UIUtil = require("client.common.ui_util")
      local itemData = CDataTable.GetTableData("Item", itemId)
      if not itemData then
        log(bWriteLog and string.format("TEncryption:ShowTipsOrEncryption itemId = %s has no config.", itemId))
        return
      end
      itemWidget.CanvasPanel_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      itemWidget.TextBlock_IntergralSourceTips:SetText(itemData.ItemName)
      tipsMark[tonumber(itemId)] = 1
      PlayerPrefsSystem.SaveTableToFile_N(tipsMark, PlayerPrefsSystem.ePlayerPrefsType.eCollectNewItemTips)
      self:AddTimer(5, function()
        if itemWidget then
          itemWidget.CanvasPanel_Tips:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
        end
      end)
    end
  end
end
return TTEncryption