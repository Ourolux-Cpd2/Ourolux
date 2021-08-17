#INCLUDE "PROTHEUS.CH"
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FSEV050   ºAutor  ³Norbert Waage Juniorº Data ³  24/04/06   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Validacao da condicao de pagamento utilizada                º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³Validaço do Usuario no campo UA_CONDPG/C5_CONDPAG           º±± 
±±ºUso       ³Filtro tipo 6 - Consulta padrao SE4                         º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/
User Function FSEV050(cCond)

Local nRet 		:= 1
Local lInMat410 := IsInCallStack("MATA410")
Local lInTMK271 := IsInCallStack("TMKA271")
Local nValor    := 0


//Default cCond := IIf(IsInCallStack("MATA410"),M->C5_CONDPAG,M->UA_CONDPG)
If Type("L410Auto")!="U" .And. L410Auto
	Return(.T.)
EndIf

If lInTMK271 .And. lTK271Auto 
	Return .T.
EndIf

If !(lInMat410 .Or. lInTMK271) .Or. U_IsAdm() .OR. U_IsFreeCondPgt() .Or. (Type("lTk271Auto") <> "U" .AND. lTk271Auto)//lTK271Auto
	Return (.T.)
EndIf  

If lInTMK271
	nValor	:= aValores[6]
	nRet	:= U_VldCPG(nValor,cCond)

ElseIf lInMat410
	If M->C5_TIPO == "N" 
		//nRet := U_VldCPG(U_TotPed(),cCond)	//Na inclusao nunca vamos ter o valor no SC6
		nRet:= U_VldCPG(nValor,cCond)	//Sol.Fernando-26/11/2020 - André - Correção na Validação do campo 
		nRet:= if(nRet>6,0,nRet)
	Else
		nRet:= 0
	EndIf

Else	//Demais Rotinas
	nRet	:= 0
EndIf

Return (nRet == 0)
