#INCLUDE "PROTHEUS.CH"
 
User Function OS200DEA()
Local aButtons := PARAMIXB[1]
Local nTam     := 0
Local nPosTran := 0
Local nPosVeic := 0
Local cUsrLib  := SuperGetMV("ES_VEIAUT",.F.,"")

If __cUSERID $ cUsrLib
    Return(aButtons)
EndIf

If ValType(aButtons)== "A" .And. Len(aButtons) > 0    
    nTam := Len(aButtons)
    nPosTran := aScan(aButtons, {|x| Upper(Alltrim(x[1])) == "TRANSP" })    
    If nPosTran <> 0
        aDel(aButtons,nPosTran)
        aSize(aButtons,nTam-1)
    EndIf
    
    nTam := Len(aButtons)
    nPosVeic := aScan(aButtons, {|x| Upper(Alltrim(x[1])) == "CARGA" })
    If nPosVeic <> 0
        aDel(aButtons,nPosVeic)   
        aSize(aButtons,nTam-1)
    EndIf
EndIf
 
Return aButtons
