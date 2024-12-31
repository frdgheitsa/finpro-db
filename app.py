import logging

from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from werkzeug.security import generate_password_hash, check_password_hash
from werkzeug.utils import secure_filename
from datetime import datetime, timedelta
import mysql.connector
from mysql.connector import Error
import os, re, math

app = Flask(__name__)
app.secret_key = 'gasol' 
app.debug = True  

# FUNGSI DAN VALIDASI

# Direktori tempat menyimpan foto profil dan product
UPLOAD_FOLDER_PROFILE = 'static/uploads/profile_pictures'
UPLOAD_FOLDER_PRODUCT = 'static/uploads/product_img'
UPLOAD_FOLDER_TRANSFER_PROOF = 'static/uploads/transfer_proof'
ALLOWED_EXTENSIONS = {'jpg', 'jpeg', 'png'}
MAX_WIDTH = 1000
MAX_HEIGHT = 1000

app.config['UPLOAD_FOLDER_PROFILE'] = UPLOAD_FOLDER_PROFILE
app.config['UPLOAD_FOLDER_PRODUCT'] = UPLOAD_FOLDER_PRODUCT
app.config['UPLOAD_FOLDER_TRANSFER_PROOF'] = UPLOAD_FOLDER_TRANSFER_PROOF
app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024 

# Fungsi untuk memeriksa ekstensi file
def allowed_file(filename):
    return '.' in filename and filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

# Fungsi untuk mendapatkan dimensi gambar
from PIL import Image
def get_image_dimensions(image_path):
    with Image.open(image_path) as img:
        return img.size

# Fungsi validasi email, username, dan phone
def validate_email(email):
    import re
    return re.match(r"[^@]+@[^@]+\.[^@]+", email)

def validate_username(username):
    return bool(re.match(r'^[a-zA-Z0-9_]+$', username))

def validate_phone(phone):
    return phone.isdigit()

def validate_postalCode(postalCode):
    return postalCode.isdigit()

@app.template_filter('rupiah')
def rupiah_format(value):
    try:
        return "Rp {:,}".format(int(value)).replace(",", ".")
    except (ValueError, TypeError):
        return value

@app.route('/api/get-date', methods=['GET'])
def get_current_date():
    # Mendapatkan tanggal saat ini
    current_date = datetime.now()
    
    formatted_date = current_date.strftime('%A, %d %B %Y')

    return jsonify({"current_date": formatted_date})

