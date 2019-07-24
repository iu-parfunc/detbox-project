
<img align="right" width="250" src="images/upenn_logo.png">

## Background

<img align="right" width="150" src="images/iu_logo.png">

In 2015 we asked ourselves why there was no available, deployable way
to run real Linux software deterministically.  Here,
*deterministically* simply means that the same bytes of input to the
software produce the same output bytes. We thus set out to create
user-space deterministic execution sandboxes.

## Research Project

### Detflow

Our first prototype, called DetFlow was described in a paper at
OOPSLA'17 [[1]](#references).  DetFlow uses a mix of language-support and
runtime sandboxing to achieve an end-to-end determinism guarantee.

 * DetFlow is [available on GitHub](https://github.com/iu-parfunc/detflow/).
 * The OOPSLA paper's artifact is available [from the ACM DL here](https://dl.acm.org/citation.cfm?doid=3152284.3133897), under "Source Materials","Auxiliary Archive". It is a 5GB download.

### DetTrace

Our second prototype


## Commercialization

The detbox approach is being commercialized by [Cloudseal
Inc](https://cloudseal.io).  Cloudseal is building low-overhead
record-and-replay-as-a-service, for bug and crash reproduction, but
the core is a deterministic execution capability that minimizes the
amount of recording needed, and eliminates unnecessary nondeterminism,
which leads to things like flaky tests.

### References

<a name="oopsla"></a>
 1. (OOPSLA'17) ["Monadic Composition for Deterministic, Parallel Batch Processing"](https://2017.splashcon.org/event/splash-2017-oopsla-detflow-a-monad-for-deterministic-parallel-shell-scripting), R Scott, O Navarro Leija, J Devietti, and R Newton, ACM SIGPLAN conference on Object-oriented Programming, Systems, Languages and Applications.

 2. (PLDI'16) ["Living on the edge: Rapid-toggling probes with cross modification on x86"](https://dl.acm.org/citation.cfm?id=3062344), B Chamith, B Svensson, L Dalessandro, R Newton. ACM SIGPLAN conference on Programming Language Design and Implementation.

 3. (PLDI'17) ["Instruction Punning: Lightweight Instrumentation for x86-64"](https://dl.acm.org/citation.cfm?id=2908084), Buddhika Chamith, Bo Joel Svensson, Luke Dalessandro, Ryan Newton. ACM SIGPLAN conference on Programming Language Design and Implementation.

