#Include "Protheus.ch"
/*
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
�������������������������������������������������������������������������ͻ��
���Programa  �TMKDADOS  �Autor  �WAR                 � Data �  09/05/06   ���
�������������������������������������������������������������������������͹��
���Desc.     � Ponto de entrada chamado para validar os campos na tela    ���
���          � de condi�ao de pagamento no Call Center                    ���
�������������������������������������������������������������������������͹��
���Uso       � AP8                                                        ���
�������������������������������������������������������������������������ͼ��
�����������������������������������������������������������������������������
�����������������������������������������������������������������������������
*/


User Function TMKDADOS(cCodPagto, cCodTransp, cEndCob,; 
					   cEndE , cCidC, cCepC,;
					   cBairroC, cBairroE, cCidE,;
					   cCepE , cEstE, aForma)
						
Local lRet := .T.
Local nLiquido 		:=	0
Local nValNFat 		:=	0
Local nLimite		:=	0
Local nRet			:=  0
Local aArea	   		:=	GetArea()
Local lEndE := .F.

// Claudino - 10/12/15 - Comentei
//If (cCodTransp == '000000')
//	lRet := .F.
//	ApMsgInfo("Utilize outra transportadora!","TMKDADOS")
//EndIf

// Claudino - 10/12/15
**********************************************************
If cFilAnt == '01' // Claudino - I1611-915 - 11/11/16
	If !Empty(cCodTransp)
		If cNivel < 3 .or. !(AllTrim(__cUserId) $ GetMv("FS_REPTRAN"))
			lRet := .F.
			ApMsgInfo("Favor n�o digitar a transportadora!","TMKDADOS")
		Else
			//If Upper(UsrRetName(__cUserId)) $ GetMv("FS_RETIRA") .AND. cCodTransp <> "99    "
			If Upper(cUserName) $ GetMv("FS_RETIRA") .AND. cCodTransp <> "99    "
				lRet := .F. 
				ApMsgStop("O Depto Comercial s� pode digitar a transportadora RETIRA!","TMKDADOS")
			EndIf
		EndIf
	EndIf
EndIf
**********************************************************
// Claudino - 10/12/15

If lRet .AND. Empty (cCodPagto)
	lRet := .F.
	ApMsgInfo("Condi�ao de pagamento deve ser informada! Pagt Vazio","TMKDADOS")
EndIf

// Claudino - 10/12/15 - Comentei
//If lRet .AND. Empty (cCodTransp)
//	lRet := .F.
//	ApMsgInfo("Transportadora deve ser informada!","TMKDADOS")
//EndIf

If lRet

	// Validate O Endere�o da entrega
	lEndE := VldEndEnt(cCodPagto, cCodTransp, cEndCob, ; 
				   cEndE , cCidC, cCepC,           ;
				   cBairroC, cBairroE, cCidE,      ;
				   cCepE , cEstE)
	If !lEndE
		lRet := .F.
		ApMsgStop("E proibido alterar o endere�o de Cobranca/Entrega!","TMKDADOS")
	EndIf
EndIf

RestArea(aArea)

Return (lRet)


///////////////////////////////////////////////////////
/* 			VALIDATE END DA ENTREGA                  */
///////////////////////////////////////////////////////

Static Function VldEndEnt(cCodPagto, cCodTransp, cEndCob, ; 
						  cEndE , cCidC, cCepC ,   ;
						  cBairroC, cBairroE, cCidE, ;
						  cCepE , cEstE)

Local lRet:= .T.
	
If cEndCob # SA1->A1_ENDCOB .Or.;
	cEndE # SA1->A1_ENDENT .Or.;
	cCidC # SA1->A1_MUNC   .Or.;
	cCepC # SA1->A1_CEPC   .Or.;
	cBairroC # SA1->A1_BAIRROC .Or.; 
	cBairroE # SA1->A1_BAIRROE .Or.;
	cCidE # SA1->A1_MUNE .Or.;
	cCepE # SA1->A1_CEPE .Or.;
	cEstE # SA1->A1_ESTE
	
	lRet:= .F. 
EndIf

Return(lRet)
						