# Database connection function
def get_db_connection():
    try:
        connection = mysql.connector.connect(
            host='localhost', 
            database='finpro2',  
            user='titikkoma', 
            password='titikkoma',
            charset="utf8mb4",
            collation="utf8mb4_general_ci"
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error: {e}")
        return None

#Home route
@app.route('/', methods=['GET'])
def home():
    connection = get_db_connection()

    if connection:
        cursor = connection.cursor(dictionary=True)

        # Query dasar untuk produk, ambil hanya 8 produk
        query = '''
        SELECT p.product_id, p.name, p.image, p.price_sell, p.stock, p.category_id, p.description, c.category_name
        FROM Products p
        LEFT JOIN Categories c ON p.category_id = c.category_id
        WHERE p.stock > 0
        LIMIT 8
        '''

        # Jalankan query produk
        cursor.execute(query)
        products = cursor.fetchall()

        # Ambil semua kategori untuk dropdown
        cursor.execute("SELECT category_id, category_name FROM Categories")
        categories = cursor.fetchall()

        # Query untuk mengambil data dari tabel 'recently_added'
        cursor.execute("SELECT * FROM recently_added")
        recently_added_items = cursor.fetchall()
        
        cursor.execute("CALL get_top_products()")
        top_products = cursor.fetchall()
        print(top_products)

        cursor.close()
        connection.close()

        # Kirimkan data ke template Jinja
        return render_template(
            'index.html',
            products=products,
            categories=categories,
            recently_added_items=recently_added_items,
            top_products=top_products
        )
    else:
        return "Database connection failed."
    
@app.route('/admin', methods=['GET'])
def admin():
    # Fungsi untuk mengambil data order items
    def fetch_order_items():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = '''
                SELECT oi.*, p.name AS product_name, p.description, p.image,
                        p.price_sell AS product_price
                FROM order_items oi
                JOIN products p ON oi.product_id = p.product_id
                ORDER BY oi.created_at DESC
                LIMIT 7
            '''
            cursor.execute(query)
            return cursor.fetchall()
        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching order items. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()

    # Fungsi untuk mengambil data top items berdasarkan total quantity
    def fetch_top_items():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = '''
                SELECT p.product_id, p.name AS product_name, p.description, p.image,
                    p.price_sell AS product_price, SUM(oi.quantity) AS total_quantity
                FROM order_items oi
                JOIN products p ON oi.product_id = p.product_id
                GROUP BY p.product_id, p.name, p.description, p.image, p.price_sell
                ORDER BY total_quantity DESC
                LIMIT 3
            '''
            cursor.execute(query)
            return cursor.fetchall()
        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching top items. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()

    # Fungsi untuk mengambil data top buyer berdasarkan total order
    def fetch_top_buyer():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = '''
                SELECT u.customer_id, u.username, COUNT(o.order_id) AS total_orders, up.profile_picture
                FROM orders o
                JOIN customers u ON o.customer_id = u.customer_id
                JOIN customer_profile up ON u.customer_id = up.customer_id
                GROUP BY u.customer_id, u.username, up.profile_picture
                ORDER BY total_orders DESC
            '''
            cursor.execute(query)
            return cursor.fetchall()
        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching top buyers. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()
    
    # Fungsi untuk mengambil data top admin berdasarkan jumlah order yang ditangani
    def fetch_top_admin():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            query = '''
                SELECT a.admin_id, COUNT(o.order_id) AS total_handles, a.username
                FROM orders o
                JOIN admin a ON o.admin_id = a.admin_id
                WHERE o.admin_id IS NOT NULL
                GROUP BY a.admin_id, a.username
                ORDER BY total_handles DESC
            '''
            cursor.execute(query)
            return cursor.fetchall()
        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching top admins. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()


    # Fungsi untuk mengambil data penghasilan dan profit
    def fetch_profit():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("CALL get_monthly_financial_report()")
            result = cursor.fetchall()

            # Mengonversi 'transaction_month' (yang berupa string) ke datetime
            for row in result:
                # Mengubah string tanggal (format 'YYYY-MM') menjadi objek datetime
                row['transaction_month'] = datetime.strptime(row['transaction_month'], '%Y-%m')

            return result  # Mengembalikan hasil setelah dikonversi
        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching profit data. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()

    def fetch_view_data():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("CALL count_view_website()")
            result = cursor.fetchall()
            print(f"Raw result: {result}")  # Menampilkan data mentah yang diambil dari database

            # Membuat dictionary dengan waktu per jam sebagai kunci
            data_dict = {f"{hour:02}:00": 0 for hour in range(24)}  # Inisialisasi dengan 0 untuk setiap jam

            # Memasukkan data ke dalam dictionary
            for row in result:
                if isinstance(row['start_time'], str):  # Jika start_time adalah string
                    row['start_time'] = datetime.strptime(row['start_time'], '%Y-%m-%d %H:%M:%S')
                
                if isinstance(row['start_time'], datetime):
                    # Ambil jam dan format menjadi HH:00
                    hour_key = row['start_time'].strftime('%H:%M')
                    data_dict[hour_key] = row['row_count']  # Menyimpan jumlah baris untuk setiap jam

            # Menampilkan hasil format yang sudah selesai
            formatted_result = [{"start_time": hour, "row_count": count} for hour, count in data_dict.items()]
            return formatted_result

        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching view data. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()

    def fetch_daily_transactions():
        conn = get_db_connection()
        cursor = conn.cursor(dictionary=True)
        try:
            cursor.execute("CALL GetDailyTransactions()")
            result = cursor.fetchall()
            print(f"Raw result: {result}")  # Menampilkan data mentah dari database

            # Memfilter data untuk satu minggu terakhir
            one_week_ago = datetime.now() - timedelta(days=7)
            filtered_result = [
                row for row in result
                if isinstance(row['transaction_date'], str) and datetime.strptime(row['transaction_date'], '%Y-%m-%d') >= one_week_ago
            ]

            # Memformat tanggal menjadi hari, bulan, dan tahun dalam bahasa Inggris
            formatted_result = []
            for row in filtered_result:
                if isinstance(row['transaction_date'], str):
                    row['transaction_date'] = datetime.strptime(row['transaction_date'], '%Y-%m-%d')
                
                if isinstance(row['transaction_date'], datetime):
                    formatted_date = row['transaction_date'].strftime('%A, %B %d, %Y')  # Contoh: Monday, January 01, 2023
                    formatted_result.append({
                        "transaction_date": formatted_date,
                        "total_revenue": row['total_revenue'],
                        "total_profit": row['total_profit'],
                        "total_cost": row['total_cost']
                    })
                
            return formatted_result

        except Exception as e:
            print(f"Error: {e}")
            flash('An error occurred while fetching daily transactions. Please try again.', 'error')
            return None
        finally:
            cursor.close()
            conn.close()


    # Ambil data dari database
    order_items = fetch_order_items()
    top_items = fetch_top_items()
    top_buyers = fetch_top_buyer()
    top_admins = fetch_top_admin()
    profit = fetch_profit()
    view_data = fetch_view_data()
    transaction_data = fetch_daily_transactions()

    # Cek apakah data berhasil diambil dan kirim ke template
    if order_items is not None:

        return render_template('admin.html', 
                               order_items=order_items, 
                               top_items=top_items, 
                               top_buyers=top_buyers,
                               top_admins=top_admins, 
                               profit=profit,
                               view_data=view_data,
                               transaction_data=transaction_data)
    else:
        flash('No order items found.', 'info')
        return render_template('admin.html')

#FRONTEND ROUTE FOR USER
@app.route('/forget_password')
def forget_password():
    return render_template('forget_password.html')

@app.route('/reset_password1')
def reset_password1():
    return render_template('reset_password.html')

@app.route('/allcategories')
def all_categories():
    connection = get_db_connection()
    if connection is None:
        return render_template('allcategories.html', categories=[], page=1, total_pages=1)

    cursor = connection.cursor(dictionary=True)
    
    # Tentukan jumlah kategori yang ingin ditampilkan per halaman
    per_page = 12
    page = request.args.get('page', 1, type=int)  # Ambil parameter page dari URL (default 1)
    offset = (page - 1) * per_page

    # Query untuk menghitung jumlah produk dalam setiap kategori
    query = '''
    SELECT c.category_id, c.category_name, c.image, COUNT(p.category_id) AS category_count
    FROM Categories c
    LEFT JOIN Products p ON c.category_id = p.category_id
    GROUP BY c.category_id
    LIMIT %s OFFSET %s
    '''
    
    cursor.execute(query, (per_page, offset))
    categories = cursor.fetchall()

    # Ambil total jumlah kategori untuk perhitungan pagination
    cursor.execute('SELECT COUNT(*) FROM Categories')
    total_categories = cursor.fetchone()['COUNT(*)']
    total_pages = math.ceil(total_categories / per_page)  # Menghitung total halaman

    cursor.close()
    connection.close()

    return render_template('allcategories.html', categories=categories, page=page, total_pages=total_pages)

@app.route('/explore_all', methods=['GET'])
def explore_all():
    connection = get_db_connection()
    cursor = connection.cursor(dictionary=True)

    # Ambil parameter dari URL
    search_query = request.args.get('query', '', type=str)  # Query pencarian
    selected_category = request.args.get('category', 0, type=int)
    per_page = 12  # Produk per halaman
    page = request.args.get('page', 1, type=int)
    offset = (page - 1) * per_page

    # Query dasar untuk produk
    query = '''
    SELECT p.product_id, p.name, p.image, p.price_sell, p.stock, p.category_id, c.category_name
    FROM Products p
    LEFT JOIN Categories c ON p.category_id = c.category_id
    WHERE p.name LIKE %s AND p.stock > 0
    '''
    params = [f"%{search_query}%"]

    # Filter berdasarkan kategori jika ada
    if selected_category and selected_category != 0:
        query += " AND p.category_id = %s"
        params.append(selected_category)

    # Tambahkan paginasi
    query += " LIMIT %s OFFSET %s"
    params.extend([per_page, offset])

    # Jalankan query produk
    cursor.execute(query, tuple(params))
    products = cursor.fetchall()

    # Query untuk menghitung total produk
    count_query = '''
    SELECT COUNT(*) AS total 
    FROM Products p
    WHERE p.name LIKE %s
    '''
    count_params = [f"%{search_query}%"]

    if selected_category and selected_category != 0:
        count_query += " AND p.category_id = %s"
        count_params.append(selected_category)

    cursor.execute(count_query, tuple(count_params))
    total_products = cursor.fetchone()['total']
    total_pages = math.ceil(total_products / per_page)

    # Ambil semua kategori untuk dropdown
    cursor.execute("SELECT category_id, category_name FROM Categories")
    categories = cursor.fetchall()

    cursor.close()
    connection.close()

    return render_template(
        'explore_all.html',
        products=products,
        categories=categories,
        search_query=search_query,
        selected_category=selected_category,
        page=page,
        total_pages=total_pages
    )

@app.route('/detail_product/<int:product_id>')
def detail_product(product_id):
    # Ambil data produk berdasarkan product_id
    connection = get_db_connection()
    if connection:
        cursor = connection.cursor(dictionary=True)

        # Query untuk mengambil produk berdasarkan ID
        query = "SELECT * FROM Products WHERE product_id = %s"
        cursor.execute(query, (product_id,))
        product = cursor.fetchone()  # Mengambil 1 baris data produk

        # Pastikan data produk ditemukan
        if not product:
            flash("Product not found", 'warning')
            cursor.close()
            connection.close()
            return redirect(url_for('home'))

        # Jika user_id ada di sesi dan role adalah customer, lakukan insert ke view_product
        if 'user_id' in session and session.get('role') == 'customer':
            query = "SELECT * FROM view_product WHERE product_id = %s AND customer_id = %s"
            cursor.execute(query, (product_id, session['user_id']))
            view = cursor.fetchone()

            if view is None:
                query = "INSERT INTO view_product (product_id, customer_id, view_date) VALUES (%s, %s, NOW())"
                cursor.execute(query, (product_id, session['user_id']))
                connection.commit()

        # Query untuk menghitung jumlah tampilan berdasarkan product_id
        query = "SELECT COUNT(*) AS view_count FROM view_product WHERE product_id = %s"
        cursor.execute(query, (product_id,))
        view_count = cursor.fetchone()['view_count']

        # Query untuk mengambil produk lain selain yang sedang dilihat
        query = "SELECT * FROM Products WHERE product_id != %s LIMIT 8"
        cursor.execute(query, (product_id,))
        other_products = cursor.fetchall()

        # Query untuk mengambil review
        query = """
            SELECT r.*, u.username, p.name AS product_name
            FROM reviews r
            JOIN customers u ON r.customer_id = u.customer_id
            JOIN products p ON r.product_id = p.product_id
            WHERE r.product_id = %s
            ORDER BY r.created_at DESC
            LIMIT 3;
        """
        cursor.execute(query, (product_id,))
        reviews = cursor.fetchall()

        cursor.close()
        connection.close()

        return render_template(
            'detail_product.html', 
            product=product, 
            other_products=other_products, 
            reviews=reviews, 
            view_count=view_count
        )
    else:
        flash("Database connection error", 'danger')
        return redirect(url_for('home'))

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        email = request.form['email']
        username = request.form['username']
        fullname = request.form['fullname']
        password = request.form['password']
        confirm_password = request.form['confirm_password']

        if password != confirm_password:
            flash('Passwords do not match!')
            return redirect(url_for('register'))

        # Hash password
        hashed_password = generate_password_hash(password)

        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            try:
                # Cek apakah email atau username sudah ada di salah satu tabel
                cursor.execute('''
                    SELECT 1 FROM (
                        SELECT email FROM customers WHERE email = %s
                        UNION ALL
                        SELECT email FROM admin WHERE email = %s
                        UNION ALL
                        SELECT email FROM employee WHERE email = %s
                        UNION ALL
                        SELECT email FROM owner WHERE email = %s
                    ) AS all_emails
                    LIMIT 1
                ''', (email, email, email, email))
                email_exists = cursor.fetchone()

                cursor.execute('''
                    SELECT 1 FROM (
                        SELECT username FROM customers WHERE username = %s
                        UNION ALL
                        SELECT username FROM admin WHERE username = %s
                        UNION ALL
                        SELECT username FROM employee WHERE username = %s
                        UNION ALL
                        SELECT username FROM owner WHERE username = %s
                    ) AS all_usernames
                    LIMIT 1
                ''', (username, username, username, username))
                username_exists = cursor.fetchone()

                if email_exists:
                    flash('Email is already taken by another account!')
                    return redirect(url_for('register'))
                
                if username_exists:
                    flash('Username is already taken by another account!')
                    return redirect(url_for('register'))

                # Insert the new user into customers table
                cursor.execute('''
                    INSERT INTO customers (email, username, fullname, password) 
                    VALUES (%s, %s, %s, %s)
                ''', (email, username, fullname, hashed_password))
                conn.commit()

                flash('Registration successful! Please log in.')
                return redirect(url_for('login'))

            except mysql.connector.Error as e:
                flash(f'Error: {e}')
                return redirect(url_for('register'))
            finally:
                cursor.close()
                conn.close()

    return render_template('register.html')

@app.route('/waranty')
def waranty():
    return render_template('waranty.html')

@app.route('/how_to_buy')
def how_to_buy():
    return render_template('how_to_buy.html')

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        email = request.form['email']
        password = request.form['password']

        conn = get_db_connection()
        if conn:
            cursor = conn.cursor(dictionary=True)
            
            # Gabungkan query untuk owner, employee, customer, dan admin
            query = """
                SELECT 'owner' AS role, owner_id AS user_id, username, email, password, fullname FROM owner WHERE email = %s
                UNION
                SELECT 'employee' AS role, employee_id AS user_id, username, email, password, fullname FROM employee WHERE email = %s
                UNION
                SELECT 'customer' AS role, customer_id AS user_id, username, email, password, fullname FROM customers WHERE email = %s
                UNION
                SELECT 'admin' AS role, admin_id AS user_id, username, email, password, fullname FROM admin WHERE email = %s
            """
            cursor.execute(query, (email, email, email, email))
            user = cursor.fetchone()

            if user and check_password_hash(user['password'], password):
                # Set session berdasarkan role
                session['user_id'] = user['user_id']
                session['username'] = user['username']
                session['role'] = user['role']
                session['fullname'] = user['fullname']
                session['email'] = user['email']
                session['password'] = password

                # Cek role dan arahkan ke halaman yang sesuai
                if user['role'] == 'owner':
                    flash('Login successful!')
                    return redirect(url_for('admin'))
                elif user['role'] == 'employee':
                    flash('Login successful!')
                    return redirect(url_for('home'))
                elif user['role'] == 'customer':
                    flash('Login successful!')
                    
                    # Cek profil customer
                    cursor.execute('SELECT * FROM customer_profile WHERE customer_id = %s', (session['user_id'],))
                    profile = cursor.fetchone()
                    if profile:
                        session['phone'] = profile['phonenumber']
                        session['address'] = profile['address']
                        session['province_id'] = profile['province_id']
                        session['city'] = profile['city']
                        session['postalCode'] = profile['postal_code']
                        session['profile_picture'] = profile['profile_picture']
                    else:
                        session['phone'] = None
                        session['address'] = None
                        session['province_id'] = None
                        session['city'] = None
                        session['postalCode'] = None
                        session['profile_picture'] = None

                    # Masukkan data ke tabel view_website setelah login sebagai customer
                    cursor.execute("""
                        INSERT INTO view_website (customer_id) 
                        VALUES (%s)
                    """, (session['user_id'],))
                    conn.commit()  # Simpan perubahan ke database

                    # Ambil item keranjang untuk pengguna
                    cursor.execute("""
                        SELECT quantity
                        FROM cart 
                        WHERE customer_id = %s
                    """, (session['user_id'],))
                    cart_items = cursor.fetchall()

                    cart = []
                    cart_count = 0
                    for item in cart_items:
                        cart.append(item)
                        cart_count += item['quantity']

                    session['cart_count'] = cart_count

                    return redirect(url_for('home'))
                elif user['role'] == 'admin':
                    flash('Login successful!')
                    return redirect(url_for('home'))

            else:
                flash('Invalid email or password!')

            cursor.close()
            conn.close()

    return render_template('login.html')

@app.route('/check_user', methods=['POST'])
def check_user():
    email_or_username = request.form.get('email_or_username', '').strip()

    if not email_or_username:
        flash('Email or username is required.', 'error')
        return redirect(url_for('forget_password'))

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Periksa apakah email atau username ada di database (di semua tabel)
        query = '''
            SELECT customer_id AS user_id, 'customer' AS role FROM customers WHERE email = %s OR username = %s
            UNION ALL
            SELECT admin_id AS user_id, 'admin' AS role FROM admin WHERE email = %s OR username = %s
            UNION ALL
            SELECT employee_id AS user_id, 'employee' AS role FROM employee WHERE email = %s OR username = %s
            UNION ALL
            SELECT owner_id AS user_id, 'owner' AS role FROM owner WHERE email = %s OR username = %s
        '''
        cursor.execute(query, (email_or_username, email_or_username, email_or_username, email_or_username, email_or_username, email_or_username, email_or_username, email_or_username))
        user = cursor.fetchone()

        if user:
            # Simpan data user_id dan role di session
            session['user_id'] = user['user_id']
            session['role'] = user['role']

            # Redirect ke halaman reset password dengan parameter user_id
            return redirect(url_for('reset_password1'))
        else:
            flash('Email or username not found.', 'error')
            return redirect(url_for('forget_password'))

    except Exception as e:
        # Ganti print dengan flash untuk menampilkan pesan kesalahan
        flash(f'An error occurred: {e}', 'error')
        return redirect(url_for('forget_password'))

    finally:
        cursor.close()
        conn.close()

@app.route('/reset_password', methods=['POST'])
def reset_password():
    user_id = request.form.get('user_id', '').strip()  # Ambil user_id dari form
    new_password = request.form.get('new_password', '').strip()  # Ambil password baru dari form
    confirm_password = request.form.get('confirm_password', '').strip()  # Ambil konfirmasi password

    # Validasi input
    if not user_id or not new_password:
        flash('User ID and password are required.', 'error')
        return redirect(url_for('reset_password1', user=user_id))

    if new_password != confirm_password:
        flash('Passwords do not match.', 'error')
        return redirect(url_for('reset_password1', user=user_id))

    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)

    try:
        # Cek apakah user_id ada di salah satu tabel (admin, employee, customers, owner)
        query = """
            SELECT 'admin' AS source FROM admin WHERE admin_id = %s
            UNION
            SELECT 'employee' AS source FROM employee WHERE employee_id = %s
            UNION
            SELECT 'customer' AS source FROM customers WHERE customer_id = %s
            UNION
            SELECT 'owner' AS source FROM owner WHERE owner_id = %s
        """
        cursor.execute(query, (user_id, user_id, user_id, user_id))
        user = cursor.fetchone()

        if user:
            # Hash password baru
            hashed_password = generate_password_hash(new_password)

            # Update password di tabel yang sesuai
            if user['source'] == 'admin':
                update_query = 'UPDATE admin SET password = %s WHERE admin_id = %s'
            elif user['source'] == 'employee':
                update_query = 'UPDATE employee SET password = %s WHERE employee_id = %s'
            elif user['source'] == 'customer':
                update_query = 'UPDATE customers SET password = %s WHERE customer_id = %s'
            else:
                update_query = 'UPDATE owner SET password = %s WHERE owner_id = %s'

            cursor.execute(update_query, (hashed_password, user_id))
            conn.commit()

            flash('Password reset successfully.', 'success')
            return redirect(url_for('login'))
        else:
            flash('User ID not found in any of the tables.', 'error')
            return redirect(url_for('reset_password1', user=user_id))

    except Exception as e:
        flash('An error occurred. Please try again.', 'error')
        return redirect(url_for('reset_password1', user=user_id))

    finally:
        cursor.close()
        conn.close()

