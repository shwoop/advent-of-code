# Day 5


## Parallelism

### threads

### thread per range

```sh
$ unset CHUNK
$ time ./target/release/day5
./target/release/day5  122.18s user 0.17s system 454% cpu 26.908 total
```

## thread per 1m records in range
```sh
$ export CHUNK=1000000
$ time ./target/release/day5
./target/release/day5  136.79s user 0.68s system 732% cpu 18.776 total
```

## thread per 10m records in range
```sh
$ export CHUNK=10000000
$ time ./target/release/day5
./target/release/day5  137.31s user 0.54s system 734% cpu 18.778 total
```


### rayon

https://github.com/rayon-rs/rayon

```sh
$ unset CHUNK
$ export RAY=1
$ time ./target/release/day5
./target/release/day5  144.44s user 0.25s system 757% cpu 19.093 total
```
