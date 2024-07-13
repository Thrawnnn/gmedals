function Nexus:Scale(number)
    return math.max(number*(ScrH()/1440), 1)
end

Nexus.Frame = Nexus.Frame or nil
function Nexus:CreateFrame(title, w, h)
    if Nexus.Frame then Nexus.Frame:Remove() end
    local frame = vgui.Create("Nexus:Frame")
    frame:SetTitle(title)
    frame:SetSize(Nexus:Scale(w), Nexus:Scale(h))
    Nexus.Frame = frame
    return frame
end

local cache = {}
function Nexus:OffsetColor(col, num, dontAlpha)
    stringCol = col.r.." "..col.g.." "..col.b.." "..col.a.." "..num..tostring(dontAlpha)
    if cache[stringCol] then
        return cache[stringCol]
    end

    local newCol = Color(col.r + num, col.g + num, col.b + num, (dontAlpha and col.a or col.a + num))
    cache[stringCol] = newCol
    return newCol
end

function Nexus:Overhead(ent, str, override, secondaryStr)
    if ent:GetPos():Distance(LocalPlayer():GetPos()) > 200 then return end

    local pos = ent:GetPos()
    local angle = ent:GetAngles()
    local eyeAngle = LocalPlayer():EyeAngles()

    angle:RotateAroundAxis(angle:Forward(), 90)
    angle:RotateAroundAxis(angle:Right(), - 90)

    local font = Nexus:GetFont(18*5, true)
    surface.SetFont(font)
    local tw, th = surface.GetTextSize(str)
    local wide = tw + Nexus:Scale(150)
    local tall = th + Nexus:Scale(60)

    cam.Start3D2D(pos + ent:GetUp() * (override or 80), Angle(0, eyeAngle.y - 90, 90), 0.05)
        local y = secondaryStr and -tall*1.8 or 0 - (tall/2)
        draw.RoundedBox(10, -wide/2, y, wide, tall, Nexus.Colors.Background)
        draw.SimpleText(str, font, 0, y + tall/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if secondaryStr then
            local tw, th = surface.GetTextSize(secondaryStr)
            local wide = tw + Nexus:Scale(150)
            local tall = th + Nexus:Scale(60)
            draw.RoundedBox(10, -wide/2, y + tall + 10, wide, tall, Nexus.Colors.Background)
            draw.SimpleText(secondaryStr, font, 0, y + tall + 10 + tall/2, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
    cam.End3D2D()
end

hook.Add("InitPostEntity", "Nexus:RequestNetworks", function()
    net.Start("Nexus:RequestNetworks")
    net.SendToServer()
end)

net.Receive("Nexus:ChatMessage", function()
    local tbl = {}
    for i = 1, net.ReadUInt(4) do
        local val = net.ReadType()
        table.insert(tbl, val)
    end

    chat.AddText(unpack(tbl))
end)

net.Receive("Nexus:Notification", function()
    notification.AddLegacy(net.ReadString(), net.ReadUInt(2), net.ReadUInt(5))
end)

function Nexus:StringQuery(title, text, callback)
    callback = callback or function() end

    local frame = vgui.Create("Nexus:Frame")
    frame:SetSize(Nexus:Scale(350), Nexus:Scale(120))
    frame:Center()
    frame:SetTitle(title)
    frame:MakePopup()

    local margin = Nexus:Scale(10)
    local entry = frame:Add("Nexus:TextEntry")
    entry:Dock(FILL)
    entry:DockMargin(margin, margin, margin, margin)
    entry:SetPlaceholder(text)

    local button = frame:Add("Nexus:Button")
    button:Dock(RIGHT)
    button:DockMargin(0, margin, margin, margin)
    button:SetText("Ok")
    button.DoClick = function()
        callback(entry:GetValue())
        frame:Remove()
    end
end