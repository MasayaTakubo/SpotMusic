# PowerShellの出力エンコーディングをSJISに設定
$OutputEncoding = [System.Text.Encoding]::GetEncoding("shift_jis")

# ファイルの作成に使用する関数
function Create-File {
    param (
        [string]$Type,
        [string]$ClassName
    )

    # 各種別に対応するパスを定義
    $paths = @{
        "command" = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\command"
        "dao"     = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\dao"
        "filter"  = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\filter"
        "bean"    = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\bean"
        "servlet" = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\resources\servlet"
        "jsp"     = "C:\pleiades\2023-12\workspace\SpotMusic\src\main\webapp\WEB-INF\jsp"
    }

    # 指定された種別が有効か確認
    if ($paths.ContainsKey($Type)) {
        $targetPath = $paths[$Type]
        $filePath = Join-Path -Path $targetPath -ChildPath "$ClassName"

        # ディレクトリが存在しない場合は作成
        if (-not (Test-Path $targetPath)) {
            New-Item -ItemType Directory -Path $targetPath -Force
        }

        # ファイルを作成
        New-Item -ItemType File -Path $filePath -Force | Out-Null
        Write-Host "ファイル作成: $filePath"
    } else {
        # 不明な種別の場合
        Write-Host ("種別 {0} は未定義です。" -f $Type)
        $global:unmappedTypes[$Type] = $ClassName
    }
}

# 未対応の種別を格納するハッシュテーブル
$global:unmappedTypes = @{}


# CSV ファイルパスの指定（修正：ファイルパスを明確に指定）
$csvFilePath = "C:\Users\koyama\Desktop\Book1.csv"

# CSVファイルが存在するか確認
if (Test-Path $csvFilePath) {
    Write-Host "CSVファイルが見つかりました: $csvFilePath"

    # StreamReaderを使ってShift_JISでCSVファイルを読み込む
    $reader = [System.IO.StreamReader]::new($csvFilePath, [System.Text.Encoding]::GetEncoding("shift_jis"))
    $csvContent = $reader.ReadToEnd()
    $reader.Close()

    # CSVコンテンツを処理する
    $csvData = $csvContent | ConvertFrom-Csv -Delimiter ","

    # デバッグ: CSVの列名を確認
    Write-Host "CSV列名一覧: " -ForegroundColor Green
    $csvData[0] | Get-Member -MemberType NoteProperty | ForEach-Object { $_.Name }

    # CSVデータの処理
    foreach ($row in $csvData) {
        # デバッグ: 各行の内容を確認
        Write-Host "処理中の行: $($row | ConvertTo-Csv -NoTypeInformation)" -ForegroundColor Cyan

        $className = $row."クラス名" # 列名が一致しているか確認
        $type = $row."種別"

        if (-not [string]::IsNullOrWhiteSpace($className) -and -not [string]::IsNullOrWhiteSpace($type)) {
            Create-File -Type $type -ClassName $className
        } else {
            # 空白行のスキップをログ出力
            Write-Host ("行スキップ: クラス名または種別が空白です (クラス名: '{0}', 種別: '{1}')" -f $className, $type) -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "CSVファイルが見つかりません: $csvFilePath" -ForegroundColor Red
}

# 未対応の種別を出力
if ($unmappedTypes.Count -gt 0) {
    Write-Host "未対応の種別一覧:" -ForegroundColor Red
    foreach ($key in $unmappedTypes.Keys) {
        Write-Host ("  {0}: {1}" -f $key, $unmappedTypes[$key])
    }
} else {
    Write-Host "すべての種別が正常に処理されました。" -ForegroundColor Green
}
