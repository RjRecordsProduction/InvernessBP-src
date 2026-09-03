local Lobby_Mid_Banner_UIBP = {}
function Lobby_Mid_Banner_UIBP:ctor()
  self.bIsSwitching = false
  self.storageEntranceUIList = {}
end
function Lobby_Mid_Banner_UIBP:OnInitialize()
  Lobby_Mid_Banner_UIBP.__super.OnInitialize(self)
  local logicLevelSprint = require("client.slua.logic.activity.newbie.logic_newbie_level_sprint")
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  local LogicPufferBundle = require("client.slua.logic.download.bundle.logic_puffer_bundle")
  if LogicPufferBundle.IsFitLobbyResDownloaded() then
    self.ShopUI = self:CreateChildWindow(self.UIRoot.CanvasPanel_6, UIManager.UI_Config.Lobby_Mid_Shop_UIBP, 1)
  end
  self:RegistReddotWidget(self.UIRoot.Image_RedPoint_Old)
  if logicLevelSprint.IsOpen() and logic_newbie_assist.CheckIsNewbieBanner() then
    log(bWriteLog and "Lobby_Mid_Banner_UIBP  use newbie banner")
    self.BannerUI1 = self:CreateChildWindow(self.UIRoot.CanvasPanel_1, UIManager.UI_Config.Activity_Newbie_Banner, 1)
    self.bNewbieBanner = true
    self.UIRoot.Button_MoreAct:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  else
    log(bWriteLog and "Lobby_Mid_Banner_UIBP use normal banner")
    self.BannerUI1 = self:CreateChildWindow(self.UIRoot.CanvasPanel_1, UIManager.UI_Config.Lobby_Mid_Binner_More_UIBP, 1)
    self.bNewbieBanner = false
    self:CheckShowMoreAct()
  end
  self.UIRoot.ActCount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.ScrollIndex = 0
  if self.nextTimer then
    self:RemoveTimer(self.nextTimer)
    self.nextTimer = nil
  end
  self:MoveToNext()
  self:InitStorageEntrance()
end
function Lobby_Mid_Banner_UIBP:RegistEvents()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:RegistEvents")
  Lobby_Mid_Banner_UIBP.__super.RegistEvents(self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_MoreAct, self.OnClickMoreActivity, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_BANNER_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_BANNER_DATA_CHANGE, self.UpdateUI, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_ACTIVITY_DATA, self.UpdateNewbieBanner, self)
  self:AddCommonEvent(EVENTTYPE_DATA_MGR, EVENTID_DATAMGR_ROLE_LEVEL_CHANGE, self.UpdateNewbieBanner, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_AWARD, self.UpdateNewbieBanner, self)
  self:AddCommonEvent(EVENTTYPE_LEVEL_UNLOCK, EVENTID_LEVEL_UNLOCK_GET_DATA, self.UpdateNewbieBanner, self)
  self:AddCommonEvent(EVENTTYPE_NEWBIE_ACTIVITY, EVENTID_NEWBIE_BANNER_CHANGED, self.UpdateNewbieBanner, self)
  self:AddCommonEvent(EVENTTYPE_NEW_NEWBIE, EVENTID_NEW_NEWBIE_UPGRADE_DATA, self.UpdateNewbieBanner, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_HIDE_LOBBY, self.OnLobbyHide, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SHOW_LOBBY, self.OnLobbyShow, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_START, self.OnSwitchToPageStart, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY, EVENTID_SWITCHTO_PAGE_END, self.OnSwitchToPageEnd, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY_BLACK_FRIDAY, EVENTID_ACTIVITY_BLACK_FRIDAY_LOBBY_ENTRANCE_INFO_UPDATED, self.OnBlackFridayEntranceUpdated, self)
  self:AddCommonEvent(EVENTTYPE_LOBBY_BUBBLE, EVENTID_LOBBY_BUBBLE_MID_BOTTOM_UPDATE, self.OnBottomBubbleUpdated, self)
  self:AddCommonEvent(EVENTTYPE_ACTIVITY, EVENTID_ACTIVITY_INFO, self.OnBottomBubbleUpdated, self)
