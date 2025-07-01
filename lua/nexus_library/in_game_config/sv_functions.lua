local function GetElementInfo(configID)
    for _, addon in ipairs(Nexus.Addons or {}) do
        local data = addon.Elements
        for _, v in ipairs(data) do
            if v.data and v.data.id == configID then
                return v.data
            end
        end
    end

    return false
end

local fileCache = util.JSONToTable(file.Read("nexus_server_settings.txt", "DATA") or "") or {}
function Nexus:SetValue(id, value)
    fileCache[id] = value
    file.Write("nexus_server_settings.txt", util.TableToJSON(fileCache))
end

function Nexus:GetValue(addon, id)
    if not id then
        if fileCache[addon] then
            return fileCache[addon]
        end

        local info = GetElementInfo(addon)
        return info and info.defaultValue or false
    end

    // v1 support
    local data = file.Read("nexus_settings.txt", "DATA") or ""
    data = util.JSONToTable(data) or {}

    if data[addon] and data[addon][id] then
        return data[addon][id]
    end

    return Nexus.Config.Addons[addon].Options[id].default
end

util.AddNetworkString("Nexus:IGC:V2:UpdateValue")
util.AddNetworkString("Nexus:IGC:V2:NetworkValue")
net.Receive("Nexus:IGC:V2:UpdateValue", function(len, ply)
    local elementType = net.ReadString()

    if not Nexus:GetValue("nexus-config-admins")[ply:GetUserGroup()] and not Nexus.Admins[ply:GetUserGroup()] then Nexus:Notify(ply, 1, 3, "Incorrect Usergroup") return end

    if elementType == "button-row" then
        local configID = net.ReadString()
        local int = net.ReadUInt(4)

        local info = GetElementInfo(configID)
        local value = info.buttons[int].value
        Nexus:SetValue(configID, value)

        info.onChange(value)

        if not info.dontNetwork then
            net.Start("Nexus:IGC:V2:NetworkValue")
            net.WriteString(elementType)
            net.WriteString(configID)
            net.WriteType(value)
            net.Broadcast()
        end
    elseif elementType == "text-entry" then
        local configID = net.ReadString()
        local value = net.ReadString()

        local info = GetElementInfo(configID)
        if info.isNumeric then
            value = tonumber(value) or info.defaultValue
        end

        Nexus:SetValue(configID, value)

        info.onChange(value)

        if not info.dontNetwork then
            net.Start("Nexus:IGC:V2:NetworkValue")
            net.WriteString(elementType)
            net.WriteString(configID)
            net.WriteString(value)
            net.Broadcast()
        end
    elseif elementType == "multi-text-entry" then
        local configID = net.ReadString()

        local info = GetElementInfo(configID)
        local data = {}
        for k, v in ipairs(info.entries) do
            data[v.id] = net.ReadString()
            if v.isNumeric then
                data[v.id] = tonumber(data[v.id]) or v.default
            end
        end

        Nexus:SetValue(configID, data)

        info.onChange(data)

        if not info.dontNetwork then
            net.Start("Nexus:IGC:V2:NetworkValue")
            net.WriteString(elementType)
            net.WriteString(configID)
            for _, v in ipairs(info.entries) do
                net.WriteString(data[v.id])
            end
            net.Broadcast()
        end
    elseif elementType == "key-table" then
        local configID = net.ReadString()

        local isAdd = net.ReadBool()
        local info = GetElementInfo(configID)
        local data = Nexus:GetValue(configID)

        if isAdd then
            local value = net.ReadString()

            if info.isNumeric then
                value = tonumber(value) or nil
            end

            if data[value] then
                Nexus:Notify(ply, 1, 3, "Value already exists!")
                return
            end

            if not value then
                Nexus:Notify(ply, 1, 3, "Please enter a number.")
                return
            end

            data[value] = isAdd and true or nil

            Nexus:SetValue(configID, data)

            if not info.dontNetwork then
                net.Start("Nexus:IGC:V2:NetworkValue")
                net.WriteString(elementType)
                net.WriteString(configID)
                net.WriteBool(isAdd)
                net.WriteString(value)
                net.Broadcast()
            end
        else
            local int = net.ReadUInt(8)
            local tbl = {}
            for i = 1, int do
                local value = net.ReadString()

                table.insert(tbl, value)

                data[value] = nil
                data[tonumber(value) or value] = nil
            end

            Nexus:SetValue(configID, data)

            if not info.dontNetwork then
                net.Start("Nexus:IGC:V2:NetworkValue")
                net.WriteString(elementType)
                net.WriteString(configID)
                net.WriteBool(false)
                net.WriteUInt(#tbl, 8)
                for _, v in ipairs(tbl) do
                    net.WriteString(v)
                end
                net.Broadcast()
            end
        end

        info.onChange(data)
    elseif elementType == "table" then
        local configID = net.ReadString()

        local isAdd = net.ReadBool()
        local info = GetElementInfo(configID)

        local data = Nexus:GetValue(configID)
        if isAdd then
            local m_id = (Nexus:GetValue("Nexus:m_id") or 0)+1
            local tbl = {
                m_id = m_id,
            }

            Nexus:SetValue("Nexus:m_id", m_id)
            for _, v in ipairs(info.values) do
                local value
                if v.type == "TextEntry" and v.isNumeric then
                    value = tonumber(net.ReadString())

                    if not value then
                        Nexus:Notify(ply, 1, 3, "Fill out all fields.")
                        return
                    end
                elseif v.type == "TextEntry" then
                    value = net.ReadString()

                    if not value then
                        Nexus:Notify(ply, 1, 3, "Fill out all fields.")
                        return
                    end
                elseif v.type == "ComboBox" then
                    value = net.ReadString()

                    if not table.HasValue(isfunction(v.values) and v.values() or v.values, value) then
                        Nexus:Notify(ply, 1, 3, "Fill out all fields.")
                        return
                    end 
                elseif v.type == "CheckBox" then
                    value = net.ReadBool()
                end

                tbl[v.id] = value
            end

            if not info.dontNetwork then
                net.Start("Nexus:IGC:V2:NetworkValue")
                net.WriteString(elementType)
                net.WriteString(configID)
                net.WriteBool(true)
                net.WriteUInt(tbl["m_id"], 20)
                for k, v in ipairs(info.values) do
                    if v.type == "TextEntry" or v.type == "ComboBox" then
                        net.WriteString(tbl[v.id])
                    elseif v.type == "CheckBox" then
                        net.WriteBool(tbl[v.id])
                    end
                end
                net.Broadcast()
            end

            table.Add(data, {tbl})
        else
            local count = net.ReadUInt(8)
            local tbl = {}
            for i = 1, count do
                local id = net.ReadUInt(20)
                table.insert(tbl, id)
                for key, v in ipairs(data) do
                    if v["m_id"] == id then
                        table.remove(data, key)
                        break
                    end
                end
            end

            if not info.dontNetwork then
                net.Start("Nexus:IGC:V2:NetworkValue")
                net.WriteString(elementType)
                net.WriteString(configID)
                net.WriteBool(false)
                net.WriteUInt(count, 8)
                for _, v in ipairs(tbl) do
                    net.WriteUInt(v, 20)
                end
                net.Broadcast()
            end
        end

        Nexus:SetValue(configID, data)

        info.onChange(data)
    end

    Nexus:Notify(ply, 0, 3, "Success")
end)

util.AddNetworkString("Nexus:IGC:v2:NetworkFull")
hook.Add("Nexus:FullyLoaded", "Nexus:IGC:v2:Loaded", function(ply)
    local completeDATA = {}
    
    for id, value in pairs(fileCache) do
        local info = GetElementInfo(id)
        if info and not info.dontNetwork then
            completeDATA[id] = value
        end
    end

    local compressedData = util.Compress(util.TableToJSON(completeDATA))

    net.Start("Nexus:IGC:v2:NetworkFull")
    net.WriteUInt(#compressedData, 32)
    net.WriteData(compressedData, #compressedData)
    net.Send(ply)
end)