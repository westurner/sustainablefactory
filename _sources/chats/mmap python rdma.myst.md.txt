---
kernelspec:
  display_name: Python 3
  language: python
  name: python3
---

# mmap python rdma

## Contents

* [Google Search Title:](#google-search-title)
* [Google Search AI Overview:](#google-search-ai-overview)
* [1. Create a memory-mapped buffer (e.g., for a file)](#chat-heading-3)
* [Map the file into memory](#map-the-file-into-memory)
* [2. Register the mmap buffer with the RDMA stack](#chat-heading-5)
* [(Specific API call will be in the python-rdma documentation)](#specific-api-call-will-be-in-the-python-rdma-documentation)
* [pd = ... # Get a Protection Domain object](#pd-get-a-protection-domain-object)
* [mr = pd.reg_mr(mm) # Register the mmap object as a Memory Region](#chat-heading-8)
* [3. Use the MR for RDMA operations](#chat-heading-9)
* [qp = ... # Get a Queue Pair object](#qp-get-a-queue-pair-object)
* [qp.post_recv(mr, ...)](#chat-heading-11)
* [qp.post_send(mr, ...)](#chat-heading-12)
* [... RDMA communication logic ...](#chat-heading-13)
* [Close the mmap object (unmaps the memory)](#close-the-mmap-object-unmaps-the-memory)

(google-search-title)=
Google Search Title:
====================

mmap python rdma


(google-search-ai-overview)=
Google Search AI Overview:
==========================


The

`mmap` module in Python can be used with RDMA by registering the memory-mapped regions with the RDMA stack, typically via the `python-rdma` library. This allows RDMA operations to directly access data in the memory-mapped buffer, bypassing extra data copies between the application and the OS kernel, which is a key benefit of RDMA. 

Key Components 

*   **`mmap` Module**: The built-in [Python `mmap` module](https://docs.python.org/3/library/mmap.html) provides an interface to the operating system's `mmap` system call, which maps a file or anonymous memory into a process's virtual address space.
*   **`python-rdma` Library**: This third-party library provides a Python API for the Linux RDMA stack (libibverbs, etc.). It allows you to manage RDMA resources like Protection Domains (PD), Memory Regions (MR), and Queue Pairs (QP). 

How it Works 

To use `mmap` memory with RDMA in Python, the general process involves: 

1.  **Allocate Memory with `mmap`**: Use the Python `mmap` module to create a memory buffer, either backed by a file or as anonymous memory for inter-process communication (IPC).
2.  **Register as an RDMA Memory Region (MR)**: The virtual memory address obtained from `mmap` must be registered with the RDMA device through the `python-rdma` library's APIs. This registration process involves "pinning" the memory pages in physical RAM so they are not swapped out, which is necessary for the NIC (Network Interface Card) to perform direct memory access.
3.  **Perform RDMA Operations**: Once the memory region is registered, the buffer can be used as the target or source for zero-copy RDMA operations (e.g., RDMA Read, Write, Send). The NIC then translates the virtual addresses to physical addresses and transfers data directly. 

Benefits 

*   **Zero-Copy Networking**: The primary advantage is eliminating unnecessary data copies between the application's buffer and the kernel's network buffers, leading to higher performance and lower latency.
*   **Efficient I/O**: `mmap` itself is an efficient way to handle large files or shared memory, and combining it with RDMA leverages this efficiency for network operations. 

Example (Conceptual) 

While specific implementation details depend on the `python-rdma` version, the core idea is to obtain the memory buffer from the `mmap` object and use the library's `register_mr` (Memory Region) equivalent function. 

python

    import mmap
    import rdma  # This requires the python-rdma library

(chat-heading-3)=
    # 1. Create a memory-mapped buffer (e.g., for a file)
    with open("large_data.bin", "r+b") as f:
(map-the-file-into-memory)=
        # Map the file into memory
        mm = mmap.mmap(f.fileno(), 0) # 0 means map the entire file

(chat-heading-5)=
        # 2. Register the mmap buffer with the RDMA stack
(specific-api-call-will-be-in-the-python-rdma-documentation)=
        # (Specific API call will be in the python-rdma documentation)
(pd-get-a-protection-domain-object)=
        # pd = ... # Get a Protection Domain object
(chat-heading-8)=
        # mr = pd.reg_mr(mm) # Register the mmap object as a Memory Region

(chat-heading-9)=
        # 3. Use the MR for RDMA operations
(qp-get-a-queue-pair-object)=
        # qp = ... # Get a Queue Pair object
(chat-heading-11)=
        # qp.post_recv(mr, ...)
(chat-heading-12)=
        # qp.post_send(mr, ...)

(chat-heading-13)=
        # ... RDMA communication logic ...

(close-the-mmap-object-unmaps-the-memory)=
        # Close the mmap object (unmaps the memory)
        mm.close()


Copied to clipboard

For official documentation and usage examples of the `python-rdma` library, refer to its [GitHub repository](https://github.com/jgunthorpe/python-rdma). 

*   [](https://github.com/jgunthorpe/python-rdma#:~:text=This%20package%20contains%20the%20Python,code%20is%20available%20on%20GitHub.)

    jgunthorpe/python-rdma - GitHub

    Aug 21, 2017 — This package contains the Python module rdma which provides a Python API for the Linux RDMA stack. It is an amalgamation of the fu...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    GitHub

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

*   [](https://stackoverflow.com/questions/33971851/what-happens-when-rdma-operates-over-mmaped-region)

    What happens when RDMA operates over mmaped region?

    Nov 28, 2015 — What happens when RDMA operates over mmaped region? ... RDMA is an efficient way to bypass the useless data copies between applica...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Stack Overflow

*   [](https://www.oracle.com/database/technologies/exadata/hardware/rdmanetwork/#:~:text=RDMA%20\(Remote%20Direct%20Memory%20Access,and%20with%20very%20low%20latency.)

    RDMA Network Fabric | Oracle Exadata Database Machine

    RDMA (Remote Direct Memory Access) allows one computer to directly access data from another without operating system or CPU involv...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Oracle

*   [](https://docs.python.org/3/library/mmap.html#:~:text=In%20either%20case%20you%20must%20provide%20a,file%20object%2C%20use%20its%20fileno\(\)%20method%20to)

    mmap — Memory-mapped file support — Python 3.14.3 ...

    Mar 7, 2026 — In either case you must provide a file descriptor for a file opened for update. If you wish to map an existing Python file object,

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Python documentation

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

*   [](https://www.reddit.com/r/C_Programming/comments/j1dxpu/python_mmap_mlock_wrapper/#:~:text=Hi%20!,Thanks%20!)

    Python mmap / mlock wrapper : r/C\_Programming - Reddit

    Sep 28, 2020 — Hi ! I'm running a python 3.8 program that is in charge of manipulating cryptographic materials (keys gen, encrypt, decrypt). And ...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Reddit

*   [](https://realpython.com/python-mmap/#:~:text=Python's%20mmap%20provides%20memory%2Dmapped,lot%20of%20file%20I/O.)

    Python mmap: Improved File I/O With Memory Mapping

    Aug 24, 2020 — Python mmap: Improved File I/O With Memory Mapping. ... The Zen of Python has a lot of wisdom to offer. One especially useful idea...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Real Python

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

*   [](https://github.com/offchan42/python-mmap-ipc#:~:text=This%20repository%20is%20an%20example,from%20one%20process%20to%20another.)

    GitHub - offchan42/python-mmap-ipc: :zap: Fast inter-process ...

    This repository is an example on how to do fast inter-process communication using memory mapped file in python. It is designed to ...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    GitHub

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

*   [](https://en.wikipedia.org/wiki/Mmap#:~:text=In%20computing%2C%20mmap\(2\),no%20physical%20RAM%20at%20all.)

    mmap - Wikipedia

    In computing, mmap(2) is a POSIX-compliant Unix system call that maps files or devices into memory. It is a method of memory-mappe...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Wikipedia

*   [](https://programmingappliedai.substack.com/p/what-is-mmap-in-linux-and-how-it)

    What is MMAP in Linux and how it is useful?

    Dec 30, 2024 — mmap (memory-mapped file) is a system call that maps a file or a portion of it into a process's virtual memory space. ... This all...

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

    Substack

    ![](data:image/gif;base64,R0lGODlhAQABAIAAAP///////yH5BAEKAAEALAAAAAABAAEAAAICTAEAOw==)

*   [](https://stackoverflow.com/questions/33971851/what-happens-when-rdma-operates-over-mmaped-region#:~:text=1%20Answer.%20Yes%2C%20you%20can%20register%20with,be%20registered%2C%20including%2C%20but%20not%20limited%20to:)

    What happens when RDMA operates over mmaped region?

    Nov 28, 2015 — 1 Answer. Yes, you can register with RDMA a region of memory mapped using mmap() . See the docs for ibv\_reg\_mr (http://www.rdmamoj...

    ![](https://encrypted-tbn3.gstatic.com/faviconV2?url=https://stackoverflow.com&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)

    Stack Overflow

*   [](https://www.ibm.com/docs/pl/aix/7.3.0?topic=m-mmap-mmap64-subroutine#:~:text=The%20mmap%20subroutine%20creates%20a%20new%20mapped,if%20the%20program%20attempts%20to%20map%20itself.)

    mmap or mmap64 Subroutine

    The mmap subroutine creates a new mapped file or anonymous memory region by establishing a mapping between a process-address space...

    ![](https://encrypted-tbn2.gstatic.com/faviconV2?url=https://www.ibm.com&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)

    IBM

*   [](https://www.youtube.com/watch?v=ky1n6luzL3Y)

    File I/O With Memory Mapping Using Python mmap

    Jun 23, 2022 — welcome to python mmap doing file i o with memory mapping my name is christopher. and i will be your guide. this course is about t...

    ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAwFBMVEUVNUwSM0sNMUkAJUEuRlo+UmUAKkTKz9S4vsSFkJqDjZcAJkEbOVDd4eUnQVYAHzwAETTU2d3Bx82psbgAHjzu8PIABDFHWmsALUaYoqsAK0bp6u2PmKJzf4ustLspXHz///9PYnIgSmYwbJA8ha83YHYZNkhdbHpfbnwneqwTdq+koGvXtj4AJE1Efp3WuUv/1jzkwUAAFzk2TWASP11ccW3/4Dm8pENmZUkAACguQUjzzEBOV0oAGzsAABsAACHQQO+gAAABdUlEQVR4AczRVYKkMBRA0YRoER4OFSGpMEa70O77X9W4wNh35/eeOHpVA+P/5oRQxv/XqZCb9LtQf1k+g7woqyz52uvkD8AbVuG267eaK94CRggna2CsI0NTN34TNhQ0QrtdhpciQ5DFEaiHPOZgkzdv373/sBRYuzilodkTe9EC2b3bPzg8Ol6AvOmq0cuyFo1TULw9OT09O18CXFTbapbNRbcHForLq+ujm1u7BFzeVV5daDUDDnv2/uHocdWLyfi2Si3i2lOVIHx8vLpnW4ftlM4llIbrv/yJCqknmSie3F339Ldv4zWtSi9J6Z7dzHGWJ1yjpdKbUdx17Gmv844MM4St8W61DJmkGEqJOwqmvgDvRVNfLETCTEzTOfbupQvBS3MRvbhYXANfDM0LTLF0L3FP7kmp4rwCSPvQVw2o0HdPgg57ieirFUBo1NPorMIXhWRKI6s9XV82SaYL1yKEkfoW/ngvfBFY8mn4kz0bUH5wAgCtOiDtyPnzkwAAAABJRU5ErkJggg==)

    ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAcElEQVR4AWP4//8/RZh6BgCZAkDsAMUNWDFCXgDFACCV8J/B+D8pGKwHRAKRAUyQDEMMQAYEUGBAAsiABpwKHjz4/9/BAZ8BDXgNgIMNGyg04MABkg1AeCEgAK8XKA5EiqORooSELykXEJuUBz43AgAIA1ZhBoG9vwAAAABJRU5ErkJggg==)

    YouTube·Real Python

    ![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcR1m8W7PR3GEm6PR-vkWxBlI7wIaqAgDmT_pvOSteMBI3_JNSvn)

    23:02

*   [](https://docs.nvidia.com/networking/display/public/sol/howto+configure+pvrdma+in+vmware+vsphere+6-5+and+6-7#:~:text=Zero%2Dcopy%20%2D%20Allows%20applications%20to%20perform%20data,without%20being%20copied%20between%20the%20network%20layers.)

    HowTo Configure PVRDMA in VMware vSphere 6.5 and 6.7 - NVIDIA Docs

    Aug 8, 2019 — Zero-copy - Allows applications to perform data transfers without involving the network software stack. Data is sent and received ...

    ![](https://encrypted-tbn0.gstatic.com/faviconV2?url=https://docs.nvidia.com&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)

    NVIDIA Docs

    ![](https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTBzVpCkE1ePa0IL_TvTJP8iKP6qwnawwsKK4TsGCcSZWivTuEU)

*   [](https://www.linkedin.com/pulse/rdma-networking-trends-rakesh-cheerla-izpuc#:~:text=Low%20Latency%20and%20Memory%20Efficiency:%20RDMA%20bypasses,and%20zero%2Dcopy%20features%20minimize%20latency%20and%20jitter.)

    RDMA Networking Trends - Rakesh Cheerla

    Oct 12, 2023 — Low Latency and Memory Efficiency: RDMA bypasses the Linux kernel and directly transfers data to application buffers, a feature kn...

    ![](https://encrypted-tbn2.gstatic.com/faviconV2?url=https://www.linkedin.com&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)

    LinkedIn

    ![](https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcSbQEn3hGkyVe5spo0rbk0Ws4cODoCzvqKWAwftEWeIAjllefpC)

*   [](https://www.lr-link.com/newsdetail/695.html#:~:text=In%20addition%2C%20RDMA%20also%20supports%20features%20such,further%20improve%20the%20efficiency%20of%20data%20transmission.)

    What is RDMA?

    Jul 24, 2025 — In addition, RDMA also supports features such as zero copy and kernel bypass, which can further improve the efficiency of data tra...

    ![](https://encrypted-tbn0.gstatic.com/faviconV2?url=https://www.lr-link.com&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)

    LR-LINK

    ![](https://encrypted-tbn2.gstatic.com/images?q=tbn:ANd9GcTuz1Ew6qlvvCrjJtJZDZjBEpyt5tICbjs7k2bSl8dt-hV52kgF)

*   [](https://github.com/syoyo/python-rdma-examples#:~:text=These%20are%20example%20scripts%20utilizing%20Python%20RDMA%20\(%20https://github.com/jgunthorpe/python%2Drdma%20\)%20.)

    syoyo/python-rdma-examples - GitHub

    These are example scripts utilizing Python RDMA ( https://github.com/jgunthorpe/python-rdma ) .

    ![](https://encrypted-tbn2.gstatic.com/faviconV2?url=https://github.com&client=AIM&size=128&type=FAVICON&fallback_opts=TYPE,SIZE,URL)

    GitHub


*   [](https://github.com/jgunthorpe/python-rdma#:~:text=This%20package%20contains%20the%20Python,code%20is%20available%20on%20GitHub.)

    jgunthorpe/python-rdma - GitHub

    Aug 21, 2017 — This package contains the Python module rdma which provides a Python API for the Linux RDMA stack. It is an amalgamation of the fu...

    ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAMAAABEpIrGAAAAb1BMVEX///8kKS74+PgsMTY+Q0f8/Pzw8PGRk5ZNUVXr6+xDSEzCxMUpLjLV1tYuMzc/Q0i3ubuUl5lbX2NTV1uLjpFKTlKxs7Xh4uOFh4rn5+h3en1vcnZ9gIPc3d6/wcJzd3o3PECmqKpjZ2rOz9CfoaRP5W5KAAABU0lEQVQ4jW1T7aKCIAzdEEUTSUuzLMtuvf8zXtiQVDx/lJ3DvgEIEPU9l1rL/F4LiFEMCQYkj2JDC6VxhaRJl3x2xgin7MePMuYRD7cQftrjrcL7ELk9nNt8yXXtyRm5mquzXADKA6LpzgZRlgBPZ1WO7yn/yrmqyGdGn95Zjav2hbNghZHMV3uNG3DZCigEmhRq+pmyrUAcifj4CO+49xciWqAe6p3pCJrNH1ATp5gH6KghQLrDnoB8GxaYPYFkhpONipjrl+wI61hQ8tB5EvYb4eTL5Ebhd8u/2f4EYfhvvWJpw9ZJ0LQfb5uxbMKi3pp5xVp30miexZHbRriHvUnojrKt7isXqWRBFQQNF2w3aYCPUl8/EREWzxtuE+pVI/wbkSGp0a51Nyg1F+L5/nel56xXgt+zcMgeC0FK27gdTzVoPXtI9DBuO2tRhJj94m3/A1GiDZXoM3d5AAAAAElFTkSuQmCC)

    GitHub

    ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAFIAAABSCAMAAADw8nOpAAAATlBMVEXw8PBN0YHz8fPk7ec2znU+z3n48vbE5s9H0H6E2aNCz3ve7OOr4b1r1ZOD2qK/5cwjzG3J59Nz1pd82J4tzXGQ3KuW3a+f37X98/pi1I2cdTi7AAAAzUlEQVRYhe3XyQ6DIBSFYYpMUgWHju//ol16INHQimmann8L99vCFYL9Z02FMnFQuxuiTEh12p22JEmSPJx0STVIN7VhaV43y0k9GqjxNUi8Kc8kSZI8nhw05FZvZqTDqUv62xDRQldXRrpphKmYfYokZDpfSLYG58R68g1ygyFJkiRJkiRJfoXUsDspC++/afDIh2Iyzu1SuHXQPeBRV0oKicvTo9d+SZukUjHze/x0uc8QkiRJViKfCvYlVYXEdcnaGmSyZW3uS+wXegGxvSCoeZ1U1gAAAABJRU5ErkJggg==)

*   [](https://stackoverflow.com/questions/33971851/what-happens-when-rdma-operates-over-mmaped-region)

    What happens when RDMA operates over mmaped region?

    Nov 28, 2015 — What happens when RDMA operates over mmaped region? ... RDMA is an efficient way to bypass the useless data copies between applica...

    ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAIAAAACACAMAAAD04JH5AAAAflBMVEX/XgAgHB0dGx0AFx4tHxzMTwn1WwD/YQAaGx0OGR4YGh2IOhESGh0AGB0VGh4SGR7BSwudQBC6SQxFJxo1IhskHhwAEx+NOxIeHRyyRw3rWATkVgXZUwhVKxnSUQhuMhd6NhOBNxQ7JBqUPRGmQw9iLxhnMBZ1NBZbLBlKJxk8C7FfAAAELklEQVR4nO2Z67aiOBCFMcGEQECuXrgpiJfz/i84AfUIId3tmSlg9azsv7qsz6pNVSUYhpaWlpaWlpaWltZ/Ew12y8Y/uO6ZLhmfIcSb5eL7CVqt0L5ZKAfUN62VEOKHRQhEfHvVyUoOS8TPX/FbAn/+HPjv+ILAmj0H6358QWDO7YMjXg1kWeG8AOTCJYIknDcH6Z1JBGY5cxXucg5W/rwAoxzYcT5zFQqZoM5mBRAEUhU2UT4vQRl7QwIekVkBaCYTbKJ5q0DXtZyDIp00Yi6nuIxtiSCakiCLC6nlUmkqiCoUE1bhzLz9MRs+7b5MwKPJ4meuWIDY/pz2EWiZSARsMh+cus6D8H1QBzrOwWWap7FbQruWx479OgsfWHIOpiAgx3frZcmuVwcaJhIBr+AJaNhvvIgV/eE3IvBu4IOJSHm2t9fyTee7aEiAT8A5oI3U88QTH1fG63/SQCZAwMfGvLZkAFGHuCEvhIYPCZBbgQLs8Ci+kOUeX5vYKAeIg+Ygv3qjGnR1ML+LfZZzYFeQTqTh3UMKAsTq1wE5cKXP8A7UieTsMhWC5d6edXDkKlgBJIBB05vc95914NWj/QcSIdpCH5nCCCvrgKNDl+3dMAfDng0iEiClFWx+afsScXqrMnKhu1ErmlXuuCUIedhp/+77eUV7Z5qDAvFrZR1W7Cug1Di5r7KcJwnfqYmZisDCtRhR1aNhuMGEByWaO66yL9lJlfrd2MSn6cJ38guusoLoS3FbH3aD81++JopkUqOJuIJghdr4Xg0W3qBFcnd8g44gaH7aKusgzBCv4QAMjGyGcR2UqSFB0PxuKR9JG/K+ZI2fDudF1eQSA2kSxXxgkAsZ3X0/cTb3zK+qJAN7pVUi18GqQQ8Gl/7vI4th69b0bUn9y7AvIQR6ZZZHcpXRhpn3KiTftiQH3q/D5gIZ3whVRu9sGQVl9rAEJU6y+f6Mw07As7LpPm35dWryRyLWV/zMFIZ9h0EK5QryYmBeEjl+Srq+9HQgbAJSrhx8vWoIWybH1pZZ3X6VA89AX7mOyxCeaxYnx2zfoCDYmzJ6U49+RSI2m/abmyPwEF6fYow96zMKIbf882/+VHlwrRP2Oy++ZU9yM0BpFu4KjpXb6FBsqrd41Eizw7WdBsrp9xKKJ6jAG4Ia/vlaq49HzwrcJ4z/gCC57yRb/ItEsIkWcVlpc432zB5nAs91XS4sEZ7vlrDlcBDzmeI/GEgWXkzEN2+G6S0gQ1BjHdxixp6OYLCn8Q8hhC2r+HEcc2d+b/VCECrbmYVM8C6QrT9TGbRriwX+voTu9uZnSh4ehL4mpw5Dn6mzgHeEnkTU+eVCqOyDoNdy/wZgtzAAXxwA/E5EA/x1AEubEH4f+nEjAo5v0GqLf6DtFfxQQH4o6PhaWlpaWlpaWlpaWlr/f/0DViY+xu94gUsAAAAASUVORK5CYII=)

    Stack Overflow

*   [](https://www.oracle.com/database/technologies/exadata/hardware/rdmanetwork/#:~:text=RDMA%20\(Remote%20Direct%20Memory%20Access,and%20with%20very%20low%20latency.)

    RDMA Network Fabric | Oracle Exadata Database Machine

    RDMA (Remote Direct Memory Access) allows one computer to directly access data from another without operating system or CPU involv...

    ![](data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAACAAAAAgCAYAAABzenr0AAAEoklEQVRYhbWXTYgdRRDHf1Xd72M3ZmM+BMFLVBDRKHgSScSjGlASjBoRBBMRPXjIQQXxKIh6iOghomI8BBFjIOIhns3m4kFJQDCioARviclqNvvem+kqDz2zb968jcS4KRh6uru6//+u7qqultfeeJ2miDdrEaEHHgFQz99YDBhWJZWOjnslf179VxoAeFWP0hgANgUQzYBymcAESTHcDWRMAK8hsp5WJKhKrVRDVcZgTQJNU2Twno0qZZtScTXcvNU6PV+pMKpWLCgdg16CmCBuGJQTK24S6CRjxpzgNu4TYwypmPuyOamsWZtbPVshKSx1oBQlGnQTrCmgkyDesnBpZQJA8JIZH9KxMcnxXmZJPtngMmkBcUgCo5jLYEq/hLWjTCTeeOmvKZPVe6yU23oM7w1e3gr0gZa9DWs35S0QYAD8AnxnMF+E3NtJmcBsURFYP7owRUBhPdhLYDtU0t2KheW+Jp4YWNE6hBNekFw4acJXmngvGBe6Sekl6JYQHOTM7u2T4M4+4B3EAhgiMgaj7aaGeAGSGpyWueIy3rJglNF5OSZ9t5MyuDpEpHkIOWzCrgkAndxjbdWMCMQVFcTHbgdEg/2lcl8SnqwWS2wcvC+gCb4s3wDfAn/C9CF0X9GNBVivwgM4D9ZWszz+CQQDnqJB/Rng8dYkx4AXgd9XQrhCeRPYDBwAHmq07wa+Bj5ToAd80Bp4ENj+P8Fr+Q14GPi01f4h0FHy6mcaHT8Be1YBuC3PAqcb9TXA0wrsaCm+cg3Aa3m1Vd+pwJZGw0XyobtWcqzCqGWLApsaDaeBYrXQxKFj+VMHF0Yu/NyI3pui6ERokfYk07fdlUsw6Bd50qUOFAJJUK36guW4ebYx5nayV6yKuEARoNAcA1zom3BbKbltFDmrwKnGmFngkdUiMAxwoQ/nZ2CQI86jwGxSWOzCQo+TChxpjXt7tQh4tdJiHCzfgnwtDyJc7HJEgUNA806+GTi8GgRClXz0S+gYXwZjc70tg8j5Sx0+VyAxHXh2AceBO1aBx53AfFIeS5o9o5dgbsiejUtYfRccAT5pEdkG/AicAI6LyrmVZv8XL9mYlPsLZWsN3LGciFw/4KPZgqMxQVy7lEgKSdmbBE/KXgCtPNLdtwJbpX0N1gT88m5qkH1QchzoGPRLPp4b8jwDoIQ4d3EIAUY9WIo8NxROuLA/GOsApM7xLoPjPp0t16JWEchZ8EK/YN/agoM0UpBI6uWc3aBwGDkHk3AoqL6gsFORu9QnouUkgcsxAwo4VwqngKMKBzpCUQj06qRJIC7MbqQIOVINIowClEohIu9H44euyz3BuElEJgJU2/QrbMWoCPyxGPk+KfPdAIsB/g7Qj9k7gkP8dd0GUiNilQFKAVRQmO8lmQ/OODe8cgIU1XsgaX6E9FJ+C3RTPg/iEE/dMLc8oAqXlAopZMAgglwlgfpdWFmbaONP6qT0zHWzBM9BI1oelBSKKJjk56leJYG21KAwLuNiVwmVfzYtUVbZsCbJ5voPBGqPNfJimul5XdbacRRyZpo0W0HIA2oFrZm3VjMVfxr14NOgzWd63ecC/wDOqvk4G7oeyQAAAABJRU5ErkJggg==)

    Oracle


Show all
