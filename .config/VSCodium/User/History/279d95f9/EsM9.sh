#!/bin/bash
# Hàm đổi tên file theo yêu cầu: lấy phần trước dấu '-', thay dấu cách bằng '_'

rename_files() {
    local dir="${1:-.}"

    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'

    if [[ "$1" == "-h" || "$1" == "--help" ]]; then
        echo -e "${YELLOW}Cách dùng:$(basename "$0") [đường_dẫn_thư_mục]${NC}"
        echo "Đổi tên tất cả file trong thư mục, lấy phần đầu trước '-', thay dấu cách thành '_'."
        echo "Nếu không nhập đường dẫn, script sẽ dùng thư mục hiện tại."
        return 0
    fi

    # Kiểm tra đường dẫn hợp lệ
    if [[ ! -d "$dir" ]]; then
        echo -e "${RED}Thư mục không tồn tại: $dir${NC}"
        return 2
    fi

    cd "$dir" || { echo -e "${RED}Không thể vào thư mục: $dir${NC}"; return 3; }

    shopt -s nullglob
    for f in *; do
        [[ -f "$f" ]] || continue

        # Lấy phần đầu trước dấu '-'
        newname="${f%%–*}"
        # Nếu không có dấu '-', bỏ qua file này
        if [[ "$newname" == "$f" ]]; then
            echo -e "${YELLOW}File không có dấu '-': $f (bỏ qua)${NC}"
            continue
        fi
        # Thay dấu cách bằng '_'
        newname="$(echo "$newname" | tr ' ' '_')"
        ext="${f##*.}"
        # Nếu file có phần mở rộng
        [[ "$ext" != "$f" ]] && newname="${newname}.${ext}"

        if [[ -e "$newname" ]]; then
            echo -e "${RED}Đã tồn tại: $newname (bỏ qua $f)${NC}"
            continue
        fi

        mv -- "$f" "$newname"
        if [[ $? -eq 0 ]]; then
            echo -e "${GREEN}Đổi tên: $f -> $newname${NC}"
        else
            echo -e "${RED}Lỗi đổi tên: $f${NC}"
        fi
    done
}

# Gọi hàm với tham số đầu vào hoặc mặc định là thư mục hiện tại
rename_files "$@"
