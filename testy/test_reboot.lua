-- test_hostconnection.lua
package.path = package.path..';../?.lua'

local Connection = require("hostconnection")
local Domain = require("domain")


local function printAttributes(conn)
	print("==== printAttributes ====")
	print("Host Name: ", conn:getHostName());
	print("Encrypted: ", conn:isEncrypted());
	print("   Secure: ", conn:isSecure());
	print("     Live: ", conn:isAlive());
end


local function reboot(conn, domainname)
	-- get a handle on the domain by name
	local dom = Domain(conn.Handle, domainname)
	if not dom then
		return false, "could not get domain"
	end

	dom:reboot();

	return true
end

local hosturi = "qemu:///system"
local conn = Connection(hosturi);
if not conn then 
	print("No connection established to: ", hosturi)
	return 
end

printAttributes(conn)
reboot(conn, "win81")

