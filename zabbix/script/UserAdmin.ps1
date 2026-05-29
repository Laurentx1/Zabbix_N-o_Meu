# Importa o módulo Active Directory
Import-Module ActiveDirectory

# Define os grupos e arquivos de saída
$Grupos = @{
    "Admins. do domínio" = "C:\Zabbix\domainadmin_users.json"
    "Administradores"           = "C:\Zabbix\administrators_users.json"
    "Administradores de empresa" = "C:\Zabbix\enterpriseadmins_users.json"
}

# Função para obter usuários e exportar para JSON
function Export-UsersToJson {
    param (
        [string]$Grupo,
        [string]$Saida
    )

    try {
        # Obtém os membros do grupo
        $Usuarios = Get-ADGroupMember -Identity $Grupo -ErrorAction Stop | ForEach-Object {
            # Verifica se o membro é um usuário (exclui grupos ou outros objetos)
            if ($_.objectClass -eq "user") {
                $User = Get-ADUser -Identity $_.SamAccountName -Properties WhenCreated -ErrorAction Stop
                [PSCustomObject]@{
                    "username" = $User.SamAccountName
                    "created"  = $User.WhenCreated.ToString("yyyy-MM-dd HH:mm:ss")
                }
            }
        }

        # Se não houver usuários, cria um array vazio
        if (-not $Usuarios) {
            $Usuarios = @()
        }

        # Converte para JSON
        $JSON = $Usuarios | ConvertTo-Json

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
    Export-UsersToJson -Grupo $Grupo -Saida $Saida
}