      SUBROUTINE spectrum(istout,ntot,vdat,sfin,alphaL,alphaD1,
     .                    specv,nnv,out,spec)

**********************************************************************
* VERSION: 2.0
*
* PURPOSE:
*    Calculating the absorption coefficient spectrum 
*    using the line intensities "sfin", the Lorentz 
*    halfwidth "alphaL", and the Doppler halfwidth
*    (without the wavenumber) "alphaD1".
*
* spec(nvMAX) : the k-values at all gridpoints inside [vmin,vmax]
*
* DATE:
*    August, 1997
*
* AUTHOR:
*    D.M.Stam (dstam@nat.vu.nl)
*
**********************************************************************
      IMPLICIT REAL*8 (a-h,o-z)

      INCLUDE 'max.incl'

      INTEGER istout,ntot,nnv,out(4)

      REAL*8 pi
      PARAMETER (pi=3.14159)

      REAL*8 vi,vj,xj,yj,F,vij
      REAL*8 vdat(nvMAX),sfin(nvMAX),alphaL(nvMAX),alphaD1(nvMAX),
     .       specv(nvMAX),spec(nvMAX)

Cf2py intent(in) istout,ntot,vdat,sfin,alphaL,alphaD1,specv,nnv
Cf2py intent(out) out,spec
      
*---------------------------------------------------------------------
*     Loop over the wavenumbers within array "specv":
*---------------------------------------------------------------------
      DO i=1,nnv
         vi= specv(i)
         spec(i)= 0.0

         DO j=1,ntot
            vj= vdat(j)
            vij= DABS(vi-vj)
            alphaD= alphaD1(j)*vj
            yj= alphaL(j)/alphaD
            xj= vij/alphaD
            
            IF (yj.GT.15. .OR. xj.GT.100.) THEN
               F= alphaL(j)/pi/(vij*vij + alphaL(j)*alphaL(j))
            ELSE
               F= VOIGT(xj,yj)/(alphaD*(pi**0.5))
            ENDIF

            spec(i)= spec(i) + sfin(j)*F
         ENDDO
      ENDDO

*---------------------------------------------------------------------
*     Write the output to the output file:
*---------------------------------------------------------------------
      IF (out(2).EQ.1) THEN
         WRITE(istout,*)
         WRITE(istout,400)
         WRITE(istout,402) nnv
         WRITE(istout,405)
         DO i=1,nnv
            WRITE(istout,415) specv(i),1.E4/specv(i),spec(i)
         ENDDO
      ENDIF

400   FORMAT('SPECTRUM OUTPUT')
402   FORMAT('delta V= ',2X,'NNV= ',I6)
405   FORMAT('V  [cm-1]            spec [microns]     sigma_abs [cm2]')
415   FORMAT(E14.8,2X,E14.8,2X,E18.10)
*---------------------------------------------------------------------
      RETURN
      END


**********************************************************************
      FUNCTION VOIGT(V,A)

