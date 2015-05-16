-- get_domain_stat.lua
package.path = package.path..';../?.lua'

local ffi = require("ffi")

local Connection = require("hostconnection")
local Domain = require("domain")


local function printAttributes(conn)
	print("==== Connection Attributes ====")
	print("Host Name: ", conn:getHostName());
	print("Encrypted: ", conn:isEncrypted());
	print("   Secure: ", conn:isSecure());
	print("     Live: ", conn:isAlive());
end


local function getstats(conn, domainname, whichstats)
	-- get a handle on the domain by name
	local dom = Domain(conn.Handle, domainname)
	if not dom then
		return false, "could not get domain"
	end

	for stat in dom:stats(ffi.C.VIR_DOMAIN_STATS_CPU_TOTAL) do
		for k,v in pairs(stat) do
			print("STAT: ", k, v);
			if (type(v) == "table") then
				for key,value in pairs(v) do
					print(key, value)
				end
			end
		end
	end

	return true
end

local domains = {
	{hosturi = "qemu:///system", domainidentifier = "arch1"},
--	{hosturi = "qemu:///system", domainidentifier = "win81"},
--	{hosturi = "test:///default", domainidentifier = "test"},
}

for _, info in ipairs(domains) do
	local conn = Connection(info.hosturi);
	if conn then 
		printAttributes(conn)
		getstats(conn, info.domainidentifier)
	else 
		print("No connection established to: ", hosturi)
	end
end



