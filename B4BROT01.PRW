#INCLUDE "PROTHEUS.CH"
/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �B4BROT01  � Autor � Fabrica B4B           � Data � 22.09.13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Rotina de Expedicao - Inclusao e/ou alteracao de Transporta-���
���          �ra e Veiculo na Nota Fiscal de Saida e data de agendamento  ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Nenhum                                                      ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Nenhum                                                      ���
���          �                                                            ���
�������������������������������������������������������������������������Ĵ��
���   DATA   � Programador   �Manutencao Efetuada                         ���
�������������������������������������������������������������������������Ĵ��
���          �               �                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
// /*/
User Function B4BROT01()

//��������������������������������������������������������������Ŀ
//� Define Array contendo as Rotinas a executar do programa      �
//� ----------- Elementos contidos por dimensao ------------     �
//� 1. Nome a aparecer no cabecalho                              �
//� 2. Nome da Rotina associada                                  �
//� 3. Usado pela rotina                                         �
//� 4. Tipo de Transa��o a ser efetuada                          �
//�    1 - Pesquisa e Posiciona em um Banco de Dados             �
//�    2 - Simplesmente Mostra os Campos                         �
//�    3 - Inclui registros no Bancos de Dados                   �
//�    4 - Altera o registro corrente                            �
//�    5 - Remove o registro corrente do Banco de Dados          �
//����������������������������������������������������������������
Local   aCores	:= {}
Private aRotina	:= MenuDef()

//��������������������������������������������������������������Ŀ
//� Define o cabecalho da tela de atualizacoes                   �
//����������������������������������������������������������������
Private cCadastro	:= "Expedicao Eletromega"

		aCores	:= { {"!Empty(F2_XDTAGEN)","BR_VERDE" },{"Empty(F2_XDTAGEN)" ,"BR_AZUL"} }

dbSelectArea("SF2")
dbSetOrder(1)
MsSeek(xFilial("SF2"))
mBrowse(6,1,22,75,"SF2"  , , , , , , aCores,,,)

Return Nil

/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �AB4BManut � Autor � Fabrica B4B		    � Data � 22.09.13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Inclusao e/ou alteracao de Transportadora e Veiculo e data  ���
���			 � de agendamento											  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function AB4BManut()

Local aArea		:= GetArea()
Local aTitles	:= {OemtoAnsi("Nota Fiscal"),OemtoAnsi("Data de agendamento")} 
Local nCntFor	:= 0
Local nOpc		:= 0
Local nX        := 0
Local lVeiculo	:= (SF2->(FieldPos("F2_VEICUL1"))>0 .And. SF2->(FieldPos("F2_VEICUL2"))>0 .And. SF2->(FieldPos("F2_VEICUL3"))>0)
Local cTransp	:= ""
Local cVeicul1	:= ""
Local cVeicul2	:= ""
Local cVeicul3	:= ""
Local cDtAgend	:= CRIAVAR("F2_XDTAGEN")
Local oDlg
Local oFolder
Local oList

Private aHeader	  := {}
Private aCols	  := {}

Private oTransp
Private oVeicul1
Private oVeicul2
Private oVeicul3
Private oDtAgend

