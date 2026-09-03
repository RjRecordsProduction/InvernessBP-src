local Newbie_Reward_Eight_Days_UIBP = {}
function Newbie_Reward_Eight_Days_UIBP:ctor()
  self._downloadPollTimers = {}
end
function Newbie_Reward_Eight_Days_UIBP:OnClose()
  for k, v in pairs(self._downloadPollTimers) do
    if v then
      self:RemoveTimer(v)
    end
  end
  self._downloadPollTimers = {}
end
function Newbie_Reward_Eight_Days_UIBP:RegistEvents()
  Newbie_Reward_Eight_Days_UIBP.__super.RegistEvents(self)
  self:AddCommonEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_DAILY_LOGIN_DAY, self.UpdateUI, self)
  for index = 1, 8 do
    local btn = "Activity_Novice_DailyItem" .. index
    self:AddOnClickedEventByControl(self.UIRoot[btn].Button_Click, self.ClickItem, self, index)
  end
  for index = 1, 7 do
    local btn = "Activity_Novice_DailyItem" .. index
    self:AddOnClickedEventByControl(self.UIRoot[btn].Activity_Novice_BigItem.Button_Click, self.DailyItemClicked, self, index, 0)
  end
  for i = 1, 3 do
    local btn = "Item0" .. i
    self:AddOnClickedEventByControl(self.UIRoot.Activity_Novice_DailyItem8[btn].Button_Click, self.DailyItemClicked, self, 8, i)
  end
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_CLOSE, self.ResetShow, self)
  self:AddCommonEvent(EVENTTYPE_WARDROBE, EVENTID_ITEM_PREVIEW_RESET_OPEN, self.ResetHide, self)
end
function Newbie_Reward_Eight_Days_UIBP:InitShow()
  for index = 1, 8 do
    local ItemBP = self.UIRoot["Activity_Novice_DailyItem" .. tostring(index)]
    ItemBP.TextBlock_ItemName:SetText("")
    local UIUtil = require("client.common.ui_util")
    ItemBP.FX_BGLight:SetWidgetVisibility(UIUtil.BoolToVisible(false))
    ItemBP.WidgetSwitcher_1:SetWidgetVisibility(UIUtil.BoolToVisible(false))
    ItemBP.Image_ItemIcon:SetWidgetVisibility(UIUtil.BoolToVisible(false))
  end
end
function Newbie_Reward_Eight_Days_UIBP:ClickItem(index)
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  if loginData and not loginData[index] then
    if index <= 7 then
      log(bWriteLog and "on_send_newbie_login_reward_req:" .. tostring(index))
      logic_newbie_new_abtest:on_send_newbie_login_reward_req(index, 1)
    else
      UIManager.ShowUI(UIManager.UI_Config.Newbie_Reward_Eight_Days_OptionsReward_UIBP)
    end
  end
end
function Newbie_Reward_Eight_Days_UIBP:DailyItemClicked(index, child)
  log(bWriteLog and "Newbie_Reward_Eight_Days_UIBP:DailyItemPressed:" .. tostring(index))
  local logic_newbie_reward_eight_day = require("client.slua.logic.activity.newbie.logic_newbie_reward_eight_day")
  local config = logic_newbie_reward_eight_day.GetNewbieLoginConfig()
  if config and config[index] then
    local control
    local reward = {}
    if child == 0 then
      local cfg = config[index]
      local path = "Activity_Novice_DailyItem" .. tostring(index)
      control = self.UIRoot[path].Activity_Novice_BigItem.Button_Click
      reward.itemId = cfg.Reward1
      reward.valid_hours = cfg.Reward1Time
    else
      local cfg = config[index]
      control = self.UIRoot.Activity_Novice_DailyItem8["Item0" .. child].Button_Click
      reward.itemId = cfg.Reward1
      reward.valid_hours = cfg.Reward1Time
      if child == 2 then
        reward.itemId = cfg.Reward2
        reward.valid_hours = cfg.Reward2Time
      elseif child == 3 then
        reward.itemId = cfg.Reward3
        reward.valid_hours = cfg.Reward3Time
      end
    end
    local UIUtil = require("client.common.ui_util")
    UIUtil.OnClickItemShowDetail(control, reward.itemId, reward.valid_hours)
  end
