---
layout: post
title: "Dart generating and executing snapshots"
date: 2013-01-11 17:32
comments: true
categories: 
- Dart
- snapshots
- DartVM
---

Todays random walk of dartness has lead me to generating and executing snapshots. 

What is a snapshot in terms of Dart? Serialized binary heaps. It has been [said](http://blog.sethladd.com/2012/09/what-dart-wants.html) that snapshots can help apps startup 10X faster. `dart2js` is a working example of this in action, when you execute the `dart2js` compiler it is actually running from a snapshot file. 

How can I currently generate them? (Might not be this way in the future) As of now you need to build from source so the `gen_snapshot` binary is built. `gen_snapshot` is the tool built from [gen_snapshot.cc](https://raw.github.com/dart-lang/bleeding_edge/master/dart/runtime/bin/gen_snapshot.cc).

``` bash
~/dart_bleeding/dart/xcodebuild/DebugIA32/test
$ cd dart

~/dart_bleeding/dart/xcodebuild/DebugIA32/test
$ git svn fetch

~/dart_bleeding/dart/xcodebuild/DebugIA32/test
$ git merge git-svn

~/dart_bleeding/dart/xcodebuild/DebugIA32/test
$ gclient sync

~/dart_bleeding/dart/xcodebuild/DebugIA32/test
$ gclient runhooks

~/dart_bleeding/dart/xcodebuild/DebugIA32/test
$ ./tools/build.py -m all --verbose -a ia32 --os=host -j 4
```

After that song and dance is finished the release build directory should contain the `gen_snapshot` executable. 

``` bash
~/dart_bleeding
$ cd dart/xcodebuild/ReleaseIA32/

~/dart_bleeding/dart/xcodebuild/ReleaseIA32
$ ls
analyzer                  libcrnspr.a               libdart_vm.a              libv8_base.a
api_docs                  libcrnss.a                libdart_withcore.a        libv8_nosnapshot.a
d8                        libcrnssckbi.a            libdouble_conversion.a    libv8_snapshot.a
dart                      libdart.a                 libjscre.a                mksnapshot
dart-sdk                  libdart_builtin.a         libnss_static_dart.a      packages
dart2js.snapshot          libdart_dependency_helper libsample_extension.dylib process_test
dart_no_snapshot          libdart_io.a              libsqlite3.a              run_vm_tests
gen_snapshot              libdart_lib.a             libssl_dart.a
libchrome_zlib.a          libdart_lib_withcore.a    libtest_extension.dylib
```

Running `gen_snapshot --help` we find the flags needed to generate a snapshot script.

```
~/dart_bleeding/dart/xcodebuild/ReleaseIA32
$ ./gen_snapshot --help
No snapshot output file specified.

Usage:

  gen_snapshot [<vm-flags>] [<options>] \
               {--script_snapshot=<out-file> | --snapshot=<out-file>} \
               [<dart-script-file>]

  Writes a snapshot of <dart-script-file> to <out-file>. If no
  <dart-script-file> is passed, a generic snapshot of all the corelibs is
  created. One of the following is required:

    --script_snapshot=<file>   Generates a script snapshot.
    --snapshot=<file>          Generates a complete snapshot. Uses the url
                               mapping specified on the command line to load
                               the libraries.
Supported options:

--package_root=<path>
  Where to find packages, that is, "package:..." imports.

--url_mapping=<mapping>
  Uses the URL mapping(s) specified on the command line to load the
  libraries. For use only with --snapshot=.
```

The dart vm provides a flag that allows the vm to load the dart script from a snapshot. 

```
--use_script_snapshot=<file_name>
  executes Dart script present in the specified snapshot file
```

Combining all this together and using the `benchmark_harness` we can test out creating and running a dart application from a snapshot.

``` bash
git clone https://github.com/financeCoding/benchmark_harness.git

~/dart
$ cd benchmark_harness/

~/dart/benchmark_harness
$ pub install
Resolving dependencies...
Dependencies installed!

~/dart/benchmark_harness
$ cd example/

~/dart/benchmark_harness/example
$ ls
DeltaBlue.dart     Richards.dart      Template.dart      packages

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart DeltaBlue.dart 
DeltaBlue(RunTime): 4326.133909287257 us.

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart Richards.dart 
Richards(RunTime): 2135.538954108858 us.

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/gen_snapshot --script_snapshot=DeltaBlue.snapshot DeltaBlue.dart 

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart --use_script_snapshot=./DeltaBlue.snapshot DeltaBlue.dart
DeltaBlue(RunTime): 4268.6567164179105 us.

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/gen_snapshot --script_snapshot=Richards.snapshot Richards.dart 

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart --use_script_snapshot=./Richards.snapshot Richards.dart 
Richards(RunTime): 2082.206035379813 us.

~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart --use_script_snapshot=./Richards.snapshot Richards.dart 
Richards(RunTime): 2079.002079002079 us.
```

The above examples might not be the best, but it's a start to using snapshots and loading them from dart vm.  

After reading [John McCutchan](http://www.johnmccutchan.com/) comment below I've generated much more interesting output. 

```
23:49:47-adam@Adams-MacBook-Air:~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart  --compiler_stats  --use_script_snapshot=./Richards.snapshot Richards.dart
Richards(RunTime): 2069.2864529472595 us.
==== Compiler Stats ====
Number of tokens:   0
  Literal tokens:   0
  Ident tokens:     0
Tokens consumed:    6973 (inf times number of tokens)
Tokens checked:     49617  (7.12 times tokens consumed)
Token rewind:       3643 (7% of tokens checked)
Token lookahead:    2361 (4% of tokens checked)
Source length:      0 characters
Scanner time:       0 msecs
Parser time:        18 msecs
Code gen. time:     66 msecs
  Graph builder:    7 msecs
  Graph SSA:        0 msecs
  Graph inliner:    10 msecs
    Parsing:        2 msecs
    Building:       1 msecs
    SSA:            1 msecs
    Optimization:   2 msecs
    Substitution:   0 msecs
  Graph optimizer:  13 msecs
  Graph compiler:   29 msecs
  Code finalizer:   4 msecs
Compilation speed:  0 tokens per msec
Code size:          56 KB
Code density:       0 tokens per KB
23:50:06-adam@Adams-MacBook-Air:~/dart/benchmark_harness/example
$ ~/dart_bleeding/dart/xcodebuild/DebugIA32/dart  --compiler_stats Richards.dart
Richards(RunTime): 2073.5751295336786 us.
==== Compiler Stats ====
Number of tokens:   1981
  Literal tokens:   68
  Ident tokens:     692
Tokens consumed:    13539 (6.83 times number of tokens)
Tokens checked:     87271  (6.45 times tokens consumed)
Token rewind:       5849 (6% of tokens checked)
Token lookahead:    3954 (4% of tokens checked)
Source length:      15543 characters
Scanner time:       3 msecs
Parser time:        23 msecs
Code gen. time:     110 msecs
  Graph builder:    5 msecs
  Graph SSA:        0 msecs
  Graph inliner:    13 msecs
    Parsing:        2 msecs
    Building:       2 msecs
    SSA:            1 msecs
    Optimization:   3 msecs
    Substitution:   1 msecs
  Graph optimizer:  13 msecs
  Graph compiler:   69 msecs
  Code finalizer:   6 msecs
Compilation speed:  14 tokens per msec
Code size:          89 KB
Code density:       22 tokens per KB
23:50:26-adam@Adams-MacBook-Air:~/dart/benchmark_harness/example
```

References made about snapshots in no particular order

* [infoq](http://www.infoq.com/articles/google-dart)
* [What is the snapshot concept in dart?](http://stackoverflow.com/questions/12871476/what-is-the-snapshot-concept-in-dart)
* [what dart wants](http://blog.sethladd.com/2012/09/what-dart-wants.html)
* [runtime corelib](https://groups.google.com/a/dartlang.org/d/topic/misc/04Z3GHxk4As/discussion)
* [snapshotting explanation for a Smalltalker](https://groups.google.com/a/dartlang.org/d/topic/misc/_U6LZS226O4/discussion)
* [Dart Team Updates, Oct 30 - Nov 13](https://groups.google.com/a/dartlang.org/d/topic/misc/BoHa1YN_itk/discussion)
* [Dart A Modern Web Language](http://www.dartlang.org/slides/2012/06/io12/Dart-A-Modern-Web-Language.pdf)
* [Slides](http://www.dartlang.org/slides/)
* [Dartisans](http://www.dartlang.org/dartisans/)


