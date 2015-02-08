# Copyright 2006 The Android Open Source Project

#Stephen.huang
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#Note : If you want to build busybox, pls remove '-Werror=format-security' from 'TARGET_GLOBAL_CFLAGS' in TARGET_linux-arm.mk . otherwise you will meet some error.
#       busybox tar utility has some type definition error. You can modify it as follows:
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
#./android/bionic/libc/kernel/arch-arm/asm/posix_types.h
#-typedef long __kernel_off_t;
#+typedef long long __kernel_off_t;

#./android/bionic/libc/unistd/mmap.c
#-void*   mmap( void*  addr,  size_t  size, int  prot, int  flags, int  fd,  long  offset )
#+void*   mmap( void*  addr,  size_t  size, int  prot, int  flags, int  fd,  off_t offset )
#-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

LOCAL_PATH:= $(call my-dir)


#ajayet : uncomment the following to build busybox
#REBUILD_BUSYBOX := true
ifdef REBUILD_BUSYBOX
include $(CLEAR_VARS)

LOCAL_SRC_FILES :=      applets/applets.c \
    archival/libarchive/data_align.c \
    archival/libarchive/data_extract_all.c \
    archival/libarchive/data_skip.c \
    archival/libarchive/data_extract_to_command.c \
    archival/libarchive/data_extract_to_stdout.c \
    archival/libarchive/decompress_bunzip2.c \
    archival/libarchive/decompress_unlzma.c \
    archival/libarchive/decompress_unzip.c \
    archival/libarchive/decompress_unxz.c \
    archival/libarchive/filter_accept_all.c \
    archival/libarchive/filter_accept_list.c \
    archival/libarchive/filter_accept_reject_list.c \
    archival/libarchive/find_list_entry.c \
    archival/libarchive/get_header_tar_bz2.c \
    archival/libarchive/get_header_cpio.c \
    archival/libarchive/get_header_tar.c \
    archival/libarchive/get_header_tar_gz.c \
    archival/libarchive/get_header_tar_lzma.c \
    archival/libarchive/header_list.c \
    archival/libarchive/header_skip.c \
    archival/libarchive/init_handle.c \
    archival/libarchive/lzo1x_1.c \
    archival/libarchive/header_verbose_list.c \
    archival/libarchive/lzo1x_1o.c \
    archival/libarchive/lzo1x_d.c \
    archival/libarchive/seek_by_jump.c \
    archival/libarchive/open_transformer.c \
    archival/libarchive/seek_by_read.c \
    archival/bbunzip.c \
    archival/bzip2.c \
    archival/cpio.c \
    archival/gzip.c \
    archival/lzop.c \
    archival/unzip.c \
    archival/rpm.c \
    archival/rpm2cpio.c \
    archival/tar.c \
    console-tools/chvt.c \
    console-tools/clear.c \
    console-tools/deallocvt.c \
    console-tools/dumpkmap.c \
    console-tools/fgconsole.c \
    console-tools/kbd_mode.c \
    console-tools/loadfont.c \
    console-tools/loadkmap.c \
    console-tools/openvt.c \
    console-tools/reset.c \
    console-tools/setconsole.c \
    console-tools/resize.c \
    console-tools/setkeycodes.c \
    console-tools/setlogcons.c \
    console-tools/showkey.c \
    coreutils/libcoreutils/cp_mv_stat.c \
    coreutils/libcoreutils/getopt_mk_fifo_nod.c \
    coreutils/basename.c \
    coreutils/catv.c \
    coreutils/cal.c \
    coreutils/cat.c \
    coreutils/chgrp.c \
    coreutils/chmod.c \
    coreutils/chown.c \
    coreutils/chroot.c \
    coreutils/cksum.c \
    coreutils/comm.c \
    coreutils/date.c \
    coreutils/cp.c \
    coreutils/cut.c \
    coreutils/echo.c \
    coreutils/dd.c \
    coreutils/dos2unix.c \
    coreutils/dirname.c \
    coreutils/du.c \
    coreutils/expand.c \
    coreutils/env.c \
    coreutils/expr.c \
    coreutils/false.c \
    coreutils/fold.c \
    coreutils/fsync.c \
    coreutils/head.c \
    coreutils/hostid.c \
    coreutils/id.c \
    coreutils/ln.c \
    coreutils/length.c \
    coreutils/logname.c \
    coreutils/mkdir.c \
    coreutils/ls.c \
    coreutils/md5_sha1_sum.c \
    coreutils/mkfifo.c \
    coreutils/mknod.c \
    coreutils/nice.c \
    coreutils/mv.c \
    coreutils/nohup.c \
    coreutils/printf.c \
    coreutils/od.c \
    coreutils/printenv.c \
    coreutils/readlink.c \
    coreutils/realpath.c \
    coreutils/rmdir.c \
    coreutils/rm.c \
    coreutils/sleep.c \
    coreutils/seq.c \
    coreutils/sort.c \
    coreutils/split.c \
    coreutils/stat.c \
    coreutils/stty.c \
    coreutils/sync.c \
    coreutils/sum.c \
    coreutils/tail.c \
    coreutils/tac.c \
    coreutils/test.c \
    coreutils/tee.c \
    coreutils/test_ptr_hack.c \
    coreutils/touch.c \
    coreutils/true.c \
    coreutils/tr.c \
    coreutils/uname.c \
    coreutils/tty.c \
    coreutils/uniq.c \
    coreutils/uudecode.c \
    coreutils/usleep.c \
    coreutils/uuencode.c \
    coreutils/whoami.c \
    coreutils/wc.c \
    coreutils/yes.c \
    debianutils/run_parts.c \
    debianutils/mktemp.c \
    debianutils/pipe_progress.c \
    debianutils/start_stop_daemon.c \
    debianutils/which.c \
    e2fsprogs/e2fs_lib.c \
    e2fsprogs/chattr.c \
    e2fsprogs/lsattr.c \
    editors/diff.c \
    editors/awk.c \
    editors/cmp.c \
    editors/patch.c \
    editors/ed.c \
    editors/sed.c \
    findutils/find.c \
    findutils/grep.c \
    findutils/xargs.c \
    init/bootchartd.c \
    init/init.c \
    init/halt.c \
    init/mesg.c \
    libbb/appletlib.c \
    libbb/ask_confirmation.c \
    libbb/bb_askpass.c \
    libbb/bb_basename.c \
    libbb/bb_bswap_64.c \
    libbb/bb_do_delay.c \
    libbb/bb_pwd.c \
    libbb/bb_qsort.c \
    libbb/bb_strtonum.c \
    libbb/chomp.c \
    libbb/change_identity.c \
    libbb/compare_string_array.c \
    libbb/concat_path_file.c \
    libbb/concat_subpath_file.c \
    libbb/copy_file.c \
    libbb/copyfd.c \
    libbb/crc32.c \
    libbb/default_error_retval.c \
    libbb/create_icmp6_socket.c \
    libbb/create_icmp_socket.c \
    libbb/device_open.c \
    libbb/dump.c \
    libbb/execable.c \
    libbb/fclose_nonstdin.c \
    libbb/fflush_stdout_and_exit.c \
    libbb/fgets_str.c \
    libbb/get_cpu_count.c \
    libbb/find_pid_by_name.c \
    libbb/find_root_device.c \
    libbb/full_write.c \
    libbb/get_console.c \
    libbb/get_last_path_component.c \
    libbb/get_line_from_file.c \
    libbb/get_volsize.c \
    libbb/getopt32.c \
    libbb/herror_msg.c \
    libbb/getpty.c \
    libbb/hash_md5_sha.c \
    libbb/human_readable.c \
    libbb/inet_common.c \
    libbb/info_msg.c \
    libbb/kernel_version.c \
    libbb/inode_hash.c \
    libbb/isdirectory.c \
    libbb/last_char_is.c \
    libbb/lineedit.c \
    libbb/lineedit_ptr_hack.c \
    libbb/llist.c \
    libbb/login.c \
    libbb/loop.c \
    libbb/make_directory.c \
    libbb/makedev.c \
    libbb/match_fstype.c \
    libbb/messages.c \
    libbb/mode_string.c \
    libbb/obscure.c \
    libbb/parse_config.c \
    libbb/perror_nomsg.c \
    libbb/parse_mode.c \
    libbb/perror_msg.c \
    libbb/perror_nomsg_and_die.c \
    libbb/platform.c \
    libbb/pidfile.c \
    libbb/print_flags.c \
    libbb/printable.c \
    libbb/printable_string.c \
    libbb/progress.c \
    libbb/procps.c \
    libbb/process_escape_sequence.c \
    libbb/read.c \
    libbb/ptr_to_globals.c \
    libbb/read_key.c \
    libbb/read_printf.c \
    libbb/recursive_action.c \
    libbb/remove_file.c \
    libbb/rtc.c \
    libbb/run_shell.c \
    libbb/safe_gethostname.c \
    libbb/safe_poll.c \
    libbb/safe_strncpy.c \
    libbb/safe_write.c \
    libbb/setup_environment.c \
    libbb/signals.c \
    libbb/simplify_path.c \
    libbb/single_argv.c \
    libbb/speed_table.c \
    libbb/skip_whitespace.c \
    libbb/str_tolower.c \
    libbb/strrstr.c \
    libbb/time.c \
    libbb/trim.c \
    libbb/u_signal_names.c \
    libbb/udp_io.c \
    libbb/wfopen.c \
    libbb/uuencode.c \
    libbb/unicode.c \
    libbb/vdprintf.c \
    libbb/verror_msg.c \
    libbb/vfork_daemon_rexec.c \
    libbb/warn_ignoring_args.c \
    libbb/wfopen_input.c \
    libbb/write.c \
    libbb/xconnect.c \
    libbb/xatonum.c \
    libbb/xfunc_die.c \
    libbb/xreadlink.c \
    libbb/xfuncs.c \
    libbb/xfuncs_printf.c \
    libbb/xgetcwd.c \
    libbb/xgethostbyname.c \
    libbb/xrealloc_vector.c \
    libbb/xregcomp.c \
    libpwdgrp/uidgid_get.c \
    loginutils/add-remove-shell.c \
    miscutils/beep.c \
    miscutils/chrt.c \
    miscutils/crond.c \
    miscutils/crontab.c \
    miscutils/dc.c \
    miscutils/rx.c \
    miscutils/fbsplash.c \
    miscutils/devmem.c \
    miscutils/hdparm.c \
    miscutils/less.c \
    miscutils/makedevs.c \
    miscutils/setsid.c \
    miscutils/man.c \
    miscutils/mountpoint.c \
    miscutils/raidautorun.c \
    miscutils/strings.c \
    miscutils/time.c \
    miscutils/timeout.c \
    miscutils/ttysize.c \
    miscutils/volname.c \
    miscutils/wall.c \
    modutils/modutils.c \
    modutils/modinfo.c \
    modutils/modprobe-small.c \
    networking/dnsd.c \
    networking/arp.c \
    networking/interface.c \
    networking/nbd-client.c \
    networking/nc.c \
    networking/ping.c \
    procps/iostat.c \
    procps/nmeter.c \
    procps/pgrep.c \
    procps/pidof.c \
    procps/pmap.c \
    procps/powertop.c \
    procps/renice.c \
    procps/ps.c \
    procps/smemcap.c \
    procps/sysctl.c \
    procps/top.c \
    procps/uptime.c \
    procps/watch.c \
    procps/kill.c \
    runit/chpst.c \
    runit/runsv.c \
    runit/runsvdir.c \
    runit/svlogd.c \
    runit/sv.c \
    shell/cttyhack.c \
    shell/ash.c \
    shell/ash_ptr_hack.c \
    shell/hush.c \
    shell/shell_common.c \
    shell/random.c \
    shell/match.c \
    shell/math.c \
    sysklogd/klogd.c \
    util-linux/volume_id/get_devname.c \
    util-linux/volume_id/util.c \
    util-linux/volume_id/volume_id.c \
    util-linux/acpid.c \
    util-linux/blkid.c \
    util-linux/blockdev.c \
    util-linux/dmesg.c \
    util-linux/fbset.c \
    util-linux/fdformat.c \
    util-linux/fdisk.c \
    util-linux/findfs.c \
    util-linux/flock.c \
    util-linux/freeramdisk.c \
    util-linux/getopt.c \
    util-linux/hexdump.c \
    util-linux/hwclock.c \
    util-linux/losetup.c \
    util-linux/lspci.c \
    util-linux/lsusb.c \
    util-linux/mdev.c \
    util-linux/mkfs_vfat.c \
    util-linux/mkswap.c \
    util-linux/more.c \
    util-linux/rdev.c \
    util-linux/readprofile.c \
    util-linux/rev.c \
    util-linux/rtcwake.c \
    util-linux/script.c \
    util-linux/scriptreplay.c \
    networking/netstat.c \
    networking/nslookup.c \
    arch/stubs.c \
    arch/sysinfo.S \
    arch/fdatasync.S \
    arch/stime.S \
    arch/getsid.S


