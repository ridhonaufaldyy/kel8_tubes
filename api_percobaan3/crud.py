from datetime import datetime
from sqlalchemy.orm import Session
from sqlalchemy.sql import func
import models, schemas
import bcrypt
from sqlalchemy import desc,DateTime

SALT = b'$2b$12$0nFckzktMD0Fb16a8JsNA.'

def get_user(db: Session, user_id: int):
    return db.query(models.User).filter(models.User.id == user_id).first()

def get_user_by_username(db: Session, username: str):
    return db.query(models.User).filter(models.User.username == username).first()

def get_dokter_by_fullname(db: Session, fullname: str):
    return db.query(models.Dokter).filter(models.Dokter.fullname == fullname).first()

def get_dokter_by_kategori(db: Session, kategori: str):
    return db.query(models.Dokter).filter(models.Dokter.spesialis == kategori).all()

# def get_users(db: Session, skip: int = 0, limit: int = 100):
#     return db.query(models.User).offset(skip).limit(limit).all()

# delete semua user
def delete_all_user(db: Session):
    jum_rec = db.query(models.User).delete()
    db.commit()
    return jum_rec

def hashPassword(passwd: str):
    bytePwd = passwd.encode('utf-8')
    pwd_hash = bcrypt.hashpw(bytePwd, SALT)
    return pwd_hash

# def get_fullname_by_user_id(db: Session, id_user: int):
#     user = db.query(models.User).filter(models.User.id == id_user).first()
#     if user:
#         return user.fullname
#     else:
#         return None


# ============
# status dan pembayaran
# def get_doctors_by_poliklinik(db: Session, id_poliklinik: int):
#     return db.query(models.Dokter).filter(models.Dokter.id_poliklinik == id_poliklinik).all()

def get_queue_by_poliklinik_id(db: Session, poliklinik_id: int):
    return (
        db.query(
            models.Pendaftaran.status_antrian,
            models.Pendaftaran.no_antrian,
            models.Pendaftaran.nama_pasien,
            models.Pendaftaran.status_antrian,
            models.Pendaftaran.status_pembayaran
        )
        # .join(models.User, models.Pendaftaran.id_user == models.User.id)  # Lakukan operasi join dengan menentukan kolom kunci
        .filter(models.Pendaftaran.id_poliklinik == poliklinik_id)
        .all()
    )    
    
# def create_janji_temu(db: Session, janji_temu: schemas.JanjiTemuCreate):
#     db_janji_temu = models.JanjiTemu(**janji_temu.dict())
#     db.add(db_janji_temu)
#     db.commit()
#     db.refresh(db_janji_temu)
#     return db_janji_temu

# def get_janji_temu(db: Session, janji_temu_id: int):
#     return db.query(models.JanjiTemu).filter(models.JanjiTemu.id == janji_temu_id).first()
    
def get_is_carts_empty_userid(db: Session, user_id:int):
    exists = db.query(models.Cart.id).filter(models.Cart.user_id == user_id).exists()
    if db.query(exists).scalar():
        return False
    else:
        return True

def get_last_status(db: Session,user_id:int):
    last_status = db.query(models.Status).filter(models.Status.user_id == user_id).order_by(desc(models.Status.timestamp)).first()
    if last_status:
        return {"status":last_status}
    else:
        #tidak ada status, cek cart
        if get_is_carts_empty_userid(db,user_id=user_id):
            #kosong, update status
            insert_status(db,user_id=user_id,status="keranjang_kosong")
            return get_last_status(db,user_id=user_id)
        

def riwayat_checkup(db: Session, user_id: int):
    return (
        db.query(
            models.Pendaftaran.tanggal_pendaftaran,
            models.Pendaftaran.nama_pasien,
            models.Dokter.fullname,
            models.Dokter.keterangan,
            models.Poliklinik.nama_poliklinik,
            # models.User.fullname
        )
        .join(models.User, models.Pendaftaran.id_user == models.User.id)
        .join(models.Dokter, models.Pendaftaran.id_dokter == models.Dokter.id_dokter)
        .join(models.Poliklinik, models.Pendaftaran.id_poliklinik == models.Poliklinik.id_poliklinik)
        .filter(models.Pendaftaran.id_user == user_id)
        .all()
    )          
        
def pembayaran (db: Session, user_id:int):
    status = get_last_status(db,user_id=user_id)
    # hanya proses yang statusnya belum_bayar, selain itu abaikan 
    temp = status["status"]
    if temp.status=="belum_bayar":
        insert_status(db=db,user_id=user_id,status="sudah_bayar")
        return {"status":"status diupdate sudah bayar"}
    else:
        return {"status":"tidak diproses, cek status"}

