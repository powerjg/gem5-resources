/*
 * A simple test to open /dev/dax and read data.
 * Assumes that someone has written a string starting at offset 0
 *
 * Run with ./test-read
 */

#include <iostream>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <cstring>

int main(int argc, char** argv) {
    // Open /dev/dax0.0
    int fd = open("/dev/dax0.0", O_RDWR);
    if (fd == -1) {
        std::cerr << "Failed to open /dev/dax0.0" << std::endl;
        return 1;
    }

    size_t page_size = 2 * 1024 * 1024;

    // Map the file into memory
    void* addr = mmap(nullptr, page_size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    if (addr == MAP_FAILED) {
        std::cerr << "Failed to map file into memory" << std::endl;
        perror("mmap");
        close(fd);
        return 1;
    }
    const char* data = "Hello, world!";

    // Read back the data
    char buffer[100];
    std::memcpy(buffer, addr, strlen(data));
    buffer[strlen(data)] = '\0';
    std::cout << "Read data: " << buffer << std::endl;

    // Unmap the file
    if (munmap(addr, page_size) == -1) {
        std::cerr << "Failed to unmap file" << std::endl;
        close(fd);
        return 1;
    }

    // Close the file
    if (close(fd) == -1) {
        std::cerr << "Failed to close file" << std::endl;
        return 1;
    }

    return 0;
}