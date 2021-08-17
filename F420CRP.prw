#INCLUDE "MSOLE.CH"
#INCLUDE "PROTHEUS.CH"
#include "rwmake.ch"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³F420CRP   ºAutor  ³Microsiga           º Data ³  13/09/2011 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Altera numero sequencial do arquivo CNAB pra 1000 posicoes º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Exclusivo para CNAB 1000 posicoes da empresa Eletromega    º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function F420CRP
Private cArquivo := mv_par04
Private _nHa 
Private cTexto  := ""
Private aTexto := {}                   
Private nBytes 
Private nBytesSalvo                            
Private cLinha := "000000"                           
 
If Alltrim(Upper(mv_par03)) == "BRATRIBE.2PE"
  //Posiciona o SEE 
  dbSelectArea("SEE")
  SEE->( dbSeek(xFilial("SEE")+cBanco+cAgencia+cConta+cSubCta) )
  
   IF AT(".",mv_par04)>0
     	cArquivo:=SubStr(TRIM(mv_par04),1,AT(".",mv_par04)-1)+"."+TRIM(SEE->EE_EXTEN)
   Else
    	cArquivo:=TRIM(mv_par04)+"."+TRIM(SEE->EE_EXTEN)
   EndIF	  

  If (_nHa := FT_FUse(AllTrim(cArquivo)))== -1
     MsgBox("Arquivo vazio!!")
     Return()
  EndIf
  FT_FGOTOP()                  
  While !FT_FEOF()      
      cTexto := FT_FREADLN()
	  AADD(aTexto , cTexto)
	  FT_FSKIP()
  EndDo
  FT_FUSE()
  fClose(_nHa)
  FErase(cArquivo)       

  _nHa := FCREATE(cArquivo)

  If _nHa == -1
      MsgStop('Erro ao criar destino. Ferror = '+str(ferror(),4),'Erro')
	  FCLOSE(_nHa)	// Fecha o arquivo de Origem
	  Return()
  Endif       

  For i:=1 to len(aTexto)   
      cLinha := Soma1(cLinha)
	  cTexto := SubStr(aTexto[i],1,994) + cLinha 
	  If i == Len(aTexto)	    
		  If (SEE->(FieldPos("EE_FIMLIN")) == 0 .Or. SEE->EE_FIMLIN == "1")	//Determina se salta linha no ultimo registro
		    cTexto := cTexto + Chr(13)+Chr(10)                                                  
		  Else
		    cTexto := cTexto
		  EndIf	
	  Else
	    	cTexto := cTexto + Chr(13)+Chr(10)                                                  	
	  EndIf	
	  nBytes := Len(cTexto)
	  nBytesSalvo := FWRITE(_nHa, cTexto, nBytes)
  Next i   
  FT_FUSE()   
  FClose(_nHa)  
  Return()  
Else 
  Return()
EndIf  