#!/usr/bin/env bash
set -e

# Colors
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}================================================================${NC}"
echo -e "${CYAN}        🕌  Deen — Islamic Companion for iPhone Installer         ${NC}"
echo -e "${CYAN}               Linux Ubuntu Official Sideload Tool              ${NC}"
echo -e "${CYAN}================================================================${NC}"
echo ""

# 1. Check usbmuxd
echo -e "${YELLOW}[1/4] Checking iPhone USB connection...${NC}"
if ! systemctl is-active --quiet usbmuxd; then
    echo -e "${RED}usbmuxd is not running. Starting usbmuxd service...${NC}"
    echo "0504630528" | sudo -S systemctl start usbmuxd
fi

# 2. Check connected device
DEVICE_UDID=$(idevice_id -l 2>/dev/null | head -n 1)

if [ -z "$DEVICE_UDID" ]; then
    echo -e "${RED}❌ No iPhone detected over USB!${NC}"
    echo -e "${YELLOW}Please connect your iPhone via USB cable to this PC, unlock your screen, and tap 'Trust This Computer'.${NC}"
    exit 1
fi

DEVICE_NAME=$(ideviceinfo -k DeviceName 2>/dev/null || echo "iPhone")
DEVICE_MODEL=$(ideviceinfo -k ProductType 2>/dev/null || echo "iPhone")
IOS_VERSION=$(ideviceinfo -k ProductVersion 2>/dev/null || echo "Unknown")

echo -e "${GREEN}✓ Connected iPhone detected:${NC}"
echo -e "  • Name:    ${CYAN}$DEVICE_NAME${NC}"
echo -e "  • Model:   ${CYAN}$DEVICE_MODEL${NC}"
echo -e "  • iOS:     ${CYAN}$IOS_VERSION${NC}"
echo -e "  • UDID:    ${CYAN}$DEVICE_UDID${NC}"
echo ""

# 3. Check pairing status
echo -e "${YELLOW}[2/4] Validating Device Pairing Trust...${NC}"
PAIR_STATUS=$(idevicepair validate 2>&1 || true)
if [[ "$PAIR_STATUS" == *"SUCCESS"* ]]; then
    echo -e "${GREEN}✓ iPhone is successfully paired and trusted!${NC}"
else
    echo -e "${YELLOW}Attempting to pair with iPhone... Unlock your phone screen and tap 'Trust'!${NC}"
    idevicepair pair || true
fi
echo ""

# 4. Verify IPA exists
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IPA_PATH="$SCRIPT_DIR/IslamicCompanion.ipa"

echo -e "${YELLOW}[3/4] Checking App Package (IslamicCompanion.ipa)...${NC}"
if [ ! -f "$IPA_PATH" ]; then
    echo -e "${YELLOW}Downloading latest release from GitHub...${NC}"
    gh release download v1.0.0 --pattern "*.ipa" --dir "$SCRIPT_DIR" --clobber
fi

echo -e "${GREEN}✓ Package ready at: ${CYAN}$IPA_PATH${NC} ($(ls -lh "$IPA_PATH" | awk '{print $5}'))"
echo ""

# 5. Launch iLoader Sideload Tool
echo -e "${YELLOW}[4/4] Launching iLoader Sideload Tool for Linux...${NC}"
ILOADER_BIN="$SCRIPT_DIR/tools/squashfs-root/AppRun"

if [ ! -f "$ILOADER_BIN" ]; then
    echo -e "${YELLOW}Extracting iLoader AppImage...${NC}"
    (cd "$SCRIPT_DIR/tools" && ./iloader.AppImage --appimage-extract)
fi

echo -e "${GREEN}================================================================${NC}"
echo -e "${GREEN}  🎉 Starting iLoader GUI (Native Linux Sideloading Tool)        ${NC}"
echo -e "${GREEN}================================================================${NC}"
echo ""
echo -e "${CYAN}خطوات التثبيت السريعة في 30 ثانية:${NC}"
echo -e " 1. ستفتح لك الآن نافذة أداة ${YELLOW}iLoader${NC} على الشاشة."
echo -e " 2. سجل الدخول بـ ${YELLOW}Apple ID${NC} الخاص بك (حساب آبل المجاني المعتاد)."
echo -e " 3. اسحب ملف ${YELLOW}$IPA_PATH${NC} وأفلته داخل iLoader أو اضغط Browse وحدده."
echo -e " 4. اضغط ${GREEN}Install${NC} — سيتم توقيع التطبيق وتثبيته فوراً على هاتفك!"
echo ""
echo -e "${CYAN}تفعيل التطبيق على الآيفون بعد التثبيت:${NC}"
echo -e " • اذهب في الآيفون إلى: ${YELLOW}الإعدادات (Settings) -> عام (General) -> إدارة الأجهزة (VPN & Device Management)${NC}"
echo -e " • اضغط على بريدك (Apple ID) ثم اضغط ${GREEN}وثوق (Trust)${NC}."
echo -e " • إذا طلب منك Developer Mode: اذهب إلى ${YELLOW}الخصوصية والأمن (Privacy & Security) -> نمط المطور (Developer Mode)${NC} وفعّله وسيعيد تشغيل الجهاز."
echo ""
echo -e "${GREEN}جاري تشغيل iLoader الآن...${NC}"

exec "$ILOADER_BIN"
