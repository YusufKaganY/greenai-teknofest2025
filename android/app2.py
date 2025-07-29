from flask import Flask, jsonify, request
from flask_cors import CORS
from ultralytics import YOLO
from PIL import Image
import io
import pyodbc
import socket
from werkzeug.security import generate_password_hash, check_password_hash


app = Flask(__name__)
CORS(app, resources={r"/*": {"origins": "*"}})

model = YOLO('C:\\Users\\senat\\Downloads\\best_updatedV1_11_4.pt')   

detected_class = [] 


table_mapping = {
    "sweat": "Kazaklar",
    "tshirt": "KisaKol",
    "KisaKollu":"KisaKol",
    "shirt": "Gomlekler",
    "Gömlek":"Gomlekler",
    "metal": "Metaller", 
    "plastik": "Plastikler", 
    "plastic": "Plastikler",  
    "paper": "Plastikler", 
    "pants": "Pantolonlar",
    "shorts": "Sortlar",  
    "skirt": "Etekler",   
    "tie": "Kravat",   
    "glass": "Camlar", 
    "cam": "Camlar",   
    "cardboard": "Cardboard", 
    "jacket": "Ceketler", 
    "dress": "Elbiseler", 
    "uzun kollu":"Kazaklar",
    "Pantolon": "Pantolonlar",
    "Kısa kollu":"KisaKol"
      
}

def get_db_connection():
    try:
        server = 'localhost'
        database = 'ReenK'
        conn = pyodbc.connect(
            f'DRIVER={{ODBC Driver 17 for SQL Server}};'
            f'SERVER={server};'
            f'DATABASE={database};'
            f'Trusted_Connection=yes'
        )
        print("✅ Database connection established.")
        return conn
    except pyodbc.Error as e:
        print("❌ Database connection error:", str(e))
        return None

@app.route('/predict', methods=['POST'])
def predict():
    global detected_class
    detected_class = []  

    if 'image' not in request.files:
        return jsonify({"error": "No image file found"}), 400

    file = request.files['image']
    try:
        img = Image.open(io.BytesIO(file.read()))
        results = model(img, conf=0.25)

        predictions = []
        
        for result in results:
            for box in result.boxes:
                class_id = int(box.cls)
                class_name = result.names[class_id]
                predictions.append({
                    "class_id": class_id,
                    "class_name": class_name,
                    "confidence": float(box.conf)
                })
                if class_name.lower() not in detected_class:
                    detected_class.append(class_name.lower()) 

                for k, v in table_mapping.items():
                    if class_name.lower() == k.lower():
                        detected_class[-1] = v  
                        break
                
        if not predictions:
            detected_class = [] 

        return jsonify(predictions)

    except Exception as e:
        print("❌ Error processing image:", str(e))
        return jsonify({"error": "Error processing image"}), 500


