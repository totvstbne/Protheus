#INCLUDE "rwmake.ch"

/*
############################################################################################
############################################################################################
#### PROGRAMA: RCTBC01 ########### AUTOR: Plínio Nogueira  ########## DATA: 20/07/18 #######
############################################################################################
#### DESCRIÇÃO: Código utilizado para cadastro da Tabela de Relacionamento das Verbas da ###
#### ***************   Folha de Pagamento com suas respectivas Contas Contábeis.         ###
############################################################################################
#### USO: MP12 -> Cadastro Verbas x Cta Contabeis                                      #####
############################################################################################
############################################################################################
*/

User Function RCTBC01


//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX
// Declaracao de Variaveis                                             X
//XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

Local cVldAlt := ".T." // Validacao para permitir a alteracao. Pode-se utilizar ExecBlock.
Local cVldExc := ".T." // Validacao para permitir a exclusao. Pode-se utilizar ExecBlock.

Private cString := "ZZA"

dbSelectArea("ZZA")
dbSetOrder(1)

AxCadastro(cString,"Cadastro de Contas Contábeis x Verbas",cVldExc,cVldAlt)

Return
