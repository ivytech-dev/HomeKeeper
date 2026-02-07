#!/bin/bash
# 1024x1024 の元画像から macOS アプリアイコン全サイズを生成するスクリプト
# 使い方: ./generate_icons.sh <元画像.png>

SOURCE="$1"
if [ -z "$SOURCE" ] || [ ! -f "$SOURCE" ]; then
    echo "使い方: $0 <1024x1024の元画像.png>"
    exit 1
fi

DEST="MyAssetSheet/Assets.xcassets/AppIcon.appiconset"

# 既存のアイコンファイルを削除（Contents.json は残す）
find "$DEST" -name "*.png" -delete

# 各サイズを生成
for size in 16 32 128 256 512; do
    sips -z $size $size "$SOURCE" --out "$DEST/icon_${size}x${size}.png" >/dev/null 2>&1
    double=$((size * 2))
    sips -z $double $double "$SOURCE" --out "$DEST/icon_${size}x${size}@2x.png" >/dev/null 2>&1
done

echo "生成完了:"
ls -la "$DEST"/icon_*.png
