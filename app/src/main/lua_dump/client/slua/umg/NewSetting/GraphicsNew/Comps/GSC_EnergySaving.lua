local GSC_EnergySaving = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local ERenderQuality = import("ERenderQuality")
function GSC_EnergySaving:ctor()
end
function GSC_EnergySaving:OnInitialize()
  self.UIRoot.TextBlock_Title:SetText(LocUtil.GetLocalizeResStr(39999))
  self:SetWidgetVisible(self.UIRoot.Button_Help, true, true)
end
function GSC_EnergySaving:RegistEvents()
  self:AddControlEventByControl(self.UIRoot.Button_Switch, "OnClicked", self.OnClickEnergySwitch, self)
  self:AddControlEventByControl(self.UIRoot.Button_Help, "OnClicked", self.OnClickButton_Help, self)
end
function GSC_EnergySaving:OnAfterAllComponentsInitialized()
  local GraphicHelperUtil = require("client.slua.umg.NewSetting.GraphicsNew.GraphicHelperUtil")
  if not GraphicHelperUtil.ShouldShowEnergySavingBtn() then
    printf("GSC_EnergySaving:OnAfterAllComponentsInitialized not show energy saving btn")
    self:Collapsed()
    return
  end
  self:SelfHitTestInvisible()
  self:SubscribeNotFirstCallBack(GraphicSettingDB.SelectedFPS, function(old, value)
    self:OnSelectedFPSChange(value)
  end)
  self:SubscribeNotFirstCallBack(GraphicSettingDB.BattleRenderQuality, function(old, value)
    self:OnSelectedQualityChange(value)
  end)
  self:Subscribe(GraphicSettingDB.SelectedEnergySaving, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_EnergySaving:AdjustQualityAndFPSChange(newSelectQuality, newSelectFPS)
  printf("GSC_EnergySaving:AdjustQualityAndFPSChange newSelectQuality: %s, newSelectFPS: %s", newSelectQuality, newSelectFPS)
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  if CustomTab == GraphicConst.CustomTabDef.Battle then
    local SelectQuality = newSelectQuality or GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
    local SelectedFPS = newSelectFPS or GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
    if SelectedFPS == GraphicConst.FPSLevelDef.FPS120 then
      if SelectQuality == ERenderQuality.VERYSMOOTH then
        if GraphicSettingDB:GetUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag1) then
          printf("GSC_EnergySaving:AdjustQualityAndFPSChange hit very smooth template. ignore")
        else
          printf("GSC_EnergySaving:AdjustQualityAndFPSChange auto open energy saving on very smooth template")
          GraphicSettingDB:UpdateUIData(GraphicSettingDB.SelectedEnergySaving, true)
        end
      elseif SelectQuality == ERenderQuality.SMOOTH then
        if GraphicSettingDB:GetUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag2) then
          printf("GSC_EnergySaving:AdjustQualityAndFPSChange hit smooth template. ignore")
        else
          printf("GSC_EnergySaving:AdjustQualityAndFPSChange auto open energy saving on smooth template")
          GraphicSettingDB:UpdateUIData(GraphicSettingDB.SelectedEnergySaving, true)
        end
      end
    end
  end
end
function GSC_EnergySaving:OnSelectedFPSChange(newSelectFPS)
  printf("GSC_EnergySaving:OnSelectedFPSChange newSelectFPS: %s", newSelectFPS)
  self:AdjustQualityAndFPSChange(nil, newSelectFPS)
end
function GSC_EnergySaving:OnSelectedQualityChange(newSelectQuality)
  printf("GSC_EnergySaving:OnSelectedQualityChange newSelectQuality: %s", newSelectQuality)
  self:AdjustQualityAndFPSChange(newSelectQuality, nil)
end
function GSC_EnergySaving:OnClickEnergySwitch()
  self:PlayAudio(sound_config.click_v1)
  local value = GraphicSettingDB:UpdateUIDataOneMinus(GraphicSettingDB.SelectedEnergySaving)
  if value == false then
    local SelectQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedQuality)
    local SelectedFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.SelectedFPS)
    if SelectedFPS == GraphicConst.FPSLevelDef.FPS120 then
      if SelectQuality == ERenderQuality.VERYSMOOTH and false == GraphicSettingDB:GetUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag1) then
        printf("GSC_EnergySaving:OnClickEnergySwitch set flag1")
        GraphicSettingDB:UpdateUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag1, true)
      elseif SelectQuality == ERenderQuality.SMOOTH and false == GraphicSettingDB:GetUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag2) then
        printf("GSC_EnergySaving:OnClickEnergySwitch set flag2")
        GraphicSettingDB:UpdateUIData(GraphicSettingDB.bEnergySaveManuelChangeFlag2, true)
      end
    end
  end
  self:GetParentUI():SetDirty(true)
end
function GSC_EnergySaving:UpdateUI(bOpen)
  self.UIRoot.Setting_Switch:SetSwitcherEnable2(bOpen, true)
  local BattleFPS = GraphicSettingDB:GetUIData(GraphicSettingDB.BattleFPS)
  printf("GSC_EnergySaving:UpdateUI bOpen\239\188\154%s, BattleFPS\239\188\154%s", bOpen, BattleFPS)
  if BattleFPS == GraphicConst.FPSLevelDef.FPS120 then
  else
  end
end
function GSC_EnergySaving:OnClickButton_Help()
  self:PlayAudio(sound_config.click_v1)
  UIManager.ShowUI(UIManager.UI_Config.common_questionmark_style_three, LocUtil.GetLocalizeResStr(817283), self.UIRoot.Button_Help)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_EnergySaving)