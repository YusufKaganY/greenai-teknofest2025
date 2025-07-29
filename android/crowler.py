import os
import re
import time
import requests
import pyodbc
from urllib.parse import urljoin, urlparse
from selenium import webdriver
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.chrome.service import Service
from webdriver_manager.chrome import ChromeDriverManager
from bs4 import BeautifulSoup
import hashlib

IMAGE_DIR = "assets/denemeCrowler"
os.makedirs(IMAGE_DIR, exist_ok=True)

def get_db_connection():
    try:
        conn = pyodbc.connect(
            'DRIVER={DRIVER NAME};'
            'SERVER=localhost;'
            'DATABASE=YOUR DATABASE NAME;'
            'Trusted_Connection=yes'
        )
        print("✅ Database connection established.")
        return conn
    except pyodbc.Error as e:
        print("❌ Database connection error:", str(e))
        return None

def site_geri_donusum_icin_mi(soup):
    anahtar_kelimeler = ['geri dönüşüm', 'recycling', 'sürdürülebilir', 'atık', 'çevre', 'yeniden kullanım', 'ekolojik']
    icerik = soup.get_text().lower()
    return any(k in icerik for k in anahtar_kelimeler)

def dosya_adi_olustur(url):
    uzanti = os.path.splitext(urlparse(url).path)[1]
    hash_object = hashlib.md5(url.encode('utf-8'))
    dosya_adi = hash_object.hexdigest() + uzanti
    return dosya_adi

def goruntu_indir(resim_url, kaynak_url):
    try:
        if not resim_url.startswith('http'):
            resim_url = urljoin(kaynak_url, resim_url)

        dosya_adi = dosya_adi_olustur(resim_url)
        dosya_yolu = os.path.join(IMAGE_DIR, dosya_adi)

        if not os.path.exists(dosya_yolu):
            response = requests.get(resim_url, timeout=10)
            response.raise_for_status()
            with open(dosya_yolu, 'wb') as f:
                f.write(response.content)
            print(f"✅ Görsel indirildi: {dosya_adi}")
        else:
            print(f"ℹ️ Görsel zaten var: {dosya_adi}")

   
        return f"/{IMAGE_DIR}/{dosya_adi}"
    except Exception as e:
        print(f"❌ Görsel indirilemedi: {e}")
        return None

def proje_fikirlerini_cek(soup, kaynak_url, conn):
    cursor = conn.cursor()
    headings = soup.find_all(['h1', 'h2', 'h3', 'h4', 'h5', 'h6'])

    for heading in headings:
        baslik_text = heading.get_text(strip=True)
        if not re.match(r'^\d+\.', baslik_text):
            continue
        baslik_text = re.sub(r'^\d+\.\s*', '', baslik_text)

        aciklama_cumleleri = []

        sib = heading.find_next_sibling()
        while sib:
            if sib.name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
                break
            if sib.name == 'p':
                text = sib.get_text(strip=True)
                if text:
                    aciklama_cumleleri.append(text)
            if sib.name in ['ul', 'ol']:
                for li in sib.find_all('li'):
                    aciklama_cumleleri.append(li.get_text(strip=True))
            sib = sib.find_next_sibling()

        if not aciklama_cumleleri:
            continue

        adimlar = '\n'.join([f"- {cumle}" for cumle in aciklama_cumleleri])

        imgs = []
  
        sib = heading.find_next_sibling()
        while sib:
            if sib.name in ['h1', 'h2', 'h3', 'h4', 'h5', 'h6']:
                break
            imgs += sib.find_all('img')
            sib = sib.find_next_sibling()

        if not imgs:
            imgs = heading.parent.find_all('img')

        if not imgs:
            image_paths = [None]
        else:
            image_paths = []
            for img in imgs:
                src = img.get('src') or img.get('data-src')
                if src:
                    path = goruntu_indir(src, kaynak_url)
                    if path:
                        image_paths.append(path)
            if not image_paths:
                image_paths = [None]

        for image_path in image_paths:
            sql = """
            INSERT INTO Deneme 
            (Baslik, Aciklama, ResimUrl, Adimlar, Kaynak, ZorlukDerecesi, Sure, Malzemeler)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            """
            try:
                cursor.execute(sql, (
                    baslik_text,
                    baslik_text,
                    image_path,
                    adimlar,
                    kaynak_url,
                    'Bilinmiyor',
                    'Bilinmiyor',
                    ''
                ))
                conn.commit()
                print(f"✅ Kaydedildi: {baslik_text} - {image_path}")
            except Exception as e:
                print(f"❌ Veritabanına kaydedilemedi ({baslik_text}): {e}")

def sayfayi_isle(driver, url, domain, ziyaret_edilenler, conn):
    if url in ziyaret_edilenler:
        return
    print(f"\n>>> Sayfa işleniyor: {url}")
    ziyaret_edilenler.add(url)

    try:
        driver.get(url)
        time.sleep(3)
        html = driver.page_source
        soup = BeautifulSoup(html, "html.parser")
    except Exception as e:
        print(f"❌ Sayfa alınamadı: {e}")
        return

    if site_geri_donusum_icin_mi(soup):
        print("✅ Geri dönüşümle ilgili içerik bulundu.")
        proje_fikirlerini_cek(soup, url, conn)
    else:
        print("❌ Geri dönüşümle ilgili içerik yok.")
        return

    for a in soup.find_all('a', href=True):
        tam_link = urljoin(url, a['href'])
        parsed_url = urlparse(tam_link)
        if domain in parsed_url.netloc and tam_link not in ziyaret_edilenler:
            sayfayi_isle(driver, tam_link, domain, ziyaret_edilenler, conn)

chrome_options = Options()
chrome_options.add_argument('--ignore-certificate-errors')
chrome_options.add_argument('--ignore-ssl-errors')
chrome_options.add_argument('--headless')
chrome_options.add_argument('--disable-gpu')

service = Service(ChromeDriverManager().install())
driver = webdriver.Chrome(service=service, options=chrome_options)

conn = get_db_connection()
if conn:
    baslangic_url = "https://www.dogtas.com/en/blog-geri-donusum-fikirleri"
    domain = urlparse(baslangic_url).netloc
    ziyaret_edilenler = set()
    sayfayi_isle(driver, baslangic_url, domain, ziyaret_edilenler, conn)
    conn.close()

driver.quit()