@app.route('/suggestions', methods=['GET'])
def get_suggestions():
    global detected_class

    if not detected_class:
        return jsonify({"error": "No detected class available"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    try:
        cursor = conn.cursor()
        all_suggestions = []

        for category in detected_class:
            if category in table_mapping.values(): 
                query = f""" 
                    SELECT Baslik, Aciklama, Adimlar, ResimUrl, Kaynak, 
                           ZorlukDerecesi, Sure, Malzemeler 
                    FROM {category}
                """
                cursor.execute(query)
                rows = cursor.fetchall()

                for row in rows:
                    all_suggestions.append({
                        "baslik": row[0],
                        "aciklama": row[1],
                        "adimlar": row[2],
                        "resimUrl": row[3],
                        "kaynak": row[4],
                        "zorlukDerecesi": row[5],
                        "sure": row[6],
                        "malzemeler": row[7],
                        "kategori": category

                    })
        
        return jsonify(all_suggestions)

    except Exception as e:
        print("❌ Error fetching suggestions:", str(e))
        return jsonify({"error": "Error fetching suggestions"}), 500
    finally:
        if conn:
            conn.close()

@app.route('/update_point', methods=['POST'])
def update_point():
    data = request.get_json()
    username = data.get("username")
    points_to_add = data.get("points", 0)

    if not username:
        return jsonify({"error": "Kullanıcı adı gerekli"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT Puan FROM Kullanicilar WHERE KullaniciAdi = ?", (username,))
        row = cursor.fetchone()
        if not row:
            return jsonify({"error": "Kullanıcı bulunamadı"}), 404

        current_points = row[0]
        new_points = current_points + points_to_add

        cursor.execute("UPDATE Kullanicilar SET Puan = ? WHERE KullaniciAdi = ?", (new_points, username))
        conn.commit()

        return jsonify({"message": "Puan güncellendi", "new_points": new_points}), 200
    except Exception as e:
        print("❌ Puan güncelleme hatası:", str(e))
        return jsonify({"error": "Puan güncellenemedi"}), 500
    finally:
        conn.close()


@app.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get("username")
    password = data.get("password")

    if not username or not password:
        return jsonify({"error": "Kullanıcı adı ve şifre gerekli"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT KullaniciID, Sifre, Puan FROM Kullanicilar WHERE KullaniciAdi = ?", (username,))
        user = cursor.fetchone()

        if user and check_password_hash(user[1], password):
            return jsonify({
                "message": "Giriş başarılı",
                "kullanici_id": user[0],
                "puan": user[2]
            }), 200
        else:
            return jsonify({"error": "Geçersiz kullanıcı adı veya şifre"}), 401
    finally:
        conn.close()

@app.route('/register', methods=['POST'])
def register():
    data = request.get_json()
    kullanici_adi = data.get("username")
    sifre = data.get("password")

    if not kullanici_adi or not sifre:
        return jsonify({"error": "Kullanıcı adı ve şifre gerekli"}), 400

    hashed_password = generate_password_hash(sifre)

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Veritabanı bağlantı hatası"}), 500

    try:
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM Kullanicilar WHERE KullaniciAdi = ?", (kullanici_adi,))
        if cursor.fetchone():
            return jsonify({"error": "Bu kullanıcı adı zaten kayıtlı"}), 409

        cursor.execute("INSERT INTO Kullanicilar (KullaniciAdi, Sifre) VALUES (?, ?)", (kullanici_adi, hashed_password))
        conn.commit()
        return jsonify({"message": "Kayıt başarılı"}), 201
    except Exception as e:
        print("❌ Kayıt hatası:", str(e))
        return jsonify({"error": "Kayıt sırasında hata oluştu"}), 500
    finally:
        conn.close()

@app.route('/suggestionbyselecting', methods=['GET'])
def get_suggestionbyselecting():
    category = request.args.get('category')  
    if not category:
        return jsonify({"error": "Kategori parametresi eksik"}), 400
    category = category.lower()

    
    for k, v in table_mapping.items():
        if category == k.lower():
            category = v
            break

    if category not in table_mapping.values():  
        return jsonify({"error": "Invalid category"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Veritabanı bağlantısı sağlanamadı"}), 500

    try:
        cursor = conn.cursor()

        query = f""" 
            SELECT Baslik, Aciklama, Adimlar, ResimUrl, Kaynak, 
                   ZorlukDerecesi, Sure, Malzemeler 
            FROM {category}
        """
        
        cursor.execute(query)
        suggestions = []
        rows = cursor.fetchall()
        for row in rows:
            suggestions.append({
                "baslik": row[0],
                "aciklama": row[1],
                "adimlar": row[2],
                "resimUrl": row[3],
                "kaynak": row[4],
                "zorlukDerecesi": row[5],
                "sure": row[6],
                "malzemeler": row[7]
            })
        return jsonify(suggestions)
    except Exception as e:
        print("❌ Error fetching suggestions:", str(e))
        return jsonify({"error": "Veritabanı sorgusunda bir hata oluştu"}), 500
    finally:
        if conn:
            conn.close()


if __name__ == '__main__':
    local_ip = socket.gethostbyname(socket.gethostname())
    print(f"🚀 API is running on http://{local_ip}:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)

