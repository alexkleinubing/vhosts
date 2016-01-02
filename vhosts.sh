#!/bin/bash
# Set default parameters
# addvhost create|delete domain.dev /var/www/domain
action=$1
domain=$2
rootdir=$3
defaultDir='/var/www/'
sitesEnabled='/etc/apache2/sites-enabled/'
sitesAvailable='/etc/apache2/sites-available/'
hostsFileEdit=true
hostsFile='/etc/hosts'
hostsFileIP='192.168.100.101'

shopt -s nocasematch # habilita comparacão case insensitive para [[ condicão ]]

owner=$(who am i | awk '{print $1}')
ESC="\033"
AZUL=36
AMARELO=33
VERMELHO=31
VERDE=32
CORPADRAO=0

function mensagem() {
	case $2 in
		info)
			COR=$AZUL ;;
		alerta)
			COR=$AMARELO ;;
		perigo)
			COR=$VERMELHO ;;
		sucesso)
			COR=$VERDE ;;
		*)
			COR=$CORPADRAO ;;
	esac
	echo -e "${ESC}[${COR}m${1}${ESC}[${CORPADRAO}m"
}

function colorize() {
	if [ -z $2 ]; then
		COR=$CORPADRAO
	elif [ -z ${$2} ]; then
		COR=${$2}
	fi
	return -e "${ESC}[${COR}m${1}${ESC}[${CORPADRAO}m"
}

# Aborta a execução se não tiver privilégios de root
function check_permission(){
	if [ "$(whoami)" != 'root' ]; then
		mensagem "Você não tem permissão para executar $0 como um usuário não-root. Use sudo." 'alerta'
		exit 1;
	fi
}

# Solicita uma ação para executar
function get_action() {
	while [[ $action != create && $action != delete ]]; do
		echo "Você deseja criar ou apagar um virtual host? (create/delete): "
		read choiceAction
		case $choiceAction in
			create) 
				action=create ;;
			delete) 
				action=delete ;;
			*) 
				action=''
				mensagem 'Opção inválida.' 'alerta'
				;;
		esac
		choiceAction=''
	done
}

# Solicita o dominio para o vhost
function get_domain() {
	while [ -z $domain ]; do
		echo "[${action}] Informe o domínio (ex. meuprojeto.dev): "
		read choiceAction
		if [ -z $choiceAction ]; then
			mensagem 'Domínio inválido.' 'alerta'
		else
			domain=$choiceAction
		fi
			choiceAction=''
	done
}

# Solicita o diretório para onde o vhost irá apontar
function get_rootdir() {
	while [ -z $rootdir ]; do
		echo "[${action} ${domain}] Informe o diretório root do projeto (${defaultDir}${domain}): "
		read choiceAction
		if [ -z $choiceAction ]; then
			rootdir="${defaultDir}${domain}"
		else
			rootdir=$choiceAction
		fi
			choiceAction=''
	done
	if ! [ -d "$rootdir" ]; then
		mensagem "O diretório $rootdir ainda não existe" 'alerta'
		echo "Deseja que o diretório $rootdir seja criado? (S/n)"
		read choiceAction
		if [ "$choiceAction"='S' -o "$choiceAction"='s' -o -z "$choiceAction" ]; then
			mkdir $rootdir
			if ! [ -d "$rootdir" ]; then
				mensagem "Não foi possível criar o diretório, por favor, crie manualmente" 'alerta'
			else
				mensagem "Diretório $rootdir criado automaticamente" 'info'
			fi
		else
			mensagem "Criação do diretório ignorada" 'info'
		fi
	fi
	mensagem "Diretório Root: ${rootdir}" 'info'
}

function adicionar() {
	while [ -e "$sitesAvailable$domain.conf" ]; do
		mensagem "O domínio $domain já existe, escolha outro" 'alerta'
		domain=''
		get_domain
	done
	get_rootdir
	echo "
	<VirtualHost *:80>
		ServerName $domain
		ServerAlias www.$domain
	
		DocumentRoot "$rootdir"
	
		<Directory "$rootdir">
			Options Indexes FollowSymLinks MultiViews
			AllowOverride All
			Order allow,deny
			Allow from all
		</Directory>
	</VirtualHost>
	" > $sitesAvailable$domain.conf
	mensagem "Adicionado: $sitesAvailable${domain}.conf" 'info'
	ln -s $sitesAvailable$domain.conf $sitesEnabled
	mensagem "Adicionado: $sitesEnabled${domain}.conf" 'info'

	if [ $hostsFileEdit=true ]; then
		echo -e "$hostsFileIP $domain www.$domain" >> $hostsFile
		mensagem "Adicionado: $hostsFileIP $domain -> $hostsFile" 'info'
	fi
	
	service apache2 restart
	mensagem "[OK] Pronto para usar: $domain" 'sucesso'
}

function apagar() {
	mensagem "FUNÇÃO DE DELETAR, DESATIVADA POR ENQUANTO =/" 'perigo'

	# while ! [ -e "$sitesAvailable$domain.conf" ]; do
	# 	for line in $(ls $sitesAvailable*.conf); do
	# 		echo $(awk -F/ '{print $(NF)}' $line)
	# 	done
	# 	mensagem "O domínio $domain não existe, escolha outro" 'alerta'
	# 	domain=''
	# 	exit 1
	# 	get_domain
	# done
}

###############################
#          PRINCIPAL          #
###############################
get_action
get_domain
case $action in
	create)	adicionar ;;
	delete)	apagar ;;
	*) mensagem 'Erro critico. A operação foi cancelada.' 'perigo'
esac
