"""
Genere le code QR du lien de telechargement de l'application.

Utilisation :
    pip install "qrcode[pil]"
    python tools/make_qr.py https://github.com/VOTRE-NOM/wassaly-app/releases/latest/download/wassaly.apk

Cree wassaly_qr.png (a imprimer, 4 cm minimum de cote). C'est un QR "statique" :
le lien est ecrit dedans, il ne expire jamais et ne depend d'aucun service payant.
Testez-le avec 2 ou 3 telephones avant d'imprimer.
"""
import sys

import qrcode
from qrcode.constants import ERROR_CORRECT_H

if len(sys.argv) < 2:
    sys.exit(__doc__)

url = sys.argv[1]
out = sys.argv[2] if len(sys.argv) > 2 else "wassaly_qr.png"

qr = qrcode.QRCode(error_correction=ERROR_CORRECT_H, box_size=24, border=4)
qr.add_data(url)
qr.make(fit=True)
qr.make_image(fill_color="#0B1F4D", back_color="white").save(out)
print(f"QR cree : {out}\nLien : {url}")
