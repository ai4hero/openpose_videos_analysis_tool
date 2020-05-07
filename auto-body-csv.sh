#!/bin/sh


DATE=$(date +%Y%m%d%H%M)
echo --------------------Welcome------------------------------
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo "【启动步态分析系统数据处理工具帧数据转为0-24坐标点2D坐标】"
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo --------------------------------------------------------
#echo "请输入待测试者编号并启动步态分析系统(支持英文字母和数字，例如：ML6001)："
#read name_id

#处理数据
#获取openpose输出文件夹文件名列表
ls ./net_resolution > ./temp/file_list
#逐行读取文件名，并处理数据


for i in `cat ./temp/file_list`;
do
cat ./net_resolution/$i > ./temp/frame_data
# {"version":1.3,"people":[{"person_id":[-1],"pose_keypoints_2d":[378.929,123.152,0.877119,378.89,155.758,0.872947,350.195,153.183,0.892028,339.828,193.621,0.869565,339.77,226.273,0.862476,402.429,155.77,0.872775,419.366,181.912,0.869706,423.341,201.415,0.846088,378.881,234.069,0.811141,360.64,234.067,0.817502,361.958,287.554,0.868445,365.856,338.449,0.863844,392.025,234.092,0.809229,390.693,287.58,0.891105,390.627,338.501,0.879153,371.154,119.24,0.947652,382.851,119.255,0.926506,365.885,121.872,0.820416,391.953,123.175,0.881414,398.469,351.572,0.779562,402.405,350.163,0.865674,384.124,342.374,0.762656,360.648,350.249,0.878573,354.131,348.91,0.832516,369.755,341.068,0.806068],"face_keypoints_2d":[],"hand_left_keypoints_2d":[],"hand_right_keypoints_2d":[],"pose_keypoints_3d":[],"face_keypoints_3d":[],"hand_left_keypoints_3d":[],"hand_right_keypoints_3d":[]}]}

awk -F '"pose_keypoints_2d":\['  '{print $2}' ./temp/frame_data |awk -F '\],"face_keypoints_2d"' '{print $1}' > ./temp/body_data
echo "进行中(正在逐一处理每一帧文件)..."
echo "frame_ID,points_ID,x,y,c" >> ./csv_video_frames.csv
  for j in `seq 0 3 72`;
  do
  echo $i > ./temp/frame_id
  awk -F '_' '{print $2}' ./temp/frame_id > ./temp/frame_num
  cat ./temp/frame_num|tr '\n' ' ' >> ./csv_video_frames.csv
  echo ","|tr '\n' ' ' >> ./csv_video_frames.csv
  point_id=$(expr $j / 3)
  echo "point_ID-$point_id"|tr '\n' ' ' >> ./csv_video_frames.csv
  echo ","|tr '\n' ' '  >> ./csv_video_frames.csv

# 378.929,123.152,0.877119,378.89,155.758,0.872947,350.195,153.183,0.892028,339.828,193.621,0.869565,339.77,226.273,0.862476,402.429,155.77,0.872775

  val=$(expr $j + 1)
# echo $val
  awk -F ',' '{print $'$val'}' ./temp/body_data|tr '\n' ' '  >> ./csv_video_frames.csv
  echo ","|tr '\n' ' '  >> ./csv_video_frames.csv

  val=$(expr $j + 2)
#  echo $val
  awk -F ',' '{print $'$val'}' ./temp/body_data|tr '\n' ' '  >> ./csv_video_frames.csv
  echo ","|tr '\n' ' '  >> ./csv_video_frames.csv

#可信度 
  val=$(expr $j + 3)
#  echo $val
  awk -F ',' '{print $'$val'}' ./temp/body_data  >> ./csv_video_frames.csv
 
  done
done

#!/bin/sh
#一次实验中，body某个点的时序csv数据，一次数据处理得到25个点的25个文件。

echo --------------------Welcome------------------------------
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo "【启动步态分析系统数据处理工具body某个点的时序csv数据，一次数据处理得到25个点的25个文件】"
echo "╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱   ',' ',' ',' ','☆　╱★　╱╱　╱"
echo --------------------------------------------------------
#echo "请输入待测试者编号并启动步态分析系统(支持英文字母和数字，例如：ML6001)："
#read name_id

for i in `seq 0 24`;
do
grep -w "point_ID-$i" ./csv_video_frames.csv >> ./point-$i.csv

done





