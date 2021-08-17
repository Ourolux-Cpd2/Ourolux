#include "protheus.ch"

User Function SV_EICCP(cFase)

Local aArea := GetArea()
Local cFiltroDI := "E2_HAWBEIC = '%W6_HAWB%' "
Local cFiltroPO := "E2_PO_EIC = '%W2_PO_NUM%' .OR. E2_TIPO $ 'PA .PR ' .And. E2_HAWBEIC = '%W2_PO_NUM%' "
Local cFiltro   := ""

Private cHawb := SW6->W6_HAWB
Private cPO   := SW2->W2_PO_NUM

Begin Sequence    
   IF cFase == "DI"
      IF !Empty(cHawb)
         cFiltro := StrTran(cFiltroDI,"%W6_HAWB%",cHawb)
      Endif
   Else
      IF !Empty(cPO)
         cFiltro := StrTran(cFiltroPO,"%W2_PO_NUM%",cPO)
      Endif
   Endif        
   
   dbSelectArea("SE2")
   SET FILTER TO &cFiltro
   
   BrowseSE2()
   
   dbSelectArea("SE2")
   SET FILTER TO
   
End Sequence

RestArea(aArea)

Return NIL

//-----------------------------------------------------------------------------------------

Static Function BrowseSE2()

Local nOldArea := Select()
    
Private aRotina := {{"Pesquisar","AxPesqui",0,1},;
                   	{"Visualizar","FA050Visua",0,2},;
                   	{"Conhecimento","MSDOCUMENT",0,4},;
                   	{"Legenda","FA040Legenda",0,7}}
                         
Private cCadastro := AVTITCAD("SE2")

Begin Sequence
	mBrowse(6,1,22,75,"SE2",,,,,,FA040Legenda("SE2"))
End Sequence                     

Return NIL