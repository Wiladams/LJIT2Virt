local ffi = require("ffi")

local export = {}

ffi.cdef[[

typedef struct _virNWFilter virNWFilter;


typedef virNWFilter *virNWFilterPtr;



int                     virConnectNumOfNWFilters (virConnectPtr conn);
int                     virConnectListNWFilters  (virConnectPtr conn,
                                                  char **const names,
                                                  int maxnames);
int                     virConnectListAllNWFilters(virConnectPtr conn,
                                                   virNWFilterPtr **filters,
                                                   unsigned int flags);

virNWFilterPtr          virNWFilterLookupByName       (virConnectPtr conn,
                                                       const char *name);
virNWFilterPtr          virNWFilterLookupByUUID       (virConnectPtr conn,
                                                       const unsigned char *uuid);
virNWFilterPtr          virNWFilterLookupByUUIDString (virConnectPtr conn,
                                                       const char *uuid);


virNWFilterPtr          virNWFilterDefineXML    (virConnectPtr conn,
                                                 const char *xmlDesc);


int                     virNWFilterUndefine     (virNWFilterPtr nwfilter);


int                     virNWFilterRef          (virNWFilterPtr nwfilter);
int                     virNWFilterFree         (virNWFilterPtr nwfilter);


const char*             virNWFilterGetName       (virNWFilterPtr nwfilter);
int                     virNWFilterGetUUID       (virNWFilterPtr nwfilter,
                                                  unsigned char *uuid);
int                     virNWFilterGetUUIDString (virNWFilterPtr nwfilter,
                                                  char *buf);
char *                  virNWFilterGetXMLDesc    (virNWFilterPtr nwfilter,
                                                  unsigned int flags);
]]

return export