def insert_status(db:Session, user_id:int, status: str):
    db_status = models.Status(user_id = user_id, status = status )
    db.add(db_status)
    db.commit()
    db.refresh(db_status)
    return db_status
       
######### user

def create_user(db: Session, user: schemas.UserDetails):
    hashed_password = hashPassword(user.password)
    db_user = models.User(
        username=user.username, 
        hashed_password=hashed_password,
        fullname = user.fullname,
        nik = user.nik,
        email = user.email,
        telphone = user.telphone
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    return db_user

def create_pendaftaran(db: Session, pendaftaran: schemas.PendaftaranCreate):
    # Mengambil tanggal dan waktu sekarang
    now = datetime.utcnow()
    
    # Mencari entri terakhir pada hari ini di poliklinik yang sama
    last_entry = (
        db.query(models.Pendaftaran)
        .filter(
            models.Pendaftaran.tanggal_pendaftaran >= now.replace(hour=0, minute=0, second=0, microsecond=0),
            models.Pendaftaran.tanggal_pendaftaran < now.replace(hour=23, minute=59, second=59, microsecond=999999),
            models.Pendaftaran.id_poliklinik == pendaftaran.poliId
        )
        .order_by(models.Pendaftaran.no_antrian.desc())
        .first()
    )

    # Menentukan nomor antrian berikutnya
    next_antrian_number = 1 if not last_entry else last_entry.no_antrian + 1

    # Membuat entri pendaftaran baru
    db_pendaftaran = models.Pendaftaran(
        id_user=pendaftaran.userId,
        alamat=pendaftaran.address,
        id_dokter=pendaftaran.doctorId,
        kategori=pendaftaran.selectedCategory,
        keluhan=pendaftaran.keluhan,
        harga=pendaftaran.harga,  # Pastikan harga diset
        metode_pembayaran=pendaftaran.metodePembayaran,
        nama_pasien = pendaftaran.nama_pasien, #
        status_antrian="pending",
        status_pembayaran="belum_bayar",
        no_antrian=next_antrian_number,
        tanggal_pendaftaran=now,
        id_poliklinik=pendaftaran.poliId
    )

    # Menambahkan dan menyimpan entri baru ke database
    db.add(db_pendaftaran)
    db.commit()
    db.refresh(db_pendaftaran)

    return db_pendaftaran

def get_antrian_by_id(db: Session, antrian_id: int):
    return db.query(models.Pendaftaran).filter(models.Pendaftaran.id_user == antrian_id).first()

def get_last_antrian_by_user_id(db: Session, user_id: int):
    return db.query(models.Pendaftaran) \
             .filter(models.Pendaftaran.id_user == user_id) \
             .order_by(models.Pendaftaran.tanggal_pendaftaran.desc()) \
             .first()
             
             
def get_obats(db: Session, skip: int = 0, limit: int = 100):
    return db.query(models.Obat).offset(skip).limit(limit).all()

def get_obats_by_nama(db: Session, nama_obat: str):
    return db.query(models.Obat).filter(models.Obat.nama == nama_obat).first()

def get_dokter_by_nama(db: Session, nama_dokter: str):
    return db.query(models.Dokter).filter(models.Dokter.fullname == nama_dokter).first()


# ambil item dengan id tertentu
def get_item_by_id(db: Session, item_id: int):
    return db.query(models.Item).filter(models.Item.id == item_id).first()

def get_poliklinik_by_id(id: int,db: Session):
    return db.query(models.Poliklinik).filter(models.Poliklinik.id == id).first()

# ambil item yang cocok dengan keyword di deskripsi
def get_item_by_keyword(db: Session, keyword: str):
    #Artikel.Benennung.like("%"+prop+"%")
    return db.query(models.Item).filter(models.Item.description.ilike("%"+keyword+"%")).all()
    #return db.query(models.Item).filter(models.Item.like("%"+keyword+"%")).first()

def get_pendaftaran_by_user_id(db: Session, id_user: int):
    return db.query(models.Pendaftaran).filter(models.Pendaftaran.id_user == id_user).order_by(models.Pendaftaran.id_pendaftaran.desc()).first()

# def create_pendaftaran(db: Session, pendaftaran_data: schemas.PendaftaranCreate):
#     db_pendaftaran = models.Pendaftaran(**pendaftaran_data.dict())
#     db.add(db_pendaftaran)
#     db.commit()
#     db.refresh(db_pendaftaran)
#     return db_pendaftaran