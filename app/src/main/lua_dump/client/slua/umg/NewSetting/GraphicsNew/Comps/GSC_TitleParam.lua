local GSC_TitleParam = {}
function GSC_TitleParam:OnPostInitialize()
  self.UIRoot.Button_Help:SetVisibility(UEnums.ESlateVisibility.Collapsed)
  self.UIRoot.Text:SetText(LocUtil.GetLocalizeResStr(880011))
end
local class = require("class")
local GSC_Base = require("client.slua.umg.NewSetting.GraphicsNew.Comps.GSC_Base")
return class(GSC_Base, nil, GSC_TitleParam)