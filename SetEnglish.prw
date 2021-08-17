#Include "rwmake.ch"

User Function SetEnglish() 

Local nCount := 0
dbSelectArea("SX6")
dbSetOrder(1)
SX6->(dbGoTop())

While !SX6->(Eof())
	If !Empty(SX6->X6_CONTEUD)
		SX6->(RecLock("SX6",.F.))
		Replace SX6->X6_CONTENG  With SX6->X6_CONTEUD  
		SX6->(MSUnLock())
		nCount = nCount + 1 
	EndIf	
	SX6->(dbSkip())
End
	
Return() 