# Logout route
@app.route('/logout')
def logout():
    session.clear()
    flash('You have been logged out.')
    return redirect(url_for('home'))

@app.route('/admin/add_product_form', methods=['GET'])
def add_product_form():
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    
    if conn:
        try:
            # Ambil kategori
            cursor.execute("SELECT category_id, category_name FROM categories")
            categories = cursor.fetchall()
            
        except Exception as e:
            flash(f"Error occurred while fetching data: {str(e)}", "danger")
            return redirect(url_for('error_page'))  # Ganti dengan route error jika ada
        
        finally:
            conn.close()  # Pastikan koneksi ditutup setelah selesai

    return render_template('add_product.html', categories=categories)


@app.route('/admin/add_product', methods=['GET', 'POST'])
def add_product():
    if request.method == 'POST':
        # Ambil data dari form
        name = request.form['name']
        description = request.form['description']
        specification = request.form['specification']
        price_sell = request.form['price_sell']
        price_buy = request.form['price_buy']
        stock = request.form['stock']
        category_id = request.form['category_id']
        image = request.files['image']
        
        # Validasi file gambar
        if image and allowed_file(image.filename):
            filename = secure_filename(image.filename)
            image_path = os.path.join(app.config['UPLOAD_FOLDER_PRODUCT'], filename)
            
            # Periksa apakah file dengan nama yang sama sudah ada, jika ada, tambahkan angka
            base_filename, extension = os.path.splitext(filename)
            counter = 1
            while os.path.exists(image_path):  # Cek apakah file dengan nama tersebut sudah ada
                filename = f"{base_filename}_{counter}{extension}"  # Tambahkan angka di belakang nama file
                image_path = os.path.join(app.config['UPLOAD_FOLDER_PRODUCT'], filename)
                counter += 1
            
            # Simpan gambar
            image.save(image_path)
            
            image_filename = filename  # Gunakan nama file yang sudah diperbarui
        else:
            image_filename = None

        # Koneksi ke database dan menambahkan produk
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor()
                query = """
                    INSERT INTO products (name, description, specifications, price_sell, price_buy, stock, category_id, image)
                    VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
                """
                values = (name, description, specification, price_sell, price_buy, stock, category_id, image_filename)
                cursor.execute(query, values)
                conn.commit()
                
                flash("Product added successfully!", "success")
                return redirect(url_for('add_product_form'))  # Redirect ke halaman form setelah berhasil

            except Error as e:
                conn.rollback()  # Rollback jika terjadi error
                flash(f"Error occurred while adding product: {str(e)}", "danger")
                return redirect(url_for('add_product'))  # Redirect ke halaman form dengan pesan error
            
            finally:
                cursor.close()
                conn.close()  # Menutup koneksi database setelah selesai
        else:
            flash("Database connection failed.", "danger")
            return redirect(url_for('add_product'))

    # Menampilkan form saat request GET
    return render_template('add_product.html')

