local dumps = {}

local oldChar
oldChar = hookfunction(string.char, function(...)
    local res = oldChar(...)
    if type(res) == "string" and #res > 20 then
        table.insert(dumps, res)
        writefile("str_" .. #dumps .. ".txt", res)
    end
    return res
end)

local oldLoad
oldLoad = hookfunction(loadstring, function(src, ...)
    if type(src) == "string" and #src > 50 then
        table.insert(dumps, src)
        writefile("dump_" .. #dumps .. ".txt", src)
    end
    return oldLoad(src, ...)
end)

local oldRand; oldRand = hookfunction(math.random, function(min, max)
    if checkcaller() then
	-- 🤣 BREAK HIS CHATGPT ENCODING 🤣 --
        return min
    end
    return oldRand(min, max)
end)

local oldReq; oldReq = hookfunction(request, function(tbl)
    if typeof(tbl) == "string" then
	-- 💀 FIX STUPID ERROR CAUSING SERVER HOP TO BREAK CAUSE THE OWNER IS A SKID AND DOESNT KNOW HOW TO USE THE REQUEST FUNCTION 💀 --
        return oldReq({ Url = tbl, Method = "GET" })
    end
    return oldReq(tbl)
end)

local oldHttp; oldHttp = hookfunction(game.HttpGet, function(self, url)
  	if url:match("api.dark") then
		-- 🔥 RETURN CORRECT RESPONSE 🔥 --
		return "v8Ya2UswRWfwQPSyvAj58VyOSmVF9mzApoR516PN91JkgJYBoSyHUaCpRPUA1rs5v9t1Ke16Elr8jgyvAj58VyE3kPVrKPd7u5rcAqARcHOTbD6UZIhATW1o7dov3IOm15cZVvVYsuCJLp8Upw6Vll9nuxapJ9y61VsNBXoXnrGt8e4MqcN26eu6P5TXTjRFlcnkxTQvH1OsRmTggCyt8sr"
  	end
	if url:match("newintestbeta") then
		-- 🏳️‍🌈 REDIRECT TO UI BACKUP 🏳️‍🌈 --
		url = "https://raw.githubusercontent.com/lukaweba19-cell/SoloX/refs/heads/main/ui.lua"
	end
  	return oldHttp(self, url)
end)

loadstring(game:HttpGet("https://raw.githubusercontent.com/lukaweba19-cell/SoloX/refs/heads/main/obfuscated.lua"))()
