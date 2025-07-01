local PANEL = {}
function PANEL:Init()
	self.margin = Nexus:Scale(10)
    self.margin = self.margin%2 ~= 0 and self.margin + 1 or self.margin

    self:SetText("")
    self:SetFont(Nexus:GetFont(20))
    self.col = Nexus.Colors.Primary

    function self:SetText(str)
        self.Text = str
    end
    function self:GetText()
        return self.Text
    end
    function self:SetTextColor(col)
        self.TextCol = col
    end
end

function PANEL:SetIcon(str)
    self.icon = str
end

function PANEL:SetColor(col)
    self.col = col
end

function PANEL:SetSecondary()
    self.col = Nexus.Colors.Secondary
end

local index = 1
function PANEL:DoClickInternal()
    self.Clicked = true
    self.ClickIndex = self.ClickIndex or index
    timer.Create(self.ClickIndex..":Nexus:Button", 0.05, 1, function()
        if not IsValid(self) then return end
        self.Clicked = false
    end)
    index = index + 1
end

function PANEL:AutoWide()
    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText())
    self:SetWide(tw + self.margin*2)
end

local black = Color(185, 185, 185, 20)
function PANEL:Paint(w, h)
    self.Height = self.Clicked and h*.8 or h

    if Nexus:GetSetting("Nexus-Disable-Animations", false) then
        self.Height = h
    end

    Nexus:DrawRoundedGradient(0, h - self.Height, w, h, self.col or self.IsSecondary and Nexus.Colors.Secondary or Nexus.Colors.Primary)

    local textCol = self.TextCol or Nexus:GetTextColor(self.col)
    draw.SimpleText(self.Text, self:GetFont(), w/2, h - (self.Height/2), textCol, 1, 1)

    if self.icon then
        local size = self.Height * 0.5
        local x, y = (w/2) - (size/2)
        Nexus:DrawImgur(self.icon, x, x, size, size, color_white)
    end

    if self:IsHovered() or self.Clicked then
        draw.RoundedBox(self.margin, 0, h - self.Height, w, self.Height, black)
    end
end
vgui.Register("Nexus:Button", PANEL, "DButton")