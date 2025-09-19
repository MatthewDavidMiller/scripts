import os
import sys
import subprocess
import csv
from datetime import datetime
from io import BytesIO

# Script saves large emails as pdfs, not including the attachments.
# Original email then moved to trash.

# 🛠️ Ensure required packages are installed locally
def install_and_import(package_name, import_name=None):
    import_name = import_name or package_name.replace('-', '_')
    try:
        __import__(import_name)
    except ImportError:
        subprocess.check_call([sys.executable, '-m', 'pip', 'install', '--user', package_name])
        globals()[import_name] = __import__(import_name)

install_and_import('imap-tools', 'imap_tools')
install_and_import('xhtml2pdf')
install_and_import('beautifulsoup4', 'bs4')

from imap_tools import MailBox, AND
from xhtml2pdf import pisa
from bs4 import BeautifulSoup

# 📧 Configuration
EMAIL = 'your_email@gmail.com'  # Replace with your Gmail address
PASSWORD = 'your_app_password'  # Use an App Password if 2FA is enabled
ATTACHMENT_SIZE_MB = 5
OUTPUT_FOLDER = 'saved_emails'
LOG_FILE = 'processed_emails.csv'

# 🗓️ Date range filter
start_date = datetime(2025, 9, 12).date()
end_date = datetime(2025, 9, 19).date()

# 📁 Ensure output folder exists
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# 📄 Load processed UIDs from log
processed_uids = set()
if os.path.exists(LOG_FILE):
    with open(LOG_FILE, newline='', encoding='utf-8') as f:
        reader = csv.reader(f)
        processed_uids = {row[0] for row in reader}

# 📬 Connect to Gmail
with MailBox('imap.gmail.com').login(EMAIL, PASSWORD, initial_folder='INBOX') as mailbox:
    messages = mailbox.fetch(AND(date_gte=start_date, date_lt=end_date), bulk=True)

    with open(LOG_FILE, 'a', newline='', encoding='utf-8') as log:
        writer = csv.writer(log)

        for msg in messages:
            if str(msg.uid) in processed_uids:
                continue  # Skip already processed

            if not msg.attachments:
                continue

            total_size = sum(len(att.payload) for att in msg.attachments)
            if total_size < ATTACHMENT_SIZE_MB * 1024 * 1024:
                continue

            # 🗓️ Format date and sanitize subject
            date_str = msg.date.strftime('%Y_%m_%d')
            subject = msg.subject or 'No_Subject'
            clean_subject = ''.join(c for c in subject if c.isalnum() or c in (' ', '_')).strip()
            filename = f"{clean_subject}_{date_str}_{msg.uid}.pdf"
            filepath = os.path.join(OUTPUT_FOLDER, filename)

            # 🖼️ Build full HTML content
            raw_html = msg.html or f"<pre>{msg.text}</pre>"

            # 🧼 Preprocess layout to flatten side-by-side elements
            soup = BeautifulSoup(raw_html, 'html.parser')
            for tag in soup.find_all(['table', 'div']):
                style = tag.get('style', '')
                style = style.replace('display:inline-block', '')
                style = style.replace('float:left', '')
                style = style.replace('float:right', '')
                style = style.replace('width:48%', 'width:100%')
                style = style.replace('width:50%', 'width:100%')
                tag['style'] = style
            html_content = str(soup)

            header = f"""
            <p><strong>From:</strong> {msg.from_}<br>
            <strong>To:</strong> {msg.to}<br>
            <strong>CC:</strong> {msg.cc}<br>
            <strong>Date:</strong> {msg.date}<br>
            <strong>Subject:</strong> {msg.subject}</p><hr>
            """

            full_html = f"""
            <html>
            <head>
            <style>
            body {{ font-family: Arial; font-size: 12px; }}
            table {{ width: 100%; border-collapse: collapse; table-layout: fixed; word-wrap: break-word; }}
            td, th {{ border: 1px solid #ccc; padding: 5px; vertical-align: top; }}
            pre {{ white-space: pre-wrap; word-wrap: break-word; }}
            </style>
            </head>
            <body>
            {header}
            {html_content}
            </body>
            </html>
            """

            # 💾 Save PDF using xhtml2pdf
            try:
                with open(filepath, "wb") as pdf_file:
                    pisa.CreatePDF(BytesIO(full_html.encode("utf-8")), dest=pdf_file)
            except Exception as e:
                print(f"❌ PDF generation failed for UID {msg.uid}: {e}")
                continue

            # 🗑️ Move to Trash
            mailbox.move(msg.uid, '[Gmail]/Trash')

            # 🧾 Log UID
            writer.writerow([msg.uid, filename, msg.from_, msg.date])

print("✅ Done: Saved cleaned PDFs, moved originals to Trash, and logged processed emails.")
