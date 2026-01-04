# flutter build apk \
#   --obfuscate \
#   --split-debug-info=./symbols \
#   --target-platform android-arm64 \
#   --split-per-abi


# Полная release-сборка Android с максимальной обфускацией
# flutter build appbundle --release --obfuscate --split-debug-info=./symbols

# То же самое для APK (если всё ещё нужен)
# flutter build apk --release --obfuscate --split-debug-info=./symbols --split-per-abi

# iOS
# flutter build ipa --release --obfuscate --split-debug-info=./symbols


flutter build apk --release --obfuscate --split-debug-info=./symbols --split-per-abi

# flutter build appbundle \                                                           
#   --release \
#   --obfuscate \
#   --split-debug-info=./build/app/outputs/symbols \
#   --no-tree-shake-icons