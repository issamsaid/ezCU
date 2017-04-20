##
## @copyright Copyright (c) 2016-, Issam SAID <said.issam@gmail.com>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##
## 1. Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
## 2. Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
## 3. Neither the name of the copyright holder nor the names of its 
##    contributors may be used to endorse or promote products derived from 
##    this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
## INCLUDING, BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY AND FITNESS
## FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
## HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
## SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
## PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
## LIABILITY, WETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
## NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
## SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## @file test/CMakeLists.txt
## @author Issam SAID
## @brief CMake build script for the ezCU unit testing.
##
project (build_tests)
cmake_minimum_required (VERSION 2.8)

## Set the CUDA host compiler.
set(CUDA_HOST_COMPILER "${CMAKE_CXX_COMPILER}"
    CACHE FILEPATH "Host side compiler used by NVCC")
mark_as_advanced(CUDA_HOST_COMPILER)

## Build the ezCU C/C++ unit tests.
add_subdirectory(src)

## Build the ezCU fortran interface unit tests.
add_subdirectory(fortran_interface)

## Add a custom target that includes the build of all the tests
add_custom_target(build_tests)
add_dependencies(build_tests ezcu_test ezcu_test_fortran)