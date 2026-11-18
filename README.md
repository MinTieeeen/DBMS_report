# Báo cáo BTL môn Hệ quản trị cơ sở dữ liệu (CO3021)

Mã nguồn LaTeX của báo cáo bài tập lớn: **Xây dựng ứng dụng đọc và sáng tác truyện trực tuyến Novelle trên nền MS SQL Server và Redis**.

## 1. Thiết lập ban đầu

### 1.1. Cài đặt công cụ

| Công cụ | Dùng để | Ghi chú |
|---|---|---|
| [MiKTeX](https://miktex.org/download) (hoặc TeX Live) | `pdflatex`, `biber` | Khi cài, chọn **"Install missing packages on-the-fly: Yes"** để MiKTeX tự tải package còn thiếu |
| [Python 3](https://www.python.org/downloads/) + Pygments | Package `minted` dùng để tô màu code | `pip install Pygments`, sau đó kiểm tra bằng `pygmentize -V` |
| [VS Code](https://code.visualstudio.com/) + extension **LaTeX Workshop** | Soạn thảo, build, xem PDF | Không bắt buộc nếu build bằng dòng lệnh |
| [Strawberry Perl](https://strawberryperl.com/) | Chỉ cần nếu muốn dùng `latexmk` | Không bắt buộc |

Sau khi cài xong, **đóng hẳn và mở lại VS Code** (hoặc terminal) để nhận PATH mới. Nếu bỏ qua bước này, LaTeX Workshop sẽ báo lỗi `spawn pdflatex ENOENT`.

Kiểm tra nhanh trong terminal:

```powershell
pdflatex --version
biber --version
pygmentize -V
```

### 1.2. Clone và mở project

```bash
git clone <url-repo> DBMS_report
code DBMS_report
```

Mở **thư mục `DBMS_report`** làm workspace để VS Code nhận cấu hình trong `.vscode/settings.json`.

## 2. Cách build

Mọi file sinh ra khi build (`*.aux`, `*.log`, `*.bbl`, cache của `minted`, ...) và **file PDF** đều nằm trong thư mục **`build/`**. Thư mục gốc chỉ chứa mã nguồn. Kết quả cuối cùng là **`build/main.pdf`**.

### 2.1. Bằng VS Code (khuyến nghị)

1. Mở `main.tex`.
2. Nhấn **Ctrl+Alt+B** (hoặc biểu tượng TeX ở thanh bên → *Build LaTeX project*).
3. Xem PDF bằng **Ctrl+Alt+V** (LaTeX Workshop tự mở `build/main.pdf`).

Các recipe (cấu hình trong `.vscode/settings.json`):

| Recipe | Khi nào dùng |
|---|---|
| `pdflatex -> biber -> pdflatex x2` (mặc định) | Build đầy đủ: mục lục, tham chiếu chéo, tài liệu tham khảo |
| `pdflatex (nhanh, 1 lần)` | Chỉ sửa chữ, không thêm `\cite`, `\label` hay mục mới |
| `latexmk (cần Perl)` | Máy đã cài Perl |

### 2.2. Bằng dòng lệnh

```powershell
cd DBMS_report
.\build.ps1          # build đầy đủ  -> build/main.pdf
.\build.ps1 quick    # 1 lần pdflatex
.\build.ps1 clean    # xoá thư mục build/
```

Hoặc, nếu có Perl: `latexmk` (cấu hình trong `.latexmkrc`, cũng xuất ra `build/`).

Script làm 2 việc mà lệnh `pdflatex -output-directory=build` không tự làm:
- tạo sẵn `build/section/`, vì mỗi `\include{section/...}` ghi file `.aux` vào đó;
- đặt biến môi trường `TEXMF_OUTPUT_DIRECTORY=build`, vì `minted` v3 cần biến này để tìm thư mục output.

Thư mục `build/` **không được commit** (xem `.gitignore`).

### 2.3. Lỗi thường gặp

| Lỗi | Cách xử lý |
|---|---|
| `spawn pdflatex ENOENT` | VS Code chưa thấy MiKTeX trong PATH → khởi động lại VS Code |
| `MiKTeX could not find the script engine 'perl'` | Đang dùng recipe `latexmk` → chuyển sang recipe `pdflatex -> biber -> pdflatex x2` hoặc cài Perl |
| `Package minted Error: You must invoke LaTeX with the -shell-escape flag` | Build thiếu cờ `-shell-escape` |
| `Package minted Error: You must have 'pygmentize' installed` | Cài Python + `pip install Pygments` |
| Tài liệu tham khảo hiện `[?]` hoặc không xuất hiện | Chưa chạy `biber`, hãy build lại đủ chuỗi |
| `minted v3 Python executable could not find output directory` | Build `-output-directory=build` mà thiếu biến `TEXMF_OUTPUT_DIRECTORY=build` → dùng `build.ps1` hoặc recipe có sẵn |
| `I can't write on file 'section/....aux'` | Thiếu thư mục `build/section/` → dùng `build.ps1` hoặc recipe có sẵn |
| Còn file `.aux`, `.log`, `main.pdf` ở thư mục gốc | Do build theo cách cũ; xoá đi, chúng đã bị `.gitignore` bỏ qua |
| Mục lục hoặc tham chiếu chéo hiện `??` | Build thêm một lần nữa |

## 3. Cấu trúc thư mục

```
DBMS_report/
├── main.tex                     # File gốc: preamble, trang bìa, danh sách thành viên, mục lục, include các chương
├── references.bib               # Tài liệu tham khảo (biblatex + biber)
├── appendix.tex                 # Phụ lục: Biên bản họp nhóm
├── section/
│   ├── 1_Introduction.tex                   # Chương 1. Giới thiệu đề tài
│   ├── 2_DBMS_Overview.tex                  # Chương 2. Tổng quan về hệ quản trị CSDL
│   ├── 3_Application_Database_Design.tex    # Chương 3. Tổng quan ứng dụng và thiết kế CSDL
│   ├── 4_DBMS_Topics.tex                    # Chương 4. So sánh và nghiên cứu (\input các chủ đề bên dưới)
│   ├── 4_DBMS_Topics/
│   │   ├── 4_1_Data_Storage.tex             # 4.1 Quản lý và lưu trữ dữ liệu
│   │   ├── 4_2_Query_Processing.tex         # 4.2 Xử lý truy vấn
│   │   ├── 4_3_Transaction.tex              # 4.3 Giao dịch
│   │   ├── 4_4_Concurrency_Control.tex      # 4.4 Kiểm soát đồng thời
│   │   ├── 4_5_Backup_Recovery.tex          # 4.5 Sao lưu và phục hồi
│   │   └── 4_6_Summary.tex                  # 4.6 Tổng hợp (hiện chưa được \input trong 4_DBMS_Topics.tex)
│   ├── 5_Architecture_Implementation.tex    # Chương 5. Thiết kế kiến trúc và triển khai ứng dụng
│   └── 6_Conclusion.tex                     # Chương 6. Kết luận và đánh giá
├── image/
│   ├── HCMUT_official_logo.png
│   ├── chapter3/                # Ảnh của chương 3 (ERD, lược đồ, ...)
│   ├── chapter4/                # Ảnh thực nghiệm chương 4
│   └── chapter5/                # Ảnh kiến trúc, ảnh chụp màn hình ứng dụng
├── build/                       # Mọi file sinh ra + main.pdf (không commit)
├── build.ps1                    # Script build (full / quick / clean)
├── .vscode/settings.json        # Recipe build cho LaTeX Workshop (xuất ra build/)
├── .latexmkrc                   # Cấu hình latexmk (tùy chọn, xuất ra build/)
└── .gitignore
```

### Quy ước nội dung

- Mỗi `\section` là **một chương** và được hiển thị dạng *CHƯƠNG n. TÊN CHƯƠNG*, bắt đầu ở trang mới. Bên trong chương dùng `\subsection` (n.m) và `\subsubsection` (n.m.k).
- Số hiệu hình, bảng và phương trình có dạng `chương.mục.số` và tự reset theo từng `\subsection`.
- Thông tin chung (tên môn, mã môn, tên đề tài, GVHD, lớp, thành viên) khai báo bằng macro ở đầu `main.tex`, ví dụ `\ReportTitle`, `\Lecturer`, `\StudentOneName`. Muốn sửa thì chỉ sửa ở đó.
- Các chỗ còn trống được đánh dấu `% TODO`.

### Thêm nội dung

**Hình ảnh:** đặt file vào `image/chapterN/`, sau đó:

```latex
\begin{figure}[H]
    \centering
    \includegraphics[width=0.9\textwidth]{image/chapter3/erd.png}
    \caption{Sơ đồ thực thể - liên kết}
    \label{fig:erd}
\end{figure}
```

**Code SQL / Redis** (dùng `minted`):

```latex
\begin{minted}[fontsize=\small, breaklines]{sql}
SELECT TOP (10) * FROM dbo.Stories ORDER BY CreatedAt DESC;
\end{minted}
```

**Tài liệu tham khảo:** thêm entry vào `references.bib`, trích dẫn bằng `\cite{key}`. Nếu muốn tài liệu xuất hiện dù không trích dẫn, thêm key vào `\nocite{...}` trong `main.tex`.

**Biên bản họp:** trong `appendix.tex`, sao chép khối `\subsection*{Buổi họp số ...}` cho mỗi buổi họp.

## 4. Làm việc nhóm với Git

- Mỗi người phụ trách file chương hoặc chủ đề của mình, để hạn chế conflict khi sửa cùng một file.
- Trước khi push, **build thử để chắc chắn không có lỗi**.
- Khi thêm mục mới vào `main.tex`, chương mới hoặc phiên bản mới, cập nhật bảng `versionhistory` trong `main.tex`.
