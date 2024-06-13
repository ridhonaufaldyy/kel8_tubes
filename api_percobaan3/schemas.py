from pydantic import BaseModel
from sqlalchemy import DateTime
from datetime import  date,datetime

# user
class UserDetailsNoPassword(BaseModel):
    username: str
    fullname: str
    nik: str
    email: str
    telphone: str

class UserBase(BaseModel):
    username: str 
    
class UserCreate(UserBase):
    password: str
    
class UserDetails(UserCreate):
    fullname : str
    nik : str
    email : str
    telphone : str


class User(UserBase):
    id: int
    class Config:
        orm_mode = True

# dokter

class DokterBase(BaseModel):
    # id_dokter : int
    fullname : str
    email : str
    telphone : str
    id_poliklinik : int
    keterangan : str
    rating : int
    harga : int
    deskripsi : str
    image_url: str


class DokterCreate(DokterBase):
    pass

class Dokter(DokterBase):
    id_dokter: int
    class Config:
        orm_mode = True
        
class NewDokterBase(BaseModel):
    id_dokter : int
    fullname : str
    email : str
    telphone : str
    id_poliklinik : int
    keterangan : str
    rating : int
    harga : int
    
class newGetDokter(BaseModel):
    id_dokter: int
    fullname: str
    email: str
    telphone: str
    id_poliklinik: int
    keterangan: str
    rating: int
    harga: int
    deskripsi: str
    image_url: str

    class Config:
        from_attributes = True
        
# Obat

class ObatBase(BaseModel):
    nama : str
    jenis : str
    harga : str
    img_name : str
    desc : str

class ObatCreate(ObatBase):
    pass

class Obat(ObatCreate):
    id: int
    class Config:
        orm_mode = True

class PendaftaranBase(BaseModel):
    selectedCategory: str
    address: str
    doctorId: int
    metodePembayaran: str
    userId: int
    nama_pasien: str
    poliId: int
    keluhan: str
    harga: int  # Pastikan harga ada di sini

class PendaftaranCreate(PendaftaranBase):
    status_antrian: str = "pending"
    status_pembayaran: str = "belum_bayar"

class PendaftaranResponse(PendaftaranCreate):
    id_pendaftaran: int
    no_antrian: int
    tanggal_pendaftaran: datetime
    status_pembayaran: str

    class Config:
        orm_mode = True
                
class StatusUpdate(BaseModel):
    status: str
    
class QueueResponse(BaseModel):
    no_antrian: int
    nama_pasien: str
    status_antrian : str;
    status_pembayaran : str
    
class CheckupHistory(BaseModel):
    tanggal_pendaftaran : datetime
    nama_pasien : str
    fullname : str
    keterangan : str
    nama_poliklinik : str
    
class JanjiTemuBase(BaseModel):
    id_user: int
    id_dokter: int
    waktu_pertemuan: datetime
    # Tambahkan field lainnya sesuai kebutuhan

class JanjiTemuCreate(JanjiTemuBase):
    pass

class JanjiTemu(JanjiTemuBase):
    id: int
    class Config:
        orm_mode = True


class Token(BaseModel):
    access_token: str
    token_type: str
