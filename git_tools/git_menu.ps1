# ==============================================================================
# Script Quản Lý GitHub Tự Động (DOAN2)
# Hỗ trợ: Đẩy code, khôi phục từ GitHub, kéo code, xem lịch sử, kiểm tra trạng thái
# ==============================================================================

[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Định vị thư mục gốc của dự án (thư mục cha của git_tools)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RepoRoot = Split-Path -Parent $ScriptDir
Set-Location $RepoRoot

function Show-Header {
    Clear-Host
    $CurrentBranch = (git branch --show-current 2>$null)
    if ($CurrentBranch) { $CurrentBranch = $CurrentBranch.Trim() } else { $CurrentBranch = "main" }
    
    $RemoteUrl = (git remote get-url origin 2>$null)
    if (-not $RemoteUrl) { $RemoteUrl = "Chua cau hinh remote" }

    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host "                TOOL QUẢN LÝ GITHUB TỰ ĐỘNG                     " -ForegroundColor Yellow
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host " [Thư mục dự án] : $RepoRoot" -ForegroundColor DarkGray
    Write-Host " [Nhánh hiện tại]: " -NoNewline -ForegroundColor White
    Write-Host "$CurrentBranch" -ForegroundColor Green
    Write-Host " [Remote URL]   : $RemoteUrl" -ForegroundColor DarkGray
    Write-Host "==================================================================" -ForegroundColor Cyan
    Write-Host ""
}

function Pause-Menu {
    Write-Host ""
    if ([System.Console]::IsInputRedirected) {
        return
    }
    Write-Host "Nhấn phím bất kỳ để quay lại Menu chính..." -ForegroundColor DarkYellow
    $null = [System.Console]::ReadKey($true)
}

function Push-To-GitHub {
    Show-Header
    Write-Host ">>> [CHỨC NĂNG 1]: ĐẨY TOÀN BỘ CODE LÊN GITHUB" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    
    $CurrentBranch = (git branch --show-current 2>$null)
    if ($CurrentBranch) { $CurrentBranch = $CurrentBranch.Trim() } else { $CurrentBranch = "main" }

    Write-Host "Kiểm tra các file thay đổi..." -ForegroundColor Cyan
    $status = git status -s
    if (-not $status) {
        Write-Host ">> Không có thay đổi nào cần đẩy lên! (Thư mục làm việc đang sạch)" -ForegroundColor Green
        Pause-Menu
        return
    }

    Write-Host "Các file đã thay đổi / tạo mới:" -ForegroundColor White
    git status -s
    Write-Host ""

    $DefaultMsg = "Update: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss")
    $msg = Read-Host "Nhập nội dung commit (Nhấn Enter để dùng mặc định: '$DefaultMsg')"
    if ([string]::IsNullOrWhiteSpace($msg)) {
        $msg = $DefaultMsg
    }

    Write-Host ""
    Write-Host "[1/3] Đang thêm file (git add .)..." -ForegroundColor Cyan
    git add .

    Write-Host "[2/3] Đang tạo commit..." -ForegroundColor Cyan
    git commit -m "$msg"

    Write-Host "[3/3] Đang đẩy lên GitHub (git push origin $CurrentBranch)..." -ForegroundColor Cyan
    git push origin $CurrentBranch

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host ">> THÀNH CÔNG: Đã đẩy toàn bộ code lên GitHub nhánh '$CurrentBranch'!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host ">> CÓ LỖI XẢY RA KHI PUSH! Vui lòng kiểm tra lại kết nối mạng hoặc xung đột (conflict)." -ForegroundColor Red
    }
    Pause-Menu
}

function Restore-From-GitHub {
    Show-Header
    Write-Host ">>> [CHỨC NĂNG 2]: KHÔI PHỤC DỰ ÁN VỀ GIỐNG GITHUB (RESET & RESTORE)" -ForegroundColor Red
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "CẢNH BÁO NGUY HIỂM:" -ForegroundColor Yellow
    Write-Host "- Thao tác này sẽ XÓA HẾT các thay đổi chưa commit trên máy cục bộ." -ForegroundColor Yellow
    Write-Host "- Đưa toàn bộ mã nguồn về đúng phiên bản mới nhất đang có trên GitHub." -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    
    $CurrentBranch = (git branch --show-current 2>$null)
    if ($CurrentBranch) { $CurrentBranch = $CurrentBranch.Trim() } else { $CurrentBranch = "main" }

    $confirm = Read-Host "Bạn có CHẮC CHẮN muốn khôi phục không? (Gõ 'YES' hoặc 'Y' để tiếp tục)"
    if ($confirm -ne "YES" -and $confirm -ne "yes" -and $confirm -ne "Y" -and $confirm -ne "y") {
        Write-Host "Đã hủy thao tác khôi phục!" -ForegroundColor DarkYellow
        Pause-Menu
        return
    }

    Write-Host ""
    Write-Host "[1/3] Đang tải dữ liệu mới nhất từ GitHub (git fetch origin)..." -ForegroundColor Cyan
    git fetch origin

    Write-Host "[2/3] Đang reset code về commit mới nhất (git reset --hard origin/$CurrentBranch)..." -ForegroundColor Cyan
    git reset --hard "origin/$CurrentBranch"

    Write-Host "[3/3] Đang dọn dẹp các file untracked thừa thãi (git clean -fd)..." -ForegroundColor Cyan
    git clean -fd

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host ">> THÀNH CÔNG: Đã khôi phục toàn bộ dự án về đúng phiên bản GitHub!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host ">> Lỗi trong quá trình khôi phục! Vui lòng kiểm tra lại kết nối mạng hoặc Git remote." -ForegroundColor Red
    }
    Pause-Menu
}

