local Socialize_TeamInformation_UIBP = {}
local IngameTipsTools = require("GameLua.Mod.BaseMod.Common.UI.InGameTipsTools")
local C_ITEM_WIDTH = 248.0
local C_ITEM_HEIGHT = 48.0
function Socialize_TeamInformation_UIBP:ctor()
end
function Socialize_TeamInformation_UIBP:OnInitialize()
  Socialize_TeamInformation_UIBP.__super.OnInitialize(self)
  self.team_mates = {}
  self.timer_list = {}
  self.isOpenTips = false
  self.LoopScrollBox_Teammate = self:InitScrollBox(self.UIRoot.LoopScrollBox_Team)
  self:InitConfig()
end
function Socialize_TeamInformation_UIBP:InitConfig()
  if self.cd_time then
    return
  end
  local type = "CommonRP"
  if UnknowPassSystem and not UnknowPassSystem.IsBuyElite then
    type = "Unpurchased"
  elseif UnknowPassSystem and UnknowPassSystem.PassType == 2 then
    type = "EliteRP"
  end
  local cfg = CDataTable.GetTable("UnknowPassBuyGiveParamCfg")
  self.cd_time = cfg.cd[type]
  self.rp_count = cfg.score[type]
end
function Socialize_TeamInformation_UIBP:RegistEvents()
  Socialize_TeamInformation_UIBP.__super.RegistEvents(self)
  self.LoopScrollBox_Teammate:SetRefreshItemCallback(self.OnRefreshItem, self)
  self.LoopScrollBox_Teammate:AddItemWidgetChildEvent("Button_Appreciates", "OnClicked", self.OnClickAppreciates, self)
  self.LoopScrollBox_Teammate:AddItemWidgetChildEvent("Button_AddFriend", "OnClicked", self.OnClickAddFriend, self)
  self.LoopScrollBox_Teammate:AddItemWidgetChildEvent("Button_Carte", "OnClicked", self.OnClickCarte, self)
  self.LoopScrollBox_Teammate:AddItemWidgetChildEvent("Button_Unable", "OnClicked", self.OnClickUnable, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_WIFI, self.OnClickButton_WIFI, self)
  self:AddOnClickedEventByControl(self.UIRoot.Button_Signal, self.OnClickButton_WIFI, self)
  self:AddCommonEvent(EVENTTYPE_STATE, EVENTID_GAMESTATE_ON_BATTLE_RESULT, self.CloseSelf, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_SPECTATING, EVENTID_ENTER_OBSERVING, self.CloseSelf, self)
end
function Socialize_TeamInformation_UIBP:OnPostInitialize()
  Socialize_TeamInformation_UIBP.__super.OnPostInitialize(self)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Notice, false)
  local IngameLikeUtilClient = require("GameLua.Mod.BaseMod.Client.Like.IngameLikeUtilClient")
  self.bIsRpGiveOpen = IngameLikeUtilClient.CheckIsRpGiveOpen()
  self:RefreshTeamList()
end
function Socialize_TeamInformation_UIBP:OnShow()
  Socialize_TeamInformation_UIBP.__super.OnShow(self)
  self:RefreshDelayShow()
