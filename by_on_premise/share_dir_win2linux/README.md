# share_dir_win2linux
윈도우 디렉터리를 공유하고, 리눅스에서 마운트하는 스크립트.
윈도우에서 작업하고, 리눅스에서 바로 파일 실행시키기 위해 만들어진 레포지토리입니다.

## 사용법
### 1. 윈도우에서 bat 파일을 실행한다. (관리자 권한)
### 2. 윈도우 계정, 비밀번호를 .smbcredentials 에 표기한다.
### 3. 리눅스 (centos || rocky || ubuntu)에서 sh 파일을 열어서 ip 및 공유 디렉터리 name을 기입한다.
### 4. 쉘을 실행한다.
### 5. 윈도우 계정의 id/pwd가 잘못되었을 경우 다음과 같이 에러가 발생한다.
#### mount error(13): Permission denied
#### Refer to the mount.cifs(8) manual page (e.g. man mount.cifs)
#### Failed to mount //ip/share_dir
