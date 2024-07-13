-- HUD Shit probably


local function DrawOverheadInfo(target, alpha)
	local pos = target:EyePos()

	pos.z = pos.z + 5

	local lp = LocalPlayer()

	local ang = (pos - lp:EyePos()):GetNormalized():Angle()

	--
	ang:RotateAroundAxis(ang:Up(), -106)
	ang:RotateAroundAxis(ang:Forward(), 90)

	ang[1] = 0
	ang[3] = 90

	pos = pos + ang:Forward() * (target.OffsetHorizontal3D2D or 8)

	cam.Start3D2D(pos, ang, 0.1)
	cam.IgnoreZ(true)
        draw.DrawText("Test", "Arial", 3, 3, 0)
	cam.IgnoreZ(false)
	cam.End3D2D()
end

hook.Add("PostDrawTranslucentRenderables", "GMedals_Draw", function(bDrawingDepth,bDrawingSkybox)
	if bDrawingDepth or bDrawingSkybox then
		return
	end

	local lp = LocalPlayer()
	local realTime = RealTime()
	local frameTime = FrameTime()

	for entTarg, shouldDraw in pairs(overheadEntCache) do
		if IsValid(entTarg) then
			local alpha =entTarg.overheadAlpha

			if lastEnt != entTarg then
				overheadEntCache[entTarg] = false
			end

			if alpha > 0 then
				if not entTarg:GetNoDraw() then
					if entTarg:IsPlayer() then
						DrawOverheadInfo(entTarg, alpha)
					end
				end
			end
		else
			overheadEntCache[entTarg] = nil
		end
	end
end)