LOCAL_PATH:= $(call my-dir)

# this will clear variables that has been set before this makefile
include $(CLEAR_VARS)

# work around, otherwise you will see build/tools/apriori/prelinkmap.c(168): library 'libnl.so' not in prelink map
LOCAL_PRELINK_MODULE:=false

LOCAL_CFLAGS += -D_GNU_SOURCE
LOCAL_CFLAGS += -DSYSCONFDIR=\"./\"
LOCAL_C_INCLUDES += $(LOCAL_PATH)/../include

libnl_la_SOURCES = \
	addr.c attr.c cache.c cache_mngr.c cache_mngt.c data.c \
	error.c handlers.c msg.c nl.c object.c socket.c utils.c

libnl_genl_la_SOURCES = \
	genl/ctrl.c genl/family.c genl/genl.c genl/mngt.c

libnl_nf_la_SOURCES = \
	netfilter/ct.c netfilter/ct_obj.c netfilter/log.c \
	netfilter/log_msg.c netfilter/log_msg_obj.c netfilter/log_obj.c \
	netfilter/netfilter.c netfilter/nfnl.c netfilter/queue.c \
	netfilter/queue_msg.c netfilter/queue_msg_obj.c netfilter/queue_obj.c

libnl_route_la_SOURCES = \
	route/addr.c route/class.c route/cls.c route/link.c \
	route/neigh.c route/neightbl.c route/nexthop.c route/qdisc.c \
	route/route.c route/route_obj.c route/route_utils.c route/rtnl.c \
	route/rule.c route/tc.c route/classid.c \
	\
	route/cls/fw.c route/cls/police.c route/cls/u32.c route/cls/basic.c \
	route/cls/cgroup.c \
	\
	route/cls/ematch_syntax.c route/cls/ematch_grammar.c \
	route/cls/ematch.c \
	route/cls/ematch/container.c route/cls/ematch/cmp.c \
	route/cls/ematch/nbyte.c route/cls/ematch/text.c \
	route/cls/ematch/meta.c \
	\
	route/link/api.c route/link/vlan.c \
	route/link/bridge.c route/link/inet6.c route/link/inet.c \
	\
	route/qdisc/blackhole.c route/qdisc/cbq.c route/qdisc/dsmark.c \
	route/qdisc/fifo.c route/qdisc/htb.c route/qdisc/netem.c \
	route/qdisc/prio.c route/qdisc/red.c route/qdisc/sfq.c \
	route/qdisc/tbf.c \
	\
	fib_lookup/lookup.c fib_lookup/request.c \
	\
	route/pktloc_syntax.c route/pktloc_grammar.c route/pktloc.c \
#	route/tsearch.c

LOCAL_SRC_FILES := $(libnl_la_SOURCES)
LOCAL_SRC_FILES += $(libnl_genl_la_SOURCES)
#LOCAL_SRC_FILES += $(libnl_nf_la_SOURCES)
#LOCAL_SRC_FILES += $(libnl_route_la_SOURCES)

LOCAL_SHARED_LIBRARIES += 
LOCAL_LDLIBS += 
LOCAL_MODULE:= libnl
LOCAL_SYSTEM_SHARED_LIBRARIES := libc libcutils libm

# include BUILD_SHARED_LIBRARY so Android will build a shared lib
include $(BUILD_SHARED_LIBRARY)
