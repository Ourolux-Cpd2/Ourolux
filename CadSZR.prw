#include "rwmake.ch"

/*/
Funcao          : CADSZR
Autor           : Gilson Belini
Data            : 19/04/2017
Descricao       : RdMake para Cadastro de Status Receita Federal
Uso             : Especifico empresa Ourolux

/*/

User Function CadSZR()

Private cCadastro := "Cadastro de Status Receita Federal"

Private aRotina := { {"Pesquisar","AxPesqui",0,1},;
                     {"Visualizar","AxVisual",0,2},;
                     {"Incluir","AxInclui",0,3},;
                     {"Alterar","AxAltera",0,4},;
                     {"Excluir","AxDeleta",0,5}}

Private cString := "SZR"

mBrowse(6,1,22,75,cString)