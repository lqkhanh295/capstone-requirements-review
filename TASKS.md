# CAPSTONE PROJECT REQUIREMENTS REVIEW DESKTOP APPLICATION
## BẢNG PHÂN CHIA NHIỆM VỤ CHI TIẾT (TEAM 5 THÀNH VIÊN)
**Công nghệ:** Flutter Desktop (Windows)  
**Kiến trúc:** Clean Architecture (Presentation, Domain, Data, Infrastructure)  
**Tài liệu tham chiếu:** Software Requirements Specification (SRS v1.0)

---

### 📊 TỔNG QUAN PHÂN CHIA VAI TRÒ

| Thành viên | Vai trò chính | Module phụ trách | Các yêu cầu SRS (FR / NFR) |
| :--- | :--- | :--- | :--- |
| **Thành viên 1** | **Team Lead / Architecture & File Parsing** | Core Architecture, Document Engine & Parsers | FR-001, FR-002, FR-003, FR-004, FR-005, FR-006, FR-007, NFR-004 |
| **Thành viên 2** | **UI/UX Specialist & Navigation** | Base Theme, 3-Column Layout, Left Panel (Req List) | Section 5.1-5.5, FR-009 (List part), Section 7, Section 8, Section 9 |
| **Thành viên 3** | **Workspace & Manual Review Engineer** | Middle Panel (Req Detail), Review & Comments | FR-008, FR-009 (Detail), FR-010, FR-011, Section 5.2 |
| **Thành viên 4** | **AI Engine & AI Review Panel Engineer** | AI Service Abstraction, AI Review Panel | FR-012, FR-013, FR-014, FR-015, FR-016, FR-017, FR-018, FR-019, Section 4 |
| **Thành viên 5** | **Dashboard, Report Export & QA/Packaging** | Review Dashboard, Export PDF/CSV, Windows Build | FR-020, Section 6.1, 6.2, NFR-001, NFR-002, NFR-003 |

---

### 👤 THÀNH VIÊN 1: TEAM LEAD / ARCHITECTURE & CORE FILE PARSER
**Mục tiêu:** Xây dựng khung kiến trúc dự án, hệ thống dữ liệu cốt lõi và module import/đọc tài liệu.

- **Nhiệm vụ cụ thể:**
  1. **Khởi tạo kiến trúc dự án (Clean Architecture):**
     - Thiết lập cấu trúc thư mục: `core/`, `domain/`, `data/`, `presentation/`, `infrastructure/`.
     - Cài đặt và cấu hình State Management (`flutter_riverpod`).
  2. **Xây dựng Domain Models cốt lõi (Section 12):**
     - Model `Document` (id, name, filePath, fileType, fileSize, importedAt, requirements[]).
     - Model `Requirement` (id, title, description, type, sourceLocation, status, review, comments[]).
     - Enum `RequirementType` (Functional, Non-functional, Business, Technical, Security, Performance, Usability, Other).
     - Enum `ReviewStatus` (Not Reviewed, Passed, Needs Review, Failed).
  3. **Xử lý File Input & Validation (FR-001, FR-002, FR-003):**
     - Tích hợp File Picker dialog (cho phép chọn file từ máy tính).
     - Tích hợp Drag & Drop (`desktop_drop`) với hiệu ứng hiển thị vùng thả file (drop zone).
     - Kiểm tra tính hợp lệ của file (định dạng hỗ trợ: PDF, DOCX, TXT, Markdown; giới hạn kích thước, kiểm tra quyền đọc).
  4. **Document Content Extraction & Parser (FR-004, FR-005, FR-006, FR-007):**
     - Bộ phân giải PDF (`syncfusion_flutter_pdf` hoặc `pdf_text`).
     - Bộ phân giải DOCX (`archive` giải nén `word/document.xml`).
     - Bộ phân giải TXT và Markdown thuần.
     - Thuật toán nhận diện phân đoạn (Section Detection: Functional Requirements vs Non-functional Requirements).
     - Thuật toán bóc tách từng Requirement và bảo tồn / sinh mã ID tự động (`REQ-001`, `REQ-002`,...).

---

### 👤 THÀNH VIÊN 2: UI/UX SPECIALIST & REQUIREMENTS LIST PANEL
**Mục tiêu:** Xây dựng hệ thống Design System chuẩn IDE và toàn bộ Cột trái (Left Sidebar) quản lý danh sách yêu cầu.

