local GSC_Base = {}
local GraphicSettingDB = require("client.slua.umg.NewSetting.GraphicsNew.GraphicSettingDB")
local GraphicConst = require("client.slua.umg.NewSetting.GraphicsNew.GraphicConst")
function GSC_Base:ctor(_, name)
  self.end
function GSC_Base:OnAfterAllComponentsInitialized()
end
function GSC_Base:OnGraphicsReset()
end
function GSC_Base:OnApplyModify()
end
function GSC_Base:Subscribe(settingKey, callback)
  self:AddDataListener(GraphicSettingDB:GetSuperData(), settingKey, callback)
end
function GSC_Base:SubscribeNotFirstCallBack(settingKey, callback)
  self:AddDataListenerNotFirstCallBack(GraphicSettingDB:GetSuperData(), settingKey, callback)
end
function GSC_Base:GetParentUI()
  return self._parentUI
end
function GSC_Base:IsCustomFavor()
  local GraphicFavor = GraphicSettingDB:GetUIData(GraphicSettingDB.GraphicFavor)
  return GraphicFavor == GraphicConst.FavorDef.Custom
end
function GSC_Base:ChangeQualityAndFPSConfirm(okCallback, cancelCallback)
  local contentMsg = LocUtil.GetLocalizeResStr(49438)
  local titleMsg = LocUtil.GetLocalizeResStr(101001)
  local okMsg = LocUtil.GetLocalizeResStr(7001)
  local cancelMsg = LocUtil.GetLocalizeResStr(7002)
  local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
  CommonMsgBoxMgr.Show(2, titleMsg, contentMsg, function()
    if okCallback then
      okCallback()
    end
  end, function()
    if cancelCallback then
      cancelCallback()
    end
  end, okMsg, cancelMsg)
end
function GSC_Base:CanChangeQualityAndFPSPreCheck()
  local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
  if nEnhancedLobbyQuality == 1 then
    local CustomTab = GraphicSettingDB:GetUIData(GraphicSettingDB.CustomTab)
    if CustomTab == GraphicConst.CustomTabDef.Lobby or CustomTab == GraphicConst.CustomTabDef.Global then
      local title = LocUtil.GetLocalizeResStr(5077)
      local content = LocUtil.GetLocalizeResStr(180021)
      local confirm = LocUtil.GetLocalizeResStr(180032)
      local cancel = LocUtil.GetLocalizeResStr(7002)
      local CommonMsgBoxMgr = require("client.slua.logic.common.logic_common_msg_box")
      CommonMsgBoxMgr.Show(2, title, content, function()
        local nEnhancedLobbyQuality = GraphicSettingDB:GetUIData(GraphicSettingDB.nEnhancedLobbyQuality)
        GraphicSettingDB:UpdateUIData(GraphicSettingDB.nEnhancedLobbyQuality, 2)
        self:GetParentUI():SetDirty(true)
      end, nil, confirm, cancel)
      return false
    end
  end
  return true
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, GSC_Base)