end
function Lobby_Mid_Banner_UIBP:OnPostInitialize()
  Lobby_Mid_Banner_UIBP.__super.OnPostInitialize(self)
  local logic_activity_recharge_mgr = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_activity_recharge_mgr)
  logic_activity_recharge_mgr:send_get_refund_black_act_list_req()
  self:UpdateUI()
  if LobbySystem.IsInNarutoVersionTime() then
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(1)
    self:SetTexture(self.UIRoot.Image_1, "/Game/UMG/Texture_200/Atlas/Lobby_Activity/FlameShadow/Frames/Lobby_Bg_Entrance_450Theme_png.Lobby_Bg_Entrance_450Theme_png")
  else
    self.UIRoot.WidgetSwitcher_0:SetActiveWidgetIndex(0)
  end
end
function Lobby_Mid_Banner_UIBP:UpdateNewbieBanner()
  local bUseNewbieBannerFlag = false
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    local logic_newbie_reward_level_sprint = require("client.slua.logic.activity.newbie.logic_newbie_reward_level_sprint")
    bUseNewbieBannerFlag = logic_newbie_reward_level_sprint.HasNewbieBanner()
  else
    local logicLevelSprint = require("client.slua.logic.activity.newbie.logic_newbie_level_sprint")
    local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
    bUseNewbieBannerFlag = logicLevelSprint.IsOpen() and logic_newbie_assist.CheckIsNewbieBanner()
  end
  log(bWriteLog and "Lobby_Mid_Banner_UIBP  update newbie banner")
  if bUseNewbieBannerFlag then
    if not self.bNewbieBanner then
      log(bWriteLog and "Lobby_Mid_Banner_UIBP update newbie banner create newbie banner")
      if self.bNewbieBanner == false and self.BannerUI1 then
        UIManager.CloseUI(UIManager.UI_Config.Lobby_Mid_Binner_More_UIBP)
        self.BannerUI1 = nil
      end
      if self.nextTimer then
        self:RemoveTimer(self.nextTimer)
        self.nextTimer = nil
      end
      self.BannerUI1 = self:CreateChildWindow(self.UIRoot.CanvasPanel_1, UIManager.UI_Config.Activity_Newbie_Banner, 1)
      self.UIRoot.Button_MoreAct:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      self.bNewbieBanner = true
      self:UpdateUI()
      self:RefreshStorageEntrance()
    end
  elseif self.bNewbieBanner then
    log(bWriteLog and "Lobby_Mid_Banner_UIBP update newbie banner delete newbie banner")
    if self.BannerUI1 then
      UIManager.CloseUI(UIManager.UI_Config.Activity_Newbie_Banner)
      self.BannerUI1 = nil
    end
    self.BannerUI1 = self:CreateChildWindow(self.UIRoot.CanvasPanel_1, UIManager.UI_Config.Lobby_Mid_Binner_More_UIBP, 1)
    self:CheckShowMoreAct()
    self.bNewbieBanner = false
    self:UpdateUI()
  end
end
function Lobby_Mid_Banner_UIBP:CheckShowMoreAct()
  local isShow = LobbySystem.CheckOpen(BP_ENUM_LOBBY_MORE_BANNER_SWITCH)
  self:SetWidgetVisible(self.UIRoot.Button_MoreAct, isShow, true)