LOCAL_C_INCLUDES += external/busybox/include
LOCAL_C_INCLUDES += external/busybox/include2
LOCAL_C_INCLUDES += external/busybox/libbb
LOCAL_C_INCLUDES += external/busybox/util-linux

LOCAL_MODULE_CLASS := EXECUTABLES
LOCAL_MODULE := busybox
LOCAL_MODULE_TAGS := user eng

intermediates:= $(local-intermediates-dir)
intermediates2:= $(local-intermediates-dir)
LOCAL_C_INCLUDES += $(intermediates)/include


#
#generate the cong header from the android-defconfig default 
#
AUTOCONF_H := $(intermediates)/include/autoconf.h
$(AUTOCONF_H): PRIVATE_PATH := $(LOCAL_PATH)
$(AUTOCONF_H): PRIVATE_CUSTOM_TOOL = $(MAKE) -C $(PRIVATE_PATH) defconfig CROSS_COMPILE=arm-eabi- ARCH=arm O=../../$(intermediates2) KBUILD_DEFCONFIG=android-defconfig
$(AUTOCONF_H): $(LOCAL_PATH)/android-defconfig
	$(transform-generated-source)

LOCAL_GENERATED_SOURCES += $(intermediates)/include/autoconf.h

#
#create the include and include2 directories
#

