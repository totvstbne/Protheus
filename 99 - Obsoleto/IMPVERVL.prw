#include 'protheus.ch'
#include 'parmtype.ch'


//////////////////////////////////////
// autor   joao filho               // 
//==================================//
// data    15/05/2018               //
//==================================//
// FAZ A LEITURA DA LINHA DO TXT,   //
// LER O CPF DO FUNCIONÁRIO E RETO- //
// NA O VALOR DA VERBA DO MESMO     //
//                                  //
////////////////////////////////////// 


user function IMPVERVL(nTipo)
	Local nRet := 0

	IF FUNNAME() == "GPEA200"
		RETURN
	ENDIF

	IF cCodigo == "004"    // PARA IMPORTAÇÃO DE HAPVIDA    (CSV)

		aHapvid := StrTokArr(alltrim(TXT),";")
		nRet := aHapvid[15]
		
	ENDIF

Return nRet	
