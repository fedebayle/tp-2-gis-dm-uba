import subprocess
import glob
import os
tile = '0000000000-0000012544'
images_ndvi = sorted(glob.glob(
    '/home/gis_dm_2021/tp-2/images/s2full/aoi/**/{tile}_ndvi.tif'.format(tile=tile)))
images_ndvi_otb = ' '.join(images_ndvi)
im_out_fname = '/home/gis_dm_2021/tp-2/images/results/{tile}_ndvi.tif'.format(
    tile=tile)
cmd = """bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;  otbcli_ConcatenateImages -il {im} -out {im_out}'""".format(
    im=images_ndvi_otb, im_out=im_out_fname)
print(cmd)
