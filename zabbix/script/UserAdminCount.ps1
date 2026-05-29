# Importa o módulo Active Directory
Import-Module ActiveDirectory

# Define os grupos
$Grupos = @{
    "Admins. do domínio" = "C:\Zabbix\domainadmin_users_count.json"
    "Administradores"           = "C:\Zabbix\administrators_users_count.json"
    "Administradores de empresa" = "C:\Zabbix\enterpriseadmins_users_count.json"
}

# Função para contar usuários e exportar para JSON
function Export-UserCountToJson {
    param (
        [string]$Grupo,
        [string]$Saida
    )

    try {
        # Obtém os membros do grupo
        $Usuarios = Get-ADGroupMember -Identity $Grupo -ErrorAction Stop

        # Conta o número de usuários (filtra apenas usuários, excluindo grupos ou outros objetos)
        $Contagem = ($Usuarios | Where-Object { $_.objectClass -eq "user" }).Count

        # Estrutura JSON no formato especificado
        $ContagemJSON = @{
            "data" = @(
                @{
                    "{#USERCOUNT}" = $Contagem
                }
            )
        }

        # Converte para JSON
        $JSON = $ContagemJSON | ConvertTo-Json -Depth 3

        # Salva no arquivo
        Set-Content -Path $Saida -Value $JSON

        # Exibe o JSON para conferência
        Write-Output "Grupo: $Grupo"
        Write-Output $JSON
    }
    catch {
        Write-Error "Erro ao processar o grupo '$Grupo': $($_.Exception.Message)"
    }
}

# Processa cada grupo
foreach ($Grupo in $Grupos.Keys) {
    $Saida = $Grupos[$Grupo]
    Export-UserCountToJson -Grupo $Grupo -Saida $Saida
}