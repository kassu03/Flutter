# 📱 Flutter Class Practice & Assignments

> **2026학년도 2학기 Flutter/Dart 실습 기록 저장소**

---

## 🛠️ 개발 환경 (Environment)
- **OS:** Windows 11
- **IDE:** VS Code
- **Flutter SDK:** `C:\src\flutter`
- **Primary Device:** Chrome / Android Emulator

---

## 주차별 과제 기록

| 주차 | 주제 / 내용 | 실행 증거 및 트러블슈팅 링크 |
| :---: | :--- | :---: |
| **Week 02** | Flutter 개발환경 구축 & 한글 경로 Impeller 셰이더 에러 해결 | [📄 Week02 보고서 보기](./Week2.md) |
| **Week 03** | 

---

## 주요 트러블슈팅
- **Impeller Shader Error (`ink_sparkle.frag`):**
  - **원인:** Windows 사용자 계정명에 한글이 포함되어 셰이더 컴파일 실패.
  - **해결:** SDK 및 프로젝트 위치를 영문 경로(`C:\src\flutter`)로 이동 후 환경변수 PATH 재설정.
