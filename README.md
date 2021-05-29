This is a benchmark to test if 4k aliasing can be defeated by delaying AGU of stores that load will incorrectly match with in the SB.

Example with `ALIGN_SRC = (2048 - 128)` and `ALIGN_DST = (2048)`

With `ALIAS_SAFE = 1`

```
taskset -c 0 sudo perf stat --all-user -e cycles ./copy

 Performance counter stats for './copy':

     1,291,478,413      cycles                                                      

       0.288596025 seconds time elapsed

       0.288575000 seconds user
       0.000000000 seconds sys
```

With `ALIAS_SAFE = 0`

```
taskset -c 0 sudo perf stat --all-user -e cycles ./copy

 Performance counter stats for './copy':

     1,502,020,511      cycles                                                      

       0.334462737 seconds time elapsed

       0.334426000 seconds user
       0.000000000 seconds sys
```


Note that the performance of the aliasing safe version is slower when there is no 4k aliasing.

My hypothesis for why this "works" is that 4k aliasing occurs when a stores address is known and matches the lower 12 bits of a load checking the SB. If the stores address, however, is not known, then the load will predict to alias or not. If it predicts not to alias then it will be able to execute out of order with the store, and since there is in fact no actual aliasing no machine clear or any other event will occur so it will ultimately be a speedup to the serialization 4k aliasing can cause.

This is a followup to @LewisKelseys and @BeeOnRopes excellent explinations of the process [here on SO](https://stackoverflow.com/a/65949599/11322131)

