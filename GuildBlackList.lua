local frame = CreateFrame("FRAME", "FooAddonFrame");
frame:RegisterEvent("IGNORELIST_UPDATE");
frame:RegisterEvent("CHAT_MSG_ADDON")
frame:RegisterEvent("ADDON_LOADED")
SLASH_GBL1 = "/gbl"


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

function array_sub(t1, t2)
    local t = {}
    for i = 1, #t1 do
      t[t1[i]] = true;
    end
    for i = #t2, 1, -1 do
      if t[t2[i]] then
        table.remove(t2, i);
      end
    end
  end

local function update_ignore_list()
    if IgnoreList == nil then
        IgnoreList = {}
    end

    local n_of_ignored = GetNumIgnores()
    for i=1, n_of_ignored do
        local ignored_name = GetIgnoreName(i)
        IgnoreList[ignored_name] = true;
    end
    local ignored_players={}
    for k,v in pairs(IgnoreList) do
        ignored_players[#ignored_players+1] = k
    end
    local msg = table.concat(ignored_players, "§")
    SendAddonMessage("GBL:Request", msg, "GUILD" );
end

local function handle_gbl_req (prefix, msg, dist, from)
    local rec_players = str_split(msg, "§")
    for key, ip in pairs(rec_players) do
        IgnoreList[ip] = true
    end
    local ignored_players={}
    for k,v in pairs(IgnoreList) do
        ignored_players[#ignored_players+1] = k
    end
    local msg_tosend = table.concat(ignored_players, "§")
    SendAddonMessage("GBL:Response", msg_tosend, "GUILD" );
end

local function handle_gbl_resp (prefix, msg, dist, from)
    local rec_players = str_split(msg, "§")
    for key, ip in pairs(rec_players) do
        IgnoreList[ip] = true
    end
end

local function get_missing_ignored_players()
    local bl_ignored={}
    for k,v in pairs(IgnoreList) do
        bl_ignored[#bl_ignored+1] = k
    end

    local game_ignore={}
    local n_of_ignored = GetNumIgnores()
    for i=1, n_of_ignored do
        local ignored_name = GetIgnoreName(i)
        game_ignore[#game_ignore+1] = ignored_name
    end
    array_sub(bl_ignored, game_ignore)
    return game_ignore
end

local function ignorelist_updated()
    new_ignored_players = get_missing_ignored_players()
    player_msg = table.concat(new_ignored_players, ", ")
    print("Players added to the guild black list: " .. player_msg)
    for i, ip in pairs(new_ignored_players) do
        IgnoreList[ip] = true
    end
    local msg_tosend = table.concat(new_ignored_players, "§")
    SendAddonMessage("GBL:Response", msg_tosend, "GUILD" );
end

local function eventHandler(self, event, ...)
    if event == "ADDON_LOADED" then
        update_ignore_list()
    elseif event == "CHAT_MSG_ADDON" then
        local prefix, msg, dist, from = ...
        if prefix == "GBL:Request" then
            handle_gbl_req(prefix, msg, dist, from)
        elseif prefix == "GBL:Response" then
            handle_gbl_resp (prefix, msg, dist, from)
        end
    elseif event == "IGNORELIST_UPDATE" then
        ignorelist_updated()
        print("ignorelist updated")
    end
end

local function gbl_handler(arg)
    if arg == "update" then
        update_ignore_list()
    elseif arg == "show" then
        for k,v in pairs(IgnoreList) do
            print(k)
        end
    end
    
end

frame:SetScript("OnEvent", eventHandler);
SlashCmdList["GBL"] = gbl_handler;