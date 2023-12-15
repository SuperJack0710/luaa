local starterPlayer = game:GetService("StarterPlayer")
local starterPlayerScripts = starterPlayer:WaitForChild("StarterPlayerScripts")

local load_bytecode = require(starterPlayerScripts.Luaa.Dependencies.Rerubi)
local compile = require(starterPlayerScripts.Luaa.Dependencies.Yueliang)

return function(source: string, env: any)
env.script = nil	
env._G = {}
return load_bytecode(compile(source),env or getfenv(0))	
end
