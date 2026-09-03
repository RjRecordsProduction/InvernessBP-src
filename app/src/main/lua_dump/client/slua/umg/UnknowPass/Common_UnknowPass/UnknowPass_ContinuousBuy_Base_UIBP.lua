local UnknowPass_ContinuousBuy_Base_UIBP = {}
function UnknowPass_ContinuousBuy_Base_UIBP:OnPostInitialize()
  UnknowPass_ContinuousBuy_Base_UIBP.__super.OnPostInitialize(self)
  self:RestoreUIOperation()
end
function UnknowPass_ContinuousBuy_Base_UIBP:OnClose()
  if not self:IsAsyncLoading() then
    self:_HideAllChildUI()
  end
  UnknowPass_ContinuousBuy_Base_UIBP.__super.OnClose(self)
end
function UnknowPass_ContinuousBuy_Base_UIBP:OnItemBtnClick()
  self:PlayAudio(sound_config.click_v1)
  if self.fClickItemCallback then
    local tClickItemCallbackParam = self.tClickItemCallbackParam or {}
    self.fClickItemCallback(table.unpack(tClickItemCallbackParam))
  end
end
function UnknowPass_ContinuousBuy_Base_UIBP:InitView(param_data)
  self._cObj_promise = nil
  self:UIOperation(function()
    self:_InitView(param_data)
  end)
end
function UnknowPass_ContinuousBuy_Base_UIBP:SetEffect(bIsShow)
  if bIsShow then
    self:_ShowChildUI(self.Enum_Effect)
  else
    self:_HideChildUI(self.Enum_Effect)
  end
end
function UnknowPass_ContinuousBuy_Base_UIBP:SetImage(sPicPath, vector2d)
  self:_ShowChildUI(self.Enum_Icon, function(ui)
    ui:SetTexture(ui.UIRoot.Image_Icon, sPicPath)
    if not vector2d then
      vector2d = FVector2D(1, 1)
    end
    if vector2d then
      ui.UIRoot.Image_Icon:SetRenderScale(vector2d)
    end
  end)
end
function UnknowPass_ContinuousBuy_Base_UIBP:_CreateCommonItemChildUI(nChildType, tChildCfg)
  if self[nChildType] then
    return self[nChildType]
  end
  local tChildCfg = self:GetChildConfigByType(nChildType)
  if not tChildCfg then
    log(bWriteLog and " Common Item Not Child Node Cfg By Name >>>>>", nChildType)
    return
  end
  local sParentName = tChildCfg.sParentName
  sParentName = sParentName or self.sDefaultRootName
  local config = UIManager.UI_Config.ChildUIWithoutBpPathForUnknowPass
  local bSync = tChildCfg.sync
  if bSync then
    config = UIManager.UI_Config.ChildUIWithoutBpPathForUnknowPassSync
  end
  self[nChildType] = self:CreateChildWindowWithBpPath(sParentName, config, tChildCfg.sBpPath)
  self[nChildType]:SetZOrder(nChildType)
  return self[nChildType]
end
function UnknowPass_ContinuousBuy_Base_UIBP:_RemoveCommonItemChildUI(nChildType)
  if not self[nChildType] then
    return
  end
  self[nChildType]:Close()
  self[nChildType] = nil
end
function UnknowPass_ContinuousBuy_Base_UIBP:_CreateOrRemoveCommonItemChildUI(nChildType, bIsShow)
  if bIsShow then
    local cObj = self:_CreateCommonItemChildUI(nChildType)
    return cObj
  else
    self:_RemoveCommonItemChildUI(nChildType)
  end
end
function UnknowPass_ContinuousBuy_Base_UIBP:_ShowChildUI(nChildType, fResolveCallback, fRejectCallback)
  local tChildCfg = self:GetChildConfigByType(nChildType)
  if not tChildCfg then
    log_error("UnknowPass_ContinuousBuy_Base_UIBP tChildCfg = nil,  childType =" .. tostring(nChildType))
    return
  end
  local bComponent = tChildCfg.sBpPath ~= nil
  if not bComponent then
    self:UIOperation(function(ui)
      local cCanvas = self.UIRoot[tChildCfg.sWidgetName]
      if cCanvas then
        local bIsButton = tChildCfg.bIsButton == true
        self:SetWidgetVisible(cCanvas, true, bIsButton)
        if cCanvas.Slot then
          cCanvas.Slot:SetZOrder(nChildType)
        else
          log_error("UnknowPass_ContinuousBuy_Base_UIBP not Slot childType =" .. tostring(nChildType))
        end
      end
      if fResolveCallback then
        fResolveCallback(ui)
      end
    end, fRejectCallback)
    return
  end
  self:UIOperation(function()
    local cObj = self:_CreateCommonItemChildUI(nChildType)
    if cObj then
      cObj:UIOperation(fResolveCallback, fRejectCallback)
    end
  end)
end
function UnknowPass_ContinuousBuy_Base_UIBP:_HideChildUI(nChildType)
  local tChildCfg = self:GetChildConfigByType(nChildType)
  if not tChildCfg then
    log_error("UnknowPass_ContinuousBuy_Base_UIBP tChildCfg = nil,  childType =" .. tostring(nChildType))
    return
  end
  local bComponent = tChildCfg.sBpPath ~= nil
  if not bComponent then
    local cCanvas = self.UIRoot[tChildCfg.sWidgetName]
    if cCanvas then
      self:SetWidgetVisible(cCanvas, false)
    end
    return
  end
  self:UIOperation(function()
    self:_RemoveCommonItemChildUI(nChildType)
  end)
end
function UnknowPass_ContinuousBuy_Base_UIBP:_HideAllChildUI()
  local tChildCfgs = self:GetChildConfig()
  for _, tChildCfg in ipairs(tChildCfgs) do
    local bComponent = tChildCfg.sBpPath ~= nil
    if not bComponent then
      local cCanvas = self.UIRoot[tChildCfg.sWidgetName]
      if cCanvas then
        self:SetWidgetVisible(cCanvas, false)
      end
    end
  end
end
function UnknowPass_ContinuousBuy_Base_UIBP:SetClickItemCallback(fCallback, ...)
  self.fClickItemCallback = fCallback
  self.tClickItemCallbackParam = table.pack(...)
  self:_ShowChildUI(self.Enum_Clickable, function(ui)
    ui:AddOnClickedEventByControl(ui.UIRoot.Button_Item, self.OnItemBtnClick, self)
  end)
end
local Trait = require("common.trait")
local Traits = {
  require("client.slua.umg.UnknowPass.Common_UnknowPass.UnknowPass_ContinuousBuy_Cfg")
}
local class = require("class")
local ui_base = require("client.slua.component.item.ItemChildren.CommonItem_UIBase")
return Trait.TraitClass(ui_base, nil, UnknowPass_ContinuousBuy_Base_UIBP, Traits)