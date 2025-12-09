# day 2

# part 1

## upseudocode

* get lengths of min and max ID in range
* iterate over lengths from min to max.
    * if not even we can skip : 12345-12349
    * split both IDs in half : 11-22 : 1,1 - 2,2
    * iterate between first halfs : 1-2
        * copy to second half of ID: 11, 22
        * check within bounds: min <= id <= max
        * acc += id


# part2

* repeating %s%s%s


123456
345678
len=6
depth=1
111111
n / 10^(len-1)

depth2
121212