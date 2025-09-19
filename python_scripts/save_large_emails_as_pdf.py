import os
import sys
import subprocess
import csv
from datetime import datetime

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
install_and_import('fpdf')

from imap_tools import MailBox, AND
from fpdf import FPDF

# 📧 Configuration
EMAIL = 'your_email@gmail.com'  # Replace with your Gmail address
PASSWORD = 'your_app_password'  # Use an App Password if 2FA is enabled
ATTACHMENT_SIZE_MB = 5
OUTPUT_FOLDER = 'saved_emails'
LOG_FILE = 'processed_emails.csv'

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
    messages = mailbox.fetch(bulk=True)

    with open(LOG_FILE, 'a', newline='', encoding='utf-8') as log:
        writer = csv.writer(log)

        for msg in messages:
            if str(msg.uid) in processed_uids:
                continue  # Skip already processed

            total_size = sum(len(att.payload) for att in msg.attachments)
            if total_size < ATTACHMENT_SIZE_MB * 1024 * 1024:
                continue

            # 🗓️ Format date and sanitize subject
            date_str = msg.date.strftime('%Y_%m_%d')
            subject = msg.subject or 'No_Subject'
            clean_subject = ''.join(c for c in subject if c.isalnum() or c in (' ', '_')).strip()
            filename = f"{clean_subject}_{date_str}_{msg.uid}.pdf"

            # 📄 Create PDF
            pdf = FPDF()
            pdf.add_page()
            pdf.set_auto_page_break(auto=True, margin=15)
            pdf.set_font("Arial", size=12)

            # Prefer plain text to avoid rendering issues
            content = msg.text or '[No content]'
            header = f"From: {msg.from_}\nTo: {msg.to}\nCC: {msg.cc}\nDate: {msg.date}\nSubject: {msg.subject}\n\n"
            pdf.multi_cell(0, 10, header + content)

            # 💾 Save PDF
            pdf.output(os.path.join(OUTPUT_FOLDER, filename))

            # 🗑️ Move to Trash
            mailbox.move(msg.uid, '[Gmail]/Trash')

            # 🧾 Log UID
            writer.writerow([msg.uid, filename, msg.from_, msg.date])

print("✅ Done: Saved PDFs, moved originals to Trash, and logged processed emails.")
