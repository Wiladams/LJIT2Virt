-- test_hostconnection.lua
package.path = package.path..';'..'../lib/virt/?.lua'

local ffi = require("ffi")

local Connection = require("hostconnection")
local Domain = require("domain")


local function printAttributes(conn)
	local lv,err = conn:getLibraryVersion();
	local libstr = nil;
	if (lv) then
		libstr = string.format("%d.%d.%d", lv.major, lv.minor, lv.release);
	else
		print("getLibraryVersion() failed: ", err);
	end

	print("==== Connection Attributes ====")
	print("  Library: ", libstr);
	print("Host Name: ", conn:getHostName());
	print("      URI: ", conn:getURI());
	print("Encrypted: ", conn:isEncrypted());
	print("   Secure: ", conn:isSecure());
	print("     Live: ", conn:isAlive());
end

local function printCPUModelNames(conn)
-- try out the model names iterator
	print("==== printCPUModelNames ====")
	for name in conn:cpuModelNames() do
		print("MODEL: ", name);
	end
end

local function printCapabilities(conn)
	print("==== printCapabilities ====");
	print(conn:getCapabilities())
end

local function printDomainInfo(conn)
	print("==== printDomainInfo ====")
	print("Number Of Domains: ", conn:getNumberOfDomains());
	for id in conn:domainIds() do
		print("ID: ", id)
		local dom = Domain(conn.Handle, id);
		print(dom);
		if dom then
			print("==== Domain: ", id)
			print("       Name: ", dom:getName())
			print("  Host Name: ", dom:getHostName())
			print("    OS Type: ", dom:getOSType())
			print("UUID String: ", dom:getUUIDString())
			print("   XML Desc: ", dom:getXMLDesc(ffi.C.VIR_DOMAIN_XML_SECURE))
			print("-- Info --")
			for k,v in pairs(dom:getInfo()) do
				print(k,v)
			end
		end
	end
end

local hosturi = "qemu:///system"
--local hosturi = "test:///default"

local conn = Connection(hosturi);
if not conn then 
	print("No connection established to: ", hosturi)
	return 
end


printAttributes(conn)
--printCPUModelNames(conn)
--printCapabilities(conn)
printDomainInfo(conn)

