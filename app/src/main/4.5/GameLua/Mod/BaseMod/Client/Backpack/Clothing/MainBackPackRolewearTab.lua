local GameplayData = require("GameLua.GameCore.Data.GameplayData")
local MainBackPackRolewearTab = {}
function MainBackPackRolewearTab:ctor(_, Data)
  self.Entryend
function MainBackPackRolewearTab:OnInitialize()
end
function MainBackPackRolewearTab:RegistEvents()
  self:AddOnClickedEventByControl(self.UIRoot.Button_Index, self.OnClickButton_Index, self)
  self:AddCommonEvent(EVENTTYPE_INGAME_BACKPACK, EVENTID_BACKPACK_AVATAR_ON_CHANGE_WEARING_DONE, self.OnChangeWearingDone, self)
end
function MainBackPackRolewearTab:OnPostInitialize()
  self:UpdateUI()
  self:RefreshCD(false)
end
function MainBackPackRolewearTab:OnClose()
end
function MainBackPackRolewearTab:OnClickButton_Index()
  self:PlayAudio(sound_config.click_v1)
  if not self.EntryData then
    print(bWriteLog and "MainBackPackRolewearTab:OnClickButton_Index entry data is invalid")
    return
  end
  local WearIndex = self.EntryData.Index
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  if self.EntryData.bIsLocked then
    PlayerController:DisplayGameTipWithMsgIDAndString(6037, tostring(self.EntryData.ShowText), "")
    return
  end
  if WearIndex < 0 then
    print(bWriteLog and "MainBackPackRolewearTab:OnClickButton_Index WearIndex  < 0")
    return
  end
  local CurrentWearIndex = PlayerController.RolewearIndex
  if WearIndex == CurrentWearIndex then
    print(bWriteLog and "MainBackPackRolewearTab:OnClickButton_Index WearIndex == CurrentWearIndex")
    return
  end
  local Character = GameplayData.GetPlayerCharacter()
  if slua.isValid(Character) then
    Character:OnInterruptCurrentEmote()
  end
  if not PlayerController:RequestChangeWear(WearIndex) then
    PlayerController:DisplayGameTipWithMsgIDAndString(6037, tostring(self.EntryData.ShowText), "")
    return
  end
end
function MainBackPackRolewearTab:OnChangeWearingDone(_, __, bNeedCD)
  self:UpdateUI()
  self:RefreshCD(bNeedCD)
end
function MainBackPackRolewearTab:UpdateUI()
  log(bWriteLog and "MainBackPackRolewearTab:UpdateUI")
  local Data = self.EntryData
  if not Data then
    return
  end
  local PlayerController = GameplayData.GetPlayerController()
  if not slua.isValid(PlayerController) then
    return
  end
  print(bWriteLog and "MainBackPackRolewearTab:UpdateUI", Data.Index, Data.bIsLocked, Data.bNeedCD, Data.ShowText, PlayerController.RolewearIndex)
  self.UIRoot.Text_index:SetText(Data.ShowText)
  local bSelect = PlayerController.RolewearIndex == Data.Index
  self:SetWidgetVisible(self.UIRoot.Image_select, bSelect, false)
  self:SetWidgetVisible(self.UIRoot.Image_yijiaSel, bSelect, false)
  self:SetWidgetVisible(self.UIRoot.Image_yijia, not bSelect, false)
  self:SetWidgetVisible(self.UIRoot.Image_lock2, Data.bIsLocked, false)
  self:SetWidgetVisible(self.UIRoot.Image_Exchange, false, false)
end
function MainBackPackRolewearTab:RefreshCD(bNeedCD)
  if bNeedCD then
    self.UIRoot:CoolDown()
    self:ClearCDTimer()
    self.CDTimer = self:AddGameTimer(0.2, true, function()
      self.UIRoot:RefreshCountDownAni()
      self.UIRoot:CustomEvent_0()
      if self.UIRoot.AnimationCurrentTime > self.UIRoot.AnimationLength then
        self:ClearCDTimer()
      end
    end)
  else
    self.UIRoot:ClearCoolDown()
  end
end
function MainBackPackRolewearTab:ClearCDTimer()
  if self.CDTimer then
    self:RemoveGameTimer(self.CDTimer)
    self.CDTimer = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, MainBackPackRolewearTab)