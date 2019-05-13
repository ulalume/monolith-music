local function checkOS ()
  local os
  local fh, _ = io.popen('uname','r')
  if fh then
    os = fh:read()
  end
  return os
end


local vra8n = {}
local controlType = require "music.control_type"

function vra8n:close()
  if not self.isConnecting then return end
  return self.out:close()
end

function vra8n:new(port, channel, baudrate)
  local this = setmetatable({port = port, channel = channel or 0, baudrate=baudrate or 38400, controlls={}}, {__index = self})

  function open()
    local osName = checkOS()
    if osName == 'Linux' then
      os.execute("stty -F "..this.port.." "..tostring(this.baudrate))
    elseif osName == 'Darwin' then
      -- can't work! mac's stty is buggy!
      os.execute("stty -f "..this.port.." "..tostring(this.baudrate))
    else
      os.execute("mode "..this.port..": baud="..tostring(this.baudrate).." parity=N data=8 stop=1")
    end
    this.out = assert(io.open(this.port, "w"), "The port "..this.port.." The baud "..this.baudrate.." could not be found.");
    io.output(this.out)
  end

  this.isConnecting, error = pcall(open)
  if error then print(error) end
  return this
end

function vra8n:sendMessage(a, b, c)
  if not self.isConnecting then return end
  --print(a,b,c)
  self.out:write(string.char(a+self.channel, b, c))
  self.out:flush()
end

function vra8n:noteOn(picth, velocity)
  self:sendMessage(144, picth, velocity)
end
function vra8n:noteOff(picth)
  self:sendMessage(128, picth, 64)
end
function vra8n:allNotesOff()
  self:sendMessage(176, 123, 0)
end
function vra8n:programChange(value)
  self:sendMessage(192, value, 0)
end
function vra8n:controlChangeAll(typeAndValueSet)
  for type, value in pairs(typeAndValueSet) do
    if controlType[type] ~= nil then
      self:controlChange(controlType[type], value)
    else
      print("みつからない control type.", type)
    end
  end
end
function vra8n:controlChange(type, value)
  self.controlls[type]=value
  self:sendMessage(176, type, value)
end

return vra8n
