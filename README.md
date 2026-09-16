# Capstone Project Requirements Review Desktop Application

A specialized Flutter Desktop application designed for reviewers and evaluators to import, parse, review, and analyze the Requirements section of Capstone Project SRS documents with AI assistance.

## 📌 Project Overview
- **Technology:** Flutter Desktop (Windows / macOS / Linux)
- **Specification:** Capstone Project Requirements Review SRS v1.0
- **Architecture:** Clean Architecture (Presentation, Domain, Data, Infrastructure)
- **UI Design System:** Professional Developer Tool / IDE style with 3-column layout:
  - **Left Panel:** Document & Requirement List with search and filtering
  - **Center Panel:** Requirement Details, manual review status, and reviewer comments
  - **Right Panel:** AI Quality Review (Scores, Issues, Suggested Revisions)

---

## 👥 Team Work Breakdown (5 Members)
For a complete breakdown of features, functional requirements (FR-001 to FR-020), and assigned responsibilities, please see [TASKS.md](TASKS.md).

- **Member 1 (Team Lead / Core Architecture & Parsers):** Project Architecture, Data Models, File I/O (File Picker, Drag-and-Drop), Document Parsers (PDF, DOCX, TXT, MD), Section & Requirement Extraction.
- **Member 2 (UI/UX & Requirement List):** Design System, Neutral-first Theme, Lucide Icons, 3-Column Workspace Layout, Left Panel Requirements List, Search & Filter.
- **Member 3 (Workspace Detail & Manual Review):** Center Panel Requirement Detail View, Review Status controls (Passed, Needs Review, Failed), Reviewer Comments System.
- **Member 4 (AI Analysis Engine & Review Panel):** AI Service Abstraction (Gemini / OpenAI / Mock), 7 Quality Criteria evaluation, Right Panel AI Results & Suggested Revisions.
- **Member 5 (Dashboard, Export & QA):** Review Dashboard & Summary Statistics, Export Review Report to PDF and CSV, Windows build optimization and packaging.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (Channel `stable`, 3.24+)
- Visual Studio 2022 with **Desktop development with C++** workload (for Windows Desktop)
- Git

### Installation & Run
1. Clone the repository:
   ```bash
   git clone https://github.com/lqkhanh295/capstone-requirements-review.git
   cd capstone-requirements-review
   ```

2. Get dependencies:
   ```bash
   flutter pub get
   ```

3. Run unit tests:
   ```bash
   flutter test test/dashboard_export_test.dart
   ```

4. Run the Windows Desktop app:
   ```bash
   flutter run -d windows
   ```

---

## 📊 Dashboard, Export & Packaging Features (Member 5 - TRUNG)
- **Review Dashboard (SRS Section 6.1):** Summarizes document metadata, requirement counts by status (`Passed`, `Needs Review`, `Failed`, `Not Reviewed`), Overall Quality Score circular gauge indicator, and recent critical issues list.
- **Export Report Module (FR-020, SRS Section 6.2):**
  - **PDF Export:** Print-ready document with cover page, summary table, quality scores breakdown, and requirement details list.
  - **CSV Export:** Tabular format compatible with MS Excel.
  - **Shortcut `Ctrl + E`:** Instant keyboard shortcut trigger for Export modal popup.
- **Performance & Packaging:** Isolate background execution (`compute`), minimum window size (`1200x800`), and production Windows Desktop release build instructions. For detailed build instructions, see [PACKAGING_GUIDE.md](PACKAGING_GUIDE.md).

