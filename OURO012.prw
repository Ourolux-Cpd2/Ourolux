#INCLUDE "RWMAKE.CH"
#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE "Tbiconn.ch"
#INCLUDE "Tbicode.ch"

#DEFINE POS_COD_LOJ      1
#DEFINE POS_PREF_TIT_PAR 2
#DEFINE POS_TIPO         3

#DEFINE TAM_COD          6
#DEFINE TAM_LOJA         2
#DEFINE TAM_PREF         3
#DEFINE TAM_NUMERO       9
#DEFINE TAM_TIPO         3  
#DEFINE TAM_PARCELA      1

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO012
Rotina para limpeza de PRE
@author Rodrigo Nunes
@since 31/08/2021
/*/
//--------------------------------------------------------------------
User Function OURO012()
    Local cArquivo := ""
    
    cArquivo := cGetFile('*.csv|*.csv')

    If Empty(cArquivo)
        Alert("Arquivo n�o selecionado!")
    else
        Processa({|| OURO12A(cArquivo)})
    EndIf

Return

//--------------------------------------------------------------------
/*/{Protheus.doc} OURO12A
Exclus�o de titulos
@author Rodrigo Nunes
@since 20/08/2021
/*/
//--------------------------------------------------------------------
Static Function OURO12A(cArquivo)
    Local aLinha        := {}
    Local aConteudo     := {}
    Local aCabeca       := {}
    Local nLinha        := 0
    Local i             := 0
    Local cFile         := "C:\TEMP\Exclusao_PRE"+DTOS(dDataBase)+"_"+Replace(Time(),":","-")+".txt" 
    Local nH            := fCreate(cFile) 
    Private lMsErroAuto	:= .F.

    If nH == -1 
        MsgStop("Falha ao criar arquivo - erro "+str(ferror())) 
        Return 
    Endif 

    DbSelectArea("SE2")

    FT_FUse(cArquivo)
    ProcRegua(FT_FLastRec())
    FT_FGoTop()

    While !FT_FEof()
        IncProc("Lendo arquivo de Previsoes...")
        nLinha++
        aLinha    := {}
        
        aLinha:=Separa( FT_FReadLn(),";",.T.)
        
        If nLinha == 1
            AAdd(aCabeca,AClone(aLinha))
        Else
            AAdd(aConteudo,AClone(aLinha))
        EndIf
        
        FT_FSkip()
    Enddo

    ProcRegua(Len(aConteudo))

    For i := 1 To Len(aConteudo)
        IncProc("Excluindo titulos do Sistema...")
        If SE2->(DbSeek("  "+;
                        SubStr(aConteudo[i][POS_PREF_TIT_PAR],1,TAM_PREF)+;
                        SubStr(aConteudo[i][POS_PREF_TIT_PAR],5,TAM_NUMERO)+;
                        SubStr(aConteudo[i][POS_PREF_TIT_PAR],15,TAM_PARCELA)+;
                        SubStr(aConteudo[i][POS_TIPO],1,TAM_TIPO)+;
                        SubStr(aConteudo[i][POS_COD_LOJ],1,TAM_COD)+;
                        SubStr(aConteudo[i][POS_COD_LOJ],8,TAM_LOJA)))
			
            Reclock("SE2",.F.)
			SE2->E2_ORIGEM = ""
			SE2->(MSUNLOCK())
			
            fWrite(nH, "E2_PREFIXO:"+SE2->E2_PREFIXO+" E2_NUM:"+SE2->E2_NUM+" E2_PARCELA:"+SE2->E2_PARCELA+" E2_TIPO:"+SE2->E2_TIPO+" E2_FORNECE:"+SE2->E2_FORNECE+" E2_LOJA:"+SE2->E2_LOJA)

            aArray := { { "E2_PREFIXO"  , SE2->E2_PREFIXO , NIL },;
                        { "E2_NUM"      , SE2->E2_NUM , NIL },;
                        { "E2_PARCELA"  , SE2->E2_PARCELA , NIL },;
                        { "E2_TIPO"     , SE2->E2_TIPO , NIL },;
                        { "E2_FORNECE"  , SE2->E2_FORNECE , NIL },;
						{ "E2_LOJA"     , SE2->E2_LOJA     , NIL } }
			MsExecAuto( { |x,y,z| FINA050(x,y,z)}, aArray,, 5)  // 3 - Inclusao, 4 - Altera��o, 5 - Exclus�o
			If lMsErroAuto
                fWrite(nH," - NAO EXCLUIDO"+ chr(13)+chr(10))
				MostraErro()
			Else
				fWrite(nH," - EXCLUS�O DO T�TULO COM SUCESSO!"+ chr(13)+chr(10))
			Endif
		EndIf
    Next

    fClose(nH) 
    Msginfo("Processamento finalizado - Arquivo de log criado :" + cFile) 
    
Return
