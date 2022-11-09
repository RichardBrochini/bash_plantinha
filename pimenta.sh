#!/usr/bin/env bash

#colocar url da API_PLANTINHA em environment
#colocar a cada 30 min no cron para rodar 
#*/30 * * * *

painel=$PAINEL_PIMENTA
hora_atual=$(date +"%k")

#converte hora pra inteiro
$hora_atual+0;

#pega valor da luz atual da plantinha
url="$API_PLANTINHA""diario.bash.umidade/"$painel
UMIDADE=$(curl ${url})

#pega valor da luz atual da plantinha
url="$API_PLANTINHA""diario.bash.temperatura/"$painel
TEMPERATURA=$(curl ${url})

#pega valor da luz atual da plantinha
url="$API_PLANTINHA""diario.bash.luz/"$painel
LUZ=$(curl ${url})

#pega valor da luz atual da plantinha
url="$API_PLANTINHA""diario.bash.agua/"$painel
AGUA=$(curl ${url})



if [ $hora_atual -eq 6 ]
then
	#verifica de ja existe iluminacao forte
	if [ $LUZ -lt 800 ]
	then
		#verifica qual a ultima hora que foi dado o comando
		url="$API_PLANTINHA""hora.bash.acender/"$painel
		ULTIMA_HORA=${url}
		echo $ULTIMA_HORA

		url="$API_PLANTINHA""bash_acender/"$painel
		curl ${url}
	fi
fi

#20 horas diaria de sol 
if [ $hora_atual -eq 3 ]
then
        #verifica de ja existe iluminacao forte
        if [ $LUZ -gt 800 ]
        then
                #verifica qual a ultima hora que foi dado o comando
                url="$API_PLANTINHA""hora.bash.apagar/"$painel
                ULTIMA_HORA=${url}
                echo $ULTIMA_HORA

                url="$API_PLANTINHA""bash_apagar/"$painel
                curl ${url}
        fi
fi

#garante que seja regada somente de dia
if [[ $hora_atual -gt 6 && $hora_atual -lt 19 ]] 
then
	#verifica pela a manhã como esta a agua e molha
	if [ $hora_atual -eq 8 ]
	then
		if [ $AGUA -lt 800 ]
        	then	
			#primeira agua da manha	
			url="$API_PLANTINHA""bash_molhar/"$painel
                	curl ${url}
		fi
	fi
fi

#manter ambiete humido, senão molha a cada 30 min durante o dia
#ruculas gosta de ambiente umidos e ricos em PH
if [[ $hora_atual -gt 6 && $hora_atual -lt 19 ]]
then
	if [[ $UMIDADE -lt 70 && $TEMPERATURA -gt 30 ]]
	then
        	url="$API_PLANTINHA""bash_molhar/"$painel
                curl ${url}
	fi
fi
echo "Dados Coletados do painel" $painel
echo $LUZ"-"
echo $UMIDADE"-"
echo $TEMPERATURA"-"
echo $AGUA"-"
