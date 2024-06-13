from datetime import datetime
from database import BaseDB
from sqlalchemy import Boolean, Column, ForeignKey, Integer, Nullable, String, func, Date, DateTime
from sqlalchemy.orm import relationship
from sqlalchemy.orm import Mapped
from typing import List
from sqlalchemy import Table


#import List
class JanjiTemu(BaseDB):
    __tablename__ = 'janji_temu'

    id = Column(Integer, primary_key=True, index=True)
    id_user = Column(Integer, ForeignKey('users.id'))
    id_dokter = Column(Integer, ForeignKey('dokter.id_dokter'))
    waktu_pertemuan = Column(DateTime, default=datetime.utcnow)

    # Define relationships
    user = relationship("User", back_populates="janji_temu")
    dokter = relationship("Dokter", back_populates="janji_temu")





class User(BaseDB):
    __tablename__ = 'users'

    id = Column(Integer, primary_key=True, index=True)
    username = Column(String, unique=True, index=True)
    fullname = Column(String,nullable=False)
    nik = Column(String,nullable=False)
    email = Column(String, unique=True, index=True)
    telphone = Column(String,nullable=False)
    hashed_password = Column(String)
    
    pendaftarans = relationship("Pendaftaran", back_populates="user")
    janji_temu = relationship("JanjiTemu", back_populates="user")
    # relasi_status = relationship("Status", back_populates="user")

class Dokter(BaseDB):
    __tablename__ = "dokter"
    id_dokter = Column(Integer, primary_key=True)
    fullname = Column(String,unique=True)
    email = Column(String,nullable=False)
    telphone = Column(String,nullable=False)
    id_poliklinik = Column(Integer, ForeignKey('poliklinik.id_poliklinik'), nullable=False)
    keterangan = Column(String,nullable=False)
    rating = Column(Integer,nullable=False) 
    harga = Column(Integer,nullable=False)
    deskripsi = Column(String,nullable=False)
    image_url = Column(String, nullable=False)
    
    polikliniks = relationship("Poliklinik", back_populates="dokters")
    pendaftarans = relationship("Pendaftaran", back_populates="dokters")
    janji_temu = relationship("JanjiTemu", back_populates="dokter")
    
class Obat(BaseDB):
    __tablename__ = "obat"
    id_obat = Column(Integer, primary_key=True)
    nama = Column(String)
    jenis = Column(String)
    harga = Column(String)
    desc = Column(String)    


class Poliklinik(BaseDB):
    __tablename__ = 'poliklinik'
    id_poliklinik = Column(Integer, primary_key=True)
    nama_poliklinik = Column(String, nullable=False)
    
    dokters = relationship("Dokter", back_populates="polikliniks")
    pendaftarans = relationship("Pendaftaran", back_populates="polikliniks")

class Pendaftaran(BaseDB):
    __tablename__ = 'pendaftaran'
    id_pendaftaran = Column(Integer, primary_key=True, index=True)
    id_user = Column(Integer, ForeignKey('users.id'))
    nama_pasien = Column(String, nullable=False)  
    alamat = Column(String, nullable=False)
    id_dokter = Column(Integer, ForeignKey('dokter.id_dokter'), nullable=False)
    kategori = Column(String, nullable=False)
    keluhan = Column(String, nullable=False)
    harga = Column(Integer, nullable=False)
    no_antrian = Column(Integer, nullable=False)
    status_antrian = Column(String, nullable=False)
    status_pembayaran = Column(String, nullable=False)
    metode_pembayaran = Column(String, nullable=False)
    tanggal_pendaftaran = Column(DateTime, default=datetime.utcnow)
    id_poliklinik = Column(Integer, ForeignKey('poliklinik.id_poliklinik'), nullable=False)

    user = relationship("User", back_populates="pendaftarans")
    dokters = relationship("Dokter", back_populates="pendaftarans")
    polikliniks = relationship("Poliklinik", back_populates="pendaftarans")