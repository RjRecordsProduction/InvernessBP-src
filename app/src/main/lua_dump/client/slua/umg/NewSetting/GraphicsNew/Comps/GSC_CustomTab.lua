local GSC_CustomTab = {}
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
function GSC_CustomTab:ctor()
end
function GSC_CustomTab:OnInitialize()
  self.HorizontalTab = self:InitHorizontalLevelOneTextTab(self.UIRoot.Common_Tab_Horizontal_LevelOne_Text_UIBP, {bDarkMode = true})
end
function GSC_CustomTab:RegistEvents()
  self.HorizontalTab:AddOnClickedCallback(self.OnClickedCustomTab, self)
end
function GSC_CustomTab:OnPostInitialize()
  local STExtraGameInstance = import("STExtraGameInstance")
  local gameInstance = STExtraGameInstance.GetInstance()
  local bSupportSwitchRenderLevelRuntime = gameInstance:IsSupportSwitchRenderLevelRuntime()
  if bSupportSwitchRenderLevelRuntime then
    local Tab_Cfg, indexTab
    if IsWoWEditor then
      Tab_Cfg = {
        LocUtil.GetLocalizeResStr(637)
      }
      indexTab = {
        GraphicConst.CustomTabDef.Battle
      }
    else
      Tab_Cfg = {
        LocUtil.GetLocalizeResStr(637),
        LocUtil.GetLocalizeResStr(8108)
      }
      indexTab = {
        GraphicConst.CustomTabDef.Battle,
        GraphicConst.CustomTabDef.Lobby
      }
      table.insert(Tab_Cfg, LocUtil.GetLocalizeResStr(656032))
      table.insert(indexTab, GraphicConst.CustomTabDef.MainCity)
      local logic_home_switch = ModuleManager.GetModule(ModuleManager.LobbyModuleConfig.logic_home_switch)
      if logic_home_switch:CheckHomeSwitchOpen() then
        table.insert(Tab_Cfg, LocUtil.GetLocalizeResStr(64741))
        table.insert(indexTab, GraphicConst.CustomTabDef.Home)
      end
    end
    self.    self.tabCfg = Tab_Cfg
    self.HorizontalTab:SetTabs(self.tabCfg)
  else
    local Tab_Cfg = {
      LocUtil.GetLocalizeResStr(25285)
    }
    self.indexTab = {
      GraphicConst.CustomTabDef.Global
    }
    self.tabCfg = Tab_Cfg
    self.HorizontalTab:SetTabs(self.tabCfg)
  end
end
function GSC_CustomTab:OnAfterAllComponentsInitialized()
  self:Subscribe(GraphicSettingDB.GraphicFavor, function(old, value)
    self:UpdateUI(value)
  end)
end
function GSC_CustomTab:UpdateUI(favor)
  printf("GSC_CustomTab:ShowOrHide favor = %s", favor)
  if favor ~= GraphicConst.FavorDef.Custom then
    self:Collapsed()
    return
  end
  self:SelfHitTestInvisible()
  self:UpdateTabSelect()
end
function GSC_CustomTab:UpdateTabSelect()
  local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
  for i, v in ipairs(self.indexTab) do
    if v == CustomTab then
      self.HorizontalTab:Select(i)
      return
    end
  end
end
function GSC_CustomTab:OnClickedCustomTab(widget, index)
  printf("GSC_CustomTab:OnClickedCustomTab index = %s", index)
  if widget ~= nil then
    self:PlayAudio(sound_config.click_v1)
  end
  local customTab = self.indexTab[index]
  GraphicSettingDB:UpdateUIData(GraphicSettingDB.CustomTab, customTab, false)
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_CustomTab)