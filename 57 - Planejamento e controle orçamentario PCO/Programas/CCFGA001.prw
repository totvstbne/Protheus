#include 'protheus.ch'
#include 'parmtype.ch'

#DEFINE CEOL		CHR(13) + CHR(10) //Quebra de Linha

/*
+-------------+----------+--------+---------------------------------+-------+-------------+
| Programa:   | CCFGA001 | Autor: | Rubens Cruz - Anadi	     	    | Data: | Maio/2019   |
+-------------+----------+--------+---------------------------------+-------+-------------+
| Descri��o:  | Rotina para importar dados no Protheus a partir de um arquivo CSV		  |
+-------------+---------------------------------------------------------------------------+
| Uso:        | Canex							                                          |
+-------------+------------------------------------+--------------------------------------+
*/

User Function CCFGA001()
	Local _nAlt, _nLarg
	Local _lOk		:= .T.
	
	
	Private oFile, oDlg
	Private _cErro		:= ""
	Private _cArq		:= ""
	Private _nLinha		:= 10
	Private _cTab		:= Space(3)
	Private _nIndice	:= 1
	Private _cCpos		:= ""
	Private _cCposInd	:= ""
	Private _nTipo		:= 0
	
	DEFINE DIALOG oDlg TITLE "Append Arquivo CSV em Tabela Protheus" FROM 0,0 TO 290,460 PIXEL
		_nAlt 	:= (oDlg:nClientHeight / 2) - 40
		_nLarg	:= (oDlg:nClientWidth / 2) - 20
	
		@ _nLinha		, 020 Say "Tabela que ser� atualizada (Ex: SRA)" Size 160, 15 Of oDlg Pixel 
		@ _nLinha + 010	, 020 MsGet _cTab Size 080, 15 Of oDlg Picture "@!" Pixel  
		@ _nLinha		, 130 Say "Indice da tabela cadastrado na SIX" Size 160, 15 Of oDlg Pixel 
		@ _nLinha + 010	, 130 MsGet _nIndice Size 080, 15 Of oDlg Picture "@E 99" Pixel 
		_nLinha += 030
	
		@ _nLinha		, 020 Say "Caminho do arquivo CSV a ser importado" Size 200, 15 Of oDlg Pixel 
		@ _nLinha + 010	, 020 MsGet _cArq Size 150, 15 Of oDlg When .F. Pixel 
		@ _nLinha + 010, 180 BUTTON _oBtn3 PROMPT "Selecionar" SIZE 040,015 OF oDlg ACTION {|| _cArq := cGetFile("*.csv|*.csv","Selecione o arquivo a ser importado",0,,.t.,GETF_LOCALHARD) } PIXEL
		_nLinha += 030

//		@ _nLinha		, 020 Say "Campos que ser�o considerados no �ndice (separados por ';')" Size 160, 15 Of oDlg Pixel 
//		@ _nLinha + 010	, 020 GET oMemo VAR _cCposInd MEMO Size 200, 30 Of oDlg Pixel 
//		_nLinha += 045

//		@ _nLinha		, 020 Say "Campos a serem importados (separados por ';')" Size 160, 15 Of oDlg Pixel 
//		@ _nLinha + 010	, 020 GET oMemo VAR _cCpos MEMO Size 200, 30 Of oDlg Pixel 
//		_nLinha += 045

		@ _nLinha		, 020 Say "Tipo de Importa��o:" Size 160, 15 Of oDlg Pixel 
		@ _nLinha + 010 , 020 RADIO oRadMenu1 VAR _nTipo ITEMS "Inclus�o","Altera��o" SIZE 092, 052 OF oDlg COLOR 0, 16777215 PIXEL 

		@ _nAlt, _nLarg - 040 BUTTON _oBtn1 PROMPT "Cancelar" 	SIZE 040,015 OF oDlg ACTION {|| _lOk := .F., oDlg:End()	} PIXEL
		@ _nAlt, _nLarg - 090 BUTTON _oBtn2 PROMPT "Confirmar"  SIZE 040,015 OF oDlg ACTION {|| Valok()					} PIXEL
	ACTIVATE DIALOG oDlg CENTERED

If Empty(_cArq)
	Return
EndIf	

If _lOk
	Set Century On
	
	oFile := FWFileReader():New(_cArq)
	If (oFile:Open())
		Processa({|| GrvDados()},"Gravando Dados")
	Else
		Alert("Arquivo CSV n�o pode ser aberto")
	EndIf
	
	oFile:Close()
	
	If !Empty(_cErro)
		MostrLog(_cErro)
	EndIf
EndIf

	
Return

/*
+------------+------------+-------+------------------------------------------+------+---------------+
| Programa   | GrvDados	  | Autor | Rubens Cruz - Anadi Consultoria 		 | Data | Novembro/2018	|
+------------+------------+-------+------------------------------------------+------+---------------+
| Descricao  | Fun��o para gravar os dados na tabela SB7 ap�s valida��o					    		|
+------------+--------------------------------------------------------------------------------------+
| Uso        | Canex												                          		    |
+------------+--------------------------------------------------------------------------------------+
*/

