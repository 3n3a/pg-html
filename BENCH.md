# BENCH

> the source for these tests are in [tests.sql](./tests.sql)

## Equal output

I tested the two implementations, one in python and the other in sql and the output of both were equal.

## Performance

Now to the interesting part, which of the two functions produces the html in less time.

Both functions were tested ten times and the timing information was gathered in [pg-html-bench.ods](./pg-html-bench.ods).

> **TLDR**: the pl/python3 implementation takes half the time on average compared to the sql implementation.
> but when handling larger amounts of work the two implementations deliver about the same performance, even thought python is in the lead by a few ms.

### PSQL

* Median Execution Time: 0.620 ms
* Average Execution Time: 0.623 ms
* Median Planning Time: 0.021 ms
* Average Planning Time: 0.021 ms

### Python

* Median Execution Time: 0.381 ms
* Average Execution Time: 0.351 ms
* Median Planning Time: 0.020 ms
* Average Planning Time: 0.019 ms

## Discussion

My theory is that the performance optimisation in python regarding recursion are much more advanced
compared to pl/pgsql where the actual looping isn't of that high importance .
