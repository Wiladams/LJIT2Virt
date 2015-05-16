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
	
	obj:getHostName();
	obj:getURI();

	return obj;
end


function Connection.create(self, driveruri)
	print("Connection.create: ", driveruri)

	driveruri = driveruri or "test:///default";

	--local conn = libvirt.Lib.virConnectOpenReadOnly(driveruri);
	local conn = libvirt.Lib.virConnectOpen(driveruri);
	if not conn == nil then
		return nil
	end

	return Connection:init(conn)
end


--[[
	Attributes of the connection
--]]
function Connection.getHostName(self)
	return ffi.string(libvirt.Lib.virConnectGetHostname(self.Handle));
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

function Connection.getLibraryVersion(self)
	if self.libraryVersion then
		return self.libraryVersion
	end

    local libVer = ffi.new("unsigned long[1]");
	local err = libvirt.Lib.virConnectGetLibVersion(self.Handle, libVer)
	if err ~= 0 then
		return false, err
	end

	local major = tonumber(libVer[0] / 1000000);
	local minor = tonumber((libVer[0]-(major*1000000))/1000);
	local release = tonumber(libVer[0]-(major*1000000)-(minor*1000));
	
	self.libraryVersion = {major=major, minor=minor, release=release}
	
	return self.libraryVersion
end


function Connection.getURI(self)
	if self.uri then
		return self.uri 
	end

	local localvalue = libvirt.Lib.virConnectGetURI(self.Handle);
	if localvalue ~= nil then
		self.uri = ffi.string(localvalue)
	end

	return self.uri;
end

function Connection.getNumberOfDomains(self)
	return libvirt.Lib.virConnectNumOfDomains(self.Handle);
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
	Iterators
--]]
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

function Connection.domainIds(self)
	local maxids = 256
	local ids = ffi.new('int[256]');
	local numIds = libvirt.Lib.virConnectListDomains(self.Handle,
		ids,
		maxids);

	print("Connection.domainIds: ", numIds)
	local idx = -1;
	local function closure()
		idx = idx + 1;
		if idx >= numIds then
			return nil;
		end

		return ids[idx];
	end
	
	return closure
end

--[[
	Domain management
--]]

function Connection.getDomain(self, identifier)
	local domPtr = libvirt.Lib.virDomainLookupByID(self.Handle,domid);

	-- really we want to return a domain object
	return domPtr;
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
