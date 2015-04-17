local ffi = require("ffi")

local libvirt, err = require("libvirt")


if (not libvirt) then
	print(err);
	return nil;
end


local function printHostName(conn)
	local hostname = ffi.string(libvirt.Lib.virConnectGetHostname(conn));
	print("Host: ", hostname);
end

local function printCPUModelNames(conn, arch)
	local flags = 0;

	-- first find out how many there are
	local err = libvirt.Lib.virConnectGetCPUModelNames(conn,arch,nil,flags);

	print("Number of models: ", err)
	if err < 0 then
		return false
	end

	local voidPtr = ffi.new("void*[1]")
	err = libvirt.Lib.virConnectGetCPUModelNames(conn,arch,voidPtr,flags);
	if err < 0 then
		print("error with virConnectGetCPUModelNames: ", err)
		return false
	end

	local modelsPtr = ffi.cast("char ***", voidPtr)
	local modelsArray = modelsPtr[0]
	--local modelsArray = ffi.cast(ffi.typeof("char *[?]",err), voidPtr[0]);

	print("Models: ", modelsArray)
	
	for i=0,err-1 do
		local str = modelsArray[i]
		if str ~= nil then
			print("MODEL: ", ffi.string(str))
		end
	end

end

local function printCapabilities(conn)
	local caps = libvirt.Lib.virConnectGetCapabilities (conn);
	if caps ~= nil then
		print("CAPS: ",ffi.string(caps));
	end
	--free(caps);
end

local driveruri = "qemu:///system";
local conn = libvirt.Lib.virConnectOpenReadOnly(driveruri);

if not conn then
	print("No connection")
	return
end

printHostName(conn)
printCPUModelNames(conn, "x86_64")
printCapabilities(conn);

libvirt.Lib.virConnectClose(conn);