end
function Lobby_Mid_Banner_UIBP:UpdateUI()
  self:AddTimerOnce(2, function()
    local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
    local bannerDataList1 = logic_lobby_mid_banner.GetBannerByLine()
    local isNewbie = false
    local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
    local logicLevelSprint = require("client.slua.logic.activity.newbie.logic_newbie_level_sprint")
    if logicLevelSprint.IsOpen() and logic_newbie_assist.CheckIsNewbieBanner() then
      isNewbie = true
    end
    local mainUI = UIManager.GetUI(UIManager.UI_Config.Lobby_Main_UIBP)
    local ui1 = self.BannerUI1
    if mainUI then
      local ui3 = mainUI:GetChildUI(UIManager.UI_Config.Lobby_Mid_Activity_UIBP)
      if ui1 and ui3 then
        if not isNewbie and (bannerDataList1 == nil or #bannerDataList1 <= 0) then
          self:SetWidgetOffset(ui3.UIRoot.CanvasPanel_1, 10)
        else
          self:SetUIOffset(ui1, 0)
          self:SetWidgetOffset(ui3.UIRoot.CanvasPanel_1, 10)
        end
      end
    end
  end)
  self:RefreshMoreActCount()
  self:RefreshMoreActRedDot()
end
function Lobby_Mid_Banner_UIBP:RefreshMoreActCount()
  self.UIRoot.ActCount:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  local bannerDataList = logic_lobby_mid_banner.GetSidebarBannerList(true)
  local num = bannerDataList and #bannerDataList or 0
  if 0 < num then
    self.UIRoot.ActCount:SetText(tostring(num))
    self.UIRoot.ActCount:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
end
function Lobby_Mid_Banner_UIBP:RefreshMoreActRedDot()
  local logic_lobby_mid_banner = require("client.slua.logic.lobby.Mid.logic_lobby_mid_banner")
  local bannerDataList = logic_lobby_mid_banner.GetSidebarBannerList(true)
  local isShow = logic_lobby_mid_banner.CheckSidebarBannerNewRedDot(bannerDataList)
  self:ToggleReddotActivation(self.UIRoot.Image_RedPoint_Old, isShow)
end
function Lobby_Mid_Banner_UIBP:SetUIOffset(ui, offset)
  ui:SetOffsets(0, offset, 0, 0)
end
function Lobby_Mid_Banner_UIBP:SetWidgetOffset(widget, offset)
  local WidgetLayoutLibrary = import("WidgetLayoutLibrary")
  local slot = WidgetLayoutLibrary.SlotAsCanvasSlot(widget)
  if slot then
    slot:SetOffsets(FMargin(0, offset, 0, 0))
  end
end
function Lobby_Mid_Banner_UIBP:OnClickMoreActivity()
  if self.bIsSwitching then
    log(bWriteLog and string.format("Lobby_Mid_Banner_UIBP:OnClickMoreActivity is switching."))
    return
  end
  self:PlayAudio(sound_config.new_activityBtn)
  local UIUtil = require("client.common.ui_util")
  if UIUtil.CheckClickCooldownSilently(UIUtil.ClickFrequencyLimit.SidebarBanner) == false then
    return
  end
  self:ToggleReddotActivation(self.UIRoot.Image_RedPoint_Old, false)
  ClientSendTLogReport(TLogEventDefine.OnClickMoreBanner)
  UIManager.ShowUI(UIManager.UI_Config.new_banner_list_page)
end
function Lobby_Mid_Banner_UIBP:OnLobbyHide()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnLobbyHide")
  if self.nextTimer then
    self:RemoveTimer(self.nextTimer)
  end
end
function Lobby_Mid_Banner_UIBP:OnLobbyShow()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnLobbyShow")
  if self.bNewbieBanner then
    log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnLobbyShow bNewbieBanner")
    return
  end
  local lobbyMainLogic = require("client.slua.logic.lobby.Main.Lobby_Main_Control")
  if lobbyMainLogic.curPage == ENUM_LobbyPageType.Mid then
    self:MoveToNext()
  end
end
function Lobby_Mid_Banner_UIBP:OnSwitchToPageStart()
  self.bIsSwitching = true
end
function Lobby_Mid_Banner_UIBP:OnSwitchToPageEnd(_, _, _, toPage)
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnSwitchToPageEnd toPage  " .. tostring(toPage))
  self.bIsSwitching = false
  local status = GameStatus.GetGameStatus()
  if not GameStatus.IsInLobbyOrMainCity() then
    return
  end
  if toPage == ENUM_LobbyPageType.Mid then
    self:MoveToNext()
  elseif self.nextTimer then
    self:RemoveTimer(self.nextTimer)
  end
end
function Lobby_Mid_Banner_UIBP:MoveToNext()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:MoveToNext")
  if not self.bNewbieBanner and self.BannerUI1 then
    self.BannerUI1:ResetScroll()
  end
  if self.nextTimer then
    self:RemoveTimer(self.nextTimer)
  end
  self.nextTimer = self:AddTimerOnce(1.95, function()
    self:MoveToNext()
  end)
end
function Lobby_Mid_Banner_UIBP:InitStorageEntrance()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:InitStorageEntrance")
  self:RefreshStorageEntrance()
end
function Lobby_Mid_Banner_UIBP:RefreshStorageEntrance()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:RefreshStorageEntrance")
  self:ClearStorageEntrance()
  local showList = {}
  local BlackFridayEntranceModule = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.BlackFridayEntranceModule)
  if BlackFridayEntranceModule and BlackFridayEntranceModule:HasBubble() then
    local BubbleData = BlackFridayEntranceModule:GetBubbleData()
    if BubbleData then
      table.insert(showList, {
        priority = 0,
        uiConfig = UIManager.UI_Config.BlackFriday_Entrance_UIBP,
        name = "BlackFriday"
      })
    end
  end
  if not Client.IsCEVersion() then
    local ok, NinjaTrainingConfig = pcall(require, "client.slua.logic.theme_system.naruto.ninja_training_config")
    if ok and NinjaTrainingConfig.IsActivityOpen() and not self:_IsNewbieNotFinishedFirstBattle() then
      table.insert(showList, {
        priority = 0,
        uiConfig = UIManager.UI_Config.Theme_Entrance_Item,
        name = "ThemeSystem"
      })
    end
  end
  local logic_newbie_assist = require("client.slua.logic.activity.newbie.logic_newbie_assist")
  local logic_newbie_new_abtest = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_newbie_new_abtest)
  if logic_newbie_assist.CheckIsNewBie() or logic_newbie_new_abtest:CheckUseNewNewbieLogic() then
    table.insert(showList, {
      priority = 0,
      uiConfig = UIManager.UI_Config.Lobby_Mid_NewRecruit_Item_UIBP,
      name = "Newbie"
    })
  end
  local logic_player_return = require("client.slua.logic.player_return.logic_player_return")
  if logic_player_return.isPlayerReturnOpenNew() then
    table.insert(showList, {
      priority = 0,
      uiConfig = UIManager.UI_Config.ReturnActivity_Entrance_Item,
      name = "Return"
    })
  end
  local ActivityUtil = require("client.slua.logic.activity.ActivityUtil")
  local tActBubbleData = ActivityUtil.GetLobbyBottomEntranceData()
  if not tActBubbleData then
    local logic_lobby_bubble = require("client.slua.logic.lobby_bubble.logic_lobby_bubble")
    tActBubbleData = logic_lobby_bubble.GetBottomBannerBubbleData()
  end
  if tActBubbleData then
    table.insert(showList, {
      priority = 2,
      uiConfig = UIManager.UI_Config.Lobby_Mid_Bottom_Banner_UIBP,
      name = "BottomBubble"
    })
  end
  table.sort(showList, function(a, b)
    return a.priority < b.priority
  end)
  local maxCount = 3
  local curCount = 0
  local PufferManager = require("client.slua.logic.download.puffer.puffer_manager")
  local PufferConst = require("client.slua.logic.download.puffer_const")
  for i = 1, #showList do
    local config = showList[i]
    log(bWriteLog and "Lobby_Mid_Banner_UIBP:RefreshStorageEntrance create entrance: " .. config.name)
    local path = config.uiConfig.path
    if path and path ~= "" then
      log(bWriteLog and "[SY]Lobby_Mid_Banner_UIBP:RefreshStorageEntrance.Path" .. path)
      local pak_util = require("client.common.pak_util")
      if pak_util.IsFileExist(path) then
        curCount = curCount + 1
        local ui = self:CreateChildWindow(self.UIRoot.WrapBox_Entrance, config.uiConfig, i)
        if ui then
          table.insert(self.storageEntranceUIList, {
            ui = ui,
            name = config.name
          })
        end
      end
    end
    if maxCount <= curCount then
      break
    end
  end