end
function Newbie_Reward_Eight_Days_UIBP:DailyItemReleased(index)
  log(bWriteLog and "Newbie_Reward_Eight_Days_UIBP:DailyItemReleased:" .. tostring(index))
  local UIUtil = require("client.common.ui_util")
  UIUtil.CloseItemTips()
end
function Newbie_Reward_Eight_Days_UIBP:OnPostInitialize()
  Newbie_Reward_Eight_Days_UIBP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Newbie_Reward_Eight_Days_UIBP:UpdateItem(ItemBP, cfg, status, Image_get)
  if not slua.isValid(ItemBP) or not cfg then
    return
  end
  if self._downloadPollTimers[ItemBP] then
    self:RemoveTimer(self._downloadPollTimers[ItemBP])
    self._downloadPollTimers[ItemBP] = nil
  end
  local id = cfg.itemId
  local ItemInfo = CDataTable.GetTableData("Item", id)
  if ItemInfo == nil then
    log_error("itemInfo == nil id = " .. id)
    return
  end
  local UIUtil = require("client.common.ui_util")
  if ItemBP.ScaleBox_1 then
    ItemBP.ScaleBox_1:SetWidgetVisibility(UIUtil.BoolToVisible(true))
  end
  if ItemBP.SizeBox_1 then
    ItemBP.SizeBox_1:SetWidgetVisibility(UIUtil.BoolToVisible(true))
  end
  ItemBP.TextBlock_ItemName:SetText(ItemInfo.ItemName)
  self:SetTexture(ItemBP.Image_2, UIUtil.GetQualityPath(ItemInfo.ItemQuality))
  ItemBP.FX_BGLight:SetWidgetVisibility(UIUtil.BoolToVisible(status == 1))
  ItemBP.Image_6:SetWidgetVisibility(UIUtil.BoolToVisible(false))
  if Image_get then
    Image_get:SetWidgetVisibility(UIUtil.BoolToVisible(status == 2))
  end
  local ModelDisplayTypeHelper = require("client.logic.avatar.ModelDisplayTypeHelper")
  if ModelDisplayTypeHelper.IsWeapon(ItemInfo.ItemType) then
    ItemBP.WidgetSwitcher_Icon:SetActiveWidgetIndex(0)
    local bigIcon, bHasAddKnownMissing = UIUtil.GetItemBigIcon(id, ItemBP.Image_ItemWeapon)
    self:SetTexture(ItemBP.Image_ItemWeapon, bigIcon, {
      needLocalize = true,
      bHasAddKnownMissing = bHasAddKnownMissing,
      bMatchSize = true
    })
    local bigIconMask, bHasAddKnownMissingMask = UIUtil.GetItemBigIcon(id, ItemBP.Image_ItemWeapon_Mask)
    self:SetTexture(ItemBP.Image_ItemWeapon_Mask, bigIconMask, {
      needLocalize = true,
      bHasAddKnownMissing = bHasAddKnownMissingMask,
      bMatchSize = true
    })
    local itemCfg = UIUtil.GetItemCfg(id)
    UIUtil.CheckAndUpdateIconScale(id, bigIcon, ItemBP.Image_ItemWeapon, 1)
    UIUtil.CheckAndUpdateIconScale(id, bigIconMask, ItemBP.Image_ItemWeapon_Mask, 1)
    if itemCfg and itemCfg.ItemBigIcon ~= bigIcon then
      self._downloadPollTimers[ItemBP] = self:AddTimerLoop(0.5, function()
        if UIUtil.HasIconDownloaded(itemCfg.ItemBigIcon) then
          self:SetTexture(ItemBP.Image_ItemWeapon, itemCfg.ItemBigIcon, {isForceUpdate = true})
          self:SetTexture(ItemBP.Image_ItemWeapon_Mask, itemCfg.ItemBigIcon, {isForceUpdate = true})
          ItemBP.Image_ItemWeapon:SetRenderScale(FVector2D(1.0, 1.0))
          ItemBP.Image_ItemWeapon:SetRenderAngle(0)
          ItemBP.Image_ItemWeapon_Mask:SetRenderScale(FVector2D(1.0, 1.0))
          ItemBP.Image_ItemWeapon_Mask:SetRenderAngle(0)
          if self._downloadPollTimers[ItemBP] then
            self:RemoveTimer(self._downloadPollTimers[ItemBP])
            self._downloadPollTimers[ItemBP] = nil
          end
        end
      end, TIMER_INFINITE, 0.5)
    end
  else
    ItemBP.WidgetSwitcher_Icon:SetActiveWidgetIndex(1)
    local bigIcon, bHasAddKnownMissing = UIUtil.GetItemBigIcon(id, ItemBP.Image_Item)
    self:SetTexture(ItemBP.Image_Item, bigIcon, {isForceUpdate = true, bHasAddKnownMissing = bHasAddKnownMissing})
    local bigIconMask, bHasAddKnownMissingMask = UIUtil.GetItemBigIcon(id, ItemBP.Image_Item_Mask)
    self:SetTexture(ItemBP.Image_Item_Mask, bigIconMask, {isForceUpdate = true, bHasAddKnownMissing = bHasAddKnownMissingMask})
    if ItemInfo.ItemSubType == ENUM_ITEM_SUBTYPE.Voice_Pack then
      ItemBP.Image_Item:SetRenderScale(FVector2D(0.55, 0.55))
      ItemBP.Image_Item_Mask:SetRenderScale(FVector2D(0.55, 0.55))
    else
      ItemBP.Image_Item:SetRenderScale(FVector2D(1, 1))
      ItemBP.Image_Item_Mask:SetRenderScale(FVector2D(1, 1))
    end
  end
  ItemBP.TimePanel:SetWidgetVisibility(UIUtil.BoolToVisible(cfg.valid_hours > 0))
  ItemBP.TimeText:SetWidgetVisibility(UIUtil.BoolToVisible(cfg.valid_hours > 0))
  local text = LocUtil.LocalizeResFormat(501060, math.floor(cfg.valid_hours / 24))
  ItemBP.TimeText:SetText(text)
  if 1 >= cfg.count then
    self:SetWidgetVisible(ItemBP.TextBlock_Number, false)
  else
    self:SetWidgetVisible(ItemBP.TextBlock_Number, true)
    ItemBP.TextBlock_Number:SetText(tostring(cfg.count))
  end