@app.route('/admin/list_products', methods=['GET'])
def manage_products():
    try:
        # Parameter dari URL
        selected_category = request.args.get('category', default=0, type=int)  # Default ke "All"
        search_query = request.args.get('query', '', type=str)  # Query pencarian
        page = request.args.get('page', 1, type=int)  # Halaman saat ini
        items_per_page = 10  # Jumlah item per halaman
        
        # Koneksi ke database
        connection = get_db_connection()
        cursor = connection.cursor(dictionary=True)
        
        # Ambil semua kategori
        cursor.execute("SELECT category_id, category_name FROM Categories")
        categories = cursor.fetchall()
        
        # Hitung offset
        offset = (page - 1) * items_per_page
        
        # Query produk dengan filter kategori dan pencarian
        if selected_category == 0:  # "All" kategori
            cursor.execute("""
                SELECT p.*, c.category_name
                FROM Products p
                LEFT JOIN Categories c ON p.category_id = c.category_id
                WHERE p.name LIKE %s
                LIMIT %s OFFSET %s
            """, ('%' + search_query + '%', items_per_page, offset))
        else:  # Filter kategori tertentu
            cursor.execute("""
                SELECT p.*, c.category_name
                FROM Products p
                LEFT JOIN Categories c ON p.category_id = c.category_id
                WHERE p.category_id = %s AND p.name LIKE %s
                LIMIT %s OFFSET %s
            """, (selected_category, '%' + search_query + '%', items_per_page, offset))
        
        products = cursor.fetchall()
        
        # Hitung total produk untuk paginasi
        if selected_category == 0:  # "All" kategori
            cursor.execute("SELECT COUNT(*) as total FROM Products WHERE name LIKE %s", ('%' + search_query + '%',))
        else:  # Filter kategori
            cursor.execute("SELECT COUNT(*) as total FROM Products WHERE category_id = %s AND name LIKE %s", (selected_category, '%' + search_query + '%'))
        
        total_products = cursor.fetchone()['total']
        total_pages = (total_products + items_per_page - 1) // items_per_page
        
        # Tutup koneksi
        cursor.close()
        connection.close()
        
        return render_template(
            'list_products.html',
            products=products,
            categories=categories,
            selected_category=selected_category,
            search_query=search_query,
            current_page=page,
            total_pages=total_pages
        )
    
    except Exception as e:
        # Tangani error
        print(f"Terjadi kesalahan: {e}")
        flash ("Terjadi kesalahan saat memproses data produk.")
        return redirect(url_for('home'))

@app.route('/admin/delete_product/<int:product_id>', methods=['POST'])
def delete_product(product_id):
    # Check if the user is an admin or owner
    if session.get('role') not in ['admin', 'owner']:
        flash('You do not have permission to delete products.', 'danger')
        return redirect(url_for('manage_products', page=1, category=0, query=''))

    # Establish connection to the database
    connection = get_db_connection()
    if connection is None:
        flash('Database connection failed.', 'danger')
        return redirect(url_for('manage_products', page=1, category=0, query=''))

    try:
        cursor = connection.cursor()
        # Delete the product from the database
        cursor.execute("DELETE FROM Products WHERE product_id = %s", (product_id,))
        connection.commit()

        flash('Product deleted successfully!', 'success')
    except Exception as e:
        connection.rollback()  # Rollback if there is an error
        flash(f'An error occurred while deleting the product: {str(e)}', 'danger')
    finally:
        cursor.close()
        connection.close()

    return redirect(url_for('manage_products', page=1, category=0, query=''))



@app.route('/admin/add_recently_added', methods=['GET'])
def call_add_recently_added():
    current_page = request.args.get('current_page', 1, type=int)  # Halaman saat ini
    selected_category = request.args.get('selected_category', default=0, type=int)  # Default ke "All"
    search_query = request.args.get('search_query', '', type=str)  # Query pencarian
    # Koneksi ke database
    conn = get_db_connection()
    
    if conn:
        try:
            cursor = conn.cursor()
            # Memanggil prosedur 'add_recently_added'
            cursor.callproc('add_recently_added')
            conn.commit()
            
            flash("Recently added products have been updated!", "success")
            return redirect( url_for('manage_products', page=current_page, category=selected_category, query=search_query) )
        except Error as e:
            conn.rollback()  # Rollback jika terjadi error
            flash(f"Error occurred while calling the procedure: {str(e)}", "danger")
            return redirect( url_for('manage_products', page=current_page, category=selected_category, query=search_query) )
        finally:
            cursor.close()
            conn.close()
    else:
        flash("Database connection failed.", "danger")
        return redirect( url_for('manage_products', page=current_page, category=selected_category, query=search_query) )

# Route for displaying order data
@app.route('/admin/order_data')
def order_data():
    # Get the current page from the query string
    page = request.args.get('page', 1, type=int)

    # Establish connection to the database
    connection = get_db_connection()
    if connection is None:
        return "Unable to connect to the database", 500

    cursor = connection.cursor(dictionary=True)

    # Pagination settings
    per_page = 10
    offset = (page - 1) * per_page

    # Query to get the total number of orders
    cursor.execute("SELECT COUNT(*) FROM orders")
    total_orders = cursor.fetchone()['COUNT(*)']
    total_pages = (total_orders + per_page - 1) // per_page

    # Query to get the orders for the current page
    cursor.execute("""
        SELECT o.*, a.fullname AS admin_name
        FROM orders o
        LEFT JOIN admin a ON o.admin_id = a.admin_id
        ORDER BY o.created_at DESC
        LIMIT %s OFFSET %s
    """, (per_page, offset))


    orders = cursor.fetchall()
    print(orders)

    # Close the connection
    cursor.close()
    connection.close()

    return render_template(
        'order_data.html', 
        orders=orders, 
        current_page=page, 
        total_pages=total_pages
    )
    
@app.route('/admin/order_detail/<int:order_id>')
def order_detail(order_id):
    # Connect to the database
    connection = get_db_connection()
    if connection is None:
        return "Unable to connect to the database", 500

    cursor = connection.cursor(dictionary=True)

    try:
        # Panggil prosedur GetOrderDetail untuk mengambil detail pesanan
        cursor.callproc('GetOrderDetail', (order_id,))

        # Ambil hasil dari prosedur
        order_info = None
        order_items = []
        for result in cursor.stored_results():
            if order_info is None:
                order_info = result.fetchone()
            else:
                order_items = result.fetchall()

        if order_info:
            # Ambil informasi tentang provinsi
            if order_info['province']:
                province_cursor = connection.cursor(dictionary=True)
                province_cursor.execute('SELECT * FROM provinsi WHERE id = %s', (order_info['province'],))
                province = province_cursor.fetchone()

                if province:
                    order_info['province_name'] = province['province']
                else:
                    order_info['province_name'] = 'Provinsi tidak ditemukan'

            return render_template('order_detail.html', order_info=order_info, order_items=order_items)
        else:
            flash("Order not found", 'danger')
            return redirect(url_for('admin'))
    except Exception as e:
        flash(f"An error occurred: {e}", 'danger')
        return redirect(url_for('admin'))
    finally:
        # Close the cursor and connection
        cursor.close()
        connection.close()
        
