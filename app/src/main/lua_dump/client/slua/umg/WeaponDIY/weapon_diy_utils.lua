local WeaponDiyUtil = {}
function WeaponDiyUtil:GetWeaponResearchMainUI()
  return UIManager.GetUI(UIManager.UI_Config.Weapon_Diy_Frame)
end
function WeaponDiyUtil:ConvertToPolar(vector)
  local _r = self:GetVectorLength(vector)
  local _angle = 0
  if vector.x == 0 then
    if 0 < vector.y then
      _angle = 90
    elseif 0 > vector.y then
      _angle = 270
    end
  else
    local tempAngle = math.atan(vector.y, vector.x) * 180 / 3.1416
    if tempAngle < 0 then
      _angle = 360 + tempAngle
    else
      _angle = tempAngle
    end
  end
  local result = {r = _r, angle = _angle}
  return result
end
function WeaponDiyUtil:ConvertToVector(r, angle)
  local result = {
    x = r * math.cos(math.rad(angle)),
    y = r * math.sin(math.rad(angle))
  }
  return result
end
function WeaponDiyUtil:GetVectorLength(vector)
  return math.sqrt(vector.x * vector.x + vector.y * vector.y)
end
function WeaponDiyUtil:GetFrame()
  return UIManager.GetUI(UIManager.UI_Config.Weapon_Diy_Frame)
end
function WeaponDiyUtil:SerializeDiyPatternTable(data)
  local result = ""
  for i, v in ipairs(data) do
    result = result .. "TexPathID" .. data[i].TexPathID
    result = result .. "OffsetX" .. data[i].DIYParam.OffSetX
    result = result .. "OffsetY" .. data[i].DIYParam.OffSetY
    result = result .. "ScaleX" .. data[i].DIYParam.ScaleX
    result = result .. "ScaleY" .. data[i].DIYParam.ScaleY
    result = result .. "ColorID" .. data[i].DIYParam.ColorID
    result = result .. "Rotation" .. data[i].DIYParam.Rotation
    result = result .. "Opacity" .. data[i].DIYParam.Opacity
    result = result .. "UClipX" .. data[i].DIYParam.UClipX
    result = result .. "UClipY" .. data[i].DIYParam.UClipY
    result = result .. "VClipX" .. data[i].DIYParam.VClipX
    result = result .. "VClipY" .. data[i].DIYParam.VClipY
  end
  return result
end
function WeaponDiyUtil:UpdateColorOrIconPanel(panel, data, str, isHide)
  if not (panel and data and str) or not panel["icon_" .. str .. "_1"] then
    return
  end
  for i = 1, 2 do
    panel["icon_" .. str .. "_" .. tostring(i)]:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    panel["num_" .. str .. "_" .. tostring(i)]:SetText("      --")
  end
  local bNeedShow = false
  local WeaponDIYSystem = require("client.slua.logic.weapon_diy.logic_weapon_diy")
  local num = tonumber(data[WeaponDIYSystem.COM_MT_ID])
  if num and 0 < num then
    self:SetOneColorOrIcon(WeaponDIYSystem.COM_MT_ID, num, 1, str, panel, isHide)
    bNeedShow = true
  end
  num = tonumber(data[WeaponDIYSystem.SP_MT_ID])
  if num and 0 < num then
    self:SetOneColorOrIcon(WeaponDIYSystem.SP_MT_ID, num, 2, str, panel, isHide)
    bNeedShow = true
  end
  return bNeedShow
end
function WeaponDiyUtil:SetOneColorOrIcon(id, num, index, str, panel, isHide)
  local cfg
  if num and 0 < num then
    local wardrobe_data = require("client.slua.logic.wardrobe.wardrobe_data")
    cfg = CDataTable.GetTableData("Item", id)
    if cfg and cfg.ItemSmallIcon and cfg.ItemSmallIcon ~= "" and not isHide then
      panel["icon_" .. str .. "_" .. tostring(index)]:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
      local util = require("client.slua_ui_framework.util")
      util.SetTexture(panel["icon_" .. str .. "_" .. tostring(index)], cfg.ItemSmallIcon)
      panel["num_" .. str .. "_" .. tostring(index)]:SetText(tostring(num))
      if str == "total" then
        local itemData = wardrobe_data:GetHallDepotItemDataByResID(id)
        if itemData and num <= itemData.count then
          local white = FSlateColor(FLinearColor(1, 1, 1, 1))
          panel["num_" .. str .. "_" .. tostring(index)]:SetColorAndOpacity(white)
        else
          local red = FSlateColor(FLinearColor(1, 0, 0, 1))
          panel["num_" .. str .. "_" .. tostring(index)]:SetColorAndOpacity(red)
        end
      end
    end
  end
end
local DIY_MAT_TYPE_ID = 37
local DIY_COLOR_SUB_TYPE_ID = 3702
local DIY_BASE_COLOR_SUB_TYPE_ID = 3704
local MAX_COLOR_ID = 1000
function WeaponDiyUtil:IsDiyColor(itemId)
  local itemData = CDataTable.GetTableData("Item", itemId)
  if itemData == nil then
    return false, nil
  end
  if itemData.ItemType == DIY_MAT_TYPE_ID and (itemData.itemSubType == DIY_COLOR_SUB_TYPE_ID or itemData.itemSubType == DIY_BASE_COLOR_SUB_TYPE_ID) then
    if not itemId or itemId == 0 then
      return false, nil
    end
    local WeaponDIYBaseColor = CDataTable.GetTableData("WeaponDIYBaseColor", itemId)
    if WeaponDIYBaseColor and WeaponDIYBaseColor.color_id and WeaponDIYBaseColor.color_id < MAX_COLOR_ID then
      return true, WeaponDIYBaseColor.color_id
    end
    local WeaponDIYColor
    WeaponDIYColor = CDataTable.GetTableData("WeaponDIYColor", itemId)
    if WeaponDIYColor and WeaponDIYColor.color_id and WeaponDIYColor.color_id < MAX_COLOR_ID then
      return true, WeaponDIYColor.color_id
    end
  end
  return false, nil
end
function WeaponDiyUtil:SetDiyColorImage(image, colorId)
  local colorDefaultMat = "/Game/UMG/Texture/Lobby_NoAtlas/Upgrade/GunDIY/T_Diffuse2.T_Diffuse2"
  local util = require("client.slua_ui_framework.util")
  util.SetTexture(image, colorDefaultMat, {sync = false})
  local colorData = CDataTable.GetTableData("WeaponDIYColorTable", colorId)
  if colorData then
    local color = FColor.FromHex(colorData.ColorString)
    local linearColor = FLinearColor.FromSRGBColor(color)
    image:SetColorAndOpacity(linearColor)
  end
end
return WeaponDiyUtil