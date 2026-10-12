local oldRand; oldRand = hookfunction(math.random, function(min, max)
    if checkcaller() then
        return min
    end
    return oldRand(min, max)
end)

local oldReq; oldReq = hookfunction(request, function(tbl)
    if typeof(tbl) == "string" then
        return oldReq({ Url = tbl, Method = "GET" })
    end
    return oldReq(tbl)
end)

local oldHttp; oldHttp = hookfunction(game.HttpGet, function(self, url)
    if url:match("api.dark") then
        return "v8Ya2UswRWfwQPSyvAj58VyOSmVF9mzApoR516PN91JkgJYBoSyHUaCpRPUA1rs5v9t1Ke16Elr8jgyvAj58VyE3kPVrKPd7u5rcAqARcHOTbD6UZIhATW1o7dov3IOm15cZVvVYsuCJLp8Upw6Vll9nuxapJ9y61VsNBXoXnrGt8e4MqcN26eu6P5TXTjRFlcnkxTQvH1OsRmTggCyt8sr"
    end
    if url:match("newintestbeta") then
        url = "https://raw.githubusercontent.com/lukaweba19-cell/SoloX/refs/heads/main/ui.lua"
    end
    return oldHttp(self, url)
end)

-- Load UI and script
local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/lukaweba19-cell/SoloX/refs/heads/main/ui.lua"))()
local script = loadstring(game:HttpGet("https://raw.githubusercontent.com/lukaweba19-cell/SoloX/refs/heads/main/darkx.lua"))()

-- Hook UI to script
if script and script.SetUI then
    script.SetUI(ui)
end
