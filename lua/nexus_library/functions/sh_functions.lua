local letters = "abcdefghijklmnopqrstuvwxyz"
function Nexus:GenerateID(amount)
    local str = ""
    for i = 1, amount do
        str = str..letters[math.random(1, #letters)]
    end
    return str
end