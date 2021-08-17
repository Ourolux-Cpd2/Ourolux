#include "totvs.ch"
#include "protheus.ch"
#include "TOPCONN.CH"
//--------------------------------------------------------------------
/*/{Protheus.doc} OURO021    
Função para importação do arquivo CSV de Orçamentos
Preenchimento das tabelas CV1 e CV2

@author Rodrigo Nunes.
@since 17/06/2020
/*/
//--------------------------------------------------------------------
User Function SubOrc() 
Local lFeito := .F.

    Processa({|| lFeito:= OrcIMP()})

Return lFeito

Static Function OrcIMP()
Local cDiret    := ""
Local cLinha    := ""
Local lPrimlin  := .T.
Local aCampos   := {}
Local aDados    := {}
Local i         := 0
Local nPosFil   := 0
Local nPosOrc   := 0
Local nPosDes   := 0
Local nPosSta   := 0
Local nPosCal   := 0
Local nPosMoe   := 0
Local nPosRev   := 0
Local nPosSeq   := 0
Local nPosCT1i  := 0
Local nPosCT1f  := 0
Local nPosCTTi  := 0
Local nPosCTTf  := 0
Local nPosPer   := 0
Local nPosDTi   := 0
Local nPosDTf   := 0
Local nPosVal   := 0
Local nPosApr   := 0
Private aErro   := {}
 
cDiret :=  cGetFile( 'Arquito CSV|*.csv|' ,;                      //[ cMascara], 
                         'Selecao de Arquivos',;                  //[ cTitulo], 
                         0,;                                      //[ nMascpadrao], 
                         'C:\',;                                  //[ cDirinicial], 
                         .F.,;                                    //[ lSalvar], 
                         GETF_LOCALHARD  + GETF_NETWORKDRIVE,;    //[ nOpcoes], 
                         .T.)         

If Empty(cDiret)
    Alert("Arquivo nao selecionado!")
    Return(.F.)
EndIf

FT_FUSE(cDiret)
ProcRegua(FT_FLASTREC())
FT_FGOTOP()

While !FT_FEOF()
 
	IncProc("Lendo arquivo texto...")
 
	cLinha := FT_FREADLN()
 
	If lPrimlin
		aCampos := Separa(cLinha,";",.T.)
		lPrimlin := .F.
	Else
		AADD(aDados,Separa(cLinha,";",.T.))
	EndIf
 
	FT_FSKIP()
EndDo
cLinha := "001"

dbSelectArea("CV1")
CV1->(dbSetOrder(1))

dbSelectArea("CV2")
CV2->(dbSetOrder(1))

nPosFil   := aScan(aCampos,{|x| AllTrim(x)=="CV1_FILIAL"})
nPosOrc   := aScan(aCampos,{|x| AllTrim(x)=="CV1_ORCMTO"})
nPosDes   := aScan(aCampos,{|x| AllTrim(x)=="CV1_DESCRI"})
nPosSta   := aScan(aCampos,{|x| AllTrim(x)=="CV1_STATUS"})
nPosCal   := aScan(aCampos,{|x| AllTrim(x)=="CV1_CALEND"})
nPosMoe   := aScan(aCampos,{|x| AllTrim(x)=="CV1_MOEDA"})
nPosRev   := aScan(aCampos,{|x| AllTrim(x)=="CV1_REVISA"})
nPosSeq   := aScan(aCampos,{|x| AllTrim(x)=="CV1_SEQUEN"})
nPosCT1i  := aScan(aCampos,{|x| AllTrim(x)=="CV1_CT1INI"})
nPosCT1f  := aScan(aCampos,{|x| AllTrim(x)=="CV1_CT1FIM"})
nPosCTTi  := aScan(aCampos,{|x| AllTrim(x)=="CV1_CTTINI"})
nPosCTTf  := aScan(aCampos,{|x| AllTrim(x)=="CV1_CTTFIM"})
nPosPer   := aScan(aCampos,{|x| AllTrim(x)=="CV1_PERIOD"})
nPosDTi   := aScan(aCampos,{|x| AllTrim(x)=="CV1_DTINI"})
nPosDTf   := aScan(aCampos,{|x| AllTrim(x)=="CV1_DTFIM"})
nPosVal   := aScan(aCampos,{|x| AllTrim(x)=="CV1_VALOR"})
nPosApr   := aScan(aCampos,{|x| AllTrim(x)=="CV1_APROVA"})