end
function Newbie_Reward_Eight_Days_UIBP:UpdateUI()
  local logic_newbie_reward_eight_day = require("client.slua.logic.activity.newbie.logic_newbie_reward_eight_day")
  local config = logic_newbie_reward_eight_day.GetNewbieLoginConfig()
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  local loginData = logic_newbie_new_abtest:GetNewbieNewDataLoginData()
  local loginDay = logic_newbie_new_abtest:GetNewbieNewDataLoginDay()
  if not config or not next(config) then
    return
  end
  local UIUtil = require("client.common.ui_util")
  for index = 1, 7 do
    local ItemBP = self.UIRoot["Activity_Novice_DailyItem" .. tostring(index)]
    local status = 0
    if index <= loginDay and not loginData[index] then
      status = 1
    elseif loginData[index] then
      status = 2
    end
    ItemBP.WidgetSwitcher_Btn:SetActiveWidgetIndex(status)
    ItemBP.TextBlock_Day:SetText(tostring(LocUtil.LocalizeResFormat(4008, index)))
    ItemBP.Image_ReceivedMask:SetWidgetVisibility(UIUtil.BoolToVisible(status == 2))
    ItemBP.Button_Click:SetWidgetVisibility(UIUtil.BoolToVisible(status == 1, true, true))
    local itemCfg
    if config[index] then
      itemCfg = {
        itemId = config[index].Reward1,
        valid_hours = config[index].Reward1Time,
        count = config[index].Reward1Number
      }
    end
    if not itemCfg then
      log_error(bWriteLog and "Newbie_Reward_Eight_Days_UIBP:UpdateUI itemCfg is nil. index: " .. tostring(index))
    end
    self:UpdateItem(ItemBP.Activity_Novice_BigItem, itemCfg, status, ItemBP.Image_get)
  end
  local ItemBP8 = self.UIRoot.Activity_Novice_DailyItem8
  local status8 = 0
  if 8 <= loginDay and not loginData[8] then
    status8 = 1
  elseif loginData[8] then
    status8 = 2
  end
  ItemBP8.Image_ReceivedMask:SetWidgetVisibility(UIUtil.BoolToVisible(status8 == 2))
  ItemBP8.WidgetSwitcher_Btn:SetActiveWidgetIndex(status8)
  ItemBP8.TextBlock_Day:SetText(tostring(LocUtil.LocalizeResFormat(4008, 8)))
  ItemBP8.Button_Click:SetWidgetVisibility(UIUtil.BoolToVisible(status8 == 1, true, true))
  for i = 1, 3 do
    local itemCfg
    if config[8] then
      itemCfg = {
        itemId = config[8]["Reward" .. i],
        valid_hours = config[8]["Reward" .. i .. "Time"],
        count = config[8]["Reward" .. i .. "Number"]
      }
    end
    local image_get = ItemBP8["Image_get0" .. i]
    if image_get then
      image_get:SetWidgetVisibility(UIUtil.BoolToVisible(false))
    end
    if itemCfg ~= nil then
      self:UpdateItem(ItemBP8["Item0" .. i], itemCfg, status8, image_get)
    end
  end
  self:SetCountDown()
  self:UpdateSelect()
  local TimeUtil = require("client.common.time_util")
  self.UIRoot.TextBlock_RefreshTime:SetText(LocUtil.LocalizeResFormat(4586, TimeUtil.FormatTime_HMS(0, true)))
