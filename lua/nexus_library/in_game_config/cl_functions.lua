concommand.Add("nexus_config", function()
    local frame = Nexus.UIBuilder:Start()
    :CreateFrame({
        id = "nexus_config_v2",
        title = "Nexus Addons",
        size = {w = Nexus:Scale(1000), h = Nexus:Scale(800)},
    })
    :AddIconButton({
        icon = "1U08KCx",
        DoClick = function()
            // v1 support
            local oldBuilder = Nexus.UIBuilder:Start()
            :CreateFrame({
                id = "nexus_config",
                title = "Nexus Addons (v1)",
                size = {w = Nexus:Scale(1000), h = Nexus:Scale(800)},
            })
    
            local panel = oldBuilder:GetLastPanel():Add("Nexus:IGC:Menu")
            panel:Dock(FILL)
        end
    })
    
    local panel = frame:GetLastPanel():Add("Nexus:Config:MenuV2")
    panel:Dock(FILL)
end)

// https://github.com/FPtje/DarkRP/blob/aec6a68c6b892c82ff5441c6ce41d4fd58e11798/gamemode/modules/base/cl_util.lua#L44
local function charWrap(text, remainingWidth, maxWidth)
    local totalWidth = 0

    text = text:gsub(".", function(char)
        totalWidth = totalWidth + surface.GetTextSize(char)

        -- Wrap around when the max width is reached
        if totalWidth >= remainingWidth then
            -- totalWidth needs to include the character width because it's inserted in a new line
            totalWidth = surface.GetTextSize(char)
            remainingWidth = maxWidth
            return "\n" .. char
        end

        return char
    end)

    return text, totalWidth
end

function Nexus:textWrap(text, font, maxWidth)
    local totalWidth = 0

    surface.SetFont(font)

    local spaceWidth = surface.GetTextSize(' ')
    text = text:gsub("(%s?[%S]+)", function(word)
            local char = string.sub(word, 1, 1)
            if char == "\n" or char == "\t" then
                totalWidth = 0
            end

            local wordlen = surface.GetTextSize(word)
            totalWidth = totalWidth + wordlen

            -- Wrap around when the max width is reached
            if wordlen >= maxWidth then -- Split the word if the word is too big
                local splitWord, splitPoint = charWrap(word, maxWidth - (totalWidth - wordlen), maxWidth)
                totalWidth = splitPoint
                return splitWord
            elseif totalWidth < maxWidth then
                return word
            end

            -- Split before the word
            if char == ' ' then
                totalWidth = wordlen - spaceWidth
                return '\n' .. string.sub(word, 2)
            end

            totalWidth = wordlen
            return '\n' .. word
        end)

    return text
end


Nexus.DataCache = Nexus.DataCache or {}
net.Receive("Nexus:IGC:v2:NetworkFull", function()
    local data = net.ReadUInt(32)
    data = net.ReadData(data)
    data = util.Decompress(data)
    data = util.JSONToTable(data)

    Nexus.DataCache = data

    if Nexus:GetValue("nexus-config-admins")[LocalPlayer():GetUserGroup()] and not Nexus:GetSetting("Nexus-v2-notification") then
        Nexus:SetSetting("Nexus-v2-notification", true)
        Nexus:Notification("Nexus", "Nexus Library has released a v2 update all your nexus addons")
    end
end)

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

function Nexus:GetValue(id)
    if Nexus.DataCache[id] then
        return Nexus.DataCache[id]
    end

    local info = GetElementInfo(id)
    return info and info.defaultValue or false
end

net.Receive("Nexus:IGC:V2:NetworkValue", function()
    local elementType = net.ReadString()
    if elementType == "button-row" then
        local id = net.ReadString()
        local value = net.ReadType()

        Nexus.DataCache[id] = value
        hook.Run("Nexus:IGC:ValueChanged", id, value)
    elseif elementType == "text-entry" then
        local id = net.ReadString()
        local value = net.ReadString()

        local info = GetElementInfo(id)
        if info.isNumeric then
            value = tonumber(value) or info.defaultValue
        end

        Nexus.DataCache[id] = value
        hook.Run("Nexus:IGC:ValueChanged", id, value)
    elseif elementType == "multi-text-entry" then
        local id = net.ReadString()

        local info = GetElementInfo(id)
        local data = {}
        for k, v in ipairs(info.entries) do
            data[v.id] = net.ReadString()
            if v.isNumeric then
                data[v.id] = tonumber(data[v.id]) or v.default
            end
        end

        Nexus.DataCache[id] = data
        hook.Run("Nexus:IGC:ValueChanged", id, data)
    elseif elementType == "key-table" then
        local id = net.ReadString()

        local isAdd = net.ReadBool()

        local info = GetElementInfo(id)
        local data = Nexus:GetValue(id)

        if isAdd then
            local value = net.ReadString()
            if info.isNumeric then
                value = tonumber(value) or nil
            end

            data[value] = isAdd and true or nil

            Nexus.DataCache[id] = data
            hook.Run("Nexus:IGC:ValueChanged", id, {isAdd = isAdd, value = value})
        else
            local int = net.ReadUInt(8)
            for i = 1, int do
                local value = net.ReadString()
                data[value] = nil
                data[tonumber(value) or value] = nil

                hook.Run("Nexus:IGC:ValueChanged", id, {isAdd = false, value = value})
            end

            Nexus.DataCache[id] = data
        end
    elseif elementType == "table" then
        local id = net.ReadString()
        local isAdd = net.ReadBool()
        local data = Nexus:GetValue(id)

        local info = GetElementInfo(id)
        if isAdd then
            local tbl = {
                m_id = net.ReadUInt(20),
            }
            for _, v in ipairs(info.values) do
                local value
                if v.type == "TextEntry" and v.isNumeric then
                    value = tonumber(net.ReadString())
                elseif v.type == "TextEntry" then
                    value = net.ReadString()
                elseif v.type == "ComboBox" then
                    value = net.ReadString()
                elseif v.type == "CheckBox" then
                    value = net.ReadBool()
                end

                tbl[v.id] = value
            end

            table.Add(data, {tbl})
            hook.Run("Nexus:IGC:ValueChanged", id, {isAdd = true, value = tbl})
        else
            local count = net.ReadUInt(8)
            for i = 1, count do
                local m_id = net.ReadUInt(20)
                for key, v in ipairs(data) do
                    if v["m_id"] == m_id then
                        table.remove(data, key)
                        break
                    end
                end

                hook.Run("Nexus:IGC:ValueChanged", id, {isAdd = false, id = m_id})
            end
        end

        Nexus.DataCache[id] = data
    end
end)