If nPosFil  == 0 .Or.;
   nPosOrc  == 0 .Or.;
   nPosDes  == 0 .Or.;
   nPosSta  == 0 .Or.;
   nPosCal  == 0 .Or.;
   nPosMoe  == 0 .Or.;
   nPosRev  == 0 .Or.;
   nPosSeq  == 0 .Or.;
   nPosCT1i == 0 .Or.;
   nPosCT1f == 0 .Or.;
   nPosCTTi == 0 .Or.;
   nPosCTTf == 0 .Or.;
   nPosPer  == 0 .Or.;
   nPosDTi  == 0 .Or.;
   nPosDTf  == 0 .Or.;
   nPosVal  == 0 .Or.;
   nPosApr  == 0
    Alert("Existem colunas invalidas no arquivo, verifique e importe novamente!!!")
    Return(.F.)
EndIf
If !Empty(aDados)
    If CV2->(dbSeek(aDados[1][nPosFil]+aDados[1][nPosOrc]+aDados[1][nPosCal]+aDados[1][nPosMoe]+aDados[1][nPosRev]))
        Alert("Chave ja importada, arquivo ignorado!!!")
        Return(.F.)
    EndIf
Else
    Alert("Arquivo vazio!!!")
    Return(.F.)
EndIf
        
Begin Transaction
ProcRegua(Len(aDados))
For i:=1 to Len(aDados)
    IncProc("Importando Registro "+ cValToChar(i) + " de " + cValToChar(Len(aDados)))  
    If i == 1        
        Reclock("CV2",.T.)
        CV2->CV2_FILIAL := aDados[i][nPosFil]
        CV2->CV2_ORCMTO := aDados[i][nPosOrc]
        CV2->CV2_DESCRI := aDados[i][nPosDes]
        CV2->CV2_STATUS := aDados[i][nPosSta]
        CV2->CV2_CALEND := aDados[i][nPosCal]
        CV2->CV2_MOEDA  := aDados[i][nPosMoe]
        CV2->CV2_REVISA := aDados[i][nPosRev]
        CV2->CV2_APROVA := aDados[i][nPosApr]
        CV2->(MsUnlock())
    EndIf

    Reclock("CV1",.T.)
    CV1->CV1_FILIAL := aDados[i][nPosFil]
    CV1->CV1_ORCMTO := aDados[i][nPosOrc]
    CV1->CV1_DESCRI := aDados[i][nPosDes]
    CV1->CV1_STATUS := aDados[i][nPosSta]
    CV1->CV1_CALEND := aDados[i][nPosCal]
    CV1->CV1_MOEDA  := aDados[i][nPosMoe]
    CV1->CV1_REVISA := aDados[i][nPosRev]
    CV1->CV1_SEQUEN := aDados[i][nPosSeq]
    CV1->CV1_CT1INI := aDados[i][nPosCT1i]
    CV1->CV1_CT1FIM := aDados[i][nPosCT1f]
    CV1->CV1_CTTINI := aDados[i][nPosCTTi]
    CV1->CV1_CTTFIM := aDados[i][nPosCTTf]
    CV1->CV1_PERIOD := aDados[i][nPosPer]
    CV1->CV1_DTINI  := STOD(aDados[i][nPosDTi])
    CV1->CV1_DTFIM  := STOD(aDados[i][nPosDTf])
    CV1->CV1_VALOR  := Val(aDados[i][nPosVal])
    CV1->CV1_APROVA := aDados[i][nPosApr]
    CV1->(MsUnlock())
Next i
End Transaction
ApMsgInfo("Importacao concluida com sucesso!","Sucesso!")

Return(.T.)
