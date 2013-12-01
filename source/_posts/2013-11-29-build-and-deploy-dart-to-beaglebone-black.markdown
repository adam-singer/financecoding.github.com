---
layout: post
title: "Build and deploy dart to Beaglebone Black"
date: 2013-11-29 08:56
comments: true
categories: 
- Dart
- BeagleBoneBlack
- Embedded
- Debian
- ARM
- ARMv7
---

I was looking into using [dart](https://www.dartlang.org) on [Beaglebone Black](http://beagleboard.org/products/beaglebone%20black) and decided it would be useful to share with others what I found.

After a some build hacks and patches I found a minimal working solution for Beaglebone Black with [Debian](https://wiki.debian.org/ArmHardFloatPort) [ARMhf](http://www.armhf.com/). A few important notes before going down the road of building dart for ARM. The `dart-sdk` is not fully supported and pub currently might not work. ~~The `dartanalyzer` might not work~~. The only supported [ARM architectures](http://en.wikipedia.org/wiki/List_of_ARM_cores) are the ones that have [ARMv7](http://en.wikipedia.org/wiki/ARMv7#32-bit_architecture) with [VFP](http://en.wikipedia.org/wiki/ARM_architecture#Floating-point_.28VFP.29). Don't spin your wheels trying to target any architecutre that is not `ARMv7` with VFP (minimum at the moment `ARMv7-A`) unless you plan on implementing the routines needed in the runtime [arm assembler](https://code.google.com/p/dart/source/browse/branches/bleeding_edge/dart/runtime/vm/assembler_arm.cc). If you do plan on implementing them, well thats just pure awesome!

```cpp assembler_arm.cc
void CPUFeatures::InitOnce() {
#if defined(USING_SIMULATOR)
  integer_division_supported_ = true;
  neon_supported_ = true;
#else
  ASSERT(CPUInfoContainsString("ARMv7"));  // Implements ARMv7.
  ASSERT(CPUInfoContainsString("vfp"));  // Has floating point unit.
  // Has integer division.
  if (CPUInfoContainsString("QCT APQ8064")) {
    // Special case for Qualcomm Krait CPUs in Nexus 4 and 7.
    integer_division_supported_ = true;
  } else {
    integer_division_supported_ = CPUInfoContainsString("idiva");
  }
  neon_supported_ = CPUInfoContainsString("neon");
#endif  // defined(USING_SIMULATOR)
#if defined(DEBUG)
  initialized_ = true;
#endif
}
```

### Download [Ubuntu 12.04.3 LTS](http://releases.ubuntu.com/precise/)

Download the desktop iso to install on VirtualBox.

### Install on [VirtualBox](https://www.virtualbox.org/)

I work mostly on mac so Ubuntu installed on VirtualBox was needed to help with cross compiling and flashing of uSD cards.

### Update the packages 

Just to be safe update any Ubuntu packages before installing the development software. 

### Install basic packages

I typically use the git [overlay](https://code.google.com/p/dart/wiki/GettingTheSource#Using_Git) on subversion when working with the dart repo. The java jre/jdk is required for building the dart_analyzer which does not work in the sdk. 

```bash shell
# Install subversion 
sudo apt-get install subversion git git-svn openssh-server vim default-jre default-jdk
```

### Install the chrome build and arm dependencies

Checkout the latest build tools scripts. The following scripts prep your system with any packages needed for building dart. 

```bash shell
# checkout build scripts
svn co http://src.chromium.org/chrome/trunk/src/build; cd build

# install dependencies
chmod u+x install-build-deps.sh
./install-build-deps.sh --no-chromeos-fonts
./install-build-deps.sh --no-chromeos-fonts --arm
```

### Install addtional libraries

The following libraries are needed for building dart but might not be included from the chrome build tool scripts. 

```bash shell
# Install addtional libs
sudo apt-get install libc6-dev-i386 g++-multilib
```

### Install depot-tools

[depot-tools](http://www.chromium.org/developers/how-tos/depottools) is required for hacking out the dart source code.

```bash shell
# depot tools
svn co http://src.chromium.org/svn/trunk/tools/depot_tools
export PATH=$PATH:`pwd`//depot_tools
```

### Checkout the dart code base

You dont need to include `--username <YOUR USERNAME>` unless you plan on creating a CL for review. 

```bash shell
mkdir dart_bleeding
cd dart_bleeding
svn ls https://dart.googlecode.com/svn/branches/bleeding_edge/ --username <YOUR USERNAME>
gclient config https://dart.googlecode.com/svn/branches/bleeding_edge/deps/all.deps
git svn clone -rHEAD https://dart.googlecode.com/svn/branches/bleeding_edge/dart dart
gclient sync
gclient runhooks
```

### Patch the gyp and version files 

A git patch can be found here [7725354](https://gist.github.com/financeCoding/7725354), that patches the build scripts to support building the `dart-sdk` for ARM. Patching the `VERSION` file was done in an attempt to get pub working. At the moment its not required. If not done then an old version number is baked into the dartvm. This patch also modifies which dartvm creates the snapshots for `pub`, `dart2js` and a wrapper util. Patch creates the requirement of having to build the dartvm for x64 before building the `dart-sdk` for ARM. The dart build scripts have a funky dependency of wanting to use the dartvm target to create the snapshot files. Which in this case wont work since our dartvm is an ARM target being built on x64.  

```diff arm.build.patch
diff --git a/tools/VERSION b/tools/VERSION
index d1ab212..0d6101d 100644
--- a/tools/VERSION
+++ b/tools/VERSION
@@ -1,5 +1,5 @@
 CHANNEL be
-MAJOR 0
-MINOR 1
-BUILD 2
-PATCH 0
+MAJOR 1
+MINOR 0
+BUILD 0
+PATCH 7
diff --git a/utils/compiler/compiler.gyp b/utils/compiler/compiler.gyp
index 294c7e9..5f3754a 100644
--- a/utils/compiler/compiler.gyp
+++ b/utils/compiler/compiler.gyp
@@ -18,7 +18,7 @@
         {
           'action_name': 'generate_snapshots',
           'inputs': [
-            '<(PRODUCT_DIR)/<(EXECUTABLE_PREFIX)dart<(EXECUTABLE_SUFFIX)',
+            '<(PRODUCT_DIR)/../DebugX64/dart',
             '../../sdk/lib/_internal/libraries.dart',
             '<!@(["python", "../../tools/list_files.py", "\\.dart$", "../../sdk/lib/_internal/compiler", "../../runtime/lib", "../../sdk/lib/_internal/dartdoc"])',
             'create_snapshot.dart',
@@ -30,7 +30,7 @@
             '<(SHARED_INTERMEDIATE_DIR)/dart2js.dart.snapshot',
           ],
           'action': [
-            '<(PRODUCT_DIR)/<(EXECUTABLE_PREFIX)dart<(EXECUTABLE_SUFFIX)',
+            '<(PRODUCT_DIR)/../DebugX64/dart',
             'create_snapshot.dart',
             '--output_dir=<(SHARED_INTERMEDIATE_DIR)',
             '--dart2js_main=sdk/lib/_internal/compiler/implementation/dart2js.dart',
diff --git a/utils/pub/pub.gyp b/utils/pub/pub.gyp
index fd5e147..ab2e243 100644
--- a/utils/pub/pub.gyp
+++ b/utils/pub/pub.gyp
@@ -25,7 +25,7 @@
             '<(SHARED_INTERMEDIATE_DIR)/pub.dart.snapshot',
           ],
           'action': [
-            '<(PRODUCT_DIR)/<(EXECUTABLE_PREFIX)dart<(EXECUTABLE_SUFFIX)',
+            '<(PRODUCT_DIR)/../DebugX64/dart',
             '--package-root=<(PRODUCT_DIR)/packages/',
             '--snapshot=<(SHARED_INTERMEDIATE_DIR)/pub.dart.snapshot',
             '../../sdk/lib/_internal/pub/bin/pub.dart',
```

### Build the `dart-sdk`  

Building of the `dart-sdk` for ARM target is a two stop process. First build x64 so we can use that dartvm to generate the snapshot files. Then the second step is running the `create_sdk` build for ARM. When the build is finished the `out/ReleaseARM/dart-sdk` should contain a full `dart-sdk` build. ~~Keep in mind this does build the `dartanalyzer` but it may not work on ARM.~~

```bash shell
# build a target for your native system to create the snapshot files. 
./tools/build.py -m debug -v -a x64 -j 8 

# build the arm target
./tools/build.py -m release -v -a arm -j 8 create_sdk
```

### Tarball the sdk

Package up the `dart-sdk` as a tarball to distribute.

```bash shell
cd ./out/ReleaseARM/
tar -czvf dart-sdk.tar.gz dart-sdk
```

### Install [Debian Wheezy 7.2 Hard Float Minimal Image](http://www.armhf.com/index.php/boards/beaglebone-black/#wheezy) on Beaglebone Black 

In virtualbox with a uSD card at `/dev/sdX` the following will download an image and write to the uSD card. Updated images can be found at [armhf](http://www.armhf.com/index.php/boards/beaglebone-black/#wheezy) 

```bash shell
wget http://s3.armhf.com/debian/wheezy/bone/debian-wheezy-7.2-armhf-3.8.13-bone30.img.xz
xz -cd debian-wheezy-7.2-armhf-3.8.13-bone30.img.xz > /dev/sdX
```

Then insert the uSD card into the Beaglebone Black and boot the image by holding down the boot switch and powering on.

<img src="http://elinux.org/images/7/76/CONN_REVA5A.jpg">

Write the booted image to the eMMC.

```bash shell
xz -cd debian-wheezy-7.2-armhf-3.8.13-bone30.img.xz > /dev/mmcblk1
```

Power down and remove the uSD card.

### Update glibc on the BeagleBone Black

Updating glibc is required cause the version of glibc installed from the chromium build scripts is greater then the one shipped with Wheezy 7.2. The following commands update glibc.   

```bash shell
# Add an addtional source for the latest glibc
sudo sed -i '1i deb http://ftp.us.debian.org/debian/ jessie main' /etc/apt/sources.list

# Update sources 
sudo apt-get update

# Download latest glibc
sudo DEBIAN_FRONTEND=noninteractive apt-get -t jessie install -y libc6 libc6-dev libc6-dbg git screen
```

### Copy over `dart-sdk`

From virtual box copy over the tarball to Beaglebone Black running debian. 

```bash shell
scp dart-sdk.tar.gz debian@192.168.2.2:~/
```

After the tarball is copied, uncompress and add to your `PATH`. 

```bash shell
tar -zxvf dart-sdk.tar.gz
export PATH=~/dart-sdk:$PATH
dart --version
Dart VM version: 1.0.0.7_r30634_adam (Fri Nov 29 01:14:42 2013) on "linux_arm"
```

### Known issues at the moment

Pub does not work, issue could be followed at [15383](https://code.google.com/p/dart/issues/detail?id=15383). I was testing this out while staying at a hotel so some proxy settings might of been blocking or tripping up pub. 

### Feedback

If you have a better way of running dart on Beagleblone Black I would love to hear it! Please contact me on [g+](https://plus.google.com/104569492481999771226/) and lets discuss.

### Update on `dartanalyzer`

`dartanalyzer` will work after installing the `default-jre` on Beaglebone Black.

```bash shell
sudo apt-get install default-jre
``` 

### Addtional resources

* [dart_bleeding](https://github.com/financeCoding/dart_bleeding) contains some scripts I typically use for this entire process. 
* [PreparingYourMachine](https://code.google.com/p/dart/wiki/PreparingYourMachine) resources for preping your machine to build from source
* [GettingTheSource](https://code.google.com/p/dart/wiki/GettingTheSource) getting the source code documentation
