local ButtonKickPlayer = {bPlayerListShow = false}
function ButtonKickPlayer:ctor(selfType)
end
function ButtonKickPlayer:Initialize()
  self:AddControlEvent(self.Button_SwitchPlayer, "OnClicked", self.OnClickButton_SwitchPlayer, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_UI, EVENTID_SHOW_KICK_PLAYER_BUTTON, self.ShowKickPlayerButton, self)
end
function ButtonKickPlayer:OnDestroy()
  sandbox.LogNormal(bWriteLog and "ButtonKickPlayer:OnDestory")
  self:Dispose()
end
function ButtonKickPlayer:ReceivedInitWidget()
  sandbox.LogNormal(bWriteLog and "ButtonKickPlayer:ReceivedInitWidget")
  self:ShowKickPlayerButton(nil, nil)
end
function ButtonKickPlayer:ShowKickPlayerButton(_, __)
  local uGameState = slua_GameFrontendHUD:GetGameState()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if slua.isValid(uPlayerController) and uPlayerController.IsObserver then
    if uPlayerController.bRoomCanKickPlayer and uGameState:GetGameModeState() ~= "ReadyState" and uPlayerController:IsObserver() == false then
      self.Button_SwitchPlayer:SetWidgetVisibility(UEnums.ESlateVisibility.Visible)
      log(bWriteLog and "ButtonKickPlayer:InitKickPlayerButton Show.")
    else
      self.Button_SwitchPlayer:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      log(bWriteLog and "ButtonKickPlayer:InitKickPlayerButton Hide.")
    end
  end
end
function ButtonKickPlayer:OnClickButton_SwitchPlayer()
  if self.bPlayerListShow == false then
    self.bPlayerListShow = true
    local tLayoutData = {}
    tLayoutData.AnchorData = FAnchors(1.0, 0.0, 1.0, 1.0)
    tLayoutData.Alignment = FVector2D(1.0, 0.0)
    tLayoutData.Size = FVector2D(346.675262, 0.0)
    BatttleWindowMgr.ShowUI("OBMapPlayerListBP", tLayoutData)
    self:RefreshData()
  else
    self.bPlayerListShow = false
    BatttleWindowMgr.HideUI("OBMapPlayerListBP")
  end
end
function ButtonKickPlayer:RefreshData()
  local uPlayerController = slua_GameFrontendHUD:GetPlayerController()
  if uPlayerController and slua.isValid(uPlayerController) then
    local uOBMapPlayerListUI = UIManager.GetUI(UIManager.UI_Config.OBMapPlayerListBP)
    if uOBMapPlayerListUI ~= nil then
      local uObservedData = uPlayerController.ObservedData
      if self.TextBlock_CrtPlayerName ~= nil then
        self.TextBlock_CrtPlayerName:SetText(uObservedData.PlayerName)
      end
      local OBUtilitySubsystem = SubsystemMgr:Get("OBUtilitySubsystem")
      if OBUtilitySubsystem then
        local uSyncOBDataActor = OBUtilitySubsystem:GetSyncOBDataActor()
        if slua.isValid(uSyncOBDataActor) then
          local uTotalPlayerList = uSyncOBDataActor.TotalPlayerList
          local uNearPlayerList = uSyncOBDataActor.NearPlayerList
          uOBMapPlayerListUI:RefreshTotalListData(uTotalPlayerList, uObservedData)
          uOBMapPlayerListUI:RefreshNearListData(uNearPlayerList, uObservedData)
        end
      end
    end
  end
end
local class = require("class")
local CDelegateContainer = require("common.delegate_container")
local CButtonKickPlayer = class(CDelegateContainer, nil, ButtonKickPlayer)
return CButtonKickPlayer