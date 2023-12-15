--[[

    Keybinder Keybinder v4
    Made by KashTheKing
    
]]--

local function luaa_assert(v: a, ...)
    assert(v,"[Luaa]:" .. ...)
end

local uis = game:GetService("UserInputService")
local cas = game:GetService("ContextActionService")
local gui = game:GetService("GuiService")
local lastInput = nil

local Keybinder = {}
Keybinder.PressBindings = {}
Keybinder.ReleaseBindings = {}
Keybinder.ComboBindings = {}
Keybinder.InputTypeBeganBindings = {}
Keybinder.InputTypeEndedBindings = {}
Keybinder.InputsPressed = {}

Keybinder.TouchEnabled = uis.TouchEnabled
Keybinder.KeyboardEnabled = uis.KeyboardEnabled
Keybinder.MouseEnabled = uis.MouseEnabled
Keybinder.GamepadEnabled = uis.GamepadEnabled
Keybinder.IsConsole = gui:IsTenFootInterface()

export type TouchButtonInfo = {
    Title:string,
    Description:string,
    Image:string,
    Position:UDim2
}

function Keybinder.SetMouseBehavior(MouseBehavior:Enum.MouseBehavior)
    luaa_assert(typeof(MouseBehavior)=="EnumItem","Invalid Enum, Expected MouseBehavior")
    uis.MouseBehavior = MouseBehavior
end

function Keybinder.GetPlatform()
    if Keybinder.KeyboardEnabled and Keybinder.MouseEnabled then
        return "Desktop"
    elseif Keybinder.TouchEnabled and not Keybinder.MouseEnabled then
        return "Mobile"
    elseif Keybinder.GamepadEnabled then
        return "Console"
    end
end

function Keybinder.BindContextAction(name:string,callback:any,touchButtonInfo:TouchButtonInfo?)
    luaa_assert(typeof(name)=="string","A name is required")
    luaa_assert(typeof(callback) == "function", "A callback function is required")

    cas:BindAction(name,callback,touchButtonInfo~=nil)

    if touchButtonInfo then
        if touchButtonInfo.Title then
            cas:SetTitle(name,touchButtonInfo.Title)
        end

        if touchButtonInfo.Description then
            cas:SetDescription(touchButtonInfo.Description)
        end

        if touchButtonInfo.Image then
            cas:SetImage(name,touchButtonInfo.Image)
        end

        if touchButtonInfo.Position then
            cas:SetPosition(name,touchButtonInfo.Position)
        end
    end
end

function Keybinder.UnbindContextAction(name:string)
    luaa_assert(typeof(name)=="string","A name is required")
    cas:UnbindAction(name)
end

function Keybinder.BindInputTypeBegan(inputType:Enum.UserInputType,name:string,callback:any)
    luaa_assert(inputType,"An input type is required")
    luaa_assert(typeof(callback) == "function", "A callback function is required")
    luaa_assert(typeof(name)=="string","A name is required")

    Keybinder.InputTypeBeganBindings[inputType] = Keybinder.InputTypeBeganBindings[inputType] or {}
    Keybinder.InputTypeBeganBindings[inputType][name] = callback
end

function Keybinder.BindInputTypeEnded(inputType:Enum.UserInputType,name:string,callback:any)
    luaa_assert(inputType,"An input type is required")
    luaa_assert(typeof(callback) == "function", "A callback function is required")
    luaa_assert(typeof(name)=="string","A name is required")

    Keybinder.InputTypeEndedBindings[inputType] = Keybinder.InputTypeEndedBindings[inputType] or {}
    Keybinder.InputTypeEndedBindings[inputType][name] = callback
end

function Keybinder.BindPress(key:Enum.KeyCode,name:string,callback:any)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(callback) == "function", "A callback function is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.PressBindings[key] = Keybinder.PressBindings[key] or {}
    Keybinder.PressBindings[key][name] = callback
end

function Keybinder.BindRelease(key:Enum.KeyCode,name:string,callback:any)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(callback) == "function", "A callback function is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.ReleaseBindings[key] = Keybinder.ReleaseBindings[key] or {}
    Keybinder.ReleaseBindings[key][name] = callback
end

function Keybinder.Bind(...)
    Keybinder.BindPress(...)
    Keybinder.BindRelease(...)
end

function Keybinder.BindKeyCombo(key:Enum.KeyCode,name:string,presses:number,decay:number,callback:any)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(name)=="string","A name is required")
    luaa_assert(presses,"A max presses value is required")
    luaa_assert(decay,"A decay value is required")
    luaa_assert(typeof(callback) == "function","A callback function is required")
    Keybinder.ComboBindings[key] = Keybinder.ComboBindings[key] or {}
    Keybinder.ComboBindings[key][name] = {Callback=callback,Decay=decay,MaxPresses=presses,Presses=0}
end

function Keybinder.UnbindPress(key:Enum.KeyCode,name:string)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.PressBindings[key][name] = nil
end

function Keybinder.UnbindRelease(key:Enum.KeyCode,name:string)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.ReleaseBindings[key][name] = nil
end

function Keybinder.Unbind(key:Enum.KeyCode,name:string)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.PressBindings[key][name] = nil
    Keybinder.ReleaseBindings[key][name] = nil
