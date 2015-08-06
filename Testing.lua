local info = debug.getinfo(1,'S');
local full_script_path = info.source
local script_path = full_script_path:sub(2,-5) -- remove "@" and "file extension" from file name
if reaper.GetOS() == "Win64" or reaper.GetOS() == "Win32" then
  S_slash = "\\"
else 
  S_slash = "/"
end
package.path = package.path .. ";" .. script_path:match("(.*"..S_slash..")") .. "?.lua"
--require("Setup Chord Track")
--require("Setup Bass Track")
require("Setup Drum Track")

