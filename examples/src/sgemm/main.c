///
/// @copyright Copyright (c) 2016-, Issam SAID <said.issam@gmail.com>
/// All rights reserved.
///
/// Redistribution and use in source and binary forms, with or without
/// modification, are permitted provided that the following conditions
/// are met:
///
/// 1. Redistributions of source code must retain the above copyright
///    notice, this list of conditions and the following disclaimer.
/// 2. Redistributions in binary form must reproduce the above copyright
///    notice, this list of conditions and the following disclaimer in the
///    documentation and/or other materials provided with the distribution.
/// 3. Neither the name of the UPMC nor the names of its contributors
///    may be used to endorse or promote products derived from this software
///    without specific prior written permission.
///
/// THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
/// INCLUDING, BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY AND FITNESS
/// FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE UPMC OR
/// ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
/// EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
/// PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
/// PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
/// LIABILITY, WETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
/// NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
/// SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
///
/// @file sgemm/main.c
/// @author Issam SAID
/// @brief An example of matrix to matrix multiplication code based on 
/// the ezcu C/C++ interface.
///
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <string.h>
#include <ezcu/ezcu.h>

///
/// @brief The main program of the ezcu based sgemm C/C++ example.
///
/// This is the main routine that shows how to use the ezcu C/C++ interface 
/// to implement a simple matrix to matrix multiplication.
/// Note that the OpenCL kernel is implemented in a seperate file (sgemm.cl).
/// @return Error code if any.
///
int main(void) {
    unsigned int i;
    float  *a;
    float  *b;
    float  *c;     
    const int N = 1024;
    unsigned int grid[3]  = {N/16, N/16, 1};
    unsigned int block[3] = {16, 16, 1};
   
    ezcu_dev_t device;

    fprintf(stdout, "... start of the ezcu sgemm C/C++ example\n");

    ///
    ///< Initialize ezcu with selecting the default GPU.
    ///
    ezcu_init();

    ///
    ///< Load the OpenCL kernel that runs the multiplication.
    ///
    ezcu_load(PREFIX"/sgemm.cu", NULL);

    ///
    ///< Get a pointer to the desired device (in this case the default GPU).
    ///
    device = ezcu_dev_find(0);

    a = (float*)malloc(N*N*sizeof(float));
    b = (float*)malloc(N*N*sizeof(float));
    c = (float*)malloc(N*N*sizeof(float));

    memset(c,   0, N*N*sizeof(float));
    srand (time(NULL));
#pragma omp parallel for private(i)
    for (i = 0; i< N*N; ++i) a[i]  = i%2 == 0 ? -rand()%10 : rand()%10;
#pragma omp parallel for private(i)
    for (i = 0; i< N*N; ++i) b[i]  = 1;

    /// 
    ///< Wrap the matrices into ezcu memory objects.
    ///
    ezcu_mem_wrap(device, a, N*N, FLOAT | READ_ONLY  | HWA);
    ezcu_mem_wrap(device, b, N*N, FLOAT | READ_ONLY  | HWA);
    ezcu_mem_wrap(device, c, N*N, FLOAT | READ_WRITE | HWA);

    ///
    ///< Set the work size and the dimensions of the kernel.
    ///
    ezcu_knl_set_wrk("sgemm", 2, grid, block);

    /// 
    ///< Run the kernel on the default GPU.
    ///
    ezcu_knl_run("sgemm", device, a, b, c, N);

    ///
    ///< Update the C matrix on the CPU side so that the results can be seen
    ///< on the host side.
    ///
    ezcu_mem_update(c, READ_ONLY);

    free(a);
    free(b);
    free(c);

    ///
    ///< Release ezcu resources.
    ///
    ezcu_release();
    fprintf(stdout, "... end   of the ezcu sgemm C/C++ example\n");
    return EXIT_SUCCESS;
}
