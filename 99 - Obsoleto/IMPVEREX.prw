#include 'protheus.ch'
#include 'parmtype.ch'
#include "topconn.ch"

//////////////////////////////////////
// autor   joao filho               // 
//==================================//
// data    15/05/2018               //
//==================================//
// FAZ A LEITURA DA LINHA DO TXT,   //
// LER O CPF DO FUNCION�RIO E RETO- //
// NA A MATR�CULA DO MESMO          //
//                                  //
////////////////////////////////////// 

user function IMPVEREX()

	// ntipo    1  ->  matricula
	//          2  ->  valor
	Local cRet := ""
	Local aHapvid := {}

	IF FUNNAME() == "GPEA200"
		RETURN
	ENDIF

	if cCodigo == "001"    // PARA IMPORTA��O DE FARMACIA

		cQuery := " SELECT * "
		cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA
		cQuery += " WHERE RA_SITFOLH <> 'D'
		cQuery += " AND RA_CIC = '"+ SUBSTR(TXT,1,11) +"' 
		
		IF select("TFOL") > 0
			TFOL->(DBCLOSEAREA())
		ENDIF 
		
		TcQuery cQuery New Alias TFOL
		
		cRet := TFOL->RA_MAT

		//cRet:= POSICIONE("SRA",5,XFILIAL("SRA")+SUBSTR(TXT,1,11),"RA_MAT")

		// verificar se valor � zerado
		nRet := SUBSTR(TXT,14,6)

		if val(nRet) == 0
			cRet := "XXXXXX"
		endif

	ELSEIF cCodigo == "002"    // PARA IMPORTA��O DE PORTOCRED  FER

		//cRet:= POSICIONE("SRA",5,XFILIAL("SRA")+SUBSTR(TXT,1,11),"RA_MAT")

		cQuery := " SELECT * "
		cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA
		cQuery += " WHERE RA_SITFOLH <> 'D'
		cQuery += " AND RA_CIC = '"+ SUBSTR(TXT,1,11) +"' 
		
		IF select("TFOL") > 0
			TFOL->(DBCLOSEAREA())
		ENDIF 
		
		TcQuery cQuery New Alias TFOL
		
		cRet := TFOL->RA_MAT

		// verificar se valor � zerado
		nRet := SUBSTR(TXT,13,6)

		if val(nRet) == 0
			cRet := "XXXXXX"
		endif

	ELSEIF cCodigo == "003"    // PARA IMPORTA��O DE RASTREAMENTO  FER

		//cRet:= POSICIONE("SRA",5,XFILIAL("SRA")+SUBSTR(TXT,1,11),"RA_MAT")

		cQuery := " SELECT * "
		cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA
		cQuery += " WHERE RA_SITFOLH <> 'D'
		cQuery += " AND RA_CIC = '"+ SUBSTR(TXT,1,11) +"' 
		
		IF select("TFOL") > 0
			TFOL->(DBCLOSEAREA())
		ENDIF 
		
		TcQuery cQuery New Alias TFOL
		
		cRet := TFOL->RA_MAT

		// verificar se valor � zerado
		nRet := SUBSTR(TXT,14,6)

		if val(nRet) == 0
			cRet := "XXXXXX"
		endif

	ELSEIF cCodigo == "004"    // PARA IMPORTA��O DE HAPVIDA    (CSV)  FER

		aHapvid := StrTokArr(alltrim(TXT),";")
		cCpf := SUBSTR( aHapvid[5],3,12)
		cCpf := StrTran( cCpf, "-", "" )

		//cRet := POSICIONE("SRA",5,XFILIAL("SRA")+cCpf,"RA_MAT")
		cQuery := " SELECT * "
		cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA
		cQuery += " WHERE RA_SITFOLH <> 'D'
		cQuery += " AND RA_CIC = '"+ cCpf +"' 
		
		IF select("TFOL") > 0
			TFOL->(DBCLOSEAREA())
		ENDIF 
		
		TcQuery cQuery New Alias TFOL
		
		cRet := TFOL->RA_MAT

		// verificar se valor � zerado
		aHapvid := StrTokArr(alltrim(TXT),";")
		nRet := aHapvid[15]
		if val(nRet) == 0
			cRet := "XXXXXX"
		endif

	ELSEIF cCodigo == "005"    // PARA IMPORTA��O ODONTO   FER

		//cRet:= POSICIONE("SRA",5,XFILIAL("SRA")+SUBSTR(TXT,1,11),"RA_MAT")
		cQuery := " SELECT * "
		cQuery += " FROM  "+RETSQLNAME("SRA")+" SRA
		cQuery += " WHERE RA_SITFOLH <> 'D'
		cQuery += " AND RA_CIC = '"+ SUBSTR(TXT,1,11) +"' 
		
		IF select("TFOL") > 0
			TFOL->(DBCLOSEAREA())
		ENDIF 
		
		TcQuery cQuery New Alias TFOL
		
		cRet := TFOL->RA_MAT

		// verificar se valor � zerado
		nRet := SUBSTR(TXT,14,6)

		if val(nRet) == 0
			cRet := "XXXXXX"
		endif

	ELSEIF cCodigo == "006"    // PARA IMPORTA��O POLICARD

		cRet:= POSICIONE("SRA",1,XFILIAL("SRA")+SUBSTR(TXT,22,6),"RA_MAT")

		// verificar se valor � zerado
		nRet := SUBSTR(TXT,79,5)

		if val(nRet) == 0
			cRet := "XXXXXX"
		endif	

	ENDIF

return cRet

