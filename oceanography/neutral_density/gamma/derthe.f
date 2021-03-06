      SUBROUTINE DERTHE(S,T,P0,DTHEDT,DTHEDS,DTHEDP)
C *********************************************************************
C ******* THIS SUBROUTINE USES THE BRYDEN (1973) POLYNOMIAL
C ******* FOR POTENTIAL TEMPERATURE AS A FUNCTION OF S,T,P
C ******* TO OBTAIN THE PARTIAL DERIVATIVES OF THETA WITH
C ******* RESPECT TO T,S,P. PRESSURE IS IN DBARS.
      IMPLICIT DOUBLE PRECISION (A-Z)
      PARAMETER (A0=-0.36504D-4,A1=-0.83198D-5,A2=+0.54065D-7)
      PARAMETER (A3=-0.40274D-9,B0=-0.17439D-5,B1=+0.29778D-7)
      PARAMETER (D0=+0.41057D-10,C0=-0.89309D-8,C1=+0.31628D-9)
      PARAMETER (C2=-0.21987D-11,E0=+0.16056D-12,E1=-0.50484D-14)
      DS=S-35.0
      P=P0
      PP=P*P
      PPP=PP*P
      TT=T*T
      TTT=TT*T
      PART=1.0+P*(A1+2.*A2*T+3.*A3*TT+DS*B1)
      DTHEDT=PART+PP*(C1+2.*C2*T)+PPP*E1
      DTHEDS=P*(B0+B1*T)+PP*D0
      PART=A0+A1*T+A2*TT+A3*TTT+DS*(B0+B1*T)
      DTHEDP=PART+2.*P*(DS*D0+C0+C1*T+C2*TT)+3.*PP*(E0+E1*T)
C      CHECK=T+PART*P+PP*(DS*D0+C0+C1*T+C2*TT)+PPP*(E0+E1*T)
C      TYPE 100,CHECK
C  100 FORMAT(1H ,' THE CHECK VALUE OF THETA FROM DERTHE IS = ',F9.5)
      RETURN
      END