end
function Socialize_TeamInformation_UIBP:RefreshDelayShow()
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Net, false)
  local logic_team_zone_ping = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_team_zone_ping)
  local isShow, playerPingSignal, networkState = logic_team_zone_ping:InGameDelayShow()
  if not isShow then
    return
  end
  if networkState == 2 then
    if playerPingSignal == 1 then
      self.UIRoot.WidgetSwitcher_WIFI:SetActiveWidgetIndex(0)
    elseif playerPingSignal == 2 then
      self.UIRoot.WidgetSwitcher_WIFI:SetActiveWidgetIndex(1)
    end
    self.UIRoot.WidgetSwitcher_Net:SetActiveWidgetIndex(0)
  else
    if playerPingSignal == 1 then
      self.UIRoot.WidgetSwitcher_Signal:SetActiveWidgetIndex(0)
    elseif playerPingSignal == 2 then
      self.UIRoot.WidgetSwitcher_Signal:SetActiveWidgetIndex(1)
    end
    self.UIRoot.WidgetSwitcher_Net:SetActiveWidgetIndex(1)
  end
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Net, true)
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Notice, true)
end
function Socialize_TeamInformation_UIBP:RefreshTeamList()
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  self.team_mates = IngameLikeClientSubSystem:GetTeamMateList()
  if IngameLikeClientSubSystem then
    self.remain_times = IngameLikeClientSubSystem:GetRemainTimes()
  end
  if not self.LoopScrollBox_Teammate then
    return
  end
  self:SetRemainTime(self.remain_times)
  self.LoopScrollBox_Teammate:SetData(self.team_mates)
  local teamSize = #self.team_mates
  self.UIRoot.Image_Scroll.Slot:SetSize(FVector2D(C_ITEM_WIDTH, C_ITEM_HEIGHT * teamSize))
  self.UIRoot.LoopScrollBox_Team.Slot:SetSize(FVector2D(C_ITEM_WIDTH, C_ITEM_HEIGHT * teamSize))
end
function Socialize_TeamInformation_UIBP:SetRemainTime(times)
  if not self.UIRoot or not self.UIRoot.UTRichTextBlock_RP then
    return
  end
  if not UnknowPassSystem.IsBuyElite then
    self.UIRoot.UTRichTextBlock_RP:SetText(DataMgr.GetFormatMsgByIDForBattleText(23567))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Notice, false)
  elseif times <= 0 then
    self.UIRoot.UTRichTextBlock_RP:SetText(DataMgr.GetFormatMsgByIDForBattleText(23565))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Notice, true)
  else
    self.UIRoot.UTRichTextBlock_RP:SetText(LocUtil.LocalizeResFormat(23566, tostring(self.remain_times)))
    self:SetWidgetVisible(self.UIRoot.CanvasPanel_Notice, true)
  end
end
function Socialize_TeamInformation_UIBP:OnRefreshItem(widget, index)
  local data = self.LoopScrollBox_Teammate:GetItemData(index)
  self:SetTexture(widget.Image_Teammate, string.format("/Game/Arts/UI/NoAtlas/ResidentStore/ResurrectTeammates_0%d.ResurrectTeammates_0%d", data.TeamIndex + 1, data.TeamIndex + 1))
  if not self.timer_list[index] then
    if self.remain_times and self.remain_times > 0 and data.Online and self.bIsRpGiveOpen then
      widget.WidgetSwitcher_RP:SetActiveWidgetIndex(0)
    else
      widget.WidgetSwitcher_RP:SetActiveWidgetIndex(1)
    end
  end
  self:SetTimer(widget, index)
  widget.WidgetSwitcher_Friend:SetActiveWidgetIndex(0)
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  local LogicFriend = require("client.slua.logic.friend.logic_new_friend")
  if LogicFriend.IsMyFriend(data.UID) or IngameLikeClientSubSystem and IngameLikeClientSubSystem.add_friend_list and IngameLikeClientSubSystem.add_friend_list[data.UID] then
    widget.WidgetSwitcher_Friend:SetActiveWidgetIndex(1)
  end
end
function Socialize_TeamInformation_UIBP:SetCdState(widget, cd)
  self:InitConfig()
  widget.TextBlock_CD:SetText(DataMgr.GetFormatMsgByIDForBattleText(6704, math.floor(cd)))
  widget.WidgetSwitcher_RP:SetActiveWidgetIndex(2)
  widget.ProgressBar_CD:SetPercent(cd / self.cd_time)
end
function Socialize_TeamInformation_UIBP:OnClickAppreciates(widget, index)
  local logic_enter_game = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_enter_game)
  if logic_enter_game:IsEnterBattleByRoom() then
    ShowNotice(66679)
    return
  end
  self:InitConfig()
  local data = self.LoopScrollBox_Teammate:GetItemData(index)
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  IngameLikeClientSubSystem:SendGiveRP(data.UID, data.PlayerName, self.rp_count)
  IngameLikeClientSubSystem.rp_give_time = IngameLikeClientSubSystem.rp_give_time or {}
  local TimeUtil = require("client.common.time_util")
  IngameLikeClientSubSystem.rp_give_time[index] = TimeUtil.GetServerTimeInSec()
  self:SetTimer(widget, index)
