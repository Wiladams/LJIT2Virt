local ffi = require("ffi")

__VIR_LIBVIRT_H_INCLUDES__ = true;

local export = {}

require "libvirt-host"
require "libvirt-domain"
require "libvirt-domain-snapshot"
require "libvirt-event"
require "libvirt-interface"
require "libvirt-network"
require "libvirt-nodedev"
require "libvirt-nwfilter"
require "libvirt-secret"
require "libvirt-storage"
require "libvirt-stream"


if ffi.os == "Windows" then
	export.Lib = ffi.load("libvirt-0.dll")
elseif ffi.os == "Linux" then
	export.Lib = ffi.load("libvirt.so")
	local err = export.Lib.virInitialize();
	if (err ~= 0) then
		return nil, "could not initialize libvirt";
	end
end

return export

