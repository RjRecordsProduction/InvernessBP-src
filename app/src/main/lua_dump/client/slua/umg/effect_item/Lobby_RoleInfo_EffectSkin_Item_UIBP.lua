local Lobby_RoleInfo_EffectSkin_Item_UIBP = {}
function Lobby_RoleInfo_EffectSkin_Item_UIBP:ctor(_, aniName, extraData)
  self.  self.extraData = extraData or {}
  self.bEnableGyroscope = extraData and extraData.bEnableGyroscope
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:OnInitialize()
  if not self.bEnableGyroscope then
    return
  end
  if self.UIRoot.CanvasPanel_Lv1_Front == nil or self.UIRoot.CanvasPanel_Lv2_Nearby == nil or self.UIRoot.CanvasPanel_Lv3_Middle == nil or self.UIRoot.CanvasPanel_Lv4_Back == nil then
    log(bWriteLog and "Lobby_RoleInfo_EffectSkin_Item_UIBP:OnInitialize wrong canvas panel")
    self.bEnableGyroscope = false
  end
  if not LobbySystem.CheckOpen(BP_ENUM_SKIN_GYROSCOPE_SWITCH_ID) then
    log(bWriteLog and "Lobby_RoleInfo_EffectSkin_Item_UIBP:OnInitialize Gyroscope switch close")
    self.bEnableGyroscope = false
  end
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:RegistEvents()
  if self.aniName ~= nil and self.UIRoot[self.aniName] then
    self:AddOnAnimationFinishedEvent(self.aniName, self.OnAnimationFinished, self)
  end
  if self.bEnableGyroscope then
    self:AddCommonEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT, self.OnGyroscopeInput, self)
  end
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:OnPostInitialize()
  if self.aniName ~= nil and self.UIRoot[self.aniName] then
    if self.extraData.bPlayOnce then
      self:PlayUserWidgetAnimation(self.UIRoot[self.aniName], 0, 1, 0, 1)
    else
      self:PlayUserWidgetAnimation(self.UIRoot[self.aniName], 0, 0, 0, 1)
    end
  end
  if self.bEnableGyroscope then
    log(bWriteLog and "Lobby_RoleInfo_EffectSkin_Item_UIBP:OnPostInitialize set Gyroscope timer")
    self.curGyroScopeDeltaYaw = 0
    self.curGyroScopeDeltaPitch = 0
    self.initPosition = {
      CanvasPanel_Lv1_Front = self.UIRoot.CanvasPanel_Lv1_Front.Slot:GetPosition(),
      CanvasPanel_Lv2_Nearby = self.UIRoot.CanvasPanel_Lv2_Nearby.Slot:GetPosition(),
      CanvasPanel_Lv3_Middle = self.UIRoot.CanvasPanel_Lv3_Middle.Slot:GetPosition(),
      CanvasPanel_Lv4_Back = self.UIRoot.CanvasPanel_Lv4_Back.Slot:GetPosition()
    }
    self.maxDeltaX = 50
    self.maxDeltaY = 50
    local time_ticker = require("common.time_ticker")
    self.gyroScopeTimer = self:AddTimerLoop(0, function()
      self:MovePanel("CanvasPanel_Lv1_Front", 1)
      self:MovePanel("CanvasPanel_Lv2_Nearby", 2)
      self:MovePanel("CanvasPanel_Lv3_Middle", 3)
      self:MovePanel("CanvasPanel_Lv4_Back", 4)
      self.curGyroScopeDeltaYaw = 0
      self.curGyroScopeDeltaPitch = 0
    end, TIMER_INFINITE, time_ticker.NEXT_FRAME)
  end
  if self.extraData.soundID and self.extraData.soundID ~= "" then
    self:PlayMusic(self.extraData.soundID)
  end
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:OnClose()
  if self.aniName ~= nil and self.UIRoot[self.aniName] then
    self.UIRoot:StopAnimation(self.UIRoot[self.aniName])
  end
  if self.bEnableGyroscope then
    for k, v in pairs(self.initPosition) do
      self.UIRoot[k].Slot:SetPosition(v)
    end
  end
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:OnAnimationFinished()
  if self.extraData.finishAniCallback then
    self:AddTimerOnce(0, function()
      self.extraData.finishAniCallback()
    end)
  end
  if self.extraData.animationTimeWhenFinish then
    self:AddTimerOnce(0, function()
      if self.UIRoot and self.aniName and self.UIRoot[self.aniName] then
        self:RemoveOnAnimationFinishedEvent(self.aniName)
        self.UIRoot:PlayAnimationTo(self.UIRoot[self.aniName], tonumber(self.extraData.animationTimeWhenFinish), tonumber(self.extraData.animationTimeWhenFinish) + 0.001, 1, 0, 1)
      end
    end)
  end
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:OnGyroscopeInput(_, __, deltaX, deltaY, deltaZ)
  if not self.lastDeltaX then
    self.lastDeltaX = deltaX
  end
  local maxValidDelta = 10
  if maxValidDelta < math.abs(self.lastDeltaX - deltaX) then
    self.curGyroScopeDeltaYaw = 0
    self.curGyroScopeDeltaPitch = 0
    self:RemoveCommonEvent(EVENTTYPE_GYROSCOPE, EVENTID_GYROSCOPE_INPUT)
    self:RemoveTimer(self.gyroScopeTimer)
    return
  end
  self.curGyroScopeDeltaYaw = self.curGyroScopeDeltaYaw + deltaX
  self.curGyroScopeDeltaPitch = self.curGyroScopeDeltaPitch + deltaY
end
function Lobby_RoleInfo_EffectSkin_Item_UIBP:MovePanel(panelName, level)
  if self.curGyroScopeDeltaYaw == 0 and self.curGyroScopeDeltaPitch == 0 then
    return
  end
  local levelDecayRate = 2 ^ (level - 1)
  local deltaRateX = -2
  local deltaRateY = 2
  local deltaX = self.curGyroScopeDeltaYaw / levelDecayRate * deltaRateX
  local deltaY = self.curGyroScopeDeltaPitch / levelDecayRate * deltaRateY
  local initPos = self.initPosition[panelName]
  local curPostion = self.UIRoot[panelName].Slot:GetPosition()
  local newPos = curPostion + FVector2D(deltaX, deltaY)
  local curMaxDeltaX = self.maxDeltaX / levelDecayRate
  local curMaxDeltaY = self.maxDeltaY / levelDecayRate
  if curMaxDeltaX < newPos.X - initPos.X then
    newPos.X = initPos.X + curMaxDeltaX
  elseif curMaxDeltaX < initPos.X - newPos.X then
    newPos.X = initPos.X - curMaxDeltaX
  end
  if curMaxDeltaY < newPos.Y - initPos.Y then
    newPos.Y = initPos.Y + curMaxDeltaY
  elseif curMaxDeltaY < initPos.Y - newPos.Y then
    newPos.Y = initPos.Y - curMaxDeltaY
  end
  self.UIRoot[panelName].Slot:SetPosition(newPos)
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CLobby_RoleInfo_EffectSkin_Item_UIBP = class(ui_base, nil, Lobby_RoleInfo_EffectSkin_Item_UIBP)
return CLobby_RoleInfo_EffectSkin_Item_UIBP