end
function Socialize_TeamInformation_UIBP:SetTimer(widget, index)
  if self.timer_list[index] then
    self:RemoveTimer(self.timer_list[index])
    self.timer_list[index] = nil
  end
  if self.remain_times and self.remain_times < 1 then
    widget.WidgetSwitcher_RP:SetActiveWidgetIndex(1)
    return
  end
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  IngameLikeClientSubSystem.rp_give_time = IngameLikeClientSubSystem.rp_give_time or {}
  local lastGiveTime = IngameLikeClientSubSystem.rp_give_time[index] or 0
  local TimeUtil = require("client.common.time_util")
  local serverTime = TimeUtil.GetServerTimeInSec()
  local cd_count = self.cd_time
  print(bWriteLog and "Socialize_TeamInformation_UIBP:SetTimer " .. tostring(serverTime) .. " " .. tostring(lastGiveTime) .. " " .. tostring(cd_count))
  if cd_count > serverTime - lastGiveTime then
    cd_count = cd_count - (serverTime - lastGiveTime)
  else
    return
  end
  self.timer_list[index] = self:AddTimer(0, function()
    while true do
      if cd_count == 0 then
        local dataItem = self.team_mates[index]
        local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
        if slua.isValid(uPlayerController) and uPlayerController.IsInPetSpectator and uPlayerController:IsInPetSpectator() then
          log(bWriteLog and "Socialize_TeamInformation_UIBP:SetTimer IsInPetSpectator")
        end
        if self.remain_times and 0 < self.remain_times and dataItem and dataItem.Online and self.bIsRpGiveOpen then
          widget.WidgetSwitcher_RP:SetActiveWidgetIndex(0)
        else
          widget.TextBlock_CD:SetText(DataMgr.GetFormatMsgByIDForBattleText(23570))
          widget.WidgetSwitcher_RP:SetActiveWidgetIndex(1)
        end
        if self.timer_list[index] then
          self:RemoveTimer(self.timer_list[index])
          self.timer_list[index] = nil
        end
        break
      else
        self:SetCdState(widget, cd_count)
      end
      coroutine.yield(0.5)
      cd_count = math.max(cd_count - 0.5, 0)
    end
  end)
end
function Socialize_TeamInformation_UIBP:OnClickAddFriend(widget, index)
  local data = self.LoopScrollBox_Teammate:GetItemData(index)
  widget.WidgetSwitcher_Friend:SetActiveWidgetIndex(1)
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  IngameLikeClientSubSystem:SendIngameAddFriend(data.UID)
end
function Socialize_TeamInformation_UIBP:OnClickCarte(widget, index)
  local data = self.LoopScrollBox_Teammate:GetItemData(index)
  local IngameLikeClientSubSystem = SubsystemMgr:Get("IngameLikeClientSubSystem")
  IngameLikeClientSubSystem:ShowPlayerCard(data.UID)
end
function Socialize_TeamInformation_UIBP:OnClickUnable(widget, index)
  if not self.bIsRpGiveOpen then
    BattleNormalTipsByTextID(43505)
  elseif not UnknowPassSystem.IsBuyElite then
    BattleNormalTipsByTextID(23567)
  end
end
function Socialize_TeamInformation_UIBP:OnClickButton_WIFI()
  self.isOpenTips = not self.isOpenTips
  self:SetWidgetVisible(self.UIRoot.CanvasPanel_Tips, self.isOpenTips)
end
function Socialize_TeamInformation_UIBP:OnClose()
  Socialize_TeamInformation_UIBP.__super.OnClose(self)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CSocialize_TeamInformation_UIBP = class(ui_base, nil, Socialize_TeamInformation_UIBP)
return CSocialize_TeamInformation_UIBP