@app.route('/settings', methods=['GET', 'POST'])
def settings():
    # Pastikan user sudah login
    if 'user_id' not in session:
        flash('User not logged in', 'error')
        return redirect(url_for('login'))

    user_id = session['user_id']

    try:
        # Ambil data user dan profile dari database
        with get_db_connection() as conn:
            with conn.cursor(dictionary=True) as cursor:
                cursor.execute('SELECT * FROM customers WHERE customer_id = %s', (user_id,))
                user = cursor.fetchone()

                cursor.execute('SELECT * FROM customer_profile WHERE customer_id = %s', (user_id,))
                profile = cursor.fetchone()

                cursor.execute('SELECT * FROM provinsi')
                provinces = cursor.fetchall()

        if request.method == 'POST':
            fullname = request.form.get('fullName') or user['fullname']
            email = request.form.get('email') or user['email']
            username = request.form.get('username') or user['username']
            password = request.form.get('password') or user['password']
            phone = request.form.get('phone') or (profile.get('phonenumber') if profile else '')
            address = request.form.get('address') or (profile.get('address') if profile else '')
            province_id = request.form.get('province_id') or (profile.get('province_id') if profile else None)
            city = request.form.get('city') or (profile.get('city') if profile else '')
            postal_code = request.form.get('postalCode') or (profile.get('postal_code') if profile else '')


            # Validasi data
            if email and not validate_email(email):
                flash('Invalid email format.', 'error')
                return redirect(url_for('settings'))

            # Cek duplikasi email dan username di semua tabel, berdasarkan kolom ID masing-masing
            with get_db_connection() as conn:
                with conn.cursor() as cursor:
                    # Cek duplikasi email
                    cursor.execute('''
                        SELECT COUNT(*) FROM (
                            SELECT email FROM admin WHERE admin_id != %s
                            UNION ALL
                            SELECT email FROM employee WHERE employee_id != %s
                            UNION ALL
                            SELECT email FROM customers WHERE customer_id != %s
                            UNION ALL
                            SELECT email FROM owner WHERE owner_id != %s
                        ) accounts
                        WHERE email = %s
                    ''', (user_id, user_id, user_id, user_id, email))
                    if cursor.fetchone()[0] > 0:
                        flash('Email already in use by another account.', 'error')
                        return redirect(url_for('settings'))

                    # Cek duplikasi username
                    cursor.execute('''
                        SELECT COUNT(*) FROM (
                            SELECT username FROM admin WHERE admin_id != %s
                            UNION ALL
                            SELECT username FROM employee WHERE employee_id != %s
                            UNION ALL
                            SELECT username FROM customers WHERE customer_id != %s
                            UNION ALL
                            SELECT username FROM owner WHERE owner_id != %s
                        ) accounts
                        WHERE username = %s
                    ''', (user_id, user_id, user_id, user_id, username))
                    if cursor.fetchone()[0] > 0:
                        flash('Username already in use by another account.', 'error')
                        return redirect(url_for('settings'))

            # Validasi nomor telepon
            if phone != 'None' and not validate_phone(phone):
                flash('Phone number can only contain numbers.', 'error')
                return redirect(url_for('settings'))

            # Validasi kode pos
            if postal_code != 'None' and not validate_postalCode(postal_code):
                flash('Postal code must be a 5-digit number.', 'error')
                return redirect(url_for('settings'))

            # Hash password jika ada perubahan
            hashed_password = generate_password_hash(password) if password != user['password'] else user['password']

            # Update data di database
            with get_db_connection() as conn:
                with conn.cursor() as cursor:
                    cursor.execute('''
                        UPDATE customers
                        SET fullname = %s, email = %s, username = %s, password = %s
                        WHERE customer_id = %s
                    ''', (fullname, email, username, hashed_password, user_id))

                    if profile:
                        cursor.execute('''
                            UPDATE customer_profile
                            SET phonenumber = %s, address = %s, province_id = %s, city = %s, postal_code = %s
                            WHERE customer_id = %s
                        ''', (phone, address, province_id, city, postal_code, user_id))
                    else:
                        cursor.execute('''
                            INSERT INTO customer_profile (customer_id, phonenumber, address, province_id, city, postal_code)
                            VALUES (%s, %s, %s, %s, %s, %s)
                        ''', (user_id, phone, address, province_id, city, postal_code))
                conn.commit()

            # Update session
            session.update({
                'fullname': fullname,
                'email': email,
                'username': username,
                'phone': phone,
                'address': address,
                'province_id': province_id,
                'city': city,
                'postalCode': postal_code,
            })

            flash('User and profile updated successfully!', 'success')
            return redirect(url_for('settings'))

    except Exception as e:
        flash(f'Error: {e}', 'error')

    return render_template('settings.html', user=user, profile=profile, provinces=provinces)

@app.route('/update_profile_picture', methods=['POST'])
def update_profile_picture():
    if 'user_id' not in session:
        flash('You need to log in first.')
        return redirect(url_for('login'))

    user_id = session['user_id']
    file = request.files.get('profile_picture')

    if file and allowed_file(file.filename):
        # Menyimpan file sementara
        filename = secure_filename(file.filename)
        file_path = os.path.join(app.config['UPLOAD_FOLDER_PROFILE'], filename)

        # Cek dimensi gambar
        file.save(file_path)
        width, height = get_image_dimensions(file_path)
        if width > MAX_WIDTH or height > MAX_HEIGHT:
            flash(f'Image dimensions should not exceed {MAX_WIDTH}px in width and {MAX_HEIGHT}px in height.')
            return redirect(url_for('settings'))

        # Membuat nama file unik
        new_filename = f"{user_id}_{filename}"
        new_file_path = os.path.join(app.config['UPLOAD_FOLDER_PROFILE'], new_filename)

        # Cek apakah direktori ada, jika tidak buat
        if not os.path.exists(app.config['UPLOAD_FOLDER_PROFILE']):
            os.makedirs(app.config['UPLOAD_FOLDER_PROFILE'])

        # Pindahkan file ke direktori yang diinginkan
        os.rename(file_path, new_file_path)

        # Update database untuk menyimpan nama file baru
        conn = get_db_connection()
        cursor = conn.cursor()

        # Mengecek apakah user sudah memiliki profil
        cursor.execute('SELECT * FROM customer_profile WHERE customer_id = %s', (user_id,))
        customer_profile = cursor.fetchone()

        if customer_profile:
            # Hapus foto lama jika ada
            old_file = customer_profile[6]
            if old_file:
                old_file_path = os.path.join(app.config['UPLOAD_FOLDER_PROFILE'], old_file)
                if os.path.exists(old_file_path):
                    os.remove(old_file_path)

            cursor.execute('UPDATE customer_profile SET profile_picture = %s WHERE customer_id = %s', (new_filename, user_id))
        else:
            # Insert baru jika tidak ada profil
            cursor.execute('INSERT INTO customer_profile (customer_id, profile_picture) VALUES (%s, %s)', (user_id, new_filename))

        conn.commit()
        cursor.close()
        conn.close()

        # Simpan nama file baru di session
        session['profile_picture'] = new_filename

        flash('Profile picture updated successfully!')
        return redirect(url_for('settings'))
    else:
        flash('No file selected or invalid file type.')
        return redirect(url_for('settings'))
    
@app.route('/add_to_cart/<int:product_id>', methods=['POST'])
def add_to_cart(product_id):
    user_id = session.get('user_id')  # Ambil user_id dari session atau login
    
    if user_id:
        conn = get_db_connection()
        if conn:
            try:
                cursor = conn.cursor(dictionary=True)
                # Memanggil stored procedure untuk menambahkan produk ke keranjang
                cursor.callproc('add_to_cart', [user_id, product_id])
                print(cursor)
                conn.commit()
                # Ambil item keranjang untuk pengguna
                cursor.execute("""
                    SELECT quantity
                    FROM cart 
                    WHERE customer_id = %s
                """, (session['user_id'],))
                cart_items = cursor.fetchall()
                
                cart = []
                cart_count = 0
                for item in cart_items:
                    cart.append(item)
                    cart_count += item['quantity']

                session['cart_count'] = cart_count
                print(f"Cart count: {cart_count}")

                
            except Exception as e:
                logging.error(f"Error adding product to cart: {e}")
            finally:
                cursor.close()
                conn.close()

    return redirect(url_for('detail_product', product_id=product_id))

@app.route('/update_cart/<int:product_id>/<string:action>', methods=['POST'])
def update_cart(product_id, action):
    user_id = session.get('user_id')
    if not user_id:
        flash('Please log in to update your cart.', 'warning')
        return redirect(url_for('login'))
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor()
            # Panggil stored procedure
            cursor.callproc('UpdateCartQuantity', [user_id, product_id, action])
            conn.commit()
        except Exception as e:
            logging.error(f"Error updating cart: {e}")
            flash('An error occurred while updating the cart.', 'danger')
        finally:
            cursor.close()
            conn.close()

    return redirect(url_for('cart'))

# Route untuk menampilkan halaman keranjang
@app.route('/cart')
def cart():
    user_id = session.get('user_id')
    if not user_id:
        flash("login required !")
        return redirect(url_for('login'))

    conn = get_db_connection()
    cart = []
    total_price = 0
    cart_count = 0

    if conn:
        try:
            cursor = conn.cursor(dictionary=True)
            cursor.execute("""
                SELECT p.product_id, p.name, p.price_sell, p.image, c.quantity
                FROM cart c
                JOIN Products p ON c.product_id = p.product_id
                WHERE c.customer_id = %s
            """, (user_id,))
            cart_items = cursor.fetchall()

            for item in cart_items:
                item['subtotal'] = float(item['price_sell']) * item['quantity']
                total_price += item['subtotal']
                cart.append(item)
                cart_count += item['quantity']

            session['cart_count'] = cart_count
        except Exception as e:
            logging.error(f"Error fetching cart data: {e}")
        finally:
            cursor.close()
            conn.close()

    return render_template('cart.html', products=cart, total_price=total_price)

