'''Template script for generating trait_estimate configuration JSON files.
'''

import os
import json
import glob
import sys

home = sys.argv[3]

filename  = sys.argv[1]
foldername = sys.argv[2]

images_dir   = os.path.join(home,foldername)
export_dir   = home+"/traits/"

config_file = os.path.join(home,"trait_config_"+filename+".json")

config_dict = {}
config_dict['file_type'] = 'envi'
config_dict["output_dir"] = export_dir
config_dict['bad_bands'] =[[300,400],[1337,1430],[1800,1960],[2450,2600]]

# Input data settings for NEON
#################################################################
config_dict['file_type'] = 'neon'
images=glob.glob(os.path.join(images_dir,"*.h5"))
images.sort()
config_dict["input_files"] = images

# Input data settings for ENVI
#################################################################
''' Only differnce between ENVI and NEON settings is the specification
of the ancillary datasets (ex. viewing and solar geometry). All hytools
functions assume that the ancillary data and the image date are the same
size, spatially, and are ENVI formatted files.

The ancillary parameter is a dictionary with a key per image. Each value
per image is also a dictionary where the key is the dataset name and the
value is list consisting of the file path and the band number.
'''

#config_dict['file_type'] = 'envi'
#aviris_anc_names = ['path_length','sensor_az','sensor_zn',
#                    'solar_az', 'solar_zn','phase','slope',
#                    'aspect', 'cosine_i','utc_time']
#images= glob.glob("*img")
#images.sort()
#config_dict["input_files"] = images

#config_dict["anc_files"] = {}
#anc_files = glob.glob("*ort")
#anc_files.sort()
#for i,image in enumerate(images):
#    config_dict["anc_files"][image] = dict(zip(aviris_anc_names,
#                                                [[anc_files[i],a] for a in range(len(aviris_anc_names))]))

config_dict['num_cpus'] = len(images)

# Assign correction coefficients
##########################################################
''' Specify correction(s) to apply and paths to coefficients.
'''

config_dict['corrections'] = ['topo','brdf']

topo_files = glob.glob("coeffs/*topo_coeffs_kkovach.json")
topo_files.sort()
config_dict["topo"] =  dict(zip(images,topo_files))

brdf_files = glob.glob("coeffs/*_brdf_coeffs_kkovach.json")
brdf_files.sort()
config_dict["brdf"] =  dict(zip(images,brdf_files))

# Select wavelength resampling type
##########################################################
'''Wavelength resampler will only be used if image wavelengths
and model wavelengths do not match exactly

See image_correct_json_generate.py for options.

'''
config_dict["resampling"]  = {}
config_dict["resampling"]['type'] =  'cubic'

# Masks
##########################################################
'''Specify list of masking layers to be appended to the
trait map. Each will be placed in a seperate layer.

For no masks provide an empty list: []
'''
config_dict["masks"] = [["ndi", {'band_1': 850,'band_2': 660,
                                  'min': 0.1,'max': 1.0}],
                        ['neon_edge',{'radius': 30}]]

# Define trait coefficients
##########################################################
models = glob.glob('trait_models/*.json')
models.sort()
config_dict["trait_models"]  = models

with open(config_file, 'w') as outfile:
    json.dump(config_dict,outfile,indent=3)