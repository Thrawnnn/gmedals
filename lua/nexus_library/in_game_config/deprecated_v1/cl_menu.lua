local PANEL = {}
function PANEL:Init()
    self.margin = Nexus:Scale(10)
    self.Navbar = self:Add("Nexus:Navbar")
    self.Navbar:Dock(TOP)
    self.Navbar:DockMargin(self.margin, self.margin, self.margin, 0)
    for name, v in pairs(Nexus.Config.Addons) do
        self.Navbar:AddItem(name, function()
            self:SelectItem(name)
        end)
        self.Navbar:SelectItem(name)
    end
end

function PANEL:CreateLabel(str)
    local label = self.Scroll:Add("DLabel")
    label:Dock(TOP)
    label:DockMargin(self.margin*2, 0, 0, 0)
    label:SetText(str)
    label:SetFont(Nexus:GetFont(25))
    label:SizeToContents()
    return label
end

function PANEL:CreateLine()
    local space = self.Scroll:Add("Panel")
    space:Dock(TOP)
    space:SetTall(Nexus:Scale(20))
end

function PANEL:SelectItem(addon)
    if IsValid(self.Scroll) then self.Scroll:Remove() end

    self.Scroll = self:Add("Nexus:ScrollPanel")
    self.Scroll:Dock(FILL)
    self.Scroll:DockMargin(0, self.margin*2, self.margin*2, self.margin*2)

    local col = table.Copy(Nexus.Colors.Green)
    col.a = 255

    local formatted = {}
    for id, v in pairs(Nexus.Config.Addons[addon].Options) do
        v.id = id
        table.Add(formatted, {v})
    end

    table.SortByMember(formatted, "order", true)

    for _, v in ipairs(formatted) do
        local id = v.id
        self:CreateLabel(v.title)

        local panel = self.Scroll:Add("DPanel")
        panel:Dock(TOP)
        panel:DockMargin(self.margin*2, self.margin, self.margin, 0)
        panel:SetTall(Nexus:Scale(50))
        panel.Paint = nil

        if v.type == "buttonChips" then
            for _, data in ipairs(v.values) do
                local button = panel:Add("Nexus:Button")
                button:Dock(LEFT)
                button:DockMargin(0, 0, self.margin, 0)
                button:SetWide(Nexus:Scale(100))
                button:SetText(data)
                button.Think = function(s, w, h)
                    if Nexus.Config:GetValue(addon, id) == data then
                        button:SetColor(col)
                    else
                        button:SetColor(Nexus.Colors.Primary)
                    end
                end
                button.DoClick = function()
                    net.Start("Nexus:IGC:SelectOption")
                    net.WriteString(addon)
                    net.WriteString(id)
                    net.WriteString(data)
                    net.SendToServer()
                end
            end
        elseif v.type == "buttons" then
            for _, data in ipairs(v.values) do
                local button = panel:Add("Nexus:Button")
                button:Dock(LEFT)
                button:DockMargin(0, 0, self.margin, 0)
                button:SetText(data[1])
                button:SizeToContents()
                button:SetColor(data[2])
                surface.SetFont(button:GetFont())
                local tw, th = surface.GetTextSize(data[1])
                button:SetWide(tw + Nexus:Scale(20))

                button.DoClick = function()
                    net.Start("Nexus:IGC:SelectOption")
                    net.WriteString(addon)
                    net.WriteString(id)
                    net.WriteString(data[1])
                    net.SendToServer()
                end
            end
        elseif v.type == "multi-submit-hidden" then
            local toSubmit = {}
            for _, data in ipairs(v.values) do
                toSubmit[data] = ""

                local entry = panel:Add("Nexus:TextEntry")
                entry:Dock(LEFT)
                entry:DockMargin(0, 0, self.margin, 0)
                entry:SetWide(Nexus:Scale(120))
                entry:SetPlaceholder(data)
                entry.OnChange = function(s)
                    toSubmit[data] = s:GetText()
                end
            end

            local button = panel:Add("Nexus:Button")
            button:Dock(LEFT)
            button:DockMargin(0, 0, self.margin, 0)
            button:SetWide(Nexus:Scale(100))
            button:SetText("Save")
            button:SetColor(col)
            button.DoClick = function()
                net.Start("Nexus:IGC:SelectOption")
                net.WriteString(addon)
                net.WriteString(id)
                net.WriteString(util.TableToJSON(toSubmit))
                net.SendToServer()
            end
        elseif v.type == "number-input" then
            local entry = panel:Add("Nexus:TextEntry")
            entry:Dock(LEFT)
            entry:DockMargin(0, 0, self.margin, 0)
            entry:SetWide(Nexus:Scale(200))
            entry:SetNumeric(true)
            entry:SetText(Nexus.Config:GetValue(addon, id))

            local button = panel:Add("Nexus:Button")
            button:Dock(LEFT)
            button:DockMargin(0, 0, self.margin, 0)
            button:SetWide(Nexus:Scale(100))
            button:SetText("Save")
            button:SetColor(col)
            button.DoClick = function()
                net.Start("Nexus:IGC:SelectOption")
                net.WriteString(addon)
                net.WriteString(id)
                net.WriteString(entry:GetText())
                net.SendToServer()
            end
        elseif v.type == "string-input" then
            local entry = panel:Add("Nexus:TextEntry")
            entry:Dock(LEFT)
            entry:DockMargin(0, 0, self.margin, 0)
            entry:SetWide(Nexus:Scale(200))
            entry:SetText(Nexus.Config:GetValue(addon, id))

            local button = panel:Add("Nexus:Button")
            button:Dock(LEFT)
            button:DockMargin(0, 0, self.margin, 0)
            button:SetWide(Nexus:Scale(100))
            button:SetText("Save")
            button:SetColor(col)
            button.DoClick = function()
                net.Start("Nexus:IGC:SelectOption")
                net.WriteString(addon)
                net.WriteString(id)
                net.WriteString(entry:GetText())
                net.SendToServer()
            end
        elseif v.type == "table-input" then
            local data = Nexus.Config:GetValue(addon, id)
            data = util.JSONToTable(data)

            panel:SetTall(150)
            panel.Paint = function(s, w, h)
                draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Secondary)
                draw.RoundedBox(self.margin,1, 1, w-2, h-2, Nexus.Colors.Background)
            end

            local left = panel:Add("DPanel")
            left:Dock(LEFT)
            left:DockMargin(1 + self.margin, 1 + self.margin, 0, 1 + self.margin)
            left:SetWide(Nexus:Scale(200))
            left.Paint = nil

            local entry = left:Add("Nexus:TextEntry")
            entry:Dock(TOP)
            entry:DockMargin(0, 0, 0, 0)
            entry:SetTall(Nexus:Scale(50))
            entry:SetPlaceholder(v.values)

            local button = left:Add("Nexus:Button")
            button:Dock(TOP)
            button:DockMargin(0, self.margin, 0, 0)
            button:SetTall(Nexus:Scale(50))
            button:SetText("Add")
            button:SetColor(col)

            local buttons = {}
            button.DoClick = function()
                local str = entry:GetText()
                local data = Nexus.Config:GetValue(addon, id)
                data = util.JSONToTable(data)
                if data[str] then
                    return
                end
                net.Start("Nexus:IGC:SelectOption")
                net.WriteString(addon)
                net.WriteString(id)
                net.WriteString("add"..str)
                net.SendToServer()

                local button = panel:Add("Nexus:Button")
                button:SetText(str)
                button.DoClick = function()
                    net.Start("Nexus:IGC:SelectOption")
                    net.WriteString(addon)
                    net.WriteString(id)
                    net.WriteString("rem"..str)
                    net.SendToServer()
                    button:Remove()
                end
                table.insert(buttons, button)
            end

            for str, bool in pairs(data) do
                local button = panel:Add("Nexus:Button")
                button:SetText(str)
                button.DoClick = function()
                    net.Start("Nexus:IGC:SelectOption")
                    net.WriteString(addon)
                    net.WriteString(id)
                    net.WriteString("rem"..str)
                    net.SendToServer()
                    button:Remove()
                end
                table.insert(buttons, button)
            end

            panel.PerformLayout = function(s, w, h)
                local ox, y = left:GetWide() + self.margin + 1 + self.margin, 1 + self.margin
                local wide = (w - self.margin*5 - ox - 1) / 4
                local tall = (h - self.margin*4 - 2) / 5
                local x = ox
                for _, v in ipairs(buttons) do
                    if not IsValid(v) then continue end
                    v:SetSize(wide, tall)
                    v:SetPos(x, y)
                    x = x + wide + self.margin
                    if x + wide > w then
                        x = ox
                        y = y + tall + self.margin
                    end
                end
            end
        elseif v.type == "table-input-multi" then
            local data = Nexus.Config:GetValue(addon, id)
            data = util.JSONToTable(data)
            local tall = 0
            panel.Paint = function(s, w, h)
                draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Secondary)
                draw.RoundedBox(self.margin,1, 1, w-2, h-2, Nexus.Colors.Background)
            end

            local left = panel:Add("DPanel")
            left:Dock(LEFT)
            left:DockMargin(1 + self.margin, 1 + self.margin, 0, 1 + self.margin)
            left:SetWide(Nexus:Scale(200))
            left.Paint = nil

            local tbl = {}
            for k, v in ipairs(v.values) do
                if v[1] == "number" then
                    local entry = left:Add("Nexus:TextEntry")
                    entry:Dock(TOP)
                    entry:DockMargin(0, 0, 0, self.margin)
                    entry:SetTall(Nexus:Scale(50))
                    entry:SetPlaceholder(v[2])
                    entry:SetNumeric(true)
                    entry.OnChange = function(s)
                        local value = s:GetText()
                        value = value == "" and 0 or value
                        value = tonumber(value) or 0

                        tbl[k] = value
                    end
                    tbl[k] = 0
                    tall = tall + Nexus:Scale(50) + self.margin
                elseif v[1] == "bool" then
                    local bool = left:Add("Nexus:CheckBox")
                    bool:Dock(TOP)
                    bool:DockMargin(0, 0, 0, self.margin)
                    bool:SetText(v[2])
                    bool:SetTall(Nexus:Scale(30))
                    bool.OnStateChanged = function(s, val)
                        tbl[k] = val
                    end
                    tbl[k] = false
                    tall = tall + Nexus:Scale(30) + self.margin
                elseif v[1] == "comboBox" then
                    local comboBox = left:Add("Nexus:ComboBox")
                    comboBox:Dock(TOP)
                    comboBox:SetTall(Nexus:Scale(40))
                    comboBox:DockMargin(0, 0, 0, self.margin)
                    for _, v in ipairs(v[2]()) do
                        comboBox:AddChoice(v) 
                        tbl[k] = v
                        comboBox:SetText(v)
                    end
                    comboBox.OnSelect = function(s, index, text, data)
                        tbl[k] = text
                    end
                    tall = tall + Nexus:Scale(40) + self.margin
                elseif v[1] == "string" then
                    local entry = left:Add("Nexus:TextEntry")
                    entry:Dock(TOP)
                    entry:DockMargin(0, 0, 0, self.margin)
                    entry:SetTall(Nexus:Scale(50))
                    entry:SetPlaceholder(v[2])
                    entry:SetTall(Nexus:Scale(50))
                    entry.OnChange = function(s)
                        local value = s:GetText()
                        tbl[k] = value
                    end
                    tbl[k] = ""
                    tall = tall + Nexus:Scale(50) + self.margin
                end
            end

            panel:SetTall(math.max(Nexus:Scale(150), tall + Nexus:Scale(50) + self.margin*2))

            local scroll = panel:Add("Nexus:ScrollPanel")
            scroll:Dock(FILL)

            local button = left:Add("Nexus:Button")
            button:Dock(TOP)
            button:DockMargin(0, 0, 0, self.margin)
            button:SetTall(Nexus:Scale(50))
            button:SetText("Add")
            button:SetColor(col)

            local buttons = {}

            local function addButton(str, bool)
                local dat = util.JSONToTable(str)
                if not dat then return end
                local text = ""
                for _, v in ipairs(dat) do
                    text = text..tostring(v).." : "
                end
                text = string.Left(text, #text - 3)

                local button = scroll:Add("Nexus:Button")
                button:SetText(text)
                button.DoClick = function()
                    net.Start("Nexus:IGC:SelectOption")
                    net.WriteString(addon)
                    net.WriteString(id)
                    net.WriteString("rem"..str)
                    net.SendToServer()
                    button:Remove()
                end
                table.insert(buttons, button)
            end

            button.DoClick = function()
                local str = util.TableToJSON(tbl)
                local data = Nexus.Config:GetValue(addon, id)
                data = util.JSONToTable(data)
                if data[str] then
                    return
                end
                addButton(str, false)

                net.Start("Nexus:IGC:SelectOption")
                net.WriteString(addon)
                net.WriteString(id)
                net.WriteString("add"..str)
                net.SendToServer()
            end

            for str, bool in pairs(data) do
                addButton(str, bool)
            end

            local o = scroll.PerformLayout
            scroll.PerformLayout = function(s, w, h)
                o(s, w, h)

                local ox, y = self.margin, 1 + self.margin
                local wide = (w - self.margin*7 - ox - 1) / 6
                local tall = (h - self.margin*4 - 2) / 5

                if v.lines then
                    wide =  w - ox - 1 - self.margin*2
                    ox = self.margin
                end

                local x = ox
                for _, v in ipairs(buttons) do
                    if not IsValid(v) then continue end
                    v:SetSize(wide, tall)
                    v:SetPos(x, y)
                    x = x + wide + self.margin
                    if x + wide > w then
                        x = ox
                        y = y + tall + self.margin
                    end
                end
            end
        elseif v.type == "percentage-inputs" then
            local data = Nexus.Config:GetValue(addon, id)
            data = util.JSONToTable(data)
            local tall = 0
            panel.Paint = function(s, w, h)
                draw.RoundedBox(self.margin, 0, 0, w, h, Nexus.Colors.Secondary)
                draw.RoundedBox(self.margin,1, 1, w-2, h-2, Nexus.Colors.Background)
            end

            local left = panel:Add("DPanel")
            left:Dock(LEFT)
            left:DockMargin(1 + self.margin, 1 + self.margin, 0, 1 + self.margin)
            left:SetWide(Nexus:Scale(200))
            left.Paint = nil

            local tbl = {}
            for k, v in ipairs(v.values) do
                if v[1] == "number" then
                    local entry = left:Add("Nexus:TextEntry")
                    entry:Dock(TOP)
                    entry:DockMargin(0, 0, 0, self.margin)
                    entry:SetTall(Nexus:Scale(50))
                    entry:SetPlaceholder(v[2])
                    entry:SetNumeric(true)
                    entry.OnChange = function(s)
                        local value = s:GetText()
                        value = value == "" and 0 or value
                        value = tonumber(value) or 0

                        tbl[k] = value
                    end
                    tbl[k] = 0
                    tall = tall + Nexus:Scale(50) + self.margin
                elseif v[1] == "bool" then
                    local bool = left:Add("Nexus:CheckBox")
                    bool:Dock(TOP)
                    bool:DockMargin(0, 0, 0, self.margin)
                    bool:SetText(v[2])
                    bool:SetTall(Nexus:Scale(30))
                    bool.OnStateChanged = function(s, val)
                        tbl[k] = val
                    end
                    tbl[k] = false
                    tall = tall + Nexus:Scale(30) + self.margin
                elseif v[1] == "comboBox" then
                    local comboBox = left:Add("Nexus:ComboBox")
                    comboBox:Dock(TOP)
                    comboBox:SetTall(Nexus:Scale(40))
                    comboBox:DockMargin(0, 0, 0, self.margin)
                    for _, v in ipairs(v[2]()) do
                        comboBox:AddChoice(v) 
                        tbl[k] = v
                        comboBox:SetText(v)
                    end
                    comboBox.OnSelect = function(s, index, text, data)
                        tbl[k] = text
                    end
                    tall = tall + Nexus:Scale(40) + self.margin
                elseif v[1] == "string" then
                    local entry = left:Add("Nexus:TextEntry")
                    entry:Dock(TOP)
                    entry:DockMargin(0, 0, 0, self.margin)
                    entry:SetPlaceholder(v[2])
                    entry:SetTall(Nexus:Scale(50))
                    entry.OnChange = function(s)
                        local value = s:GetText()
                        tbl[k] = value
                    end
                    tbl[k] = ""
                    tall = tall + Nexus:Scale(50) + self.margin
                end
            end

            panel:SetTall(math.max(Nexus:Scale(150), tall + Nexus:Scale(50) + self.margin*2))

            local scroll = panel:Add("Nexus:ScrollPanel")
            scroll:Dock(FILL)

            local button = left:Add("Nexus:Button")
            button:Dock(TOP)
            button:DockMargin(0, 0, 0, self.margin)
            button:SetTall(Nexus:Scale(50))
            button:SetText("Add")
            button:SetColor(col)

            local buttons = {}

            local function addButton(str, bool)
                local dat = util.JSONToTable(str)
                if not dat then return end
                local text = math.Round(dat[3], 1).."% "..dat[1].." "..dat[2]

                local button = scroll:Add("Nexus:Button")
                button:SetText(text)
                button.DoClick = function()
                    net.Start("Nexus:IGC:SelectOption")
                    net.WriteString(addon)
                    net.WriteString(id)
                    net.WriteString("rem"..str)
                    net.SendToServer()
                    button:Remove()
                end
                table.insert(buttons, button)
            end

            button.DoClick = function()
                local str = util.TableToJSON(tbl)
                local data = Nexus.Config:GetValue(addon, id)
                data = util.JSONToTable(data)
                if data[str] then
                    return
                end
                addButton(str, false)

                net.Start("Nexus:IGC:SelectOption")
                net.WriteString(addon)
                net.WriteString(id)
                net.WriteString("add"..str)
                net.SendToServer()
            end

            for str, bool in pairs(data) do
                addButton(str, bool)
            end

            local o = scroll.PerformLayout
            scroll.PerformLayout = function(s, w, h)
                o(s, w, h)

                local ox, y = self.margin, 1 + self.margin
                local wide = (w - self.margin*6 - ox - 1) / 5
                local tall = (h - self.margin*4 - 2) / 5

                if v.lines then
                    wide =  (w - ox - 1 - self.margin*3)/3
                    ox = self.margin
                end

                local x = ox
                for _, v in ipairs(buttons) do
                    if not IsValid(v) then continue end
                    v:SetSize(wide, tall)
                    v:SetPos(x, y)
                    x = x + wide + self.margin
                    if x + wide > w then
                        x = ox
                        y = y + tall + self.margin
                    end
                end
            end
        end

        self:CreateLine()
    end

    hook.Run("Nexus:Config:AddonOpened", addon, self.Scroll)
end

vgui.Register("Nexus:IGC:Menu", PANEL, "EditablePanel")

net.Receive("Nexus:IGC:NetworkFull", function()
    local int = net.ReadUInt(32)
    local data = net.ReadData(int)
    data = util.Decompress(data)
    data = util.JSONToTable(data) or {}

    for addon, data in pairs(data) do
        for id, value in pairs(data) do
            Nexus.Config.Addons[addon].Options[id].default = value
        end
    end
end)

net.Receive("Nexus:IGC:UpdateValue", function()
    local addon, id, value = net.ReadString(), net.ReadString(), net.ReadString()
    Nexus.Config.Addons[addon].Options[id].default = value

    if Nexus.Config.Addons[addon].Options[id].resetMenu then
        if IsValid(Nexus.Config.Frame) then
            local value = Nexus.Config.Frame.panel.Scroll:GetVBar():GetScroll()
            local frame = vgui.Create("Nexus:Frame")
            frame:SetSize(Nexus:Scale(1000), Nexus:Scale(800))
            frame:SetTitle("Nexus Addons")
            frame:Center()
            frame:MakePopup()
            Nexus.Config.Frame = frame
        
            Nexus.Config.Frame.panel = frame:Add("Nexus:IGC:Menu")
            Nexus.Config.Frame.panel:Dock(FILL)

            timer.Simple(0.1, function()
                Nexus.Config.Frame.panel.Scroll:GetVBar():SetScroll(value)
            end)
        end
    end
end)