
module purge
module load intel-oneapi/2023.1.0
module load gcc/12.2.0

export ZDIR='/p/work/danhamil/projects/CWARHM_data/installs/zlib-1.3.1'
export H5DIR='/p/work/danhamil/projects/CWARHM_data/installs/hdf5-1.14.4'
export NCDIR='/p/work/danhamil/projects/CWARHM_data/installs/netcdf-c-4.9.2'
export BLASDIR='/p/work/danhamil/projects/CWARHM_data/installs/OpenBLAS-v0.3.25'
export FC=gfortran
export F77=gfortran
export F90=gfortran
export CC="/opt/cray/pe/gcc/12.2.0/snos/bin/gcc"

root_path="/p/work/danhamil/projects/CWARHM_data/installs/summa"
zlib_path="${root_path}/installs/zlib/"
hdf5_path="${root_path}/installs/hdf5/"
netcdf_c_path="${root_path}/installs/netcdf-c/"
netcdf_f_path="${root_path}/installs/netcdf-fortran/"
openblas_path="${root_path}/installs/OpenBLAS"



zlib_url="https://github.com/madler/zlib.git"
hdf5_url="https://github.com/HDFGroup/hdf5.git"
netcdf_c_url="http://github.com/Unidata/netcdf-c"
netcdf_f_url="http://github.com/Unidata/netcdf-fortran"
openblas_url="https://github.com/OpenMathLib/OpenBLAS"

#===================================================================

echo "cloning ${zlib_url} into ${zlib_path}"
git clone --single-branch --branch v1.3.1 "$zlib_url" "$zlib_path"

owd=$(pwd)
cd "$zlib_path"

git remote add upstream "$zlib_url"
git pull upstream v1.3.1

echo "Building zlib"
./configure --prefix=${ZDIR}
make check
make install

#===================================================================


echo "cloning ${hdf5_url} into ${hdf5_path}"
git clone --single-branch --branch hdf5_1.14.4 "$hdf5_url" "$hdf5_path"

cd $hdf5_path
echo "Building hdf5"
./configure --with-zlib=${ZDIR} --prefix=${H5DIR} --enable-hl
make check
make install

#================================================================
echo "cloning ${netcdf_c_url} into ${netcdf_c_path}"
git clone --single-branch --branch v4.9.2 "$netcdf_c_url" "$netcdf_c_path"

echo "Building netcdf-c"
cd "$netcdf_c_path"
CPPFLAGS="-I${H5DIR}/include -I${ZDIR}/include" LDFLAGS="-L${H5DIR}/lib -L${ZDIR}/lib" ./configure --prefix=${NCDIR}
make check
make install

#===================================================================
#
echo "cloning ${netcdf_f_url} into ${netcdf_f_path}"
git clone --single-branch --branch v4.6.1 "$netcdf_f_url" "$netcdf_f_path"

cd "$netcdf_f_path"
export NFDIR=${NCDIR}
export CPPFLAGS=$CPPFLAGS" -I${NCDIR}/include"
export LDFLAGS=$LDFLAGS" -L${NCDIR}/lib"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${NCDIR}/lib
export LIBS=$LIBS" -lnetcdf"
./configure --prefix=${NCDIR}
make all check install

#============================================================================
echo "cloning ${openblas_url} into ${openblas_path}"
git clone --single-branch --branch v0.3.25 "$openblas_url" "$openblas_path"

cd "$openblas_path"
make
make PREFIX=${BLASDIR} install

#============================================================================