@app.route('/checkout', methods=['GET', 'POST'])
def checkout():
    # Cek apakah pengguna sudah login
    user_id = session.get('user_id')
    if not user_id:
        flash('Please log in to proceed with checkout', 'warning')
        return redirect(url_for('login'))  # Ganti dengan route login Anda

    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)

            # Ambil semua produk di keranjang pengguna
            cursor.execute("""
                SELECT p.product_id, p.name, p.price_sell, c.quantity, 
                       (p.price_sell * c.quantity) AS subtotal, p.image, p.stock
                FROM cart c
                JOIN products p ON c.product_id = p.product_id
                WHERE c.customer_id = %s
            """, (user_id,))
            products = cursor.fetchall()

            # Hitung total harga
            total_price = sum([product['subtotal'] for product in products])

            # Ambil semua provinsi
            cursor.execute("SELECT * FROM provinsi")
            provinces = cursor.fetchall()

            if request.method == 'POST':
                # Ambil data dari form checkout
                name = request.form['name']
                email = request.form['email']
                address = request.form['address']
                phone = request.form['phone']
                postal_code = request.form['postal_code']
                city = request.form['city']
                province_id = request.form['province_id']
                payment_method = request.form['payment_method']
                
                # Validasi format email
                if not validate_email(email):
                    flash('Invalid email format.', 'error')
                    return render_template('checkout.html', products=products, total_price=total_price, provinces=provinces)
                
                # Validasi phone number
                if not validate_phone(phone):
                    flash('Phone number can only contain numbers.', 'error')
                    return render_template('checkout.html', products=products, total_price=total_price, provinces=provinces)
                
                # Validasi postal code harus angka dan memiliki panjang 5 digit
                if not validate_postalCode(postal_code) or len(postal_code) != 5:
                    flash('Postal code must be a number and have a length of 5 digits', 'danger')
                    return render_template('checkout.html', products=products, total_price=total_price, provinces=provinces)

                # Panggil stored procedure untuk membuat pesanan
                cursor.callproc('CreateOrder', 
                                (user_id, total_price, name, email, address, phone, postal_code, city, province_id, payment_method))
                order_id = None
                for result in cursor.stored_results():
                    order_id = result.fetchone()['order_id']

                # Jika metode pembayaran Bank Transfer, proses upload bukti transfer
                transfer_proof_path = None
                if payment_method == 'bank_transfer':
                    if 'transfer_proof' in request.files:
                        file = request.files['transfer_proof']
                        if file and allowed_file(file.filename):
                            # Nama file yang akan disimpan
                            extension = file.filename.rsplit('.', 1)[1].lower()
                            filename = f"{user_id}-{order_id}.{extension}"
                            transfer_proof_path = os.path.join(app.config['UPLOAD_FOLDER_TRANSFER_PROOF'], filename)

                            try:
                                # Simpan file bukti transfer
                                file.save(transfer_proof_path)
                                print(f"File berhasil disimpan di: {transfer_proof_path}")

                                # Panggil stored procedure untuk menyimpan pembayaran
                                cursor.callproc('SavePayment', 
                                                (order_id, payment_method, filename, 'pending'))
                                conn.commit()

                            except Exception as e:
                                logging.error(f"Error saving payment proof to database: {e}")
                                flash('Terjadi kesalahan saat menyimpan bukti pembayaran', 'danger')
                        else:
                            flash('File tidak valid atau ekstensi tidak diizinkan', 'danger')
                    else:
                        flash('Tidak ada file yang diupload', 'danger')

                # Kurangi stok produk berdasarkan quantity di keranjang
                for product in products:
                    product_id = product['product_id']
                    quantity = product['quantity']

                    # Pastikan stok cukup sebelum mengurangi
                    if product['stock'] < quantity:
                        flash(f"Stok untuk produk {product['name']} tidak mencukupi.", 'danger')
                        raise Exception("Stok tidak mencukupi")

                    cursor.execute("""
                        UPDATE products
                        SET stock = stock - %s
                        WHERE product_id = %s
                    """, (quantity, product_id))

                # Kosongkan keranjang setelah pesanan dibuat
                cursor.execute("DELETE FROM cart WHERE customer_id = %s", (user_id,))
                conn.commit()

                flash('Order placed successfully! Thank you for your purchase.', 'success')
                return redirect(url_for('cart'))

            # Render halaman checkout dengan produk di keranjang
            return render_template('checkout.html', products=products, total_price=total_price, provinces=provinces)

        except Exception as e:
            logging.error(f"Error processing checkout: {e}")
            flash('An error occurred. Please try again later.')
        finally:
            cursor.close()
            conn.close()

    return render_template('checkout.html', products=[], total_price=0, provinces=[])

@app.route('/transaction_history')
def transaction_history():
    user_id = session['user_id']
    # Get the current page from the query string
    page = request.args.get('page', 1, type=int)

    # Establish connection to the database
    connection = get_db_connection()
    if connection is None:
        return "Unable to connect to the database", 500

    cursor = connection.cursor(dictionary=True)

    # Pagination settings
    per_page = 10
    offset = (page - 1) * per_page

    # Query untuk mendapatkan total jumlah pesanan
    cursor.execute("SELECT COUNT(*) FROM orders WHERE customer_id = %s", (user_id,))
    total_orders = cursor.fetchone()['COUNT(*)']
    total_pages = (total_orders + per_page - 1) // per_page

    # Query untuk mendapatkan pesanan untuk halaman saat ini
    cursor.execute("""
        SELECT * FROM orders 
        WHERE customer_id = %s
        LIMIT %s OFFSET %s
    """, (user_id, per_page, offset))

    orders = cursor.fetchall()
    
    # Close the connection
    cursor.close()
    connection.close()

    return render_template(
        'order_data.html', 
        orders=orders, 
        current_page=page, 
        total_pages=total_pages
    )

@app.route('/admin/get_product/<int:product_id>', methods=['GET'])
def get_product(product_id):
    current_page = request.args.get('current_page', 1, type=int)
    selected_category = request.args.get('selected_category', default=0, type=int)  # Default ke "All"
    search_query = request.args.get('search_query', '', type=str)  # Query pencarian
    conn = get_db_connection()
    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("""
                SELECT p.*, c.category_name
                FROM products p
                LEFT JOIN categories c ON p.category_id = c.category_id
                WHERE p.product_id = %s
            """, (product_id,))
        product_updates = cursor.fetchone()
        # Ambil kategori
        cursor.execute("SELECT category_id, category_name FROM Categories")
        categories = cursor.fetchall()
        
        if product_updates:
            return render_template('add_product.html', product_updates=product_updates, categories=categories, current_page=current_page, selected_category=selected_category, search_query=search_query)
        else:
            flash ("Product Not Found")
    except Exception as e:
        return jsonify({'error': str(e)}), 500
    finally:
        cursor.close()
        conn.close()


