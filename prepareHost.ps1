param(
    [Parameter(Mandatory=$true)]
    [string]$addr,
    
    [string]$name = "orangepi",
    
    [string]$host = "opi5"
)

# Получаем имя текущего пользователя
$currentUser = $env:USERNAME
$sshPath = "$env:USERPROFILE\.ssh"
$publicKeyPath = "$sshPath\smartgates\id_rsa.pub"
$configPath = "$sshPath\config"

# Проверяем существование публичного ключа
if (-not (Test-Path $publicKeyPath)) {
    Write-Error "Публичный ключ не найден: $publicKeyPath"
    exit 1
}

# Читаем публичный ключ
$publicKey = Get-Content $publicKeyPath -Raw
$publicKeyTrimmed = $publicKey.Trim()

# Формируем команду для удаленного выполнения с проверкой наличия ключа
# Сначала проверяем, существует ли уже ключ в authorized_keys
$remoteCommand = @"
if [ -f ~/.ssh/authorized_keys ]; then
    if grep -Fq '$publicKeyTrimmed' ~/.ssh/authorized_keys; then
        echo "Ключ уже существует в authorized_keys"
        exit 0
    fi
fi
[ -d ~/.ssh ] || (mkdir ~/.ssh; chmod 700 ~/.ssh)
cat >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "Ключ успешно добавлен"
"@

# Выполняем копирование ключа
try {
    Write-Host "Проверка и копирование SSH ключа на $name@$addr..." -ForegroundColor Yellow
    
    # Используем pipe для передачи ключа через ssh
    $result = $publicKey | ssh "${name}@${addr}" $remoteCommand
    
    if ($LASTEXITCODE -eq 0) {
        if ($result -match "Ключ уже существует") {
            Write-Host "SSH ключ уже существует на удаленном сервере" -ForegroundColor Green
        } elseif ($result -match "Ключ успешно добавлен") {
            Write-Host "SSH ключ успешно скопирован" -ForegroundColor Green
        } else {
            Write-Host "SSH ключ успешно скопирован" -ForegroundColor Green
        }
    } else {
        Write-Error "Ошибка при копировании SSH ключа"
        exit 1
    }
} catch {
    Write-Error "Ошибка при выполнении SSH команды: $_"
    exit 1
}

# Обновляем конфиг файл SSH
if (Test-Path $configPath) {
    Write-Host "Обновление конфигурации SSH для хоста $host..." -ForegroundColor Yellow
    
    # Читаем текущий конфиг
    $configContent = Get-Content $configPath
    
    # Ищем секцию Host $host
    $hostFound = $false
    $newConfig = @()
    $i = 0
    
    while ($i -lt $configContent.Length) {
        $line = $configContent[$i]
        
        # Если нашли секцию хоста
        if ($line -match "^Host\s+$host$") {
            $hostFound = $true
            $newConfig += $line
            $i++
            
            # Пропускаем существующие параметры User и HostName в этой секции
            while ($i -lt $configContent.Length -and $configContent[$i] -match "^\s+") {
                $currentLine = $configContent[$i]
                if ($currentLine -match "^\s+User\s+") {
                    # Пропускаем старую строку User
                    $i++
                    continue
                }
                if ($currentLine -match "^\s+HostName\s+") {
                    # Пропускаем старую строку HostName
                    $i++
                    continue
                }
                $newConfig += $currentLine
                $i++
            }
            
            # Добавляем новые параметры
            $newConfig += "    User $name"
            $newConfig += "    HostName $addr"
        } else {
            $newConfig += $line
            $i++
        }
    }
    
    # Если секция не найдена, добавляем новую
    if (-not $hostFound) {
        $newConfig += ""
        $newConfig += "Host $host"
        $newConfig += "    User $name"
        $newConfig += "    HostName $addr"
    }
    
    # Сохраняем обновленный конфиг
    $newConfig | Set-Content $configPath
    Write-Host "Конфигурация SSH успешно обновлена" -ForegroundColor Green
    
} else {
    # Если конфиг файл не существует, создаем новый
    Write-Host "Создание нового конфигурационного файла SSH..." -ForegroundColor Yellow
    $configContent = @"
Host $host
    User $name
    HostName $addr
"@
    $configContent | Set-Content $configPath
    Write-Host "Конфигурационный файл SSH создан" -ForegroundColor Green
}

Write-Host "Операция завершена успешно!" -ForegroundColor Green