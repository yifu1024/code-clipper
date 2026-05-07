#!/usr/bin/env python3
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont


ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "Assets" / "README"
ICON = ROOT / "Assets" / "CodeClipper.iconset" / "icon_256x256.png"


def font(size, bold=False):
    candidates = [
        "/System/Library/Fonts/PingFang.ttc",
        "/System/Library/Fonts/Supplemental/Arial Unicode.ttf",
        "/System/Library/Fonts/Supplemental/Arial.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size=size, index=1 if bold and path.endswith(".ttc") else 0)
        except OSError:
            continue
    return ImageFont.load_default()


def rounded(draw, rect, radius, fill, outline=None, width=1):
    draw.rounded_rectangle(rect, radius=radius, fill=fill, outline=outline, width=width)


def text(draw, pos, value, size, fill, bold=False, anchor=None):
    draw.text(pos, value, font=font(size, bold), fill=fill, anchor=anchor)


def save(image, name):
    OUT.mkdir(parents=True, exist_ok=True)
    image.save(OUT / name)


def hero():
    w, h = 1400, 720
    image = Image.new("RGB", (w, h), "#eef6ff")
    draw = ImageDraw.Draw(image)
    rounded(draw, (70, 70, w - 70, h - 70), 34, "#ffffff", "#d6e3f3", 2)
    rounded(draw, (90, 90, w - 90, h - 90), 26, "#f7fbff")

    icon = Image.open(ICON).convert("RGBA").resize((180, 180))
    image.paste(icon, (150, 150), icon)

    text(draw, (380, 155), "CodeClipper", 70, "#172033", True)
    text(draw, (384, 250), "自动读取信息验证码，复制后按秒恢复剪贴板", 34, "#415168")
    text(draw, (384, 315), "菜单栏常驻 · 正则规则 · 通知提醒 · DMG 拖拽安装", 26, "#6b7c93")

    rounded(draw, (384, 410, 690, 485), 18, "#1f7ae0")
    text(draw, (537, 448), "下载 CodeClipper.dmg", 26, "#ffffff", True, "mm")
    rounded(draw, (720, 410, 990, 485), 18, "#edf4fb", "#c6d7ea", 2)
    text(draw, (855, 448), "授予完全磁盘访问", 26, "#26364d", True, "mm")

    for i, label in enumerate(["1. 收到验证码", "2. 自动复制", "3. 定时恢复"]):
        x = 170 + i * 360
        rounded(draw, (x, 560, x + 280, 620), 18, "#e7f2ff")
        text(draw, (x + 140, 590), label, 24, "#1f5f9f", True, "mm")

    save(image, "hero.png")


def install():
    w, h = 1400, 820
    image = Image.new("RGB", (w, h), "#f4f6f8")
    draw = ImageDraw.Draw(image)
    rounded(draw, (120, 80, 1280, 740), 28, "#ffffff", "#d7dee8", 2)
    rounded(draw, (120, 80, 1280, 130), 28, "#edf1f5")
    text(draw, (700, 105), "CodeClipper.dmg", 24, "#344054", True, "mm")

    icon = Image.open(ICON).convert("RGBA").resize((150, 150))
    image.paste(icon, (330, 305), icon)
    text(draw, (405, 485), "CodeClipper.app", 28, "#172033", True, "mm")

    rounded(draw, (835, 300, 1015, 470), 36, "#eaf3ff", "#adc8e8", 2)
    text(draw, (925, 356), "A", 76, "#1f7ae0", True, "mm")
    text(draw, (925, 485), "Applications", 28, "#172033", True, "mm")

    draw.line((540, 385, 780, 385), fill="#1f7ae0", width=8)
    draw.polygon([(780, 385), (740, 360), (740, 410)], fill="#1f7ae0")
    text(draw, (660, 335), "拖动安装", 32, "#1f5f9f", True, "mm")

    text(draw, (700, 640), "双击 DMG 后，把 App 拖到 Applications 即可像普通应用一样安装。", 30, "#5d6b7c", anchor="mm")
    save(image, "install.png")


def settings():
    w, h = 1400, 1040
    image = Image.new("RGB", (w, h), "#eef2f7")
    draw = ImageDraw.Draw(image)
    rounded(draw, (90, 70, 1310, 970), 24, "#ffffff", "#d3dbe7", 2)
    rounded(draw, (90, 70, 330, 970), 24, "#f0f4f8")

    for x, c in [(125, "#ff5f57"), (150, "#febc2e"), (175, "#28c840")]:
        draw.ellipse((x, 100, x + 16, 116), fill=c)

    sidebar = [("状态", "●"), ("匹配规则", "⌕"), ("剪贴板", "▣"), ("权限", "✓")]
    for i, (label, symbol) in enumerate(sidebar):
        y = 170 + i * 62
        if label == "剪贴板":
            rounded(draw, (115, y - 18, 305, y + 34), 12, "#dcecff")
        text(draw, (135, y + 7), symbol, 22, "#3978c4", anchor="lm")
        text(draw, (175, y + 7), label, 24, "#26364d", True if label == "剪贴板" else False, "lm")

    text(draw, (390, 130), "剪贴板", 42, "#172033", True)
    sections = [
        ("监听", [("启动后自动监听", "开启"), ("开机自动启动", "开启"), ("扫描间隔", "3 秒")]),
        ("剪贴板", [("恢复剪贴板内容", "90 秒后"), ("复制后发送通知", "开启")]),
        ("权限", [("信息数据库", "已授权"), ("安装位置", "/Applications/CodeClipper.app")]),
    ]

    y = 205
    for title, rows in sections:
        text(draw, (390, y), title, 25, "#344054", True)
        y += 24
        rounded(draw, (390, y, 1210, y + 68 * len(rows) + 20), 18, "#f8fafc", "#dce3ec", 2)
        for i, (left, right) in enumerate(rows):
            row_y = y + 28 + i * 68
            text(draw, (430, row_y), left, 24, "#172033", anchor="lm")
            pill_color = "#e8f6ef" if right == "开启" or right == "已授权" else "#eef4fb"
            rounded(draw, (955, row_y - 21, 1170, row_y + 21), 14, pill_color)
            text(draw, (1062, row_y), right, 22, "#276749" if pill_color == "#e8f6ef" else "#42526b", True, "mm")
        y += 68 * len(rows) + 70

    text(draw, (800, 940), "支持规则配置、通知提醒、权限检测和定时恢复剪贴板。", 26, "#667085", anchor="mm")
    save(image, "settings.png")


if __name__ == "__main__":
    hero()
    install()
    settings()
    print(OUT)
