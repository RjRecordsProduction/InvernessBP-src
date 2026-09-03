local ace_config = require("client.slua.umg.ace_imprint.config.ace_config")
local util = require("client.slua_ui_framework.util")
local asset_util = require("common.asset_util")
local Common_KingMark_UIBP_2 = {}
function Common_KingMark_UIBP_2:ctor(_, open_param)
  self.open_param = open_param or 4
end
function Common_KingMark_UIBP_2:OnInitialize()
  local showIndex = self.open_param or 4
  self:UpdateShowLevel(showIndex)
end
function Common_KingMark_UIBP_2:RegistEvents()
end
function Common_KingMark_UIBP_2:OnPostInitialize()
  self:UpdateUI()
end
function Common_KingMark_UIBP_2:OnClose()
  if self._fontMaterialWidgets then
    for i = 1, #self._fontMaterialWidgets do
      local widget = self._fontMaterialWidgets[i]
      if widget and slua.isValid(widget) then
        local fontInfo = widget.Font
        if fontInfo then
          fontInfo.FontMaterial = nil
          widget:SetFont(fontInfo)
        end
      end
    end
    self._fontMaterialWidgets = nil
  end
  log(bWriteLog and "Common_KingMark_UIBP_2:OnClose")
end
function Common_KingMark_UIBP_2:UpdateShowLevel(showIndex)
  log_format("Common_KingMark_UIBP_2:UpdateShowLevel. showIndex=%s", showIndex)
  self.open_param = showIndex
  self.UIRoot.WidgetSwitcher_Level:SetActiveWidgetIndex(showIndex)
end
function Common_KingMark_UIBP_2:PlayAnimationById(showID)
  log_format("Common_KingMark_UIBP_2:PlayAnimationById. showID=%s", showID)
  if not showID then
    return
  end
  local animID = self:GetAnimationIdByShowId(showID)
  local animName = "anim_KingMark" .. tostring(animID)
  log_format("Common_KingMark_UIBP_2:PlayAnimationById. animName=%s", animName)
  if self.UIRoot[animName] then
    self:PlayUserWidgetAnimation(self.UIRoot[animName], 0, 1, 0, 1)
  end
end
function Common_KingMark_UIBP_2:GetAnimationIdByShowId(showID)
  local animID = 0
  local tempID = showID
  if 1000 < showID then
    tempID = showID // 1000
  end
  if 7 <= tempID and tempID <= 10 then
    animID = tempID - 7
  end
  return animID
end
function Common_KingMark_UIBP_2:SetWidgetInfo(imprint_id, imprint_data)
  local advance_widget, history_widget, image_widget
  local isGodAce = false
  local show_index = self:GetAnimationIdByShowId(imprint_id) + 1
  local aceImprintCfg
  if not aceImprintCfg then
    local base_id = imprint_id
    if 1000 < imprint_id then
      base_id = imprint_id // 1000
    end
    aceImprintCfg = ace_config.HonerImprintInfo[base_id]
  end
  imprint_data.advance_num = tonumber(imprint_data.advance_num) or 0
  imprint_data.history_num = tonumber(imprint_data.history_num) or 0
  local count = imprint_data.advance_num + imprint_data.history_num
  if imprint_data.advance_num == 0 then
    self:UpdateShowLevel(0)
    advance_widget = self.UIRoot.TextBlock_Gray
    history_widget = self.UIRoot.TextBlock_2
    image_widget = self.UIRoot.Image_Icon_Gray
    if aceImprintCfg then
      util.SetTexture(image_widget, aceImprintCfg.Icon)
    end
    if show_index == 4 then
      self:SetWidgetVisible(history_widget, false)
      isGodAce = true
    end
  else
    self:UpdateShowLevel(show_index)
    if show_index == 1 then
      advance_widget = self.UIRoot.TextBlock_5
      history_widget = self.UIRoot.TextBlock_6
    elseif show_index == 2 then
      advance_widget = self.UIRoot.TextBlock_3
      history_widget = self.UIRoot.TextBlock_4
    elseif show_index == 3 then
      advance_widget = self.UIRoot.TextBlock_0
      history_widget = self.UIRoot.TextBlock_1
    elseif show_index == 4 then
      advance_widget = self.UIRoot.TextBlock_Num04
      isGodAce = true
    end
  end
  if imprint_data.advance_num and advance_widget then
    advance_widget:SetText(imprint_data.advance_num)
    if isGodAce then
      advance_widget:SetText(count)
    end
    if aceImprintCfg then
      self:SetTxtFontRes(advance_widget, aceImprintCfg.FontMaterial)
    end
  end
  if imprint_data.history_num and history_widget then
    history_widget:SetText(count)
    if aceImprintCfg then
      self:SetTxtFontRes(history_widget, aceImprintCfg.FontMaterial)
    end
  end
  log_format("Common_KingMark_UIBP_2:SetWidgetInfo. imprint_data.advance_num=%s", imprint_data.advance_num)
  log_format("Common_KingMark_UIBP_2:SetWidgetInfo. imprint_data.history_num=%s", count)
end
function Common_KingMark_UIBP_2:getShowActiveIndex(...)
  return self.open_param
end
function Common_KingMark_UIBP_2:SetTxtFontRes(TextBlock_Num, fontMaterialPath)
  if TextBlock_Num == nil or fontMaterialPath == nil or fontMaterialPath == "" then
    return
  end
  local fontMaterial = asset_util.GetAssetSync(fontMaterialPath)
  if fontMaterial then
    local fontInfo = TextBlock_Num.Font
    fontInfo.FontMaterial = fontMaterial
    TextBlock_Num:SetFont(fontInfo)
    if not self._fontMaterialWidgets then
      self._fontMaterialWidgets = {}
    end
    self._fontMaterialWidgets[#self._fontMaterialWidgets + 1] = TextBlock_Num
  end
end
function Common_KingMark_UIBP_2:UpdateUI()
  log(bWriteLog and "Common_KingMark_UIBP_2:UpdateUI")
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, Common_KingMark_UIBP_2)