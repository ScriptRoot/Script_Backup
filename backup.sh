#!/usr/bin/env bash

#####################################################################################################
#   Este script foi desenvolvido para facilitar a rotina de backup de meu sistema linux,            #
#   podendo ser facilmente adaptado conforme suas necessidades.                                     #
#                                                                                                   #
#       Autor: Leandro Vezu                                                                         #
#           Vesão: Beta                                                                             #
#####################################################################################################

# Verificando se é Root
if [ "$UID" -ne 0 ]; then
    echo "Voce precisa ser root para executar o backup!"
    exit 1
fi

# Diretório onde será montado o dispositivo
diretorio_de_montagem="/mnt/backup"

# Diretórios a serem copiados
diretorios_para_backup=("/home" "/var/log" "/etc")

# Diretório do arquivo de log
log_arquivo="/var/log/backup.log"


# Verificando para não dar conflito
if [ -d "$diretorio_de_montagem" ]; then
    echo "O diretório $diretorio_de_montagem já existe."
else
    echo "Criando diretório $diretorio_de_montagem..."
    sudo mkdir -p "$diretorio_de_montagem"
    sleep 2
fi

# Montando o dispositivo
echo "Montando dispositivo..."
sudo mount /dev/sda2 "$diretorio_de_montagem"

if [ $? -eq 0 ]; then
    echo "Dispositivo montado com sucesso."
else
    echo "$(date) - Falha ao montar o dispositivo.\n" >> "$log_arquivo"
    exit 1
fi

# Copiando os diretórios para o dispositivo
echo "Iniciando backup..."
for diretorio in "${diretorios_para_backup[@]}"; do
    if [ -d "$diretorio" ]; then
        # Usando rsync para copiar os diretórios de forma mais eficiente
        sudo rsync -a --info=progress2 "$diretorio" "$diretorio_de_montagem/"
        
        # Verificando o sucesso do comando rsync
        if [ $? -eq 0 ]; then
            echo "Backup do diretório $diretorio concluído."
            echo "$(date) - Backup do diretório $diretorio concluído.\n" >> "$log_arquivo"
            
            # Limpando os diretórios originais
            sudo rm -rf "$diretorio"
            echo "Limpeza do diretório $diretorio concluída."
            echo "$(date) - Limpeza do diretório $diretorio concluída.\n" >> "$log_arquivo"
        else
            echo "Erro ao realizar o backup do diretório $diretorio."
            echo "$(date) - Erro ao realizar o backup do diretório $diretorio.\n" >> "$log_arquivo"
        fi
    else
        echo "Diretório $diretorio não encontrado."
        echo "$(date) - Diretório $diretorio não encontrado.\n" >> "$log_arquivo"
    fi
    echo "" >> "$log_arquivo"
done

# Desmontando o dispositivo
echo "Desmontando dispositivo..."
sudo umount "$diretorio_de_montagem"

if [ $? -eq 0 ]; then
    echo "Dispositivo desmontado com sucesso."
else
    echo "Falha ao desmontar o dispositivo.\n" >> "$log_arquivo"
    exit 1
fi

echo "$(date) - Backup completo concluído.\n" >> "$log_arquivo"
echo "" >> "$log_arquivo"

echo "Backup concluído com sucesso.\n"
