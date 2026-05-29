# Importa o módulo Active Directory
Import-Module ActiveDirectory

# Define o arquivo de saída
$Saida = "C:\Zabbix\all_users_lastlogon.json"

# Função para obter todos os usuários e exportar para JSON
function Export-AllUsersToJson {
    param (
        [string]$Saida
    )

    try {
        # Obtém todos os usuários do domínio
        $Usuarios = Get-ADUser -Filter * -Properties SamAccountName, LastLogon -ErrorAction Stop | ForEach-Object {
            [PSCustomObject]@{
                "username"  = $_.SamAccountName
                "lastLogon" = if ($_.LastLogon) { ([datetime]::FromFileTime($_.LastLogon)).ToString("yyyy-MM-dd HH:mm:ss") } else { "1970-01-01" }
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
        Write-Output "Todos os usuários do domínio"
        Write-Output $JSON
    }
    catch {
        Write-Error "Erro ao processar os usuários: $($_.Exception.Message)"
    }
}

# Executa a função
Export-AllUsersToJson -Saida $Saida