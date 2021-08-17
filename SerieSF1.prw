#INCLUDE "PROTHEUS.CH"

/*
+-----------------------------------------------------------------------+
¦Funcao    ¦ SerieSF1 ¦ Autor ¦ Claudino Domingues    ¦ Data ¦ 28/03/16 ¦
+----------+------------------------------------------------------------¦
¦Descricao ¦ Rotina chamada no campo F1_SERIE propriedade validação de  ¦
¦          ¦ usuario, cuja a funcionalidade é preencher com zeros       ¦
¦          ¦ quando o campo estiver vazio, ou completar com zeros a     ¦
¦          ¦ esquerda.                                                  ¦
+-----------------------------------------------------------------------+
*/

User Function SerieSF1()

Local _nCarac := Len(Alltrim(cSerie))

If FUNNAME() == "MATA116"
	If Empty(cSerie)
		cSerie := "000"
	Else
		If _nCarac == 1
			If ISALPHA(cSerie)
				cSerie := "00"+Alltrim(cSerie)
			Else
				cSerie := StrZero(Val(cSerie), TamSX3("F1_SERIE")[1])
			Endif
		ElseIf _nCarac == 2
			cSerie := "0"+Alltrim(cSerie)
		EndIf
	EndIf
Else
	If !l103Auto
		If Empty(cSerie)
			cSerie := "000"
		Else
			If _nCarac == 1
				If ISALPHA(cSerie)
					cSerie := "00"+Alltrim(cSerie)
				Else
					cSerie := StrZero(Val(cSerie), TamSX3("F1_SERIE")[1])
				Endif
			ElseIf _nCarac == 2
				cSerie := "0"+Alltrim(cSerie)
			EndIf
		EndIf
	EndIf
EndIf

Return .T.