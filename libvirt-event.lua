local ffi = require("ffi")

local export = {}

ffi.cdef[[
typedef enum {
    VIR_EVENT_HANDLE_READABLE  = (1 << 0),
    VIR_EVENT_HANDLE_WRITABLE  = (1 << 1),
    VIR_EVENT_HANDLE_ERROR     = (1 << 2),
    VIR_EVENT_HANDLE_HANGUP    = (1 << 3),
} virEventHandleType;


typedef void (*virEventHandleCallback)(int watch, int fd, int events, void *opaque);


typedef int (*virEventAddHandleFunc)(int fd, int event,
                                     virEventHandleCallback cb,
                                     void *opaque,
                                     virFreeCallback ff);


typedef void (*virEventUpdateHandleFunc)(int watch, int event);


typedef int (*virEventRemoveHandleFunc)(int watch);


typedef void (*virEventTimeoutCallback)(int timer, void *opaque);


typedef int (*virEventAddTimeoutFunc)(int timeout,
                                      virEventTimeoutCallback cb,
                                      void *opaque,
                                      virFreeCallback ff);


typedef void (*virEventUpdateTimeoutFunc)(int timer, int timeout);


typedef int (*virEventRemoveTimeoutFunc)(int timer);

void virEventRegisterImpl(virEventAddHandleFunc addHandle,
                          virEventUpdateHandleFunc updateHandle,
                          virEventRemoveHandleFunc removeHandle,
                          virEventAddTimeoutFunc addTimeout,
                          virEventUpdateTimeoutFunc updateTimeout,
                          virEventRemoveTimeoutFunc removeTimeout);

int virEventRegisterDefaultImpl(void);
int virEventRunDefaultImpl(void);

int virEventAddHandle(int fd, int events,
                      virEventHandleCallback cb,
                      void *opaque,
                      virFreeCallback ff);
void virEventUpdateHandle(int watch, int events);
int virEventRemoveHandle(int watch);

int virEventAddTimeout(int frequency,
                       virEventTimeoutCallback cb,
                       void *opaque,
                       virFreeCallback ff);
void virEventUpdateTimeout(int timer, int frequency);
int virEventRemoveTimeout(int timer);
]]

return export
