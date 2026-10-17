# 🛠️ GitHub Manager Tool (DOAN2)

Thư mục công cụ tự động hóa các thao tác Git & GitHub dành cho dự án **DOAN2**.

---

## 🚀 Cách chạy công cụ

### Cách 1: Click đúp (Khuyên dùng trên Windows)
- Mở thư mục `git_tools` trong File Explorer.
- Nhấp đúp chuột vào file **`run.bat`**.

### Cách 2: Chạy từ Terminal / VS Code
Mở terminal trong VS Code (hoặc PowerShell / CMD) và gõ:
```powershell
.\git_tools\run.bat
```
hoặc chạy trực tiếp PowerShell:
```powershell
powershell -ExecutionPolicy Bypass -File .\git_tools\git_menu.ps1
```

---

## 📋 Danh sách các chức năng trong Menu

| Lựa chọn | Chức năng | Mô tả chi tiết |
|:---:|:---|:---|
| **[1]** | **🚀 Đẩy toàn bộ lên GitHub** | Chạy `git add .`, tự động hỏi commit message (hoặc dùng mặc định thời gian hiện tại) và `git push` lên nhánh hiện tại. |
| **[2]** | **🔄 Khôi phục về giống GitHub** | **CỰC KỲ HỮU ÍCH**: Hủy toàn bộ thay đổi lỗi ở máy và khôi phục code về đúng commit mới nhất trên GitHub (`git fetch`, `git reset --hard`, `git clean -fd`). |
| **[3]** | **📥 Kéo code mới nhất** | Thực hiện `git pull` để tải các commit mới nhất từ GitHub về máy. |
| **[4]** | **📊 Kiểm tra trạng thái** | Thực hiện `git status` để xem các file vừa thêm, xóa hoặc sửa đổi. |
| **[5]** | **📜 Xem lịch sử commit** | Hiển thị 10 commit gần nhất dạng đồ thị rút gọn trực quan. |
| **[6]** | **💾 Quản lý Stash (Lưu tạm)** | Hỗ trợ lưu tạm code chưa hoàn thiện (`stash`) và lấy lại sau (`stash pop`). |
| **[0]** | **❌ Thoát** | Đóng menu công cụ. |

---

## 📁 Cấu trúc thư mục `git_tools`
- [run.bat](file:///d:/VSCode/DOAN2/git_tools/run.bat): Trình khởi chạy một chạm (tự động mở giao diện đẹp).
- [git_menu.ps1](file:///d:/VSCode/DOAN2/git_tools/git_menu.ps1): Bản PowerShell giao diện màu sắc, đầy đủ cảnh báo xác nhận.
- [git_menu.bat](file:///d:/VSCode/DOAN2/git_tools/git_menu.bat): Bản Batch/CMD thuần dự phòng chạy độc lập không cần PowerShell.
- [README.md](file:///d:/VSCode/DOAN2/git_tools/README.md): Hướng dẫn sử dụng.
