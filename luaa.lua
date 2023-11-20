--By SuperJack0710
--Version 1.04

--Changelog (1.04)

--Added newsignal() global
--Added Signals
------------------

local file_types = {".drive", ".crefol", ".fol", ".scr", ".txt", ".shrtcut", ".mod"}
local player = game.Players.LocalPlayer
local replicatedStorage = game:GetService("ReplicatedStorage")
local httpService = game:GetService("HttpService")
local letters = {"a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","x","y","z","A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","1","2","3","4","5","6","7","8","9","0","*","#","@","!","%","^","&","(",")","?",">","/","<",".",",","[","]","{","}"}
local processThreads = {}
local processes = {}
local lastPID = 0

--Load modules
local ls = require(script.Loadstring)
local templates = {
driveFileTemplate = {[1] = {}, [2] = "Drive", [3] = ".drive", [4] = {}},
crefolFileTemplate = {[1] = {}, [2] = "CoreFolder", [3] = ".crefol",[4] = {}},
folFileTemplate = {[1] = {}, [2] = "Folder", [3] = ".fol", [4] = {}},
scrFileTemplate = {[1] = {}, [2] = "Script", [3] = ".scr", [4] = {[1] = ""}},
txtFileTemplate = {[1] = {}, [2] = "Text", [3] = ".txt", [4] = {[1] = ""}},    
shrtcutFileTemplate = {[1] = {}, [2] = "Shortcut", [3] = ".shrtcut", [4] = {[1] = nil, [2] = "rbxassetid://"}},
modFileTemplate = {[1] = {}, [2] = "Module",[3] = ".mod",[4] = {[1] = ""}}	
}

local function luaa_error(...)
error("[Luaa]: " .. ...)
end

local function luaa_warn(...)
warn("[Luaa]: " .. ...)
end

local function luaa_print(...)
print("[Luaa]: " .. ...)
end

local fileMetaTable = {
__index = function(t,k)
if k == "Name" then
return t[2]
else
if k == "FileType" then
return t[3]		
else --If no common value is being indexed then:	
if t[4][k] then
return t[4][k]
else
luaa_error("Cannot find " .. k .. " inside" .. t[3])				
end
	  end
   end
end,	
__newindex = function(t,k,v)
if k == "Name" then
t[2] = v
else		
if k == "FileType" then			
luaa_error("Attempt to set read-only value")
else				
if k == "Parent" then				
table.insert(v,t)					
	     end		
	  end			
   end
end,	
	
	
	
	

}
local folderMetaTable = {
__index = function(t,k)
if k == "Name" then
return t[2]
else
if k == "FileType" then
return t[3]		
else --If no common value is being indexed then:	
if t[4][k] then
return t[4][k]
else
if t[1][k] then			
return t[1][k]						
else			
luaa_error("Could not index")
                end
			end
		end
	end
end,	
__newindex = function(t,k,v)
if k == "Name" then
t[2] = v
else		
if k == "FileType" then			
luaa_error("Attempt to set read-only value")
else				
if k == "Parent" then				
table.insert(v[1],t)					
         end		
      end			
   end
end,	


	
}

local luaa = {}
luaa.Drive = {[1] = {}, [2] = "Drive", [3] = ".drive"}
luaa.libraries = {}
luaa.globals = {}
luaa.apis = {}

local drive = luaa.Drive

--File types

--.drive - Cannot be created. Represents the drive

--.crefol - Stands for core folder.

--.fol - Stands for folder. A way to organize files

--.scr - Script file

--.txt - Text file

--.shrtcut - Shortcut. Only renders whenever parented to Desktop. When clicked, it calls the function binded to .OnClick and passes the mouse's X and Y position.

----------------------------------------------------------------------------------------------

--Functions
local function RemoveMetaTables(t: any) --Call on FileSystem before saving to save space by removing metatables
    
local subTables = {} 
    
for k,v in pairs(t) do --Remove t's metatable and prepare to call removeMetaTables on sub tables
if type(v) == "table" then
setmetatable(v,nil)            
for k,val in v do            
if type(val) == "table" then    
table.insert(subTables,val)                
   end
end
else
continue
   end
end
for _, subTable in subTables do 
RemoveMetaTables(subTables)
   end
end

local function IsFileTypeAFolder(fileType: any)
if string.find(fileType,"fol") then
return true
else        
return false
   end
end

