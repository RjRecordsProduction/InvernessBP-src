local PlaneTeamNameUI = {}
function PlaneTeamNameUI:ctor(_, ShowData)
  print(bWriteLog and "PlaneTeamNameUI:ctor")
  self.end
function PlaneTeamNameUI:UpdateShowInfo(ShowData)
  self.  self:OnShow()
end
function PlaneTeamNameUI:OnShow()
  print(bWriteLog and "PlaneTeamNameUI:OnShow22")
  PlaneTeamNameUI.__super.OnShow(self)
  if self.ShowData and self.ShowData.ShowAni then
    self:PlayAnim(self.ShowData.ShowAni)
    return
  end
  local ShowTeamNum, ShowTeamIndexs
  if self.ShowData and self.ShowData.TeamNum then
    ShowTeamNum = tonumber(self.ShowData.TeamNum)
  end
  if self.ShowData and self.ShowData.ShowItemIndex then
    ShowTeamIndexs = {}
    for _, Param in pairs(SplitStr(self.ShowData.ShowItemIndex, ",")) do
      local index = tonumber(Param)
      if index then
        ShowTeamIndexs[#ShowTeamIndexs + 1] = index
      end
    end
  end
  if ShowTeamNum then
    self:OnShowDell(ShowTeamNum, ShowTeamIndexs, self.ShowData.FromPlaneShowPanel)
  else
    self.UIRoot.TeamNum4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function PlaneTeamNameUI:OnShowDell(ShowTeamNum, ShowTeamIndexs, FromPlaneShowPanel)
  local GameplayData = require("GameLua.GameCore.Data.GameplayData")
  local playerstate = GameplayData.GetPlayerState()
  if not slua.isValid(playerstate) then
    return
  end
  local ConfigDrivePlaneShowSubsystem = SubsystemMgr:Get("ConfigDrivePlaneShowSubsystem")
  if not ConfigDrivePlaneShowSubsystem then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local TeamMateInfo = ConfigDrivePlaneShowSubsystem:GetCurrentTeamMatePlayerStateList()
  if not TeamMateInfo or #TeamMateInfo < 1 then
    self.UIRoot:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if self.UIRoot.WidgetSwitcher_1 then
    self.UIRoot.WidgetSwitcher_1:SetActiveWidgetIndex(ShowTeamNum - 1)
  elseif self.UIRoot.TeamNum4 then
    self.UIRoot.TeamNum4:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  end
  for index, value in ipairs(TeamMateInfo) do
    if self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index] and self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].TeammateNameText and self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].TeammateNameText then
      self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].TeammateNameText:SetText(value.PlayerName)
      self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].Imagebg:SetBrushfromPathAsync("/Game/Arts/UI/NoAtlas/Character_ID/Character_ID_Emerges_0" .. index .. ".Character_ID_Emerges_0" .. index, false)
      if self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].WidgetSwitcher_0 then
        self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].WidgetSwitcher_0:SetActiveWidgetIndex(0)
      end
      local GamePlayTools = require("GameLua.Mod.BaseMod.Common.GamePlayTools")
      local PlaneShowConfig = GamePlayTools.GetCurrentConfig("PlaneShowConfig")
      if FromPlaneShowPanel and value.CabinShowActorID and PlaneShowConfig and PlaneShowConfig.CabinShowItemConfig and PlaneShowConfig.CabinShowItemConfig.ShowItems and PlaneShowConfig.CabinShowItemConfig.ShowItems[value.CabinShowActorID] then
        local ShowItem = PlaneShowConfig.CabinShowItemConfig.ShowItems[value.CabinShowActorID]
        if ShowItem and ShowItem.ShowType == "FinalNameUI" and ShowItem.SwitchIndex then
          print(bWriteLog and "PlaneTeamNameUI:RegistEvents WidgetSwitcher:" .. tostring(ShowItem.SwitchIndex))
          self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].WidgetSwitcher_0:SetActiveWidgetIndex(ShowItem.SwitchIndex)
          if self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index]["UIswitchIndex" .. ShowItem.SwitchIndex] then
            self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index]["UIswitchIndex" .. ShowItem.SwitchIndex]:PlayUserWidgetAnimation(self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index]["UIswitchIndex" .. ShowItem.SwitchIndex].Fadein, 0, 1, 0, 1)
            self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index]["UIswitchIndex" .. ShowItem.SwitchIndex].TeammateNameText:SetText(value.PlayerName)
          end
        end
      elseif self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].Fadein then
        self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index]:PlayUserWidgetAnimation(self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. index].Fadein, 0, 1, 0, 1)
      end
    end
  end
  if ShowTeamIndexs then
    for itemi = 1, 4 do
      if self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. 5 - itemi] then
        self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. 5 - itemi]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
      end
    end
    for key, value in pairs(ShowTeamIndexs) do
      if self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. value] then
        self.UIRoot["ItemUI" .. 5 - ShowTeamNum .. value]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      end
    end
  end
end
function PlaneTeamNameUI:RegistEvents()
  PlaneTeamNameUI.__super.RegistEvents(self)
  print(bWriteLog and "PlaneTeamNameUI:RegistEvents")
  if self.UIRoot.Ani_BlackFade then
    self:AddControlEventByControl(self.UIRoot.Ani_BlackFade, "OnAnimationFinished", self.OnAnimationFinished, self)
  end
  if self.UIRoot.Ani_BlackFade_02 then
    self:AddControlEventByControl(self.UIRoot.Ani_BlackFade_02, "OnAnimationFinished", self.OnAnimationFinished, self)
  end
end
function PlaneTeamNameUI:PlayAnim(Animname)
  print(bWriteLog and "PlaneTeamNameUI:PlayAnim")
  self.UIRoot.TeamNum4:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  if Animname and self.UIRoot[Animname] and not self.UIRoot:IsAnyAnimationPlaying() then
    print(bWriteLog and "PlaneTeamNameUI:PlayAnim" .. Animname)
    self.UIRoot.Vx_Image_Black:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self:PlayUserWidgetAnimation(self.UIRoot[Animname], 0, 1, 0, 1)
  end
end
function PlaneTeamNameUI:OnAnimationFinished()
  self.UIRoot.Vx_Image_Black:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  print(bWriteLog and "PlaneTeamNameUI:OnAnimationFinished")
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, PlaneTeamNameUI)