- **Nhiệm vụ cụ thể:**
  1. **Thiết kế Hệ thống Giao diện (Design System - Section 5.1, 5.3, 5.4):**
     - Tone màu trung tính (Neutral-first visual system, viền 1px subtle gray, bo góc 6–10px, không gradient/glassmorphism).
     - Bộ icon: Lucide Icons (`lucide_icons`).
     - Typography: Font Inter (UI) & JetBrains Mono (Code/ID).
     - Bảng màu trạng thái: Green (Passed), Amber (Needs Review), Red (Failed), Gray (Not Reviewed).
  2. **Bố cục chính Workspace 3 cột (Section 5.2):**
     - Left Sidebar: ~220–240 px.
     - Main Content (Middle): Co giãn linh hoạt.
     - AI Review Panel (Right): ~320–380 px.
  3. **Cột trái - Danh sách Requirements (Section 5.5, FR-009):**
     - Thanh tìm kiếm (Search bar) tìm theo ID, Tiêu đề hoặc nội dung (Section 7).
     - Nhóm tab lọc nhanh: `[All]`, `[Needs Review]`, `[Failed]`.
     - Header hiển thị tổng số: `REQUIREMENTS (24)`.
     - Danh sách Requirement cards với: Icon trạng thái (`✓`, `⚠`, `✕`), Mã ID, Tiêu đề, Badge đếm issue (ví dụ: `2 issues`, `1 critical issue`).
  4. **Điều hướng & Phím tắt (Section 7, 8, 9):**
     - Điều hướng danh sách bằng phím mũi tên `↑ / ↓`.
     - Phím tắt `Ctrl + F` kích hoạt nhanh ô tìm kiếm.
     - Đảm bảo Focus states và Tooltips hiển thị chuẩn khi rê chuột.

---

### 👤 THÀNH VIÊN 3: WORKSPACE DETAIL & MANUAL REVIEW WORKFLOW
**Mục tiêu:** Xây dựng Cột giữa (Main Content) hiển thị chi tiết Requirement và quy trình đánh giá thủ công của Reviewer.

- **Nhiệm vụ cụ thể:**
  1. **Hiển thị Chi tiết Requirement (Section 5.2, FR-009):**
     - Header: Mã Requirement ID, Title, Source Context / Vị trí trong file gốc.
     - Dropdown / Badge phân loại loại yêu cầu (FR-008: Functional, Non-functional, Security, Performance...).
     - Khung hiển thị mô tả yêu cầu (Description) định dạng rõ ràng, dễ đọc.
  2. **Quy trình Đánh giá thủ công - Manual Review Status (FR-010):**
     - Bộ chọn trạng thái đánh giá: `Not Reviewed`, `Passed`, `Needs Review`, `Failed`.
     - Cập nhật màu sắc trạng thái tức thì và đồng bộ sang Cột trái (Requirement List) và Dashboard.
  3. **Hệ thống Ghi chú Reviewer Comments (FR-011):**
     - Giao diện danh sách comment theo từng requirement.
     - Form thêm comment mới kèm timestamp.
     - Chức năng chỉnh sửa (Edit) và xóa (Delete) comment.
  4. **Đồng bộ trạng thái & Phím tắt:**
     - Lắng nghe State khi người dùng click chọn requirement ở cột trái.
     - Phím tắt `Ctrl + S`: Lưu trạng thái phiên review hiện tại.
     - Giao diện chuyển đổi linh hoạt khi tài liệu chưa được import (Empty placeholder state).

---

### 👤 THÀNH VIÊN 4: AI ANALYSIS INTEGRATION & AI REVIEW PANEL
**Mục tiêu:** Xây dựng module kết nối AI, phân tích chất lượng yêu cầu và toàn bộ Cột phải (AI Review Panel).

