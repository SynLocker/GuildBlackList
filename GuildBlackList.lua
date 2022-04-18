local frame = CreateFrame("FRAME", "FooAddonFrame");
frame:RegisterEvent("IGNORELIST_UPDATE");
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("ADDON_LOADED")

local function str_split (inputstr, sep)
    if sep == nil then
            sep = "%s"
    end
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
            table.insert(t, str)
    end
    return t
end

local function update_ignore_list()
    if IgnoreList == nil then
        IgnoreList = {}
    end

    local n_of_ignored = GetNumIgnores()
    for i=1, n_of_ignored do
        local ignored_name = GetIgnoreName(i)
        IgnoreList[ignored_name] = true;
        print("From ignore list: " .. ignored_name)
    end
    local ignored_players={}
    for k,v in pairs(IgnoreList) do
        ignored_players[#ignored_players+1] = k
        print("From global list: " .. k)
    end
    local msg = table.concat(ignored_players, "§")
    print("Msg: " .. msg)
    SendAddonMessage("GBL:Request", msg, "GUILD" );
end

local function handle_gbl_req (prefix, msg, dist, from)
    print(msg)
    local rec_players = str_split(msg, "§")
    for key, ip in pairs(rec_players) do
        IgnoreList[ip] = true
        print("player:" .. ip)
    end
    local ignored_players={}
    for k,v in pairs(IgnoreList) do
        ignored_players[#ignored_players+1] = k
    end
    local msg_tosend = table.concat(ignored_players, "§")
    print(msg_tosend)
    SendAddonMessage("GBL:Response", msg_tosend, "GUILD" );
end

local function handle_gbl_resp (prefix, msg, dist, from)
    local rec_players = str_split(msg, "§")
    for key, ip in pairs(rec_players) do
        IgnoreList[ip] = true
    end
    print("resp:" .. msg)
end

local function eventHandler(self, event, ...)
    print("GBL:" .. event)
    if event == "ADDON_LOADED" then
        print("ADDON LOADED")
        update_ignore_list()
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, dist, from = ...
        if prefix == "GBL:Request" then
            handle_gbl_req(prefix, msg, dist, from)
        elseif prefix == "GBL:Response" then
            handle_gbl_resp (prefix, msg, dist, from)
        end
    end
end

frame:SetScript("OnEvent", eventHandler);

--[[
    
    
    if prefix == "GBL:Request" then
        print(msg)
    elseif prefix == "GBL:Response" do
        print(msg)
    end
    
    
]]