local ffi = require("ffi")

local export = {}

ffi.cdef[[
typedef enum {
    VIR_STREAM_NONBLOCK = (1 << 0),
} virStreamFlags;

virStreamPtr virStreamNew(virConnectPtr conn,
                          unsigned int flags);
int virStreamRef(virStreamPtr st);

int virStreamSend(virStreamPtr st,
                  const char *data,
                  size_t nbytes);

int virStreamRecv(virStreamPtr st,
                  char *data,
                  size_t nbytes);



typedef int (*virStreamSourceFunc)(virStreamPtr st,
                                   char *data,
                                   size_t nbytes,
                                   void *opaque);

int virStreamSendAll(virStreamPtr st,
                     virStreamSourceFunc handler,
                     void *opaque);


typedef int (*virStreamSinkFunc)(virStreamPtr st,
                                 const char *data,
                                 size_t nbytes,
                                 void *opaque);

int virStreamRecvAll(virStreamPtr st,
                     virStreamSinkFunc handler,
                     void *opaque);

typedef enum {
    VIR_STREAM_EVENT_READABLE  = (1 << 0),
    VIR_STREAM_EVENT_WRITABLE  = (1 << 1),
    VIR_STREAM_EVENT_ERROR     = (1 << 2),
    VIR_STREAM_EVENT_HANGUP    = (1 << 3),
} virStreamEventType;



typedef void (*virStreamEventCallback)(virStreamPtr stream, int events, void *opaque);

int virStreamEventAddCallback(virStreamPtr stream,
                              int events,
                              virStreamEventCallback cb,
                              void *opaque,
                              virFreeCallback ff);

int virStreamEventUpdateCallback(virStreamPtr stream,
                                 int events);

int virStreamEventRemoveCallback(virStreamPtr stream);


int virStreamFinish(virStreamPtr st);
int virStreamAbort(virStreamPtr st);

int virStreamFree(virStreamPtr st);
]]

return export

