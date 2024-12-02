module global_vars
    implicit none
    integer, parameter :: N = 1024
    double precision, dimension(0:N-1, 0:N-1) :: OUT, IN, W, OUT0
end module global_vars

program openmp_fortran
  use omp_lib
  use global_vars

  implicit none

  integer :: i, j, ii, jj, k, argc, nths
  character(len=4) :: argv
  integer :: equal, res
  double precision :: ini, tend, tbase, topt

  k = 3
  argc = command_argument_count()
  if (argc > 0) then
     call get_command_argument(1, argv)
     read (argv,'(I10)') k
!     print *, k
  end if

  call random_seed()
  call init()

  ! Sequential base case
  ini = omp_get_wtime()
  call base(k)
  tend = omp_get_wtime()
  tbase = (tend - ini)

  ! Optimized parallel version
  ini = omp_get_wtime()
  call opt(k)
  tend = omp_get_wtime()
  topt = (tend - ini)

  res = cmp(k)
  nths = omp_get_max_threads()
  if (.not. res) then
     print *, "NOOK!",k,nths,tbase,topt
  else
     print *, "OK!!!",k,nths,tbase,topt
     print *, "Time",tbase,topt
  end if
contains

  subroutine init()
    integer :: i, j
    double precision :: x

    do i = 0, N-1
      do j = 0, N-1
        call random_number(x)
        IN(i, j) = 2.0 !i
        call random_number(x)
        W(i, j) = 2.0 !i
      end do
    end do
  end subroutine init

  function cmp(k) result(equal)
    integer, intent(in) :: k
    integer :: i, j
    logical :: equal
    equal = .true.

    do i = k, N - k - 1 
      do j = k, N - k - 1
        if (OUT0(i, j) /= OUT(i, j)) then
          equal = .false.
          print *, "Mismatch at (", i, ",", j, "): OUT0 = ", OUT0(i, j), " OUT = ", OUT(i, j)
          exit
        end if
      end do
      if (.not. equal) exit
    end do
  end function cmp

  subroutine base(k)
    integer, intent(in) :: k
    integer :: i, j, ii, jj

    !$omp parallel
    !$omp single
    !$omp taskloop
    do i = k, N - k - 1 
      do j = k, N - k - 1
        OUT0(i, j) = 0.0
        do ii = -k, k
          do jj = -k, k
            !print *, i, ",", j, ": OUT0 = ", OUT0(i, j)
            OUT0(i, j) = OUT0(i, j) + IN(i + ii, j + jj) * W(k + ii, k + jj)
          end do
        end do
      end do
    end do
    !$omp end taskloop
    !$omp end single
    !$omp end parallel
  end subroutine base

subroutine STMT(lb, ub, k, i, j)
    implicit none
    integer, intent(in) :: lb, ub, k, i, j
    integer :: ii, jj
    ! Presupone que OUT, IN, y W son matrices globales
    do ii = -k, k
        do jj = lb, ub
            !print *, i, ",", j, ": OUT = ", OUT(i, j-jj)
            OUT(i, j - jj) = OUT(i, j - jj) + IN(i + ii, j) * W(k + ii, k + jj)
        end do
    end do
end subroutine STMT

subroutine opt(k)
    integer, intent(in) :: k
    integer :: i, j
    ! Parallel region with OpenMP
    !$omp parallel
    !$omp single
    !$omp taskloop
    do i = k, N-k-1
        ! Primera parte del bucle
        do j = 0, 2*k-1
            OUT(i, j+k) = 0.0
            call STMT(-k, -k+j, k, i, j)
        end do
        ! Segunda parte del bucle
        do j = 2*k, N-2*k-1
            OUT(i, j+k) = 0.0
            call STMT(-k, k, k, i, j)
        end do
        ! Tercera parte del bucle
        do j = N-2*k, N-1
            call STMT(j-N+k+1, k, k, i, j)
        end do
    end do
    !$omp end taskloop
    !$omp end single
    !$omp end parallel
end subroutine opt

end program openmp_fortran
