## Background

In 2015 we asked ourselves why there was no available, deployable way
to run real Linux software deterministically.  Here,
*deterministically* simply means that the same bytes of input to the
software produce the same output bytes. We thus set out to create
user-space deterministic execution sandboxes.

### Detflow

Our first prototype, called DetFlow

was described in a paper at OOPSLA'17 [[1]](#oopsla).

is available [on GitHub here](https://github.com/iu-parfunc/detflow/)





### DetTrace


## Commercialization

The approach developed in the detbox project is being commercialized
by [Cloudseal Inc](https://cloudseal.io).  Cloudseal is developing
low-overhead record-and-replay-as-a-service, but the core is a
deterministic execution capability that minimizes the amount of
recording needed.

### References

<a name="oopsla"></a>
 1. R. G. Scott, O. S. Navarro Leija, J. Devietti, and R. R. Newton. ["Monadic Composition for Deterministic, Parallel Batch Processing"](https://2017.splashcon.org/event/splash-2017-oopsla-detflow-a-monad-for-deterministic-parallel-shell-scripting), OOPSLA 2017.


<a name="chapter-1"></a>