@app.route('/admin/update_product/<int:product_id>', methods=['GET', 'POST'])
def update_product(product_id):
    current_page = request.args.get('page', 1, type=int)
    selected_category = request.args.get('selected_category', default=0, type=int)  # Default ke "All"
    search_query = request.args.get('search_query', '', type=str)  # Query pencarian
    conn = get_db_connection()
    if conn:
        try:
            cursor = conn.cursor(dictionary=True)

            # Ambil data produk berdasarkan ID
            cursor.execute("SELECT * FROM products WHERE product_id = %s", (product_id,))
            product = cursor.fetchone()

            if not product:
                flash('Product not found', 'danger')
                return redirect({{ url_for('manage_products', page=1, category=selected_category, query=search_query) }})  # Redirect ke list_products jika produk tidak ditemukan

            if request.method == 'POST':
                # Ambil data dari form
                name = request.form['name']
                category_id = request.form['category_id']
                price_sell = request.form['price_sell']
                price_buy = request.form['price_buy']
                stock = request.form['stock']
                description = request.form['description']
                specification = request.form['specification']
                image_file = request.files.get('image')

                # Validasi dan proses file gambar jika ada
                if image_file and allowed_file(image_file.filename):
                    filename = secure_filename(image_file.filename)
                    image_path = os.path.join(app.config['UPLOAD_FOLDER_PRODUCT'], filename)

                    # Periksa apakah file dengan nama yang sama sudah ada, jika ada, tambahkan angka
                    base_filename, extension = os.path.splitext(filename)
                    counter = 1
                    while os.path.exists(image_path):
                        filename = f"{base_filename}_{counter}{extension}"
                        image_path = os.path.join(app.config['UPLOAD_FOLDER_PRODUCT'], filename)
                        counter += 1

                    # Hapus gambar sebelumnya jika ada
                    if product['image']:
                        old_image_path = os.path.join(app.config['UPLOAD_FOLDER_PRODUCT'], product['image'])
                        if os.path.exists(old_image_path):
                            os.remove(old_image_path)

                    # Simpan gambar baru
                    image_file.save(image_path)
                    image_filename = filename
                else:
                    image_filename = product['image']  # Gunakan gambar lama jika tidak ada unggahan baru

                # Perbarui data produk di database
                query = """
                    UPDATE products 
                    SET name = %s, category_id = %s, price_sell = %s, price_buy = %s, stock = %s, description = %s, specifications = %s, image = %s
                    WHERE product_id = %s
                """
                values = (name, category_id, price_sell, price_buy, stock, description, specification, image_filename, product_id)
                cursor.execute(query, values)
                conn.commit()

                flash("Product updated successfully!", "success")
                return redirect( url_for('manage_products', page=current_page, category=selected_category, query=search_query) )  # Redirect ke list_products setelah berhasil

            return render_template('update_product.html', product=product)  # Pastikan product dikirim ke template

        except Exception as e:
            logging.error(f"Error updating product: {e}")
            flash('An error occurred while updating the product.', 'danger')
            return redirect({{ url_for('manage_products', page=1, category=selected_category, query=search_query) }})  # Redirect ke list_products jika terjadi kesalahan
        finally:
            cursor.close()
            conn.close()

    flash('Database connection failed.', 'danger')  # Menampilkan pesan jika koneksi gagal
    return redirect(url_for('home'))  # Redirect ke halaman lain jika koneksi gagal

@app.route('/admin/update_order_status/<int:order_id>', methods=['POST'])
def update_order_status(order_id):
    # Check if user is admin
    if session.get('role') == 'customer':
        return redirect(url_for('order_data'))

    # Get the new status from the form
    new_status = request.form['status']
    admin_id = session.get('user_id')

    # Establish connection to the database
    connection = get_db_connection()
    cursor = connection.cursor()

    cursor.execute(" SELECT *FROM orders WHERE order_id = %s", (order_id,))
    order = cursor.fetchone()
    
    if order[14] == admin_id:
        # Update the order status in the database
        cursor.execute("""
            UPDATE orders 
            SET status_order = %s, admin_id = %s
            WHERE order_id = %s
        """, (new_status, admin_id, order_id))
    else:
        flash("Can't update status, because it's already handled by another employee")
        return redirect(url_for('order_data'))

    # Commit the change and close the connection
    connection.commit()
    cursor.close()
    connection.close()

    # Redirect to the order data page after updating status
    return redirect(url_for('order_data'))


@app.route('/transaction_detail/<int:order_id>')
def transaction_detail(order_id):
    # Connect to the database
    connection = get_db_connection()
    if connection is None:
        return "Unable to connect to the database", 500

    cursor = connection.cursor(dictionary=True)

    try:
        # Call the stored procedure to get order details
        cursor.callproc('GetOrderDetail', (order_id,))

        # Fetch results from the procedure
        order_info = None
        order_items = []
        for result in cursor.stored_results():
            if order_info is None:
                order_info = result.fetchone()
                print(order_info)
            else:
                order_items = result.fetchall()
                print(order_items)

        if order_info:
            # Check if province exists and is not None
            province_id = order_info.get('province')
            if province_id is not None:
                province_cursor = connection.cursor(dictionary=True)
                province_cursor.execute('SELECT * FROM provinsi WHERE id = %s', (province_id,))
                province = province_cursor.fetchone()

                if province:
                    order_info['province_name'] = province['province']
                else:
                    order_info['province_name'] = 'Provinsi tidak ditemukan'
            else:
                order_info['province_name'] = 'Provinsi tidak tersedia'

            return render_template('order_detail.html', order_info=order_info, order_items=order_items)
        else:
            flash("Order not found", 'danger')
            return redirect(url_for('transaction_history'))
    except Exception as e:
        error_message = str(e) if e is not None else "Unknown error occurred"
        flash(f"An error occurred: {error_message}", 'danger')  # Ensure e is converted to string
        return redirect(url_for('transaction_history'))
    finally:
        # Close the cursor and connection
        cursor.close()
        connection.close()
        
@app.route('/review/<int:order_id>/<int:product_id>/<int:order_item_id>', methods=['GET', 'POST'])
def review_product(order_id, product_id, order_item_id):
    # Periksa apakah pengguna sudah login dan memiliki peran yang sesuai
    if 'role' not in session or session['role'] != 'user':
        flash('Anda harus login sebagai pengguna untuk memberikan review.', 'warning')
        return redirect(url_for('login'))

    # Cari produk berdasarkan product_id dari database
    conn = get_db_connection()
    if conn is None:
        flash('Tidak dapat terhubung ke database.', 'danger')
        return redirect(url_for('order_details', order_id=order_id))

    try:
        cursor = conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM products WHERE product_id = %s", (product_id,))
        item = cursor.fetchone()
        if not item:
            flash('Produk tidak ditemukan.', 'danger')
            return redirect(url_for('order_details', order_id=order_id))
    finally:
        cursor.close()
        conn.close()

    if request.method == 'POST':
        # Ambil data review dari form
        review = request.form.get('review')
        rating = request.form.get('rating')

        if not review or not rating:
            flash('Harap isi ulasan dan berikan rating.', 'danger')
            return render_template('review_product.html', item=item, order_id=order_id)

        # Simpan review ke database
        conn = get_db_connection()
        if conn is None:
            flash('Tidak dapat menyimpan review ke database.', 'danger')
            return render_template('review_product.html', item=item, order_id=order_id)

        try:
            cursor = conn.cursor()
            cursor.execute(
                "INSERT INTO reviews (customer_id, product_id, review, rating) VALUES (%s, %s, %s, %s)",
                (session.get('user_id'), product_id, review, rating)
            )
            conn.commit()
            flash('Review berhasil disimpan.', 'success')
            cursor.execute(
                "UPDATE order_items SET review_status = %s WHERE order_item_id = %s",
                ('done', order_item_id,)
            )
            conn.commit()

        except Exception as e:
            conn.rollback()
            flash('Gagal menyimpan review.', 'error')
            print(f"Error: {e}")
        except Error as e:
            flash(f'Terjadi kesalahan saat menyimpan review: {e}', 'danger')
        finally:
            cursor.close()
            conn.close()

        return redirect(url_for('order_detail', order_id=order_id))

    # Halaman review produk
    return render_template('review_product.html', item=item, order_id=order_id)

# Registration route
@app.route('/admin/create_account', methods=['GET', 'POST'])
def create_account():
    if request.method == 'POST':
        email = request.form['email']
        username = request.form['username']
        fullname = request.form['fullname']
        password = request.form['password']
        confirm_password = request.form['confirm_password']
        role = request.form['role']  # Ambil input role dari form

        # Validasi password
        if password != confirm_password:
            flash('Passwords do not match!')
            return redirect(url_for('create_account'))  # Pastikan mengarah ke route yang benar

        # Hash password sebelum menyimpan ke database
        hashed_password = generate_password_hash(password)

        # Koneksi ke database
        conn = get_db_connection()
        if conn:
            cursor = conn.cursor()
            try:
                if role == 'employee':
                    # Insert data ke tabel "employee"
                    cursor.execute(
                        'INSERT INTO employee (email, username, fullname, password, role) VALUES (%s, %s, %s, %s, %s)',
                        (email, username, fullname, hashed_password, role)
                    )
                elif role == 'admin':
                    # Insert data ke tabel "admin"
                    cursor.execute(
                        'INSERT INTO admin (email, username, fullname, password, role) VALUES (%s, %s, %s, %s, %s)',
                        (email, username, fullname, hashed_password, role)
                    )
                else:
                    flash('Invalid role selected!')
                    return redirect(url_for('create_account'))

                conn.commit()
                flash('Create account successful!')
                return redirect(url_for('create_account'))
            except mysql.connector.IntegrityError:
                flash('Username or email already exists!')
                return redirect(url_for('create_account'))
            finally:
                cursor.close()
                conn.close()

    return render_template('create_account.html')

