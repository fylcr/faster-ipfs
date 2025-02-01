#!/bin/bash

if [ $# -ne 2 ]; then
    echo "用法: $0 <文件名> <分片大小>"
    exit 1
fi

input_file="$1"
split_size="$2"

if [ ! -f "$input_file" ]; then
    echo "错误: 输入文件 $input_file 不存在。"
    exit 1
fi

split_size=$(echo "$split_size" | tr '[:lower:]' '[:upper:]')

dir=$(dirname -- "$input_file")
filename=$(basename -- "$input_file")

if [[ "$filename" =~ \. ]]; then
    extension="${filename##*.}"
    base="${filename%.*}"
else
    extension=""
    base="$filename"
fi

output_dir="$dir/output"
mkdir -p -- "$output_dir"

split_args=()
[ -n "$extension" ] && split_args+=(--additional-suffix=".$extension")

# 修改1: 使用足够大的后缀位数（如6位）
if ! split -d -a 7 "${split_args[@]}" -b "$split_size" -- "$input_file" "$output_dir/${base}_"; then
    echo "错误: 文件分割失败。"
    exit 1
fi

# 修改2: 自动去除前导零的数值转换
for file in "$output_dir/${base}_"*; do
    filename_part=$(basename -- "$file")
    suffix=${filename_part#"${base}_"}
    
    if [ -n "$extension" ]; then
        suffix=${suffix%".$extension"}
        if [[ "$suffix" =~ ^[0-9]+$ ]]; then
            new_num=$((10#$suffix + 1))        # 转为十进制数并+1
            new_suffix=$new_num                # 直接使用自然数格式
            new_file="$output_dir/${base}_${new_suffix}.$extension"
            mv -- "$file" "$new_file"
        fi
    else
        if [[ "$suffix" =~ ^[0-9]+$ ]]; then
            new_num=$((10#$suffix + 1))
            new_suffix=$new_num
            new_file="$output_dir/${base}_$new_suffix"
            mv -- "$file" "$new_file"
        fi
    fi
done

echo "文件分割完成。输出目录: $output_dir"
