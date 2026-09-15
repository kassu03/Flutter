# Flutter
플루터 과제 결과 오류 해결 과정을 기록

## 09/09 Week2
### 1. Flutter doctor -v 수집
<img width="1652" height="1139" alt="image" src="https://github.com/user-attachments/assets/a3e519f5-983b-411a-aa4c-7421e9e541c5" />

### 2. 첫 앱 실행 결과
<img width="1916" height="1140" alt="image" src="https://github.com/user-attachments/assets/12d7be7a-9433-44ec-8409-d2d4f5fa896d" />

### 3. Github 저장소
저장소 주소: https://github.com/kassu03/Flutter

첫 Commit ID: e9c226b

### 4. 목표,관찰,원인,행동,결과
목표: Windows 환경에서 Flutter SDK 설치 및 첫 샘플 앱 웹/앱 구동

관찰: flutter run -d chrome 실행 시 ink_sparkle.frag 셰이더 컴파일 오류 (DevFSShaderCompilationException, SIGSEGV) 발생

원인: Windows 사용자 계정명 및 설치 경로에 한글(김현중)이 포함되어 Impeller 셰이더 컴파일러가 경로를 정상 인식하지 못함

행동: Flutter SDK를 한글이 없는 C:\src\flutter로 이동, 환경 변수 PATH 재설정, 프로젝트 폴더를 C:\src\my_app으로 변경 후 flutter clean 실행

결과: 경로 오류 해결 후 Chrome 브라우저에서 샘플 앱 정상 구동 완료
