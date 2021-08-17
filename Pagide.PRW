#include "rwmake.ch"        

User Function Pagide()

//_cCgc := "0"+Left(SA2->A2_CGC,8)+Substr(SA2->A2_CGC,9,4)+Right(SA2->A2_CGC,2)

_cCgc := "0"+ALLTRIM(SA2->A2_CGC)

If SA2->A2_TIPO <> "J" 
   _cCgc := Left(SA2->A2_CGC,9)+"0000"+Substr(SA2->A2_CGC,10,2)
Endif

Return(_cCgc)
