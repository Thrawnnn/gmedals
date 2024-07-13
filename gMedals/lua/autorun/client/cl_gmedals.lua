surface.CreateFont( "medalFont", {
	font = "Arial",
	size = 25,
} )

net.Receive("UpdateMedals", function()
    local ply = net.ReadPlayer()
    local medal = net.ReadInt(8)
    ply:GiveMedal(medal)
end)

net.Receive("RemoveMedals", function()
    local ply = net.ReadPlayer()
    local medal = net.ReadInt(8)
    ply:RemoveMedal(medal)
end)

net.Receive("SendMedals", function()
    local ply = net.ReadPlayer()
    local medal = net.ReadInt(8)
    ply:GiveMedal(medal)
    print("Broadcast received")
end)

net.Receive("SendMedalsRemove", function()
    local ply = net.ReadPlayer()
    local medal = net.ReadInt(8)
    ply:RemoveMedal(medal)
end)

hook.Add("PostPlayerDraw", "gMedal_DrawMedal", function(ply)
    if (ply:GetPos():Distance(EyePos()) > 512) then return end

    local highestPriority = -1
    local medalToDraw = nil

    for medalEnum, medalData in pairs(gMedals.Config) do
        if ply:HasMedal(medalEnum) then
            if medalData.priority > highestPriority then
                highestPriority = medalData.priority -- some priority logic gates
                medalToDraw = medalData
            end
        end
    end

    if medalToDraw then
        local xMod = 0
        local pos = ply:GetPos() + ply:GetUp() * (ply:OBBMaxs().z + 5)
        pos = pos + Vector(0, 0, math.cos(CurTime() / 2))

        local angle = (pos - EyePos()):GetNormalized():Angle()
        angle.y = angle.y + math.sin(CurTime()) * 10
        angle:RotateAroundAxis(angle:Up(), -90)
        angle:RotateAroundAxis(angle:Forward(), 90)

        cam.Start3D2D(pos, angle, 0.05)
        surface.SetFont("medalFont")
        local textWidth, textHeight = surface.GetTextSize(medalToDraw.desc)

        surface.SetDrawColor(medalToDraw.color or Color(0, 0, 0, 100))
        surface.SetMaterial(medalToDraw.material)
        surface.DrawTexturedRect(-125, -250, medalToDraw.width or 250, medalToDraw.height or 250)
        draw.SimpleText(medalToDraw.desc, "medalFont", -textWidth / 2, 0, Color(255,255,255))
        cam.End3D2D()
    end
end)
