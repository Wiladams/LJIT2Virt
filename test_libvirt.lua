local libvirt, err = require("libvirt")


if (not libvirt) then
	print(err);
	return nil;
end