*---------------------------------------------------------------------
* This function calculates the Voigt profile:
*---------------------------------------------------------------------
      IMPLICIT REAL*8  (a-h,o-z)

      DIMENSION H0(41),H1(81),H2(41)
      DIMENSION GAUS20(20),WHT20(20),GAUS10(10),WHT10(10),
     .          GAUS3(3),WHT3(3)

      DATA H0 /
     . 1.0000000, 0.9900500, 0.9607890, 0.9139310, 0.8521440, 0.7788010,
     . 0.6976760, 0.6126260, 0.5272920, 0.4448580, 0.3678790, 0.2981970,
     . 0.2369280, 0.1845200, 0.1408580, 0.1053990, 0.0773050, 0.0555760,
     . 0.0391640, 0.0270520, 0.0183156, 0.0121552, 0.0079071, 0.0050418,
     . 0.0031511, 0.0019305, 0.0011592, 0.0006823, 0.0003937, 0.0002226,
     . 0.0001234, 0.0000671, 0.0000357, 0.0000186, 0.0000095, 0.0000048,
     . 0.0000024, 0.0000011, 0.0000005, 0.0000002, 0.0000001/

      DATA H1 /
     .-1.1283800,-1.1059600,-1.0404800,-0.9370300,-0.8034600,-0.6494500,
     .-0.4855200,-0.3219200,-0.1677200,-0.0301200, 0.0859400, 0.1778900,
     . 0.2453700, 0.2898100, 0.3139400, 0.3213000, 0.3157300, 0.3009400,
     . 0.2802700, 0.2564800, 0.2317260, 0.207528 , 0.1848820, 0.1643410,
     . 0.1461280, 0.1302360, 0.1165150, 0.1047390, 0.0946530, 0.0860050,
     . 0.0785650, 0.0721290, 0.0665260, 0.0616150, 0.0572810, 0.0534300,
     . 0.0499880, 0.0468940, 0.0440980, 0.0415610, 0.0392500, 0.0351950,
     . 0.0317620, 0.0288240, 0.0262880, 0.0240810, 0.0221460, 0.0204410,
     . 0.0189290, 0.0175820, 0.0163750, 0.0152910, 0.0143120, 0.0134260,
     . 0.0126200, 0.0118860, 0.0112145, 0.0105990, 0.0100332, 0.0095119,
     . 0.0090306, 0.0085852, 0.0081722, 0.0077885, 0.0074314, 0.0070985,
     . 0.0067875, 0.0064967, 0.0062243, 0.0059688, 0.0057287, 0.0055030,
     . 0.0052903, 0.0050898, 0.0049006, 0.0047217, 0.0045526, 0.0043924,
     . 0.0042405, 0.0040964, 0.0039595/

      DATA H2 /
     . 1.0000000, 0.9702000, 0.8839000, 0.7494000, 0.5795000, 0.3894000,
     . 0.1953000, 0.0123000,-0.1476000,-0.2758000,-0.3679000,-0.4234000,
     .-0.4454000,-0.4392000,-0.4113000,-0.3689000,-0.3185000,-0.2657000,
     .-0.2146000,-0.1683000,-0.1282100,-0.0950500,-0.0686300,-0.0483000,
     .-0.0331500,-0.0222000,-0.0145100,-0.0092700,-0.0057800,-0.0035200,
     .-0.0021000,-0.0012200,-0.0007000,-0.0003900,-0.0002100,-0.0001100,
     .-0.0000600,-0.0000300,-0.0000100,-0.0000100, 0.0000000/ 

      DATA GAUS20 /.05,.15,.25,.35,.45,.6,.75,.9,1.05,1.2,1.35,1.5,1.65, 
     .1.8,1.95,2.1,2.25,2.4,2.55,2.7/
      DATA WHT20 /.0996,.097634,.0938184,.0883723,.100389,.104549,
     ..0855171,.0668929,.0500384,.0357960,.0244891,.0160216,.0100240,
     ..00599769,.00343183,.00187789,.000982679,.000491757,.000235342,
     ..0000681124/

      DATA GAUS10 /.245341,.737474,1.234076,1.738538,2.254974,2.788806,  
     .  3.347855,3.944764,4.603682,5.38748/
      DATA WHT10 /.462244,.2866755,.1090172,.02481052,.003243773, 
     .  .0002283386,.7802556E-5,.1086069E-6,.4399341E-9,.2229394E-12/

      DATA GAUS3 /.436077,1.335849,2.350605/
      DATA WHT3 / .7246296,.1570673,.004530010/ 

**********************************************************************
      IF (A.GT.0.175) GOTO 10
* A =< 0.175 :
      V0= V*10.0
      N=V0
      IF (N.LT.40)  GOTO 1
      IF (N.LT.120) GOTO 2
* N > 119 :
      VOIGT= (.56419 + .846/(V**2)) / (V**2)*A
      RETURN
* N < 40 :
1     V1= N
      N = N+1
      V2= V0-V1
      N1= N+1
      VOIGT= V2*(H0(N1)-H0(N)+A*(H1(N1)-H1(N)+A*(H2(N1)-H2(N)))) +
     .       H0(N)+ A*(H1(N) + A*H2(N))
      RETURN
* 39 < N < 120 :
2     N= N/2 + 20
      V1= (N-20)*2.0
      N= N+1
      V2= (V0-V1)/2.0 
      N1= N+1
      VOIGT= A*((H1(N1)-H1(N))*V2+H1(N))
      RETURN
* A > 0.175 :
10    IF (A.LE..5) GOTO 20  
      IF (A.LE.1.) GOTO 30
      IF (A.LE.15.) GOTO 40  
      GOTO 80   
20    IF (V.LE.2.7) GOTO 50 
      IF (V.LE.7.) GOTO 60         
      IF (V.LE.100.) GOTO 70    
      GOTO 80              
30    IF (V.LE.2.7) GOTO 60        
      IF (V.LE.40.) GOTO 70
      GOTO 80      
40    IF (V.LE.20.) GOTO 70   
      GOTO 80           
********************************************************************
* Super 20 point quadrature:
********************************************************************
50    VOIGT=0.                            
      DO 55 I=1,20          
55       VOIGT=VOIGT + 
     .         WHT20(I)*A/3.14159*(1./(A*A+(V-GAUS20(I))**2)+
     .         1./(A*A+(V+GAUS20(I))**2))
      RETURN                          
********************************************************************
* 10 point Gaussian quadrature:
********************************************************************
60    VOIGT=0.                              
      DO 65 I=1,10                    
65    VOIGT=VOIGT +
     .      WHT10(I)*A/3.14159*(1./(A*A+(V-GAUS10(I))**2)+
     .      1./(A*A +(V+GAUS10(I))**2))
      RETURN                      
********************************************************************
* 3 point Gaussian quadrature:
********************************************************************
70    VOIGT=0.       
      DO 75 I=1,3 
75       VOIGT=VOIGT +
     .         WHT3(I)*A/3.14159*(1./(A*A+(V-GAUS3(I))**2)
     .         +1./(A*A+ (V+GAUS3(I))**2)) 
      RETURN                   
********************************************************************
* Lorentzian profile:
********************************************************************
80    VOIGT=A/1.77245/(A*A+V*V)         

********************************************************************
      RETURN
      END
