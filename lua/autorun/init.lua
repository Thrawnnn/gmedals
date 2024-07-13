local gMedals = gMedals or {}


function gMedals.LoadFile(fileName)
	if (!fileName) then
		error("[gMedals Bootstrapper] File to include has no name!")
	end

	if fileName:find("sv_") then
		if (SERVER) then
			include(fileName)
		end
	elseif fileName:find("sh_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end
		include(fileName)
	elseif fileName:find("cl_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		else
			include(fileName)
		end
	elseif fileName:find("rq_") then
		if (SERVER) then
			AddCSLuaFile(fileName)
		end

		_G[string.sub(fileName, 26, string.len(fileName) - 4)] = include(fileName)
	end
end

function gMedals.includeDir(directory, hookMode, variable, uid)
	for k, v in ipairs(file.Find(directory.."/*.lua", "LUA")) do
        gMedals.LoadFile(directory.."/"..v)
    end
end

gMedals.includeDir("gMedals") 