If lVeiculo

	RegToMemory("SF2",.F.)
	
	cTransp	:= Posicione("SA4",1,xFilial("SA4")+SF2->F2_TRANSP,"A4_NOME")
	cVeicul1:= Posicione("DA3",1,xFilial("DA3")+SF2->F2_VEICUL1,"DA3_DESC")
	cVeicul2:= Posicione("DA3",1,xFilial("DA3")+SF2->F2_VEICUL2,"DA3_DESC")	
	cVeicul3:= Posicione("DA3",1,xFilial("DA3")+SF2->F2_VEICUL3,"DA3_DESC")
	cDtAgend:= STOD("  /  /  ")

	//������������������������������������������������������Ŀ
	//� Montagem do aHeader                                  �
	//��������������������������������������������������������
	dbSelectArea("SX3")
	dbSetOrder(1)
	If dbSeek("SF2")
		While ( !Eof() .And. (SX3->X3_ARQUIVO == "SF2") )
			If ( X3USO(SX3->X3_USADO) .And. ;
				AllTrim(SX3->X3_CAMPO) $ "F2_DOC|F2_SERIE|F2_CLIENTE|F2_LOJA|F2_EMISSAO" .And. ;
				cNivel >= SX3->X3_NIVEL )
				
				Aadd(aHeader,{ TRIM(X3Titulo()),;
					SX3->X3_CAMPO,;
					SX3->X3_PICTURE,;
					SX3->X3_TAMANHO,;
					SX3->X3_DECIMAL,;
					SX3->X3_VALID,;
					SX3->X3_USADO,;
					SX3->X3_TIPO,;
					SX3->X3_ARQUIVO,;
					SX3->X3_CONTEXT } )
			EndIf
			dbSelectArea("SX3")
			dbSkip()
		EndDo
	EndIf                     
	
	//������������������������������������������������������Ŀ
	//� Montagem do aCols                                    �
	//��������������������������������������������������������
	dbSelectArea("SF2")
	AADD(aCols,Array(Len(aHeader)))
	For nCntFor:=1 To Len(aHeader)
		If ( aHeader[nCntFor,10] <>  "V" )
			aCols[Len(aCols)][nCntFor] := FieldGet(FieldPos(aHeader[nCntFor,2]))
		Else			
			aCols[Len(aCols)][nCntFor] := CriaVar(aHeader[nCntFor,2])
		EndIf
	Next nCntFor
	
	//���������������������������������������������Ŀ
	//�Monta a tela de exibicao dos dados           �
	//�����������������������������������������������
	DEFINE MSDIALOG oDlg TITLE OemToAnsi("Manutencao de Transportadoras e Veiculos e Dt. Agendamento") FROM 09,00 TO 28.2,80 
	
	oFolder	:= TFolder():New(001,001,aTitles,{"HEADER"},oDlg,,,, .T., .F.,315,141)
	oList 	:= TWBrowse():New( 5, 1, 310, 42,,{aHeader[1,1],aHeader[2,1],aHeader[3,1],aHeader[4,1],aHeader[5,1]},{30,90,50,30,50},oFolder:aDialogs[1],,,,,,,,,,,,.F.,,.T.,,.F.,,, ) //"Numero"###"Serie"###"Cliente"###"Loja"###"DT Emissao"
	oList:SetArray(aCols)
	oList:bLine	:= {|| {aCols[oList:nAt][1],aCols[oList:nAt][2],aCols[oList:nAt][3],aCols[oList:nAt][4],aCols[oList:nAt][5]}}
	oList:lAutoEdit	:= .F.
	
	@ 051,005 SAY RetTitle("F2_TRANSP")		SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
	@ 066,005 SAY RetTitle("F2_VEICUL1")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]
	@ 081,005 SAY RetTitle("F2_VEICUL2")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]	
	@ 095,005 SAY RetTitle("F2_VEICUL3")	SIZE 40,10 PIXEL OF oFolder:aDialogs[1]	
    
    //FOLDER[2]
	@ 010,005 SAY RetTitle("F2_XDTAGEN")    SIZE 40,10 PIXEL OF oFolder:aDialogs[2]	
	@ 010,050 MSGET M->F2_XDTAGEN	PICTURE PesqPict("SF2","F2_XDTAGEN")	SIZE 50,07 PIXEL OF oFolder:aDialogs[2] 
	
	
	@ 051,050 MSGET M->F2_TRANSP	PICTURE PesqPict("SF2","F2_TRANSP")		F3 CpoRetF3("F2_TRANSP")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cTransp:="",.T.),.F.) .Or. (ExistCpo("SA4").And.AB4BDisp(@cTransp))
	@ 066,050 MSGET M->F2_VEICUL1	PICTURE PesqPict("SF2","F2_VEICUL1")	F3 CpoRetF3("F2_VEICUL1")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cVeicul1:="",.T.),.F.) .Or. (ExistCpo("DA3").And.AB4BDisp(@cVeicul1))
	@ 081,050 MSGET M->F2_VEICUL2	PICTURE PesqPict("SF2","F2_VEICUL2")	F3 CpoRetF3("F2_VEICUL2")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cVeicul2:="",.T.),.F.) .Or. (ExistCpo("DA3").And.AB4BDisp(@cVeicul2))	
	@ 095,050 MSGET M->F2_VEICUL3	PICTURE PesqPict("SF2","F2_VEICUL3")	F3 CpoRetF3("F2_VEICUL3")	SIZE 50,07 PIXEL OF oFolder:aDialogs[1] VALID IIf(Vazio(),(cVeicul3:="",.T.),.F.) .Or. (ExistCpo("DA3").And.AB4BDisp(@cVeicul3))	
	
	@ 051,105 MSGET oTransp		VAR cTransp		PICTURE PesqPict("SF2","F2_TRANSP")		WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]
	@ 066,105 MSGET oVeicul1	VAR cVeicul1	PICTURE PesqPict("SF2","F2_VEICUL1")	WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]
	@ 081,105 MSGET oVeicul2	VAR cVeicul2	PICTURE PesqPict("SF2","F2_VEICUL2")	WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]	
	@ 095,105 MSGET oVeicul3	VAR cVeicul3	PICTURE PesqPict("SF2","F2_VEICUL3")	WHEN .F. SIZE 150,07 PIXEL OF oFolder:aDialogs[1]		
	
	@ 110,005 TO 111,310 PIXEL OF oFolder:aDialogs[1]
	@ 113,225 BUTTON OemToAnsi("Confirmar")	SIZE 040,13 FONT oFolder:aDialogs[1]:oFont ACTION (nOpc:=1,oDlg:End())	OF oFolder:aDialogs[1] PIXEL	
	@ 113,270 BUTTON OemToAnsi("Cancelar")	SIZE 040,13 FONT oFolder:aDialogs[1]:oFont ACTION oDlg:End()			OF oFolder:aDialogs[1] PIXEL	
	
	//replica bot�es para folder[2]
   	@ 110,005 TO 111,310 PIXEL OF oFolder:aDialogs[2]
	@ 113,225 BUTTON OemToAnsi("Confirmar")	SIZE 040,13 FONT oFolder:aDialogs[2]:oFont ACTION (nOpc:=1,oDlg:End())	OF oFolder:aDialogs[2] PIXEL	
 	@ 113,270 BUTTON OemToAnsi("Cancelar")	SIZE 040,13 FONT oFolder:aDialogs[2]:oFont ACTION oDlg:End()			OF oFolder:aDialogs[2] PIXEL	
	
	
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
	If nOpc == 1
		RecLock("SF2",.F.)
		SF2->F2_TRANSP	:= M->F2_TRANSP
		SF2->F2_VEICUL1	:= M->F2_VEICUL1
		SF2->F2_VEICUL2	:= M->F2_VEICUL2		
		SF2->F2_VEICUL3	:= M->F2_VEICUL3
		SF2->F2_XDTAGEN	:= M->F2_XDTAGEN
		
		MsUnlock()
	Endif
	

