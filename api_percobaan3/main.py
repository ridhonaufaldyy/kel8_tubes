import logging
from os import path


from fastapi import Depends, Request, FastAPI, HTTPException


from fastapi.responses import FileResponse
from fastapi.security import OAuth2PasswordRequestForm,OAuth2PasswordBearer
from pydantic import BaseModel


from sqlalchemy.orm import Session


from database import SessionLocal, engine


from jose import jwt
import datetime

from fastapi.middleware.cors import CORSMiddleware
from fastapi import FastAPI

import crud, models, schemas
from typing import Dict,List

models.BaseDB.metadata.create_all(bind=engine)
app = FastAPI(title="Web service BarayaFood",
    description="Web service untuk quiz provis Mei 2024",
    version="0.0.1",)

app.add_middleware(
 CORSMiddleware,
 allow_origins=["*"],
 allow_credentials=True,
 allow_methods=["*"],
 allow_headers=["*"],
)


# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="token")


# Mendefinisikan temporary_data sebagai kamus kosong
temporary_data: Dict[str, int] = {}


@app.get("/")
async def root():
    return {"message": "Dokumentasi API: [url]:8000/docs"}# create user 

# create users
@app.post("/users/", response_model=schemas.User)
def create_user(user: schemas.UserDetails, db: Session = Depends(get_db)):
    db_user = crud.get_user_by_username(db, username=user.username)
    if db_user:
        raise HTTPException(status_code=400, detail="Error: Username sudah digunakan")
    return crud.create_user(db=db, user=user)

# hasil adalah akses token    
@app.post("/login") #,response_model=schemas.Token
async def login(user: schemas.UserCreate, db: Session = Depends(get_db)):
    if not authenticate(db,user):
        raise HTTPException(status_code=400, detail="Username atau password tidak cocock")

    # ambil informasi username
    user_login = crud.get_user_by_username(db,user.username)
    if user_login:
        access_token  = create_access_token(user.username)
        user_id = user_login.id
        return {"user_id":user_id,"access_token": access_token}
    else:
        raise HTTPException(status_code=400, detail="User tidak ditemukan, kontak admin")


