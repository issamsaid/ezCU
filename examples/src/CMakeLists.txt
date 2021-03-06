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
## 3. Neither the name of the copyright holder nor the names of its contributors
##    may be used to endorse or promote products derived from this software
##    without specific prior written permission.
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
## @file examples/src/CMakeLists.txt
## @author Issam SAID
## @brief CMake build script for the ezcu C/C++ examples.
##
cmake_minimum_required(VERSION 3.8 FATAL_ERROR)

project(c_examples LANGUAGES C CXX)

## Set the CUDA host compiler.
set(CUDA_HOST_COMPILER "${CMAKE_C_COMPILER}"
    CACHE FILEPATH "Host side compiler used by NVCC")
mark_as_advanced(CUDA_HOST_COMPILER)

## Include the ezcu headers
include_directories(${CMAKE_SOURCE_DIR}/include)

## Add a custom target that includes the build of all the C examples
add_custom_target(c_examples)

## Build all the subdirectories
file(GLOB sub_dirs RELATIVE ${CMAKE_SOURCE_DIR}/examples/src *)
foreach(dir ${sub_dirs})
	if(IS_DIRECTORY ${CMAKE_SOURCE_DIR}/examples/src/${dir})
		add_subdirectory(${dir})
        add_dependencies(c_examples ${dir})
	endif()
endforeach()

## workaround to install this target simultaneously with the main target.
## This is due to a cmake restriction: 
##  - Installing a target with the EXCLUDE_FROM_ALL target property 
##    set to TRUE has undefined behavior. 
##  
## first: inform the build location of the target. 
set (EZCU_C_EXAMPLES_FILES ${EZCU_C_EXAMPLES_FILES})
