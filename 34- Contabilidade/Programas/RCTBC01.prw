#INCLUDE "rwmake.ch"

/*
############################################################################################
############################################################################################
#### PROGRAMA: RCTBC01 ########### AUTOR: Pl�nio Nogueira  ########## DATA: 20/07/18 #######
############################################################################################
#### DESCRI��O: C�digo utilizado para cadastro da Tabela de Relacionamento das Verbas da ###
#### ***************   Folha de Pagamento com suas respectivas Contas Cont�beis.         ###
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

AxCadastro(cString,"Cadastro de Contas Cont�beis x Verbas",cVldExc,cVldAlt)

Return
