
![UPenn Logo]("images/upenn_logo.png")

<img align="right" src="images/upenn_logo.png">


## Background

In 2015 we asked ourselves why there was no available, deployable way
to run real Linux software deterministically.  Here,
*deterministically* simply means that the same bytes of input to the
software produce the same output bytes. We thus set out to create
user-space deterministic execution sandboxes.

## Research Project

### Detflow

Our first prototype, called DetFlow was described in a paper at
OOPSLA'17 [[1]](#oopsla).  DetFlow uses a mix of language-support and
runtime sandboxing to achieve an end-to-end determinism guarantee.

 * DetFlow is [available on GitHub](https://github.com/iu-parfunc/detflow/).
 * The OOPSLA paper's artifact is available [from the ACM DL here](https://dl.acm.org/citation.cfm?doid=3152284.3133897), under "Source Materials","Auxiliary Archive". It is a 5GB download.

### DetTrace

Our second prototype


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
