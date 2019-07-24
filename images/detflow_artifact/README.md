
# oopsla17_detmonad_artifact

Artifact for OOPSLA 2017 AEC

Getting started
---------------

You can run this artifact in two ways.

 1. Use the virtual machine with preinstalled Docker images.
 2. Unpack the sources and build the Docker image (see step-by-step, below).

The former does not require network access, while the latter does.

Once you either enter the VM or build the docker image
`parfunc/detmonad_oopsla17_artifact`, then you can enter the main
Docker image containing the "detflow" software.

    cd ~/oopsla17_detmonad_artifact
    docker run -it parfunc/detmonad_oopsla17_artifact

You can also use `make run` as a shortcut to get into the image.
After that, you will find yourself in a prompt where you can run
commands like this:

    root@bbed6b75191e:/detmonad# detflow --runshell date
    Wed Dec 31 19:00:00 EST 1969

What, it's 1969!?  Yes, it's *always* 1969 inside detflow.

Next, you can try one of the Haskell examples written in the `DetIO`
monad:

    cd /detmonad/examples/should_run/hello_world
    detflow HelloWorld.hs

But this will fail:

    cd /detmonad/examples/should_run/hello_files
    detflow HelloFiles.hs

Why?  It needs access to the file system.  Try:

    detflow HelloFiles.hs -i in -o out

Deterministic workflows only see the subset of the file system they
have access too.  That's not quite the whole story though, because
they also have read-only access to certain system directories such as
`/usr`.  Because we're running inside a container, we have strict
control over what binaries occur in `/usr`.

The `detflow` (and `detmake`) commands are what are evaluated during
benchmarking.  The have limited `--help` menus available on the
command line.  When you are ready to run the full benchmarks, proceed
to the `oopsla17_detmonad_artifact/results_image` directory where you
will use Docker to run the benchmarks *as* a Docker build (and store
the results as a Docker image).

### A note about Haskell packaging and "stack"

The directory `/detmonad` contains the `detflow`/`detmake` executables
as a Haskell Stack project.  Normally we would run `detflow` with
`stack exec -- detflow args`.  The only reason we do not is that the
Docker image above is already running inside a `stack exec bash`
session by default, which brings all the necessary things into scope.


Step-by-step guide
------------------

In this section we walk through the sections of the paper, describing
how the concepts described there relate to the code.

 * We will call the `oopsla17_detmonad_artifact` directory the
   ARTIFACT ROOT.'
 * We will call the `oopsla17_detmonad_artifact/detmonad` directory
   the SOURCE CODE directory.

The descriptions below regarding the implementation are relative to
the source code directory.

### Section 3.1

The `detflow` executable's main entrypoint is located in `harness/Main.hs`. This
mostly contains the logic for managing the input and output directories, and
creating a temporary file which takes a "detflow script" (with `main :: DetIO
()`) and converts it into a Haskell program with a main function of type `IO
()`.

`detflow` is the key trusted component in this system.  It both mediates between
`DetIO` and `IO`, and manages permissions (sec 3.4).  But there are also
several options in how `detflow` wraps and executes `DetIO` code.  For example,
`detflow HelloWorld.hs` runs the code interpreted, `detflow -c HelloWorld.hs`
compiles the code before running it.  Other options are described with
`detflow --help`.  For exmaple, `detflow -j2` will run (lightweight) threads
on an OS threadpool of size 2.

### Section 3.2

The core `DetIO` type and supporting operations are defined in
`src/Control/Monad/DetIO/Unsafe.hs` Although some operations in that module
are unsafe, a safe interface is exposed in `src/Control/Monad/DetIO.hs`.
In particular, note that the function
`liftIOToDet :: IO a -> DetIO a` is _only_ exposed in the `Unsafe` module.

### Section 3.3

`readFile` and `writeFile` are defined in `src/Control/Monad/DetIO/Reexports.hs`,
a module dedicated to functions that are essentially plain `IO` functions that
have been lifted to `DetIO` (with some additional permissions checks).

`forkIO`, `joinThread`, and `forkWithPerms` are defined in
`src/Control/Monad/DetIO/Unsafe.hs`.  Ultimately, the safe interface is
reexported through `Control.Monad.DetIO`, which is what users of the library
(writers of `DetIO` code against the public interface) are expected to use.
Every DetIO file, such as `examples/should_run/hello_world/HelloWorld.hs`,
imports this module.

### Section 3.4

The core permissions datatype `Perm` is located in
`src/Control/Monad/DetIO/Perms.hs`. Also located in that module is `InitialPerms`,
which forms a join semilattice, as described in section 3.4.2. The implementation
of the join operation `(\/)` can be found in the
`instance JoinSemiLattice InitialPerms`.

The checking out of permissions occurs in the `checkout` function. Note that in
addition to a `Perms` argument (which represents the permissions that a parent
thread already owns), `checkout` also takes a `PathPerm` argument, which
represents the permissions that the child thread requests.

