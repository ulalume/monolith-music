local midi
local requiredMidi = pcall(function ()
  midi = require "luamidi"
end)


local vra8n = {}
function vra8n.gc()
  if not requiredMidi then return end
  return midi.gc()
end

local controlType = require "music.control_type"

function vra8n:new(deviceNumber, channel)
  local out
  local name
  if requiredMidi then
    out = midi.openout(deviceNumber)
    name = midi.getOutPortName(deviceNumber)
  end
  return setmetatable({deviceNumber = deviceNumber, channel = channel or 0, out = out, name = name, controlls={}}, {__index = self})
end

function vra8n:sendMessage(a, b, c)
  if self.out == nil then return end

  -- 一回別のfileio読んどかないとおかしくなる
  -- love.filesystem.write( "_", "_" )
  -- print(a,b,c)
  self.out:sendMessage(a + self.channel, b, c)
end

-- pitch=鍵: 0-127、velocity=強さ: 0-127
function vra8n:noteOn(picth, velocity)
--print("noteOn!")
  self:sendMessage(144, picth, velocity)
end

function vra8n:noteOff(picth)
  self:sendMessage(128, picth, 64)
end

function vra8n:allNotesOff()
  self:sendMessage(176, 123, 0)
end

-- preset tone 0-7
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
