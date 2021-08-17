#include "rwmake.ch"

/*/
Funcao          : CADSZV
Autor           : Gilson Belini
Data            : 08/04/2017
Descricao       : RdMake para Cadastro de Regra de Analise Risk Rating
Uso             : Especifico empresa Ourolux

/*/

User Function CadSZV()

Private cCadastro := "Cadastro de Regra Risk Rating - CISP"

Private aRotina := { {"Pesquisar","AxPesqui",0,1},;
                     {"Visualizar","AxVisual",0,2},;
                     {"Incluir","AxInclui",0,3},;
                     {"Alterar","AxAltera",0,4},;
                     {"Excluir","AxDeleta",0,5}}

Private cString := "SZV"

mBrowse(6,1,22,75,cString)