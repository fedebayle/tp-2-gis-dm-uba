################EJERCICIO 5################

#PolygonClassStatistics
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_PolygonClassStatistics  -in /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif \
                        -vec /home/gis_dm_2021/tp-2/verdad_campo.shp \
                        -field  id \
                        -out ~/clase13/results/classes_stat.xml'

#SampleSelection

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_SampleSelection -in /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif \
                       -vec /home/gis_dm_2021/tp-2/verdad_campo.shp \
                       -instats ~/clase13/results/classes_stat.xml \
                       -field id \
                       -strategy smallest \
                       -outrates ~/clase13/results/rates.csv \
                       -out ~/clase13/results/samples.sqlite'

#SampleExtraction

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_SampleExtraction -in /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif \
                        -vec ~/clase13/results/samples.sqlite \
                        -outfield prefix \
                        -outfield.prefix.name band_ \
                        -field id'


#ComputeImageStatistics

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_ComputeImagesStatistics -il  /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif \
                               -out ~/clase13/results/images_statistics.xml'




#TrainVectorClassifier

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_TrainVectorClassifier -io.vd ~/clase13/results/samples.sqlite \
			     -io.stats ~/clase13/results/images_statistics.xml \
                             -cfield id \
                             -classifier rf \
                             -classifier.rf.max 5 \
                             -classifier.rf.nbtrees 150 \
                             -io.out ~/clase13/results/rfModel.txt \
                             -io.confmatout ~/clase13/results/ConfusionMatrixRF.csv \
                             -feat band_0 band_1 band_2 band_3 band_4 band_5'


#ImageClassifier

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_ImageClassifier -in /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif  \
                       -imstat ~/clase13/results/images_statistics.xml \
                       -model ~/clase13/results/rfModel.txt \
                       -out ~/clase13/results/0000000000-0000000000_predict.tif'

################EJERCICIO 6################

#ImageClassifier

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_ImageClassifier -in /home/gis_dm_2021/tp-2/images/results/0000000000-0000010496_ndvi.tif  \
                       -imstat ~/clase13/results/images_statistics.xml \
                       -model ~/clase13/results/rfModel.txt \
                       -out ~/clase13/results/0000000000-0000010496_predict.tif'

################EJERCICIO 7################

gdal_merge.py -ot UInt32 -o ~/clase13/imgs/results_merge.tif ~/clase13/results/0000000000-0000000000_predict.tif ~/clase13/results/0000000000-0000010496_predict.tif

gdal_translate -ot UInt32 ~/clase13/results/results_merge_temp.tif ~/clase13/results/results_merge.tif


################EJERCICIO 8################

gdal_calc.py \
-A ~/clase13/imgs/results_merge.tif  \
--A_band=1 \
-B ~/clase13/imgs/mask_agri_aoi_res.tif \
--B_band=1 \
--calc="((B==1)*A)+((B==0)*0)" \
--outfile ~/clase13/results/results_merge_mask_temp.tif

gdal_translate -ot UInt32 ~/clase13/results/results_merge_mask_temp.tif ~/clase13/results/results_merge_mask.tif

################EJERCICIO 9################

gdal_calc.py \
-A ~/clase13/results/results_merge_mask.tif  \
--A_band=1 \
--calc="(((A==1) | (A==4))*1)+((A!=1) & (A!=4))*0" \
--outfile ~/clase13/results/results_merge_mask_soja.tif

gdal_calc.py \
-A ~/clase13/results/results_merge_mask.tif  \
--A_band=1 \
--calc="(((A==2) | (A==3))*1)+((A!=2) & (A!=3))*0" \
--outfile ~/clase13/results/results_merge_mask_maiz.tif

gdal_calc.py \
-A ~/clase13/results/results_merge_mask.tif  \
--A_band=1 \
--calc="(A==5)*1+(A!=5)*0" \
--outfile ~/clase13/results/results_merge_mask_girasol.tif


ogr2ogr -sql "SELECT * FROM departamentos WHERE nombre='PTE ROQUE SAENZ PENA'" -dialect sqlite /home/gis_dm_2021/tp-2/departamentos_rsp.shp /home/gis_dm_2021/tp-2/departamentos.shp
ogr2ogr -sql "SELECT * FROM departamentos WHERE nombre='GENERAL VILLEGAS'" -dialect sqlite /home/gis_dm_2021/tp-2/departamentos_villegas.shp /home/gis_dm_2021/tp-2/departamentos.shp
ogr2ogr -sql "SELECT * FROM departamentos WHERE nombre='GENERAL ROCA'" -dialect sqlite /home/gis_dm_2021/tp-2/departamentos_roca.shp /home/gis_dm_2021/tp-2/departamentos.shp


#ROQUE SAENZ PEÑA

gdalwarp -cutline /home/gis_dm_2021/tp-2/departamentos_rsp.shp -crop_to_cutline  ~/clase13/results/results_merge_mask_soja.tif ~/clase13/results/results_merge_mask_soja_rsp.tif
gdalwarp -cutline /home/gis_dm_2021/tp-2/departamentos_rsp.shp -crop_to_cutline  ~/clase13/results/results_merge_mask_maiz.tif ~/clase13/results/results_merge_mask_maiz_rsp.tif


