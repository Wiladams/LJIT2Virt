-- domain.lua
local ffi = require("ffi")
local bit = require("bit")
local bor = bit.bor;
local band = bit.band;

local libvirt, err = require("libvirt")


local Domain = {}
setmetatable(Domain, {
	__call = function(self, ...)
		return self:open(...)
	end,
})

local Domain_mt = {
	__index = Domain
}

-- for destructor
-- virDomainFree
--



function Domain.init(self, rawhandle)
	local obj = {
		Handle = rawhandle	-- should be stored in a smart pointer
	}
	setmetatable(obj, Domain_mt)
	
	obj:getName();

	return obj;
end


function Domain.open(self, connPtr, identifier)
	-- lookup a domain based on the identifier type
	local domPtr = nil;

	if (type(identifier) == 'number') then
		domPtr = libvirt.Lib.virDomainLookupByID(connPtr,identifier);
	elseif (type(identifier) == "string") then
		domPtr = libvirt.Lib.virDomainLookupByName(connPtr,identifier);
	end

	if domPtr ~= nil then
		return Domain:init(domPtr);
	end

	return nil;
end


--[[
	Informatics
--]]
function Domain.getCPUState(self, cpuNum)
--[[
	local err = libvirt.Lib.virDomainGetCPUStats(self.Handle,
                         virTypedParameterPtr params,
                         unsigned int nparams,
                         int start_cpu,
                         unsigned int ncpus,
                         unsigned int flags);
--]]
end

--
-- iterator over cpu states for all cpus in the domain
--
function Domain.cpuStates(self)
	local info = self:getInfo();
	local idx = -1;

	local function closure()
		idx = idx+1;
		if not info or idx >= info.nrVirtCpu then
			return nil;
		end

		return self:getCPUState(idx)
	end

	return closure
end

function Domain.getHostName(self, flags)
	if self.hostName then
		return self.hostName
	end
	
	flags = flags or 0
	local localvalue = libvirt.Lib.virDomainGetHostname(self.Handle, flags);
	if localvalue ~= nil then
		self.hostName = ffi.string(localvalue)
	end

	return self.hostName;
end

function Domain.getInfo(self)
	local info = ffi.new("virDomainInfo")
	local err = libvirt.Lib.virDomainGetInfo(self.Handle, info)
	if err < 0 then
		return nil
	end

	return {
		state = info.state;
		maxMem = info.maxMem;
		memory = info.memory;
		nrVirtCpu = info.nrVirtCpu;
		cpuTime = info.cpuTime;
	}
end

--[[
	one of 
	virDomainState
--]]
function Domain.getState(self, flags)
	flags = flags or 0
	local state = ffi.new("int[1]")
	local reason = ffi.new("int[1]")

	local err = libvirt.Lib.virDomainGetState(self.Handle,state,reason,flags);

	if err ~= 0 then
		return false
	end

	return state[0], reason[0];
end

function Domain.getName(self)
	if self.name then
		return self.name
	end

	local localname = libvirt.Lib.virDomainGetName(self.Handle);
	if localname ~= nil then
		self.name = ffi.string(localname)
	end

	return self.name;
end

function Domain.getOSType(self)
	if self.osType then
		return self.osType
	end

	local localvalue = libvirt.Lib.virDomainGetOSType(self.Handle);
	if localvalue ~= nil then
		self.osType = ffi.string(localvalue)
	end

	return self.osType;
end

function Domain.getUUIDString(self)
	if self.uuidString then
		return self.uuidString
	end

	local buff = ffi.new("char[256]")
	local err = libvirt.Lib.virDomainGetUUIDString(self.Handle, buff);
	if err ~= 0 then
		return false;
	end
	self.uuidString = ffi.string(buff)

	return self.uuidString;
end

function Domain.getXMLDesc(self, flags)

	if self.xmlDesc then
		return self.xmlDesc
	end

	flags = flags or 0
	local localvalue = libvirt.Lib.virDomainGetXMLDesc(self.Handle, flags);
	if localvalue ~= nil then
		self.xmlDesc = ffi.string(localvalue)
	end

	return self.xmlDesc;
end


