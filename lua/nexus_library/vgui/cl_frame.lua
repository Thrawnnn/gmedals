local PANEL = {}
function PANEL:Init()
    if not IsValid(LocalPlayer()) then self:Remove() end
	self.margin = Nexus:Scale(10)
    self.round = Nexus:Scale(20)
    self.Draggable = true
    self.ExtraButtons = {}

    self.Header = self:Add("DPanel")
    self.Header:Dock(TOP)
    self.Header:SetTall(Nexus:Scale(50))
    self.Header.Paint = function(s, w, h)
        local height = Nexus:Scale(33)
        if self.icon then
            Nexus:DrawImgur(self.icon, Nexus:Scale(20), (h/2) - (height/2), height, height)
        end

        draw.SimpleText(self.Title, Nexus:GetFont(26, nil, true), self.icon and Nexus:Scale(30) + height or Nexus:Scale(20), h/2 + 1, Nexus.Colors.Text, 0, 1)
    end
    self.Header.PerformLayout = function(s, w, h)
        local height = Nexus:Scale(33)
        self.Header.CloseButton:SetSize(height, height)
        self.Header.CloseButton:SetPos(w - Nexus:Scale(20) - height, (h/2) - (height/2))

        local x = w - Nexus:Scale(20) - height - height - self.margin
        self.Header.SettingsIcon:SetSize(height, height)
        self.Header.SettingsIcon:SetPos(x, (h/2) - (height/2))

        for _, v in ipairs(self.ExtraButtons) do
            x = x - height - self.margin
            v:SetSize(height, height)
            v:SetPos(x, (h/2) - (height/2))              
        end

        self.Header.Cover:DockMargin(0, 0, w - self.Header.SettingsIcon:GetX() + self.margin, 0)
    end

    self.Header.CloseButton = self.Header:Add("Nexus:Button")
    self.Header.CloseButton:SetText("")
    self.Header.CloseButton:SetIcon("1Qx2b5j")
    self.Header.CloseButton:SetColor(Nexus.Colors.Red)
    self.Header.CloseButton.DoClick = function()
        self:Remove()
    end

    self.Header.SettingsIcon = self.Header:Add("Nexus:Button")
    self.Header.SettingsIcon:SetText("")
    self.Header.SettingsIcon:SetIcon("cAADBPb")
    self.Header.SettingsIcon:SetSecondary()
    self.Header.SettingsIcon.DoClick = function(s)
        local currentUI = Nexus.UIBuilder:Start()
        :CreateFrame({
            darken = true,
            size = {w = Nexus:Scale(300), h = Nexus:Scale(400)},
            title = "Settings",
            id = "Settings-Frame",
            reference = s,
        })
        
        :AddCheckbox({
            text = "Disable Gradients",
            stateChanged = function(state)
                Nexus:SetSetting("Nexus-Disable-Gradients", state)
            end,
            size = {h = Nexus:Scale(35)},
            state = Nexus:GetSetting("Nexus-Disable-Gradients", false),
        })

        :AddCheckbox({
            text = "Disable Animations",
            stateChanged = function(state)
                Nexus:SetSetting("Nexus-Disable-Animations", state)
            end,
            size = {h = Nexus:Scale(35)},
            state = Nexus:GetSetting("Nexus-Disable-Animations", false),
        })

        :AddText({text = "Current Theme:"})
        :AddComboBox({
            text = Nexus:GetSetting("Nexus-Theme", "Default")
        })
        for title, _ in pairs(Nexus.Themes) do
            currentUI:AddChoice(title, function()
                Nexus:SetSetting("Nexus-Theme", title)
                Nexus.Colors = Nexus.Themes[Nexus:GetSetting("Nexus-Theme", "Default")]
                self:Remove()
            end)
        end
        currentUI:AddText({text = "(reopen the ui on change)", align = 6})

        hook.Run("Nexus:AddSettings", currentUI)
    end

    self.Header.Cover = self.Header:Add("DPanel")
    self.Header.Cover:Dock(FILL)
    self.Header.Cover.OnMousePressed = function() self:OnMousePressed() end
    self.Header.Cover:SetCursor("sizeall")
    self.Header.Cover.Think = function()
        self:Think()
    end
    self.Header.Cover.Paint = nil

    self.Header.Cover.OnMouseReleased = function() self:OnMouseReleased() end

    self.Line = self:Add("DPanel")
    self.Line:Dock(TOP)
    self.Line:DockMargin(self.margin, 0, self.margin, 0)
    self.Line:SetTall(Nexus:Scale(3))
    self.Line:SetBackgroundColor(Nexus.Colors.Outline)
end

function PANEL:SetTitle(str, icon)
    self.Title = str
    self.icon = icon
end

