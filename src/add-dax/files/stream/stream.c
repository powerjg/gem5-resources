#include <stdlib.h>
#include <sys/mman.h>
#include <string.h>
#include <gem5/m5ops.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
    // Stream array size. Each array is (1 << 22) * sizeof(int) = 16 MB
    const uint64_t STREAM_SIZE = 1 << 22;
    if (argc > 3)
    {
        printf("usage: # ./stream-shared <worker_id> <total_workers>");
        return -1;
    }

    // Parse the worker_id and total_workers
    int worker_id = atoi(argv[1]);
    int total_workers = atoi(argv[2]);

    if (worker_id >= total_workers)
    {
        printf("worker_id should be less than total_workers");
        return -1;
    }

    // Open the DAX device
    char dax_device[] = "/dev/dax0.0";
    int dax = open(dax_device, O_RDWR);
    if (dax < 0)
    {
        printf("Failed to open /dev/dax0.0\n");
        printf("Ensure this is the correct device: %s\n", dax_device);
        return -1;
    }

    // Map the DAX device to the virtual address space
    // We map a total of 3 * STREAM_SIZE * sizeof(int) = 48 MB since each
    // array is 16 MB
    int *mmap_addr = (int *)mmap(NULL, 3 * STREAM_SIZE * sizeof(int),
                                 PROT_READ | PROT_WRITE, MAP_SHARED, dax, 0);

    if (mmap_addr == MAP_FAILED)
    {
        printf("Failed to mmap\n");
        printf("Ensure the DAX device is at least 3 * %ld\n", STREAM_SIZE);
        return -1;
    }

    // Since there are a total of 3 arrays (A, B, and C), calculate the
    // start and end of each stream for the worker
    int *A = mmap_addr;
    int *B = mmap_addr + STREAM_SIZE;
    int *C = mmap_addr + 2 * STREAM_SIZE;
    uint64_t start = worker_id * (STREAM_SIZE / total_workers);

    m5_work_begin(0, 0); // Exit simulation to dump stats

    // Initialize the streams
    // A is initialized to 1
    // B is initialized to 2
    for (uint64_t i = start; i < (STREAM_SIZE / total_workers); i++)
    {
        A[i] = 1;
        B[i] = 2;
    }
    // C is initialized to 0
    memset(C, 0, (STREAM_SIZE / total_workers) * sizeof(int));

    ////////////////////////////// ADD OPERATION //////////////////////////////

    // Perform the stream operation
    for (uint64_t i = start; i < (STREAM_SIZE / total_workers); i++)
    {
        C[i] = A[i] + B[i];
    }

    m5_work_end(0, 0); // Exit simulation to dump stats

    munmap(mmap_addr, 3 * STREAM_SIZE * sizeof(int));
    close(dax);
}