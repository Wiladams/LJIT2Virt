local ffi = require("ffi")

__VIR_LIBVIRT_H_INCLUDES__ = true;

local export = {}

-- Copy one dictionary into another
local function appendTable(dst, src)
	if not src then
		return dst;
	end

	for key, value in pairs(src) do 
		dst.key = value;
	end

	return dst;
end

-- Load all the definitions, while copying
-- dictionary values into export table
appendTable(export, require "libvirt-host");
appendTable(export, require "libvirt-domain");
appendTable(export, require "libvirt-domain-snapshot");
appendTable(export, require "libvirt-event");
appendTable(export, require "libvirt-interface");
appendTable(export, require "libvirt-network");
appendTable(export, require "libvirt-nodedev");
appendTable(export, require "libvirt-nwfilter");
appendTable(export, require "libvirt-secret");
appendTable(export, require "libvirt-storage");
appendTable(export, require "libvirt-stream");
appendTable(export, require "virterror");


if ffi.os == "Windows" then
	export.Lib = ffi.load("libvirt-0.dll")
elseif ffi.os == "Linux" then
	export.Lib = ffi.load("/usr/lib/libvirt.so")
elseif ffi.os == "OSX" then
	export.Lib = ffi.load("libvirt");
end

if not export.Lib then
    return nil, "could not load library, 'libvirt'"
end

local err = export.Lib.virInitialize();

if (err ~= 0) then
    return nil, "could not initialize libvirt";
end

return export