Else

	MsgAlert(OemToAnsi("Criar os campos F2_VEICUL1, F2_VEICUL2 e F2_VEICUL3 ou executar o RdMake UPDFIS"))

Endif

RestArea(aArea)

Return Nil

/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �MenuDef   � Autor � Fabrica B4B		    � Data � 22.09.13 ���
�������������������������������������������������������������������������Ĵ��
���Retorno   �Array com opcoes da rotina.                                 ���
�������������������������������������������������������������������������Ĵ��
���Parametros�Parametros do array a Rotina:                               ���
���          �1. Nome a aparecer no cabecalho                             ���
���          �2. Nome da Rotina associada                                 ���
���          �3. Reservado                                                ���
���          �4. Tipo de Transa��o a ser efetuada:                        ���
���          �		1 - Pesquisa e Posiciona em um Banco de Dados         ���
���          �    2 - Simplesmente Mostra os Campos                       ���
���          �    3 - Inclui registros no Bancos de Dados                 ���
���          �    4 - Altera o registro corrente                          ���
���          �    5 - Remove o registro corrente do Banco de Dados        ���
���          �5. Nivel de acesso                                          ���
���          �6. Habilita Menu Funcional                                  ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function MenuDef()

Private aRotina	:= {	{ "Pesquisar"  ,"AxPesqui"      , 0 , 1,0,.F.},;	
						{ "Visualizar" ,"AxVisual"      , 0 , 2,0,NIL},;	
						{ "Manutencao" ,"U_AB4BManut()" , 0 , 3,0,NIL},;	
						{ "Legenda"    ,"U_EletLeg()"   , 0 , 3,0,NIL}}

Return(aRotina)
                 
/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �EletLeg  � Autor � Fabrica B4B		    � Data � 22.09.13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Legenda			                                          ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
User Function EletLeg()

BrwLegenda(cCadastro, "Legenda", {{ "BR_VERDE" ,"Com data de agendamento"	},;  
				                  { "BR_AZUL"  ,"Sem data de agendamento" 	}})

Return Nil

/*/                
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������Ŀ��
���Programa  �A512Disp  � Autor � Fabrica B4B		    � Data � 22.09.13 ���
�������������������������������������������������������������������������Ĵ��
���Descricao �Display do Campo                                            ���
��������������������������������������������������������������������������ٱ�
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
/*/
Static Function AB4BDisp(cCampo)

Local aArea	:= GetArea()
Local cCpo	:= ReadVar()

Do Case
	Case cCpo == "M->F2_TRANSP"
		cCampo := Posicione("SA4",1,xFilial("SA4")+M->F2_TRANSP,"A4_NOME")
		oTransp:Refresh()
	Case cCpo == "M->F2_VEICUL1"
		cCampo	:= Posicione("DA3",1,xFilial("DA3")+M->F2_VEICUL1,"DA3_DESC")
		oVeicul1:Refresh()	
	Case cCpo == "M->F2_VEICUL2"
		cCampo	:= Posicione("DA3",1,xFilial("DA3")+M->F2_VEICUL2,"DA3_DESC")
		oVeicul2:Refresh()	
	Otherwise
		cCampo	:= Posicione("DA3",1,xFilial("DA3")+M->F2_VEICUL3,"DA3_DESC")
		oVeicul3:Refresh()	
EndCase

RestArea(aArea)

Return(.T.)
