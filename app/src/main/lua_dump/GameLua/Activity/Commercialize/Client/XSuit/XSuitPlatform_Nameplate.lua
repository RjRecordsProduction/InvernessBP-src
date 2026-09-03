local XSuitPlatform_Nameplate = {}
function XSuitPlatform_Nameplate:ctor()
end
function XSuitPlatform_Nameplate:OnInitialize()
end
function XSuitPlatform_Nameplate:UpdatedaPlayerInfo(PlayerInfo)
  log(bWriteLog and "XSuitPlatform_Nameplate UpdatedaPlayerInfo ")
  if not slua.isValid(self.UIRoot) then
    return
  end
  self.UIRoot.Name:SetText(PlayerInfo.PlayerName)
  local SuitID = PlayerInfo.ItemID
  local XSuitCfg = CDataTable.GetTableData("GoldClothBattleEffect", SuitID)
  if XSuitCfg then
    print(bWriteLog and "XSuitPlatform_Nameplate:UpdatedaPlayerInfo" .. XSuitCfg.CallIcon)
    local params = {sync = false, bMatchSize = true}
    self:SetTexture(self.UIRoot.Image_xsuit, XSuitCfg.CallIcon, params)
  end
  local Nation = PlayerInfo.Nation
  if Nation == "None" then
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  local NationInfo = CDataTable.GetTableData("RegionConfig", Nation)
  NationInfo = NationInfo or CDataTable.GetTableData("RegionConfig", "G1")
  if not NationInfo then
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
    return
  end
  if GlobalData.GetNationSwitch("Battle") and GlobalData.GetNationSwitch("All") then
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
    self.UIRoot.Image_Nation:SetBrushFromPathAsync(NationInfo.res_path, false)
  else
    self.UIRoot.Image_Nation:SetWidgetVisibility(UEnums.ESlateVisibility.Collapsed)
  end
end
function XSuitPlatform_Nameplate:OnClose()
  log(bWriteLog and "XSuitPlatform_Nameplate OnClose ")
end
function XSuitPlatform_Nameplate:OnShow()
  log(bWriteLog and "XSuitPlatform_Nameplate OnShow ")
end
function XSuitPlatform_Nameplate:OnHide()
  log(bWriteLog and "XSuitPlatform_Nameplate OnHide ")
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
return class(ui_base, nil, XSuitPlatform_Nameplate)