--[[
unsigned int            virDomainGetID          (virDomainPtr domain);
int                     virDomainGetUUID        (virDomainPtr domain,
                                                 unsigned char *uuid);
unsigned long           virDomainGetMaxMemory   (virDomainPtr domain);
int                     virDomainSetMaxMemory   (virDomainPtr domain,
                                                 unsigned long memory);
int                     virDomainSetMemory      (virDomainPtr domain,
                                                 unsigned long memory);
int                     virDomainSetMemoryFlags (virDomainPtr domain,
                                                 unsigned long memory,
                                                 unsigned int flags);
int                     virDomainSetMemoryStatsPeriod (virDomainPtr domain,
                                                       int period,
                                                       unsigned int flags);
int                     virDomainGetMaxVcpus    (virDomainPtr domain);
int                     virDomainGetSecurityLabel (virDomainPtr domain,
                                                   virSecurityLabelPtr seclabel);
char *                  virDomainGetHostname    (virDomainPtr domain,
                                                 unsigned int flags);
int                     virDomainGetSecurityLabelList (virDomainPtr domain,
                                                       virSecurityLabelPtr* seclabels);
--]]
--[[
	stats: virDomainStatsTypes
	flags: virConnectGetAllDomainStatsFlags

	Returns: count of staistics structures on success, -1 on error


struct _virTypedParameter {
    char field[VIR_TYPED_PARAM_FIELD_LENGTH];  /* parameter name */
    int type;   /* parameter type, virTypedParameterType */
    union {
        int i;                      /* type is INT */
        unsigned int ui;            /* type is UINT */
        long long int l;            /* type is LLONG */
        unsigned long long int ul;  /* type is ULLONG */
        double d;                   /* type is DOUBLE */
        char b;                     /* type is BOOLEAN */
        char *s;                    /* type is STRING, may not be NULL */
    } value; /* parameter value */
};

typedef enum {
    VIR_TYPED_PARAM_INT     = 1, /* integer case */
    VIR_TYPED_PARAM_UINT    = 2, /* unsigned integer case */
    VIR_TYPED_PARAM_LLONG   = 3, /* long long case */
    VIR_TYPED_PARAM_ULLONG  = 4, /* unsigned long long case */
    VIR_TYPED_PARAM_DOUBLE  = 5, /* double case */
    VIR_TYPED_PARAM_BOOLEAN = 6, /* boolean(character) case */
    VIR_TYPED_PARAM_STRING  = 7, /* string case */

    VIR_TYPED_PARAM_LAST
} virTypedParameterType;

--]]
local function valueFromParameter(param)
	if param.type == ffi.C.VIR_TYPED_PARAM_INT then
		return param.value.i;
	elseif param.type == ffi.C.VIR_TYPED_PARAM_UINT then
		return param.value.ui;
	elseif param.type == ffi.C.VIR_TYPED_PARAM_LLONG then
		return param.value.l;
	elseif param.type == ffi.C.VIR_TYPED_PARAM_ULLONG then
		return param.value.ul;
	elseif param.type == ffi.C.VIR_TYPED_PARAM_DOUBLE then
		return param.value.d;
	elseif param.type == ffi.C.VIR_TYPED_PARAM_BOOLEAN then
		return param.value.b ~= 0;
	elseif param.type == ffi.C.VIR_TYPED_PARAM_STRING then
		return ffi.string(param.value.s);
	end

	return nil
end

local function typedParameterPtrToTable(nparams, params)
	local res = {}

	for idx=0, nparams-1 do
		local item = {
			[ffi.string(params[idx].field)] = valueFromParameter(params[idx]);
		}

		table.insert(res, item)
	end

	return res;
end

function Domain.stats(self, whichstats, flags)
	--flags = flags or ffi.C.VIR_CONNECT_GET_ALL_DOMAINS_STATS_OTHER;
	flags = flags or 0

	whichstats = whichstats or bor(
		ffi.C.VIR_DOMAIN_STATS_STATE,
		ffi.C.VIR_DOMAIN_STATS_CPU_TOTAL,
		ffi.C.VIR_DOMAIN_STATS_BALLOON,		
		ffi.C.VIR_DOMAIN_STATS_VCPU,
		ffi.C.VIR_DOMAIN_STATS_INTERFACE,
		ffi.C.VIR_DOMAIN_STATS_BLOCK
	);

	-- a list of a single domain
	local doms = ffi.new("virDomainPtr[2]");
	doms[0] = self.Handle;
	doms[1] = nil;
	local retStats = ffi.new("virDomainStatsRecordPtr *[1]")
	local numStats = libvirt.Lib.virDomainListGetStats(doms,
                          whichstats,
                          retStats,
                          flags);

	local idx = -1;
	local function closure()
		idx = idx + 1;
		if idx >= numStats then
			return nil;
		end

		-- get out the stats
		-- turn them into a table
		-- return to the caller
		return typedParameterPtrToTable(retStats[0][idx].nparams, retStats[0][idx].params);
	end

	return closure
end


--[[
	Domain management operations
--]]
function Domain.destroy(self)
	local err = libvirt.Lib.virDomainDestroy(self.Handle);
	
	return err;
end


function Domain.reboot(self, flags)
	flags = flags or 0
	local err = libvirt.Lib.virDomainReboot(self.Handle,flags);
	
	return err;
end

-- do a hard reset, like pressing the hardware reset
-- button on a physical machine
function Domain.reset(self, flags)
	flags = flags or 0
	local err = libvirt.Lib.virDomainReset(self.Handle, flags)
end

-- shutdown : Will shutdown the domain by sending RST signal
-- to processes.
function Domain.shutdown(self, flags)
	flags = flags or 0
	local err = libvirt.Lib.virDomainShutdown(self.Handle)
	--local err = libvirt.Lib.virDomainShutdownFlags(self.Handle, flags)
	
	return err;
end

function Domain.suspend(self)
	local err = libvirt.Lib.virDomainSuspend(self.Handle);

	return err;
end

function Domain.resume(self)
	local err = libvirt.Lib.virDomainResume(self.Handle);
	
	return err;
end

-- will save the memory state of a domain to a specified
-- file.  It will appear as 'not running'
-- MUST use restore() to get it running again
function Domain.save(self, tofilename, flags)
	flags = flags or 0
	local err = libvirt.Lib.virDomainSaveFlags(self.Handle,tofilename, nil, flags);

	return image;
end

function Domain.restore(self, fromfilename)
	local err = libvirt.Lib.virDomainRestore(self.Handle,fromimage);
	return err;
end

--[[



int                     virDomainRestoreFlags   (virConnectPtr conn,
                                                 const char *from,
                                                 const char *dxml,
                                                 unsigned int flags);
char *                  virDomainScreenshot     (virDomainPtr domain,
                                                 virStreamPtr stream,
                                                 unsigned int screen,
                                                 unsigned int flags);

int virDomainGetCPUStats(virDomainPtr domain,
                         virTypedParameterPtr params,
                         unsigned int nparams,
                         int start_cpu,
                         unsigned int ncpus,
                         unsigned int flags);

int                     virDomainGetControlInfo (virDomainPtr domain,
                                                 virDomainControlInfoPtr info,
                                                 unsigned int flags);


char *                  virDomainGetSchedulerType(virDomainPtr domain,
                                                  int *nparams);

--]]

return Domain
