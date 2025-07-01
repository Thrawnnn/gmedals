local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
    self.BaseH = Nexus:Scale(60)
    self:SetTall(self.BaseH)

    local old = self.SetTall
    function self:SetTall(val, dontReapply)
        old(self, val)
        self.BaseH = self.StopChanging and self.BaseH or val
    end

    self.isExpanded = false
    self.items = self.items or {}

    self.Canvas = self:Add("DPanel")
    self.Canvas.Paint = function(s, w, h)
        draw.RoundedBoxEx(Nexus:Scale(10), 0, 0, w, h, Nexus.Colors.Header, false, false, true, true)
    end
    self.Canvas.OnChildAdded = function(s, child)
        table.insert(self.items, child)
    end
    self.Canvas.overrideParent = self:GetParent()
end

function PANEL:PerformLayout(w, h)
    self.Canvas:SetPos(0, self.BaseH)
    self.Canvas:SetWide(w)
end

function PANEL:SetText(str)
    self.text = str
end

function PANEL:GetText(str)
    return self.text
end

function PANEL:AddItem(str)
    local panel = self.Canvas:Add(str)
    panel:Dock(TOP)
    panel:DockMargin(self.margin, self.margin, self.margin, 0)

    return panel
end

function PANEL:IsExpanded()
    return self.isExpanded
end

function PANEL:DoClick()
    self:Expand()
end

function PANEL:Expand()
    self.isExpanded = not self.isExpanded
    self.StopChanging = true
    if self.isExpanded then
        local tall = self.BaseH + self.margin
        for _, v in ipairs(self.items) do
            if v and IsValid(v) then
                tall = tall + v:GetTall() + self.margin
            end
        end

        self:SizeTo(-1, tall, 0.2, 0)
    else
        self:SizeTo(-1, self.BaseH, 0.2, 0)
    end

    self.Canvas:InvalidateLayout(true)
end

function PANEL:OnSizeChanged(w, h)
    if not IsValid(self.Canvas) then return end
    self.Canvas:SetSize(w, h - self.BaseH)
end

function PANEL:Paint(w, h)
    self.bgCol = self.bgCol or Nexus:OffsetColor(Nexus.Colors.Background, 20, true)

    draw.RoundedBoxEx(Nexus:Scale(10), 0, 0, w, self.BaseH, self.bgCol, true, true, not self:IsExpanded() and true or false, not self:IsExpanded() and true or false)
    draw.SimpleText(self:GetText(), Nexus:GetFont(23, true), self.margin*2, self.BaseH/2, Nexus.Colors.Text, TEXT_ALIGN_LEFT, 1)

    local size = self.BaseH*.4
    Nexus:DrawImgur("2QGKAd6", w - size - self.margin*4, self.BaseH/2, size, size, Nexus.Colors.Text, self:IsExpanded() and 180 or 0)
end
vgui.Register("Nexus:Category", PANEL, "Nexus:Button")