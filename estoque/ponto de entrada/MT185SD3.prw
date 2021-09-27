#include 'protheus.ch'
#include 'parmtype.ch'
#INCLUDE 'FWMVCDEF.CH'
/*/{Protheus.doc} MT185SD3
Gravação dos campos na SD3
@author Diogo
@since 27/07/2018
@version 1.0
@type function
/*/
user function MT185SD3()
	M->D3_YORCSRV	:= SCP->CP_YORCSRV	
	M->D3_YLOCATE	:= SCP->CP_YLOCATE
	M->D3_YITORC 	:= SCP->CP_YITORC 
	M->D3_YTPCOD 	:= SCP->CP_YTPCOD
return