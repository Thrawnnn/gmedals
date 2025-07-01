function Nexus.PopoutMenu(s, tbl, onClicked, dontSort, spawnOnMouse, hide)
    tbl = tbl or {}

    if not dontSort then
        table.SortByMember(tbl, "text", true)
    end

    local margin = Nexus:Scale(10)
    margin = margin%2 == 0 and margin or margin + 1

    s.Panel = vgui.Create("DButton")
    s.Panel:SetSize(ScrW(), ScrH())
    s.Panel:MakePopup()
    s.Panel:SetText("")
    s.Panel.DoClick = function(ss)
        ss:Remove()
    end
    s.Panel.Paint = function(s, w, h)
        surface.SetDrawColor(0, 0, 0, hide and 0 or 210)
        surface.DrawRect(0, 0, w, h)
    end
    s.Panel.Think = function(ss)
        if not IsValid(s) then
            ss:Remove()
            return
        end

        ss:MoveToFront()
    end

    local x, y = s:LocalToScreen(0, s:GetTall() + margin)

    if spawnOnMouse then
        x, y = input.GetCursorPos()
        x = x + Nexus:Scale(10)
        y = y + Nexus:Scale(10)
    end

    local panel = s.Panel:Add("DPanel")
    panel:SetSize(Nexus:Scale(200), Nexus:Scale(300))
    panel:SetPos(x, y)
    panel.Paint = function(s, w, h)
        draw.RoundedBox(margin, 0, 0, w, h, Nexus:OffsetColor(Nexus.Colors.Background, 20, true))
    end

    local scroll = panel:Add("Nexus:ScrollPanel")
    scroll:Dock(FILL)

    surface.SetFont(Nexus:GetFont(20))

    local maxW = Nexus:Scale(150)

    local tall = 0
    for _, data in ipairs(tbl) do
        local v = data.text
        local button = scroll:Add("Nexus:Button")
        button:Dock(TOP)
        button:DockMargin(margin, margin, margin, 0)
        button:SetTall(Nexus:Scale(35))
        button:SetText(v)
        button:SetSecondary(true)
        button.DoClick = function()
            s.Panel:Remove()
            onClicked(v)
            data.func()
        end

        local tw, th = surface.GetTextSize(v)
        maxW = math.max(maxW, tw)
        tall = tall + Nexus:Scale(35) + margin
    end

    maxW = maxW + margin*4
    maxW = math.max(maxW, s:GetWide())

    panel:SetWide(maxW)
    panel:SetTall(math.min(tall, Nexus:Scale(300)) + margin)

    if spawnOnMouse then
        panel:SetWide(Nexus:Scale(200))
    end
    return maxW
end

local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
    self.margin = self.margin%2 == 0 and self.margin or self.margin + 1

	self:SetFont(Nexus:GetFont(20))
	self:SetTextColor(Color(120, 120, 120))
	self.Options = {}
    self.DontSort = false
end

function PANEL:DoClick()
	Nexus.PopoutMenu(self, self.Options, function(val)
		self.Selected = val
		self:SetText(val)
		self:OnSelect(false, val)
	end, self.DontSort)
end

function PANEL:SetValue(str)
    self:SetText(str)
end

function PANEL:GetValue()
    return self:GetText()
end

function PANEL:SetDontSort(bool)
    self.DontSort = bool
end

function PANEL:OnSelect(index, value)
end

function PANEL:AddChoice(a, func)
    func = func or function() end

	table.Add(self.Options, {{text = a, func = func}})
end

function PANEL:AutoWide()
    surface.SetFont(self:GetFont())
    local tw, th = surface.GetTextSize(self:GetText().."•")
    self:SetWide(tw + 4 + self.margin*3)
end

function PANEL:Paint(w, h)
    Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Primary)

	draw.RoundedBox(self.margin, 2, 2, w-4, h-4, Nexus.Colors.Background)
	draw.SimpleText(self:GetText(), self:GetFont(), self.margin+4, h/2, Nexus.Colors.Text, 0, 1)
	draw.SimpleText("•", self:GetFont(), w - self.margin - 4, h/2, Nexus.Colors.Text, TEXT_ALIGN_RIGHT, 1)
end
vgui.Register("Nexus:ComboBox", PANEL, "Nexus:Button")