import cv2
import tkinter as tk
from tkinter import filedialog, messagebox
from ultralytics import YOLO
# 1. KHỞI TẠO MÔ HÌNH AI
try:
    model = YOLO(r"D:\VSCode\DOAN2\data\ra-dai\best.pt")
    print(f"Tổng số loại biển báo hỗ trợ: {len(model.names)}")
except Exception as e:
    print("Lỗi: Không tìm thấy file best.pt! Hãy để best.pt cùng thư mục với file code này.")


# 2. CÁC HÀM XỬ LÝ NHẬN DIỆN
# Hàm nhận diện trên Ảnh tĩnh
def chon_anh():
    file_path = filedialog.askopenfilename(
        title="Chọn ảnh giao thông",
        filetypes=[("Image files", "*.jpg *.jpeg *.png *.bmp *.webp")]
    )
    if not file_path:
        return

    # Hạ conf=0.2 để bắt nhạy hơn với các biển báo nhỏ hoặc hơi mờ
    results = model.predict(source=file_path, conf=0.2, imgsz=640)

    # Kiểm tra số lượng biển báo phát hiện được
    boxes = results[0].boxes
    num_detections = len(boxes)

    if num_detections == 0:
        messagebox.showinfo(
            "Kết quả",
            "Không tìm thấy biển báo nào trong ảnh này!\n\n"
            "Mẹo: Hãy thử chọn ảnh chụp biển báo ngoài đường phố thực tế."
        )
    else:
        # In ra màn hình Console tên các biển báo tìm thấy và độ chính xác
        print(f"\n---> Tìm thấy {num_detections} biển báo trong ảnh:")
        for box in boxes:
            cls_id = int(box.cls[0])
            conf_score = float(box.conf[0]) * 100
            ten_bien = model.names[cls_id]
            print(f" + {ten_bien} (Độ tin cậy: {conf_score:.1f}%)")

    # Vẽ khung và tên tiếng Việt lên ảnh
    annotated_img = results[0].plot()

    # Tự động thu nhỏ cửa sổ nếu ảnh quá lớn so với màn hình laptop
    h, w = annotated_img.shape[:2]
    max_width = 1000
    max_height = 700
    if w > max_width or h > max_height:
        scale = min(max_width / w, max_height / h)
        new_w, new_h = int(w * scale), int(h * scale)
        annotated_img = cv2.resize(annotated_img, (new_w, new_h))

    cv2.imshow("Ket qua nhan dien Anh (Nhan phim bat ky de dong)", annotated_img)
    cv2.waitKey(0)
    cv2.destroyAllWindows()


# Hàm chọn Video từ máy tính
def chon_video():
    file_path = filedialog.askopenfilename(
        title="Chọn video hành trình",
        filetypes=[("Video files", "*.mp4 *.avi *.mkv *.mov")]
    )
    if not file_path:
        return
    chay_luong_video(file_path)


# Hàm mở Webcam laptop
def mo_webcam():
    chay_luong_video(0)


# Hàm xử lý chung cho cả Video và Webcam (Tối ưu nhẹ máy)
def chay_luong_video(source):
    cap = cv2.VideoCapture(source)
    if not cap.isOpened():
        messagebox.showerror("Lỗi", "Không thể mở nguồn Video hoặc Webcam!")
        return

    print("\nĐang chạy nhận diện thời gian thực... Nhấn phím 'q' trên cửa sổ video để dừng.")

    while cap.isOpened():
        ret, frame = cap.read()
        if not ret:
            break

        # Đặt imgsz=480, conf=0.25 và verbose=False để CPU chạy mượt, không bị lag
        results = model.predict(source=frame, imgsz=480, conf=0.25, verbose=False)
        annotated_frame = results[0].plot()

        # Thu nhỏ khung hình video nếu video gốc quá to (ví dụ video 4K/FullHD)
        h, w = annotated_frame.shape[:2]
        if w > 1000:
            annotated_frame = cv2.resize(annotated_frame, (1000, int(h * 1000 / w)))

        cv2.imshow("Nhan dien Bien Bao - Nhan phim 'q' de thoat", annotated_frame)

        # Nhấn phím 'q' (chữ thường) trên bàn phím để thoát
        if cv2.waitKey(1) & 0xFF == ord('q'):
            break

    cap.release()
    cv2.destroyAllWindows()


# ==========================================
# 3. THIẾT KẾ GIAO DIỆN CHÍNH (TKINTER)
# ==========================================
root = tk.Tk()
root.title("Hệ Thống Nhận Diện Biển Báo Giao Thông Việt Nam")
root.geometry("450x330")
root.resizable(False, False)

# Tiêu đề
lbl_title = tk.Label(
    root,
    text="NHẬN DIỆN BIỂN BÁO GIAO THÔNG",
    font=("Arial", 14, "bold"),
    fg="#1a73e8"
)
lbl_title.pack(pady=(20, 5))

lbl_sub = tk.Label(
    root,
    text="Hỗ trợ nhận diện 52 loại biển báo Việt Nam (YOLO11)",
    font=("Arial", 10),
    fg="#5f6368"
)
lbl_sub.pack(pady=(0, 15))

# Các nút bấm chức năng
btn_img = tk.Button(
    root, text="🖼️ Chọn Ảnh để nhận diện",
    font=("Arial", 12), width=30, height=1, bg="#e8f0fe", cursor="hand2",
    command=chon_anh
)
btn_img.pack(pady=7)

btn_vid = tk.Button(
    root, text="🎬 Chọn Video hành trình",
    font=("Arial", 12), width=30, height=1, bg="#e8f0fe", cursor="hand2",
    command=chon_video
)
btn_vid.pack(pady=7)

btn_cam = tk.Button(
    root, text="📷 Mở Webcam trực tiếp",
    font=("Arial", 12), width=30, height=1, bg="#e8f0fe", cursor="hand2",
    command=mo_webcam
)
btn_cam.pack(pady=7)

# Ghi chú hướng dẫn
lbl_note = tk.Label(
    root,
    text="Lưu ý: Khi đang chạy Video/Webcam, nhấn phím 'q' để thoát",
    font=("Arial", 9, "italic"),
    fg="#d93025"
)
lbl_note.pack(pady=15)

root.mainloop()