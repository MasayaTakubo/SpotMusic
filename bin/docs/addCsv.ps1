# PowerShell�̏o�̓G���R�[�f�B���O��SJIS�ɐݒ�
$OutputEncoding = [System.Text.Encoding]::GetEncoding("shift_jis")

# �t�@�C���̍쐬�Ɏg�p����֐�
function Create-File {
    param (
        [string]$Type,
        [string]$ClassName
    )

    # �e��ʂɑΉ�����p�X���`
    $paths = @{
        "command" = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\command"
        "dao"     = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\dao"
        "filter"  = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\filter"
        "bean"    = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\bean"
        "servlet" = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\servlet"
        "jsp"     = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\webapp\WEB-INF\jsp"
    }

    # �w�肳�ꂽ��ʂ��L�����m�F
    if ($paths.ContainsKey($Type)) {
        $targetPath = $paths[$Type]
        $filePath = Join-Path -Path $targetPath -ChildPath "$ClassName"

        # �f�B���N�g�������݂��Ȃ��ꍇ�͍쐬
        if (-not (Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force
        }

        # �t�@�C�����쐬
        New-Item -ItemType File -Path $filePath -Force | Out-Null
        Write-Host "�t�@�C���쐬: $filePath"
    } else {
        # �s���Ȏ�ʂ̏ꍇ
        Write-Host ("��� {0} �͖���`�ł��B" -f $Type)
        $global:unmappedTypes[$Type] = $ClassName
    }
}

# ���Ή��̎�ʂ��i�[����n�b�V���e�[�u��
$global:unmappedTypes = @{}


# CSV �t�@�C���p�X�̎w��i�C���F�t�@�C���p�X�𖾊m�Ɏw��j
$csvFilePath = "C:\Users\koyama\Desktop\Book1.csv"

# CSV�t�@�C�������݂��邩�m�F
if (Test-Path $csvFilePath) {
    Write-Host "CSV�t�@�C����������܂���: $csvFilePath"

    # StreamReader���g����Shift_JIS��CSV�t�@�C����ǂݍ���
    $reader = [System.IO.StreamReader]::new($csvFilePath, [System.Text.Encoding]::GetEncoding("shift_jis"))
    $csvContent = $reader.ReadToEnd()
    $reader.Close()

    # CSV�R���e���c����������
    $csvData = $csvContent | ConvertFrom-Csv -Delimiter ","

    # �f�o�b�O: CSV�̗񖼂��m�F
    Write-Host "CSV�񖼈ꗗ: " -ForegroundColor Green
    $csvData[0] | Get-Member -MemberType NoteProperty | ForEach-Object { $_.Name }

    # CSV�f�[�^�̏���
    foreach ($row in $csvData) {
        # �f�o�b�O: �e�s�̓��e���m�F
        Write-Host "�������̍s: $($row | ConvertTo-Csv -NoTypeInformation)" -ForegroundColor Cyan

        $className = $row."�N���X��" # �񖼂���v���Ă��邩�m�F
        $type = $row."���"

        if (-not [string]::IsNullOrWhiteSpace($className) -and -not [string]::IsNullOrWhiteSpace($type)) {
            Create-File -Type $type -ClassName $className
        } else {
            # �󔒍s�̃X�L�b�v�����O�o��
            Write-Host ("�s�X�L�b�v: �N���X���܂��͎�ʂ��󔒂ł� (�N���X��: '{0}', ���: '{1}')" -f $className, $type) -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "CSV�t�@�C����������܂���: $csvFilePath" -ForegroundColor Red
}

# ���Ή��̎�ʂ��o��
if ($unmappedTypes.Count -gt 0) {
    Write-Host "���Ή��̎�ʈꗗ:" -ForegroundColor Red
    foreach ($key in $unmappedTypes.Keys) {
        Write-Host ("  {0}: {1}" -f $key, $unmappedTypes[$key])
    }
} else {
    Write-Host "���ׂĂ̎�ʂ�����ɏ�������܂����B" -ForegroundColor Green
}
