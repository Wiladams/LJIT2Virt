local ffi = require("ffi")

local libvirt, err = require("libvirt")


if (not libvirt) then
	print(err);
	return nil;
end

local driveruri = "test:///default";
local conn = libvirt.Lib.virConnectOpenReadOnly(driveruri);


local hostname = ffi.string(libvirt.Lib.virConnectGetHostname(conn));
print("Host: ", hostname);

libvirt.Lib.virConnectClose(conn);

