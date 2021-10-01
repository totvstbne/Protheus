#include "protheus.ch"
#include "dbtree.ch"
#include "ap5mail.ch"
#INCLUDE "TBICONN.CH"
#include 'TopConn.CH'

// PE que permite alterar verba na rotina de integração dos resultados do ponto para folha de pagamento
// Autor: Rodrigo Lucas  Data: 08/10/2020
// Empresa: Mconsult
// Usuário solicitante: Fabiana Felix
// Justificativa: No processo da Servnac existem sindicatos que possuem aliquotas diferentes para adicional noturno. 
//                Para atender a regra, foi criado campo (RCE_YVADCN) no cadastro do sindicato para informar a verba referente adicional noturno,
//                quando for diferente do padrão de 20%. O PE verifica a existencia do preenchimento para mudar a verba que o ponto lança como padrão. 


User Function PONCALATOT ()

	Local cFilFunc    := PARAMIXB[1]
	Local cMatFunc    := PARAMIXB[2]
	Local aTotEve     := PARAMIXB[3]
//Local dPerIni    := PARAMIXB[4]
//Local dPerFim     := PARAMIXB[5]
//Local aCalend     := PARAMIXB[6]

/*
O ponto de entrada recebe os parâmetros abaixo:
PARAMIXB[1] -> Filial do funcionário
PARAMIXB[2] -> Matrícula do Funcionário
PARAMIXB[3] -> Eventos gerados para a folha
PARAMIXB[4] -> Data inicial do período de apontamento
PARAMIXB[5] -> Data final do período de apontamento
PARAMIXB[6] -> Calendário de marcações
Deve-se retornar um array de 16 posições, conforme estrutura abaixo:
aTotEve[1][01] -> Data do evento
aTotEve[1][02] -> Código do evento do Ponto
aTotEve[1][03] -> Horas do evento
aTotEve[1][04] -> Código da verba da Folha
aTotEve[1][05] -> Código do centro de custo
aTotEve[1][06] -> Valor do evento
aTotEve[1][07] -> Data do evento (formato AAAAMMDD)
aTotEve[1][08] -> Função do funcionário
aTotEve[1][09] -> Departamento do funcionário
aTotEve[1][10] -> Posto do funcionário
aTotEve[1][11] -> Processo do funcionário
aTotEve[1][12] -> Código do roteiro
aTotEve[1][13] -> Código do período
aTotEve[1][14] -> Código da semana de pagamento
aTotEve[1][15] -> Código do tipo de hora extra
aTotEve[1][16] -> Percentual de valorização da hora extra
*/

	If Len(atoteve)>0
		_ncont := 1

		While _ncont <= Len(atoteve)

			If atoteve[_ncont,02] == "139" // condição para evento de adicional noturno
		/*
				if select("SRA") >0
				SRA->(DBCLOSEAREA())
				ENDIF
			DBSELECTAREA("SRA")
			SRA->(DBSETORDER(1))
		*/
				cquery := "SELECT * FROM "+RETSQLNAME("SRA")+" WHERE D_E_L_E_T_ = ' ' AND RA_FILIAL = '"+cFilFunc+"' AND RA_MAT = '"+cMatFunc+"' "

				TcQuery cQuery New Alias T01
				DbSelectArea("T01")

				IF !T01->(Eof())

					_CSINDICA := T01->RA_SINDICA
					_CVERBADC :=  posicione("RCE",1,XFILIAL("RCE",cFilFunc)+_CSINDICA,"RCE_YVADCN")

					If !empty(_CVERBADC) // caso o cadastro do sindicato possua verba especifica para adicional noturno
						atoteve[_ncont,04] := _CVERBADC // altera no array a verba para integração
					Endif
				
				ENDIF
				T01->(DBCLOSEAREA())
			endif
			_ncont++
		Enddo

	endif



/*
No exemplo acima, para os funcionários da filial 01, é feita a inclusão de um
evento na data final do período de apontamento com a quantidade de 10 horas.
*/

Return aTotEve
