-- HUD Shit probably


local function gMedal_Draw(target, alpha)
	local pos = target:EyePos()

	pos.z = pos.z + 5

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle() -- keep the angles correct

	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang:Forward() * (target.OffsetHorizontal3D2D or 8)

	cam.Start3D2D(pos, ang, 0.1)
		cam.IgnoreZ(true)
        		draw.DrawText("Test", "Arial", 3, 3, 0) -- just a test thing
		cam.IgnoreZ(false)
	cam.End3D2D()
end

hook.Add("PostDrawTranslucentRenderables", "GMedals_Draw", function(bDP, bDS)
	if bDP or bDS then
		return
	end

	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()
end)
