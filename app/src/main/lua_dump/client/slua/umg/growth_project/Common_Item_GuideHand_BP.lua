local Common_Item_GuideHand_BP = {}
function Common_Item_GuideHand_BP:ctor(_, cnt, cb, isPoke)
  self.loopCnt = cnt or 0
  self.  self.end
function Common_Item_GuideHand_BP:OnInitialize()
  Common_Item_GuideHand_BP.__super.OnInitialize(self)
  self.Canvas_Panel_HandGuide = self.UIRoot.Canvas_Panel_HandGuide
end
function Common_Item_GuideHand_BP:RegistEvents()
  Common_Item_GuideHand_BP.__super.RegistEvents(self)
  self:AddControlEventByControl(self.UIRoot.Animation_Hand, "OnAnimationFinished", self.OnAnimationEnd, self)
end
function Common_Item_GuideHand_BP:OnPostInitialize()
  Common_Item_GuideHand_BP.__super.OnPostInitialize(self)
  self:UpdateUI()
end
function Common_Item_GuideHand_BP:UpdateUI()
  self.UIRoot.Canvas_Panel_HandGuide:SetWidgetVisibility(UEnums.ESlateVisibility.SelfHitTestInvisible)
  if self.isPoke then
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_chuo1chuo, 0, self.loopCnt, 0, 1)
  else
    self:PlayUserWidgetAnimation(self.UIRoot.Animation_Hand, 0, self.loopCnt, 0, 1)
  end
end
function Common_Item_GuideHand_BP:OnAnimationEnd()
  if self.cb then
    self.cb()
    self.cb = nil
  end
end
local class = require("class")
local ui_base = require("client.slua_ui_framework.base")
local CCommon_Item_GuideHand_BP = class(ui_base, nil, Common_Item_GuideHand_BP)
return CCommon_Item_GuideHand_BP