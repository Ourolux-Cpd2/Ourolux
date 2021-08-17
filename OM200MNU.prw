#INCLUDE "PROTHEUS.CH"
 //.
User Function OM200MNU()
    Local cUsrLib := SuperGetMV("ES_VEIAUT",.F.,"")
    
    If Funname() == "OMSA200"
        
        If __cUSERID $ cUsrLib
            Return(aRotina)
        EndIf
        
        If ValType(aRotina)== "A" .And. Len(aRotina) > 0    
            If ValType(aRotina[5][2]) == "A"  .And. Len(aRotina[5][2]) > 0    
                If Upper(Alltrim(aRotina[5][2][5][1])) == "ASSOCIAR VEICULO"
                    nTam := Len(aRotina[5][2])
                    aDel(aRotina[5][2],5)
                    aSize(aRotina[5][2],nTam-1)
                EndIf
            EndIf
        EndIf
    EndIf

Return aRotina