end

function Keybinder.UnbindKeyCombo(key:Enum.KeyCode,name:string)
    luaa_assert(key,"A Keycode is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.ComboBindings[key][name] = nil
end

function Keybinder.UnbindInputTypeBegan(input:Enum.UserInputType,name:string)
    luaa_assert(input,"An Input Type is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.InputTypeBeganBindings[input][name] = nil
end

function Keybinder.UnbindInputTypeEnded(input:Enum.UserInputType,name:string)
    luaa_assert(input,"An Input Type is required")
    luaa_assert(typeof(name)=="string","A name is required")
    Keybinder.InputTypeEndedBindings[input][name] = nil
end

function Keybinder.IsKeyPressed(key:Enum.KeyCode)
    luaa_assert(typeof(key)=="EnumItem","Invalid Enum, Expected KeyCode")

    return uis:IsKeyDown(key)
end

function Keybinder.IsGamepadPressed(button:Enum.KeyCode,Gamepad:Enum.UserInputType)
    luaa_assert(typeof(button)=="EnumItem","Invalid Enum, Expected KeyCode")
    luaa_assert(typeof(Gamepad)=="EnumItem","Invalid Enum, Expected UserInputType")
    luaa_assert(tostring(Gamepad):match("Gamepad"),"Invalid UserInputType, Expected a Gamepad; Enum.UserInputType.Gamepad1")

    if not uis:GetGamepadConnected(Gamepad) then return false end

    local isButtonPressed = false

    local state = uis:GetGamepadState(Gamepad)

    for _, input in pairs(state) do
        if input.KeyCode == button and input.UserInputState == Enum.UserInputState.Begin then
            isButtonPressed = true
            break
        end
    end

    return isButtonPressed
end

function Keybinder.IsInputTypeActive(input:Enum.UserInputType)
    luaa_assert(typeof(input)=="EnumItem","Invalid Enum, Expected UserInputType")

    for _,v in Keybinder.InputsPressed do
        if v.UserInputType == input then
            return true
        end
    end
end

function Keybinder.WaitForKey(key:Enum.KeyCode?,Timeout: number?)
    luaa_assert(typeof(key)=="EnumItem","Invalid Enum, Expected KeyCode")

    local inputGiven = nil
    local start = tick()

    repeat
        local input = uis.InputBegan:Wait()

        if not key or input.KeyCode == key then
            inputGiven = input
        end

    until inputGiven or (Timeout and tick() - start >= Timeout) 
end

function Keybinder.WaitForInput(inputType:Enum.UserInputType?,Timeout: number?)
    luaa_assert(typeof(inputType)=="EnumItem","Invalid Enum, Expected UserInputType")
    local inputGiven = nil
    local start = tick()

    repeat
        local input = uis.InputBegan:Wait()

        if not inputType or input.UserInputType == inputType then
            inputGiven = input
        end

    until inputGiven or (Timeout and tick() - start >= Timeout) 
end

function Keybinder._InputBegan(input:InputObject,isTyping:boolean)
    local inputsIndex = table.find(Keybinder.InputsPressed,input)
    if inputsIndex then
        table.remove(Keybinder.InputsPressed,inputsIndex)
    end
    table.insert(Keybinder.InputsPressed,input)

    if not isTyping then
        local bindings = Keybinder.PressBindings[input.KeyCode]

        if bindings then
            for i,callback in pairs(bindings) do
                task.spawn(callback)
            end
        end

        bindings = Keybinder.ComboBindings[input.KeyCode]

        if bindings then
            for name,binding in pairs(bindings) do                    
                binding.Presses += 1
                if binding.Presses >= binding.MaxPresses then
                    task.spawn(binding.Callback)
                    binding.Presses = 0
                else
                    task.delay(binding.Decay,function()
                        if binding.Presses > 0 then
                            binding.Presses -= 1
                        end
                    end)
                end
            end
        end

        bindings = Keybinder.InputTypeBeganBindings[input.UserInputType]

        if bindings then
            for name,callback in bindings do
                task.spawn(callback)
            end
        end
    end
end

function Keybinder._InputEnded(input:InputObject,isTyping:boolean) 
    local inputsIndex = table.find(Keybinder.InputsPressed,input)
    if inputsIndex then
        table.remove(Keybinder.InputsPressed,inputsIndex)
    end

    if not isTyping then
        local bindings = Keybinder.ReleaseBindings[input.KeyCode]

        if bindings then
            for i,callback in pairs(bindings) do
                task.spawn(callback)
            end
        end

        bindings = Keybinder.InputTypeEndedBindings[input.UserInputType]

        if bindings then
            for name,callback in bindings do
                task.spawn(callback)
            end
        end
    end
end
function Keybinder.GetLastInput()
return lastInput
end
	
uis.InputBegan:Connect(function(InputObject)
InputObject.KeyCode = lastInput
end)





Keybinder.InputBeganSignal = uis.InputBegan
Keybinder.InputEndedSignal = uis.InputEnded
Keybinder.InputBeganConnection = Keybinder.InputBeganSignal:Connect(Keybinder._InputBegan)
Keybinder.InputEndedConnection = Keybinder.InputEndedSignal:Connect(Keybinder._InputEnded)

return Keybinder
