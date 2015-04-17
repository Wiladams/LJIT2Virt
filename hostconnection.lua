-- hostconnection.lua
local ffi = require("ffi")
local libvirt, err = require("libvirt")


if (not libvirt) then
	print(err);
	return nil;
end


local Connection = {}
setmetatable(Connection, {
	__call = function(self, ...)
		return self:create(...)
	end,
})

local Connection_mt = {
	__index = Connection
}

function Connection.init(self, rawhandle)
	local obj = {
		Handle = rawhandle	-- should be stored in a smart pointer
	}
	setmetatable(obj, Connection_mt)
	
	return obj;
end


function Connection.create(self, driveruri)
	print("Connection.create: ", driveruri)

	driveruri = driveruri or "test:///default";

	local conn = libvirt.Lib.virConnectOpenReadOnly(driveruri);
	if not conn == nil then
		return nil
	end

	return Connection:init(conn)
end

function Connection.getHostName(self)
	return ffi.string(libvirt.Lib.virConnectGetHostname(self.Handle));
end

-- an iterator of cpu models for the architecture
function Connection.cpuModelNames(self, arch)
	arch = arch or "x86_64"

	local modelsArray = ffi.new(ffi.typeof("char **[1]"))
	local nModels = libvirt.Lib.virConnectGetCPUModelNames(self.Handle,arch,modelsArray,0);

	local idx = -1;
	local function closure()
		idx = idx + 1;
		if idx >= nModels then
			return nil;
		end

		return ffi.string(modelsArray[0][idx])
	end

	return closure;
end

function Connection.getCapabilities(self)
	local capsPtr = libvirt.Lib.virConnectGetCapabilities (self.Handle);
	local capsStr = nil;

	if capsPtr ~= nil then
		capsStr = ffi.string(capsPtr);
	--free(caps);
	end

	return capsStr;
end

function Connection.isAlive(self)
	return libvirt.Lib.virConnectIsAlive(self.Handle) == 1;
end

function Connection.isSecure(self)
	return libvirt.Lib.virConnectIsSecure(self.Handle) == 1;
end

function Connection.isEncrypted(self)
	return libvirt.Lib.virConnectIsEncrypted(self.Handle) == 1;
end





--[[
int virNodeGetMemoryParameters(virConnectPtr conn,
int virNodeSetMemoryParameters(virConnectPtr conn,
int virNodeGetCPUMap(virConnectPtr conn,

int                     virConnectRef           (virConnectPtr conn);
int                     virConnectClose         (virConnectPtr conn);
const char *            virConnectGetType       (virConnectPtr conn);
int                     virConnectGetVersion    (virConnectPtr conn,
                                                 unsigned long *hvVer);
int                     virConnectGetLibVersion (virConnectPtr conn,
                                                 unsigned long *libVer);
char *                  virConnectGetHostname   (virConnectPtr conn);
char *                  virConnectGetURI        (virConnectPtr conn);
char *                  virConnectGetSysinfo    (virConnectPtr conn,
                                                 unsigned int flags);

int virConnectSetKeepAlive(virConnectPtr conn,
                           int interval,
                           unsigned int count);
int virConnectRegisterCloseCallback(virConnectPtr conn,
                                    virConnectCloseFunc cb,
                                    void *opaque,
                                    virFreeCallback freecb);
int virConnectUnregisterCloseCallback(virConnectPtr conn,
                                      virConnectCloseFunc cb);
int                     virConnectGetMaxVcpus   (virConnectPtr conn,
                                                 const char *type);
char *                  virConnectGetCapabilities (virConnectPtr conn);


int virConnectCompareCPU(virConnectPtr conn,
                         const char *xmlDesc,
                         unsigned int flags);

int virNodeGetFreePages(virConnectPtr conn,
                        unsigned int npages,
                        unsigned int *pages,
                        int startcell,
                        unsigned int cellcount,
                        unsigned long long *counts,
                        unsigned int flags);

int virNodeAllocPages(virConnectPtr conn,
                      unsigned int npages,
                      unsigned int *pageSizes,
                      unsigned long long *pageCounts,
                      int startCell,
                      unsigned int cellCount,
                      unsigned int flags);









int                     virNodeGetInfo          (virConnectPtr conn,
                                                 virNodeInfoPtr info);

--]]


return Connection