end
function Lobby_Mid_Banner_UIBP:ClearStorageEntrance()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:ClearStorageEntrance")
  for _, item in ipairs(self.storageEntranceUIList or {}) do
    if item.ui then
      item.ui:CloseSelf()
    end
  end
  self.storageEntranceUIList = {}
end
function Lobby_Mid_Banner_UIBP:OnBlackFridayEntranceUpdated()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnBlackFridayEntranceUpdated")
  self:RefreshStorageEntrance()
end
function Lobby_Mid_Banner_UIBP:OnCrazyWeekendActUpdate()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnCrazyWeekendActUpdate")
  self:RefreshStorageEntrance()
end
function Lobby_Mid_Banner_UIBP:OnBottomBubbleUpdated()
  log(bWriteLog and "Lobby_Mid_Banner_UIBP:OnBottomBubbleUpdated")
  self:RefreshStorageEntrance()
end
function Lobby_Mid_Banner_UIBP:_IsNewbieNotFinishedFirstBattle()
  local LogicNewbie = require("client.logic.newbie.logic_newbie")
  if not LogicNewbie.IsNewbie(true) then
    return false
  end
  local totalGameCount = LogicNewbie.GetTotalGameCount()
  printf("Lobby_Mid_Banner_UIBP:_IsNewbieNotFinishedFirstBattle totalGameCount=%s", tostring(totalGameCount))
  return totalGameCount < 1
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_Mid_Banner_UIBP = class(ui_base, nil, Lobby_Mid_Banner_UIBP)
return CLobby_Mid_Banner_UIBP