### Section 3.6

`system` is defined in `src/Control/Monad/DetIO/System.hs`. Of particular
interest is `readCreateProcess` (which `system` indirectly calls), as it sets
up the use of `LD_PRELOAD` to load the `libdet` library into the address space
of the invoked subprocess.

### Section 4.1

The `HelloWorld.hs` file mentioned above provides a simple example of how to
experiment with the (deterministic) interaction of threads and print order,
based on pedigree, which is described in section 4.1 of the paper.  In
particular, you may notice that lines from the main thread print out one at a
time, whereas output from other threads is dumped in bursts.

### Section 5

`libdet`, the determinizing runtime, is implemented in `cbits/libdet.c`. Due to
`libdet`'s use of `LD_PRELOAD`, it overrides system calls by defining functions
with identical names and type signatures. For example, it:

* Intercepts time-gathering functions such as `clock`, `ntp_gettime`, `times`,
  `time`, `clock_gettime`, `gettime`, and `gettimeofday`.
* Catches attempts to open nondeterministic directories like `/dev/urandom`
  by intercepting `open()`
* Intercepts `pthread_create()`, `fork()`, etc. to impose an ordering on threads
  and processes
* Intercepts `getpid` and friends to manage `libdet`'s own deterministic,
  virtual IDs
* Intercepts the `stat()` family to return constant dummy metadata for each file

### Section 7: Performance Evaluation

#### Accessing the virtual machine

If you are not already reading this inside the virtual machine, please access it
by adding the .ova file to Virtualbox, booting it up, and opening the
`oopsla17_detmonad_artifact` directory and documentation visible on the
Desktop.  The username for this VM is `detflow`, with the password the same as
the username.

#### Building the artifact from scratch

If you have Docker installed and would like to avoid a large download by
performing extra computation locally, you can unpack the source tarball into a
directory (the artifact root, e.g. `~/oopsla17_detmonad_artifact`) and build the
image tagged `parfunc/detmonad_oopsla17_artifact` simply by typing `make`.  This
should require nothing but GNU make and docker itself installed.

After the image builds, it contains everything needed for benchmarking, but has
not yet run any benchmarks.  This is the "main" docker image, on top
of which we will layer one more image with the benchmarking results.

#### Running the benchmarks

Whether or not you built the main docker image yourself, or use the
one included on the Desktop, to run the benchmarks, you will switch to
the `results_image` directory inside the artifact root and build
*another* Docker image.

    cd ~/oopsla17_detmonad_artifact/results_image
    make

The resulting call to `docker build` is what actually runs all benchmarks,
creating a persistent image with the results (that can also be used for further
experimentation).  The above will also copy out the data and plots generated by
benchmarking into `~/oopsla17_detmonad_artifact/output`.  These can be
browsed within the virtual image or on your host system.  You can also
type `make shell` to drop back into the benchmarking image if you like.

The full benchmark run should take less than an hour.  The input sizes
and the parameter sweep have been shrunk significantly to make it more managable.



#### Example benchmark output, included

If you want to get a sense of what the output will be while you're waiting for
it to run, the artifact root contains two example output tarballs that resulted
from running the docker build.

 * `output_server.tgz` - output from a server machine running Docker (two-socket
   Xeon CPU E5-2670, at 2.60GHz).  No virtual machine was used.
 * `output_vm.tgz` - output generated from running the benchmarks inside a VM on an
   Linux Ubuntu 17.04 dual-core laptop.

#### Benchmark outputs, piece by piece

If you are interested in a top-down reading of the scripts that run the
benchmarks, start in `oopsla17_detmonad_artifact/scripts/run_all_artifact_benchmarks.sh`.
That initiates the benchmarks in three steps:

 * Microbenchmarks (7.1)
 * Bioinformatics benchmarks (7.2)
 * Deterministic make benchmarks (7.3)

The top-level script also establishes parameters such as the number of
TRIALS to run each benchmark.  (The infrastructure takes the median
time.)

##### Section 7.1: Microbenchmarks

The Docker image runs these microbenchmarks only at thread setting 4.
It places the results in the `output/microbenchmarks/` directory.

If you open `microbenchmarks/microbenchmarks_report.html` in a web
browser, you will see the mean execution times for each microbenchmark
compiled into one bar chart, as well as linear regressions for individual
benchmarks (this is produced by the Haskell `criterion` library).
One can hover over the charts to see further details.

