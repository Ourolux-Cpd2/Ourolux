#include "Protheus.ch"
#include "Totvs.ch"
#include "Topconn.ch"
#include "TbiConn.ch"
#include "TbiCode.ch"
#include "rwmake.ch"


/*/{Protheus.doc} EICR0001
Impressão do cadastro de produtos com descrição completa da LI

@author Maurício Aureliano
@since 22.05.2018

@param 	cArq, 		Arquivo pré-formatado


@return	Nil		Sem Retorno.
/*/


User Function EICR0001()


    Local oFWMsExcel
    Local oExcel
    Local cArquivo    := GetTempPath()+'zTstExc1.xml'

	Local cPerg		:= "EICR01"
	Local cHtml		:= ""
	Local cQuery	:= ""
	Local cDescGI	:= ""
	Local cDescP	:= ""
	Local cDescI	:= ""

	Local aArea		:= GetArea()

	Local Enter		:= CHR(13)+CHR(10)

	Local nLastKey:= 0

	Pergunte(cPerg,.T.) // Caso o parametro esteja como .T. o sistema ira apresentar a tela de perguntas antes que abrir a tela configuração do relatório.

	If LastKey() == 27 .or. nLastKey == 27 
		Return() 
	Endif 

	cQuery	:=  "SELECT "
	cQuery	+= Enter + " B1_COD "
	cQuery	+= Enter + " ,B1_DESC "
	cQuery	+= Enter + " ,B1_TIPO "
	cQuery	+= Enter + " ,B1_UM "
	cQuery	+= Enter + " ,B1_POSIPI "
	cQuery	+= Enter + " ,B1_PESO "
	cQuery	+= Enter + " ,B1_DESC_GI "
	cQuery	+= Enter + " ,B1_DESC_P "
	cQuery	+= Enter + " ,B1_DESC_I "
	cQuery	+= Enter + " FROM "+RetSqlName("SB1")+" SB1 "
	cQuery	+= Enter + " WHERE "
	cQuery	+= Enter + " B1_COD BETWEEN '"	+ mv_par01	+ "' AND '"	+ mv_par02	+ "' "
	cQuery	+= Enter + " AND SB1.D_E_L_E_T_ <> '*' "

	TCQuery cQuery New Alias "QRYPRO"
	QRYPRO->(dbGoTop())

	// Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	// Aba 01 - Produtos
	oFWMsExcel:AddworkSheet("Produtos_LI")

	// Criando a Tabela
	oFWMsExcel:AddTable("Produtos_LI","Produtos")
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Codigo",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Descricao",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Tipo",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","UM",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","NCM",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Peso",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Descr_LI",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Descr_Português",1)
	oFWMsExcel:AddColumn("Produtos_LI","Produtos","Descr_Inglês",1)

	// Criando as Linhas... Enquanto não for fim da query
	While !(QRYPRO->(EoF()))

		// Buscando descrições MEMO - Tabela "SYP"
		cDescGI	:= u_DescSYP("B1_DESC_GI",QRYPRO->B1_DESC_GI)
		cDescP		:= u_DescSYP("B1_DESC_P" ,QRYPRO->B1_DESC_P)
		cDescI		:= u_DescSYP("B1_DESC_I"  ,QRYPRO->B1_DESC_I)

		oFWMsExcel:AddRow("Produtos_LI","Produtos",{	QRYPRO->B1_COD,	QRYPRO->B1_DESC	, QRYPRO->B1_TIPO	, QRYPRO->B1_UM, QRYPRO->B1_POSIPI, QRYPRO->B1_PESO, cDescGI	, cDescP, cDescI	})

		// Pulando Registro
		QRYPRO->(DbSkip())
	EndDo

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()
	oFWMsExcel:GetXMLFile(cArquivo)

	//Abrindo o excel e abrindo o arquivo xml
	oExcel := MsExcel():New()             //Abre uma nova conexão com Excel
	oExcel:WorkBooks:Open(cArquivo)     //Abre uma planilha
	oExcel:SetVisible(.T.)                 //Visualiza a planilha
	oExcel:Destroy()                        //Encerra o processo do gerenciador de tarefas

	QRYPRO->(DbCloseArea())
	RestArea(aArea)

Return



User Function DescSYP(cCampo,cChave)

	Local nLin		:= 0
	Local nChar		:= 0
	Local cRet := ""

	DbSelectArea("SYP")
	DbSetOrder(1)
	DbSeek(xFilial("SYP")+cChave)

	Do While 	YP_FILIAL	==	xFilial("SYP") .And. YP_CHAVE	==	cChave .And. !Eof()

		If Empty(SYP->YP_TEXTO)
			DbSkip()
			Loop
		Endif					
		nLin += 1 
		nChar:= At("\13\10",SYP->YP_TEXTO) 
		If nChar = 0
			cRet := cRet + AllTrim(SYP->YP_TEXTO)
		Else	
			cRet := cRet + AllTrim(Substr(SYP->YP_TEXTO,1, nChar-1))
		Endif	
		DbSkip()

	Enddo

Return cRet



Static Function ValidP1(cPerg)

	dbSelectArea("SX1")
	dbSetOrder(1)

	aRegs:={}              
	aAdd(aRegs,{cPerg,"01","Produto de ?                     "	,"","","mv_ch1" ,"C", 15,0,0,"G",""														,"mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Produto ate ?                    "	,"","","mv_ch2" ,"C", 15,0,0,"G",""										                ,"mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""		,"","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg + aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				FieldPut(j,aRegs[i,j])
			Next
			MsUnlock()
			dbCommit()
		Endif
	Next

Return(.T.)