# Account List Route
@app.route('/admin/list_account', methods=['GET'])
def list_account():
    # Koneksi ke database
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        try:
            # Ambil parameter dari query string
            current_page = int(request.args.get('page', 1))
            role_filter = request.args.get('role', 'all')
            search_query = request.args.get('query', '')
            
            # Tentukan jumlah data per halaman
            per_page = 10
            offset = (current_page - 1) * per_page

            # Query dasar
            base_query = """
                SELECT account_id, email, username, fullname, role
                FROM (
                    SELECT admin_id AS account_id, email, username, fullname, role FROM admin
                    UNION ALL
                    SELECT employee_id AS account_id, email, username, fullname, role FROM employee
                    UNION ALL
                    SELECT customer_id AS account_id, email, username, fullname, 'customer' AS role FROM customers
                ) accounts
            """

            # Filter berdasarkan role
            if role_filter != 'all':
                base_query += " WHERE role = %s"

            # Filter berdasarkan search query
            if search_query:
                base_query += (" AND" if role_filter != 'all' else " WHERE")
                base_query += " (email LIKE %s OR username LIKE %s OR fullname LIKE %s)"

            # Hitung total data untuk pagination
            count_query = f"SELECT COUNT(*) FROM ({base_query}) subquery"
            params = []
            if role_filter != 'all':
                params.append(role_filter)
            if search_query:
                params.extend([f"%{search_query}%"] * 3)
            
            cursor.execute(count_query, params)
            total_data = cursor.fetchone()[0]

            # Query dengan limit dan offset
            base_query += " ORDER BY fullname ASC LIMIT %s OFFSET %s"
            params.extend([per_page, offset])

            cursor.execute(base_query, params)
            all_accounts = cursor.fetchall()

            # Format data untuk template
            accounts = [
                {"account_id": row[0], "email": row[1], "username": row[2], "fullname": row[3], "role": row[4]}
                for row in all_accounts
            ]

            # Hitung total halaman
            total_pages = (total_data + per_page - 1) // per_page

            return render_template('manage_account.html', accounts=accounts, current_page=current_page,
                                   total_pages=total_pages, role_filter=role_filter, search_query=search_query)
        finally:
            cursor.close()
            conn.close()
    else:
        flash('Failed to connect to the database.')
        return redirect(url_for('admin'))

@app.route('/admin/manage_account/<account_id>', methods=['GET', 'POST'])
def manage_account(account_id):
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        try:
            # Ambil data akun berdasarkan account_id
            query = """
                SELECT account_id, email, username, fullname, role
                FROM (
                    SELECT admin_id AS account_id, email, username, fullname, role FROM admin
                    UNION ALL
                    SELECT employee_id AS account_id, email, username, fullname, role FROM employee
                    UNION ALL
                    SELECT customer_id AS account_id, email, username, fullname, 'customer' AS role FROM customers
                ) accounts
                WHERE account_id = %s
            """
            cursor.execute(query, (account_id,))
            account = cursor.fetchone()

            if not account:
                flash('Account not found!', 'error')
                return redirect(url_for('list_account'))

            if request.method == 'POST':
                email = request.form.get('email', account[1])
                username = request.form.get('username', account[2])
                fullname = request.form.get('fullname', account[3])
                role = request.form.get('role', account[4])

                # Validasi email
                if not validate_email(email):
                    flash('Invalid email format!', 'error')
                    return redirect(url_for('manage_account', account_id=account_id))

                # Cek apakah email atau username sudah ada, kecuali untuk akun yang sedang diperbarui
                query_check = """
                    SELECT COUNT(*) FROM (
                        SELECT admin_id AS account_id, email, username FROM admin
                        UNION ALL
                        SELECT employee_id AS account_id, email, username FROM employee
                        UNION ALL
                        SELECT customer_id AS account_id, email, username FROM customers
                    ) accounts
                    WHERE (email = %s OR username = %s) AND account_id != %s
                """
                cursor.execute(query_check, (email, username, account_id))
                result = cursor.fetchone()

                if result[0] > 0:
                    flash('Email or username already exists!', 'error')
                    return redirect(url_for('manage_account', account_id=account_id))

                # Update data akun
                update_query = None
                if role == 'admin':
                    update_query = """
                        UPDATE admin
                        SET email = %s, username = %s, fullname = %s, role = %s
                        WHERE admin_id = %s
                    """
                elif role == 'employee':
                    update_query = """
                        UPDATE employee
                        SET email = %s, username = %s, fullname = %s, role = %s
                        WHERE employee_id = %s
                    """
                elif role == 'customer':
                    update_query = """
                        UPDATE customers
                        SET email = %s, username = %s, fullname = %s
                        WHERE customer_id = %s
                    """

                if update_query:
                    cursor.execute(update_query, (email, username, fullname, role, account_id))
                    conn.commit()
                    flash('Account updated successfully!', 'success')
                    return redirect(url_for('list_account'))
                else:
                    flash('Role not recognized for update.', 'error')

            # Render form untuk update akun
            return render_template('update_account.html', account={
                "account_id": account[0],
                "email": account[1],
                "username": account[2],
                "fullname": account[3],
                "role": account[4]
            })
        finally:
            cursor.close()
            conn.close()
    else:
        flash('Failed to connect to the database.', 'error')
        return redirect(url_for('list_account'))

@app.route('/admin/delete_account/<account_id>', methods=['GET', 'POST'])
def delete_account(account_id):
    conn = get_db_connection()
    if conn:
        cursor = conn.cursor()
        try:
            if request.method == 'POST':
                # Ambil data akun berdasarkan account_id
                query = """
                    SELECT account_id, role
                    FROM (
                        SELECT admin_id AS account_id, role FROM admin
                        UNION ALL
                        SELECT employee_id AS account_id, role FROM employee
                        UNION ALL
                        SELECT customer_id AS account_id, 'customer' AS role FROM customers
                    ) accounts
                    WHERE account_id = %s
                """
                cursor.execute(query, (account_id,))
                account = cursor.fetchone()

                if not account:
                    flash('Account not found!', 'error')
                    return redirect(url_for('list_account'))

                # Menambahkan konfirmasi penghapusan akun
                if 'delete' in request.form:
                    # Hapus data akun berdasarkan role
                    delete_query = None
                    if account[1] == 'admin':
                        delete_query = "DELETE FROM admin WHERE admin_id = %s"
                    elif account[1] == 'employee':
                        delete_query = "DELETE FROM employee WHERE employee_id = %s"
                    elif account[1] == 'customer':
                        delete_query = "DELETE FROM customers WHERE customer_id = %s"

                    if delete_query:
                        cursor.execute(delete_query, (account_id,))
                        conn.commit()

                        # Hapus juga data terkait di customer_profile jika ada
                        if account[1] == 'customer':
                            cursor.execute("DELETE FROM customer_profile WHERE customer_id = %s", (account_id,))
                            conn.commit()

                        flash('Account deleted successfully!', 'success')
                        return redirect(url_for('list_account'))
                    else:
                        flash('Role not recognized for delete.', 'error')

            else:
                flash('Are you sure you want to delete this account? Please confirm by clicking the delete button again.', 'warning')

        finally:
            cursor.close()
            conn.close()
    else:
        flash('Failed to connect to the database.', 'error')
        return redirect(url_for('list_account'))

from math import ceil
from flask import render_template, request, flash
from datetime import datetime

@app.route('/admin/financial_report', methods=['GET'])
def financial_report():
    current_page = request.args.get('page', 1, type=int)
    items_per_page = 10  # Jumlah item per halaman
    selected_year = request.args.get('year', 0, type=int)

    def fetch_years():
        current_year = datetime.now().year
        return list(range(2000, current_year + 1))  # Daftar tahun dari 2000 hingga saat ini

    # Mengambil daftar tahun untuk dropdown
    years = fetch_years()

    # Menjalankan prosedur SQL
    conn = get_db_connection()
    cursor = conn.cursor(dictionary=True)
    try:
        cursor.execute("CALL get_monthly_financial_report()")
        financial_report = cursor.fetchall()

        # Mengubah format tanggal dan filter berdasarkan tahun (jika ada)
        for row in financial_report:
            if 'transaction_month' in row:
                try:
                    row['transaction_month'] = datetime.strptime(row['transaction_month'], '%Y-%m')
                except ValueError:
                    row['transaction_month'] = None

        if selected_year != 0:
            financial_report = [
                row for row in financial_report
                if row['transaction_month'] and row['transaction_month'].year == selected_year
            ]

        # Pagination
        total_records = len(financial_report)
        total_pages = ceil(total_records / items_per_page)
        start_index = (current_page - 1) * items_per_page
        end_index = start_index + items_per_page
        financial_report = financial_report[start_index:end_index]

    except Exception as e:
        print(f"Error: {e}")
        flash('An error occurred while fetching financial data.', 'error')
        return render_template('error.html', message="Could not fetch financial report data.")
    finally:
        cursor.close()
        conn.close()

    # Menyajikan data laporan keuangan
    return render_template(
        'financial_report.html',
        financial_report=financial_report,
        years=years,
        selected_year=selected_year,
        current_page=current_page,
        total_pages=total_pages
    )


if __name__ == '__main__':
     app.run(host='0.0.0.0', port=5001, debug=True)