Static Function GrvDados()
	Local _aCposInd, _aCpos
	Local nX, nY, _nPosInd, _nPosCpo
	Local _cLinAux, _cFilial, _cMat, _cAux
	Local _aHeader
	Local _nCont	:= 0
	Local _cInd		:= ""
	
	Private _aAux
	
	ProcRegua(0)
	
	IncProc()
	IncProc()//Adicionado segunda vez para carregar barra de progresso sem fun��o de Loop

	_cAux		:= oFile:GetLine()
	//Tratativa para caracteres estranhos que geram em alguns casos na convers�o de XLS para CSV
	If (Substr(_cAux,1,3) == '﻿')
		_cAux := Substr(_cAux,4)
	EndIf
	
	_aHeader 	:= StrTokArr2(_cAux,";",.T.)
	_aHeader 	:= ValCols(_aHeader)
	
	DbSelectArea("SIX")
	DbSetOrder(1)
	If DbSeek( _cTab + cValToChar(_nIndice) )
		//Define o indice que ser� utilizado na busca
		_aCposInd := StrTokArr2(Alltrim(SIX->CHAVE),"+")
	Else
		Alert("Indice n�o encontrado")
		Return
	EndIf

	For nX := 1 To Len(_aCposInd)
		//Se for campo data, tira DTOS para efetuar a consulta e compara��o corretamente
		If "DTOS(" $ _aCposInd[nX]
			_aCposInd[nX] := StrTran(_aCposInd[nX],"DTOS(","")
			_aCposInd[nX] := StrTran(_aCposInd[nX],")","")
		EndIf
		_nPosInd := Ascan(_aHeader,{|x| x[1] == _aCposInd[nX]} )
		If _nPosInd > 0
			_cInd += "+ _aAux[" + cValToChar(_nPosInd) + "] "
		Else
			Alert("Campo de �ndice " + _aCposInd[nX] + " n�o identificado no CSV" )
			Return
		EndIf
	Next nX
	_cInd := Substr(_cInd,3)

	While (oFile:HasLine())
		_nCont++
		_cLinAux := oFile:GetLine()

		//Linhas em branco dever�o ser puladas
		If Empty(_cLinAux) 
			Loop
		EndIf

		_aAux := StrTokArr2(_cLinAux,";",.T.)
		
		IncProc("Importando linha " + cValToChar(_nCont))
		
		DbSelectArea(_cTab)
		DbSetOrder(_nIndice)

		//Se for inclus�o
		If _nTipo = 1
			//Completa com espa�os para conseguir efetuar o seek 
			For nX := 1 To Len(_aCposInd)
				_nPosCpo := Ascan(_aHeader,{|x| x[1] == _aCposInd[nX]} )
				If _nPosCpo > 0 .AND. _aHeader[_nPosCpo][2] == "C"
					_aAux[_nPosCpo] := Padr(_aAux[_nPosCpo],_aHeader[_nPosCpo][3])
				EndIf
			Next nX

			If !DbSeek( &(_cInd) )
				RecLock(_cTab,.T.)
					//Depois grava os campos informados
					For nX := 1 To Len(_aHeader)
						_nPosCpo := Ascan(_aHeader,{|x| x[1] == _aHeader[nX][1]} )
						If _nPosCpo > 0
							Do Case
								Case _aHeader[_nPosCpo][2] == "N"
									_aAux[_nPosCpo] := StrTran(_aAux[_nPosCpo],".","")
									_aAux[_nPosCpo] := StrTran(_aAux[_nPosCpo],",",".")
									_aAux[_nPosCpo]:= Val(_aAux[_nPosCpo])
								Case _aHeader[_nPosCpo][2] == "D"
									_aAux[_nPosCpo] := CTOD(_aAux[_nPosCpo])
								Case _aAux[_nPosCpo] == "NULL" //Quando o campo for nulo, grava vazio
									_aAux[_nPosCpo] := ''
								Otherwise
									_aAux[_nPosCpo] := Upper(NoAcento(Alltrim(_aAux[_nPosCpo])))
							EndCase
							(_cTab)->&(_aHeader[_nPosCpo][1])	:= _aAux[_nPosCpo]
						EndIf
					Next nX
				MsUnlock()
			Else
				_cErro += "Linha " + cValToChar(_nCont) + ": Chave '" + &(_cInd) + "' j� existe " + Chr(13) + Chr(10)
				Loop
			EndIf
		Else //Se for altera��o
			If DbSeek( &(_cInd) )
				RecLock(_cTab,.F.)
					For nX := 1 To Len(_aHeader)
						_nPosCpo := Ascan(_aHeader,{|x| x[1] == _aHeader[nX][1]} )
						If _nPosCpo > 0
							Do Case
								Case _aHeader[_nPosCpo][2] == "N"
									_aAux[_nPosCpo] := StrTran(_aAux[_nPosCpo],".","")
									_aAux[_nPosCpo] := StrTran(_aAux[_nPosCpo],",",".")
									_aAux[_nPosCpo]:= Val(_aAux[_nPosCpo])
								Case _aHeader[_nPosCpo][2] == "D"
									_aAux[_nPosCpo] := CTOD(_aAux[_nPosCpo])
								Case _aAux[_nPosCpo] == "NULL" //Quando o campo for nulo, grava vazio
									_aAux[_nPosCpo] := ''
								Otherwise
									_aAux[_nPosCpo] := Upper(NoAcento(Alltrim(_aAux[_nPosCpo])))
							EndCase
							(_cTab)->&(_aHeader[_nPosCpo][1])	:= _aAux[_nPosCpo]
						EndIf
					Next nX
				MsUnlock()
			Else
				_cErro += "Linha " + cValToChar(_nCont) + ": Chave " + &(_cInd) + " n�o existe " + Chr(13) + Chr(10)
				Loop
			EndIf
		EndIf

	EndDo

   oFile:Close()

