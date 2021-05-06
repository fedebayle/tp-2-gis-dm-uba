import rasterio as rio
file = '/home/gis_dm_2021/clase13/results/results_merge_mask_maiz_roca.tif'
raster = rio.open(file).read()
raster_crop = raster[raster == 1]
sum_pixels = raster_crop.sum()
print(sum_pixels)