#lihat detil user_id
@app.get("/get_users/{user_id}", response_model=schemas.UserDetailsNoPassword)
def read_user(user_id: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    usr = verify_token(token) 
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")
    
    # Create UserDetails instance from db_user
    user_details_no_password = schemas.UserDetailsNoPassword(
        username=db_user.username,
        fullname=db_user.fullname,
        nik=db_user.nik,
        email=db_user.email,
        telphone=db_user.telphone
    )
    return user_details_no_password

@app.get("/api/dokters/{dokter_id}", response_model=schemas.newGetDokter)
def read_dokter_by_id(dokter_id: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr = verify_token(token) 
    dokter = db.query(models.Dokter).filter(models.Dokter.id_dokter == dokter_id).first()
    if not dokter:
        raise HTTPException(status_code=404, detail="Dokter not found")
    return dokter

# tambah item ke keranjang
# response ada id (cart), sedangkan untuk paramater input  tidak ada id (cartbase)

@app.get("/tampilkan_semua_obat/", response_model=list[schemas.Obat])
def read_obats(skip: int = 0, limit: int = 100, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token)
    obats = crud.get_obats(db, skip=skip, limit=limit)
    return obats

@app.get("/obat_by_name/{nama_obat}", response_model=schemas.Obat)
def obat_by_name(nama_obat: str, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token) 
    db_obat = crud.get_obats_by_nama(db,nama_obat)
    if db_obat is None:
        raise HTTPException(status_code=404, detail="Obat not found")
    return 


@app.get("/checkup-history/{user_id}", response_model=list[schemas.CheckupHistory])
async def get_checkup_history(user_id: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token) 
    checkup_history = crud.riwayat_checkup(db, user_id)
    if not checkup_history:
        raise HTTPException(status_code=404, detail="Checkup history not found")
    return checkup_history

@app.get("/antrian/{user_id}", response_model=schemas.PendaftaranResponse)
async def read_last_antrian(user_id: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    usr = verify_token(token)
    # if usr.id != user_id:
    #     raise HTTPException(status_code=403, detail="Not authorized to view this user's antrian")
    
    antrian = crud.get_last_antrian_by_user_id(db, user_id)
    if antrian is None:
        raise HTTPException(status_code=404, detail="Antrian not found")
    
    return schemas.PendaftaranResponse(
        id_pendaftaran=antrian.id_pendaftaran,
        selectedCategory=antrian.kategori,
        address=antrian.alamat,
        doctorId=antrian.id_dokter,
        metodePembayaran=antrian.metode_pembayaran,
        userId=antrian.id_user,
        nama_pasien=antrian.nama_pasien,  # Pastikan ini ada
        poliId=antrian.id_poliklinik,
        keluhan=antrian.keluhan,
        harga=antrian.harga,
        no_antrian=antrian.no_antrian,
        tanggal_pendaftaran=antrian.tanggal_pendaftaran,
        status_pembayaran=antrian.status_pembayaran,
        status_antrian=antrian.status_antrian  
    )

@app.get("/dokter_by_name/{nama_dokter}", response_model=schemas.Dokter)
def dokter_by_name(nama_dokter: str, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token) 
    db_dokter = crud.get_dokter_by_nama(db,nama_dokter)
    if db_dokter is None:
        raise HTTPException(status_code=404, detail="Dokter not found")
    return db_dokter

# @app.get("/dokter_by_kategori/", response_model=list[schemas.Dokter])
# def read_items(kategori:str, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
#     usr =  verify_token(token)
#     dokters = crud.get_dokter_by_kategori(db,kategori)
#     return dokters

@app.get("/doctors_poliklinik/{id_poliklinik}", response_model=List[schemas.NewDokterBase])
def read_doctors_by_poliklinik(id_poliklinik: int, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    usr = verify_token(token)
    doctors = db.query(models.Dokter).filter(models.Dokter.id_poliklinik == id_poliklinik).all()
    if not doctors:
        raise HTTPException(status_code=404, detail="Doctors not found for this poliklinik ID")
    return doctors


@app.put("/edit_users/{user_id}", response_model=schemas.User)
def update_user(user_id: int, user: schemas.UserDetails, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    usr = verify_token(token) 
    db_user = crud.get_user(db, user_id=user_id)
    if db_user is None:
        raise HTTPException(status_code=404, detail="User not found")

    # Update user details
    db_user.username = user.username
    db_user.fullname = user.fullname
    db_user.nik = user.nik
    db_user.email = user.email
    db_user.telphone = user.telphone

    # Update password if provided
    if user.password:
        db_user.hashed_password = crud.hashPassword(user.password)

    db.commit()
    db.refresh(db_user)
    return db_user

###################  status

@app.post("/janji_temu/", response_model=schemas.JanjiTemu)
def create_janji_temu(janji_temu: schemas.JanjiTemuCreate, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr = verify_token(token) 
    try:
        # Ambil data dari objek janji_temu
        id_user = janji_temu.id_user
        id_dokter = janji_temu.id_dokter
        waktu_pertemuan = janji_temu.waktu_pertemuan

        # Buat objek JanjiTemu dari data yang diberikan
        db_janji_temu = models.JanjiTemu(
            id_user=id_user,
            id_dokter=id_dokter,
            waktu_pertemuan=waktu_pertemuan
        )

        # Simpan objek ke database
        db.add(db_janji_temu)
        db.commit()
        db.refresh(db_janji_temu)

        # Kembalikan objek yang sudah disimpan sebagai respons
        return db_janji_temu
    except Exception as e:
        # Tangani kesalahan dan kembalikan respons yang sesuai
        raise HTTPException(status_code=500, detail=str(e))

# @app.post("/janji_temu/", response_model=schemas.JanjiTemu)
# def create_janji_temu(janji_temu: schemas.JanjiTemuCreate, db: Session = Depends(get_db)):
#     db_janji_temu = models.JanjiTemu(**janji_temu.dict())
#     db.add(db_janji_temu)
#     db.commit()
#     db.refresh(db_janji_temu)
#     return db_janji_temu

@app.get("/janji_temu/{user_id}", response_model=list[schemas.JanjiTemu])
def get_janji_temu_by_user(user_id: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr = verify_token(token)
    janji_temu = db.query(models.JanjiTemu).filter(models.JanjiTemu.id_user == user_id).all()
    if not janji_temu:
        raise HTTPException(status_code=404, detail="Janji Temu not found")
    return janji_temu

@app.get("/api/dokters/", response_model=list[schemas.newGetDokter])
def read_dokters(skip: int = 0, limit: int = 100, db: Session = Depends(get_db), token: str = Depends(oauth2_scheme)):
    usr = verify_token(token)
    dokters = db.query(models.Dokter).offset(skip).limit(limit).all()
    return [schemas.newGetDokter.from_orm(dokter) for dokter in dokters]


@app.get("/queue/{poliklinik_id}", response_model=list[schemas.QueueResponse])
def get_queue_by_poliklinik_id(poliklinik_id: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token) 
    queue = crud.get_queue_by_poliklinik_id(db, poliklinik_id)
    if not queue:
        raise HTTPException(status_code=404, detail="Queue not found for this polyclinic")
    return queue

@app.post("/pendaftaran/", response_model=schemas.PendaftaranResponse)
def create_pendaftaran(pendaftaran: schemas.PendaftaranCreate, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token)
    db_pendaftaran = crud.create_pendaftaran(db=db, pendaftaran=pendaftaran)

    response = schemas.PendaftaranResponse(
        id_pendaftaran=db_pendaftaran.id_pendaftaran,
        selectedCategory=db_pendaftaran.kategori,
        address=db_pendaftaran.alamat,
        doctorId=db_pendaftaran.id_dokter,
        nama_pasien=db_pendaftaran.nama_pasien,
        metodePembayaran=db_pendaftaran.metode_pembayaran,
        userId=db_pendaftaran.id_user,
        poliId=db_pendaftaran.id_poliklinik,
        no_antrian=db_pendaftaran.no_antrian,
        tanggal_pendaftaran=db_pendaftaran.tanggal_pendaftaran,
        status_pembayaran=db_pendaftaran.status_pembayaran,
        keluhan=db_pendaftaran.keluhan,
        harga=db_pendaftaran.harga,
        # Pastikan harga ada di sini
    )

    return response

@app.put("/update_status_pembayaran/user/{id_user}")
def update_status_by_user_id(id_user: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token) 

    # Temukan pendaftaran terakhir untuk user yang diberikan
    pendaftaran = crud.get_pendaftaran_by_user_id(db, id_user)
    if not pendaftaran:
        raise HTTPException(status_code=404, detail="Pendaftaran not found for this user")
    
    # Perbarui status pembayaran menjadi "sudah_bayar"
    pendaftaran.status_pembayaran = "sudah_bayar"
    db.commit()
    
    return {"message": "Status updated successfully"}

@app.put("/update_status_pendaftaran_proses/user/{id_user}")
def update_status_by_user_id(id_user: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token)
    # Temukan pendaftaran terakhir untuk user yang diberikan
    pendaftaran = crud.get_pendaftaran_by_user_id(db, id_user)
    if not pendaftaran:
        raise HTTPException(status_code=404, detail="Pendaftaran not found for this user")
    
    # Perbarui status pembayaran menjadi "sudah_bayar"
    pendaftaran.status_antrian = "proses"
    db.commit()
    
    return {"message": "Status updated successfully"}

@app.put("/update_status_pendaftaran_terlewat/user/{id_user}")
def update_status_by_user_id(id_user: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token)
    # Temukan pendaftaran terakhir untuk user yang diberikan
    pendaftaran = crud.get_pendaftaran_by_user_id(db, id_user)
    if not pendaftaran:
        raise HTTPException(status_code=404, detail="Pendaftaran not found for this user")
    
    # Perbarui status pembayaran menjadi "sudah_bayar"
    pendaftaran.status_antrian = "terlewat"
    db.commit()
    
    return {"message": "No Antrian Anda Terlewat Harap Daftar Kembali"}

@app.put("/update_status_pendaftaran_selesai/user/{id_user}")
def update_status_by_user_id(id_user: int, db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token)
    # Temukan pendaftaran terakhir untuk user yang diberikan
    pendaftaran = crud.get_pendaftaran_by_user_id(db, id_user)
    if not pendaftaran:
        raise HTTPException(status_code=404, detail="Pendaftaran not found for this user")
    
    # Perbarui status pembayaran menjadi "sudah_bayar"
    pendaftaran.status_antrian = "selesai"
    db.commit()
    
    return {"message": "Selesai"}

#status diset manual dulu karena cukup rumit kalau ditangani constraitnya


#user membayar
@app.post("/pembayaran/{user_id}")
def bayar(user_id:int,  db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    return crud.pembayaran(db=db,user_id=user_id)

@app.get("/get_status/{user_id}")
def last_status(user_id:int,  db: Session = Depends(get_db),token: str = Depends(oauth2_scheme)):
    usr =  verify_token(token) #bisa digunakan untuk mengecek apakah user cocok (tdk boleh akses data user lain)
    return crud.get_last_status(db,user_id)


######################## AUTH

# periksa apakah username ada dan passwordnya cocok
# return boolean TRUE jika username dan password cocok
def authenticate(db,user: schemas.UserCreate):
    user_cari = crud.get_user_by_username(db=db, username=user.username)
    if user_cari:
        return (user_cari.hashed_password == crud.hashPassword(user.password))
    else:
        return False    
    

SECRET_KEY = "ilkom_upi_top"


def create_access_token(username):
    # info yang penting adalah berapa lama waktu expire
    expiration_time = datetime.datetime.utcnow() + datetime.timedelta(hours=24)    # .now(datetime.UTC)
    access_token = jwt.encode({"username":username,"exp":expiration_time},SECRET_KEY,algorithm="HS256")
    return access_token    


def verify_token(token: str):
    try:
        payload = jwt.decode(token,SECRET_KEY,algorithms=["HS256"])  # bukan algorithm,  algorithms (set)
        username = payload["username"]  
     
       
    # exception jika token invalid
    except jwt.ExpiredSignatureError:
        raise HTTPException(status_code=401, detail="Unauthorize token, expired signature, harap login")
    except jwt.JWSError:
        raise HTTPException(status_code=401, detail="Unauthorize token, JWS Error")
    except jwt.JWTClaimsError:
        raise HTTPException(status_code=401, detail="Unauthorize token, JWT Claim Error")
    except jwt.JWTError:
        raise HTTPException(status_code=401, detail="Unauthorize token, JWT Error")   
    except Exception as e:
        raise HTTPException(status_code=401, detail="Unauthorize token, unknown error"+str(e))
    
    return {"user_name": username}



    
# internal untuk testing, jangan dipanggil langsung
# untuk swagger  .../doc supaya bisa auth dengan tombol gembok di kanan atas
# kalau penggunaan standard, gunakan /login

@app.post("/token", response_model=schemas.Token)
async def token(req: Request, form_data: OAuth2PasswordRequestForm = Depends(),db: Session = Depends(get_db)):

    f = schemas.UserCreate
    f.username = form_data.username
    f.password = form_data.password
    if not authenticate(db,f):
        raise HTTPException(status_code=400, detail="username or password tidak cocok")

    #info = crud.get_user_by_username(form_data.username)
    # email = info["email"]   
    # role  = info["role"]   
    username  = form_data.username

    #buat access token\
    # def create_access_token(user_name,email,role,nama,status,kode_dosen,unit):
    access_token  = create_access_token(username)

    return {"access_token": access_token, "token_type": "bearer"}