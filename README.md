# TÜBİTAK 2242 Üniversite Öğrencileri Araştırma Proje Yarışması 2025 <br> Kategori: Enerji ve Çevre - TEKNOFEST

## **Proje Hakkında**
> Bu proje, **TÜBİTAK 2242 Üniversite Öğrencileri Araştırma Proje Yarışması**'nda **Enerji ve Çevre** kategorisinde **Türkiye genelinde ilk 10'a** girerek büyük başarı elde etmiştir.  

> Bu Flutter projesi, çevre bilincini artırmak ve sürdürülebilirliği desteklemek amacıyla geliştirilmiş yenilikçi bir mobil uygulamadır. Kullanıcılar, evdeki atıklarıyla yapabilecekleri yaratıcı geri dönüşüm projelerini keşfedebilir, yapay zeka desteğiyle görsel yükleyip atık türünü öğrenebilir ve Türkiye genelindeki geri dönüşüm noktalarını harita üzerinde görüntüleyebilir.

> Uygulama, Python ile geliştirilen bir Selenium botu sayesinde internet üzerindeki geri dönüşüm içeriklerini otomatik olarak tarar ve SQL Server veritabanına kaydeder. Ardından, Flutter uygulaması bu verileri çekerek kullanıcıya sunar.

> Buna ek olarak, kullanıcıların yüklediği atık görselleri **yapay zeka tabanlı bir sınıflandırma modeli** tarafından analiz edilerek türleri tahmin edilir ve uygun proje önerileri otomatik olarak gösterilir.

---
### Takım Hakkında
- **Takım Adı**: GreenAI
- **Takım Kaptanı**: Senanur Topal
- **Takım Üyesi**: Yusuf Kağan Yıldırım


## Öne Çıkan Özellikler

### İl Bazlı Geri Dönüşüm Noktaları

- Türkiye’deki şehir bazında geri dönüşüm noktaları harita üzerinde gösterilir.
- Noktalar hakkında temel bilgiler sağlanır. (adres, kurum adı vb.)

### Görsel Tanıma ve Sınıflandırma

- Kullanıcı, uygulamaya bir atık görseli yükleyebilir. (örneğin: plastik şişe)
- Görsel, yapay zeka modeli tarafından analiz edilerek atık türü belirlenir.
- Tahmin sonucu kullanıcıya sunulur.

### Akıllı Proje Önerisi

- Yapay zekanın tahmin ettiği atık türüne göre, ilgili projeler önerilir.
- Kullanıcı uygun olan projeye yönlendirilir.
- Projeler, kategori sekmeleriyle gösterilir. (Plastik, Kağıt, Cam ...)
- Dilerse tüm projeleri tek listede görebilir.

### Otomatik Veri Çekimi (Python Bot)

- Selenium botu, belirlenen geri dönüşüm sitelerini tarar.
- Proje başlığı, açıklama, adımlar, malzeme listesi ve görsel URL’si alınır.
- Görseller proje klasörüne kaydedilir. (`/assets/denemeCrowler/`)

---

## Projeyi Çalıştırma

### 1. Python Backend (`app2.py`) çalıştırma

Terminal veya VSCode terminalinde projenin Python dosyasının olduğu klasöre gidin:

```bash
cd /path/to/python/app
python app2.py
```
### 2. Flutter Frontend (`main.dart`) çalıştırma
Terminal veya VSCode terminalinde Flutter projesinin kök dizinine gidin:

```bash
cd /path/to/flutter/project
flutter run
```
---



## English Version

# TÜBİTAK 2242 University Student Research Project Competition 2025 <br> Category: Energy & Environment – TEKNOFEST

## **About the Project**
> This project achieved great success by ranking **among the top 10 in Turkey** in the **Energy and Environment** category of the **TÜBİTAK 2242 University Students Research Project Competition**.

> This Flutter project is an innovative mobile application developed to raise environmental awareness and support sustainability. Users can explore creative recycling projects they can do at home using waste materials, upload images to identify the type of waste with the help of artificial intelligence, and view recycling points across Turkey on an interactive map.

> The project includes a Python-based Selenium bot that automatically scrapes recycling-related content from various websites and stores it in a SQL Server database. The Flutter app then retrieves this data and displays it to the user.

> In addition, an **image classification model powered by artificial intelligence** analyzes the uploaded photos to determine the waste type and offers relevant project suggestions accordingly.

---

### Team Information
- **Team Name**: GreenAI  
- **Team Leader**: Senanur Topal  
- **Team Member**: Yusuf Kağan Yıldırım  

---

## Key Features

### City-Based Recycling Point Map
- Displays recycling points across Turkish cities on an interactive map.
- Provides basic info for each point (address, organization name, etc.).

### Image Recognition & Classification
- Users can upload an image (e.g., a plastic bottle).
- AI model predicts the type of waste based on the image.
- The predicted result is shown to the user.

### Smart Project Suggestions
- Based on the predicted waste type, users are recommended suitable recycling projects.
- Projects are grouped by categories (Plastic, Paper, Glass etc.).
- Users can browse by category tabs or view all suggestions in a single list.

### Automated Data Collection (Python Bot)
- Selenium bot crawls selected recycling websites.
- Automatically retrieves: project title, description, steps, material list, and image URL.
- Images are saved locally in the project directory (`/assets/denemeCrowler/`).

---

## Running the Project

### 1. Run Python Backend (`app2.py`)

Open the terminal or VSCode terminal and navigate to the folder containing the Python script:

```bash
cd /path/to/python/app
python app2.py
```

### 2. Run Flutter Frontend (`main.dart`)

Open the terminal or VSCode terminal and navigate to the root folder of the Flutter project:

```bash
cd /path/to/flutter/project
flutter run
```

