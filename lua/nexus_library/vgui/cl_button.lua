local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
    self:SetText("")
    self:SetFont(Nexus:GetFont(20))
    self:SetTextColor(Nexus.Colors.Text)
    function self:SetText(str)
        self.Text = str
    end
    function self:GetText()
        return self.Text
    end
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:SetSecondary()
    self.IsSecondary = true
end

local black = Color(0, 0, 0, 100)
function PANEL:Paint(w, h)
    draw.RoundedBox(self.margin, 0, 0, w, h, self.col or self.IsSecondary and Nexus.Colors.Secondary or Nexus.Colors.Primary)
    draw.SimpleText(self.Text, self:GetFont(), w/2, h/2, self:GetTextColor(), 1, 1)

    if self:IsHovered() or self.Clicked then
        draw.RoundedBox(self.margin, 0, 0, w, h, black)
    end
end
vgui.Register("Nexus:Button", PANEL, "DButton")