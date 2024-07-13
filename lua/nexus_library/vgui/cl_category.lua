local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(6)
    self:SetTall(Nexus:Scale(60))

    self.isExpanded = false
    self.items = self.items or {}

    self.Canvas = self:Add("DPanel")
    self.Canvas.Paint = function(s, w, h)
        draw.RoundedBoxEx(Nexus:Scale(10), 0, 0, w, h, Nexus.Colors.Header, false, false, true, true)
    end
end

function PANEL:PerformLayout(w, h)
    self.Canvas:SetPos(0, Nexus:Scale(60))
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
    table.insert(self.items, panel)
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

    if self.isExpanded then
        local tall = Nexus:Scale(60) + self.margin
        for _, v in ipairs(self.items) do
            if v and IsValid(v) then
                tall = tall + v:GetTall() + self.margin
            end
        end

        self:SizeTo(-1, tall, 0.2, 0)
    else
        self:SizeTo(-1, Nexus:Scale(60), 0.2, 0)
    end

    self.Canvas:InvalidateLayout(true)
end

function PANEL:OnSizeChanged(w, h)
    if not IsValid(self.Canvas) then return end
    self.Canvas:SetSize(w, h - Nexus:Scale(60))
end

function PANEL:Paint(w, h)
    draw.RoundedBoxEx(Nexus:Scale(10), 0, 0, w, Nexus:Scale(60), Nexus.Colors.Header, true, true, not self:IsExpanded() and true or false, not self:IsExpanded() and true or false)
    draw.SimpleText(self:GetText(), Nexus:GetFont(23, true), self.margin*2, Nexus:Scale(60)/2, Nexus.Colors.Text, TEXT_ALIGN_LEFT, 1)

    local size = Nexus:Scale(60)*.4
    Nexus:DrawImgur("2QGKAd6", w - size - self.margin*4, Nexus:Scale(60)/2, size, size, Nexus.Colors.Text, self:IsExpanded() and 180 or 0)
end
vgui.Register("Nexus:Category", PANEL, "Nexus:Button")