function PANEL:HideCloseButton()
    self.Header.CloseButton:Hide()
end

function PANEL:SetNoRound()
    self.NoRound = true
end

function PANEL:Paint(w, h)
    self.col = self.col or table.Copy(Nexus.Colors.Secondary)
    self.col.a = 30
    Nexus:DrawRoundedGradient(0, 0, w, h, Nexus.Colors.Background, self.col, self.NoRound and 0 or self.round)

//    Nexus:Blur(self, 16, 16, 255, w,)
end

function PANEL:OnMousePressed()
	local screenX, screenY = self:LocalToScreen(0, 0)

	if (self.Draggable && gui.MouseY() < (screenY + self.Header:GetTall())) then
		self.Dragging = {gui.MouseX() - self.x, gui.MouseY() - self.y}
		self:MouseCapture(true)
		return
	end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Sizing = nil
	self:MouseCapture(false)
end

function PANEL:Think()
	local mousex = math.Clamp(gui.MouseX(), 1, ScrW() - 1)
	local mousey = math.Clamp(gui.MouseY(), 1, ScrH() - 1)

	if (self.Dragging) then
		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		x = math.Clamp(x, 0, ScrW() - self:GetWide())
		y = math.Clamp(y, 0, ScrH() - self:GetTall())

		self:SetPos(x, y)
	end

	local screenX, screenY = self:LocalToScreen(0, 0)
	if (self.Hovered && self.Draggable && mousey < (screenY + self.Header:GetTall())) then
		return
	end

	self:SetCursor("arrow")
	if (self.y < 0) then
		self:SetPos(self.x, 0)
	end
end

function PANEL:AddButton(icon, doClick)
    local button = self.Header:Add("Nexus:Button")
    button:SetText("")
    button:SetIcon(icon)
    button:SetSecondary()
    button.DoClick = function()
        doClick()
    end

    table.insert(self.ExtraButtons, button)
end
vgui.Register("Nexus:Frame", PANEL, "EditablePanel")

function Nexus.Example()
    local margin = Nexus:Scale(10)
    local currentUI = Nexus.UIBuilder:Start()
    :CreateFrame({
        size = {w = Nexus:Scale(750), h = Nexus:Scale(800)},
        title = "Custom UI",
        icon = "https://imgur.com/iG1M1Ze",
        id = "Unbox",
    })

    :AddScrollPanel()

    :AddNavbar()
        :AddChoice("Inventory", function() end)
        :AddChoice("Tab #2", function() end)
    :AddSpacer()

    :AddBlock()
    :AddButton({
        text = "#1",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Button awdad #2",
        DoClick = function(s) end,
        color = Nexus.Colors.Red,
    })

    :BackupParent()
    :AddBlock()
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })
    :AddButton({
        text = "Auto Scroller",
        DoClick = function(s) end,
    })

    :BackupParent()
    :AddButton({
        text = "Quick Bar Button",
        DoClick = function(s) end,
        font = Nexus:GetFont(30),
    })
    :AddSpacer()

    :AddBlock()    
    :AddCheckbox()
    :AddCheckbox({
        text = "Checkbox with a a label"
    })

    :BackupParent()
    :AddCheckbox({
        text = "Full blocked out CheckBox",
        stateChanged = function(state) end,
        size = {h = Nexus:Scale(40)},
    })
    :AddSpacer()

    :AddBlock()
    :AddComboBox()

    :BackupParent()
    :AddComboBox({text = "Pizza"})
        :AddChoice("Pizza", function() end)
        :AddChoice("Burger", function() end)
    :AddSpacer()

    :AddNumSlider({
        value = 10,
        onChange = function(val) print(val) end,
    })

    :AddCategory({title = "Hello!", size = {h = Nexus:Scale(60)}})
    :AddComboBox({text = "Pizza"})
        :AddChoice("Pizza", function() end)
        :AddChoice("Burger", function() end)
        :AddCheckbox({
            text = "Full blocked out CheckBox",
            stateChanged = function(state) end,
            size = {h = Nexus:Scale(40)},
        })
        :AddText({text = "Custom Label"})
        :AddNumSlider({
            onChange = function(val) print(val) end,
        })
        
    :AddNavbar()
    :AddChoice("Inventory", function() end)
    :AddChoice("Tab #2", function() end)
        :AddBlock():BackupParent()
    :AddBlock({dontDraw = true}):BackupParent()
    :AddBlock({dontDraw = true}):BackupParent()
    :AddBlock({dontDraw = true}):BackupParent()
    :AddBlock({dontDraw = true}):BackupParent()
    :AddBlock({dontDraw = true}):BackupParent()
    :AddBlock({dontDraw = true}):BackupParent()
end

concommand.Add("nexus_example", Nexus.Example)