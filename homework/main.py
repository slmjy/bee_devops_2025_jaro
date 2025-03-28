import sys
from flask import Flask, send_file

app = Flask(__name__)

@app.route("/")
def index():
    return send_file("index.html")


if "--help" in sys.argv:
    print("📝 Nápověda:")
    print("  --run       Spustí hlavní aplikaci")
    print("  --debug     Spustí aplikaci v debug módu")
    print("  --test      Spustí testovací režim")
    print("  --help      Zobrazí tuto nápovědu")

elif "--version" in sys.argv:
    print("📦 Verze aplikace: 1.0.0")

elif "--test" in sys.argv:
    print("🧪 Testovací režim spuštěn!")

elif "--debug" in sys.argv:
    print("🚧 Spouštím Flask v debug módu...")
    app.run(host="0.0.0.0", port=80, debug=True)

elif "--run" in sys.argv:
    print("🚀 Spouštím aplikaci...")
    app.run(host="0.0.0.0", port=80)

else:
    print("✅ Aplikace běží!")


