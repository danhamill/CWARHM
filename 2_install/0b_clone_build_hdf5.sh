

export ZDIR='/p/work/danhamil/projects/CWARHM_data/installs/zlib-1.3.1'
export H5DIR='/p/work/danhamil/projects/CWARHM_data/installs/hdf5-1.14.4'
export NCDIR='/p/work/danhamil/projects/CWARHM_data/installs/netcdf-c-4.9.2'
export BLASDIR='/p/work/danhamil/projects/CWARHM_data/installs/OpenBLAS-v0.3.25'
export FC=gfortran
export F77=gfortran
export F90=gfortran
export CC="/opt/cray/pe/gcc/12.2.0/snos/bin/gcc"

# Find the line with the destination path
dest_line=$(grep -m 1 "^install_path_summa" ../0_control_files/control_active.txt) 

# Extract the path
summa_path=$(echo ${dest_line##*|}) 
summa_path=$(echo ${summa_path%%#*}) 


if [ "$summa_path" = "default" ]; then
  
 # Get the root path
 root_line=$(grep -m 1 "^root_path" ../0_control_files/control_active.txt)
 root_path=$(echo ${root_line##*|}) 
 root_path=$(echo ${root_path%%#*}) 
 summa_path="${root_path}/installs/summa/"
 zlib_path="${root_path}/installs/zlib/"
 hdf5_path="${root_path}/installs/hdf5/"
 netcdf_c_path="${root_path}/installs/netcdf-c/"
 netcdf_f_path="${root_path}/installs/netcdf-fortran/"
 openblas_path="${root_path}/installs/OpenBLAS"

fi

zlib_url="https://github.com/madler/zlib.git"
hdf5_url="https://github.com/HDFGroup/hdf5.git"
netcdf_c_url="http://github.com/Unidata/netcdf-c"
netcdf_f_url="http://github.com/Unidata/netcdf-fortran"
openblas_url="https://github.com/OpenMathLib/OpenBLAS"



echo "cloning ${hdf5_url} into ${hdf5_path}"
git clone --single-branch --branch hdf5_1.14.4 "$hdf5_url" "$hdf5_path"

module purge
module load intel-oneapi/2023.1.0
module load gcc/12.2.0

cd $hdf5_path
echo "Building hdf5"
./configure --with-zlib=${ZDIR} --prefix=${H5DIR} --enable-hl
make check
make install







