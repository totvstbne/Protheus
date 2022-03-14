//	#########################################################################################
//	Projeto: PETCARE
//	Modulo : PCO
//	Fonte  : ³PCOA1001.prw
//	---------+-------------------+-----------------------------------------------------------
//	Descricao ³Ponto de Entrada utilizado para adicionar opcoes no menu do usuario
//	---------+-------------------+-----------------------------------------------------------
//	Objetivo ³Utilizado para adicionar opcoes para exportar e importar dados do Excel
//	             |
//	---------+-------------------+-----------------------------------------------------------
//	#########################################################################################

User Function PCOA1001()
Local	_aRotina	:= {}
Local   _aRot		:= {{OemToAnsi("Importar"),'ExecBlock("PETPCO01",.f.,.f.)' , 0 , 2 }}
Local   _aRotAnt		:= {{OemToAnsi("Importar*"),'ExecBlock("BFPC004D",.f.,.f.)' , 0 , 2 }}

aAdd(_aRotina, {OemToAnsi("Excel")	,_aRot,0,3})
//aAdd(_aRotina, {OemToAnsi("Excel*")	,_aRotAnt,0,3})
Return _aRotina 
