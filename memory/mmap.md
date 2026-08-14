## Normal I/O
When you "normally" read/write to a file with your program, you basically make `read()` and `write()` syscalls. 

```
DISK                    KERNEL SPACE                  USER SPACE (your process)
┌──────────┐           ┌──────────────────┐          ┌─────────────────────┐
│          │  read()   │                  │  copy    │                     │
│ file.dat │ ────────► │   Page Cache     │ ───────► │   your buffer       │
│ (disk)   │           │   (RAM)          │          │   (RAM, e.g. []byte)│
│          │           │                  │          │                     │
└──────────┘           └──────────────────┘          └─────────────────────┘
                             ▲                                  │
                             │            write()               │
                             └──────────────────────────────────┘
                                        copy back
```

- You call `read(fd, buf, n)` (syscall) which switches to kernel mode
- Kernel checks: Is this already in page cache (RAM)? If not, directly pull it
- Kernel copies data from page cache to your user-space buffer (also in RAM)
- `write()` is the reverse: your buffer is copied to the page cache and the kernel flashes page cache to disk (asynchronously)
using `fsync`.

So there are two RAM copies of the same data existing simultaneously: one in the page cache, one in your buffer.

## mmap

```
DISK                    KERNEL SPACE                  USER SPACE (your process)
┌──────────┐           ┌──────────────────┐           ┌─────────────────────┐
│          │           │                  │           │                     │
│ file.dat │◄─────────►│   Page Cache     │◄────────► │  virtual address    │
│ (disk)   │  page-in/ │   (RAM)          │  mapped   │  space region       │
│          │  page-out │                  │  directly │  (points to same    │
└──────────┘  (lazy,   └──────────────────┘  (no copy)│   physical RAM      │
               on fault)                              │   pages)            │
                                                      └─────────────────────┘
```

- you call `mmap()`: This is a syscall which allocates an area in your process's virtual address space
- you try to access e.g. `data[1000]`. Is that in your page cache?
    - NO: you get a page fault and kernel loads the (4KB) page to page cache
    - YES: you get the page with data from page cache
- Writes to the mapped memory dirty that page; the kernel flushes it back to disk on its own schedule (or when you call `msync()`).


So basically you're reading/writing the same physical RAM that the page cache uses.