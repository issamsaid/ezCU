!>
!! @copyright Copyright (c) 2016-, Issam SAID <said.issam@gmail.com>
!! All rights reserved.
!!
!! Redistribution and use in source and binary forms, with or without
!! modification, are permitted provided that the following conditions
!! are met:
!!
!! 1. Redistributions of source code must retain the above copyright
!!    notice, this list of conditions and the following disclaimer.
!! 2. Redistributions in binary form must reproduce the above copyright
!!    notice, this list of conditions and the following disclaimer inthe
!!    documentation and/or other materials provided with the distribution.
!! 3. Neither the name of the copyright holder nor the names of its contributors
!!    may be used to endorse or promote products derived from this software
!!    without specific prior written permission.
!!
!! THIS SOFTWARE IS PROVIDED "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES,
!! INCLUDING, BUT NOT LIMITED TO, WARRANTIES OF MERCHANTABILITY AND FITNESS
!! FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT 
!! HOLDER OR ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, 
!! SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
!! PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
!! PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF 
!! LIABILITY, WETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
!! NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
!! SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
!!
!! @file m_mem_test.f90
!! @author Issam SAID
!! @brief Unit testing file for the ezcu Fortran interface for CUDA
!! memory objects manipulation routines.
!<
module m_mem_test
    use, intrinsic :: iso_c_binding
    use            :: m_ezcu_flags
    use            :: m_ezcu_types
    use            :: m_ezcu_base
    use            :: m_ezcu_dev
    use            :: m_ezcu_mem
    use            :: m_ezcu_util
    use            :: m_handler
    
    implicit none

    private

    public :: mem_test

    integer, parameter :: N = 64
    type(ezcu_dev_t), pointer :: d

