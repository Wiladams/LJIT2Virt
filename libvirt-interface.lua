local ffi = require("ffi")

local export = {}

ffi.cdef[[

typedef struct _virInterface virInterface;

typedef virInterface *virInterfacePtr;

virConnectPtr           virInterfaceGetConnect    (virInterfacePtr iface);

int                     virConnectNumOfInterfaces (virConnectPtr conn);
int                     virConnectListInterfaces  (virConnectPtr conn,
                                                   char **const names,
                                                   int maxnames);

int                     virConnectNumOfDefinedInterfaces (virConnectPtr conn);
int                     virConnectListDefinedInterfaces  (virConnectPtr conn,
                                                          char **const names,
                                                          int maxnames);

typedef enum {
    VIR_CONNECT_LIST_INTERFACES_INACTIVE      = 1 << 0,
    VIR_CONNECT_LIST_INTERFACES_ACTIVE        = 1 << 1,
} virConnectListAllInterfacesFlags;

int                     virConnectListAllInterfaces (virConnectPtr conn,
                                                     virInterfacePtr **ifaces,
                                                     unsigned int flags);

virInterfacePtr         virInterfaceLookupByName  (virConnectPtr conn,
                                                   const char *name);
virInterfacePtr         virInterfaceLookupByMACString (virConnectPtr conn,
                                                       const char *mac);

const char*             virInterfaceGetName       (virInterfacePtr iface);
const char*             virInterfaceGetMACString  (virInterfacePtr iface);

typedef enum {
    VIR_INTERFACE_XML_INACTIVE = 1 << 0 /* dump inactive interface information */
} virInterfaceXMLFlags;

char *                  virInterfaceGetXMLDesc    (virInterfacePtr iface,
                                                   unsigned int flags);
virInterfacePtr         virInterfaceDefineXML     (virConnectPtr conn,
                                                   const char *xmlDesc,
                                                   unsigned int flags);

int                     virInterfaceUndefine      (virInterfacePtr iface);

int                     virInterfaceCreate        (virInterfacePtr iface,
                                                   unsigned int flags);

int                     virInterfaceDestroy       (virInterfacePtr iface,
                                                   unsigned int flags);

int                     virInterfaceRef           (virInterfacePtr iface);
int                     virInterfaceFree          (virInterfacePtr iface);

int                     virInterfaceChangeBegin   (virConnectPtr conn,
                                                   unsigned int flags);
int                     virInterfaceChangeCommit  (virConnectPtr conn,
                                                   unsigned int flags);
int                     virInterfaceChangeRollback(virConnectPtr conn,
                                                   unsigned int flags);

int virInterfaceIsActive(virInterfacePtr iface);

]]

return export

