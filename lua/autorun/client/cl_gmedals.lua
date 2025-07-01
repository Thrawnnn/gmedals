Thrawn = Thrawn or {}

surface.CreateFont( "medalFont", {
	font = "Arial",
	size = 45,
} )

gMedals.NewConfig = ReloadConfig()

hook.Add("PostPlayerDraw", "gMedal_DrawMedal", function(ply)
    if (ply:GetPos():Distance(EyePos()) > 512) then return end

    local highestPriority = -1
    local medalToDraw = nil

    for medalEnum, medalData in ipairs(gMedals.NewConfig) do -- try NewConfig?
        if ply:HasMedal(gMedals.NewConfig[medalEnum].id) then
            medalData.priority = tonumber(medalData.priority)
            if medalData.priority > highestPriority then
                highestPriority = medalData.priority -- some priority logic
                medalToDraw = medalData -- New medals do not show up for some reason above your person, could this be an issue with priority??
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
            --print(medalToDraw.material)
            surface.SetMaterial(Material(medalToDraw.editorMat) or Material("achievement.png"))
            surface.DrawTexturedRect(-125, -250, medalToDraw.width or 250, medalToDraw.height or 250)
            draw.SimpleText(medalToDraw.desc, "medalFont", -textWidth / 2, 0, Color(255,255,255))
        cam.End3D2D()
    end
end)

function Thrawn.ScaleUI(num)
    return math.max(num * (ScrH() / 1080), 1)
end