INCLUDES_H := $(addprefix $(intermediates)/include/, \
            usage_compressed.h \
            applet_tables.h \
        )
$(INCLUDES_H): PRIVATE_PATH := $(LOCAL_PATH)
$(INCLUDES_H): PRIVATE_CUSTOM_TOOL = $(MAKE) -C $(PRIVATE_PATH) prepare-all CROSS_COMPILE=arm-eabi- ARCH=arm O=../../$(intermediates2) KBUILD_DEFCONFIG=android-defconfig EXTRA_CFLAGS="-I../../bionic/libc/arch-arm/include   -I../../bionic/libc/include   -I../../bionic/libstdc++/include   -I../../bionic/libc/kernel/common   -I../../bionic/libc/kernel/arch-arm   -I../../bionic/libm/include   -I ../../bionic/libm/include/arch/arm   -I../../bionic/libthread_db/include -DRUN_LVL=1" V=1
$(INCLUDES_H): $(intermediates)/include/autoconf.h-typedef long __kernel_off_t;
+typedef long long __kernel_off_t;

	$(transform-generated-source)

LOCAL_GENERATED_SOURCES += $(INCLUDES_H)

LOCAL_CFLAGS +=  -include include/autoconf.h -DRUN_LVL=1 -D_LARGEFILE_SOURCE -D_LARGEFILE64_SOURCE -D_FILE_OFFSET_BITS=64 -D_GNU_SOURCE -D"BB_VER=KBUILD_STR(1.18.2)" -DBB_BT=AUTOCONF_TIMESTAMP -D"KBUILD_STR(s)=\#s" #-Q   -include include/usage_compressed.h


include $(BUILD_EXECUTABLE)

else

#ajayet : no need to build busybox everytime 
#this will copy the prebuilt version to system/bin

include $(CLEAR_VARS)

LOCAL_SRC_FILES := prebuilt/busybox

LOCAL_MODULE := busybox

LOCAL_MODULE_TAGS := eng

LOCAL_MODULE_CLASS := EXECUTABLES

#LOCAL_MODULE_PATH := $(local_target_dir)

include $(BUILD_PREBUILT)

endif