The microbenchmarks can be divided up into two categories:

 * Ones which print a line of text
  - `Text.putStrLn`. This uses an implementation from the Haskell `text`
    library, which is the de facto standard for Unicode text, and does
    not use any `detflow` features.
  - `DetIO.putTextLn_det`. This is the `detflow` reimplementation of
    `putStrLn` which is fully determinized using thread pedigrees.
  - `DetIO.putTextLn_nondet`. This is like `DetIO.putTextLn_det`, except
    that the determinizing pedigree features are disabled. This is provided
    to give a sense of how much overhead the pedigrees involve.

 * Ones which shell out to a simple C program (which simply returns).
   The program is compiled before running the benchmarks, so only the time
   it takes to shell out and run the program is timed.
  - `Process.readProcess`. This uses an implementation from the standard
    Haskell `process` library.
  - `DetIO.readProcess_det`. This uses the `detflow` reimplementation of
    `readProcess` which runs the C program in the `libdet` runtime.
  - `DetIO.readProcess_nondet`. This is like `DetIO.readProcess_det`,
     except it does not go through `libdet` when running the C program.

The implementation of these microbenchmarks can be found in
`/detmonad/examples/microbenchmarks/src/Main.hs`.

For the raw data behind these results, look at
`microbenchmarks/microbench_log.txt`. This shows the raw `criterion` output
for each microbenchmark, including:

* The median times (under `time`). Also included is an R-squared value
  representing how well the measurements fit the regression line.
* The mean times (under `mean`)
* The standard deviations (under `std dev`)

Each of these also includes the minimum and maximum times.

To run the benchmarks, go into `/detmonad/examples/microbenchmarks` and run
`make`.

##### Section 7.2: Bioinformatics

The `output/plots` directory contains gnuplot-generated output created
from the csv data in `output/data`.  Here you will find two kinds of
plots:

 * *realtime*: for each benchmark, how long did the regular
   (nondeterministic) execution, i.e. `detflow --nondet`, take
   compared to the `detflow --det` execution?

 * *parallel speedup*: what is the parallel efficiency of increasing
   threads?

You can also run an individual bioinformatics test.  The code,
compiled binaries, and sample input datasets for the applications can
be found in `/detmonad/examples/bioinfo`.  Each of the per-benchmark
directories shares a convention on how to drive the benchmark using
`make` commands.

Each application takes an `in/` directory to an `out/`.  Further, they
will cache an `in_expected` and ``out_expected` directory, for the
initial state of the input directory, and an example output state,
respectively.  Here is a sample interaction:

 * Enter the docker image (either pre- or post-benchmarking).
 * `cd /detmonad/examples/bioinfo/raxml`
 * `make freshen` - clear the output directory, and make sure the
    input directory is in its starting state.  Freshening the input
    is sometimes necessary because some bioinformatics applications
    *mutate* their input (and require R/W permission).
 * `make test` - run the application, processing the input directory.
 * `make check_out` - check against the previous output to help ensure
    the job is end-to-end bitwise deterministic.  This is run
    automatically by `make test`.
 * `make clean` - reset the state by clearing the expected output

If you would like to run an individual bioinformatics *benchmark*,
there are other scripts to help with this under:
`/detmonad/benchmark_scripts/bioinfo`.

For instance, you can benchmark just the bwa program applied to a
singl sample input file with:

    HOWMANY=1 TRIALS=1 THREADSETTINGS=2 SUB_VARIANT=det_ld_preload ./bwa.sh

Finally, note that `detflow --rr-record`/`detflow --rr-replay` can run
the program through the Mozilla `rr` program.  However, we have not
yet been able to get `rr` running under containerization, so these
variants are not run automatically by the benchmarking container.

##### Section 7.2: Detmake

Unlike other DetIO programs such as `HelloWorld.hs` above, detmake is
precompiled as its own binary program, called `detmake`.  You can view
the options with `detmake -h`.  Detmake is meant to be a (very limited) drop-in
replacement for gnumake.  For example, `detmake -j3` uses three processors, just
like `make -j3`.  You can try it with your own (simple) Makefiles.  Some
modifications may be necessary if advanced GNU Make features are used.

The source code for `detmake` is located under `/detmonad/examples/detmake/app`.
`DetmakeLib.hs` contains the logic that emulates key features from GNU make,
while `Detmake.hs` the `DetIO` code which runs targets in parallel.

The detmake benchmarks are run in a similar manner as the bioinformatics ones.
Using scripts in `/detmonad/benchmark_scripts/detmake`, individual benchmarks
can be run with different options.  For example:

    BENCHMARK_NAME=06_splash/apps/barnes SUB_VARIANT=gnumake TRIALS=1 THREADSETTINGS=2 ./06_splash.sh

##### Further experiments

The microbenchmarks and apps we present here are a sampling of things which we
have shown to run deterministically under `detflow`. We encourage you to try
running `detflow` on your own scripts, and to shell out to other pieces of
software, in an attempt to find something which _isn't_ determinized! Be
forewarned that `detflow` is a prototype.

Using containerization is the first level of defense against
interference from environmental vagaries.  Detflow's file-system
permission's and libdet's libc interception are the second.  However,
libc-interception is not watertight: there is a large, known class of
holes in this approach, such as statically linked system calls and
directly nondeterministic x86 instructions.  (100% secure determinism
against even adversarial code is future work).  Nevertheless, we
believe the code which we have successfully determinized represents a
fair portion of real-world apps.
