#include 'protheus.ch'
#include 'parmtype.ch'

/*/{Protheus.doc} OS200DAK
//TODO Descrição auto-gerada.
@author Caio
@since 17/02/2020
@version 1.0
@return ${return}, ${return_description}

@type function
/*/

User Function OS200DAK()
		
Local aArea      := GetArea()
Local aAreaPED   := {}
Local cPedidos   := ""
Local lReprocess := .F.
Local lLote      := .F.
Local cIdReg     := ""
Local cIdPZC     := ""
Local cEmpPrep   := cEmpAnt
Local cFilPrep   := cFilAnt
Local dHoje      := Date()
Local cNewTransp := Alltrim(Iif(Type("DAK_TRANSP") == "C",DAK_TRANSP,""))
Local cOldTransp := "" 
	
	If Select("TRBPED") > 0 .And. !Empty(cNewTransp)
		
		If !Empty(cNewTransp) //varíavel da rotina padrão
			
			aAreaPED := TRBPED->(GetArea())
			
			TRBPED->(DbGoTop())
			
			While TRBPED->(!Eof())
			
				cOldTransp := TRBPED->TRANSP
				
				If !Empty(TRBPED->PED_MARCA) .And. cOldTransp != cNewTransp

					If Select("PR1") == 0
						DbSelectArea("PR1")
					Endif
					
					cPedido := TRBPED->(PED_FILORI+PED_PEDIDO)
					
					PR1->(dbSetOrder(2)) //PR1_FILIAL + PR1_ALIAS + PR1_CHAVE
					PR1->(MsUnlock())
							
					If PR1->(dbSeek(xFilial("PR1")+"SA4"+cPedido))
						
						RecLock("PR1",.F.)
						
							PR1->(dbDelete())
		
						PR1->(MsUnlock())
						
					Endif

					RecLock("PR1",!PR1->(dbSeek(xFilial("PR1")+"SA4"+cPedido)))
					
						PR1->PR1_FILIAL := xFilial("PR1")
						PR1->PR1_ALIAS  := "SA4"
						PR1->PR1_RECNO  := SC5->(Recno())
						PR1->PR1_TIPREQ := "1"
						PR1->PR1_DATINT := Date()
						PR1->PR1_HRINT	:= Time()		
						PR1->PR1_STINT  := "P"
						PR1->PR1_OBSERV := cNewTransp
						PR1->PR1_CHAVE  := cPedido
						
					PR1->(MsUnlock())
					
					cPedidos += cPedido + ";"  
					 
				Endif 
				
				TRBPED->(DbSkip())
				
			EndDo
			
			If !Empty(cPedidos)
				
				cPedidos := Substr(cPedidos,1,Len(cPedidos)-1)
				
				If FindFunction("U_FTOUA012")
					
					StartJob("U_FTOUA012",GetEnvServer(),.F.,lReprocess ;
					                                        ,lLote      ;
					                                        ,cIdReg     ;
					                                        ,cIdPZC     ;
					                                        ,cEmpPrep   ;
					                                        ,cFilPrep   ;
					                                        ,dHoje      ;
					                                        ,cPedidos   )
				
				Else
					
					Alert("Função U_FTOUA012 não compilada. Aviso o administrador do sistema!","OS200DAK")
					
				Endif
				
			Endif
			
			If !Empty(aAreaPED)
				RestArea(aAreaPED)
			Endif	
			
		Endif
		
	Endif
	
	If Empty(DAK->DAK_TRANSP)
		
		If RecLock("DAK",.F.)
		
			DAK->DAK_TRANSP := SC5->C5_TRANSP
			
			DAK->(MsUnlock())
		
		Endif
		
	Endif
		 
	RestArea(aArea)
	
Return(Nil)