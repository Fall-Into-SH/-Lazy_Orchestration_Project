#!/bin/bash

# Windows 공유 폴더 정보
WINDOWS_IP="172.30.1.16"
WINDOWS_SHARE_NAME="test_share"

# 마운트할 리눅스 디렉터리
MOUNT_POINT="/mnt/windows_share"

# 크리덴셜 파일 경로
CREDENTIALS_FILE="$HOME/.smbcredentials"

# 배포판 인식 및 패키지 관리자 설정
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
elif [ -f /etc/redhat-release ]; then
    OS="centos"
else
    OS=$(uname -s)
fi

# 필요한 패키지 설치
echo "Installing necessary packages..."
if [[ "$OS" == "ubuntu" ]]; then
    sudo apt update
    sudo apt install -y cifs-utils
elif [[ "$OS" == "centos" || "$OS" == "rocky" ]]; then
    sudo yum install -y cifs-utils
else
    echo "Unsupported OS: $OS"
    exit 1
fi

# 크리덴셜 파일 체크
if [ ! -f $CREDENTIALS_FILE ]; then
  echo "not found $HOME/.smbcredentials"
  exit 1
fi

chmod 600 $CREDENTIALS_FILE

# 마운트할 디렉터리 생성
echo "Creating mount point directory..."
sudo mkdir -p $MOUNT_POINT

# /etc/fstab에 항목 추가
echo "Adding entry to /etc/fstab..."
FSTAB_ENTRY="//$WINDOWS_IP/$WINDOWS_SHARE_NAME $MOUNT_POINT cifs credentials=$CREDENTIALS_FILE,iocharset=utf8,vers=3.0,sec=ntlmssp 0 0"

# 기존에 동일한 항목이 있는지 확인하고 없으면 추가
if ! grep -q "$FSTAB_ENTRY" /etc/fstab; then
  echo "$FSTAB_ENTRY" | sudo tee -a /etc/fstab
  echo "Entry added to /etc/fstab."
else
  echo "Entry already exists in /etc/fstab."
fi

# 마운트 실행
echo "Mounting all entries from /etc/fstab..."
sudo mount -a

# 마운트 결과 확인
if mount | grep $MOUNT_POINT > /dev/null; then
  echo "Successfully mounted //$WINDOWS_IP/$WINDOWS_SHARE_NAME to $MOUNT_POINT"
else
  echo "Failed to mount //$WINDOWS_IP/$WINDOWS_SHARE_NAME"
fi

