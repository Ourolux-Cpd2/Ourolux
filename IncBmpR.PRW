#include "rwmake.ch"
#include "tbiconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณINCBMPR   บAutor  ณGelson Carmo -H.D.  บ Data ณ  10/08/02   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณPermitir a inclusao de imagens no repositorio de imagens    บฑฑ
ฑฑบ          ณde forma automatica, especificando apenas o diretorio       บฑฑ
ฑฑบ          ณonde os BitMaps se encontram.                               บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณGENERICO - CONFIGURADOR                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/

User Function IncBmpR()
Private cDrive := ""
Private cDir   := ""
Private cFile  := ""
Private lInclui:= .T.
Private aItens := {}
Private nList := 1
Private cBmp  := ""


//PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" MODULO "FAT"


@ 124,256 To 403,869 Dialog oDlg Title OemToAnsi("Exemplo de Inclusao de Bitmaps de forma automatica no Repositorio")
SelArq( @aItens )

lFirst := .T.
@ 6,103 To 108,191 Title OemToAnsi("Repositorio")
oBmp := TBmpRep():New( 9, 103, 108, 191,, .T.,oDlg, , , .F., .F., , , .F., , .T., , .F. )


@ 6,198 To 108,286 Title OemToAnsi("arquivo")
oBit := TBitMap():New(9, 198, 108, 286,, cBMP, .t., , , , , , , , , , .t.)

//ฺฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฟ
//ณ LISTBOX COM ARQUIVOS                                                ณ
//ภฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤฤู
@ 7,5 ListBox nList Items aItens Size 93,130  object oLista
oLista:bLClicked := { || MostraImg() }
oLista:bChange   := { || MostraImg() }
oLista:bSetGet   := { || MostraImg() }

@ 116,202 BmpButton Type 4 Action Inclui()
@ 116,248 BmpButton Type 2 Action Close(oDlg)

Activate Dialog oDlg
Return


Static Function Inclui()

If Len(aItens) == 0
   Alert("NAO HA ARQUIVOS PARA IMPORTACAO, VERIFIQUE O DIRETORIO")
   return
Endif

For x := 1 to len( aItens )
	    
	cFile := oBmp:InsertBmp( aItens[x],,@lInclui)
	
	IF !Empty( cFile )
		oBmp:LoadBmp(cFile)
		oBmp:Refresh()
	Endif
	
Next
Return


Static Function SelArq( aItens )
Local aDir
Local cImg
Local nPosIni

cDir := cGetFile ( "Diretorio de Imagens|*.*", "Selecione o Diretorio onde estใo as Imagens",2, "SERVIDOR", .F., GETF_RETDIRECTORY)
cImg := "JPG*BMP"

aFiles := {}
aDir( cDir+"*.*", aFiles)

aItens:= {}
For n:= 1 to Len( aFiles )
	nPosIni := aT( ".", aFiles[n] ) + 1
	If subs( aFiles[n], nPosIni, 3) $ cImg
		Aadd( aItens, cDir + aFiles[n] )
	Endif
Next

//If ValType( oLista ) # NIL
//	oLista:Refresh()
//Endif

Return


Static Function MostraImg()

//REFRESH - ARQUIVOS FISICOS
If oLista:nAt  == 0
   oLista:nAt := 1
Endif

cBMP := aItens[ oLista:nAt ]
oBit:cBMPFile:=cBMP
oBit:Load(cBMP)
oBit:refresh()

//REFRESH - REPOSITORIO DE IMAGENS
oBmp:cBMPFile:=cBMP
oBmp:Load(cBMP)
oBmp:refresh()

odlg:Refresh()

Return
