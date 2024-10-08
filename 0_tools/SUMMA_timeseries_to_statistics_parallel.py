'''Loads timeseries of simulated variables and computes a variety of statistics.'''

import os
import glob
import xarray as xr
from pathlib import Path
import multiprocessing as mp

# Settings
src_dir = '/scratch/wknoben/summaWorkflow_data/domain_NorthAmerica/simulations/run1/SUMMA'
src_pat = 'run1_G*_timestep.nc'
des_dir = '/scratch/wknoben/summaWorkflow_data/domain_NorthAmerica/simulations/run1/statistics'
des_fil = 'run1_summa_day_stats_{}_{}_{}.nc'
settings= {'wallClockTime': 'mean'}
viz_fil = 'run1_summa_day_stats_{}_{}.nc'
viz_fil = viz_fil.format(','.join(settings.keys()),','.join(settings.values()))

# Make sure we're dealing with the right kind of inputs 
src_dir = Path(src_dir) 
des_dir = Path(des_dir)

# Ensure the output path exists
des_dir.mkdir(parents=True, exist_ok=True) 

# Get the names of all inputs
src_files = glob.glob(str( src_dir / src_pat ))
src_files.sort()

# -- functions
def run_loop(file):
    
    # extract the subset IDs
    subset = file.split('/')[-1].split('_')[1]
    
    # pass if file exists already
    if os.path.isfile(des_dir / 'run1_summa_day_stats_mean_wallClockTime_{}'.format(subset)):
        return
    
    # open file
    dat = xr.open_dataset(file)
    
    # compute the requested statistics
    for var,stat in settings.items():
        
        # Select the case
        if stat == 'mean':
            new = dat[var].mean(dim='time')
        elif stat == 'max':
            new = dat[var].max(dim='time')
        
        new.to_netcdf(des_dir / des_fil.format(stat,var,subset))
    return
    
def merge_subsets_into_one(src,pattern,des,name):
    
    '''Merges all files in {src} that match {pattern} into one file stored in /{des}/{name.nc}'''
    
    # Find all files
    src_files = glob.glob(str( src / pattern ))
    
    # Merge into one
    out = xr.merge([xr.open_dataset(file) for file in src_files])
    
    # save to file
    out.to_netcdf(des / name)
    
    return #nothing
# -- end functions

# -- start parallel processing
ncpus = int(os.environ.get('SLURM_CPUS_PER_TASK',default=1))
if __name__ == "__main__":
    pool = mp.Pool(processes=ncpus)
    pool.map(run_loop,src_files)
    pool.close()
# -- end parallel processing

# merge the individual files into one for further vizualization
merge_subsets_into_one(des_dir,des_fil.replace('{}','*'),des_dir,viz_fil)

# remove the individual files for cleanliness
for file in glob.glob(des_fil.replace('{}','*')):
    os.remove(file)