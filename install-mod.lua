local function CheckFileExist(filename)
    local file = io.open(filename, "r")
    if (file == nil) then
        print(string.format("Couldn't find \"%s\" generating new one.", filename))
        file = io.open(filename, "w")
    else
        print(string.format("Found \"%s\".", filename))
    end
    file:close()
end

local function checkForExistingMod(CONTENT, modid)
    
    return CONTENT:match(modid) == modid
end


local availableCommands

availableCommands = {
    ["install"] = {
        desc = "Installs mod for given mod-id.",
        f = function(FILEPATH, arg)
            local file = io.open(FILEPATH, "r+")
            local FILECONTENT = file:read("*all")
            for index=2,#arg do
                local modid = arg[index]
                if not checkForExistingMod(FILECONTENT, modid) then
                    print(string.format("Added mod %s", modid))
                    file:write(string.format("ServerModSetup(\"%s\")\n", modid))
                else
                    print(string.format("Mod %s already exist", modid))
                end
            end
            file:close()
        end
    },
    ["remove"] = {
        desc = "Removes a mod for given mod-id.",
        f = function(FILEPATH, arg)
            local FILECONTENT = file:read("*all")
            for index=2,#arg do
                local modid = arg[index]
                if checkForExistingMod(FILECONTENT, modid) then
                   FILECONTENT = string.gsub(FILECONTENT, "ServerModSetup%(\""..modid.."\"%)\n", "")
                   print(FILECONTENT)
                else
                    print(string.format("Mod %s doesn't exist", modid))
                end
                file:seek("set", 0)
            end
        end
    },
    ["help"] = {
        desc = "Shows all available commands.",
        f = function()
            print("Usage: install-mods COMMAND [MODID]...\n")
            for commandName,commandObject in pairs(availableCommands) do
                print(commandName, commandObject.desc)
            end
        end
    },
}

local function HandleArguments(FILEPATH, arg)
    if #arg == 0 then
        availableCommands["help"].f()
    else
        local command = arg[1]
        for commandName, commandObject in pairs(availableCommands) do
            if commandName == command then
                commandObject.f(FILEPATH, arg)
            end
        end
    end
end

local FILEPATH = "dedicated_server_mods_setup.lua"
CheckFileExist(FILEPATH)
local file = io.open(FILEPATH, "r+")
HandleArguments(FILEPATH, arg)
file:close()