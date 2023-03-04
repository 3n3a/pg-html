# BENCH

> the source for these tests are in [tests.sql](./tests.sql)

## Equal output

I tested the two implementations, one in python and the other in sql and the output of both were equal.

## Performance

Now to the interesting part, which of the two functions produces the html in less time.

Both functions were tested ten times and the timing information was gathered in [pg-html-bench.ods](./pg-html-bench.ods).

> **TLDR**: the pl/python3 implementation takes half the time on average compared to the sql implementation.

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