function Pull-From-GitHub {
    Show-Header
    Write-Host ">>> [CHỨC NĂNG 3]: KÉO CẬP NHẬT MỚI NHẤT TỪ GITHUB (PULL)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    
    $CurrentBranch = (git branch --show-current 2>$null)
    if ($CurrentBranch) { $CurrentBranch = $CurrentBranch.Trim() } else { $CurrentBranch = "main" }

    Write-Host "Đang kéo cập nhật từ nhánh '$CurrentBranch' trên GitHub..." -ForegroundColor Cyan
    git pull origin $CurrentBranch

    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host ">> Đã cập nhật xong!" -ForegroundColor Green
    } else {
        Write-Host ""
        Write-Host ">> Quá trình kéo code gặp lỗi hoặc xung đột (conflict)!" -ForegroundColor Red
    }
    Pause-Menu
}

function Show-Git-Status {
    Show-Header
    Write-Host ">>> [CHỨC NĂNG 4]: KIỂM TRA TRẠNG THÁI DỰ ÁN (GIT STATUS)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    git status
    Pause-Menu
}

function Show-Git-Log {
    Show-Header
    Write-Host ">>> [CHỨC NĂNG 5]: XEM 10 COMMIT GẦN NHẤT (GIT LOG)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    git log -n 10 --oneline --graph --decorate
    Write-Host ""
    Pause-Menu
}

function Manage-Git-Stash {
    Show-Header
    Write-Host ">>> [CHỨC NĂNG 6]: LƯU TẠM THAY ĐỔI (GIT STASH)" -ForegroundColor Yellow
    Write-Host "------------------------------------------------------------------" -ForegroundColor DarkGray
    Write-Host "1. Stash Save : Lưu tạm thay đổi hiện tại và đưa code về trạng thái sạch" -ForegroundColor White
    Write-Host "2. Stash Pop  : Lấy lại các thay đổi đã lưu tạm gần nhất" -ForegroundColor White
    Write-Host "3. Stash List : Xem danh sách các bản lưu tạm" -ForegroundColor White
    Write-Host "0. Quay lại Menu chính" -ForegroundColor DarkGray
    Write-Host ""
    
    $subChoice = Read-Host "Chọn thao tác (0-3)"
    switch ($subChoice) {
        "1" {
            $msg = Read-Host "Nhập ghi chú cho bản lưu tạm (hoặc Enter)"
            if ([string]::IsNullOrWhiteSpace($msg)) {
                git stash
            } else {
                git stash save "$msg"
            }
        }
        "2" {
            git stash pop
        }
        "3" {
            git stash list
        }
        default {
            return
        }
    }
    Pause-Menu
}

# Vòng lặp Menu chính
while ($true) {
    Show-Header
    Write-Host "Vui lòng chọn một thao tác:" -ForegroundColor White
    Write-Host ""
    Write-Host "  [1] " -NoNewline -ForegroundColor Green
    Write-Host "Đẩy toàn bộ thay đổi lên GitHub (Add + Commit + Push)" -ForegroundColor White
    Write-Host "  [2] " -NoNewline -ForegroundColor Red
    Write-Host "Khôi phục dự án về giống GitHub (Reset Hard & Discard Changes)" -ForegroundColor White
    Write-Host "  [3] " -NoNewline -ForegroundColor Cyan
    Write-Host "Kéo cập nhật mới nhất từ GitHub (Git Pull)" -ForegroundColor White
    Write-Host "  [4] " -NoNewline -ForegroundColor Yellow
    Write-Host "Kiểm tra trạng thái Git (Git Status)" -ForegroundColor White
    Write-Host "  [5] " -NoNewline -ForegroundColor Magenta
    Write-Host "Xem lịch sử commit gần nhất (Git Log)" -ForegroundColor White
    Write-Host "  [6] " -NoNewline -ForegroundColor DarkCyan
    Write-Host "Lưu tạm thay đổi (Git Stash / Pop)" -ForegroundColor White
    Write-Host "  [0] " -NoNewline -ForegroundColor DarkGray
    Write-Host "Thoát chương trình" -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "==================================================================" -ForegroundColor Cyan
    
    $choice = Read-Host "Nhập lựa chọn của bạn [0-6]"
    if ($choice -eq $null) {
        break
    }
    
    switch ($choice.Trim()) {
        "1" { Push-To-GitHub }
        "2" { Restore-From-GitHub }
        "3" { Pull-From-GitHub }
        "4" { Show-Git-Status }
        "5" { Show-Git-Log }
        "6" { Manage-Git-Stash }
        "0" {
            Write-Host "`nTạm biệt!" -ForegroundColor Green
            Start-Sleep -Seconds 1
            exit
        }
        default {
            Write-Host "Lựa chọn không hợp lệ, vui lòng thử lại!" -ForegroundColor Red
            Start-Sleep -Milliseconds 800
        }
    }
}