Return

/*
+-------------+----------+--------+---------------------------------+-------+--------------+
| Programa:   | MostrLog | Autor: | Rubens Cruz - Anadi	     	    | Data: | Novembro/2018|
+-------------+----------+--------+---------------------------------+-------+--------------+
| Descri��o:  | Exibe tela informando erros apresentados no processo		   			   |
+-------------+----------------------------------------------------------------------------+
| Uso:        | Canex					                                                   |
+-------------+----------------------------------------------------------------------------+
| Parametros: | _cMsg := Mensagem que ser� exibida na tela								   |
+-------------+----------------------------------------------------------------------------+
*/

Static Function MostrLog(_cMsg)
Local cMask	:= "Erro_CCFGA001_" + DTOS(Date()) + "_" + StrTran(Time(),":","") + ".txt"
Local cFile	:= ""
Local _lRet	:= .F.
Local oDlgErr

Define MsDialog oDlgErr Title "Erros no processo" From 3, 0 to 340, 500 Pixel
@ 5, 5 Get oMemo Var _cMsg Memo Size 240, 145 Of oDlgErr Pixel
oMemo:bRClicked := { || AllwaysTrue() }

Define SButton From 153, 175 Type  1 Action oDlgErr:End() Enable Of oDlgErr Pixel // Apaga
Define SButton From 153, 145 Type 13 Action (_lRet := .T.,oDlgErr:End()) Enable Of oDlgErr Pixel

Activate MsDialog oDlgErr Center

If _lRet
	cFile := cGetFile (Nil,"Escolha o destino",0, "C:\", .T., GETF_LOCALHARD + GETF_RETDIRECTORY) //cGetFile( , "Selecione o Diret�rio do arquivo de Log",,,.T. )
	If (!Empty(cFile))
		MemoWrite( cFile + cMask, _cMsg )
		MsgInfo("Arquivo log gerado: " + cFile + cMask)
	EndIf
EndIf

Return

/*
+------------+------------+-------+------------------------------------------+------+---------------+
| Programa   | ValCols	  | Autor | Rubens Cruz - Anadi Consultoria 		 | Data | Novembro/2018	|
+------------+------------+-------+------------------------------------------+------+---------------+
| Descricao  | Fun��o para verificar o tipo das colunas para grava��o					    		|
+------------+--------------------------------------------------------------------------------------+
| Uso        | Luft												                          		    |
+------------+--------------------------------------------------------------------------------------+
*/

Static Function ValCols(_aColunas)
	Local _aCabec	:= {}
	Local nX

	DbSelectArea("SX3")
	DbSetOrder(2)
	
	For nX := 1 To Len(_aColunas)
		//Remover poss�veis espa�os no Excel
		_aColunas[nX] := Alltrim(_aColunas[nX])
		
		If DbSeek( _aColunas[nX] )
			If !SX3->X3_CONTEXT == "V"
				AADD(_aCabec,{_aColunas[nX],;
							  SX3->X3_TIPO,;
							  SX3->X3_TAMANHO})
			Else
				_cErro += "Campo " + _aColunas[nX] + " � virtual e, portanto, n�o ser� considerada " + CEOL
			EndIf
		Else
			_cErro += "Coluna " + _aColunas[nX] + " n�o encontrada na SX3 " + CEOL
		EndIf
	Next nX
	
Return _aCabec

/*
+------------+------------+-------+------------------------------------------+------+---------------+
| Programa   | ValOk	  | Autor | Rubens Cruz - Anadi Consultoria 		 | Data | Novembro/2018	|
+------------+------------+-------+------------------------------------------+------+---------------+
| Descricao  | Fun��o para validar se as informa��es digitadas est�o OK					    		|
+------------+--------------------------------------------------------------------------------------+
| Uso        | Canex												                          		    |
+------------+--------------------------------------------------------------------------------------+
*/

Static Function Valok()
	Local _lRet	:= .T.

	Do Case
		Case Empty(_cTab)
			Alert("Tabela n�o preenchida")
			_lRet := .F.
		Case Empty(_nTipo)
			Alert("Tipo de importa��o n�o preenchido")
			_lRet := .F.
		Case Empty(_cArq)
			Alert("Arquivo CSV n�o foi informado")
			_lRet := .F.
	EndCase

	If _lRet
		oDlg:End()
	EndIf

Return 



