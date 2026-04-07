#!/bin/bash
#
# Script: convert-md-to-audio.sh
# Mô tả: Chuyển đổi hàng loạt file .md thành audio (.mp3) và phụ đề (.srt) bằng edge-tts với voice tiếng Việt.
# Tác giả: Chuyên gia Linux
# Ngày cập nhật: 17-09-2025
#

# Màu cho terminal
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Hàm in hướng dẫn sử dụng
show_help() {
    echo -e "${YELLOW}Sử dụng:${NC} $0 [TUỲ CHỌN]"
    echo -e "  Tự động chuyển tất cả file .md trong thư mục hiện tại sang audio (.mp3) và subtitle (.srt)"
    echo
    echo -e "${YELLOW}Tuỳ chọn:${NC}"
    echo -e "  -h, --help   Hiển thị hướng dẫn sử dụng"
    echo -e "  -d DIR       Thư mục chứa file .md (mặc định: ./)"
    echo
    echo -e "${YELLOW}Ví dụ:${NC}"
    echo -e "  $0"
    echo -e "  $0 -d /duong-dan/thu-muc"
    echo
}

# Xử lý tham số dòng lệnh
TARGET_DIR="."
while [[ $# -gt 0 ]]; do
    case "$1" in
        -h|--help)
            show_help
            exit 0
            ;;
        -d)
            shift
            TARGET_DIR="$1"
            ;;
        *)
            echo -e "${RED}Lỗi:${NC} Tham số không hợp lệ: $1" >&2
            show_help
            exit 1
            ;;
    esac
    shift
done

# Kiểm tra thư mục tồn tại
if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Lỗi:${NC} Thư mục '$TARGET_DIR' không tồn tại!" >&2
    exit 2
fi

# Tạo thư mục output nếu chưa có
mkdir -p "$TARGET_DIR/audio" "$TARGET_DIR/srt"

# Đếm file .md
MD_COUNT=$(find "$TARGET_DIR/text" -maxdepth 1 -type f -name '*.md' | wc -l)

if [ "$MD_COUNT" -eq 0 ]; then
    echo -e "${YELLOW}Không tìm thấy file .md nào trong thư mục $TARGET_DIR${NC}"
    exit 0
fi

echo -e "${GREEN}Bắt đầu chuyển đổi $MD_COUNT file .md...${NC}"

# Lặp qua từng file .md
find "$TARGET_DIR/text" -maxdepth 1 -type f -name '*.md' | while read -r file; do
    basename_noext=$(basename "$file" .md)

    audio_file="$TARGET_DIR/audio/${basename_noext}.mp3"
    srt_file="$TARGET_DIR/srt/${basename_noext}.srt"

    echo -e "${BLUE}Đang xử lý:${NC} $(basename "$file")"

    # Kiểm tra file rỗng
    if [ ! -s "$file" ]; then
        echo -e "${YELLOW}Cảnh báo:${NC} File $file bị rỗng, bỏ qua." >&2
        continue
    fi

    text_input="${basename_noext}. $(cat "$file")"
    # Thực thi lệnh edge-tts
    if edge-tts --voice vi-VN-NamMinhNeural \
        --text "$text_input" \
        --write-media "$audio_file" \
        --write-subtitles "$srt_file"; then
        echo -e "${GREEN}✔ Đã tạo:$audio_file và $srt_file${NC}"
    else
        echo -e "${RED}✗ Lỗi khi chuyển đổi $file RETRY 1${NC}"
        if edge-tts --voice vi-VN-NamMinhNeural \
            --text "$text_input" \
            --write-media "$audio_file" \
            --write-subtitles "$srt_file"; then
            echo -e "${GREEN}✔ Đã tạo:$audio_file và $srt_file${NC}"
        else
            echo -e "${RED}✗ Lỗi khi chuyển đổi RETRY 2 $file${NC}"
            
        fi
    fi

done

echo -e "${GREEN}Hoàn tất chuyển đổi tất cả file .md trong '$TARGET_DIR'!${NC}"