end
function Newbie_Reward_Eight_Days_UIBP:UpdateSelect()
end
function Newbie_Reward_Eight_Days_UIBP:SetCountDown()
  local logic_newbie_reward_eight_day = require("client.slua.logic.activity.newbie.logic_newbie_reward_eight_day")
  local deltaTime = logic_newbie_reward_eight_day.GetNewbieEndTime()
  local TimeUtil = require("client.common.time_util")
  local timeText = TimeUtil.FormatCountDownTime_D_or_HMS(deltaTime, 1)
  self.UIRoot.TextBlock_Time:SetText(LocUtil.LocalizeResFormat(7176, tostring(timeText)))
  local updateFunc = function(nTime)
    if self.UIRoot and slua.isValid(self.UIRoot) then
      local sTempTimeStr = TimeUtil.FormatCountDownTime_D_or_HMS(nTime, 1)
      self.UIRoot.TextBlock_Time:SetText(LocUtil.LocalizeResFormat(7176, tostring(sTempTimeStr)))
    end
  end
  self:AddClock(deltaTime, updateFunc, nil)
end
function Newbie_Reward_Eight_Days_UIBP:ResetHide()
  self:Collapsed()
end
function Newbie_Reward_Eight_Days_UIBP:ResetShow()
  self:SelfHitTestInvisible()
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CNewbie_Reward_Eight_Days_UIBP = class(ui_base, nil, Newbie_Reward_Eight_Days_UIBP)
return CNewbie_Reward_Eight_Days_UIBP