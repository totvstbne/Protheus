
//	#########################################################################################
//	Projeto: PETCARE
//	Modulo : PCO
//	Fonte  : �PCOA1002.prw
//	---------+-------------------+-----------------------------------------------------------
//	Descricao �Ponto de Entrada utilizado para adicionar opcoes no menu do usuario
//	---------+-------------------+-----------------------------------------------------------
//	Objetivo �Utilizado para adicionar opcoes para exportar e importar dados do Excel
//	             |
//	---------+-------------------+-----------------------------------------------------------
//	#########################################################################################
 
User Function PCOA1201()
Local	_aRotina	:= {}
Local   _aRot		:= {{OemToAnsi("Importar"),'ExecBlock("PETPCO02",.f.,.f.)' , 0 , 2 }}

aAdd(_aRotina, {OemToAnsi("Excel")	,_aRot,0,2})

Return _aRotina 