contains
  
    logical function wrap_buffer() result(status)
        real :: h(N)
        call ezcu_mem_wrap(h, d, N, FLOAT)
        status = associated(d) 
    end function wrap_buffer
    
    logical function wrap_allocatable() result(status)
        real, allocatable :: h(:)
        allocate(h(N)) 
        call ezcu_mem_wrap(h, d, FLOAT)
        status = associated(d) 
        deallocate(h)
    end function wrap_allocatable

    logical function wrap_pointer() result(status)
        real, pointer, dimension(:) :: h
        allocate(h(N)) 
        call ezcu_mem_wrap_ptr(h, d, FLOAT)
        status = associated(d) 
        deallocate(h)
    end function wrap_pointer

    logical function read_access_buffer() result(status)
        real, allocatable :: h(:)
        allocate(h(N))
        call ezcu_mem_wrap(h, d, READ_WRITE)
        call ezcu_mem_update(h, READ_ONLY)
        status = associated(d) 
        deallocate(h)
    end function read_access_buffer

    logical function write_access_buffer() result(status)    
        real :: h(-3:N-4)
        h(-3:N-4) = 0.0
        h(-3)     = 1.2
        call ezcu_mem_wrap(h, d, N, READ_WRITE)        
        call ezcu_mem_update(h, N, READ_ONLY)
        status = h(-3).eq.1.2
         
    end function write_access_buffer

    logical function write_access_allocatable() result(status)    
        real, allocatable :: h(:)
        allocate(h(-3:N-4))
        h(-3:N-4) = 0.0
        h(-3)     = 1.2
        call ezcu_mem_wrap(h, d, READ_WRITE)        
        call ezcu_mem_update(h, READ_ONLY)
        status = h(-3).eq.1.2
         
        deallocate(h)
    end function write_access_allocatable

    logical function write_access_pointer() result(status)    
        real, pointer :: h(:)
        allocate(h(-3:N-4))
        h(-3:N-4) = 0.0
        h(-3)     = 1.2
        h(N-10)   = -1.2
        call ezcu_mem_wrap_ptr(h, d, READ_WRITE)        
        call ezcu_mem_update_ptr(h, READ_ONLY)
        status = h(-3).eq.1.2.and. h(N-10).eq.-1.2
         
        deallocate(h)
    end function write_access_pointer

    logical function access_buffer_2d() result(status)
        real, allocatable :: h2d(:,:)
        integer :: i, j, H, W
        H = 16
        W = 4
        status=.true.
        allocate(h2d(H,W))
        call ezcu_mem_wrap(h2d, d, READ_WRITE)
        call ezcu_mem_update(h2d, WRITE_ONLY)
        do j=1,W
            do i=1,H
                h2d(i,j) = (j-1)*H+i
            enddo
        enddo
        call ezcu_mem_update(h2d, READ_ONLY)
        do j=1,W
            do i=1,H
                status = status .and. (abs(h2d(i,j) - ((j-1)*H+i)) < 1.e-4)
            enddo
        enddo
        deallocate(h2d)
    end function access_buffer_2d

    logical function access_buffer_3d() result(status)
        real, allocatable :: h3d(:,:,:)
        integer :: TH, TW, TD
        TH = 16
        TW = 16
        TD = 16
        
        allocate(h3d(-3:TH+4, -3:TW+4, -3:TD+4))
        h3d = 0.
        h3d(1:TH, 1:TW, 1:TD) = 1.2
        call ezcu_mem_wrap(h3d, d, READ_WRITE)
        call ezcu_mem_update(h3d, READ_ONLY)
        
        status = .true.
        deallocate(h3d)
    end function access_buffer_3d

    logical function access_buffer_4d() result(status)
        real, allocatable, target         :: h4d(:,:,:,:)
        real, pointer, dimension(:,:,:,:) :: hptr
        integer, parameter                :: TH=16, TW=16, TD=16, TK=32
        real                              :: h(TH,TW,TD,TK)
        
        allocate(hptr(4,4,4,4))
        allocate(h4d(-3:TH+4, -3:TW+4, -3:TD+4, -3:TK+4))
        h4d = 0.
        h4d(1:TH, 1:TW, 1:TD, 1:TK) = 1.2
        call ezcu_mem_wrap(h4d, d, READ_WRITE)
        call ezcu_mem_wrap_ptr(hptr, d, READ_WRITE)
        call ezcu_mem_wrap(h, d, TH, TW, TD, TK, READ_WRITE)
        call ezcu_mem_update(h4d, READ_ONLY)
        call ezcu_mem_update_ptr(hptr, READ_ONLY)
        call ezcu_mem_update(h, TH, TW, TD, TK, READ_ONLY)
        
        status = .true.
        deallocate(h4d)
        deallocate(hptr)
    end function access_buffer_4d

    subroutine setup()
        call ezcu_init()
        call ezcu_dev_find(0, d)
    end subroutine setup

    subroutine teardown()
        call ezcu_release()
    end subroutine teardown
    
    subroutine mem_test()
        call run(setup, teardown, wrap_buffer, &
              "mem_test.wrap_buffer")
        call run(setup, teardown, wrap_allocatable, &
              "mem_test.wrap_allocatable")
        call run(setup, teardown, wrap_pointer, &
              "mem_test.wrap_pointer")
        call run(setup, teardown, read_access_buffer, &
               "mem_test.read_access_buffer")
        call run(setup, teardown, write_access_buffer, &
              "mem_test.write_access_buffer")
        call run(setup, teardown, write_access_allocatable, &
              "mem_test.write_access_allocatable")
        call run(setup, teardown, write_access_pointer, &
              "mem_test.write_access_pointer")
        call run(setup, teardown, access_buffer_2d, &
              "mem_test.access_buffer_2d")
        call run(setup, teardown, access_buffer_3d, &
              "mem_test.access_buffer_3d")
        call run(setup, teardown, access_buffer_4d, &
              "mem_test.access_buffer_4d")
    end subroutine mem_test

end module m_mem_test