- **Nhiệm vụ cụ thể:**
  1. **Kiến trúc AI Provider Abstraction (Section 4.3, FR-018, FR-019):**
     - Tạo abstract class `AIService` cho phép hoán đổi provider dễ dàng.
     - `GeminiAIService` / `OpenAIAIService` (tích hợp API thật, cho phép người dùng nhập API Key).
     - `MockAIService` (tự động phân tích offline dựa trên bộ rule ngữ nghĩa, hỗ trợ demo khi không có mạng/hết quota).
     - Xử lý lỗi linh hoạt (Rate-limit cooldown, retry, báo lỗi thân thiện, không làm sập ứng dụng).
  2. **Đánh giá 7 tiêu chí chất lượng (FR-013, Section 4.1):**
     - Phân tích: Clarity, Completeness, Testability, Consistency, Feasibility, Ambiguity, Duplication.
     - Định dạng đầu ra khớp chính xác **AI Response Contract** (Section 4.2).
  3. **Cột phải - AI Review Panel (Section 5.6, FR-014, FR-015):**
     - Khung hiển thị Điểm tổng quan (`Overall 84 / 100`) với màu tương ứng.
     - Danh sách điểm chi tiết từng tiêu chí (Clarity Good, Testability Needs review...).
     - Danh sách Issues kèm mức độ nghiêm trọng (`Low`, `Medium`, `High`).
  4. **Suggested Revision & Batch Analysis (FR-016, FR-017):**
     - Khung đề xuất câu văn cải tiến (`Suggested Revision`).
     - Nút `[Apply suggestion]` (yêu cầu người dùng xác nhận trước khi cập nhật, không tự ý ghi đè văn bản gốc).
     - Chức năng Batch AI Analysis (phân tích toàn bộ requirements với progress indicator).
     - Phím tắt `Ctrl + Enter`: Gửi phân tích AI cho requirement đang chọn.

---

### 👤 THÀNH VIÊN 5: REVIEW DASHBOARD, EXPORT & PACKAGING
**Mục tiêu:** Xây dựng màn hình thống kê Dashboard, module xuất báo cáo chuyên nghiệp (PDF/CSV) và đóng gói app Windows.

- **Nhiệm vụ cụ thể:**
  1. **Màn hình Review Dashboard (Section 6.1):**
     - Thống kê tài liệu: Tên tài liệu, ngày review, tổng số requirements.
     - Biểu đồ / Thẻ tóm tắt phân loại trạng thái: `Passed`, `Needs Review`, `Failed`.
     - Chỉ số điểm chất lượng tổng thể (`Overall Quality Score`).
     - Danh sách các vấn đề nổi cộm gần đây (`Recent Issues`).
  2. **Module Xuất Báo Cáo - Export Report (FR-020, Section 6.2):**
     - Xuất báo cáo định dạng **PDF** chuẩn in ấn (sử dụng thư viện `pdf` & `printing`):
       - Trang bìa/Header: Thông tin dự án, tài liệu, thời gian review, tổng điểm.
       - Bảng tóm tắt số lượng theo trạng thái.
       - Chi tiết từng Requirement kèm điểm AI, Issues, Suggested Revision và Reviewer Comments.
     - Xuất dữ liệu bảng ra file **CSV** (hỗ trợ mở bằng Excel).
     - Phím tắt `Ctrl + E`: Kích hoạt popup xuất báo cáo.
  3. **Tối ưu hóa hiệu năng & Đóng gói Windows (NFR-001, NFR-002, NFR-003):**
     - Chạy các tác vụ nặng (Parse file PDF/DOCX, xử lý AI, Render PDF) trên background isolate/async để không bị giật lag giao diện (No UI freeze).
     - Thiết lập cửa sổ Windows Desktop (`window_manager`): kích thước tối thiểu (1200x800), thanh tiêu đề chuyên nghiệp.
     - Build thử nghiệm phiên bản Release trên Windows (`flutter build windows`).
     - Viết tài liệu hướng dẫn chạy dự án và kiểm thử toàn diện (Integration Testing).

---

### 📅 KẾ HOẠCH PHỐI HỢP & GIAO TIẾP (GIT WORKFLOW)

```
main (Chỉ merge khi hoàn tất và test pass)
  └── develop (Nhánh tích hợp chung)
        ├── feature/member-1-core-parser
        ├── feature/member-2-layout-list
        ├── feature/member-3-detail-review
        ├── feature/member-4-ai-panel
        └── feature/member-5-dashboard-export
```

- **Quy tắc làm việc nhóm:**
  1. Tất cả code mới đều tạo branch từ `develop`.
  2. Các Model và Repository Interface của **Thành viên 1** sẽ được ưu tiên hoàn thành trước trong ngày đầu tiên để 4 thành viên còn lại có thể code song song mà không bị phụ thuộc.
  3. Mỗi pull request cần có ít nhất 1 thành viên khác review trước khi merge vào `develop`.
