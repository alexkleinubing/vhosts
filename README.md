# vhosts
Automatiza a criação de Virtual Hosts pelo terminal. Seja dentro da conexão SSH do Vagrant ou local.

## Instalação

O script precisar estar em `/usr/bin/` com permissão de execução e sem a extensão.

Exemplo:
```
/usr/bin/vhost
```

## Comandos Úteis

Permissão de execução
```
sudo chmod +x vhost.sh
```

Mover para o diretório correto
```
sudo mv /caminho/do/vhost.sh /usr/bin/vhost
```

## Finalizando

Basta digitar no terminal
```
vhost
```

Ou, adicionar os argumentos
```
vhost create|delete meuprojeto.dev /var/www/meuprojeto
```

##ToDo

- Função delete
- Aceitar opções
    - Para criar diretório do projeto automaticamente, caso seja um create
    - Para apagar diretório do projeto, caso seja um delete
    - Para não modificar o arquivo hosts
- Um maneira de apenas editar o arquivo hosts, já que podemos usar uma VM para o virtualhost