local function createFile(isFolder: boolean, fileType: string)
local file = templates[string.sub(fileType, 2, #fileType) .. "FileTemplate"]
function file:Delete()
self = nil
end	
function file:IsA(fileType: string)		
return self[3] == fileType
end
function file:Clone()
local clone = file
return clone
end
function file:SetMetadata(metadata: string)
luaa.libraries.filesystem.writemetadata(self, metadata)
end
function file:GetMetadata()
luaa.libraries.filesystem.readmetadata(self)
end	
	
if not isFolder then
setmetatable(file,fileMetaTable)    
file[1] = nil
else    
function file:GetChildren()
return file[1]
end
function file:WaitForChild(name: string)
repeat task.wait() until file[1][name]
return file[1][name]
end		
function file:FindFirstChild(name: string)
for i,v in file[1] do
if v[2] == name then				
return v			
   end
end			
luaa_error("Could not find child with name " .. name .. " under " .. file[2] .. "." )
end	
setmetatable(file,folderMetaTable)
end
return file
end

local function generateId()
local result = ""	
for i = 1, 100 do
result = result .. letters[math.random(1,#letters)]		
   end
return result	
end

luaa.Drive[1].Users = {}

--Create filesystem library and file system related globals
luaa.libraries.filesystem = {}

--Globals 
luaa.globals.loadfile = function(filePath: any)
	if not IsFileTypeAFolder(filePath[3]) then    
		local fileObject = {
			["children"] = filePath[1],    
			["name"] = filePath[2],
			["type"] = filePath[3],
			["data"] = filePath[4]
			["metadata"] == pcall(function() return filePath[5] end)
		}
		return fileObject
	else    
		luaa_error("Cannot load a folder.")
	end
end


--filesystem library.

function luaa.libraries.filesystem.create(fileType: string)

--Check if fileType is valid
if fileType == ".drive" then    
luaa_error("Cannot create file type.")
else
        
for i,v in file_types do
if i == #file_types then
luaa_error("Unknown file type.")
else
if v == fileType then            
break    
else                
continue
      end
   end    
end
local file = createFile(IsFileTypeAFolder(fileType),fileType)
file = templates[string.sub(fileType,2,9999999) .. "FileTemplate"]
return file
   end
end
function luaa.libraries.filesystem.delete(file: any)
if file[3] ~= ".drive" or ".crefol" then
file = nil
else
luaa_error("Cannot delete protected files.")    
   end    
end
function luaa.libraries.filesystem.isfolder(file: any)
if string.find(file[3],"fol") or string.find(file[3],"drive") then    
return true
else        
return false
   end
end
function luaa.libraries.filesystem.getsize(file: any)    
return string.len(file[4])    
end
function luaa.libraries.filesystem.isA(file: any, fileType: string)
for i,v in file_types do
if i == #file_types then
luaa_error("Unknown file type.")
else
if v == fileType then            
break    
else                
continue
    end
end    

end
if file[3] == fileType then
return true 
else
return false
   end
end
function luaa.libraries.filesystem.writemetadata(file: any, metadata: string)
if not file then	
luaa_error("No file found")
else		
if string.len(metadata)	> 300 then	
luaa_error("Metadata cannot be longer than 300 characters.")
else
file[5] = metadata
	  end
   end
end
function luaa.libraries.filesystem.readmetadata(file: any)
if file[5] == nil then
luaa_warn("No metadata associated with file.")		
return nil		
else	
return file[5]
   end
end
function luaa.libraries.filesystem.newtype(fileType: string, defaultName: string)
if fileType:sub(1,2) ~= "." then
local template = {[1] = {}, [2] = defaultName, [3] = fileType, [4] = {}}
table.insert(file_types, fileType)	
templates[fileType:sub(1,2) .. "FileTemplate"] = template	
else
luaa_error("File type string must start with .")
   end
end

--Clipboard API

luaa.globals.setclipboard = function(text: string)
player:SetAttribute("luaa/clipboard",text)
end
luaa.globals.getclipboard = function()
if not player:GetAttribute("luaa/clipboard")	 then
luaa_error("No text saved to clipboard yet")
else
return player:GetAttribute("luaa/clipboard")
   end
end

--users api
luaa.apis.users = {}
function luaa.apis.users.create(name: string, pass: string)
local file = luaa.libraries.filesystem.create(".fol")	
file.Name = name	
file.Parent = luaa.Drive.Users	
	luaa.libraries.filesystem.writemetadata(file, pass .. "|" .. name)

end
function luaa.apis.users.delete(name: string)
luaa.Drive.Users[1][name] = nil
end
function luaa.apis.users.iscredvalid(user: string, pass: string)
return luaa.Drive.Users[user]:GetMetadata():split("|")[2] == pass
end

--http library
luaa.libraries.http = {}
function luaa.libraries.http.postasync(url: string, data: any, headers: any)
if not (string.sub(url,1,5) == "http" or "https") then
luaa_error("URL must be HTTP or HTTPS.")
else
replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent:FireServer(url, data, headers,"POST")
return replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent.OnClientEvent:Wait()
   end
end
function luaa.libraries.http.getasync(url: string, headers: any)
if string.sub(url,1,5) ~= "http" or "https" then
luaa_error("URL must be HTTP or HTTPS.")
else
replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent:FireServer(url, nil, headers, "GET")
return replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent.OnClientEvent:Wait()
   end
end
function luaa.libraries.http.deleteasync(url: string,  headers: any)
if string.sub(url,1,5) ~= "http" or "https" then
luaa_error("URL must be HTTP or HTTPS.")
else
replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent:FireServer(url, nil, headers, "DELETE")
return replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent.OnClientEvent:Wait()
	end
end
function luaa.libraries.http.patchasync(url: string, data: any, headers: any)
if string.sub(url,1,5) ~= "http" or "https" then
luaa_error("URL must be HTTP or HTTPS.")
else
replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent:FireServer(url, data, headers,"PATCH")
return replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent.OnClientEvent:Wait()
	end
end
function luaa.libraries.http.putasync(url: string, data: any, headers: any)
if string.sub(url,1,5) ~= "http" or "https" then
luaa_error("URL must be HTTP or HTTPS.")
else
replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent:FireServer(url, data, headers,"PATCH")
return replicatedStorage.Events.Luaa.Libraries.http.HTTPRequestEvent.OnClientEvent:Wait()
	end
end
function luaa.libraries.http.urlencode(url: string)
return httpService:UrlEncode(url)
end
function luaa.libraries.http.jsonencode(luaTable: any)
return httpService:JSONEncode(luaTable)
end
function luaa.libraries.http.jsondecode(json: any)
return httpService:JSONDecode(json)
end
function luaa.libraries.http.generateguid(wrapincurlybraces: boolean)
return httpService:GenerateGUID(wrapincurlybraces)
end


--custom enums
luaa.globals.CEnums = {}

function luaa.globals.newenumtype(enumTypeName: string)
if luaa.globals.CEnums[enumTypeName] then	
luaa_error("A custom EnumType with the name " .. enumTypeName .. " already exists.")		
else		
luaa.globals.CEnums[enumTypeName] = {}
local enumType = luaa.globals.CEnums[enumTypeName]	
function enumType:GetEnumItems()
local enumItems = {}			
for i,v in enumType do	
if typeof(v) ~= "function" then				
table.insert(enumItems,v)
   end		
return enumItems				
end

return luaa.globals.CEnums[enumTypeName]
      end
function enumType:CreateEnumItem(enumItemName: string)	
if luaa.globals.CEnums[enumTypeName][enumItemName] then
luaa_error("A custom EnumItem with the name " .. enumItemName .. " already exists")	
else				
luaa.globals.CEnums[enumTypeName][enumItemName] = {}		
local enumItem = luaa.globals.CEnums[enumTypeName][enumItemName]
enumItem.Parent = enumType
enumItem.Name = enumItemName
	     end	
	  end
   end
end

--signals
function luaa.globals.newsignal(name: string)
local signal = {}
function signal:Connect(func: any)
local SignalConnection	= {}
SignalConnection.Listener = func
function SignalConnection:Disconnect()
self = nil	
   end
end
function signal:Fire(...)
for i,v in signal:GetConnections() do
v.Listener(...)			
      end
   end	
function signal:Once(func: any)
local connection
connection = signal:Connect(function()
func()
connection:Disconnect()		
end)
end
function signal:GetConnections()
local returnTable = {}
for i,v in signal do
if typeof(v) == "table" then
table.insert(returnTable,v)			
		  end
	   end
   return returnTable
   end
end

--process library
luaa.libraries.process = {}

function luaa.libraries.process.create(app: any)
local PID = lastPID + 1
lastPID = PID
	
local processObject = {}
processObject.ProcessID = PID
processObject.Source = app.Source
processObject.Running = true

processes[PID] = processObject
processThreads[PID] = coroutine.create(ls(processObject.Source))
end
function luaa.libraries.process.term(process: number | any)
if type(process) == "number" then
coroutine.close(processThreads[processes])
return
elseif type(process) == "table" then
coroutine.close(processThreads[process.ProcessID])
processes[process.ProcessID] = nil		
else	
error("process must be a process ID or a Process object.")		
   end
end
function luaa.libraries.process.stop(process: number | any)
if type(process) == "number" then
coroutine.yield(processThreads[process])
processes[process].Running = false		
elseif type(process) == "table" then
coroutine.yield(processThreads[process.ProcessId])
process.Running = false
else
error("process must be a process ID or a Process object.")
   end
end
function luaa.libraries.process.resume(process: number | any)
if type(process) == "number" then
coroutine.resume(processThreads[process])
processes[process].Running = true	
elseif type(process) == "table" then
coroutine.resume(processThreads[process.ProcessId])
process.Running = true
else
error("process must be a process ID or a Process object.")
   end	
end
function luaa.libraries.process.status(process: number | any)
if type(process) == "number" then
return coroutine.status(processThreads[process])		
elseif type(process) == "table" then
return coroutine.status(processThreads[process.ProcessID])
else
error("process must be a process ID or a Process object.")
   end
end

return luaa
