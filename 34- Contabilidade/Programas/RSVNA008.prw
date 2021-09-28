#include "rwmake.ch"
#include "protheus.ch"
#include "topconn.ch"
/*/{Protheus.doc} ZBPLZBO
Importação da planilha de orçamento
@author diogo
@since 23/04/2019
@version 1.0
@example
(examples)
@see (links_or_references)
/*/

user function RSVNA008()
	Local aPergs		:= {}
	Local c_Arquivo		:= Space(300)
	Private aDados		:= {}
	Private aErros		:= {}
	Private aRet		:= {}
	Private aDadPl		:= {}
	Private oProcess
	
	aAdd(aPergs,{6,"Planilha Orçamentária",c_Arquivo,"","","",60,.T.,"Arquivo CSV (*.csv) |*.csv"})
	aAdd(aPergs,{1,"Filial"	, space(6),"@!",'.T.','SM0','.T.',40,.T.})
	aAdd(aPergs,{1,"Ano"	, space(4),"@!",'.T.','','.T.',40,.T.})
	If ParamBox(aPergs,"Importação Planilha",@aRet)
		oProcess	:= MsNewProcess():New({|lCancelar| Controle(aRet,@lCancelar) },"Processando...","Iniciando...",.T.)
		oProcess:Activate()
	EndIf
return

Static Function Controle(aRet,lCancelar)
	lErros := .F.
	oProcess:SetRegua1(4)
	oProcess:IncRegua1("Lendo Arquivo CSV")
	cSVArray(aRet[1],@aDadPl,@lCancelar)
	If !ControleErro(@lCancelar)
	Return
	EndIF
	oProcess:IncRegua1("Importando dados")
	fImport(@aDadPl,@lErros)
	If !ControleErro(@lCancelar,@lErros)
	Return
	EndIF
	AppBringToFront()
	MsgInfo("Processamento concluido!")
Return

Static Function ControleErro(lCancelar, lErros)
	If lCancelar .OR. lErros
		if lErros
			MsgAlert("Processamento concluido - alguns itens não foram salvos. Verifique log.")
		endif
		If !Empty(aErros)
			aEval(aErros,{|x| AutoGrLog(x) })
			AppBringToFront()
		EndIf
		if lCancelar
			Alert("Processamento Cancelado!")
		endif
	Return .F.
	EndIf
Return .T.

static function fImport(aCsv, lCancelar)

	Local aArea 	:= GetArea()
	Local nTamanho	:= Len(aCsv)

	If len(aCsv) <= 0
		Return
	Endif
	oProcess:SetRegua2(Len(aCsv))
	DbSelectArea("ZB1")
	
	cQuery:= "SELECT TOP 1 ZB1_ANO FROM "+RetSqlName("ZB1")+" ZB1 "
	cQuery+= "WHERE ZB1.D_E_L_E_T_ = ' ' AND "
	cQuery+= "ZB1_FILIAL = '"+aCsv[len(aCsv)][1]+"' AND "
	cQuery+= "ZB1_ANO = '"+aCsv[len(aCsv)][2]+"' "
	tcQuery cQuery new Alias QRZB1
	If QRZB1->(!Eof())
		If !(msgYesNo("Planilha orçamentária já existente para esse ano, deseja importar novamente?"))
		 	QRZB1->(dbCloseArea())
		 	Return
		Else
			cUpd:="DELETE FROM "+RetSqlName("ZB1")+" WHERE ZB1_FILIAL = '"+aCsv[len(aCsv)][1]+"' AND ZB1_ANO='"+aCsv[len(aCsv)][2]+"' "
			tcSqlExec(cUpd)
			TcRefresh(RetSqlName("ZB1"))
		Endif
	Endif
	QRZB1->(dbCloseArea())
	
	For nx := 1 to len(aCsv)
		Reclock("ZB1",.T.)
			ZB1->ZB1_FILIAL		:= aCsv[nX][1]	
			ZB1->ZB1_ANO		:= aCsv[nX][2]
			ZB1->ZB1_COMPET		:= aCsv[nX][3]	
			ZB1->ZB1_CCUSTO		:= aCsv[nX][4]
			ZB1->ZB1_NMCUSTO	:= aCsv[nX][5]	
			ZB1->ZB1_FONTE		:= aCsv[nX][6]	
			ZB1->ZB1_CONTA		:= aCsv[nX][7]	
			ZB1->ZB1_NMCONTA	:= aCsv[nX][8]	
			ZB1->ZB1_MONTANT	:= aCsv[nX][9]	
			ZB1->ZB1_VALOR		:= val(strtran(strtran(alltrim(aCsv[nX][10]),".",""),",","."))	
			ZB1->ZB1_DEPARA		:= "N"
		MsUnlock()
	Next
	RestArea(aArea)
Return

Static Function cSVArray(_cArquivo,aArray,lCancelar)
	Local _nHa
	Local aLinha
	If (_nHa := FT_FUse(AllTrim(_cArquivo)))== -1	//Abre Arquivo
		help(" ",1,"NOFILEIMPOR")
		lCancelar	:= .T.
	Return .F.
	EndIf
	FT_FGOTOP()
	FT_FSKIP()
	While !FT_FEOF()
		If lCancelar
			FT_FUSE()
		Return
		EndIf
		aLinha	:= Separa(FT_FREADLN(),";",.T.)
		If Len(aLinha)<10
			AADD(aErros,"Erro de estrutura no arquivo! Verifique o layout do arquivo "+_cArquivo)
			lCancelar	:= .T.
			Exit
		EndIf
		If !Empty(aLinha[1])
			aadd(aArray,{aRet[2];	//Filial
			,aRet[3]; 				//Ano
			,fGetMes(alltrim(aLinha[9])); 	//Competência
			,alltrim(aLinha[3]); 	//Centro de Custo
			,alltrim(aLinha[4]); 	//Nome do Centro de Custo
			,alltrim(aLinha[5]); 	//Fonte da Informação
			,alltrim(aLinha[6]); 	//Código da Conta
			,alltrim(aLinha[7]); 	//Nome da Conta
			,alltrim(aLinha[8]); 	//Montante
			,aLinha[10]; 	//Valor
			})
		EndIf
		FT_FSKIP()
	EndDo
	FT_FUSE()
Return

Static Function fGetMes(cDado)
	Local cRet:= ""
	If "JAN" $ upper(alltrim(cDado))
		cRet:= "01" 
	Elseif "FEV" $ upper(alltrim(cDado))
		cRet:= "02"
	Elseif "MAR" $ upper(alltrim(cDado))
		cRet:= "03"
	Elseif "ABRI" $ upper(alltrim(cDado)) 
		cRet:= "04"
	Elseif "MAIO" $ upper(alltrim(cDado))
		cRet:= "05"
	Elseif "JUNHO" $ upper(alltrim(cDado))
		cRet:= "06"
	Elseif "JULHO" $ upper(alltrim(cDado))
		cRet:= "07"
	Elseif "AGOST" $ upper(alltrim(cDado))
		cRet:= "08"
	Elseif "SETEMB" $ upper(alltrim(cDado))
		cRet:= "09"
	Elseif "OUTUBR" $ upper(alltrim(cDado))
		cRet:= "10"
	Elseif "NOVEM" $ upper(alltrim(cDado))
		cRet:= "11"
	Elseif "DEZEM" $ upper(alltrim(cDado))
		cRet:= "12"
	Else
		cRet:= "00"
	Endif
Return cRet