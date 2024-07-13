local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(6)
    self.max = 100
    self.number = 0

    self.TextBox = self:Add("Nexus:TextEntry")
    self.TextBox:SetText(self.number)
    self.TextBox:SetNumeric(true)
    self.TextBox.OnChange = function(s)
        local value = s:GetText() == "" and 0 or s:GetText()
        value = tonumber(value) or 0
        self.SettingValue = value
        self.number = value
        self:OnChange(self.number)
    end
    self.TextBox.OnValueChange = self.TextBox.OnChange

    self.Slider = self:Add("DPanel")
    self.Slider:Dock(FILL)
    self.Slider.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:Scale(10), self.Slider.Button:GetX() + self.Slider.Button:GetWide()/2, h*.1, w - (self.Slider.Button:GetX() + self.Slider.Button:GetWide()/2), h*.8, Nexus.Colors.Secondary)

        draw.RoundedBox(Nexus:Scale(10), 0, h*.1, self.Slider.Button:GetX() + self.Slider.Button:GetWide()/2, h*.8+1, Nexus:OffsetColor(Nexus.Colors.Primary, 50))

        s.Wide = w
    end
    self.Slider.PerformLayout = function(s, w, h)
        self.Slider.Button:SetSize(Nexus:Scale(50), h)
    end

    self.Slider.Button = self.Slider:Add("DButton")
    self.Slider.Button:SetText("")
    self.Slider.Button.Paint = function(s, w, h)
        draw.RoundedBox(Nexus:Scale(10), 0, 0, Nexus:Scale(50), h, Nexus.Colors.Primary)

        local size = h*.5
        Nexus:DrawImgur("VcYwaxt", w/2, h/2, size, size, color_white, 90)

        if self.SettingValue then
            self.SettingValue = false

            s:SetX((self.Slider.Wide - w) / self.max * self.number)            
        end

        s.Wide = w
    end

    self.Slider.Button.OnMousePressed = function(s)
        s.IsPressed = true
    end

    self.Slider.Button.Think = function(s)
        self.Slider.Loaded = true

        if not s.IsPressed then return end
        if not input.IsMouseDown(MOUSE_LEFT) then s.IsPressed = false return end
        local x, y = self.Slider:LocalCursorPos()
        x = x - (s:GetWide()/2)
        x = math.Clamp(x, 0, self.Slider.Wide - s.Wide)
        self.TextBox:SetText(math.Round((s:GetX() * self.max) / (self.Slider.Wide - self.Slider.Button.Wide)))
        self.number = self.TextBox:GetText()
        self:OnChange(self.number)
        s:SetX(x)
    end
end

function PANEL:SetValue(num)
    self.TextBox:SetText(num)
    self.TextBox:OnChange()
end

function PANEL:SetMax(num)
    self.max = num
end

function PANEL:OnChange(value) end
function PANEL:Paint(w, h) end
function PANEL:PerformLayout(w, h)
    self.SettingValue = true
    self.TextBox:Dock(RIGHT)
    self.TextBox:DockMargin(self.margin, h*.1, 0, h*.1)
end

vgui.Register("Nexus:NumSlider", PANEL, "EditablePanel")