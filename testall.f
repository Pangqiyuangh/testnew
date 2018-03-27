	program test
	implicit none
        integer i,iflag,xsub(128),ier,num
        integer nj,ns,r
        real*16 begin1,end1
        integer*8  time_begin,time_end,countrage,countmax
        real*16 U1(8,128),V1(8,128),U2(8,128),V2(8,128)
        real*16 re1(128),re2(128),x(128),xsubb(128),pi,time1,time2
        real*16 arr(4)
        parameter (pi=3.141592653589793238462643383279502884197d0)
        complex*16 U(128,8),V(128,8),c(128),S(128),re(128),M(128,8)
        complex*16 fk(-64:63)
        real*8 x1(128),eps,error
        double complex in1, out1
        dimension in1(128), out1(128)
	integer*8 :: plan
        integer FFTW_FORWARD,FFTW_MEASURE
        parameter (FFTW_FORWARD=-1)
        parameter (FFTW_MEASURE=0)
    
        character*8 date
        character*10 time
        character*5 zone 
        integer*4 values1(8),values2(8)
        
        arr(1)=3600
        arr(2)=60
        arr(3)=1
        arr(4)=0.001
        nj=128
        ns=128
        r=8
        iflag=1
        eps=1E-6
        num=10000
        open(unit = 10,file = 'Ur.txt')
        read(10,*) U1
        open(unit = 20,file = 'Vr.txt')
        read(20,*) V1
        open(unit = 10,file = 'Ui.txt')
        read(10,*) U2
        open(unit = 10,file = 'Vi.txt')
        read(10,*) V2
        call dfftw_plan_dft_1d(plan,nj,in1,out1,FFTW_FORWARD,0)

        re=dcmplx(re1,re2)        
        U=dcmplx(transpose(U1),transpose(U2))
        V=dcmplx(transpose(V1),transpose(V2))
        !print *,V(2,:)
        !print *,U(1,:)
        do i = 1,128
           x(i) = i*pi/8
        enddo
        xsub=mod(floor(x+0.5),ns)+1
        do i = 1,128
           c(i) = exp(dcmplx(0,1)*i/ns)
        enddo
        !print *,c(1:12)
        do i = 1,128
           x1(i) = i*pi*2*pi/(8*nj)
        enddo

        call date_and_time(date,time,zone,values1)
        do i=1,num
        call nufft1dIapp(nj,c,U,V,xsub,ns,iflag,r,S,plan)
        enddo
        call date_and_time(date,time,zone,values2)
        time1=sum((values2(5:8)-values1(5:8))*arr)
        print *,' T_our         = ',time1/num

        call date_and_time(date,time,zone,values1)
        do i=1,num
        call nufft1d1f90(nj,x1,c,iflag,eps,ns,fk,ier)
        enddo
        call date_and_time(date,time,zone,values2)
        time2=sum((values2(5:8)-values1(5:8))*arr)
        print *,' T_nyu         = ',time2/num
        print *,' T_our/T_nyu   = ',time1/time2
        error=real(sum((S-conjg(fk)*nj)*conjg(S-conjg(fk)*nj))/
     &  sum(S*conjg(S)))
        print *,' error         = ',error
        call dfftw_destroy_plan(plan)
        

	end program