#GENERAL ROCA
gdalwarp -cutline /home/gis_dm_2021/tp-2/departamentos_roca.shp -crop_to_cutline  ~/clase13/results/results_merge_mask_soja.tif ~/clase13/results/results_merge_mask_soja_roca.tif
gdalwarp -cutline /home/gis_dm_2021/tp-2/departamentos_roca.shp -crop_to_cutline  ~/clase13/results/results_merge_mask_maiz.tif ~/clase13/results/results_merge_mask_maiz_roca.tif


#GENERAL VILLEGAS

gdalwarp -cutline /home/gis_dm_2021/tp-2/departamentos_villegas.shp -crop_to_cutline ~/clase13/results/results_merge_mask_soja.tif ~/clase13/results/results_merge_mask_soja_villegas.tif
gdalwarp -cutline /home/gis_dm_2021/tp-2/departamentos_villegas.shp -crop_to_cutline  ~/clase13/results/results_merge_mask_maiz.tif ~/clase13/results/results_merge_mask_maiz_villegas.tif

################EJERCICIO 11################

gdalwarp -t_srs EPSG:4326 -of GTiff -cutline /home/gis_dm_2021/clase13/segs/aoi_segs.shp -cl aoi_segs -crop_to_cutline /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif /home/gis_dm_2021/clase13/segs/ndvi_clip.tif

#MeanShiftSmoothing

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;
otbcli_MeanShiftSmoothing \
-in /home/gis_dm_2021/clase13/segs/ndvi_clip.tif \
-fout /home/gis_dm_2021/clase13/segs/ndvi_clip_smooth.tif \
-foutpos /home/gis_dm_2021/clase13/segs/ndvi_clip_smooth_pos.tif \
-spatialr 5 \
-ranger 0.1 \
-maxiter 100'


#LSMSSegmentation
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;
otbcli_LSMSSegmentation -in /home/gis_dm_2021/clase13/segs/ndvi_clip_smooth.tif \
-inpos /home/gis_dm_2021/clase13/segs/ndvi_clip_smooth_pos.tif \
-out /home/gis_dm_2021/clase13/segs/ndvi_clip_seg.tif \           -spatialr 5 \
-ranger 0.1 \
-minsize 5 \
-tilesizex 1024 \
-tilesizey 1024'


#LSMSVectorization
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_LSMSVectorization -in /home/gis_dm_2021/clase13/segs/ndvi_clip.tif \
  -inseg /home/gis_dm_2021/clase13/segs/ndvi_clip_seg.tif \
  -out /home/gis_dm_2021/clase13/segs/ndvi_clip_seg.shp'


################EJERCICIO 12################

#MeanShiftSmoothing

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;
otbcli_MeanShiftSmoothing \
-in /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif  \
-fout /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_smooth.tif \
-foutpos /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_smooth_pos.tif \
-spatialr 5 \
-ranger 0.1 \
-maxiter 100'


#LSMSSegmentation
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;
otbcli_LSMSSegmentation -in /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_smooth.tif \
-inpos /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_smooth_pos.tif \
-out /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_seg.tif \           -spatialr 5 \
-ranger 0.1 \
-minsize 5 \
-tilesizex 1024 \
-tilesizey 1024'


#LSMSVectorization
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_LSMSVectorization -in /home/gis_dm_2021/tp-2/images/results/0000000000-0000000000_ndvi.tif \
  -inseg /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_seg.tif \
  -out /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_seg.shp'

#Para el tile 0000000000-0000010496

#MeanShiftSmoothing

bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;
otbcli_MeanShiftSmoothing \
-in /home/gis_dm_2021/tp-2/images/results/0000000000-0000010496_ndvi.tif  \
-fout /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_smooth.tif \
-foutpos /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_smooth_pos.tif \
-spatialr 5 \
-ranger 0.1 \
-maxiter 100'


#LSMSSegmentation
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile;
otbcli_LSMSSegmentation -in /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_smooth.tif \
-inpos /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_smooth_pos.tif \
-out /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_seg.tif \
-spatialr 5 \
-ranger 0.1 \
-minsize 5 \
-tilesizex 1024 \
-tilesizey 1024'


#LSMSVectorization
bash -c 'source ~/OTB-7.2.0-Linux64/otbenv.profile; otbcli_LSMSVectorization -in /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi.tif \
  -inseg /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_seg.tif \
  -out /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_seg.shp'


#Luego mergeamos ambas capas vectoriales.
ogr2ogr -f "ESRI Shapefile" /home/gis_dm_2021/clase13/segs/ndvi_seg.shp /home/gis_dm_2021/clase13/segs/0000000000-0000000000_ndvi_seg.shp
ogr2ogr -f "ESRI Shapefile" -append -update /home/gis_dm_2021/clase13/segs/ndvi_seg.shp /home/gis_dm_2021/clase13/segs/0000000000-0000010496_ndvi_seg.shp
