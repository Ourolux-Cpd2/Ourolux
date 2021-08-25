User Function  MT110LOK()
Local nPosCub   := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XCUBAGE'})
Local nPosPBru  := aScan(aHeader,{|x| AllTrim(x[2]) == 'C1_XPESBRU'})
Local nPesAux   := 0
Local nCubTot   := 0
Local nlx       := 0

For nlx := 1 To len(aCols)
    If !aCols[nlx][Len(aCols[nlx])]
        nCubTot	+= aCols[nlx][nPosCub]
        nPesAux	+= aCols[nlx][nPosPBru]

        //Calculo para busca de melhor pre�o de container
        //Rodrigo Nunes - 20/08/2021
        U_OURO006(aCols[nlx][nPosCub],aCols[nlx][nPosPBru],nlx)

    EndIf
Next

_nVolCubado	:= nCubTot
_xPesBru	:= nPesAux

_xoVolCub:Refresh()
_xoPesBru:Refresh()


Return(.T.) 
