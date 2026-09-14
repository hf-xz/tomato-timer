# TODO

## 应用图标

`build-app.sh` 与 `Info.plist` 的图标 wiring 已就绪，只差图标文件。

### 要做的事

1. 准备一张 1024×1024 的 PNG（如 `icon.png`）。
2. 在仓库根目录执行以下命令生成 `.icns`：
   ```bash
   mkdir AppIcon.iconset
   for s in 16 32 128 256 512; do
     sips -z $s $s icon.png --out AppIcon.iconset/icon_${s}x${s}.png
     sips -z $((s*2)) $((s*2)) icon.png --out AppIcon.iconset/icon_${s}x${s}@2x.png
   done
   cp icon.png AppIcon.iconset/icon_512x512@2x.png
   iconutil -c icns AppIcon.iconset -o Resources/AppIcon.icns
   ```
3. 确认文件就位：`Resources/AppIcon.icns`（文件名必须叫 `AppIcon.icns`，格式 `.icns`）。
4. 重建并运行：
   ```bash
   bash scripts/build-app.sh && open dist/TomatoTimer.app
   ```
5. 若 Finder / 系统设置里仍显示旧图标，刷新 LaunchServices 缓存：
   ```bash
   /System/Library/Frameworks/CoreServices.framework/Versions/A/Frameworks/LaunchServices.framework/Versions/A/Support/lsregister -f dist/TomatoTimer.app
   ```

### 相关配置（已改好，无需再动）

- `scripts/build-app.sh`：签名前把 `Resources/AppIcon.icns` 拷到 `Contents/Resources/`（文件不存在时自动跳过）。
- `Info.plist`：`CFBundleIconFile = AppIcon`（值不带扩展名，已绑定进签名）。
