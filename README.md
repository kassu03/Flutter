# Flutter
플루터 과제 결과 오류 해결 과정을 기록

09/09 Week2
### 1. Flutter 개발 환경 구축
- **Flutter SDK 다운로드 및 설치:** `C:\src\flutter` 경로에 최신 SDK 세팅
- **환경 변수(PATH) 지정:** 시스템 사용자 변수 Path에 `C:\src\flutter\bin` 추가하여 터미널 명령어 연동
- **개발 도구 연동:** VS Code 확장(Flutter, Dart) 설치 및 `flutter doctor` 정상 작동 검증

### 2. 트러블슈팅 및 오류 해결 (Impeller Shader Error)
- **문제 발생:** 
  - `flutter run -d chrome` 실행 시 `ink_sparkle.frag` 셰이더 컴파일 오류 (`DevFSShaderCompilationException`, `SIGSEGV`) 발생하며 웹 실행 중단.
- **원인 분석:** 
  - Windows 사용자 계정명 및 기존 SDK 설치 경로에 **한글(`김현중`)**이 포함되어 Impeller 셰이더 컴파일러가 경로를 정상 인식하지 못함.
- **해결 조치:** 
  1. Flutter SDK 위치를 한글이 없는 완전한 영문 경로(`C:\src\flutter`)로 이동.
  2. 사용자 환경 변수 Path를 `C:\src\flutter\bin`으로 재설정.
  3. 프로젝트 위치 역시 `C:\dev\week2_first_app` (또는 영문 경로)으로 구동 환경 일치.
  4. `flutter clean` 및 `flutter pub get` 실행 후 재구동.
- **결과:** 
  - 경로 오류 해결 후 Chrome 브라우저에서 Flutter 앱 정상 구동 성공.
