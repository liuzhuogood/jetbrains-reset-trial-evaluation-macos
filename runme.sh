#!/bin/bash

if [ "$1" = "--prepare-env" ]; then
  DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
  mkdir -p ~/Scripts

  echo "Copying the script to $HOME/Scripts"
  cp -rf "$DIR/runme.sh" ~/Scripts/jetbrains-reset.sh
  chmod +x ~/Scripts/jetbrains-reset.sh

  echo
  echo "Copying com.jetbrains.reset.plist to $HOME/Library/LaunchAgents"
  cp -rf "$DIR/com.jetbrains.reset.plist" ~/Library/LaunchAgents

  echo
  echo "Loading job into launchctl"
  launchctl load ~/Library/LaunchAgents/com.jetbrains.reset.plist

  echo
  echo "That's it, enjoy ;)"
  exit 0
fi

if [ "$1" = "--launch-agent" ]; then
  PROCESS=(idea webstorm datagrip phpstorm clion pycharm goland rubymine rider)
  COMMAND_PRE=("${PROCESS[@]/#/MacOS/}")

  echo "Killing JetBrains processes..."
  kill -9 $(ps aux | egrep $(IFS='|'; echo "${COMMAND_PRE[*]}") | awk '{print $2}') 2>/dev/null
fi

# Reset Intellij evaluation
for product in IntelliJIdea WebStorm DataGrip PhpStorm CLion PyCharm GoLand RubyMine Rider; do
  echo "Resetting trial period for $product"

  # Remove evaluation key
  rm -rf ~/Library/Application\ Support/JetBrains/$product*/eval/*.key

  # Remove 'evlsprt' flags from options XML
  sed -i '' '/evlsprt/d' ~/Library/Application\ Support/JetBrains/$product*/options/other.xml

  echo
done

echo "Removing additional plist files..."
rm -f ~/Library/Preferences/com.apple.java.util.prefs.plist
rm -f ~/Library/Preferences/com.jetbrains.*.plist
rm -f ~/Library/Preferences/jetbrains.*.*.plist

for f in ~/Library/Preferences/jetbrains.*.plist; do
  if [[ -f $f ]]; then
    fn=${f##*/}; key=${fn%.plist}
    echo "Deleting preference $key and file $f"
    defaults delete "${key}" 2>/dev/null && rm "$f"
  fi
done

echo "Removing Java user preferences..."
rm -rf ~/.java/.userPrefs
rm -rf ~/.java/.userPrefs/com/jetbrains

echo "Removing macOS sandbox cache entries..."
find /private/var/folders/ -type d -name '*JetBrains*' -exec rm -rf {} + 2>/dev/null

echo "Force deleting JetBrains cached application support..."
rm -rf ~/Library/Application\ Support/JetBrains/*/eval
rm -rf ~/Library/Application\ Support/JetBrains/*/options/other.xml

echo "Force deleting JetBrains cached plist entries..."
defaults delete com.jetbrains 2>/dev/null

echo "Clearing JetBrains account data, logs, cache..."
# rm -rf ~/.config/JetBrains
# rm -rf ~/.local/share/JetBrains
# rm -rf ~/Library/Caches/JetBrains   
# rm -rf ~/Library/Logs/JetBrains
# rm -rf ~/Library/Application\ Support/JetBrains
# rm -rf ~/Library/Preferences/JetBrains

echo "Removing JetBrains Toolbox remnants..."
rm -rf ~/Library/Application\ Support/JetBrains/Toolbox
rm -rf ~/.local/share/JetBrains/Toolbox
rm -rf ~/.config/JetBrains/Toolbox
rm -rf ~/Library/Preferences/Toolbox

echo
echo "🔒 建议手动编辑 /etc/hosts 文件添加以下内容以屏蔽联网验证："
echo "127.0.0.1 account.jetbrains.com"
echo "127.0.0.1 www.jetbrains.com"
echo "127.0.0.1 plugins.jetbrains.com"
echo
echo "执行命令: sudo nano /etc/hosts"

echo
echo "✅ JetBrains 清理完成。重启系统以彻底生效。"