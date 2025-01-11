#/bin/bash

# Summa installation prerequisites
# D.Hamill
# 11 Jan 25

module purge
module load intel-oneapi/2023.0.0
module load gcc/12.2.0

export FC=gfortran
export F77=gfortran
export F90=gfortran
export CC="/opt/cray/pe/gcc/12.2.0/bin/gcc"

export INSTALL="//p/home/danhamil/installs"
export WRK="${INSTALL}/wrk"






#===================================================================
echo "working on zlib installation"
cd $WRK
zlib_url="https://github.com/madler/zlib/releases/download/v1.3.1/zlib-1.3.1.tar.gz"
wget $zlib_url

export PKG=zlib
export V=1.3.1

cd $INSTALL
[[ -d ${PKG}-${V} ]] && tar xf wrk/zlib-${V}.tar.gz

cd ${PKG}-${V}
export ZDIR=$(pwd)

echo "Building zlib"
./configure --prefix=${INSTALL}/${PKG}-${V}
ls .
make
make check
make install 

#===================================================================
echo "working on hdf5 installation"
cd $WRK
hdf5_url="https://github.com/HDFGroup/hdf5/archive/refs/tags/hdf5_1.14.5.tar.gz"
wget $hdf5_url

PKG=hdf5
V=1.14.5

cd $INSTALL
[[ -d ${PKG}-${V} ]] && tar wrk/hdf5-${V}.tar.gz
cd ${PKG}-${V}
export H5DIR=$(pwd)

[[! -d build]] && mkdir build
cd build

echo "Building hdf5"
./configure --with-zlib=${ZDIR} --prefix=${H5DIR} --enable-hl
make check
make INSTALL

#================================================================
echo "working on netcdf-c installation"
cd $WRK
netcdf_c_url="https://github.com/Unidata/netcdf-c/archive/refs/tags/v4.9.2.tar.gz"
wget $netcdf_c_url

PKG=netcdf-c
V=4.9.2

cd $INSTALL
[[ -d ${PKG}-${V} ]] && tar wrk/V${V}.tar.gz

cd ${PKG}-${V}
export NCDIR=$(pwd)

echo "Building netcdf-c"

CPPFLAGS="-I${H5DIR}/include -I${ZDIR}/include" LDFLAGS="-L${H5DIR}/lib -L${ZDIR}/lib" ./configure --prefix=${NCDIR}
make check
make INSTALL

#===================================================================
#
echo "working on netcdf-fortran installation"
cd $WRK
netcdf_f_url="https://github.com/Unidata/netcdf-fortran/archive/refs/tags/v4.6.1.tar.gz"
wget $netcdf_f_url

PKG=netcdf-fortran
V=4.6.1

cd $INSTALL
[[ -d ${PKG}-${V} ]] && tar wrk/V${V}.tar.gz    

cd ${PKG}-${V}

echo "Building netcdf-fortran"

export NFDIR=${NCDIR}
export CPPFLAGS=$CPPFLAGS" -I${NCDIR}/include"
export LDFLAGS=$LDFLAGS" -L${NCDIR}/lib"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NCDIR}/lib
export LIBS=$LIBS" -lnetcdf"
./configure --prefix=${NCDIR}
make all check INSTALL

#============================================================================
echo "working on openblas installation"
cd $WRK
openblas_url="https://github.com/OpenMathLib/OpenBLAS/archive/refs/tags/v0.3.28.tar.gz"
wget $openblas_url

PKG=openblas
V=0.3.28

cd $INSTALL
[[ -d ${PKG}-${V} ]] && tar wrk/V${V}.tar.gz

cd ${PKG}-${V}      
export BLASDIR=$(pwd)

echo "Building openblas"
make
make check
make PREFIX=${BLASDIR} INSTALL

#============================================================================





