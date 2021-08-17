#include "rwmake.ch"

/*/
Funcao          : CADSZS
Autor           : Gilson Belini
Data            : 19/04/2017
Descricao       : RdMake para Cadastro de Status Sintegra
Uso             : Especifico empresa Ourolux

/*/

User Function CadSZS()

Private cCadastro := "Cadastro de Status Sintegra"

Private aRotina := { {"Pesquisar","AxPesqui",0,1},;
                     {"Visualizar","AxVisual",0,2},;
                     {"Incluir","AxInclui",0,3},;
                     {"Alterar","AxAltera",0,4},;
                     {"Excluir","AxDeleta",0,5}}

Private cString := "SZS"

mBrowse(6,1,22,75,cString)